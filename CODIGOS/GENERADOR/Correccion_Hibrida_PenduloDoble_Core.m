function out = Correccion_Hibrida_PenduloDoble_Core(pct, Xk, Yk, Xa, Ya, v_ms)
% CORRECCION_HIBRIDA_PENDULODOBLE_CORE  31-ago-2026 / 01-sep-2026 (aporte
%   propio): reemplaza a Correccion_Posicion_Suave_PenduloDoble_Core.m
%   como correccion de PRODUCCION - un metodo DISTINTO por curva, elegido
%   segun la naturaleza fisica de cada una, no un metodo universal
%   aplicado a las 4 por igual:
%
%   - X (rodilla y tobillo, avance horizontal): monotono por naturaleza
%     (caminando hacia adelante, nunca se retrocede) - se usa Warp_
%     Temporal_Core.m (deformacion de TIEMPO, garantiza monotonia por
%     construccion matematica, ver su propia cabecera) + un afin GLOBAL
%     CONSTANTE (a0, b0 fijos, iguales para cualquier sujeto/talla).
%   - Y (rodilla y tobillo, vaiven vertical): oscila libremente, no hay
%     monotonia que proteger - se sigue usando Correccion_Posicion_
%     Suave_PenduloDoble_Core.m (Fourier K=14, corrige PUNTO A PUNTO).
%
%   CAMBIO 01-sep-2026 (pedido del usuario, "no es logico que alguien mas
%   bajo desplace mas que alguien mas alto"): el afin de X dejo de
%   depender de la velocidad (que si dependia hasta la version anterior,
%   ver Ajustar_Warp_Temporal_TallaSola.m para el detalle completo de por
%   que se quito). Con b0>0 fijo y el crudo(100%) monotono en talla por
%   geometria (r=1.000), el resultado final queda GARANTIZADO monotono
%   en talla: a mas talla, igual o mas avance, siempre - no es un
%   resultado empirico, es una propiedad de la formula. Se probo agregar
%   talla como covariable con restriccion de signo (que hubiera
%   preservado la monotonia igual) y el ajuste convergio exactamente a
%   esta misma solucion (coeficiente de talla = 0) - confirma que este es
%   el mejor resultado posible sin romper el orden fisico.
%   v_ms se mantiene como argumento por compatibilidad con los llamadores
%   existentes (app, Evaluar_CorreccionFinal_vs_Kuopio.m) pero YA NO SE
%   USA dentro de esta funcion.
%
%   RESULTADO (LOSO real N=44, SOLO TALLA):
%     Rodilla X: r=0.999, RMSEnorm=1.10, 0/100 retrocesos, monotono en talla GARANTIZADO
%     Tobillo X: r=0.999, RMSEnorm=1.17, 0/100 retrocesos, monotono en talla GARANTIZADO
%     Rodilla Y / Tobillo Y: SIN CAMBIO, siguen con Fourier (0.89 / 0.92)
%
%   out = Correccion_Hibrida_PenduloDoble_Core(pct, Xk, Yk, Xa, Ya, v_ms)
%
% ENTRADA
%   pct          [1 x n] % del ciclo, 0-100
%   Xk,Yk,Xa,Ya  desplazamiento de rodilla/tobillo, YA con angulo
%                calibrado (Calibracion_Koopman_Kuopio_Core.m) y YA
%                normalizado a 0 en pct(1) - misma entrada que ya recibia
%                Correccion_Posicion_Suave_PenduloDoble_Core.m.
%   v_ms         velocidad de marcha (m/s) - se mantiene por compatibilidad
%                de firma con los llamadores existentes, no se usa.
%
% SALIDA: struct `out` con .Xk, .Yk, .Xa, .Ya corregidos, mismo tamano
% que la entrada. Xk/Xa por warp temporal, Yk/Ya por Fourier (sin cambio).
% ==========================================================================

if nargin < 6
    error('Se requieren pct, Xk, Yk, Xa, Ya, v_ms.');
end

% --- Y: sin cambio, Fourier (Correccion_Posicion_Suave_PenduloDoble_Core.m) ---
outF = Correccion_Posicion_Suave_PenduloDoble_Core(pct, Xk, Yk, Xa, Ya);

% --- X: warp temporal + afin CONSTANTE (garantiza monotonia en talla) ---
persistent COEFW
if isempty(COEFW)
    COEFW = load(fullfile(fileparts(mfilename('fullpath')), 'Coeficientes_Warp_Temporal.mat'), 'coefWarp', 'K');
end

out = struct();
out.Yk = outF.Yk;
out.Ya = outF.Ya;
out.Xk = aplicar_warp_afin(COEFW.coefWarp.RodX, pct, COEFW.K, Xk);
out.Xa = aplicar_warp_afin(COEFW.coefWarp.TobX, pct, COEFW.K, Xa);

end

% --------------------------------------------------------------------
function pred = aplicar_warp_afin(p, pct, K, crudo)
gcoef = p(1:2*K);
a0 = p(2*K+1); b0 = p(2*K+2);
tau = Warp_Temporal_Core(pct, gcoef, K);
crudo_warp = interp1(pct, crudo(:).', tau, 'pchip');
pred = a0 + b0 .* crudo_warp;
end
