% ===================================================
% PRUEBA AUTOMATIZADA - SPM1D_Core.m y BlandAltman_Core.m
% Datos sinteticos con verdad conocida - mismo patron que
% CODIGOS/CALIBRACION/Test_Calibracion_Offset.m
% ===================================================
%
% No usa ningun dato real del proyecto. Genera curvas y pares
% sinteticos con un efecto conocido de antemano y verifica que ambos
% nucleos lo recuperen dentro de una tolerancia razonable, y que NO
% detecten efecto donde no lo hay (control de falsos positivos).
%
% Ejecutar antes de confiar en los resultados sobre datos reales, y
% de nuevo si se modifica cualquiera de los dos _Core.m.

clear; clc; close all
rng(2026);

n_ok = 0; n_total = 0;
fprintf('==================================================================\n');
fprintf('TEST SPM1D_Core.m + BlandAltman_Core.m - DATOS SINTETICOS\n');
fprintf('==================================================================\n');

%% ---- TEST 1: SPM1D pareado, SIN diferencia real (control falsos positivos) ----
n_total = n_total + 1;
nPuntos = 101; nEnsayos = 8;
eje = linspace(0,100,nPuntos)';
base = 20*sin(pi*eje/100) + 10;   % forma de curva generica, tipo ROM articular

curvasA = repmat(base,1,nEnsayos) + 1.5*randn(nPuntos,nEnsayos);
curvasB = repmat(base,1,nEnsayos) + 1.5*randn(nPuntos,nEnsayos);

r1 = SPM1D_Core(curvasA, curvasB, struct('graficar',false,'nombre_A','SimA','nombre_B','SimB'));

ok1 = r1.pct_ciclo_significativo < 15;   % tolera algo de FWER residual, pero no un tramo grande
fprintf('\n[TEST 1] Sin diferencia real -> %.1f%% del ciclo marcado significativo (esperado: bajo) -> %s\n', ...
        r1.pct_ciclo_significativo, ternary(ok1,'PASS','FAIL'));
n_ok = n_ok + ok1;

%% ---- TEST 2: SPM1D pareado, CON diferencia real en ventana conocida ----
n_total = n_total + 1;
nEnsayos2 = 10;
curvasA2 = repmat(base,1,nEnsayos2) + 1.0*randn(nPuntos,nEnsayos2);
curvasB2 = curvasA2;
ventana_real = eje >= 20 & eje <= 45;
efecto = 6;   % desplazamiento grande y constante dentro de la ventana
curvasB2(ventana_real,:) = curvasB2(ventana_real,:) - efecto;

r2 = SPM1D_Core(curvasA2, curvasB2, struct('graficar',false,'nombre_A','SimA','nombre_B','SimB_conEfecto'));

hay_cluster_en_ventana = false;
for c = 1:numel(r2.clusters)
    solapa = ~(r2.clusters(c).x_fin < 20 || r2.clusters(c).x_ini > 45);
    if solapa, hay_cluster_en_ventana = true; end
end
ok2 = hay_cluster_en_ventana;
fprintf('\n[TEST 2] Diferencia real inyectada en 20-45%% del ciclo -> cluster detectado solapando esa ventana -> %s\n', ...
        ternary(ok2,'PASS','FAIL'));
if ~isempty(r2.clusters)
    for c = 1:numel(r2.clusters)
        fprintf('   cluster detectado: %.1f%%-%.1f%% (p=%.4f)\n', r2.clusters(c).x_ini, r2.clusters(c).x_fin, r2.clusters(c).p_valor);
    end
end
n_ok = n_ok + ok2;

%% ---- TEST 3: SPM1D independiente (grupos distintos, n desiguales) ----
n_total = n_total + 1;
nA3 = 6; nB3 = 9;
curvasA3 = repmat(base,1,nA3) + 1.2*randn(nPuntos,nA3);
curvasB3 = repmat(base,1,nB3) + 1.2*randn(nPuntos,nB3);
ventana_real3 = eje >= 60 & eje <= 80;
curvasB3(ventana_real3,:) = curvasB3(ventana_real3,:) + 7;

r3 = SPM1D_Core(curvasA3, curvasB3, struct('graficar',false,'pareado',false, ...
     'nombre_A','GrupoNuevo','nombre_B','TrayectoriaFija'));

hay_cluster_en_ventana3 = false;
for c = 1:numel(r3.clusters)
    solapa = ~(r3.clusters(c).x_fin < 60 || r3.clusters(c).x_ini > 80);
    if solapa, hay_cluster_en_ventana3 = true; end
end
ok3 = hay_cluster_en_ventana3 && ~r3.pareado;
fprintf('\n[TEST 3] Diseno independiente (nA=%d,nB=%d), efecto en 60-80%% -> detectado y diseno=independiente -> %s\n', ...
        nA3, nB3, ternary(ok3,'PASS','FAIL'));
n_ok = n_ok + ok3;

%% ---- TEST 4: Bland-Altman SIN bias (metodos equivalentes) ----
n_total = n_total + 1;
n4 = 30;
verdad = 80 + 15*rand(n4,1);        % p.ej. picos de Fz %BW simulados
ruido_sd = 2.0;
x4 = verdad + ruido_sd*randn(n4,1);
y4 = verdad + ruido_sd*randn(n4,1);

r4 = BlandAltman_Core(x4, y4, struct('graficar',false,'nombre_A','MetodoA','nombre_B','MetodoB','unidad','%BW'));

ok4 = (r4.CI_bias(1) < 0) && (r4.CI_bias(2) > 0);   % el IC del bias debe cubrir 0
fprintf('\n[TEST 4] Sin bias real -> IC95%% del bias = [%.3f, %.3f] debe cubrir 0 -> %s\n', ...
        r4.CI_bias(1), r4.CI_bias(2), ternary(ok4,'PASS','FAIL'));
n_ok = n_ok + ok4;

%% ---- TEST 5: Bland-Altman CON bias conocido ----
n_total = n_total + 1;
bias_real = 4.5;
x5 = verdad + ruido_sd*randn(n4,1);
y5 = verdad - bias_real + ruido_sd*randn(n4,1);   % B sistematicamente mas bajo

r5 = BlandAltman_Core(x5, y5, struct('graficar',false,'nombre_A','MetodoA','nombre_B','MetodoB','unidad','%BW'));

ok5 = (r5.CI_bias(1) < bias_real) && (r5.CI_bias(2) > bias_real);
fprintf('\n[TEST 5] Bias real inyectado = %.2f -> IC95%% del bias = [%.3f, %.3f] debe cubrirlo -> %s\n', ...
        bias_real, r5.CI_bias(1), r5.CI_bias(2), ternary(ok5,'PASS','FAIL'));
n_ok = n_ok + ok5;

%% ---- TEST 6: Bland-Altman, sesgo proporcional detectable ----
n_total = n_total + 1;
n6 = 40;
media6 = 50 + 40*rand(n6,1);
pendiente_real = 0.25;
dif6 = pendiente_real*media6 + 1.5*randn(n6,1);
x6 = media6 + dif6/2;
y6 = media6 - dif6/2;

r6 = BlandAltman_Core(x6, y6, struct('graficar',false,'nombre_A','MetodoA','nombre_B','MetodoB','unidad','u'));

ok6 = r6.sesgo_proporcional.evaluable && r6.sesgo_proporcional.detectado;
fprintf('\n[TEST 6] Sesgo proporcional real (pendiente=%.2f) -> detectado (p=%.4f) -> %s\n', ...
        pendiente_real, r6.sesgo_proporcional.p, ternary(ok6,'PASS','FAIL'));
n_ok = n_ok + ok6;

%% ---- TEST 7: Extraer_Features0D recupera pico/ROM conocidos ----
n_total = n_total + 1;
eje7 = linspace(0,60,61)';
pico_real = 95; valle_real = 10; x_pico_real = 25;
curva7 = valle_real + (pico_real-valle_real) * exp(-((eje7-x_pico_real)/8).^2);
feats = Extraer_Features0D(curva7, eje7);

ok7 = abs(feats.pico - pico_real) < 0.5 && abs(feats.pico_x - x_pico_real) <= 1 && abs(feats.valle - valle_real) < 1;
fprintf('\n[TEST 7] Pico/valle conocidos -> pico=%.2f (esperado %.0f), x_pico=%.1f (esperado %.0f), valle=%.2f (esperado %.0f) -> %s\n', ...
        feats.pico, pico_real, feats.pico_x, x_pico_real, feats.valle, valle_real, ternary(ok7,'PASS','FAIL'));
n_ok = n_ok + ok7;

%% ---- RESUMEN ----
fprintf('\n==================================================================\n');
fprintf('RESUMEN: %d/%d pruebas PASS\n', n_ok, n_total);
fprintf('==================================================================\n');
if n_ok == n_total
    fprintf('Todo OK: los nucleos recuperan la verdad conocida dentro de tolerancia.\n');
else
    fprintf('ATENCION: revisar la(s) prueba(s) marcada(s) FAIL antes de usar sobre datos reales.\n');
end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end
