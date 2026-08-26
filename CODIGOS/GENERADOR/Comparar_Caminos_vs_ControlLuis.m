function Comparar_Caminos_vs_ControlLuis()
% COMPARAR_CAMINOS_VS_CONTROLLUIS  24-ago-2026, pedido del usuario:
%                   compara los DOS caminos de reduccion del angulo tibial
%                   (via tobillo vs via rodilla) contra el angulo real de
%                   REFERENCIAS/Control_apoyo_Luis_V4.csv y
%                   Control_balanceo_Luis_V4.csv - dato PROPIO del
%                   proyecto, SOLO angulo de inclinacion tibial.
%
%                   NO usa Camargo a proposito (decision del usuario):
%                   Camargo queda reservado para la validacion externa
%                   final, no se usa para construir/elegir - misma regla
%                   de no-circularidad ya establecida (P-23/P-24).
%
%                   Objetivo: decidir con evidencia si el salto del angulo
%                   en el cambio de fase se resuelve usando un solo camino
%                   en todo el ciclo, y cual.

dir_ref = fullfile(fileparts(mfilename('fullpath')), '..','..','REFERENCIAS');
A = leer_csv_ref(fullfile(dir_ref,'Control_apoyo_Luis_V4.csv'));
B = leer_csv_ref(fullfile(dir_ref,'Control_balanceo_Luis_V4.csv'));

T_ap  = A.t(end);
T_bal = B.t(end);
T_tot = T_ap + T_bal;
frac_ap_real = T_ap / T_tot;

fprintf('=== Referencia real (Control_*_Luis_V4.csv) ===\n');
fprintf('apoyo:    t=0..%.2fs, angulo %.1f -> %.1f deg (rango %.1f)\n', T_ap, A.ang(1), A.ang(end), range(A.ang));
fprintf('balanceo: t=0..%.2fs, angulo %.1f -> %.1f deg (rango %.1f)\n', T_bal, B.ang(1), B.ang(end), range(B.ang));
fprintf('frac_apoyo real = %.3f (%.1f%% del ciclo)\n', frac_ap_real, frac_ap_real*100);
fprintf('SALTO real en el cambio de fase: %.2f deg (%.1f -> %.1f)\n\n', ...
    B.ang(1)-A.ang(end), A.ang(end), B.ang(1));

pct_ref = [linspace(0, frac_ap_real*100, numel(A.ang)), ...
           linspace(frac_ap_real*100, 100, numel(B.ang))];
ang_ref = [A.ang(:); B.ang(:)].';

% --- Generador: los dos caminos, ciclo completo, mismo sujeto aproximado ---
% (no se conoce la talla real del sujeto de Control_Luis; se usa la
% talla por defecto - la comparacion aqui es de FORMA y RANGO, no de
% magnitud absoluta punto a punto)
antro = Estimar_Antropometria_Core(struct('talla_m',1.71,'masa_kg',68,'sexo','M'));
tempo = Temporizacion_Core(antro, 'Koopman');
K = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m);
pct_K = linspace(0, 100, numel(K.theta_tibia_via_tobillo_deg));

fprintf('=== Generador (Koopman), ciclo completo ===\n');
fprintf('via tobillo: %.1f -> %.1f deg (rango %.1f)\n', ...
    K.theta_tibia_via_tobillo_deg(1), K.theta_tibia_via_tobillo_deg(end), range(K.theta_tibia_via_tobillo_deg));
fprintf('via rodilla: %.1f -> %.1f deg (rango %.1f)\n\n', ...
    K.theta_tibia_via_rodilla_deg(1), K.theta_tibia_via_rodilla_deg(end), range(K.theta_tibia_via_rodilla_deg));

% correlacion de forma contra la referencia (remuestreando el generador
% a los mismos %ciclo de la referencia)
tob_i = interp1(pct_K, K.theta_tibia_via_tobillo_deg, pct_ref, 'pchip');
rod_i = interp1(pct_K, K.theta_tibia_via_rodilla_deg, pct_ref, 'pchip');
r_tob = corr(ang_ref(:), tob_i(:));
r_rod = corr(ang_ref(:), rod_i(:));
rmse_tob = sqrt(mean((ang_ref(:)-tob_i(:)).^2));
rmse_rod = sqrt(mean((ang_ref(:)-rod_i(:)).^2));
fprintf('Contra la referencia real (ciclo completo):\n');
fprintf('  via tobillo: r=%.3f  RMSE=%.1f deg\n', r_tob, rmse_tob);
fprintf('  via rodilla: r=%.3f  RMSE=%.1f deg\n', r_rod, rmse_rod);
if r_rod > r_tob, fprintf('  -> via RODILLA correlaciona mejor\n'); else, fprintf('  -> via TOBILLO correlaciona mejor\n'); end

fig = figure('Name','Caminos de reduccion vs Control_Luis real','Position',[80 80 1200 600],'Color','w');
hold on; grid on; box on;
plot(pct_ref, ang_ref, 'k-', 'LineWidth', 3);
plot(pct_K, K.theta_tibia_via_tobillo_deg, '-', 'Color',[0.85 0.33 0.10], 'LineWidth', 2);
plot(pct_K, K.theta_tibia_via_rodilla_deg, '-', 'Color',[0.10 0.40 0.75], 'LineWidth', 2);
xline(frac_ap_real*100, ':k', 'apoyo|balanceo (real)');
xlabel('% ciclo de marcha'); ylabel('\theta_{tibia} [deg] (0 = vertical)');
title({'Angulo tibial: referencia REAL del proyecto (Control\_Luis, negro)', ...
       'vs. los dos caminos de reduccion de Koopman'});
legend({sprintf('REAL Control\\_Luis (rango %.0f deg)', range(ang_ref)), ...
        sprintf('via tobillo (r=%.2f, RMSE=%.0f)', r_tob, rmse_tob), ...
        sprintf('via rodilla (r=%.2f, RMSE=%.0f)', r_rod, rmse_rod)}, 'Location','best');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Comparar_Caminos_vs_ControlLuis_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('\nFigura guardada en: %s\n', out_png);

end

% ==========================================================================
function S = leer_csv_ref(ruta)
% Lee los CSV de REFERENCIAS/ (separador ';', columnas vacias al final,
% posible fila final con NaN - ver nota de G7 en Cadena_Cinematica_Core.m)
M = readmatrix(ruta, 'Delimiter', ';', 'DecimalSeparator', '.');
M = M(:, 1:4);
val = all(isfinite(M(:,[1 4])), 2);
M = M(val, :);
S.t   = M(:,1);
S.x   = M(:,2);
S.y   = M(:,3);
S.ang = M(:,4);
end
