% ===================================================
% Fig5_Datos_Plataforma.m
%
% COPIA de CODIGOS/VALIDACIONES/Validacion_Plataforma.m con la LOGICA DE
% CALCULO INTACTA (mismo Savitzky-Golay orden 3 ventana 9, mismo atan2,
% mismo offset de -5.85 deg en apoyo, misma normalizacion 0-60 / 60-100
% con pchip, mismas medias y SD).
%
% Cambios respecto al original, todos autorizados (P-R2-7.5):
%   1. Sin dialogos -> rutas fijas, reproducible.
%   2. Sin figuras -> aqui solo se calcula y se guarda.
%      Todo lo visual vive en Fig5_Generar.m.
%
% Produce ademas los datos temporales que pide R2-4.
% ===================================================

clear; clc;

%% ---------------- CONFIGURACION ----------------
BASE = fullfile(fileparts(fileparts(mfilename('fullpath'))), ...
                'codigos y base original');

fs_sim            = 120;    % identico al original
fcorte_cinematica = 6;
sgolay_orden      = 3;
sgolay_window     = 9;

%% ---------------- BASES DE DATOS DE REFERENCIA ----------------
bd_ap  = load(fullfile(BASE,'REFERENCIAS','BaseDatos_Plataforma_Apoyo.mat'));
bd_bal = load(fullfile(BASE,'REFERENCIAS','BaseDatos_Plataforma_Balanceo.mat'));

tiempo_apoyo_ref    = bd_ap.tiempo_apoyo;
tiempo_balanceo_ref = bd_bal.tiempo_balanceo;
duracion_ref        = tiempo_apoyo_ref + tiempo_balanceo_ref;

media_ap     = bd_ap.angulo_plat_tiempo_apoyo(:);
sd_ap        = bd_ap.sd_plat_apoyo(:);
eje_media_ap = linspace(0, 60, length(media_ap));
eje_sd_ap    = linspace(0, 60, length(sd_ap));

media_bal     = bd_bal.angulo_plat_tiempo_balanceo(:);
sd_bal        = bd_bal.sd_plat_balanceo(:);
eje_media_bal = linspace(60, 100, length(media_bal));
eje_sd_bal    = linspace(60, 100, length(sd_bal));

eje_norm     = linspace(0, 100, 101)';
idx_apoyo    = eje_norm <= 60;
idx_balanceo = eje_norm > 60;
eje_ap       = eje_norm(idx_apoyo);
eje_bal      = eje_norm(idx_balanceo);

ref_norm = zeros(101,1);
sd_exp   = zeros(101,1);
ref_norm(idx_apoyo)    = interp1(eje_media_ap,  media_ap,  eje_ap,  'pchip');
ref_norm(idx_balanceo) = interp1(eje_media_bal, media_bal, eje_bal, 'pchip');
sd_exp(idx_apoyo)      = interp1(eje_sd_ap,  sd_ap,  eje_ap,  'pchip');
sd_exp(idx_balanceo)   = interp1(eje_sd_bal, sd_bal, eje_bal, 'pchip');

%% ---------------- ENSAYOS DEL SIMULADOR ----------------
dir_ap  = fullfile(BASE,'SIMULADOR','APOYO - SIM','Coordenadas_Apoyo');
dir_bal = fullfile(BASE,'SIMULADOR','BALANCEO - SIM','Coordenadas_Balanceo');

f_ap  = sort({dir(fullfile(dir_ap ,'*.csv')).name});
f_bal = sort({dir(fullfile(dir_bal,'*.csv')).name});

n_ensayos = numel(f_ap);
assert(numel(f_bal) == n_ensayos, 'Apoyo y balanceo no tienen el mismo n.');
fprintf('Ensayos de angulo: %d apoyo, %d balanceo\n', numel(f_ap), numel(f_bal));

trials_ap  = zeros(sum(idx_apoyo),    n_ensayos);
trials_bal = zeros(sum(idx_balanceo), n_ensayos);
t_ap_vec   = zeros(1, n_ensayos);
t_bal_vec  = zeros(1, n_ensayos);

for k = 1:n_ensayos
    % ---- APOYO ----
    D = readtable(fullfile(dir_ap, f_ap{k}), ...
                  'VariableNamingRule','preserve','Delimiter',';');
    t = D{:,1};  if max(t) > 10, t = t/1000; end
    t = t - t(1);  t_ap_vec(k) = t(end);

    xo = D{:,6}; yo = D{:,7}; xa = D{:,2}; ya = D{:,3};
    theta = rad2deg(unwrap(atan2(yo - ya, xo - xa)));
    ang   = sgolayfilt(theta - 5.85, sgolay_orden, sgolay_window);   % offset del original

    trials_ap(:,k) = interp1(linspace(0,60,numel(ang)), ang, eje_ap, 'pchip');

    % ---- BALANCEO ----
    D = readtable(fullfile(dir_bal, f_bal{k}), ...
                  'VariableNamingRule','preserve','Delimiter',';');
    t = D{:,1};  if max(t) > 10, t = t/1000; end
    t = t - t(1);  t_bal_vec(k) = t(end);

    xo = D{:,6}; yo = D{:,7}; xa = D{:,2}; ya = D{:,3};
    theta = rad2deg(unwrap(atan2(yo - ya, xo - xa)));
    ang   = sgolayfilt(theta, sgolay_orden, sgolay_window);          % sin offset, como el original

    trials_bal(:,k) = interp1(linspace(60,100,numel(ang)), ang, eje_bal, 'pchip');
end

sim_ap   = mean(trials_ap,  2);   sd_sim_ap  = std(trials_ap,  0, 2);
sim_bal  = mean(trials_bal, 2);   sd_sim_bal = std(trials_bal, 0, 2);

ref_ap  = ref_norm(idx_apoyo);    ref_sd_ap  = sd_exp(idx_apoyo);
ref_bal = ref_norm(idx_balanceo); ref_sd_bal = sd_exp(idx_balanceo);

residual_ap  = sim_ap  - ref_ap;      % R2-7
residual_bal = sim_bal - ref_bal;

tiempo_apoyo_sim    = mean(t_ap_vec);
tiempo_balanceo_sim = mean(t_bal_vec);
duracion_sim        = tiempo_apoyo_sim + tiempo_balanceo_sim;

%% ---------------- VERIFICACION CONTRA EL PAPER ----------------
met = @(s,r,sd) deal(sqrt(mean(((s-r)./sd).^2)), corr(s,r), 100*mean(abs(s-r)<=sd));
[rm_ap, r_ap, p_ap]    = met(sim_ap,  ref_ap,  ref_sd_ap);
[rm_bal, r_bal, p_bal] = met(sim_bal, ref_bal, ref_sd_bal);

fprintf('\n=== VERIFICACION CONTRA EL PAPER ===\n');
fprintf('APOYO    RMSEnorm=%.4f (0.38)  r=%.4f (1.00)   %%1SD=%.2f (100)\n',  rm_ap,  r_ap,  p_ap);
fprintf('BALANCEO RMSEnorm=%.4f (1.58)  r=%.4f (0.997)  %%1SD=%.2f (72.50)\n', rm_bal, r_bal, p_bal);

fprintf('\n=== DATOS TEMPORALES (R2-4) ===\n');
fprintf('Referencia : apoyo %.4f s | balanceo %.4f s | ciclo %.4f s\n', ...
        tiempo_apoyo_ref, tiempo_balanceo_ref, duracion_ref);
fprintf('Simulador  : apoyo %.4f s | balanceo %.4f s | ciclo %.4f s\n', ...
        tiempo_apoyo_sim, tiempo_balanceo_sim, duracion_sim);
fprintf('Factor de lentitud del simulador: %.1fx\n', duracion_sim/duracion_ref);

save(fullfile(fileparts(mfilename('fullpath')),'Fig5_datos_plataforma.mat'), ...
     'eje_ap','eje_bal','ref_ap','ref_sd_ap','ref_bal','ref_sd_bal', ...
     'sim_ap','sd_sim_ap','sim_bal','sd_sim_bal', ...
     'trials_ap','trials_bal','residual_ap','residual_bal','n_ensayos', ...
     'tiempo_apoyo_ref','tiempo_balanceo_ref','duracion_ref', ...
     'tiempo_apoyo_sim','tiempo_balanceo_sim','duracion_sim');

fprintf('\nGuardado: Fig5_datos_plataforma.mat\n');
