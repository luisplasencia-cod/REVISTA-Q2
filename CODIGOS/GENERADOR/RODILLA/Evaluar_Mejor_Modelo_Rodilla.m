function Evaluar_Mejor_Modelo_Rodilla(antro_in)
% EVALUAR_MEJOR_MODELO_RODILLA  Paso 1 del plan "parte por parte" pedido
%                   por el usuario 24-ago-2026: encontrar el MEJOR modelo
%                   para la posicion de la RODILLA, evaluado contra dato
%                   REAL del proyecto (Control_apoyo_Luis_V4.csv +
%                   Control_balanceo_Luis_V4.csv) - NO Camargo, que queda
%                   reservado para la validacion final (regla del usuario).
%
%                   Metodo simple (SIN cadena de muslo, sin depender del
%                   angulo de cadera - eso evita el problema de flexion de
%                   rodilla insuficiente en Zhao/Yun que aparecio hoy):
%                   posicion de la rodilla = rotacion del segmento tibial
%                   sobre el TOBILLO fijo (Cadena_Cinematica_Core.m), con
%                   el theta_tibia de cada candidato (su MEJOR camino ya
%                   establecido: Koopman via_rodilla, Yun via_tobillo,
%                   Zhao nativo) y L_tibia estimada de la antropometria.
%                   Romero-Sorozabal se compara aparte: da posicion de
%                   rodilla DIRECTA (sin angulo), pero su Z tiene la
%                   anomalia conocida - se compara solo en X, y en angulo
%                   derivado con caveat.

% Esta funcion vive en CODIGOS/GENERADOR/RODILLA/ (carpeta dedicada,
% 24-ago-2026, pedido del usuario) - depende de los Core de la carpeta
% padre CODIGOS/GENERADOR/. addpath explicito para no depender de que
% el cwd sea esa carpeta (mismo bug de robustez ya encontrado y
% corregido hoy en Yun2014_Wrapper.m).
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));

if nargin < 1 || isempty(antro_in)
    antro_in = struct('talla_m', 1.71, 'masa_kg', 68, 'sexo', 'M');
end
antro = Estimar_Antropometria_Core(antro_in);
tempo0 = Temporizacion_Core(antro, 'Koopman');
L_t_cm = antro.long_tibia_m * 100;

% --- Referencia real (Control_Luis, ciclo completo) ---
dir_ref = fullfile(fileparts(mfilename('fullpath')), '..','..','..','REFERENCIAS');
A = leer_csv_ref(fullfile(dir_ref,'Control_apoyo_Luis_V4.csv'));
B = leer_csv_ref(fullfile(dir_ref,'Control_balanceo_Luis_V4.csv'));
frac_ap_real = A.t(end) / (A.t(end)+B.t(end));
pct_ref = [linspace(0, frac_ap_real*100, numel(A.ang)), linspace(frac_ap_real*100, 100, numel(B.ang))];
ang_ref = [A.ang(:); B.ang(:)].';
x_ref   = [A.x(:); B.x(:)+A.x(end)].';   % continuo, mismo criterio que Generar_Trayectoria.m
y_ref   = [A.y(:); B.y(:)+A.y(end)].';

% --- Los 4 candidatos: theta_tibia con su MEJOR camino ya establecido ---
K = Koopman2014_Core(tempo0.velocidad_ms*3.6, antro.talla_m);
ang_K = K.theta_tibia_via_rodilla_deg;
pct_K = linspace(0,100,numel(ang_K));

Z = Zhao2026_Core(antro.long_muslo_m+antro.long_tibia_m, 1/tempo0.tiempo_ciclo_s);
ang_Z = rad2deg(Z.theta_tibia_rad);
pct_Z = linspace(0,100,numel(ang_Z));

Y = Yun2014_Wrapper(vector14_desde_antropometria(antro));
ang_Y = rad2deg(Y.theta_tibia_via_tobillo_R_rad);
pct_Y = linspace(0,100,numel(ang_Y));

v_kph = tempo0.velocidad_ms*3.6;
RS = Romero_Sorozabal2024_Core(v_kph, antro.talla_m, struct('nMuestras', 191));
pct_RS = RS.rodilla.pct_ciclo;
dx = RS.tobillo.x_m - RS.rodilla.x_m; dz = RS.tobillo.z_abajo_pelvis_m - RS.rodilla.z_abajo_pelvis_m;
ang_RS = rad2deg(atan2(dx,dz));

nombres = {'Koopman','Zhao','Yun','Romero-Sorozabal'};
pcts = {pct_K, pct_Z, pct_Y, pct_RS};
angs = {ang_K, ang_Z, ang_Y, ang_RS};

fprintf('=== Angulo tibial vs Control_Luis real ===\n');
fprintf('%-20s %8s %8s\n','Modelo','r','RMSE(deg)');
r_all = zeros(1,4); rmse_all = zeros(1,4);
for i=1:4
    ai = interp1(pcts{i}, angs{i}, pct_ref, 'pchip');
    r_all(i) = corr(ang_ref(:), ai(:));
    rmse_all(i) = sqrt(mean((ang_ref(:)-ai(:)).^2));
    fprintf('%-20s %8.3f %8.2f\n', nombres{i}, r_all(i), rmse_all(i));
end

% --- Posicion de rodilla (via Cadena_Cinematica_Core, K/Z/Y) ---
pos_K = Cadena_Cinematica_Core(deg2rad(ang_K), antro.long_tibia_m);
pos_Z = Cadena_Cinematica_Core(deg2rad(ang_Z), antro.long_tibia_m);
pos_Y = Cadena_Cinematica_Core(deg2rad(ang_Y), antro.long_tibia_m);

fprintf('\n=== Posicion (X) vs Control_Luis real - CORRELACION DE FORMA ===\n');
fprintf('%-20s %8s\n','Modelo','r(X)');
xs = {pos_K.x_cm, pos_Z.x_cm, pos_Y.x_cm, RS.rodilla.x_m*100 - RS.tobillo.x_m*100};
r_x = zeros(1,4);
for i=1:4
    xi = interp1(pcts{i}, xs{i}, pct_ref, 'pchip');
    r_x(i) = corr(x_ref(:), xi(:));
    fprintf('%-20s %8.3f\n', nombres{i}, r_x(i));
end

fig = figure('Name','Evaluacion: mejor modelo para RODILLA','Position',[80 80 1300 550],'Color','w');
col = {[0.85 0.33 0.10],[0.47 0.67 0.19],[0.30 0.55 0.75],[0.60 0.20 0.60]};

subplot(1,2,1); hold on; grid on; box on;
plot(pct_ref, ang_ref, 'k-', 'LineWidth',3);
for i=1:4, plot(pcts{i}, angs{i}, '-', 'Color',col{i}, 'LineWidth',2); end
xlabel('% ciclo'); ylabel('\theta_{tibia} [deg]');
title('Angulo tibial: real (negro) vs los 4');
leg = [{'REAL Control\_Luis'}, arrayfun(@(i) sprintf('%s (r=%.2f)',nombres{i},r_all(i)), 1:4, 'UniformOutput',false)];
legend(leg, 'Location','best');

subplot(1,2,2); hold on; grid on; box on;
bar([r_all; r_x]');
set(gca,'XTickLabel',nombres);
ylabel('correlacion r'); ylim([-1 1]); yline(0,'k:');
legend({'r(angulo)','r(posicion X)'}, 'Location','best');
title('Ranking de fidelidad contra Control\_Luis real');

sgtitle('Paso 1: mejor modelo para la RODILLA (sin Camargo, reservado para el final)', 'FontWeight','bold');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Evaluar_Mejor_Modelo_Rodilla_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('\nFigura guardada en: %s\n', out_png);

end

% ==========================================================================
function S = leer_csv_ref(ruta)
M = readmatrix(ruta, 'Delimiter', ';', 'DecimalSeparator', '.');
M = M(:, 1:4);
val = all(isfinite(M(:,[1 4])), 2);
M = M(val, :);
S.t = M(:,1); S.x = M(:,2); S.y = M(:,3); S.ang = M(:,4);
end

function p14 = vector14_desde_antropometria(antro)
if ~isfield(antro,'edad_anios') || isempty(antro.edad_anios), antro.edad_anios = 25; end
if ~isfield(antro,'sexo'), antro.sexo = 'M'; end
sexo01 = double(upper(antro.sexo(1)) == 'M');
p14 = [antro.edad_anios, antro.talla_m*100, antro.masa_kg, sexo01, ...
       antro.long_muslo_m*100, antro.long_tibia_m*100, ...
       32.8, 29.7, 25.5, 10, antro.long_pie_m*100, 7.30, 7.10, 9.80];
end
