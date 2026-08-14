function resultado = TOST_Core(x, y, margen, opciones)
% TOST_CORE  Prueba de equivalencia TOST (two one-sided tests,
%            Schuirmann 1987) sobre una metrica escalar (0D) - pico,
%            ROM, tiempo-al-pico, etc., tipicamente la salida de
%            Extraer_Features0D.m.
%
%   resultado = TOST_Core(x, y, margen)
%   resultado = TOST_Core(x, y, margen, opciones)
%
% Por que existe este archivo: SPM1D_Core.m (y cualquier prueba t
% clasica) responde "¿hay diferencia significativa?" - con el N modesto
% de este articulo, la respuesta puede salir "no" simplemente por falta
% de potencia, no porque el simulador de verdad reproduzca la curva.
% TOST responde una pregunta distinta y mas fuerte: "¿la diferencia es
% lo bastante chica como para no importar?", declarando ANTES un margen
% de equivalencia. Ver DISCUSION_Q2.md P-3 (candidato B) - es la pieza
% que mas protege el argumento central del articulo ante un revisor Q2.
%
% ENTRADA
%   x, y      vectores de una metrica 0D por ensayo/sujeto (salida de
%             Extraer_Features0D.m: .pico, .ROM, .pico_x, etc.)
%             - Diseno PAREADO (mismo ensayo/sujeto medido en ambas
%               condiciones): numel(x) == numel(y).
%             - Diseno INDEPENDIENTE (dos grupos que no se corresponden
%               1 a 1): numel(x) y numel(y) pueden diferir.
%   margen    margen de equivalencia, mismas unidades que x,y. Puede ser:
%               - escalar E: margen simetrico [-E, +E]
%               - vector [lo hi]: margen asimetrico (lo debe ser < 0)
%             No hay valor por defecto - es una decision metodologica
%             que debe declararse explicitamente y a priori (ver
%             GUIA_INTERPRETACION.md seccion 2 para como elegirlo, p.ej.
%             a partir de la variabilidad ensayo-a-ensayo del sujeto
%             original, ya calculable con Extraer_Features0D.m sobre
%             REFERENCIAS/*.mat).
%   opciones  struct opcional con cualquiera de estos campos:
%     .pareado    (default: true si numel(x)==numel(y), false si no -
%                  mismo criterio que SPM1D_Core.m; puede forzarse)
%     .alpha      (default 0.05) nivel de cada prueba de una cola. El
%                  TOST completo, a diferencia de una prueba de dos
%                  colas, NO se corrige por 2: es una propiedad conocida
%                  del procedimiento de Schuirmann (dos pruebas alpha
%                  de una cola dan una prueba de equivalencia alpha
%                  global, no alpha/2).
%     .nombre_metrica  (default '') para el reporte
%     .unidad     (default '') para el reporte
%
% METODOLOGIA (Schuirmann, 1987; TOST de bioequivalencia, estandar
% adoptado en biomecanica para "equivalencia" en vez de "no diferencia")
%   1. Diferencia media observada d = mean(x-y) [pareado] o
%      mean(x)-mean(y) [independiente], con su error estandar SE y
%      grados de libertad gl segun el diseno.
%   2. Dos pruebas t de una cola:
%        H0_inferior: verdadera diferencia <= margen(1)  (demasiado
%                     negativa) - se rechaza si d esta significativamente
%                     por ENCIMA de margen(1)
%        H0_superior: verdadera diferencia >= margen(2)  (demasiado
%                     positiva) - se rechaza si d esta significativamente
%                     por DEBAJO de margen(2)
%   3. Se concluye EQUIVALENCIA (dentro del margen declarado) solo si
%      AMBAS nulas se rechazan, es decir si p_TOST = max(p_inferior,
%      p_superior) < alpha. Criterio grafico equivalente: el IC de
%      (1-2*alpha) para d cae enteramente dentro de [margen(1),margen(2)]
%      (p.ej. IC90% para alpha=0.05 - no IC95%, es otra propiedad
%      conocida del procedimiento, no un error de tipeo).
%
% SALIDA: struct `resultado` con la diferencia media, su IC(1-2*alpha),
% los dos p-valores de una cola, el p-valor TOST, y la conclusion de
% equivalencia (logical) - listo para citar en Resultados.
%
% Requiere: Statistics and Machine Learning Toolbox (tinv, tcdf) - mismo
% requisito que CODIGOS/CALIBRACION/Calibracion_Offset_Core.m y
% CODIGOS/ESTADISTICA/BlandAltman_Core.m.
% ==========================================================================

if nargin < 4, opciones = struct(); end

x = x(:); y = y(:);
nX = numel(x); nY = numel(y);

def = struct('pareado', nX==nY, 'alpha', 0.05, 'nombre_metrica', '', 'unidad', '');
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

if opciones.pareado && nX ~= nY
    error('Diseno pareado solicitado pero x (%d) e y (%d) no tienen el mismo numero de elementos.', nX, nY);
end

if isscalar(margen)
    margen = [-abs(margen), abs(margen)];
else
    margen = margen(:)';
    if numel(margen) ~= 2 || margen(1) >= margen(2) || margen(1) >= 0 || margen(2) <= 0
        error('margen debe ser un escalar positivo (margen simetrico) o un vector [lo hi] con lo<0<hi.');
    end
end

alpha = opciones.alpha;

if opciones.pareado
    dif = x - y;
    n = numel(dif);
    d = mean(dif);
    SE = std(dif) / sqrt(n);
    gl = n - 1;
else
    d = mean(x) - mean(y);
    vX = var(x); vY = var(y);
    sp2 = ((nX-1)*vX + (nY-1)*vY) / (nX+nY-2);
    SE = sqrt(sp2*(1/nX + 1/nY));
    gl = nX + nY - 2;
end

if SE == 0
    % Diferencia identica en todos los pares/ensayos (solo pasa con
    % datos sinteticos sin ruido) - equivalencia trivial si d esta
    % dentro del margen, sin division por cero.
    p_inferior = double(d <= margen(1));
    p_superior = double(d >= margen(2));
    t_inferior = NaN; t_superior = NaN;
    IC = [d d];
else
    t_inferior = (d - margen(1)) / SE;
    p_inferior = 1 - tcdf(t_inferior, gl);      % H0: d <= margen(1)

    t_superior = (d - margen(2)) / SE;
    p_superior = tcdf(t_superior, gl);          % H0: d >= margen(2)

    t_crit = tinv(1-alpha, gl);
    IC = [d - t_crit*SE, d + t_crit*SE];        % IC (1-2*alpha), p.ej. 90% para alpha=0.05
end

p_tost = max(p_inferior, p_superior);
equivalente = p_tost < alpha;
equivalente_por_IC = IC(1) >= margen(1) && IC(2) <= margen(2);

resultado = struct();
resultado.pareado = opciones.pareado;
resultado.nX = nX; resultado.nY = nY;
resultado.diferencia_media = d;
resultado.SE = SE;
resultado.gl = gl;
resultado.margen = margen;
resultado.alpha = alpha;
resultado.IC = IC;
resultado.t_inferior = t_inferior;
resultado.p_inferior = p_inferior;
resultado.t_superior = t_superior;
resultado.p_superior = p_superior;
resultado.p_tost = p_tost;
resultado.equivalente = equivalente;
resultado.equivalente_por_IC = equivalente_por_IC;

etiqueta = opciones.nombre_metrica;
if isempty(etiqueta), etiqueta = 'metrica'; end
fprintf('\n------------------------------------------------------------------\n');
fprintf('TOST (Schuirmann) - %s | diseno %s | margen = [%.3g, %.3g]%s\n', ...
        etiqueta, ternary(opciones.pareado,'pareado','independiente'), margen(1), margen(2), opciones.unidad);
fprintf('Diferencia media = %.3g%s, IC%.0f%% = [%.3g, %.3g]%s\n', ...
        d, opciones.unidad, 100*(1-2*alpha), IC(1), IC(2), opciones.unidad);
fprintf('p_inferior = %.4f | p_superior = %.4f | p_TOST = %.4f\n', p_inferior, p_superior, p_tost);
if equivalente
    fprintf('-> EQUIVALENTE dentro del margen declarado (alpha=%.2f)\n', alpha);
else
    fprintf('-> NO se demuestra equivalencia dentro del margen declarado (alpha=%.2f)\n', alpha);
end
if equivalente ~= equivalente_por_IC
    fprintf('[AVISO] el criterio del IC%.0f%% da una conclusion distinta al p_TOST - revisar manualmente (normal solo si p_TOST esta muy cerca de alpha).\n', 100*(1-2*alpha));
end
fprintf('------------------------------------------------------------------\n');

end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end
