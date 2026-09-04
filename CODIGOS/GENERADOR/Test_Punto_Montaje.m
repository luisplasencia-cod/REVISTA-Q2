function Test_Punto_Montaje()
% TEST_PUNTO_MONTAJE  Pruebas de Aplicar_Punto_Montaje_Core.m (punto de
%                      montaje protesico sobre el segmento tibial, medido
%                      desde el tobillo - sesion de integracion con
%                      GAITSIM/Raspberry, 02-sep-2026; REESCRITAS
%                      03-sep-2026 para la definicion por SEGMENTO, ver
%                      cabecera de Aplicar_Punto_Montaje_Core.m). NO
%                      duplica Test_Generador_Trayectoria.m Tests 16-18
%                      (esos prueban punto_seguimiento_m de Cadena_
%                      Cinematica_Core.m, el pipeline de exportacion a CSV
%                      con su propia convencion de signo en X).
% ==========================================================================
addpath(fileparts(mfilename('fullpath')));
fprintf('\n=== Test_Punto_Montaje ===\n\n');
nPass = 0; nTotal = 0;

% Geometria de referencia: cadena rigida (antes de cualquier correccion)
L1 = 45; L2 = 42; Xh = 0; Yh = 0;
theta1 = deg2rad(linspace(-10, 30, 30));
theta2 = deg2rad(linspace(-15, 50, 30));
pos = Cinematica_DoblePendulo_Core(theta1, theta2, L1, L2, Xh, Yh);

% ---- Test 1: d=0 es no-op exacto (punto de montaje = tobillo) ----
nTotal = nTotal + 1;
r0 = Aplicar_Punto_Montaje_Core(pos.Xa, pos.Ya, pos.Xk, pos.Yk, 0);
ok = all(abs(r0.Xm_cm - pos.Xa) < 1e-12) && all(abs(r0.Ym_cm - pos.Ya) < 1e-12);
nPass = reportar(nPass, ok, 1, 'd_montaje_cm=0 reproduce el tobillo exacto (no-op)');

% ---- Test 2: segmento vertical, calculo trivial a mano ----
% Tobillo en (5,12), rodilla en (5,20) -> segmento vertical de 8 cm hacia
% arriba. Con d=4: Pm = (5, 16), la mitad.
nTotal = nTotal + 1;
r_v = Aplicar_Punto_Montaje_Core(5, 12, 5, 20, 4);
ok = abs(r_v.Xm_cm - 5) < 1e-12 && abs(r_v.Ym_cm - 16) < 1e-12;
nPass = reportar(nPass, ok, 2, sprintf('segmento vertical, d=4: Xm=%.4f (esp. 5), Ym=%.4f (esp. 16)', r_v.Xm_cm, r_v.Ym_cm));

% ---- Test 3: segmento horizontal, calculo trivial a mano ----
% Tobillo en (5,12), rodilla en (1,12) -> segmento horizontal de 4 cm hacia
% -X. Con d=4: Pm = (1,12), o sea la rodilla exacta.
nTotal = nTotal + 1;
r_h = Aplicar_Punto_Montaje_Core(5, 12, 1, 12, 4);
ok = abs(r_h.Xm_cm - 1) < 1e-12 && abs(r_h.Ym_cm - 12) < 1e-12;
nPass = reportar(nPass, ok, 3, sprintf('segmento horizontal, d=4: Xm=%.4f (esp. 1), Ym=%.4f (esp. 12)', r_h.Xm_cm, r_h.Ym_cm));

% ---- Test 4: d = longitud del segmento reproduce EXACTAMENTE la rodilla ----
nTotal = nTotal + 1;
r_rod = Aplicar_Punto_Montaje_Core(pos.Xa, pos.Ya, pos.Xk, pos.Yk, L2);
ok = all(abs(r_rod.Xm_cm - pos.Xk) < 1e-9) && all(abs(r_rod.Ym_cm - pos.Yk) < 1e-9);
nPass = reportar(nPass, ok, 4, 'd_montaje_cm=|segmento| reproduce exactamente la rodilla de Cinematica_DoblePendulo_Core.m');

% ---- Test 5: distancia tobillo->montaje constante = d, con eje REAL (15-24 cm) ----
nTotal = nTotal + 1;
d_prueba = 20.0;  % cm - dentro del rango real del eje de prueba (15-24 cm)
r_d = Aplicar_Punto_Montaje_Core(pos.Xa, pos.Ya, pos.Xk, pos.Yk, d_prueba);
dist = sqrt((r_d.Xm_cm - pos.Xa).^2 + (r_d.Ym_cm - pos.Ya).^2);
ok = max(abs(dist - d_prueba)) < 1e-9;
nPass = reportar(nPass, ok, 5, sprintf('distancia tobillo->montaje constante = %.1f cm (max error=%.2e)', d_prueba, max(abs(dist-d_prueba))));

% ---- Test 6: d > longitud del segmento dispara error controlado ----
nTotal = nTotal + 1;
try
    Aplicar_Punto_Montaje_Core(pos.Xa, pos.Ya, pos.Xk, pos.Yk, L2 + 1);
    ok = false;
catch
    ok = true;
end
nPass = reportar(nPass, ok, 6, 'd_montaje_cm > |segmento| dispara error controlado (no puede pasar la rodilla)');

% ---- Test 7 (NUEVO 03-sep-2026): el punto cae SOBRE el segmento incluso
%      cuando el segmento NO es rigido (caso real tras la correccion de
%      posicion, que mueve rodilla y tobillo por separado) ----
nTotal = nTotal + 1;
Xa2 = pos.Xa + 0.8*sin(linspace(0,3,30));      % perturbaciones independientes
Ya2 = pos.Ya - 0.5*cos(linspace(0,4,30));      % que rompen la rigidez
Xk2 = pos.Xk - 0.6*cos(linspace(0,5,30));
Yk2 = pos.Yk + 0.9*sin(linspace(0,2,30));
r_nr = Aplicar_Punto_Montaje_Core(Xa2, Ya2, Xk2, Yk2, d_prueba);
dist_nr = sqrt((r_nr.Xm_cm - Xa2).^2 + (r_nr.Ym_cm - Ya2).^2);
vx = Xk2 - Xa2; vy = Yk2 - Ya2; Lseg = sqrt(vx.^2 + vy.^2);
fuera = abs(vx.*(r_nr.Ym_cm - Ya2) - vy.*(r_nr.Xm_cm - Xa2)) ./ Lseg;  % dist. a la recta
ok = max(abs(dist_nr - d_prueba)) < 1e-9 && max(fuera) < 1e-9;
nPass = reportar(nPass, ok, 7, sprintf('con segmento NO rigido (%.1f-%.1f cm): distancia exacta (err %.1e) Y sobre el segmento (err %.1e)', ...
    min(Lseg), max(Lseg), max(abs(dist_nr-d_prueba)), max(fuera)));

% ---- Test 8 (NUEVO): llamada con la firma VIEJA da error explicito ----
nTotal = nTotal + 1;
try
    Aplicar_Punto_Montaje_Core(pos.Xa, pos.Ya, theta2, 16, L2);  % firma vieja
    ok = false;
catch ME
    ok = contains(ME.message, 'FIRMA VIEJA');
end
nPass = reportar(nPass, ok, 8, 'llamada con la firma vieja (Xa,Ya,theta,d,L) da error explicito, no resultados equivocados');

fprintf('\n=== %d/%d pruebas PASS ===\n\n', nPass, nTotal);
if nPass < nTotal
    error('Test_Punto_Montaje: %d de %d pruebas fallaron.', nTotal-nPass, nTotal);
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
