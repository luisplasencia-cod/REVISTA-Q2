% Comprueba que Fig5_Datos_Fuerza.m reproduce los numeros publicados
% (RMSEnorm = 21.87, r = 0.9501, ICC(3,1) = 0.9984)
clear; clc;
D = load(fullfile(fileparts(mfilename('fullpath')),'Fig5_datos_fuerza.mat'));

sim = D.sim_media(:); ref = D.ref_media_ap(:); sd = D.ref_sd_ap(:);

err_total = sim - ref;
err_norm  = err_total ./ sd;
RMSEnorm  = sqrt(mean(err_norm.^2));
r         = corr(sim, ref);
pct1SD    = 100*mean(abs(err_total) <= sd);

% ICC(3,1) entre los ensayos del simulador (misma definicion del proyecto)
M = D.trials_norm; [n,kk] = size(M);
MSR = kk*var(mean(M,2),0,1);
MSC = n*var(mean(M,1),0,2);
MSE = (sum((M - mean(M,2) - mean(M,1) + mean(M(:))).^2,'all'))/((n-1)*(kk-1));
ICC = (MSR - MSE)/(MSR + (kk-1)*MSE);

fprintf('n ensayos usados : %d\n', D.n_ensayos);
fprintf('RMSEnorm         : %.4f   (paper: 21.87)\n', RMSEnorm);
fprintf('r                : %.4f   (paper: 0.9501)\n', r);
fprintf('ICC(3,1)         : %.4f   (paper: 0.9984)\n', ICC);
fprintf('%% dentro de 1SD  : %.2f\n', pct1SD);
fprintf('\nPico simulador   : %.2f %%BW = %.1f N\n', max(sim), max(sim)/100*D.BW_N);
fprintf('Pico ref 1       : %.2f %%BW = %.1f N (al %.0f%%)\n', D.ref_peak1_val, D.ref_peak1_val/100*D.BW_N, D.ref_peak1_time);
fprintf('Pico ref 2       : %.2f %%BW = %.1f N (al %.0f%%)\n', D.ref_peak2_val, D.ref_peak2_val/100*D.BW_N, D.ref_peak2_time);
fprintf('Valle ref        : %.2f %%BW = %.1f N (al %.0f%%)\n', D.ref_valley_val, D.ref_valley_val/100*D.BW_N, D.ref_valley_time);
fprintf('\nDuracion de ejecucion del simulador (apoyo): %.2f s (media de %d ensayos)\n', mean(D.dur_ms)/1000, D.n_ensayos);
fprintf('Residual max: %.2f %%BW   Residual medio: %.2f %%BW\n', max(D.residual), mean(D.residual));
