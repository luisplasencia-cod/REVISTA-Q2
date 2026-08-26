 trenitenfunction Test_Combinar_Candidatos()
% TEST_COMBINAR_CANDIDATOS  Pruebas + visualizacion de Combinar_Candidatos_Core.m
%                            (24-ago-2026, cierre de plan_ensamble_multimodelo.md
%                            pasos 5-6).

fprintf('=== Test_Combinar_Candidatos ===\n\n');
nPass = 0; nTotal = 0;

antro_in = struct('talla_m', 1.71, 'masa_kg', 68, 'sexo', 'M');
antro = Estimar_Antropometria_Core(antro_in);
tempo0 = Temporizacion_Core(antro, 'Koopman');

[comb, tempo] = Combinar_Candidatos_Core(antro, tempo0, 101);

% --- Test 1: campos presentes ---
nTotal = nTotal + 1;
ok = all(isfield(comb, {'apoyo','balanceo','detalle'})) && ...
     all(isfield(comb.apoyo, {'x_cm','y_cm'})) && all(isfield(comb.balanceo, {'x_cm','y_cm'}));
nPass = nPass + reporta(ok, 'Test 1: campos apoyo/balanceo/detalle presentes');

% --- Test 2: tamanos consistentes (101 puntos por fase) ---
nTotal = nTotal + 1;
ok = numel(comb.apoyo.x_cm) == 101 && numel(comb.balanceo.x_cm) == 101;
nPass = nPass + reporta(ok, 'Test 2: 101 puntos por fase');

% --- Test 3: el promedio de X en apoyo cae DENTRO del rango [min,max] de los 4 individuales ---
nTotal = nTotal + 1;
d = comb.detalle;
x_ind_ap = [d.x_koopman_apoyo_cm; d.x_zhao_apoyo_cm; d.x_yun_apoyo_cm; d.x_romero_apoyo_cm];
ok = all(comb.apoyo.x_cm >= min(x_ind_ap,[],1) - 1e-9) && all(comb.apoyo.x_cm <= max(x_ind_ap,[],1) + 1e-9);
nPass = nPass + reporta(ok, 'Test 3: X combinado (apoyo) esta dentro del rango de los 4 candidatos individuales, punto a punto');

% --- Test 4: el promedio de Y en balanceo cae DENTRO del rango de los 3 (K/Z/Y, sin Romero) ---
nTotal = nTotal + 1;
y_ind_bal = [d.y_koopman_balanceo_cm; d.y_zhao_balanceo_cm; d.y_yun_balanceo_cm];
ok = all(comb.balanceo.y_cm >= min(y_ind_bal,[],1) - 1e-9) && all(comb.balanceo.y_cm <= max(y_ind_bal,[],1) + 1e-9);
nPass = nPass + reporta(ok, 'Test 4: Y combinado (balanceo) esta dentro del rango de los 3 candidatos angulares (Romero excluido en Z)');

% --- Test 5: Romero-Sorozabal SI aporta a X (no es identico al promedio de solo K/Z/Y) ---
nTotal = nTotal + 1;
x_solo3_ap = mean([d.x_koopman_apoyo_cm; d.x_zhao_apoyo_cm; d.x_yun_apoyo_cm], 1);
ok = max(abs(comb.apoyo.x_cm - x_solo3_ap)) > 1e-6;
nPass = nPass + reporta(ok, 'Test 5: Romero-Sorozabal cambia el promedio de X (no es un no-op)');

% --- Test 6: reproducibilidad (misma entrada -> misma salida) ---
nTotal = nTotal + 1;
[comb2, ~] = Combinar_Candidatos_Core(antro, tempo0, 101);
ok = isequal(comb.apoyo.x_cm, comb2.apoyo.x_cm) && isequal(comb.balanceo.y_cm, comb2.balanceo.y_cm);
nPass = nPass + reporta(ok, 'Test 6: reproducibilidad (misma antropometria -> misma salida exacta)');

fprintf('\n=== %d/%d PASS ===\n\n', nPass, nTotal);

visualizar(comb, antro, tempo);

end

% ==========================================================================
function ok = reporta(cond, msg)
if cond, fprintf('  [PASS] %s\n', msg); else, fprintf('  [FAIL] %s\n', msg); end
ok = double(cond);
end

% ==========================================================================
function visualizar(comb, antro, tempo)
d = comb.detalle;
pct_ap  = linspace(0, tempo.frac_apoyo*100, 101);
pct_bal = linspace(tempo.frac_apoyo*100, 100, 101);

fig = figure('Name','Combinar_Candidatos_Core - verificacion visual', ...
    'Position',[100 80 1300 800],'Color','w');

col = struct('koopman',[0.85 0.33 0.10],'zhao',[0.47 0.67 0.19], ...
    'yun',[0.30 0.55 0.75],'romero',[0.60 0.20 0.60],'combinado',[0.10 0.10 0.10]);

% --- Panel 1: X vs %ciclo, apoyo+balanceo, 4 individuales + combinado ---
subplot(2,2,1); hold on; grid on; box on;
plot(pct_ap,  d.x_koopman_apoyo_cm,  '-', 'Color',col.koopman, 'LineWidth',1);
plot(pct_bal, d.x_koopman_balanceo_cm,'-', 'Color',col.koopman, 'LineWidth',1, 'HandleVisibility','off');
plot(pct_ap,  d.x_zhao_apoyo_cm,     '-', 'Color',col.zhao,    'LineWidth',1);
plot(pct_bal, d.x_zhao_balanceo_cm,  '-', 'Color',col.zhao,    'LineWidth',1, 'HandleVisibility','off');
plot(pct_ap,  d.x_yun_apoyo_cm,      '-', 'Color',col.yun,     'LineWidth',1);
plot(pct_bal, d.x_yun_balanceo_cm,   '-', 'Color',col.yun,     'LineWidth',1, 'HandleVisibility','off');
plot(pct_ap,  d.x_romero_apoyo_cm,   '-', 'Color',col.romero,  'LineWidth',1);
plot(pct_bal, d.x_romero_balanceo_cm,'-', 'Color',col.romero,  'LineWidth',1, 'HandleVisibility','off');
plot(pct_ap,  comb.apoyo.x_cm,       '-', 'Color',col.combinado,'LineWidth',3);
plot(pct_bal, comb.balanceo.x_cm,    '-', 'Color',col.combinado,'LineWidth',3, 'HandleVisibility','off');
xline(tempo.frac_apoyo*100, ':k', 'apoyo|balanceo');
xlabel('% ciclo'); ylabel('X [cm] (relativo a tobillo)');
title('X: 4 candidatos + combinado (negro grueso)');
legend({'Koopman','Zhao','Yun','Romero-Sorozabal','Combinado'}, 'Location','best');

% --- Panel 2: Y vs %ciclo, 3 individuales (sin Romero) + combinado ---
subplot(2,2,2); hold on; grid on; box on;
plot(pct_ap,  d.y_koopman_apoyo_cm,  '-', 'Color',col.koopman, 'LineWidth',1);
plot(pct_bal, d.y_koopman_balanceo_cm,'-', 'Color',col.koopman, 'LineWidth',1, 'HandleVisibility','off');
plot(pct_ap,  d.y_zhao_apoyo_cm,     '-', 'Color',col.zhao,    'LineWidth',1);
plot(pct_bal, d.y_zhao_balanceo_cm,  '-', 'Color',col.zhao,    'LineWidth',1, 'HandleVisibility','off');
plot(pct_ap,  d.y_yun_apoyo_cm,      '-', 'Color',col.yun,     'LineWidth',1);
plot(pct_bal, d.y_yun_balanceo_cm,   '-', 'Color',col.yun,     'LineWidth',1, 'HandleVisibility','off');
plot(pct_ap,  comb.apoyo.y_cm,       '-', 'Color',col.combinado,'LineWidth',3);
plot(pct_bal, comb.balanceo.y_cm,    '-', 'Color',col.combinado,'LineWidth',3, 'HandleVisibility','off');
xline(tempo.frac_apoyo*100, ':k', 'apoyo|balanceo');
xlabel('% ciclo'); ylabel('Y [cm] (vertical, relativo a tobillo)');
title('Y: 3 candidatos (Romero-Sorozabal EXCLUIDO, ver anomalia) + combinado');
legend({'Koopman','Zhao','Yun','Combinado'}, 'Location','best');

% --- Panel 3: vista sagital combinada (X vs Y), apoyo y balanceo ---
subplot(2,2,3); hold on; grid on; box on; axis equal;
plot(comb.apoyo.x_cm,    comb.apoyo.y_cm,    '-', 'Color',[0.10 0.40 0.75], 'LineWidth',2.5);
plot(comb.balanceo.x_cm, comb.balanceo.y_cm, '-', 'Color',[0.85 0.45 0.10], 'LineWidth',2.5);
plot(comb.apoyo.x_cm(1), comb.apoyo.y_cm(1), 'ko', 'MarkerFaceColor','k', 'MarkerSize',6, 'HandleVisibility','off');
xlabel('X [cm]'); ylabel('Y [cm]'); title('Trayectoria combinada de la rodilla (relativa al tobillo, SIN traslacion E6)');
legend({'apoyo','balanceo'}, 'Location','best');

% --- Panel 4: dispersion entre candidatos (rango max-min) por %ciclo ---
subplot(2,2,4); hold on; grid on; box on;
x_ind_ap  = [d.x_koopman_apoyo_cm; d.x_zhao_apoyo_cm; d.x_yun_apoyo_cm; d.x_romero_apoyo_cm];
x_ind_bal = [d.x_koopman_balanceo_cm; d.x_zhao_balanceo_cm; d.x_yun_balanceo_cm; d.x_romero_balanceo_cm];
rango_ap  = max(x_ind_ap,[],1)  - min(x_ind_ap,[],1);
rango_bal = max(x_ind_bal,[],1) - min(x_ind_bal,[],1);
plot(pct_ap,  rango_ap,  '-', 'Color',[0.4 0.4 0.4], 'LineWidth',2);
plot(pct_bal, rango_bal, '-', 'Color',[0.4 0.4 0.4], 'LineWidth',2, 'HandleVisibility','off');
xline(tempo.frac_apoyo*100, ':k', 'apoyo|balanceo');
xlabel('% ciclo'); ylabel('Rango X entre candidatos [cm] (max-min)');
title('Dispersion entre los 4 candidatos en X (cuanto discrepan)');

sgtitle(sprintf('Combinar\\_Candidatos\\_Core -- talla=%.2fm, v=%.2fm/s', antro.talla_m, tempo.velocidad_ms), 'FontWeight','bold');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Test_Combinar_Candidatos_figura.png');
try
    exportgraphics(fig, out_png, 'Resolution', 150);
    fprintf('Figura guardada en: %s\n', out_png);
catch ME
    fprintf('  [aviso] no se pudo exportar PNG: %s\n', ME.message);
end

end
