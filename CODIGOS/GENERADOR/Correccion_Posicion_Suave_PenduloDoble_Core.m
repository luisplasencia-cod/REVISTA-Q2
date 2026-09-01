function out = Correccion_Posicion_Suave_PenduloDoble_Core(pct, Xk, Yk, Xa, Ya)
% CORRECCION_POSICION_SUAVE_PENDULODOBLE_CORE  31-ago-2026: version FINAL
% de la correccion de posicion - reemplaza a Correccion_Posicion_
% PenduloDoble_Core.m (16 tramos, con costura visible entre tramos).
%
% MOTIVO DEL CAMBIO (pedido explicito del usuario, 31-ago-2026, "que se
% pueda hacer algo para suavizarlo"): la version de 16 tramos tenia una
% pequena discontinuidad de valor en cada frontera de tramo - visible en
% las figuras y, para un simulador con motores reales, un salto de
% velocidad/aceleracion en cada frontera. Se reemplazo por una funcion
% CONTINUA: en vez de 16 constantes (a_q, b_q) por tramo, a(t) y b(t) son
% series de Fourier periodicas del %ciclo (matematica mas compleja,
% autorizada explicitamente por el usuario), ajustadas por minimos
% cuadrados (lineal en los coeficientes de Fourier, ver derivacion
% abajo). El numero de armonicos (K=14) se eligio igual que los 16
% tramos: por barrido LOSO real (N=44) hasta encontrar la meseta estable
% del RMSEnorm, no a mano (Analisis_Correccion_Fase5_FourierK.m).
%
% RESULTADO (LOSO real N=44, combinada con la calibracion de angulo ya
% existente, Calibracion_Koopman_Kuopio_Core.m - ver Analisis_
% Correccion_Fase6_ComboSuave.m). Estos numeros son de la busqueda de
% familia de correccion, con antropometria/velocidad REALES de Kuopio
% (compara estrategias entre si, no es el resultado final de la app):
%   Rodilla X: r=0.998, RMSEnorm=0.52 (Excelente)
%   Rodilla Y: r=0.945, RMSEnorm=0.87 (Excelente)
%   Tobillo X: r=0.998, RMSEnorm=0.77 (Bueno)
%   Tobillo Y: r=0.985, RMSEnorm=0.87 (Excelente)
% Mejor o empatada con las otras 3 variantes probadas (posicion sola
% escalon/suave, combinada escalon) en las 4 curvas a la vez.
%
% REAJUSTADO 31-ago-2026 (tarde, Refit_CorreccionFinal_TallaSola.m) con
% SOLO TALLA como entrada (igual pipeline que la app) - los coeficientes
% de Coeficientes_CorreccionFinal.mat que esta funcion carga son estos,
% no los de arriba. Resultado honesto (LOSO real N=44, SOLO talla):
%   Rodilla X: r=0.999, RMSEnorm=1.01 (Bueno)
%   Rodilla Y: r=0.949, RMSEnorm=0.89 (Excelente)
%   Tobillo X: r=0.998, RMSEnorm=1.11 (Bueno)
%   Tobillo Y: r=0.988, RMSEnorm=0.92 (Excelente)
%
% DERIVACION: corregido(t) = a(t) + b(t)*crudo(t), con
%   a(t) = A . Phi(t),  b(t) = B . Phi(t)
%   Phi(t) = [1, cos(2*pi*t/100), sin(2*pi*t/100), ..., cos(2*pi*K*t/100), sin(2*pi*K*t/100)]
% Sustituyendo: real(t) ~= Phi(t).A + (crudo(t)*Phi(t)).B - LINEAL en
% [A;B], se resuelve por minimos cuadrados (ver Calcular_Coeficientes_
% CorreccionFinal.m para el ajuste de produccion, N=44 completo).
%
% IMPORTANTE - orden del pipeline: esta funcion espera que el CRUDO de
% entrada ya venga de angulos CALIBRADOS (Calibracion_Koopman_Kuopio_
% Core.m aplicado ANTES de Cinematica_DoblePendulo_Core) - los
% coeficientes de aqui se ajustaron sobre esa base, no sobre angulo
% crudo puro. Aplicarla sobre posicion de angulo crudo sin calibrar es
% una combinacion NO validada (ver Analisis_Correccion_Fase4/6 para la
% comparacion completa de las 4 variantes).
%
% LIMITACION DECLARADA (igual que la version anterior): coeficientes
% ajustados con los 44 sujetos de Kuopio (talla 161-186.6cm) - fuera de
% ese rango es extrapolacion sin verificar.
%
%   out = Correccion_Posicion_Suave_PenduloDoble_Core(pct, Xk, Yk, Xa, Ya)
%
% ENTRADA
%   pct        [1 x n] % del ciclo, 0-100
%   Xk,Yk,Xa,Ya  desplazamiento de rodilla/tobillo, YA con angulo
%              calibrado (Calibracion_Koopman_Kuopio_Core.m) y YA
%              normalizado a 0 en pct(1) - salida de Cinematica_
%              DoblePendulo_Core.m
%
% SALIDA: struct `out` con .Xk, .Yk, .Xa, .Ya corregidos (curva
% CONTINUA, sin escalones), mismo tamano que la entrada.
%
% Funciona con CUALQUIER longitud de arreglo.
% ==========================================================================

if nargin < 5
    error('Se requieren pct, Xk, Yk, Xa, Ya.');
end

persistent COEF
if isempty(COEF)
    datos = load(fullfile(fileparts(mfilename('fullpath')), 'Coeficientes_CorreccionFinal.mat'), 'coefPos', 'K');
    COEF = datos;
end
K = COEF.K;

pct = pct(:).';
n = numel(pct);
Phi = ones(n, 2*K+1);
w = 2*pi*pct/100;
for k = 1:K
    Phi(:, 2*k)   = cos(k*w);
    Phi(:, 2*k+1) = sin(k*w);
end

entrada = struct('Xk', Xk(:).', 'Yk', Yk(:).', 'Xa', Xa(:).', 'Ya', Ya(:).');
campos = {'Xk','Yk','Xa','Ya'};
mapa_campo = struct('Xk','RodX', 'Yk','RodY', 'Xa','TobX', 'Ya','TobY');
out = struct();
m = 2*K+1;
for c = 1:numel(campos)
    camp = campos{c};
    v = entrada.(camp);
    if numel(v) ~= n
        error('%s debe tener el mismo largo que pct (%d). Se recibio %d.', camp, n, numel(v));
    end
    coef = COEF.coefPos.(mapa_campo.(camp));
    A = coef(1:m); B = coef(m+1:end);
    at = (Phi*A).'; bt = (Phi*B).';
    % NOTA (31-ago-2026): se probo forzar el cierre exacto en pct(1)
    % restando el propio valor inicial (salida-salida(1)) - REVERTIDO:
    % empeoraba fuerte el RMSEnorm de X (rodilla 0.53->1.53, tobillo
    % 0.77->3.31) porque el ajuste global de Fourier a veces tiene un
    % residuo real (no numerico) en t=0 que, al restarlo como constante,
    % desplaza TODA la curva (incluidos los puntos ya bien ajustados en
    % t>0, que son los que de verdad puntuan en el LOSO). El cierre
    % exacto en 0 para el CSV se resuelve en la etapa de EXPORTACION
    % (Escribir_CSV_Simulador.m ya normaliza cada fase a (0,0) con su
    % propio primer punto), no aqui - mantener esta funcion "tal cual
    % sale" del ajuste, sin normalizacion adicional.
    out.(camp) = at + bt .* v;
end

end
