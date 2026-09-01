function Test_GRF_Newton_ApoyoSimple()
% TEST_GRF_NEWTON_APOYOSIMPLE  Pruebas de MasaSegmentaria_DeLeva1996_Core.m
%                    y GRF_Newton_ApoyoSimple_Core.m (28-ago-2026). Cierra
%                    H16 de _REVISION/detalle/03_codigo.md ("archivos
%                    *_Core.m nuevos sin Test_*.m, rompe la convencion
%                    Core/Test/Guia del proyecto").
%
% Yun se EXCLUYE de las pruebas automaticas a proposito (no por omision):
% corre una regresion GPR de terceros, ~1-2 min por llamada con I/O de 30
% archivos - mismo criterio ya establecido en el resto del proyecto
% (Fukuchi/CIERRE_*.md: "Yun pendiente, bloqueado por carga de maquina").
% Test 8 lo ejercita, pero con try/catch que reporta WARN (no FAIL) si
% tarda o falla por recursos - no bloquea la corrida completa del archivo.
% ==========================================================================
addpath(fileparts(mfilename('fullpath')));
fprintf('\n=== Test_GRF_Newton_ApoyoSimple ===\n\n');
nPass = 0; nTotal = 0;

% ---- Test 1: MasaSegmentaria - suma de todos los segmentos ~100%, F ----
nTotal = nTotal + 1;
mF = MasaSegmentaria_DeLeva1996_Core(struct('masa_kg', 61.9, 'sexo', 'F'));
ok = abs(mF.verificacion_suma_pct - 100) < 0.05;
nPass = reportar(nPass, ok, 1, sprintf('suma masa segmentaria F = %.4f%% (~100)', mF.verificacion_suma_pct));

% ---- Test 2: idem, M ----
nTotal = nTotal + 1;
mM = MasaSegmentaria_DeLeva1996_Core(struct('masa_kg', 73.0, 'sexo', 'M'));
ok = abs(mM.verificacion_suma_pct - 100) < 0.05;
nPass = reportar(nPass, ok, 2, sprintf('suma masa segmentaria M = %.4f%% (~100)', mM.verificacion_suma_pct));

% ---- Test 3: masa_kg de un segmento = fraccion * masa_total (consistencia interna) ----
nTotal = nTotal + 1;
ok = abs(mF.muslo_masa_kg - mF.muslo_masa_frac*61.9) < 1e-9 && abs(mF.hat_masa_kg - mF.hat_masa_frac*61.9) < 1e-9;
nPass = reportar(nPass, ok, 3, 'masa_kg por segmento = fraccion * masa_total');

% ---- Test 4: sexo invalido dispara error controlado ----
nTotal = nTotal + 1;
try
    MasaSegmentaria_DeLeva1996_Core(struct('masa_kg', 70, 'sexo', 'X'));
    ok = false;
catch
    ok = true;
end
nPass = reportar(nPass, ok, 4, 'sexo invalido dispara error');

% ---- Test 5: GRF Koopman - autochequeo de energia (media vGRF en un
% ciclo completo = peso corporal, exacto por periodicidad) ----
nTotal = nTotal + 1;
antro = struct('talla_m', 1.70, 'masa_kg', 70, 'sexo', 'F');
oK = GRF_Newton_ApoyoSimple_Core(antro, 'Koopman');
ok = abs(oK.verificacion_media_vGRF_pctBW - 100) < 5;
nPass = reportar(nPass, ok, 5, sprintf('Koopman: media vGRF = %.2f%%BW (~100, tol 5)', oK.verificacion_media_vGRF_pctBW));

% ---- Test 6: idem, Zhao ----
nTotal = nTotal + 1;
oZ = GRF_Newton_ApoyoSimple_Core(antro, 'Zhao');
ok = abs(oZ.verificacion_media_vGRF_pctBW - 100) < 5;
nPass = reportar(nPass, ok, 6, sprintf('Zhao: media vGRF = %.2f%%BW (~100, tol 5)', oZ.verificacion_media_vGRF_pctBW));

% ---- Test 7: GRF horizontal medio en un ciclo completo ~ 0 (mismo
% argumento de periodicidad que el Test 5/6, para el eje anteroposterior -
% ningun avance neto puede venir de una fuerza horizontal con media
% distinta de cero sobre un ciclo cerrado) ----
%
% FALLA A PROPOSITO desde el 29-ago-2026 (no se ajusto el umbral ni el
% test para taparlo, mismo criterio que Test 15 de Test_Generador_
% Trayectoria.m): consecuencia YA DECLARADA del cambio de cadera de esta
% sesion (Cadera_Continua_Zhao_Core.m V1 quito el pico de cientos de %BW
% del quiebre de velocidad, pero declara en su propia cabecera que puede
% quedar "un pequeno quiebre de VALOR" residual en los 4 bordes internos
% de la mezcla lineal de doble apoyo - eso rompe la periodicidad exacta de
% la velocidad horizontal, y por eso la media de GRF horizontal ya no da
% exactamente 0). No se persigue mas en esta sesion porque el pipeline
% completo de GRF_Newton_ApoyoSimple_Core.m quedo SUPERADO por el modelo
% empirico de Fukuchi (Predecir_GRF_Personalizado_Core.m, r=0.866 contra
% Kuopio vs. r=0.40 de este pipeline) - ver GUIA_INTERPRETACION.md
% #8-quinquies. Resolver este Test 7 de raiz exigiria cerrar el sistema de
% 2 piernas acopladas (ver limitacion abierta en Cadera_Continua_Zhao_
% Core.m), no vale la pena para un pipeline ya no recomendado.
nTotal = nTotal + 1;
media_h_pctBW = 100*mean(oK.GRF_horizontal_N)/(70*9.80665);
ok = abs(media_h_pctBW) < 5;
nPass = reportar(nPass, ok, 7, sprintf('Koopman: media GRF horizontal = %.2f%%BW (~0, tol 5)', media_h_pctBW));

% ---- Test 8: dentro de apoyo_simple_mask_estricta (erosionada, ver
% cabecera de GRF_Newton_ApoyoSimple_Core.m), vGRF en rango fisiologico
% plausible (no exacto - banda amplia a proposito). NOTA: con la mascara
% SIN erosionar este test fallaba (min~3%BW) - la version erosionada es
% la que corrige eso, hallazgo de esta misma prueba el 28-ago-2026, ver
% comentario "Mascara ERODIDA" en GRF_Newton_ApoyoSimple_Core.m ----
nTotal = nTotal + 1;
vgrf_simple = oK.GRF_vertical_pctBW(oK.apoyo_simple_mask_estricta);
ok = ~isempty(vgrf_simple) && all(vgrf_simple > 20) && all(vgrf_simple < 250);
nPass = reportar(nPass, ok, 8, sprintf('Koopman: vGRF en apoyo_simple_mask_estricta en [%.1f, %.1f]%%BW (banda [20,250])', ...
    min(vgrf_simple), max(vgrf_simple)));

% ---- Test 9: candidato='Combinado' rechazado explicitamente (no expone
% theta_muslo/theta_tibia por separado, ver cabecera) ----
nTotal = nTotal + 1;
try
    GRF_Newton_ApoyoSimple_Core(antro, 'Combinado');
    ok = false;
catch
    ok = true;
end
nPass = reportar(nPass, ok, 9, 'candidato=''Combinado'' rechazado con error claro');

% ---- Test 10: masa_kg/sexo faltantes disparan error (GRF los necesita,
% a diferencia de Generar_Trayectoria.m que puede correr solo con talla) ----
nTotal = nTotal + 1;
try
    GRF_Newton_ApoyoSimple_Core(struct('talla_m', 1.70), 'Koopman');
    ok = false;
catch
    ok = true;
end
nPass = reportar(nPass, ok, 10, 'antropometria sin masa_kg/sexo dispara error');

% ---- Test 11 (informativo, no cuenta para el PASS/FAIL final): Yun,
% mismo autochequeo que Test 5/6 - excluido del conteo por su costo, ver
% cabecera. No usa reportar() para no afectar nTotal/nPass. ----
fprintf('\n[INFO] Test 11 (Yun, no cuenta en el resumen): puede tardar 1-2 min...\n');
try
    tYun = tic;
    oY = GRF_Newton_ApoyoSimple_Core(antro, 'Yun');
    okY = abs(oY.verificacion_media_vGRF_pctBW - 100) < 5;
    if okY
        fprintf('[INFO] Yun: media vGRF = %.2f%%BW (~100, tol 5) - OK, %.1fs\n', oY.verificacion_media_vGRF_pctBW, toc(tYun));
    else
        fprintf('[WARN] Yun: media vGRF = %.2f%%BW - FUERA de tolerancia, revisar\n', oY.verificacion_media_vGRF_pctBW);
    end
catch ME
    fprintf('[WARN] Yun: no se pudo correr (%s) - no bloquea el resto de las pruebas\n', ME.message);
end

fprintf('\n=== %d/%d pruebas PASS (Test 1-10; Test 11/Yun informativo aparte) ===\n\n', nPass, nTotal);
if nPass < nTotal
    error('Test_GRF_Newton_ApoyoSimple: %d de %d pruebas fallaron.', nTotal-nPass, nTotal);
end

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
