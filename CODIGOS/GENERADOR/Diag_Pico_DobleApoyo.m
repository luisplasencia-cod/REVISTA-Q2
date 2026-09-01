function Diag_Pico_DobleApoyo()
% DIAG_PICO_DOBLEAPOYO  29-ago-2026: diagnostico puntual para ubicar el
% origen del pico espurio (~144-155%BW) que aparece en el 8-11% del ciclo
% de diag_zhao_doble_apoyo_86kg.png, comparado contra la Fig.5 del propio
% paper de Zhao 2026 (donde el VGRF predicho no muestra ese pico, sigue
% suave dentro de la banda de 8 ensayos medidos).
%
% HIPOTESIS A VERIFICAR: el "temprano" de la formula de reparto de doble
% apoyo (Ec.9) empieza exactamente en t=0 (instante de heel-strike de la
% pierna trackeada) - el mismo instante donde el CoM tiene un quiebre de
% VELOCIDAD entre el final del balanceo del ciclo anterior y el inicio del
% apoyo del ciclo actual (Cadena_Completa_Core fija el tobillo en (0,0) en
% ese instante exacto). El comentario del codigo ya declara que existe un
% quiebre analogo en el empalme apoyo->balanceo (medio ciclo despues) y
% que el suavizado Savitzky-Golay lo "corrige" - esta prueba mide si al
% OTRO lado del empalme (balanceo->apoyo, que cae justo donde empieza la
% ventana de "temprano") el suavizado deja un residuo de pico en la
% aceleracion de la pierna trackeada.
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta); addpath(fullfile(carpeta,'RODILLA','Kuopio'));

antro_in = struct('talla_m', 1.70, 'masa_kg', 86, 'sexo', 'M');
out = GRF_Newton_ApoyoSimple_Core(antro_in, 'Zhao');

pct = out.pct_ciclo;
figure('Position',[80 80 1000 800]);

subplot(3,1,1);
plot(pct, out.GRF_vertical_trackeada_pctBW, 'b-', 'LineWidth',1.5); hold on
xline(pct(find(out.apoyo_simple_mask,1,'first')), 'k--');
grid on; xlim([0 60]); ylabel('Fz trackeada %BW');
title('GRF vertical de la pierna trackeada (reparto Zhao Ec.9)');

subplot(3,1,2);
% recomputar las 3 aceleraciones internas para verlas por separado
G=9.80665;
M_total = out.antro.masa_kg;
plot(pct, out.GRF_vertical_pctBW, 'r-'); hold on;
grid on; xlim([0 60]); ylabel('Fz TOTAL (ambos pies) %BW');
title('GRF vertical total (antes del reparto) - deberia ser suave');

subplot(3,1,3);
% mask de temprano/tardio reconstruida igual que el Core
T = out.tempo.tiempo_ciclo_s;
t_u = out.t_s;
fase_trackeada = mod(t_u, T);
en_apoyo = fase_trackeada <= out.tempo.tiempo_apoyo_s;
plot(pct, en_apoyo, 'g-'); hold on
plot(pct, out.apoyo_simple_mask, 'b-');
legend('en apoyo (trackeada)','apoyo simple');
grid on; xlim([0 60]); ylabel('mask'); xlabel('% ciclo');

sgtitle('Diagnostico pico doble apoyo temprano (Zhao, 86kg)');
saveas(gcf, fullfile(carpeta,'Diag_Pico_DobleApoyo_figura.png'));

fprintf('Fz TOTAL (antes de repartir) en pct=0..15: \n');
disp(table(pct(pct<=15)', out.GRF_vertical_pctBW(pct<=15)', 'VariableNames',{'pct','Fz_total_pctBW'}));
fprintf('\nFz TRACKEADA (despues de repartir) en pct=0..15: \n');
disp(table(pct(pct<=15)', out.GRF_vertical_trackeada_pctBW(pct<=15)', 'VariableNames',{'pct','Fz_trackeada_pctBW'}));

end
