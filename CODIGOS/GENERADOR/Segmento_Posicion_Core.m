function out = Segmento_Posicion_Core(theta_rad, L_m, opciones)
% SEGMENTO_POSICION_CORE  Convierte el angulo absoluto de un segmento
%                         rigido (p.ej. theta_tibia de cualquiera de los
%                         tres candidatos - Zhao2026_Core.m,
%                         Yun2014_Wrapper.m, Koopman2014_Core.m, o el
%                         theta_tibia_real de Cargar_Camargo_Core.m) y su
%                         longitud en la posicion (x,y) del extremo
%                         distal, y de cualquier punto intermedio del
%                         segmento - no requiere literatura nueva, es
%                         trigonometria directa sobre lo que ya se
%                         genera. Es el paso que le falta a la reduccion
%                         para llegar a la cinematica directa completa de
%                         analisis_escalamiento_Q1_generador_trayectorias.md
%                         #5 (angulos -> posicion del extremo proximal de
%                         la protesis).
%
%                         Convencion: theta=0 significa segmento VERTICAL
%                         (misma convencion ya verificada en
%                         Cargar_Camargo_Core.m contra
%                         REFERENCIAS/Control_apoyo_Luis_V4.csv) - el eje
%                         "x" de salida es "avance" (horizontal), el eje
%                         "y" es vertical:
%                           x = origen_x + f*L*sin(theta)
%                           y = origen_y + f*L*cos(theta)
%
%   out = Segmento_Posicion_Core(theta_rad, L_m)
%   out = Segmento_Posicion_Core(theta_rad, L_m, opciones)
%
% ENTRADA
%   theta_rad   angulo absoluto del segmento (rad), [1 x n] - 0=vertical,
%               positivo/negativo segun la inclinacion (misma convencion
%               que theta_tibia_real_deg de Cargar_Camargo_Core.m y que
%               REFERENCIAS/ del proyecto)
%   L_m         longitud del segmento (m), escalar - real (medida, p.ej.
%               Cargar_Camargo_Core.m .long_tibia_r_m) o estimada (de
%               Leva 1996, ver analisis_escalamiento...md #5-bis)
%   opciones (struct opcional):
%     .origen_x, .origen_y   posicion (m) del extremo PROXIMAL (p.ej. la
%                             rodilla, si el segmento es la tibia) -
%                             default [0, 0]. Puede ser escalar (fijo) o
%                             vector [1 x n] (si el extremo proximal ya
%                             se conoce en movimiento, p.ej. encadenando
%                             muslo->tibia)
%     .fracciones             vector de fracciones a lo largo del
%                             segmento, 0=extremo proximal, 1=extremo
%                             distal (default [1], solo el extremo distal)
%
% SALIDA: struct `out`
%   .x, .y      matrices [numel(fracciones) x n] - posicion (m) de cada
%               fraccion pedida, para cada instante de theta_rad
%   .fracciones  las fracciones usadas (para saber que fila es cual)
%
% Ejemplo de uso: posicion del tobillo (extremo distal de la tibia) con
% origen en la rodilla fija en (0,0):
%   res = Cargar_Camargo_Core(...);
%   pos = Segmento_Posicion_Core(deg2rad(res.theta_tibia_real_deg), res.long_tibia_r_m);
%   % pos.x, pos.y = trayectoria del tobillo relativa a la rodilla
% ==========================================================================

if nargin < 3, opciones = struct(); end
def = struct('origen_x', 0, 'origen_y', 0, 'fracciones', 1);
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

theta_rad = theta_rad(:).';
n = numel(theta_rad);

if ~(isnumeric(L_m) && isscalar(L_m) && L_m > 0)
    error('L_m debe ser un escalar positivo (longitud del segmento, m). Se recibio: %s', mat2str(L_m));
end

ox = opciones.origen_x; oy = opciones.origen_y;
if isscalar(ox), ox = ox * ones(1,n); end
if isscalar(oy), oy = oy * ones(1,n); end
if numel(ox) ~= n || numel(oy) ~= n
    error('origen_x/origen_y deben ser escalares o vectores del mismo largo que theta_rad (%d). Se recibio %d/%d.', n, numel(ox), numel(oy));
end

fr = opciones.fracciones(:);
if any(fr < 0) || any(fr > 1)
    error('opciones.fracciones debe estar entre 0 (extremo proximal) y 1 (extremo distal). Se recibio: %s', mat2str(fr'));
end

nFrac = numel(fr);
x = nan(nFrac, n);
y = nan(nFrac, n);
for k = 1:nFrac
    x(k,:) = ox + fr(k) * L_m * sin(theta_rad);
    y(k,:) = oy + fr(k) * L_m * cos(theta_rad);
end

out = struct();
out.x = x;
out.y = y;
out.fracciones = fr;

end
