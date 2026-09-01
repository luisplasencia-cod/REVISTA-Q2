% REFIT_CORRECCIONFINAL_TALLASOLA  31-ago-2026: reajuste completo,
% consistente con lo que la app REALMENTE genera - SOLO talla como
% entrada (antropometria y velocidad ESTIMADAS, Drillis&Contini/Froude,
% igual que App_Animacion_Cadera_Rodilla_Tobillo.m), no antropometria
% real medida como en el ajuste anterior (Calcular_Coeficientes_
% CorreccionFinal.m, ahora inconsistente con la app). El angulo LOSO
% (Calibracion_Koopman_Kuopio_Core.m) se deja igual (relacion angulo
% Koopman -> angulo real, no depende fuerte de como se obtuvo v); SOLO
% se reajusta la correccion de POSICION (Fourier K=14) sobre el crudo
% generado con talla sola.
%
% Primero LOSO real (N=44) para validar honesto, despues ajuste
% agrupado completo (N=44) para desplegar - mismo patron ya usado en
% todo el proyecto.

carpeta = fileparts(mfilename('fullpath'));
carpeta_kuopio = fullfile(carpeta, 'RODILLA', 'Kuopio');
addpath(carpeta_kuopio);
archivos = dir(fullfile(carpeta_kuopio, 'raw', '*_l_comf_01.csv'));
ids = sort(cellfun(@(s) str2double(s(1:2)), {archivos.name}));
n = 101; pct = linspace(0,100,n);
pts_norm = 2:n;
K = 14;
cal = Calibracion_Koopman_Kuopio_Core();
campos = {'RodX','RodY','TobX','TobY'};
nombres = {'RODILLA X','RODILLA Y','TOBILLO X','TOBILLO Y'};

% ---------- cargar TODO con SOLO TALLA (igual que la app) ----------
S_all = struct('id',{},'pos_cal',{},'RealRodX',{},'RealRodY',{},'RealTobX',{},'RealTobY',{});
for i = 1:numel(ids)
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
    catch
        continue;
    end
    if numel(S.x_horiz_cm) ~= n, continue; end

    antro = Estimar_Antropometria_Core(struct('talla_m', S.talla_cm/100));
    tempo = Temporizacion_Core(antro, 'Koopman');
    Kd = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, struct('nMuestras', n));
    theta1 = deg2rad(Kd.cadera_flexext.angulo_deg(:).');
    theta2 = Kd.theta_tibia_via_rodilla_rad(:).';
    theta1c = deg2rad(cal.off_muslo_deg) + cal.gan_muslo*theta1;
    theta2c = deg2rad(cal.off_tibia_deg) + cal.gan_tibia*theta2;
    L1_cm = antro.long_muslo_m*100; L2_cm = antro.long_tibia_m*100;
    zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;
    cadT = Trayectoria_Cadera_Core(pct, zancada_cm, 2.25, 0);
    posc = Cinematica_DoblePendulo_Core(theta1c, theta2c, L1_cm, L2_cm, cadT.Xh_cm, cadT.Yh_cm);

    k = numel(S_all) + 1;
    S_all(k).id = sid;
    S_all(k).pos_cal = struct('RodX', posc.Xk-posc.Xk(1), 'RodY', posc.Yk-posc.Yk(1), ...
                               'TobX', posc.Xa-posc.Xa(1), 'TobY', posc.Ya-posc.Ya(1));
    S_all(k).RealRodX = S.x_horiz_cm(:).'; S_all(k).RealRodY = S.y_vert_cm(:).';
    S_all(k).RealTobX = S.x_horiz_tobillo_cm(:).'; S_all(k).RealTobY = S.y_vert_tobillo_cm(:).';
end
N = numel(S_all);
fprintf('N sujetos: %d\n', N);

Real = struct();
for c = 1:4, Real.(campos{c}) = cell2mat(arrayfun(@(k) S_all(k).(['Real' campos{c}]), 1:N, 'uni',0)'); end
SD = struct();
for c = 1:4, SD.(campos{c}) = std(Real.(campos{c}), 0, 1); end

% ---------- LOSO real para validar ----------
for c = 1:4, PredLOSO.(campos{c}) = nan(N,n); end
for i = 1:N
    otros = setdiff(1:N, i);
    for c = 1:4
        camp = campos{c};
        crudos_otros = cell2mat(arrayfun(@(k) S_all(k).pos_cal.(camp), otros, 'uni', 0)');
        reales_otros = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), otros, 'uni', 0)');
        coef = fit_fourier_afin(pct, crudos_otros, reales_otros, K);
        PredLOSO.(camp)(i,:) = aplicar_fourier_afin(pct, S_all(i).pos_cal.(camp), coef, K);
    end
end

fprintf('\n=== SOLO TALLA, correccion REAJUSTADA (LOSO real, N=%d) ===\n', N);
for c = 1:4
    camp = campos{c};
    pred = PredLOSO.(camp); real = Real.(camp);
    r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:N);
    rmse = sqrt(mean((pred-real).^2,2));
    err_norm = (pred(:,pts_norm) - real(:,pts_norm)) ./ SD.(camp)(pts_norm);
    rmsenorm = mean(sqrt(mean(err_norm.^2, 2)));
    fprintf('%-12s r=%.3f  RMSE=%.1fcm  RMSEnorm=%.2f\n', nombres{c}, mean(r), mean(rmse), rmsenorm);
end

% ---------- coeficientes de PRODUCCION (N completo) ----------
coefPos = struct();
for c = 1:4
    camp = campos{c};
    crudos = cell2mat(arrayfun(@(k) S_all(k).pos_cal.(camp), 1:N, 'uni', 0)');
    reales = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), 1:N, 'uni', 0)');
    coefPos.(camp) = fit_fourier_afin(pct, crudos, reales, K);
end
save(fullfile(carpeta, 'Coeficientes_CorreccionFinal.mat'), 'coefPos', 'K');
fprintf('\nCoeficientes de produccion (SOLO TALLA) guardados en Coeficientes_CorreccionFinal.mat\n');

save(fullfile(carpeta, 'Refit_TallaSola_resultados.mat'), 'S_all','Real','PredLOSO','pct');

f = figure('Position',[80 80 1150 850], 'Color','w');
for c = 1:4
    camp = campos{c};
    subplot(2,2,c); hold on; grid on; box on;
    crudo_m = mean(cell2mat(arrayfun(@(k) S_all(k).pos_cal.(camp), 1:N, 'uni',0)'), 1);
    plot(pct, mean(Real.(camp),1), 'k', 'LineWidth', 2.4);
    plot(pct, crudo_m, '--', 'Color', [0.55 0.55 0.55], 'LineWidth', 2.0);
    plot(pct, mean(PredLOSO.(camp),1), 'Color', [0.00 0.30 0.70], 'LineWidth', 2.2);
    title(nombres{c}); xlabel('% ciclo'); ylabel('cm');
    if c==1, legend({'real','crudo (solo talla)','final REAJUSTADO (solo talla)'}, 'Location','best','FontSize',8); end
end
sgtitle('Correccion reajustada con SOLO TALLA (LOSO real, N=44) - igual pipeline que la app', 'FontWeight','bold');
exportgraphics(f, fullfile(carpeta, 'Refit_TallaSola_figura.png'), 'Resolution', 150);
fprintf('Guardado figura.\n');

function coef = fit_fourier_afin(pct, crudos, reales, K)
Nsuj = size(crudos,1);
Phi = fourier_base(pct, K);
Xdes = []; Ydes = [];
for k = 1:Nsuj
    Xdes = [Xdes; [Phi, Phi .* crudos(k,:)']]; %#ok<AGROW>
    Ydes = [Ydes; reales(k,:)']; %#ok<AGROW>
end
coef = Xdes \ Ydes;
end

function pred = aplicar_fourier_afin(pct, crudo, coef, K)
Phi = fourier_base(pct, K);
m = size(Phi,2);
A = coef(1:m); B = coef(m+1:end);
at = Phi*A; bt = Phi*B;
pred = at(:).' + bt(:).' .* crudo;
end

function Phi = fourier_base(pct, K)
n = numel(pct);
Phi = ones(n, 2*K+1);
w = 2*pi*pct(:)/100;
for k = 1:K
    Phi(:, 2*k)   = cos(k*w);
    Phi(:, 2*k+1) = sin(k*w);
end
end
