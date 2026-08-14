% ===================================================
% TEST_POTENCIAAPRIORI_TOST
% Prueba automatizada de PotenciaApriori_Core.m y TOST_Core.m con datos
% sinteticos de verdad conocida (mismo patron que
% CODIGOS/CALIBRACION/Test_Calibracion_Offset.m,
% CODIGOS/ESTADISTICA/Test_SPM1D_BlandAltman.m y
% CODIGOS/MULTISUJETO/Test_Procesar_Multisujeto.m).
%
% Parte A: PotenciaApriori_Core - verifica que la tasa de falsos
%          positivos con efecto=0 se acerca a alpha, que la potencia
%          sube con N y con el efecto, y que un efecto grande con N
%          grande alcanza el objetivo de 80%.
% Parte B: TOST_Core - verifica que detecta equivalencia cuando la
%          diferencia real esta dentro del margen (pareado e
%          independiente), que la rechaza cuando esta claramente fuera,
%          y que no revienta con SE=0 (datos identicos).
%
% No revalida SPM1D_Core.m desde cero - eso ya lo hace
% Test_SPM1D_BlandAltman.m. Usa parametros mas chicos que el default de
% produccion (n_iter, n_perm) para que la prueba corra en minutos, no
% horas - el default de produccion se corre aparte cuando haga falta el
% resultado real para el articulo.
% ===================================================

clear; clc;
addpath(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'ESTADISTICA'));

fprintf('=== Test_PotenciaApriori_TOST ===\n\n');
n_pass = 0; n_total = 0;

%% ---- PARTE A: PotenciaApriori_Core ----
rng(2026);
eje_x = linspace(0,60,61)';
curva_base = 20*sin(pi*eje_x/60) + 5;   % forma tipo angulo de rodilla, grados
sd_trial = 0.5*ones(size(eje_x));       % variabilidad ensayo-a-ensayo sintetica

opcA = struct('efectos', [0 5], 'Ns', [5 15 30], ...
              'n_trials_sujeto', 4, 'n_trials_ref', 8, ...
              'factor_intersujeto', 1.5, 'n_iter', 60, 'n_perm', 400, ...
              'graficar', false, 'guardar_en', '', 'unidad', ' deg');

resA = PotenciaApriori_Core(curva_base, sd_trial, opcA);

% Test 1: con efecto=0, la tasa de deteccion (falso positivo) esta
% razonablemente cerca de alpha=0.05 (tolerancia amplia: n_iter=60 da
% ruido binomial grande; se acepta hasta 3x alpha)
n_total = n_total + 1;
fp_rate = resA.potencia(1, end);   % efecto=0, N mas grande
if fp_rate <= 0.15
    fprintf('[PASS] Test 1: tasa de falso positivo con efecto=0 es %.3f (<=0.15, esperado ~alpha=0.05)\n', fp_rate); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 1: tasa de falso positivo con efecto=0 es %.3f, demasiado alta\n', fp_rate);
end

% Test 2: con efecto grande (5 deg, 10x sd_trial) y N grande, la
% potencia es alta
n_total = n_total + 1;
pot_alta = resA.potencia(2, end);   % efecto=5, N=30
if pot_alta >= 0.8
    fprintf('[PASS] Test 2: potencia con efecto=5deg y N=30 es %.3f (>=0.80)\n', pot_alta); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 2: potencia con efecto=5deg y N=30 es %.3f, mas baja de lo esperado\n', pot_alta);
end

% Test 3: la potencia con efecto=5 no baja al aumentar N (monotonia no
% estricta - tolera empates por ruido Monte Carlo)
n_total = n_total + 1;
fila_efecto5 = resA.potencia(2,:);
if all(diff(fila_efecto5) >= -0.15)
    fprintf('[PASS] Test 3: potencia (efecto=5deg) no cae al aumentar N: %s\n', mat2str(fila_efecto5,2)); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 3: potencia (efecto=5deg) cae de forma no monotona: %s\n', mat2str(fila_efecto5,2));
end

% Test 4: N_para_objetivo es finito para el efecto grande (se alcanza
% 80% dentro del grid evaluado) y NaN o mayor que para el efecto nulo
n_total = n_total + 1;
if ~isnan(resA.N_para_objetivo(2))
    fprintf('[PASS] Test 4: N_para_objetivo(efecto=5deg) = %.1f (finito, se alcanza el 80%% dentro del grid)\n', resA.N_para_objetivo(2)); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 4: N_para_objetivo(efecto=5deg) salio NaN - no alcanzo 80%% ni con N=30 (revisar parametros del test)\n');
end

%% ---- PARTE B: TOST_Core ----
rng(2026);

% Caso 1: pareado, diferencia real pequena (0.2 deg) dentro de un
% margen de 1 deg -> debe concluir equivalencia
n = 20;
x1 = 10 + 0.2 + 0.3*randn(n,1);
y1 = 10 + 0.3*randn(n,1);
r1 = TOST_Core(x1, y1, 1.0, struct('nombre_metrica','pico_pareado_equivalente'));

n_total = n_total + 1;
if r1.equivalente
    fprintf('[PASS] Test 5: TOST pareado detecta equivalencia con diferencia chica dentro de margen 1.0 (p_TOST=%.4f)\n', r1.p_tost); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 5: TOST pareado NO detecto equivalencia esperada (p_TOST=%.4f, d=%.3f)\n', r1.p_tost, r1.diferencia_media);
end

% Caso 2: pareado, diferencia real grande (3 deg) fuera de un margen de
% 1 deg -> NO debe concluir equivalencia
x2 = 10 + 3.0 + 0.3*randn(n,1);
y2 = 10 + 0.3*randn(n,1);
r2 = TOST_Core(x2, y2, 1.0, struct('nombre_metrica','pico_pareado_no_equivalente'));

n_total = n_total + 1;
if ~r2.equivalente
    fprintf('[PASS] Test 6: TOST pareado NO concluye equivalencia con diferencia grande fuera de margen (p_TOST=%.4f)\n', r2.p_tost); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 6: TOST pareado concluyo equivalencia cuando NO deberia (p_TOST=%.4f, d=%.3f)\n', r2.p_tost, r2.diferencia_media);
end

% Caso 3: independiente (nX != nY), diferencia chica dentro de margen
x3 = 50 + 0.1 + 1.0*randn(18,1);
y3 = 50 + 1.0*randn(25,1);
r3 = TOST_Core(x3, y3, 2.0, struct('nombre_metrica','ROM_independiente_equivalente'));

n_total = n_total + 1;
if r3.equivalente && ~r3.pareado
    fprintf('[PASS] Test 7: TOST independiente (nX=%d,nY=%d) detecta equivalencia dentro de margen 2.0\n', r3.nX, r3.nY); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 7: TOST independiente no se comporto como se esperaba (equivalente=%d, pareado=%d)\n', r3.equivalente, r3.pareado);
end

% Caso 4: datos identicos (SE=0) - no debe romper, debe concluir
% equivalencia trivial porque d=0 esta dentro de cualquier margen
x4 = ones(10,1)*5;
y4 = ones(10,1)*5;
r4 = TOST_Core(x4, y4, 0.5, struct('nombre_metrica','identico_SE_cero'));

n_total = n_total + 1;
if r4.SE == 0 && r4.equivalente && r4.diferencia_media == 0
    fprintf('[PASS] Test 8: TOST con SE=0 (datos identicos) no revienta y concluye equivalencia trivial\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 8: TOST con SE=0 no se comporto como se esperaba\n');
end

% Test 9: el criterio del IC(1-2*alpha) coincide con la conclusion del
% p_TOST en el caso bien separado (Caso 2, diferencia grande y clara)
n_total = n_total + 1;
if r2.equivalente == r2.equivalente_por_IC
    fprintf('[PASS] Test 9: criterio p_TOST y criterio IC%.0f%% coinciden en el caso bien separado\n', 100*(1-2*r2.alpha)); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 9: criterio p_TOST (%d) y criterio IC (%d) discrepan en un caso que deberia ser inequivoco\n', r2.equivalente, r2.equivalente_por_IC);
end

%% ---- RESUMEN ----
fprintf('\n==================================================================\n');
fprintf('RESULTADO: %d/%d pruebas PASS\n', n_pass, n_total);
fprintf('==================================================================\n');
if n_pass == n_total
    fprintf('Todas las pruebas pasaron. PotenciaApriori_Core.m y TOST_Core.m listos para usar con datos reales.\n');
else
    fprintf('Hay pruebas fallidas - revisar antes de usar con datos reales.\n');
end
