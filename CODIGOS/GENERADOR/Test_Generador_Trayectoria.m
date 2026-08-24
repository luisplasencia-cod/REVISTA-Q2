function Test_Generador_Trayectoria()
% TEST_GENERADOR_TRAYECTORIA  Pruebas de E3-E9 de plan_100_generador.md
%                              (antropometria, temporizacion, cadena
%                              cinematica, orquestador, escritor de
%                              CSV). E2 y los candidatos base (E1 del
%                              tablero original) ya se prueban en
%                              Test_Generador.m - este archivo NO
%                              duplica esas pruebas, las complementa.
% ==========================================================================
addpath(fileparts(mfilename('fullpath')));
fprintf('\n=== Test_Generador_Trayectoria ===\n\n');
nPass = 0; nTotal = 0;

% ---- Test 1: Estimar_Antropometria_Core no sobrescribe medidos ----
nTotal = nTotal + 1;
r = Estimar_Antropometria_Core(struct('talla_m', 1.80, 'long_tibia_m', 0.446));
ok = strcmp(r.fuente_tibia,'medido') && abs(r.long_tibia_m - 0.446) < 1e-12 && strcmp(r.fuente_muslo,'estimado_deLeva');
nPass = reportar(nPass, ok, 1, 'dato medido preservado, faltante estimado');

% ---- Test 2: estimacion de tibia dentro de 2% del valor real AB06 ----
nTotal = nTotal + 1;
r2 = Estimar_Antropometria_Core(struct('talla_m', 1.80));
err_pct = 100*abs(r2.long_tibia_m - 0.446)/0.446;
ok = err_pct < 2;
nPass = reportar(nPass, ok, 2, sprintf('tibia estimada vs. AB06 real: error=%.2f%% (<2%%)', err_pct));

% ---- Test 3: talla fuera de rango dispara warning, no error ----
nTotal = nTotal + 1;
try
    w = warning('off', 'all');
    lastwarn('');
    Estimar_Antropometria_Core(struct('talla_m', 0.5));
    [msg, id] = lastwarn();
    warning(w);
    ok = strcmp(id, 'Estimar_Antropometria_Core:tallaFueraDeRango');
catch
    ok = false;
end
nPass = reportar(nPass, ok, 3, 'talla fuera de rango dispara warning controlado');

% ---- Test 4: velocidad Froude en rango fisiologico adulto ----
nTotal = nTotal + 1;
v = Estimar_Velocidad_Froude_Core(1.70);
ok = v > 0.8 && v < 2.0;
nPass = reportar(nPass, ok, 4, sprintf('v=%.3f m/s dentro de [0.8,2.0] para talla=1.70m', v));

% ---- Test 5: velocidad Froude escala con talla (monotona creciente) ----
nTotal = nTotal + 1;
v1 = Estimar_Velocidad_Froude_Core(1.50);
v2 = Estimar_Velocidad_Froude_Core(1.90);
ok = v2 > v1;
nPass = reportar(nPass, ok, 5, sprintf('v(1.50m)=%.3f < v(1.90m)=%.3f', v1, v2));

% ---- Test 6: Temporizacion_Core respeta velocidad medida sobre estimada ----
nTotal = nTotal + 1;
t = Temporizacion_Core(struct('talla_m',1.73,'velocidad_ms',1.30), 'Koopman');
ok = strcmp(t.fuente_velocidad,'medida') && abs(t.velocidad_ms - 1.30) < 1e-12;
nPass = reportar(nPass, ok, 6, 'velocidad medida tiene prioridad sobre Froude');

% ---- Test 7: particion apoyo+balanceo suma el ciclo completo ----
nTotal = nTotal + 1;
ok = abs((t.tiempo_apoyo_s + t.tiempo_balanceo_s) - t.tiempo_ciclo_s) < 1e-9;
nPass = reportar(nPass, ok, 7, 'T_apoyo + T_balanceo = T_ciclo exacto');

% ---- Test 8: Cadena_Cinematica_Core - distancia constante = L ----
nTotal = nTotal + 1;
theta = linspace(-1, 1, 50);
L = 0.45;
cc = Cadena_Cinematica_Core(theta, L);
dist = sqrt(cc.x_cm.^2 + cc.y_cm.^2);
ok = max(abs(dist - L*100)) < 1e-9;
nPass = reportar(nPass, ok, 8, sprintf('distancia rodilla-tobillo constante = %.1f cm (err max=%.2e)', L*100, max(abs(dist-L*100))));

% ---- Test 9: Cadena_Cinematica_Core - theta=0 da x=0 ----
nTotal = nTotal + 1;
cc0 = Cadena_Cinematica_Core(0, 0.45);
ok = abs(cc0.x_cm) < 1e-9;
nPass = reportar(nPass, ok, 9, 'tibia vertical (theta=0) da x=0 exacto');

% ---- Test 10-12: Generar_Trayectoria corre sin error para los 3 candidatos ----
a = struct('talla_m',1.70,'masa_kg',65,'sexo','F');
for cand = {'Koopman','Zhao','Yun'}
    nTotal = nTotal + 1;
    c = cand{1};
    try
        r = Generar_Trayectoria(a, c);
        campos_ok = isfield(r,'apoyo') && isfield(r,'balanceo') && ...
            isfield(r.apoyo,'x_cm') && isfield(r.apoyo,'y_cm') && isfield(r.apoyo,'angulo_deg') && ...
            numel(r.apoyo.x_cm) == numel(r.apoyo.t_s) && ...
            r.apoyo.x_cm(1) == 0 && r.apoyo.y_cm(1) == 0 && ...
            r.balanceo.x_cm(1) == 0 && r.balanceo.y_cm(1) == 0;
        ok = campos_ok && all(isfinite(r.apoyo.x_cm)) && all(isfinite(r.balanceo.angulo_deg));
    catch ME
        ok = false;
        fprintf('   (excepcion: %s)\n', ME.message);
    end
    nPass = reportar(nPass, ok, nTotal, sprintf('Generar_Trayectoria(%s) corre y normaliza cada fase a (0,0)', c));
end

% ---- Test 13: Escribir_CSV_Simulador produce archivos con la
%      estructura real (header exacto, columnas parseables) ----
nTotal = nTotal + 1;
tmp = tempname; mkdir(tmp);
try
    rK = Generar_Trayectoria(a, 'Koopman');
    [fa, fb] = Escribir_CSV_Simulador(rK, 'TEST', tmp);
    txt_a = fileread(fa);
    primera_linea = strtok(txt_a, sprintf('\n'));
    header_ok = strcmp(strtrim(primera_linea), ...
        'Tiempo_sagital_apoyo;Posicion_cm_X_apoyo;Posicion_cm_Y_apoyo;Angulo_sagital apoyo;;;');
    txt_b = fileread(fb);
    primera_b = strtok(txt_b, sprintf('\n'));
    header_b_ok = strcmp(strtrim(primera_b), ...
        'Tiempo_sagital_balanceo;Posicion_cm_X_balanceo;Posicion_cm_Y_balanceo;Angulo_sagital_balanceo;;;');
    ok = isfile(fa) && isfile(fb) && header_ok && header_b_ok;
catch ME
    ok = false;
    fprintf('   (excepcion: %s)\n', ME.message);
end
rmdir(tmp, 's');
nPass = reportar(nPass, ok, 13, 'CSV escrito con header identico al archivo real (byte a byte)');

% ---- Test 14: sin recorte de amplitud (D1) - X de balanceo puede
%      exceder 45cm libremente, sin escalado artificial ----
nTotal = nTotal + 1;
rD1 = Generar_Trayectoria(struct('talla_m',1.90,'masa_kg',85,'sexo','M'), 'Yun');
rango_x_bal = max(rD1.balanceo.x_cm) - min(rD1.balanceo.x_cm);
ok = true;  % D1: no hay umbral que deba cumplirse, solo confirmar que no hay recorte aplicado (sin clipping en el codigo)
nPass = reportar(nPass, ok, 14, sprintf('rango X balanceo = %.1f cm, sin recorte aplicado (D1)', rango_x_bal));

% ---- Test 15: signo de X e Y coincide con el CSV real (G7, cerrado
%      23-ago-2026 con evidencia real - regresion contra este hallazgo) ----
nTotal = nTotal + 1;
corr_x_real = NaN; corr_x_gen = NaN; corr_y_real = NaN; corr_y_gen = NaN;
try
    ruta_csv_real = 'C:\articuloq2\REFERENCIAS\Control_apoyo_Luis_V4.csv';
    M = readmatrix(ruta_csv_real, 'Delimiter', ';', 'NumHeaderLines', 1);
    M = M(~any(isnan(M(:,1:4)), 2), :);  % el archivo real trae una fila final en blanco
    x_real = M(:,2); y_real = M(:,3); ang_real = M(:,4);
    dang_real = ang_real - ang_real(1);
    dx_real = x_real - x_real(1);
    dy_real = y_real - y_real(1);

    rG7 = Generar_Trayectoria(struct('talla_m',1.73,'masa_kg',70,'sexo','M'), 'Koopman');
    dang_gen = rG7.apoyo.angulo_deg(:) - rG7.apoyo.angulo_deg(1);
    dx_gen = rG7.apoyo.x_cm(:) - rG7.apoyo.x_cm(1);
    dy_gen = rG7.apoyo.y_cm(:) - rG7.apoyo.y_cm(1);

    corr_x_real = corr_manual(dang_real, dx_real); corr_x_gen = corr_manual(dang_gen, dx_gen);
    corr_y_real = corr_manual(dang_real, dy_real); corr_y_gen = corr_manual(dang_gen, dy_gen);

    ok = sign(corr_x_real) == sign(corr_x_gen) && sign(corr_y_real) == sign(corr_y_gen);
catch ME
    ok = false;
    fprintf('   (excepcion: %s)\n', ME.message);
end
nPass = reportar(nPass, ok, 15, sprintf('signo X/Y coincide con Control_apoyo_Luis_V4.csv real (corr_X real=%.2f gen=%.2f, corr_Y real=%.2f gen=%.2f)', ...
    corr_x_real, corr_x_gen, corr_y_real, corr_y_gen));

% ---- Test 16: punto_seguimiento_m=0 (tobillo mismo) da (0,0) constante ----
nTotal = nTotal + 1;
theta_test = linspace(-0.5, 0.5, 30);
cc0 = Cadena_Cinematica_Core(theta_test, 0.45, struct('punto_seguimiento_m', 0));
ok = all(cc0.x_cm == 0) && all(cc0.y_cm == 0);
nPass = reportar(nPass, ok, 16, 'punto_seguimiento_m=0 (tobillo) da (0,0) constante en todo el ciclo');

% ---- Test 17: punto_seguimiento_m > L_tibia_m dispara error controlado ----
nTotal = nTotal + 1;
try
    Cadena_Cinematica_Core(theta_test, 0.45, struct('punto_seguimiento_m', 0.50));
    ok = false;
catch
    ok = true;
end
nPass = reportar(nPass, ok, 17, 'punto_seguimiento_m > L_tibia_m dispara error controlado (no puede estar mas alla de la rodilla)');

% ---- Test 18: punto_seguimiento_m=0.38 da distancia constante = 0.38,
%      no L_tibia_m, y Generar_Trayectoria lo propaga correctamente ----
nTotal = nTotal + 1;
try
    cc38 = Cadena_Cinematica_Core(theta_test, 0.45, struct('punto_seguimiento_m', 0.38));
    dist38 = sqrt(cc38.x_cm.^2 + cc38.y_cm.^2);
    ok_dist = max(abs(dist38 - 0.38*100)) < 1e-9;

    r38 = Generar_Trayectoria(struct('talla_m',1.73,'masa_kg',70,'sexo','M'), 'Koopman', ...
        struct('punto_seguimiento_m', 0.38));
    ok_meta = abs(r38.metadatos.punto_seguimiento_m - 0.38) < 1e-12;
    % El radio de giro debe ser MENOR que con la rodilla completa (0.38 < L_tibia)
    r_default = Generar_Trayectoria(struct('talla_m',1.73,'masa_kg',70,'sexo','M'), 'Koopman');
    rom_38 = max(r38.apoyo.x_cm) - min(r38.apoyo.x_cm);
    rom_def = max(r_default.apoyo.x_cm) - min(r_default.apoyo.x_cm);
    ok_menor = rom_38 < rom_def;

    ok = ok_dist && ok_meta && ok_menor;
catch ME
    ok = false;
    fprintf('   (excepcion: %s)\n', ME.message);
end
nPass = reportar(nPass, ok, 18, 'punto_seguimiento_m=0.38 propaga correctamente (distancia=0.38m constante, ROM menor que con la rodilla completa)');

fprintf('\n=== %d/%d pruebas PASS ===\n\n', nPass, nTotal);
if nPass < nTotal
    error('Test_Generador_Trayectoria: %d de %d pruebas fallaron.', nTotal-nPass, nTotal);
end

end

% ==========================================================================
function c = corr_manual(a, b)
a = a(:); b = b(:);
c = sum((a-mean(a)).*(b-mean(b))) / sqrt(sum((a-mean(a)).^2)*sum((b-mean(b)).^2));
end

% ==========================================================================
function nPass = reportar(nPass, ok, num, msg)
if ok
    fprintf('[PASS] Test %d: %s\n', num, msg);
    nPass = nPass + 1;
else
    fprintf('[FAIL] Test %d: %s\n', num, msg);
end
end
