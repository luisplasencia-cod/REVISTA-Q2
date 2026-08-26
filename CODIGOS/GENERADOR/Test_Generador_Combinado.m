function Test_Generador_Combinado()
% TEST_GENERADOR_COMBINADO  Prueba de integracion minima: candidato=
%                            'Combinado' en Generar_Trayectoria.m
%                            (24-ago-2026, cierre del paso 6 de
%                            plan_ensamble_multimodelo.md Sec.5). La
%                            correctitud del PROMEDIO en si ya la prueba
%                            Test_Combinar_Candidatos.m (6/6 PASS) - esto
%                            solo verifica el cableado E6/normalizacion/
%                            restriccion de punto_seguimiento_m.

fprintf('=== Test_Generador_Combinado ===\n\n');
nPass = 0; nTotal = 0;

antro_in = struct('talla_m', 1.71, 'masa_kg', 68, 'sexo', 'M');

% --- Test 1: corre sin error, campos completos ---
nTotal = nTotal + 1;
try
    r = Generar_Trayectoria(antro_in, 'Combinado');
    ok = all(isfield(r, {'apoyo','balanceo','metadatos'})) && ...
         all(isfield(r.apoyo, {'t_s','x_cm','y_cm','angulo_deg'})) && ...
         all(isfield(r.balanceo, {'t_s','x_cm','y_cm','angulo_deg'}));
catch ME
    ok = false;
    fprintf('    excepcion: %s\n', ME.message);
end
nPass = nPass + reporta(ok, 'Test 1: Generar_Trayectoria(antro,''Combinado'') corre y devuelve campos completos');

% --- Test 2: todo finito, sin NaN/Inf ---
nTotal = nTotal + 1;
ok = all(isfinite(r.apoyo.x_cm)) && all(isfinite(r.apoyo.y_cm)) && ...
     all(isfinite(r.balanceo.x_cm)) && all(isfinite(r.balanceo.y_cm)) && ...
     all(isfinite(r.apoyo.angulo_deg)) && all(isfinite(r.balanceo.angulo_deg));
nPass = nPass + reporta(ok, 'Test 2: salida completamente finita (sin NaN/Inf)');

% --- Test 3: normalizacion a (0,0) en la 1ra muestra de cada fase ---
nTotal = nTotal + 1;
ok = abs(r.apoyo.x_cm(1)) < 1e-9 && abs(r.apoyo.y_cm(1)) < 1e-9 && ...
     abs(r.balanceo.x_cm(1)) < 1e-9 && abs(r.balanceo.y_cm(1)) < 1e-9;
nPass = nPass + reporta(ok, 'Test 3: normalizacion (0,0) en la 1ra muestra, igual que los otros 3 candidatos');

% --- Test 4: E6 (traslacion de balanceo) SI se aplico - el balanceo combinado
%     avanza netamente en X (no vuelve exactamente al mismo x que empezo,
%     salvo compensacion casual) ---
nTotal = nTotal + 1;
avance_neto_cm = r.balanceo.x_cm(end) - r.balanceo.x_cm(1);
ok = abs(avance_neto_cm) > 1;  % deberia ser un avance de varios cm, no ~0
nPass = nPass + reporta(ok, sprintf('Test 4: traslacion E6 aplicada al balanceo combinado (avance neto=%.1fcm)', avance_neto_cm));

% --- Test 5: restriccion de punto_seguimiento_m - debe fallar si es distinto de la rodilla ---
nTotal = nTotal + 1;
ok = false;
try
    Generar_Trayectoria(antro_in, 'Combinado', struct('punto_seguimiento_m', 0.10));
catch
    ok = true;
end
nPass = nPass + reporta(ok, 'Test 5: punto_seguimiento_m distinto de la rodilla anatomica lanza error con ''Combinado''');

% --- Test 6: punto_seguimiento_m = long_tibia_m explicito (mismo valor) SI funciona ---
nTotal = nTotal + 1;
antro_completo = Estimar_Antropometria_Core(antro_in);
try
    r6 = Generar_Trayectoria(antro_in, 'Combinado', struct('punto_seguimiento_m', antro_completo.long_tibia_m));
    ok = isfinite(r6.apoyo.x_cm(end));
catch
    ok = false;
end
nPass = nPass + reporta(ok, 'Test 6: punto_seguimiento_m EXACTO a la rodilla anatomica SI funciona con ''Combinado''');

fprintf('\n=== %d/%d PASS ===\n\n', nPass, nTotal);

end

% ==========================================================================
function ok = reporta(cond, msg)
if cond, fprintf('  [PASS] %s\n', msg); else, fprintf('  [FAIL] %s\n', msg); end
ok = double(cond);
end
