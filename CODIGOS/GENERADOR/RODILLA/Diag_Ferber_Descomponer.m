function T = Diag_Ferber_Descomponer()
% DIAG_FERBER_DESCOMPONER - 02-sep-2026: aisla si el problema de r_X bajo
% contra Ferber es la rampa de avance de cadera (Trayectoria_Cadera_Core,
% que asume marcha OVERGROUND) contaminando la comparacion contra un
% dataset que es TREADMILL (confirmado: Ferber/README_Ferber2024_original.txt
% linea 18/48-49, "walking on a treadmill"), a diferencia de Kuopio
% (overground, confirmado en su propio docstring).
%
% Compara 4 variantes de Xpred contra Ferber RELHIP (la unica convencion
% fisicamente valida para treadmill, ya que en treadmill la cadera casi no
% se traslada en el marco de laboratorio):
%   v0_crudo_sin_calibrar : angulo Koopman crudo (sin LOSO), sin rampa, sin correccion  (=DIAG_ferber_lados)
%   v1_calibrado_sin_rampa: angulo calibrado LOSO, sin rampa (zancada=0), sin correccion hibrida
%   v2_pipeline_menos_Xh  : pipeline COMPLETO (calibrado+rampa+correccion), luego se resta la rampa Xh usada como insumo
%   v3_pipeline_full_Xk   : pipeline COMPLETO tal cual usa Validar_Externo_Ferber_Core.m hoy (para referencia)

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
addpath(fullfile(fileparts(mfilename('fullpath')), 'Ferber'));
carpeta = fileparts(mfilename('fullpath'));
carpeta_ferber = fullfile(carpeta, 'Ferber');
Tmeta = readtable(fullfile(carpeta_ferber, 'muestra_40.csv'));
n = 101; pct = linspace(0,100,n);
warning('off','all');

filas = {};
for i = 1:height(Tmeta)
    sid = Tmeta.sub_id(i);
    talla_cm = Tmeta.Height(i);
    json_path = fullfile(carpeta_ferber, 'muestra40_raw', sprintf('%d_%s', sid, Tmeta.filename{i}));
    if ~isfile(json_path), continue; end
    try
        S = Cargar_Ferber2024_Core(json_path);
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message); continue;
    end
    if numel(S.x_horiz_cm) ~= n, continue; end

    antro = Estimar_Antropometria_Core(struct('talla_m', talla_cm/100));
    tempo = Temporizacion_Core(antro, 'Koopman');
    cal = Calibracion_Koopman_Kuopio_Core();
    Kd = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, struct('nMuestras', n));
    theta1 = deg2rad(Kd.cadera_flexext.angulo_deg(:).');
    theta2 = Kd.theta_tibia_via_rodilla_rad(:).';
    theta1c = deg2rad(cal.off_muslo_deg) + cal.gan_muslo*theta1;
    theta2c = deg2rad(cal.off_tibia_deg) + cal.gan_tibia*theta2;
    L1_cm = antro.long_muslo_m*100; L2_cm = antro.long_tibia_m*100;
    zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;

    % --- v0: crudo sin calibrar, sin rampa (equivalente DIAG_ferber_lados) ---
    v0 = L1_cm*sin(theta1); v0 = v0 - v0(1);

    % --- v1: calibrado LOSO, sin rampa, SIN correccion hibrida ---
    v1 = L1_cm*sin(theta1c); v1 = v1 - v1(1);

    % --- v2: pipeline completo (rampa + correccion), luego RESTA la rampa usada ---
    cad = Trayectoria_Cadera_Core(pct, zancada_cm, 2.25, 0);
    posc = Cinematica_DoblePendulo_Core(theta1c, theta2c, L1_cm, L2_cm, cad.Xh_cm, cad.Yh_cm);
    Xkc = posc.Xk - posc.Xk(1); Ykc = posc.Yk - posc.Yk(1);
    Xac = posc.Xa - posc.Xa(1); Yac = posc.Ya - posc.Ya(1);
    c = Correccion_Hibrida_PenduloDoble_Core(pct, Xkc, Ykc, Xac, Yac, tempo.velocidad_ms);
    v3 = c.Xk;                      % = lo que usa Validar_Externo_Ferber_Core.m hoy
    v2 = c.Xk - cad.Xh_cm;          % resta la MISMA rampa (sin warp) que se sumo como insumo
    v2 = v2 - v2(1);

    Xreal_r = S.x_horiz_relhip_cm(:).';
    Xreal_g = S.x_horiz_cm(:).';

    r0 = corr(v0(:), Xreal_r(:));
    r1 = corr(v1(:), Xreal_r(:));
    r2 = corr(v2(:), Xreal_r(:));
    r3g = corr(v3(:), Xreal_g(:));
    r3r = corr(v3(:), Xreal_r(:));
    rmse0 = sqrt(mean((v0-Xreal_r).^2));
    rmse1 = sqrt(mean((v1-Xreal_r).^2));
    rmse2 = sqrt(mean((v2-Xreal_r).^2));

    filas(end+1,:) = {sid, talla_cm, r0, rmse0, r1, rmse1, r2, rmse2, r3g, r3r}; %#ok<AGROW>
end
warning('on','all');

T = cell2table(filas, 'VariableNames', {'sub_id','talla_cm', ...
    'r_v0_crudo','rmse_v0','r_v1_calibLOSO','rmse_v1','r_v2_pipeline_menosXh','rmse_v2', ...
    'r_v3_full_vs_global','r_v3_full_vs_relhip'});

fprintf('\n=== Descomposicion RODILLA X vs Ferber relhip (N=%d) ===\n', height(T));
fprintf('v0 crudo sin calibrar, sin rampa:      r=%.3f (SD %.3f)  RMSE=%.2fcm\n', mean(T.r_v0_crudo), std(T.r_v0_crudo), mean(T.rmse_v0));
fprintf('v1 calibrado LOSO, sin rampa:          r=%.3f (SD %.3f)  RMSE=%.2fcm\n', mean(T.r_v1_calibLOSO), std(T.r_v1_calibLOSO), mean(T.rmse_v1));
fprintf('v2 pipeline completo MENOS rampa Xh:   r=%.3f (SD %.3f)  RMSE=%.2fcm\n', mean(T.r_v2_pipeline_menosXh), std(T.r_v2_pipeline_menosXh), mean(T.rmse_v2));
fprintf('v3 pipeline completo (Xk full) vs GLOBAL:  r=%.3f (SD %.3f)\n', mean(T.r_v3_full_vs_global), std(T.r_v3_full_vs_global));
fprintf('v3 pipeline completo (Xk full) vs RELHIP:  r=%.3f (SD %.3f)  [= columna r_X_relhip de Validar_Externo_Ferber_Core.m]\n', mean(T.r_v3_full_vs_relhip), std(T.r_v3_full_vs_relhip));

writetable(T, fullfile(carpeta, 'Diag_Ferber_Descomponer_resultados.csv'));
end
