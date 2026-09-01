% DIAG_CIERRE_CICLO  31-ago-2026: el usuario observo que el angulo/
% posicion NO cierra bien (inicio de apoyo != fin de balanceo) cuando se
% aplica la correccion final, pero SI cierra razonablemente sin ella.
% Diagnostico numerico antes de armar la exportacion CSV.

talla_m = 1.70; masa_kg = 70; n = 101; pct = linspace(0,100,n);

antro = Estimar_Antropometria_Core(struct('talla_m', talla_m, 'masa_kg', masa_kg));
tempo = Temporizacion_Core(antro, 'Koopman');
K = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, struct('nMuestras', n));

theta1_crudo = deg2rad(K.cadera_flexext.angulo_deg(:).');
theta2_crudo = K.theta_tibia_via_rodilla_rad(:).';

cal = Calibracion_Koopman_Kuopio_Core();
theta1_cal = deg2rad(cal.off_muslo_deg) + cal.gan_muslo * theta1_crudo;
theta2_cal = deg2rad(cal.off_tibia_deg) + cal.gan_tibia * theta2_crudo;

fprintf('=== ANGULO (grados) ===\n');
fprintf('theta1 (muslo)  crudo: inicio=%.3f  fin=%.3f  gap=%.4f\n', ...
    rad2deg(theta1_crudo(1)), rad2deg(theta1_crudo(end)), rad2deg(theta1_crudo(end)-theta1_crudo(1)));
fprintf('theta1 (muslo)  CAL:   inicio=%.3f  fin=%.3f  gap=%.4f\n', ...
    rad2deg(theta1_cal(1)), rad2deg(theta1_cal(end)), rad2deg(theta1_cal(end)-theta1_cal(1)));
fprintf('theta2 (tibia)  crudo: inicio=%.3f  fin=%.3f  gap=%.4f\n', ...
    rad2deg(theta2_crudo(1)), rad2deg(theta2_crudo(end)), rad2deg(theta2_crudo(end)-theta2_crudo(1)));
fprintf('theta2 (tibia)  CAL:   inicio=%.3f  fin=%.3f  gap=%.4f\n', ...
    rad2deg(theta2_cal(1)), rad2deg(theta2_cal(end)), rad2deg(theta2_cal(end)-theta2_cal(1)));

% relacion teorica: si crudo(1)=crudo(end)+g, cal = a+b*crudo =>
% cal(end)-cal(1) = b*(crudo(end)-crudo(1)) = b*g -> el afin ESCALA el
% gap por b, no lo agranda si b<1. Verificar:
fprintf('\nVerificacion: b1*gap_crudo1 = %.4f (deberia ser = gap CAL1)\n', cal.gan_muslo*rad2deg(theta1_crudo(end)-theta1_crudo(1)));
fprintf('Verificacion: b2*gap_crudo2 = %.4f (deberia ser = gap CAL2)\n', cal.gan_tibia*rad2deg(theta2_crudo(end)-theta2_crudo(1)));

% ---------- posicion: crudo vs final (angulo cal + correccion suave) ----------
L1_cm = antro.long_muslo_m*100; L2_cm = antro.long_tibia_m*100;
zancada_cm = tempo.velocidad_ms*tempo.tiempo_ciclo_s*100;
cad = Trayectoria_Cadera_Core(pct, zancada_cm, 2.25, 0);

pos0 = Cinematica_DoblePendulo_Core(theta1_crudo, theta2_crudo, L1_cm, L2_cm, cad.Xh_cm, cad.Yh_cm);
Xk=pos0.Xk-pos0.Xk(1); Yk=pos0.Yk-pos0.Yk(1); Xa=pos0.Xa-pos0.Xa(1); Ya=pos0.Ya-pos0.Ya(1);

posc = Cinematica_DoblePendulo_Core(theta1_cal, theta2_cal, L1_cm, L2_cm, cad.Xh_cm, cad.Yh_cm);
Xkc=posc.Xk-posc.Xk(1); Ykc=posc.Yk-posc.Yk(1); Xac=posc.Xa-posc.Xa(1); Yac=posc.Ya-posc.Ya(1);
final = Correccion_Posicion_Suave_PenduloDoble_Core(pct, Xkc, Ykc, Xac, Yac);

fprintf('\n=== POSICION Y (cm) - deberia cerrar (sin deriva vertical neta) ===\n');
fprintf('Yk crudo: inicio=%.3f fin=%.3f gap=%.3f\n', Yk(1), Yk(end), Yk(end)-Yk(1));
fprintf('Yk FINAL: inicio=%.3f fin=%.3f gap=%.3f\n', final.Yk(1), final.Yk(end), final.Yk(end)-final.Yk(1));
fprintf('Ya crudo: inicio=%.3f fin=%.3f gap=%.3f\n', Ya(1), Ya(end), Ya(end)-Ya(1));
fprintf('Ya FINAL: inicio=%.3f fin=%.3f gap=%.3f\n', final.Ya(1), final.Ya(end), final.Ya(end)-final.Ya(1));

fprintf('\n=== POSICION X (cm) - NO deberia cerrar (avance neto = zancada) ===\n');
fprintf('Xk crudo: inicio=%.3f fin=%.3f avance=%.3f (zancada=%.3f)\n', Xk(1), Xk(end), Xk(end)-Xk(1), zancada_cm);
fprintf('Xk FINAL: inicio=%.3f fin=%.3f avance=%.3f\n', final.Xk(1), final.Xk(end), final.Xk(end)-final.Xk(1));
