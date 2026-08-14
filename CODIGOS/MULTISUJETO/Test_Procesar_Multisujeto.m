% ===================================================
% TEST_PROCESAR_MULTISUJETO
% Prueba automatizada de Procesar_Multisujeto_Core.m con datos
% sinteticos de verdad conocida (mismo patron que
% CODIGOS/CALIBRACION/Test_Calibracion_Offset.m y
% CODIGOS/ESTADISTICA/Test_SPM1D_BlandAltman.m).
%
% Parte A: correccion - verifica que el pipeline recupera un sesgo
%          conocido, maneja correctamente un sujeto sin reprogramar
%          todavia, y detecta un corrimiento de grupo conocido.
% Parte B: escala - genera 20 sujetos sinteticos x 10 ensayos y mide el
%          tiempo de ejecucion, para confirmar HOY (antes de tener datos
%          reales) que el pipeline es rapido a la escala esperada para
%          el articulo (15-20 sujetos).
%
% No valida SPM1D_Core.m ni Extraer_Features0D.m desde cero - eso ya lo
% hace CODIGOS/ESTADISTICA/Test_SPM1D_BlandAltman.m. Esta prueba valida
% que Procesar_Multisujeto_Core.m los conecta correctamente.
% ===================================================

clear; clc;
addpath(fileparts(mfilename('fullpath')));

fprintf('=== Test_Procesar_Multisujeto ===\n\n');
n_pass = 0; n_total = 0;

%% ---- PARTE A: correccion con verdad conocida (4 sujetos sinteticos) ----
rng(2026);
eje_x = linspace(0,60,61)';
base  = 20*sin(pi*eje_x/60) + 5;   % forma tipo angulo de rodilla, magnitud en grados

subj_offset = [0, 3, 4];   % sujeto 1 = misma distribucion que la trayectoria fija; 2 y 3 desplazados
sim_bias    = 2;           % sesgo constante que el simulador agrega, grados - verdad conocida a detectar
noise_sd    = 0.5;
n_trials    = 8;

datosSujetos = struct('id',{}, 'eje_x',{}, 'trials_propios',{}, 'trials_simulador',{});
for s = 1:3
    curva_s = base + subj_offset(s);
    datosSujetos(s).id               = sprintf('Sintetico_%d', s);
    datosSujetos(s).eje_x            = eje_x;
    datosSujetos(s).trials_propios   = curva_s + noise_sd*randn(numel(eje_x), n_trials);
    datosSujetos(s).trials_simulador = curva_s + sim_bias + noise_sd*randn(numel(eje_x), n_trials);
end

% Cuarto sujeto: todavia no se reprogramo el simulador con su CSV.
datosSujetos(4).id               = 'Sintetico_4_sin_reprogramar';
datosSujetos(4).eje_x            = eje_x;
datosSujetos(4).trials_propios   = base + subj_offset(1) + noise_sd*randn(numel(eje_x), n_trials);
datosSujetos(4).trials_simulador = [];

trayectoria_fija = base + subj_offset(1) + noise_sd*randn(numel(eje_x), n_trials);

opciones = struct('graficar', false, 'guardar_en', '', 'n_perm', 2000);
resultado = Procesar_Multisujeto_Core(datosSujetos, trayectoria_fija, opciones);

% Test 1: tabla con una fila por sujeto
n_total = n_total + 1;
if height(resultado.por_sujeto) == 4
    fprintf('[PASS] Test 1: tabla_resumen tiene 4 filas (una por sujeto)\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 1: tabla_resumen tiene %d filas, se esperaban 4\n', height(resultado.por_sujeto));
end

% Test 2: sujeto sin reprogramar queda marcado con NaN, sin romper el pipeline
n_total = n_total + 1;
fila4 = resultado.por_sujeto(4,:);
if isnan(fila4.RMSEnorm) && isnan(fila4.ICC) && strcmp(fila4.Clasificacion{1}, 'Sin reprogramar aun')
    fprintf('[PASS] Test 2: sujeto sin reprogramar queda NaN/marcado, sin error\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 2: sujeto sin reprogramar no quedo como se esperaba\n');
end

% Test 3: SPM1D por sujeto detecta el sesgo constante de +2 grados (sujetos 1-3)
n_total = n_total + 1;
pct_signif = resultado.por_sujeto.SPM_pct_ciclo_signif(1:3);
if all(pct_signif > 70)
    fprintf('[PASS] Test 3: SPM1D por sujeto detecta el sesgo de %.1f grados (%.0f%%-%.0f%% del ciclo)\n', ...
        sim_bias, min(pct_signif), max(pct_signif)); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 3: SPM1D por sujeto no detecto el sesgo esperado (%.1f%%-%.1f%% del ciclo)\n', ...
        min(pct_signif), max(pct_signif));
end

% Test 4: ICC(3,1) alto para los sujetos con datos (ruido bajo frente a la forma de la curva)
n_total = n_total + 1;
icc_vals = resultado.por_sujeto.ICC(1:3);
if all(icc_vals > 0.9)
    fprintf('[PASS] Test 4: ICC(3,1) > 0.9 en los 3 sujetos con datos\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 4: ICC(3,1) por debajo de 0.9 en algun sujeto: %s\n', mat2str(icc_vals', 3));
end

% Test 5: Comparacion 4 (independiente) detecta el corrimiento del grupo
n_total = n_total + 1;
if resultado.spm_comparacion4.pct_ciclo_significativo > 30
    fprintf('[PASS] Test 5: Comparacion 4 detecta el corrimiento del grupo (%.1f%% del ciclo)\n', ...
        resultado.spm_comparacion4.pct_ciclo_significativo); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 5: Comparacion 4 no detecto el corrimiento esperado (%.1f%% del ciclo)\n', ...
        resultado.spm_comparacion4.pct_ciclo_significativo);
end

% Test 6: variabilidad de grupo calculada sobre los 4 sujetos, magnitud razonable
n_total = n_total + 1;
if resultado.variabilidad_grupo.n_sujetos == 4 && resultado.variabilidad_grupo.ROM_media > 0
    fprintf('[PASS] Test 6: variabilidad_grupo sobre 4 sujetos, ROM medio = %.2f grados\n', ...
        resultado.variabilidad_grupo.ROM_media); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 6: variabilidad_grupo con valores inesperados\n');
end

%% ---- PARTE B: prueba de escala (20 sujetos sinteticos x 10 ensayos) ----
fprintf('\n--- Prueba de escala: 20 sujetos sinteticos x 10 ensayos ---\n');
rng(2026);
n_trials20 = 10;

datosSujetos20 = struct('id',{}, 'eje_x',{}, 'trials_propios',{}, 'trials_simulador',{});
for s = 1:20
    curva_s = base + 2*randn(1);   % variacion natural pequena entre sujetos sinteticos
    datosSujetos20(s).id               = sprintf('S%02d', s);
    datosSujetos20(s).eje_x            = eje_x;
    datosSujetos20(s).trials_propios   = curva_s + noise_sd*randn(numel(eje_x), n_trials20);
    datosSujetos20(s).trials_simulador = curva_s + sim_bias + noise_sd*randn(numel(eje_x), n_trials20);
end
trayectoria_fija20 = base + noise_sd*randn(numel(eje_x), n_trials20);

opciones20 = struct('graficar', false, 'guardar_en', '');
t_ini = tic;
resultado20 = Procesar_Multisujeto_Core(datosSujetos20, trayectoria_fija20, opciones20);
t_total = toc(t_ini);

n_total = n_total + 1;
UMBRAL_SEG = 60;
if t_total < UMBRAL_SEG
    fprintf('[PASS] Test 7: 20 sujetos x 10 ensayos procesados en %.2f s (umbral %d s)\n', t_total, UMBRAL_SEG);
    n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 7: 20 sujetos x 10 ensayos tardo %.2f s, por encima del umbral de %d s\n', t_total, UMBRAL_SEG);
end
fprintf('Tiempo reportado internamente por el propio Core: %.2f s\n', resultado20.tiempo_ejecucion_seg);

%% ---- RESUMEN ----
fprintf('\n==================================================================\n');
fprintf('RESULTADO: %d/%d pruebas PASS\n', n_pass, n_total);
fprintf('==================================================================\n');
