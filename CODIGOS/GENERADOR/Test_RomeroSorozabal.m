function Test_RomeroSorozabal()
% TEST_ROMEROSOROZABAL  Pruebas sinteticas + visualizacion interactiva de
%                        Romero_Sorozabal2024_Core.m (24-ago-2026, sesion
%                        de continuacion de plan_ensamble_multimodelo.md).
%                        Mismo patron Test_*.m del resto de CODIGOS/GENERADOR.

fprintf('=== Test_RomeroSorozabal ===\n\n');
nPass = 0; nTotal = 0;

% Sujeto de referencia: talla y velocidad tipicas del dataset (mediana
% cohorte joven: 171cm, 4.6 kph)
v_kph = 4.6;
l_m = 1.71;

out = Romero_Sorozabal2024_Core(v_kph, l_m);

% --- Test 1: campos de salida presentes ---
nTotal = nTotal + 1;
ok = isfield(out,'cadera') && isfield(out,'rodilla') && isfield(out,'tobillo');
nPass = nPass + reporta(ok, 'Test 1: struct con cadera/rodilla/tobillo');

% --- Test 2: cada articulacion tiene x_m,y_m,z_m,z_abajo_pelvis_m,pct_ciclo ---
nTotal = nTotal + 1;
campos_ok = true;
for art = {'cadera','rodilla','tobillo'}
    a = out.(art{1});
    campos_ok = campos_ok && all(isfield(a, {'x_m','y_m','z_m','z_abajo_pelvis_m','pct_ciclo'}));
end
nPass = nPass + reporta(campos_ok, 'Test 2: campos completos en las 3 articulaciones');

% --- Test 3: z_abajo_pelvis_m = -z_m (consistencia interna) ---
nTotal = nTotal + 1;
ok = max(abs(out.tobillo.z_abajo_pelvis_m + out.tobillo.z_m)) < 1e-10;
nPass = nPass + reporta(ok, 'Test 3: z_abajo_pelvis_m es -z_m exacto');

% --- Test 4: continuidad ciclica (pct=0 aprox igual a pct=100) ---
% El primer key-point (t=1%) y el ultimo (t=100%) tienen su PROPIA
% regresion de y (no son copia exacta como en Koopman) - se espera
% continuidad razonable, no exacta. Verificamos que la diferencia sea
% pequena relativa al rango de la curva (< 15%), no que sea cero.
nTotal = nTotal + 1;
rango_z = range(out.tobillo.z_m);
salto = abs(out.tobillo.z_m(1) - out.tobillo.z_m(end));
ok = salto < 0.15 * rango_z;
nPass = nPass + reporta(ok, sprintf('Test 4: continuidad ciclica tobillo-Z razonable (salto=%.4fm, %.1f%% del rango)', salto, 100*salto/rango_z));

% --- Test 5: rangos plausibles contra Fig.2b/3a del paper (orden de magnitud) ---
% Z de rodilla/tobillo EXCLUIDO de este chequeo a proposito - ver
% "ANOMALIA CONOCIDA" en el encabezado de Romero_Sorozabal2024_Core.m:
% beta3(altura) de las Tablas A2-Z/A3-Z da ~2x la profundidad esperada
% (verificado con 2 chequeos antropometricos independientes, tabla
% re-confirmada contra la pagina HTML de MDPI - no es error de
% transcripcion). Decision del usuario 24-ago-2026: no se usa Z de este
% candidato en el ensamble, solo X. Aqui solo se verifica lo que SI se usa.
nTotal = nTotal + 1;
ok = true;
ok = ok && max(abs(out.cadera.x_m)) < 0.3;              % hip X: paper ~ -0.1 a 0.1
ok = ok && all(out.cadera.z_m > -0.4 & out.cadera.z_m < 0.1);   % hip Z: paper ~ -0.05 a -0.25 (SI consistente)
ok = ok && max(abs(out.tobillo.x_m)) < 1.0;              % ankle X: paper ~ -0.5 a 0.5
nPass = nPass + reporta(ok, 'Test 5: rangos de posicion plausibles en los campos USADOS por el ensamble (cadera X/Z, tobillo X)');
fprintf('    [info] rodilla/tobillo Z (NO usados en el ensamble): rodilla=[%.3f %.3f]m, tobillo=[%.3f %.3f]m -- ver anomalia declarada en el encabezado del .m\n', ...
    min(out.rodilla.z_m), max(out.rodilla.z_m), min(out.tobillo.z_m), max(out.tobillo.z_m));

% --- Test 6: rodilla entre cadera y tobillo en Z (orden anatomico) ---
nTotal = nTotal + 1;
ok = all(out.cadera.z_m > out.rodilla.z_m) && all(out.rodilla.z_m > out.tobillo.z_m);
nPass = nPass + reporta(ok, 'Test 6: orden anatomico cadera > rodilla > tobillo en Z (todo el ciclo)');

% --- Test 7: advertencias de rango se disparan fuera de dataset ---
nTotal = nTotal + 1;
w = warning('off', 'all');
lastwarn('');
Romero_Sorozabal2024_Core(0.5, 1.71); % velocidad fuera de 1.29-8.02
[msg, id] = lastwarn();
ok = strcmp(id, 'RomeroSorozabal2024:rangoVelocidad');
warning(w);
nPass = nPass + reporta(ok, 'Test 7: advertencia de rango de velocidad se dispara fuera del dataset');

% --- Test 8: entradas invalidas lanzan error ---
nTotal = nTotal + 1;
ok = false;
try
    Romero_Sorozabal2024_Core(-1, 1.71);
catch
    ok = true;
end
nPass = nPass + reporta(ok, 'Test 8: v_kph negativo lanza error');

fprintf('\n=== %d/%d PASS ===\n\n', nPass, nTotal);

% --- Visualizacion interactiva ---
visualizar(v_kph, l_m);

end

% ==========================================================================
function ok = reporta(cond, msg)
if cond
    fprintf('  [PASS] %s\n', msg);
else
    fprintf('  [FAIL] %s\n', msg);
end
ok = double(cond);
end

% ==========================================================================
function visualizar(v_kph, l_m)
% Genera una figura interactiva (queda abierta en MATLAB para que el
% usuario la manipule - zoom, rotar, etc.) y ademas la guarda como PNG
% para revisión rapida fuera de MATLAB.

out = Romero_Sorozabal2024_Core(v_kph, l_m);

fig = figure('Name', 'Romero-Sorozabal 2024 - verificacion visual', ...
    'Position', [100 100 1200 700], 'Color', 'w');

colores = struct('cadera', [0.20 0.40 0.70], 'rodilla', [0.85 0.45 0.10], 'tobillo', [0.20 0.65 0.30]);
articulaciones = {'cadera','rodilla','tobillo'};

% --- Subplot 1: vista sagital (x vs z_abajo_pelvis), como Fig.4 del paper ---
subplot(2,2,1); hold on; grid on; box on;
for k = 1:3
    a = out.(articulaciones{k});
    plot(a.x_m, a.z_abajo_pelvis_m, '-', 'Color', colores.(articulaciones{k}), 'LineWidth', 2, ...
        'DisplayName', articulaciones{k});
end
set(gca, 'YDir', 'reverse'); % z_abajo_pelvis crece hacia abajo -> pantalla hacia abajo
xlabel('X sagital [m] (convencion nativa del paper, signo sin verificar)');
ylabel('Distancia debajo de pelvis [m]');
title(sprintf('Vista sagital (v=%.1f kph, talla=%.2fm)', v_kph, l_m));
legend('Location','best');

% --- Subplot 2: X (sagital) vs %ciclo, las 3 articulaciones ---
subplot(2,2,2); hold on; grid on; box on;
for k = 1:3
    a = out.(articulaciones{k});
    plot(a.pct_ciclo, a.x_m, '-', 'Color', colores.(articulaciones{k}), 'LineWidth', 2, ...
        'DisplayName', articulaciones{k});
end
xlabel('% ciclo de marcha'); ylabel('X sagital [m]');
title('Posicion sagital vs. ciclo'); legend('Location','best');

% --- Subplot 3: altura debajo de pelvis vs %ciclo ---
subplot(2,2,3); hold on; grid on; box on;
for k = 1:3
    a = out.(articulaciones{k});
    plot(a.pct_ciclo, a.z_abajo_pelvis_m, '-', 'Color', colores.(articulaciones{k}), 'LineWidth', 2, ...
        'DisplayName', articulaciones{k});
end
xlabel('% ciclo de marcha'); ylabel('Distancia debajo de pelvis [m]');
title('Altura vs. ciclo'); legend('Location','best');

% --- Subplot 4: theta_tibia derivado (atan2), comparado con Koopman/Yun ---
subplot(2,2,4); hold on; grid on; box on;
dx = out.tobillo.x_m - out.rodilla.x_m;
dz = out.tobillo.z_abajo_pelvis_m - out.rodilla.z_abajo_pelvis_m;
theta_tibia_rs_deg = rad2deg(atan2(dx, dz)); % 0=vertical, mismo signo que Segmento_Posicion_Core.m
plot(out.tobillo.pct_ciclo, theta_tibia_rs_deg, 'k-', 'LineWidth', 2.5, 'DisplayName', 'Romero-Sorozabal (derivado)');

try
    outK = Koopman2014_Core(v_kph, l_m);
    pct = linspace(0,100,numel(outK.theta_tibia_via_tobillo_deg));
    plot(pct, outK.theta_tibia_via_tobillo_deg, '--', 'Color',[0.6 0.6 0.6], 'LineWidth', 1.5, 'DisplayName', 'Koopman 2014 (via tobillo)');
catch ME
    fprintf('  [aviso] no se pudo superponer Koopman: %s\n', ME.message);
end

xlabel('% ciclo de marcha'); ylabel('\theta_{tibia} [deg] (0=vertical)');
title({'\theta_{tibia} SOLO DIAGNOSTICO - usa Z de rodilla/tobillo', 'EXCLUIDA del ensamble (ver anomalia declarada)'});
legend('Location','best');

sgtitle('Romero-Sorozabal 2024 -- verificacion visual (CODIGOS/GENERADOR)', 'FontWeight','bold');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Test_RomeroSorozabal_figura.png');
try
    exportgraphics(fig, out_png, 'Resolution', 150);
    fprintf('Figura guardada en: %s\n', out_png);
catch ME
    fprintf('  [aviso] no se pudo exportar PNG: %s\n', ME.message);
end

end
