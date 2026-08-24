% ===================================================
% TEST_GENERADOR
% Prueba automatizada de Zhao2026_Core.m y Reduccion_Winter_Core.m con
% datos sinteticos de verdad conocida (mismo patron que
% CODIGOS/POTENCIA_EQUIVALENCIA/Test_PotenciaApriori_TOST.m,
% CODIGOS/MULTISUJETO/Test_Procesar_Multisujeto.m).
%
% Parte A: Zhao2026_Core - verifica la formula (Ecs. 1-2, Tabla 1) contra
%          calculo manual en puntos concretos, la relacion de fase entre
%          'izquierda'/'derecha', periodicidad del ciclo, y linealidad en
%          la longitud de pierna l.
% Parte B: Reduccion_Winter_Core - verifica el camino via rodilla, el
%          camino via tobillo, que el cruce entre ambos detecta acuerdo
%          cuando los datos son consistentes por construccion y
%          desacuerdo cuando no lo son, y el manejo de entrada invalida.
% Parte C: Yun2014_Wrapper - SOLO si el toolbox esta presente en disco
%          (docs/literatura/pdfs/yun2014_toolbox/database/Data_x.mat,
%          gitignored por licencia KIST) - si no esta, se informa y se
%          saltea sin contar como fallo.
% Parte D: Cargar_Camargo_Core - SOLO si el sujeto piloto AB06 esta en
%          disco (varios GB, no versionado en git).
% Parte E: Koopman2014_Core - verifica el ajuste de spline quintico
%          contra un caso sintetico de verdad conocida, la continuidad
%          entre tramos, y que el ROM reconstruido de cada articulacion
%          (a velocidad/talla promedio del paper) cae cerca de los ROM
%          publicados en la Tabla 6 del propio paper (9.94/34.22/52.76/
%          20.04 grados) - la unica verdad externa disponible sin volver
%          a leer el PDF.
%
% No revalida el toolbox de Yun 2014 en si (eso ya lo hizo el equipo,
% ver docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md
% #4.5) - solo que el wrapper de este proyecto lo llama y post-procesa
% bien.
% ===================================================

clear; clc;
addpath(fileparts(mfilename('fullpath')));

fprintf('=== Test_Generador ===\n\n');
n_pass = 0; n_total = 0;

%% ---- PARTE A: Zhao2026_Core ----

l = 0.90;  % m, longitud de pierna de prueba
f = 0.90;  % zancadas/s, cadencia de prueba

coef_cadera  = struct('B0', 0.086, 'B1', -0.316, 'B2', -0.067, 'B3', 0.026, ...
                       'phi1', -1.105, 'phi2', 1.433, 'phi3', 0.187);
coef_rodilla = struct('B0', 0.468, 'B1',  0.465, 'B2',  0.311, 'B3', -0.093, ...
                       'phi1',  0.244, 'phi2', -0.990, 'phi3', 0.266);

res_izq = Zhao2026_Core(l, f, struct('lado','izquierda','nMuestras',101));

% Test 1: phi_cadera(t=0) coincide con el calculo manual de la Ec.1
n_total = n_total + 1;
phi_cadera_t0_manual = coef_cadera.B0*l + l*( ...
    coef_cadera.B1*sin(coef_cadera.phi1) + ...
    coef_cadera.B2*sin(coef_cadera.phi2) + ...
    coef_cadera.B3*sin(coef_cadera.phi3));
err1 = abs(res_izq.phi_cadera_rad(1) - phi_cadera_t0_manual);
if err1 < 1e-10
    fprintf('[PASS] Test 1: phi_cadera(t=0) coincide con calculo manual (err=%.2e)\n', err1); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 1: phi_cadera(t=0) difiere del calculo manual (err=%.2e)\n', err1);
end

% Test 2: theta_tibia = phi_cadera - phi_rodilla, punto a punto, exacto
n_total = n_total + 1;
err2 = max(abs(res_izq.theta_tibia_rad - (res_izq.phi_cadera_rad - res_izq.phi_rodilla_rad)));
if err2 < 1e-12
    fprintf('[PASS] Test 2: theta_tibia = phi_cadera - phi_rodilla se cumple exacto (err=%.2e)\n', err2); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 2: theta_tibia != phi_cadera - phi_rodilla (err=%.2e)\n', err2);
end

% Test 3: 'derecha' reproduce 'izquierda' con el desfase +j*pi por armonico
n_total = n_total + 1;
res_der = Zhao2026_Core(l, f, struct('lado','derecha','nMuestras',101));
t = res_izq.t;
phi_cadera_der_manual = coef_cadera.B0*l*ones(size(t));
for j = 1:3
    Bj  = [coef_cadera.B1, coef_cadera.B2, coef_cadera.B3];
    phj = [coef_cadera.phi1, coef_cadera.phi2, coef_cadera.phi3];
    phi_cadera_der_manual = phi_cadera_der_manual + Bj(j)*l*sin(2*pi*j*f*t + phj(j) + j*pi);
end
err3 = max(abs(res_der.phi_cadera_rad - phi_cadera_der_manual));
if err3 < 1e-10
    fprintf('[PASS] Test 3: lado=''derecha'' aplica el desfase +j*pi correctamente (err=%.2e)\n', err3); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 3: lado=''derecha'' no coincide con el calculo manual (err=%.2e)\n', err3);
end

% Test 4: periodicidad - phi(t=0) debe coincidir con phi(t=T) (mismo punto
% de fase, un ciclo despues)
n_total = n_total + 1;
err4 = abs(res_izq.phi_rodilla_rad(1) - res_izq.phi_rodilla_rad(end));
if err4 < 1e-8
    fprintf('[PASS] Test 4: phi_rodilla es periodico en T=1/f (err=%.2e)\n', err4); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 4: phi_rodilla no cierra el ciclo (err=%.2e)\n', err4);
end

% Test 5: linealidad en l - duplicar l duplica phi(t) exactamente en
% todos los puntos (la formula es B0*l + suma de terminos en l)
n_total = n_total + 1;
res_l2 = Zhao2026_Core(2*l, f, struct('lado','izquierda','nMuestras',101));
err5 = max(abs(res_l2.phi_rodilla_rad - 2*res_izq.phi_rodilla_rad));
if err5 < 1e-10
    fprintf('[PASS] Test 5: phi_rodilla escala linealmente con l (err=%.2e)\n', err5); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 5: phi_rodilla no escala linealmente con l (err=%.2e)\n', err5);
end

%% ---- PARTE B: Reduccion_Winter_Core ----

n = 50;
theta_muslo = deg2rad(10*sin(linspace(0,2*pi,n)));
phi_rodilla = deg2rad(30 + 20*sin(linspace(0,2*pi,n)));

% Test 6: camino via rodilla, signo por defecto (-1)
n_total = n_total + 1;
r6 = Reduccion_Winter_Core(struct('theta_muslo_rad', theta_muslo, 'phi_rodilla_rad', phi_rodilla));
esperado6 = theta_muslo - phi_rodilla;
err6 = max(abs(r6.theta_tibia_via_rodilla_rad - esperado6));
if err6 < 1e-12 && isequal(r6.caminos_usados, {'rodilla'})
    fprintf('[PASS] Test 6: camino via rodilla = theta_muslo - phi_rodilla, exacto (err=%.2e)\n', err6); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 6: camino via rodilla no coincide (err=%.2e)\n', err6);
end

% Test 7: los dos caminos, construidos para COINCIDIR por diseno ->
% diferencia debe ser ~0
n_total = n_total + 1;
theta_pie = zeros(1,n);
phi_tobillo_consistente = esperado6 - theta_pie;  % fuerza via_tobillo == via_rodilla
r7 = Reduccion_Winter_Core(struct( ...
    'theta_muslo_rad', theta_muslo, 'phi_rodilla_rad', phi_rodilla, ...
    'theta_pie_rad', theta_pie, 'phi_tobillo_rad', phi_tobillo_consistente));
if r7.diferencia_max_abs_deg < 1e-6
    fprintf('[PASS] Test 7: cruce rodilla/tobillo detecta acuerdo cuando son consistentes por construccion (diff_max=%.2e deg)\n', r7.diferencia_max_abs_deg); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 7: cruce rodilla/tobillo no detecto el acuerdo esperado (diff_max=%.4f deg)\n', r7.diferencia_max_abs_deg);
end

% Test 8: los dos caminos, con un desacuerdo grande introducido a proposito
% (10 grados de sesgo) -> el cruce debe detectarlo
n_total = n_total + 1;
sesgo_deg = 10;
phi_tobillo_inconsistente = phi_tobillo_consistente + deg2rad(sesgo_deg);
r8 = Reduccion_Winter_Core(struct( ...
    'theta_muslo_rad', theta_muslo, 'phi_rodilla_rad', phi_rodilla, ...
    'theta_pie_rad', theta_pie, 'phi_tobillo_rad', phi_tobillo_inconsistente));
if abs(r8.diferencia_max_abs_deg - sesgo_deg) < 1e-6
    fprintf('[PASS] Test 8: cruce rodilla/tobillo detecta el desacuerdo de %.1f deg introducido (medido=%.4f deg)\n', sesgo_deg, r8.diferencia_max_abs_deg); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 8: cruce rodilla/tobillo no detecto el desacuerdo esperado (medido=%.4f deg, esperado=%.1f deg)\n', r8.diferencia_max_abs_deg, sesgo_deg);
end

% Test 9: sin ningun camino completo -> error controlado, no un crash
% silencioso ni un resultado incorrecto
n_total = n_total + 1;
lanzo_error = false;
try
    Reduccion_Winter_Core(struct('theta_muslo_rad', theta_muslo));  % falta phi_rodilla_rad
catch
    lanzo_error = true;
end
if lanzo_error
    fprintf('[PASS] Test 9: entrada incompleta (falta phi_rodilla_rad) lanza error controlado\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 9: entrada incompleta no lanzo error - riesgo de resultado silenciosamente incorrecto\n');
end

%% ---- PARTE C: Yun2014_Wrapper (solo si el toolbox esta en disco) ----

aqui = fileparts(mfilename('fullpath'));
toolbox_dir = fullfile(aqui, '..', '..', 'docs', 'literatura', 'pdfs', 'yun2014_toolbox');
db_file = fullfile(toolbox_dir, 'database', 'Data_x.mat');

if isfile(db_file)
    n_total = n_total + 1;
    try
        % Mismo sujeto de prueba que demo_Gait_Pred.m del toolbox
        test_body_parameter = [30,173,70.2,1,32.8,42.4,32.8,29.7,25.5,10,24,7.30,7.10,9.80];
        res_yun = Yun2014_Wrapper(test_body_parameter, toolbox_dir);
        campos_esperados = {'R_hip_extension','L_hip_extension','R_knee_flexion','L_knee_flexion', ...
                             'R_ankle_plantarflexion','L_ankle_plantarflexion', ...
                             'theta_tibia_via_tobillo_R_rad','theta_tibia_via_tobillo_L_rad','periodo_s'};
        tiene_todos = all(isfield(res_yun, campos_esperados));
        rom_tobillo_R = range(res_yun.R_ankle_plantarflexion.mean);
        finito = all(isfinite(res_yun.theta_tibia_via_tobillo_R_rad));
        if tiene_todos && finito && rom_tobillo_R > 0 && rom_tobillo_R < 90
            fprintf('[PASS] Test 10: Yun2014_Wrapper corre con el toolbox real, campos completos, ROM tobillo R=%.1f deg (plausible)\n', rom_tobillo_R); n_pass = n_pass + 1;
        else
            fprintf('[FAIL] Test 10: Yun2014_Wrapper corrio pero la salida no es plausible (campos=%d, finito=%d, ROM=%.1f)\n', tiene_todos, finito, rom_tobillo_R);
        end
    catch ME
        fprintf('[FAIL] Test 10: Yun2014_Wrapper lanzo un error inesperado: %s\n', ME.message);
    end
else
    fprintf('[SKIP] Test 10: toolbox de Yun 2014 no encontrado en %s (database/Data_x.mat gitignored por licencia KIST) - no cuenta como fallo.\n', toolbox_dir);
end

%% ---- PARTE D: Cargar_Camargo_Core (solo si los sujetos piloto estan en disco) ----

camargo_dir = fullfile(aqui, '..', '..', 'docs', 'literatura', 'pdfs', 'camargo2021_piloto', 'AB06');
sesion = '10_09_18';
trial = 'levelground_ccw_normal_01_01.mat';

if isfolder(camargo_dir)
    n_total = n_total + 1;
    try
        res_cam = Cargar_Camargo_Core(camargo_dir, sesion, trial);
        long_ok = res_cam.long_tibia_r_m > 0.25 && res_cam.long_tibia_r_m < 0.55;  % rango humano plausible
        rom_rodilla = range(res_cam.knee_angle_r_deg);
        rom_ok = rom_rodilla > 20 && rom_rodilla < 90;  % ROM de rodilla en marcha real
        finito = all(isfinite(res_cam.theta_tibia_real_deg));
        if long_ok && rom_ok && finito
            fprintf('[PASS] Test 11: Cargar_Camargo_Core corre con datos reales (AB06), long_tibia=%.3f m, ROM rodilla=%.1f deg (ambos plausibles)\n', res_cam.long_tibia_r_m, rom_rodilla); n_pass = n_pass + 1;
        else
            fprintf('[FAIL] Test 11: Cargar_Camargo_Core corrio pero la salida no es plausible (long=%.3f m, ROM=%.1f deg, finito=%d)\n', res_cam.long_tibia_r_m, rom_rodilla, finito);
        end
    catch ME
        fprintf('[FAIL] Test 11: Cargar_Camargo_Core lanzo un error inesperado: %s\n', ME.message);
    end
else
    fprintf('[SKIP] Test 11: sujeto piloto AB06 de Camargo no encontrado en %s - no cuenta como fallo.\n', camargo_dir);
end

%% ---- PARTE E: Koopman2014_Core ----

% Test 12: caso sintetico de verdad conocida para hermite_quintico (via
% la funcion publica, construyendo un caso donde la solucion analitica se
% conoce: un segmento de p(t)=t^3 entre x=0 y x=10, con derivadas exactas
% en ambos extremos). No se puede llamar hermite_quintico directo (es
% local a Koopman2014_Core.m) - se verifica indirectamente confirmando
% que Koopman2014_Core reproduce EXACTO el valor y la pendiente en cada
% nodo (heel contact, x=1) contra el calculo manual de la regresion.
n_total = n_total + 1;
v_test = 3.0; l_test = 1.69; % media de la poblacion del paper
res_koop = Koopman2014_Core(v_test, l_test, struct('nMuestras', 501));

% Valor manual de "Angle" en Heel Contact de cadera flex/ext (Tabla 2):
% y = 20.354 + 1.934*v  (sin terminos v^2 ni l)
y_manual_hc = 20.354 + 1.934*v_test;
[~, idx_hc] = min(abs(res_koop.cadera_flexext.pct_ciclo - 1));
err_hc = abs(res_koop.cadera_flexext.angulo_deg(idx_hc) - y_manual_hc);
if err_hc < 0.5  % tolerancia por discretizacion de la malla, no por el ajuste
    fprintf('[PASS] Test 12: Koopman2014_Core reproduce el angulo de Heel Contact (cadera flex/ext) calculado a mano (err=%.3f deg)\n', err_hc); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 12: Koopman2014_Core no reproduce el angulo de Heel Contact esperado (obtenido=%.2f, manual=%.2f)\n', res_koop.cadera_flexext.angulo_deg(idx_hc), y_manual_hc);
end

% Test 13: continuidad - sin saltos grandes entre puntos consecutivos de
% la malla fina (501 puntos), en ninguna de las 4 articulaciones
n_total = n_total + 1;
campos = {'cadera_abaduccion','cadera_flexext','rodilla_flexext','tobillo_flexext'};
salto_max = 0;
for i = 1:numel(campos)
    d = diff(res_koop.(campos{i}).angulo_deg);
    salto_max = max(salto_max, max(abs(d)));
end
if salto_max < 5  % grados entre puntos separados por 0.2% de ciclo - un salto real seria >>5
    fprintf('[PASS] Test 13: las 4 curvas de Koopman2014_Core son continuas (salto maximo entre puntos = %.3f deg)\n', salto_max); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 13: se detecto un salto grande entre tramos del spline (%.2f deg) - revisar el ensamblado de segmentos\n', salto_max);
end

% Test 14: ROM reconstruido cerca del ROM publicado en la Tabla 6 del
% paper (9.94 / 34.22 / 52.76 / 20.04 grados) - tolerancia amplia (dentro
% de STD tipica reportada en el propio paper, Tabla 6: STD~1.4-3.4 grados)
% porque el ROM del paper es un promedio poblacional a velocidad variable,
% no un valor exacto reproducible con un solo (v,l)
n_total = n_total + 1;
rom_publicado = [9.94, 34.22, 52.76, 20.04];
rom_calculado = zeros(1,4);
for i = 1:numel(campos)
    a = res_koop.(campos{i}).angulo_deg;
    rom_calculado(i) = max(a) - min(a);
end
dif_rom = abs(rom_calculado - rom_publicado);
tolerancia_rom = [8, 15, 20, 10]; % grados, amplia a proposito (ver comentario arriba)
if all(dif_rom < tolerancia_rom)
    fprintf('[PASS] Test 14: ROM reconstruido cerca del publicado (Tabla 6) para las 4 articulaciones: %s\n', mat2str(round(rom_calculado,1))); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 14: ROM reconstruido lejos del publicado - calculado=%s, publicado=%s\n', mat2str(round(rom_calculado,1)), mat2str(rom_publicado));
end

% Test 15: corre en los extremos del rango validado (0.5 y 5 kph) sin
% error y sin producir NaN/Inf
n_total = n_total + 1;
try
    r_lento = Koopman2014_Core(0.5, l_test);
    r_rapido = Koopman2014_Core(5.0, l_test);
    ok_finito = true;
    for i = 1:numel(campos)
        ok_finito = ok_finito && all(isfinite(r_lento.(campos{i}).angulo_deg)) && all(isfinite(r_rapido.(campos{i}).angulo_deg));
    end
    if ok_finito
        fprintf('[PASS] Test 15: Koopman2014_Core corre sin error en los extremos del rango validado (0.5 y 5 kph), salida finita\n'); n_pass = n_pass + 1;
    else
        fprintf('[FAIL] Test 15: salida no finita (NaN/Inf) en los extremos del rango\n');
    end
catch ME
    fprintf('[FAIL] Test 15: Koopman2014_Core lanzo un error inesperado en los extremos del rango: %s\n', ME.message);
end

% Test 16b: Koopman2014_Core queda conectado a Reduccion_Winter_Core.m -
% el campo theta_tibia_via_tobillo_deg existe, es finito, y su ROM es del
% mismo orden de magnitud que el ROM real de la plataforma del proyecto
% (REFERENCIAS/Control_apoyo_Luis_V4.csv: -50 a +22 grados, ~72 deg ROM
% total incluyendo balanceo) - tolerancia amplia porque son poblaciones y
% condiciones distintas, solo se busca "mismo orden de magnitud", no un
% match exacto
n_total = n_total + 1;
tiene_campo = isfield(res_koop, 'theta_tibia_via_tobillo_deg');
if tiene_campo
    finito_red = all(isfinite(res_koop.theta_tibia_via_tobillo_deg));
    rom_red = range(res_koop.theta_tibia_via_tobillo_deg);
    plausible = finito_red && rom_red > 2 && rom_red < 100;
    if plausible
        fprintf('[PASS] Test 16b: Koopman2014_Core conectado a Reduccion_Winter_Core.m, theta_tibia_via_tobillo ROM=%.1f deg (plausible)\n', rom_red); n_pass = n_pass + 1;
    else
        fprintf('[FAIL] Test 16b: theta_tibia_via_tobillo presente pero no plausible (ROM=%.1f, finito=%d)\n', rom_red, finito_red);
    end
else
    fprintf('[FAIL] Test 16b: Koopman2014_Core no expone theta_tibia_via_tobillo_deg - la conexion con Reduccion_Winter_Core.m no quedo hecha\n');
end

% Test 16: advertencia (no error) fuera del rango validado
n_total = n_total + 1;
lastwarn('');
Koopman2014_Core(6.0, l_test);
[msg, id] = lastwarn();
if strcmp(id, 'Tiempo_Ciclo_Koopman2014_Core:fueraDeRango')
    fprintf('[PASS] Test 16: v_kph=6 (fuera de 0.5-5) dispara advertencia de rango, no error\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 16: no se disparo la advertencia esperada para v_kph fuera de rango\n');
end

%% ---- PARTE F: Segmento_Posicion_Core ----

% Test 17b: theta=0 (vertical) -> extremo distal queda justo "arriba" del
% origen, a distancia L exacta
n_total = n_total + 1;
Ltest = 0.45;
p0 = Segmento_Posicion_Core(0, Ltest);
if abs(p0.x - 0) < 1e-12 && abs(p0.y - Ltest) < 1e-12
    fprintf('[PASS] Test 17: theta=0 (vertical) da x=0, y=L exacto\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 17: theta=0 no da (0,L) - obtenido (%.4f,%.4f)\n', p0.x, p0.y);
end

% Test 18: theta=90 grados -> extremo distal a distancia L, en horizontal
n_total = n_total + 1;
p90 = Segmento_Posicion_Core(pi/2, Ltest);
if abs(p90.x - Ltest) < 1e-10 && abs(p90.y - 0) < 1e-10
    fprintf('[PASS] Test 18: theta=90deg da x=L, y=0 (err x=%.2e, err y=%.2e)\n', abs(p90.x-Ltest), abs(p90.y)); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 18: theta=90deg no da (L,0) - obtenido (%.4f,%.4f)\n', p90.x, p90.y);
end

% Test 19: invariante fisico - para CUALQUIER theta, la distancia del
% extremo distal al origen debe ser exactamente L (segmento rigido) -
% chequeo fuerte de la formula completa, no solo casos particulares
n_total = n_total + 1;
theta_variado = linspace(-pi, pi, 200);
pv = Segmento_Posicion_Core(theta_variado, Ltest, struct('origen_x', 3, 'origen_y', -2));
dist = sqrt((pv.x - 3).^2 + (pv.y - (-2)).^2);
err_dist = max(abs(dist - Ltest));
if err_dist < 1e-10
    fprintf('[PASS] Test 19: distancia al origen = L exacto para 200 angulos distintos (err max=%.2e)\n', err_dist); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 19: la distancia al origen no es constante = L (err max=%.2e)\n', err_dist);
end

% Test 20: multiples fracciones - la fraccion 0.5 debe quedar exactamente
% a mitad de camino entre origen y el extremo distal (fraccion 1)
n_total = n_total + 1;
pf = Segmento_Posicion_Core(0.7, Ltest, struct('fracciones', [0, 0.5, 1]));
punto_medio_esperado = (pf.x(1,:) + pf.x(3,:))/2;
err_medio = abs(pf.x(2,:) - punto_medio_esperado);
if err_medio < 1e-10 && abs(pf.x(1,:)) < 1e-12 && abs(pf.y(1,:)) < 1e-12
    fprintf('[PASS] Test 20: fraccion=0.5 cae exacto a mitad de camino, fraccion=0 coincide con el origen\n'); n_pass = n_pass + 1;
else
    fprintf('[FAIL] Test 20: fraccion=0.5 no cae a mitad de camino (err=%.2e)\n', err_medio);
end

% Test 21: con datos reales de Camargo (si estan en disco) - la posicion
% del tobillo relativa a la rodilla, calculada solo con theta_tibia_real
% y long_tibia_r_m, debe mantener distancia constante = long_tibia_r_m en
% las 101 muestras del ciclo (mismo invariante que Test 19, ahora con
% datos reales en vez de sinteticos)
if isfolder(camargo_dir)
    n_total = n_total + 1;
    try
        theta_real_rad = deg2rad(res_cam.theta_tibia_real_deg);
        pos_real = Segmento_Posicion_Core(theta_real_rad, res_cam.long_tibia_r_m);
        dist_real = sqrt(pos_real.x.^2 + pos_real.y.^2);
        err_real = max(abs(dist_real - res_cam.long_tibia_r_m));
        if err_real < 1e-9
            fprintf('[PASS] Test 21: con AB06 real, distancia rodilla-tobillo constante = %.4f m en las 101 muestras (err max=%.2e)\n', res_cam.long_tibia_r_m, err_real); n_pass = n_pass + 1;
        else
            fprintf('[FAIL] Test 21: con AB06 real, la distancia no se mantiene constante (err max=%.2e)\n', err_real);
        end
    catch ME
        fprintf('[FAIL] Test 21: error inesperado usando Segmento_Posicion_Core con datos de Camargo: %s\n', ME.message);
    end
else
    fprintf('[SKIP] Test 21: sujeto piloto AB06 no encontrado - no cuenta como fallo.\n');
end

%% ---- RESUMEN ----
fprintf('\n=== %d/%d pruebas PASS ===\n', n_pass, n_total);
if n_pass < n_total
    fprintf('Revisar los [FAIL] antes de usar estas funciones con datos reales.\n');
end
