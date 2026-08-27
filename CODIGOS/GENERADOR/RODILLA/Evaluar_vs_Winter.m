function Evaluar_vs_Winter(antro_in)
% EVALUAR_VS_WINTER  24-ago-2026: compara los 4 candidatos contra el
%                   sujeto real de Winter (Winter_Cadera_Rodilla_Tobillo.csv,
%                   Extraer_Winter_CSV.m) - SOLO rodilla relativa a
%                   cadera (necesita unicamente theta_muslo, evita el
%                   problema de flexion insuficiente de Zhao/Yun que
%                   aparece al combinar muslo+tibia).
%
% rodilla_rel_cadera_x = +L_muslo*sin(theta_muslo)
% rodilla_rel_cadera_y =  L_muslo*cos(theta_muslo)  (aqui se compara
% solo la FORMA/variacion, no el offset - se resta la 1ra muestra en
% ambos, real y generado, antes de correlacionar)
%
% SIGNO VERIFICADO EMPIRICAMENTE 24-ago-2026 (NO es el mismo signo que
% Cadena_Cinematica_Core.m usa para la TIBIA): con -sin(theta_muslo)
% (mismo signo que la tibia), los 3 candidatos angulares dieron
% correlacion NEGATIVA contra Winter real (Koopman r=-0.816, Zhao=-0.613,
% Yun=-0.468) - los 3 al mismo tiempo, senal clara de un signo de formula
% invertido, no de un problema real de los 3 modelos. Con +sin(theta_muslo)
% los 3 se vuelven POSITIVOS con la MISMA magnitud (Koopman r=+0.816).
% El signo del MUSLO no hereda automaticamente el signo ya verificado de
% la TIBIA (G7, Cadena_Cinematica_Core.m) - son articulaciones distintas,
% cada una necesita su propia verificacion contra dato real, no asumirse.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
if nargin < 1 || isempty(antro_in)
    antro_in = struct('talla_m', 1.71, 'masa_kg', 68, 'sexo', 'M');
end
antro = Estimar_Antropometria_Core(antro_in);
tempo0 = Temporizacion_Core(antro, 'Koopman');
L_m_cm = antro.long_muslo_m * 100;

W = readtable(fullfile(fileparts(mfilename('fullpath')), 'Winter_Cadera_Rodilla_Tobillo.csv'));
pct_W = linspace(0, 100, height(W));  % Winter no trae %ciclo explicito - se asume que las 106 muestras cubren 1 ciclo
dx_W = (W.rodilla_x_cm - W.cadera_x_cm) - (W.rodilla_x_cm(1) - W.cadera_x_cm(1));
dy_W = (W.rodilla_y_cm - W.cadera_y_cm) - (W.rodilla_y_cm(1) - W.cadera_y_cm(1));

% --- Angulo de muslo de cada candidato, ciclo completo nativo ---
K = Koopman2014_Core(tempo0.velocidad_ms*3.6, antro.talla_m);
m_K = deg2rad(K.cadera_flexext.angulo_deg); pct_K = linspace(0,100,numel(m_K));

% NOTA 26-ago-2026: Winter no documenta que pierna se midio. Probado con
% 'derecha' (mismo chequeo que se hizo para Maastricht/Control_Luis, ver
% CIERRE_RODILLA.md) el r EMPEORA (0.613 -> -0.392) - a diferencia de los
% otros dos casos. Esto confirma que el lado hay que verificarlo por
% dataset, no asumir uno fijo para todo el proyecto - se mantiene
% 'izquierda' (default del paper) por ser el que de hecho ajusta mejor
% aqui, no por ser "el correcto" (el lado real del sujeto de Winter sigue
% sin documentarse).
Z = Zhao2026_Core(antro.long_muslo_m+antro.long_tibia_m, 1/tempo0.tiempo_ciclo_s);
m_Z = Z.phi_cadera_rad; pct_Z = linspace(0,100,numel(m_Z));

Yw = Yun2014_Wrapper(vector14_desde_antropometria(antro));
m_Y = deg2rad(Yw.R_hip_extension.mean); pct_Y = linspace(0,100,numel(m_Y));

v_kph = tempo0.velocidad_ms*3.6;
RS = Romero_Sorozabal2024_Core(v_kph, antro.talla_m, struct('nMuestras', height(W)));
dx_RS = (RS.rodilla.x_m*100 - RS.cadera.x_m*100); dx_RS = dx_RS - dx_RS(1);
pct_RS = RS.rodilla.pct_ciclo;

nombres = {'Koopman','Zhao','Yun','Romero-Sorozabal'};
col = {[0.85 0.33 0.10],[0.47 0.67 0.19],[0.30 0.55 0.75],[0.60 0.20 0.60]};

fprintf('=== Rodilla relativa a cadera (X) vs Winter real ===\n');
fprintf('%-20s %8s\n','Modelo','r(X)');
pcts = {pct_K, pct_Z, pct_Y, pct_RS};
angs_m = {m_K, m_Z, m_Y, []};
r_all = zeros(1,4);
dx_gen = cell(1,4);
for i=1:3
    dx = L_m_cm*sin(angs_m{i}); dx = dx - dx(1);  % signo verificado, ver encabezado
    dx_i = interp1(pcts{i}, dx, pct_W, 'pchip');
    r_all(i) = corr(dx_W(:), dx_i(:));
    dx_gen{i} = dx_i;
    fprintf('%-20s %8.3f\n', nombres{i}, r_all(i));
end
dx_RS_i = interp1(pct_RS, dx_RS, pct_W, 'pchip');
r_all(4) = corr(dx_W(:), dx_RS_i(:));
dx_gen{4} = dx_RS_i;
fprintf('%-20s %8.3f\n', nombres{4}, r_all(4));

fig = figure('Name','Rodilla vs Winter real','Position',[80 80 900 500],'Color','w');
hold on; grid on; box on;
plot(pct_W, dx_W, 'k-', 'LineWidth',3);
for i=1:4, plot(pct_W, dx_gen{i}, '-', 'Color',col{i}, 'LineWidth',2); end
xlabel('% ciclo (asumido)'); ylabel('rodilla - cadera, X [cm] (relativo al inicio)');
leg = [{'REAL Winter'}, arrayfun(@(i) sprintf('%s (r=%.2f)',nombres{i},r_all(i)), 1:4, 'UniformOutput',false)];
legend(leg, 'Location','best');
title('Rodilla relativa a cadera: real (Winter) vs los 4 candidatos');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Evaluar_vs_Winter_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('\nFigura guardada en: %s\n', out_png);

end

function p14 = vector14_desde_antropometria(antro)
if ~isfield(antro,'edad_anios') || isempty(antro.edad_anios), antro.edad_anios = 25; end
if ~isfield(antro,'sexo'), antro.sexo = 'M'; end
sexo01 = double(upper(antro.sexo(1)) == 'M');
p14 = [antro.edad_anios, antro.talla_m*100, antro.masa_kg, sexo01, ...
       antro.long_muslo_m*100, antro.long_tibia_m*100, ...
       32.8, 29.7, 25.5, 10, antro.long_pie_m*100, 7.30, 7.10, 9.80];
end
