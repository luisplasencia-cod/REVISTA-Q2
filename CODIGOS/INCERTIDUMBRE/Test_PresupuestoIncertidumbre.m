% ===================================================
% TEST_PRESUPUESTOINCERTIDUMBRE
% Prueba automatizada de PresupuestoIncertidumbre_Core.m con casos de
% verdad conocida (mismo patron que
% CODIGOS/CALIBRACION/Test_Calibracion_Offset.m,
% CODIGOS/ESTADISTICA/Test_SPM1D_BlandAltman.m,
% CODIGOS/MULTISUJETO/Test_Procesar_Multisujeto.m y
% CODIGOS/POTENCIA_EQUIVALENCIA/Test_PotenciaApriori_TOST.m).
%
% Verifica: (1) combinacion RSS de dos componentes iguales con gl=Inf
% recupera u_c = valor*sqrt(2) y k=1.96 (limite normal exacto, no la
% aproximacion k=2); (2) un solo componente reproduce u_c=valor y U=k*valor
% exactamente; (3) gl efectivos con un componente dominante y uno
% pequeno tiende al gl del dominante (propiedad conocida de
% Welch-Satterthwaite); (4) contribucion_pct suma 100% y el componente
% mas grande domina; (5) gl finitos (tipo A, muestra chica) dan k > 1.96
% (la incertidumbre expandida es mas ancha que el limite normal, como
% debe ser con pocos grados de libertad); (6) error controlado si falta
% un campo obligatorio; (7) caso de uso real del proyecto: RMSD de
% Piche 2022 (Tipo B, literatura) + residuo de calibracion de offset
% (Tipo A, sintetico) -> u_c y U con orden de magnitud razonable.
% ===================================================

clear; clc;
addpath(fileparts(mfilename('fullpath')));

fprintf('=== Test_PresupuestoIncertidumbre ===\n\n');
n_pass = 0; n_total = 0;

%% Test 1: dos componentes iguales, gl=Inf -> u_c = valor*sqrt(2), k=1.96
c1 = struct('nombre','A','tipo','B','valor',2.0,'gl',Inf,'fuente','sintetico');
c2 = struct('nombre','B','tipo','B','valor',2.0,'gl',Inf,'fuente','sintetico');
r1 = PresupuestoIncertidumbre_Core([c1 c2], struct('nombre_magnitud','test1','unidad',' deg'));

n_total = n_total + 1;
u_c_esperado = 2.0*sqrt(2);
if abs(r1.u_c - u_c_esperado) < 1e-9
    fprintf('[PASS] Test 1a: u_c = %.6f coincide con sqrt(2)*2.0 = %.6f\n', r1.u_c, u_c_esperado); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 1a: u_c = %.6f, esperado %.6f\n', r1.u_c, u_c_esperado);
end

n_total = n_total + 1;
if abs(r1.k - 1.959963985) < 1e-4
    fprintf('[PASS] Test 1b: k = %.6f coincide con el limite normal exacto 1.959964 (gl_eff=Inf)\n', r1.k); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 1b: k = %.6f, esperado ~1.959964\n', r1.k);
end

%% Test 2: un solo componente -> u_c y U exactos
c3 = struct('nombre','Unico','tipo','B','valor',3.3,'gl',Inf,'fuente','Piche2022 (sintetico para test)');
r2 = PresupuestoIncertidumbre_Core(c3, struct('nombre_magnitud','test2','unidad',' deg'));

n_total = n_total + 1;
if abs(r2.u_c - 3.3) < 1e-9 && abs(r2.U - 1.959963985*3.3) < 1e-4
    fprintf('[PASS] Test 2: componente unico reproduce u_c=%.4f y U=%.4f exactamente\n', r2.u_c, r2.U); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 2: u_c=%.4f (esperado 3.3) o U=%.4f (esperado %.4f)\n', r2.u_c, r2.U, 1.959963985*3.3);
end

%% Test 3: gl efectivos con un componente dominante (gl chico) y uno
%  pequeno (gl grande) tienden al gl del dominante
c_dom = struct('nombre','Dominante','tipo','A','valor',5.0,'gl',9,'fuente','sintetico, n=10');
c_chico = struct('nombre','Chico','tipo','B','valor',0.1,'gl',Inf,'fuente','sintetico');
r3 = PresupuestoIncertidumbre_Core([c_dom c_chico], struct('nombre_magnitud','test3','unidad',' deg'));

n_total = n_total + 1;
if abs(r3.gl_eff - 9) < 0.5
    fprintf('[PASS] Test 3: gl_eff = %.2f tiende al gl=9 del componente dominante, como predice Welch-Satterthwaite\n', r3.gl_eff); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 3: gl_eff = %.2f, esperado cerca de 9\n', r3.gl_eff);
end

%% Test 4: contribucion_pct suma 100% y el componente mas grande domina
n_total = n_total + 1;
suma_pct = sum(r3.contribucion_pct);
if abs(suma_pct - 100) < 1e-6 && r3.contribucion_pct(1) > r3.contribucion_pct(2)
    fprintf('[PASS] Test 4: contribucion_pct suma %.4f%% y el componente Dominante (%.2f%%) supera a Chico (%.2f%%)\n', ...
        suma_pct, r3.contribucion_pct(1), r3.contribucion_pct(2)); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 4: suma_pct=%.4f (esperado 100) o el orden de contribucion no es el esperado\n', suma_pct);
end

%% Test 5: gl finitos chicos dan k > 1.96 (mas ancho que el limite normal)
c_pocas_muestras = struct('nombre','Repetibilidad n=6','tipo','A','valor',1.5,'gl',5,'fuente','sintetico, n=6');
r5 = PresupuestoIncertidumbre_Core(c_pocas_muestras, struct('nombre_magnitud','test5','unidad',' deg'));

n_total = n_total + 1;
if r5.k > 1.96
    fprintf('[PASS] Test 5: con gl=5 (muestra chica), k=%.4f > 1.96 (limite normal) - la incertidumbre expandida es correctamente mas conservadora\n', r5.k); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 5: con gl=5, k=%.4f deberia ser mayor que 1.96\n', r5.k);
end

%% Test 6: error controlado si falta un campo obligatorio
n_total = n_total + 1;
c_incompleto = struct('nombre','Incompleto','tipo','A','valor',1.0);  % falta .gl
fallo_esperado = false;
try
    PresupuestoIncertidumbre_Core(c_incompleto);
catch err
    fallo_esperado = contains(err.message, 'nombre, tipo, valor, gl');
end
if fallo_esperado
    fprintf('[PASS] Test 6: componente sin .gl produce un error controlado y explicito\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 6: no se detecto el error esperado por campo faltante\n');
end

%% Test 7: caso de uso real del proyecto - RMSD de Piche 2022 (Tipo B,
%  literatura, rodilla=3.3 deg) + residuo de calibracion de offset
%  (Tipo A, sintetico, imitando la salida de Calibracion_Offset_Core.m)
%  + repetibilidad ensayo-a-ensayo (Tipo A)
c_instrumento = struct('nombre','Validacion iSen vs. optoelectronico (rodilla)', ...
    'tipo','B', 'valor', 3.3, 'gl', 21, ...
    'fuente','Piche et al. 2022, Measurement, n=22 sujetos sanos');
c_offset = struct('nombre','Residuo de calibracion de offset vertical', ...
    'tipo','A', 'valor', 0.8, 'gl', 7, ...
    'fuente','Calibracion_Offset_Core.m (sintetico, placeholder hasta datos reales)');
c_repetibilidad = struct('nombre','Repetibilidad ensayo-a-ensayo', ...
    'tipo','A', 'valor', 0.5, 'gl', 9, ...
    'fuente','sd_trial (sintetico, placeholder hasta datos reales)');

r7 = PresupuestoIncertidumbre_Core([c_instrumento c_offset c_repetibilidad], ...
    struct('nombre_magnitud','Angulo de plataforma (ejemplo de uso real)', 'unidad',' deg'));

n_total = n_total + 1;
u_c_manual = sqrt(3.3^2 + 0.8^2 + 0.5^2);
if abs(r7.u_c - u_c_manual) < 1e-9 && r7.contribucion_pct(1) > 90
    fprintf('[PASS] Test 7: caso de uso real da u_c=%.4f deg (dominado por el instrumento, %.1f%% de u_c^2), consistente con que la validacion del instrumento es la fuente mayor\n', ...
        r7.u_c, r7.contribucion_pct(1)); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 7: u_c=%.4f (esperado %.4f) o contribucion del instrumento %.1f%% (esperado >90%%)\n', ...
        r7.u_c, u_c_manual, r7.contribucion_pct(1));
end

%% ---- RESUMEN ----
fprintf('\n==================================================================\n');
fprintf('RESULTADO: %d/%d pruebas PASS\n', n_pass, n_total);
fprintf('==================================================================\n');
if n_pass == n_total
    fprintf('Todas las pruebas pasaron. PresupuestoIncertidumbre_Core.m listo para usar con datos reales.\n');
else
    fprintf('Hay pruebas fallidas - revisar antes de usar con datos reales.\n');
end
