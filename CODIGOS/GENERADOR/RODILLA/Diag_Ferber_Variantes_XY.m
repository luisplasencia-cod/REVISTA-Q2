function T = Diag_Ferber_Variantes_XY()
% DIAG_FERBER_VARIANTES_XY - 02-sep-2026: decide la variante final de
% comparacion contra Ferber (treadmill) probando, para X e Y, con y sin
% Correccion_Hibrida_PenduloDoble_Core, siempre con Xh=Yh=0 (sin la rampa
% de avance/oscilacion de cadera que asume marcha OVERGROUND -
% Trayectoria_Cadera_Core - inapropiada para un dataset de treadmill).

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
    catch
        continue;
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

    % --- SIN rampa (Xh=Yh=0), NO CORREGIDO (solo geometria + calibracion LOSO) ---
    posNC = Cinematica_DoblePendulo_Core(theta1c, theta2c, L1_cm, L2_cm, 0, 0);
    XkNC = posNC.Xk - posNC.Xk(1); YkNC = posNC.Yk - posNC.Yk(1);

    % --- SIN rampa (Xh=Yh=0), SI CORREGIDO (Correccion_Hibrida con v=tempo) ---
    XaNC = posNC.Xa - posNC.Xa(1); YaNC = posNC.Ya - posNC.Ya(1);
    cC = Correccion_Hibrida_PenduloDoble_Core(pct, XkNC, YkNC, XaNC, YaNC, tempo.velocidad_ms);
    XkC = cC.Xk; YkC = cC.Yk;

    Xreal_r = S.x_horiz_relhip_cm(:).'; Yreal_r = S.y_vert_relhip_cm(:).';

    r_x_NC = corr(XkNC(:), Xreal_r(:)); rmse_x_NC = sqrt(mean((XkNC-Xreal_r).^2));
    r_y_NC = corr(YkNC(:), Yreal_r(:)); rmse_y_NC = sqrt(mean((YkNC-Yreal_r).^2));
    r_x_C  = corr(XkC(:),  Xreal_r(:)); rmse_x_C  = sqrt(mean((XkC-Xreal_r).^2));
    r_y_C  = corr(YkC(:),  Yreal_r(:)); rmse_y_C  = sqrt(mean((YkC-Yreal_r).^2));

    dentro_rango = talla_cm >= 161 && talla_cm <= 186.6;
    filas(end+1,:) = {sid, talla_cm, dentro_rango, r_x_NC, rmse_x_NC, r_y_NC, rmse_y_NC, r_x_C, rmse_x_C, r_y_C, rmse_y_C}; %#ok<AGROW>
end
warning('on','all');

T = cell2table(filas, 'VariableNames', {'sub_id','talla_cm','dentro_rango', ...
    'r_x_sinCorr','rmse_x_sinCorr','r_y_sinCorr','rmse_y_sinCorr', ...
    'r_x_conCorr','rmse_x_conCorr','r_y_conCorr','rmse_y_conCorr'});

fprintf('\n=== Ferber relhip, SIN rampa (Xh=Yh=0), N=%d ===\n', height(T));
fprintf('SIN Correccion_Hibrida:  r_X=%.3f (SD %.3f) RMSE=%.2fcm | r_Y=%.3f (SD %.3f) RMSE=%.2fcm\n', ...
    mean(T.r_x_sinCorr), std(T.r_x_sinCorr), mean(T.rmse_x_sinCorr), mean(T.r_y_sinCorr), std(T.r_y_sinCorr), mean(T.rmse_y_sinCorr));
fprintf('CON Correccion_Hibrida:  r_X=%.3f (SD %.3f) RMSE=%.2fcm | r_Y=%.3f (SD %.3f) RMSE=%.2fcm\n', ...
    mean(T.r_x_conCorr), std(T.r_x_conCorr), mean(T.rmse_x_conCorr), mean(T.r_y_conCorr), std(T.r_y_conCorr), mean(T.rmse_y_conCorr));

writetable(T, fullfile(carpeta, 'Diag_Ferber_Variantes_XY_resultados.csv'));
end
