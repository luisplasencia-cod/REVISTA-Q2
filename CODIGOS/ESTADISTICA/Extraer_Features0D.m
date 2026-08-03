function features = Extraer_Features0D(curvas, eje_x, opciones)
% EXTRAER_FEATURES0D  Reduce un conjunto de curvas de ciclo de marcha a
%                      metricas escalares (0D) por ensayo, para
%                      alimentar BlandAltman_Core.m (Bland-Altman
%                      compara pares de valores escalares, no curvas
%                      completas punto a punto - eso es el trabajo de
%                      SPM1D_Core.m).
%
%   features = Extraer_Features0D(curvas, eje_x)
%   features = Extraer_Features0D(curvas, eje_x, opciones)
%
% ENTRADA
%   curvas    matriz [nPuntos x nEnsayos]
%   eje_x     vector [nPuntos x 1], tipicamente %ciclo de marcha (0-100)
%             o %fase (0-60 apoyo, 60-100 balanceo)
%   opciones  struct opcional:
%     .fase_ini   (default: min(eje_x)) inicio de la ventana para
%                 "media_fase" y para restringir donde se busca el pico
%     .fase_fin   (default: max(eje_x))
%
% SALIDA: struct `features`, cada campo es un vector [1 x nEnsayos]:
%     .pico          valor maximo de cada ensayo dentro de [fase_ini,fase_fin]
%     .pico_x         %ciclo en el que ocurre ese maximo (timing del pico)
%     .valle         valor minimo de cada ensayo dentro de [fase_ini,fase_fin]
%     .valle_x       %ciclo en el que ocurre ese minimo
%     .ROM           pico - valle
%     .media_fase    media de cada ensayo dentro de [fase_ini,fase_fin]
%
% Ejemplos de uso en este proyecto: pico_Fz (%BW) por ensayo para
% comparar AMTI vs. literatura; ROM de angulo tibial por sujeto para
% comparar Kinovea vs. STT-IWS o IMU de Alessandro vs. STT-IWS.
% ==========================================================================

if nargin < 3, opciones = struct(); end
eje_x = eje_x(:);
if size(curvas,1) ~= numel(eje_x)
    error('curvas debe tener tantas filas como elementos tiene eje_x. Se recibio %d filas vs %d puntos en eje_x.', size(curvas,1), numel(eje_x));
end

def = struct('fase_ini', min(eje_x), 'fase_fin', max(eje_x));
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

idx_fase = eje_x >= opciones.fase_ini & eje_x <= opciones.fase_fin;
if ~any(idx_fase)
    error('El rango [fase_ini, fase_fin] = [%.2f, %.2f] no contiene ningun punto de eje_x.', opciones.fase_ini, opciones.fase_fin);
end

eje_fase = eje_x(idx_fase);
curvas_fase = curvas(idx_fase, :);
nEnsayos = size(curvas_fase, 2);

pico = nan(1,nEnsayos); pico_x = nan(1,nEnsayos);
valle = nan(1,nEnsayos); valle_x = nan(1,nEnsayos);
media_fase = nan(1,nEnsayos);

for k = 1:nEnsayos
    col = curvas_fase(:,k);
    [pico(k), idx_max] = max(col);
    pico_x(k) = eje_fase(idx_max);
    [valle(k), idx_min] = min(col);
    valle_x(k) = eje_fase(idx_min);
    media_fase(k) = mean(col);
end

features = struct();
features.pico = pico;
features.pico_x = pico_x;
features.valle = valle;
features.valle_x = valle_x;
features.ROM = pico - valle;
features.media_fase = media_fase;

end
