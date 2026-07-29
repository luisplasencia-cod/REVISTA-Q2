% ===================================================
% PROTOCOLO DE VALIDACIÓN - PLATAFORMA
% PLATAFORMA
% ===================================================

clear
clc
close all
close all force
delete(findall(0,'Type','figure','-and','WindowStyle','normal'))

%% CONFIGURACIÓN
fs_sim = 120;        
fcorte_cinematica = 6;     
% ===== FILTRO =====
sgolay_orden = 3;
sgolay_window = 9;

%% =======================
% CARGA BASE DE DATOS PLATAFORMA CORREGIDA
%% =======================

[file_bd_ap, path_bd_ap] = uigetfile('*.mat','Seleccione BaseDatos_Plataforma_Apoyo.mat');
bd_ap = load(fullfile(path_bd_ap, file_bd_ap));

[file_bd_bal, path_bd_bal] = uigetfile('*.mat','Seleccione BaseDatos_Plataforma_Balanceo.mat');
bd_bal = load(fullfile(path_bd_bal, file_bd_bal));

tiempo_apoyo_ref    = bd_ap.tiempo_apoyo;
tiempo_balanceo_ref = bd_bal.tiempo_balanceo;
duracion_ref        = tiempo_apoyo_ref + tiempo_balanceo_ref;

% Referencia apoyo
media_ap     = bd_ap.angulo_plat_tiempo_apoyo(:);
sd_ap        = bd_ap.sd_plat_apoyo(:);
eje_media_ap = linspace(0,  60, length(media_ap));
eje_sd_ap    = linspace(0,  60, length(sd_ap));

% Referencia balanceo
media_bal     = bd_bal.angulo_plat_tiempo_balanceo(:);
sd_bal        = bd_bal.sd_plat_balanceo(:);
eje_media_bal = linspace(60, 100, length(media_bal));
eje_sd_bal    = linspace(60, 100, length(sd_bal));

% Ejes normalizados
eje_norm     = linspace(0, 100, 101)';
idx_apoyo    = eje_norm <= 60;
idx_balanceo = eje_norm > 60;

eje_ap  = eje_norm(idx_apoyo);
eje_bal = eje_norm(idx_balanceo);

rodilla_exp_norm = zeros(101,1);
sd_exp           = zeros(101,1);

rodilla_exp_norm(idx_apoyo)    = interp1(eje_media_ap,  media_ap,  eje_ap,  'pchip');
rodilla_exp_norm(idx_balanceo) = interp1(eje_media_bal, media_bal, eje_bal, 'pchip');

sd_exp(idx_apoyo)    = interp1(eje_sd_ap,  sd_ap,  eje_ap,  'pchip');
sd_exp(idx_balanceo) = interp1(eje_sd_bal, sd_bal, eje_bal, 'pchip');

%% =======================
% CARGA 5 ENSAYOS - APOYO
%% =======================
n_pts_apoyo    = sum(idx_apoyo);
n_pts_balanceo = sum(idx_balanceo);

[files_apoyo, path_apoyo] = uigetfile('*.csv', ...
    'Seleccione los 10 archivos de APOYO (Ctrl+Click)', ...
    'MultiSelect','on');

if ~iscell(files_apoyo)
    error('Debe seleccionar los 10 archivos de apoyo.');
end
files_apoyo = sort(files_apoyo);   % asegura orden por nombre
n_ensayos   = numel(files_apoyo);

trials_apoyo_norm = zeros(n_pts_apoyo, n_ensayos);
raw_apoyo_cell     = cell(1, n_ensayos);
filt_apoyo_cell    = cell(1, n_ensayos);
t_apoyo_cell        = cell(1, n_ensayos);
t_apoyo_vec         = zeros(1, n_ensayos);

for k = 1:n_ensayos
    data_apoyo = readtable(fullfile(path_apoyo, files_apoyo{k}), ...
        'VariableNamingRule','preserve','Delimiter',';');

    t_ap = data_apoyo{:,1};
    if max(t_ap) > 10, t_ap = t_ap / 1000; end
    t_ap = t_ap - t_ap(1);
    t_apoyo_vec(k)  = t_ap(end);
    t_apoyo_cell{k} = t_ap;

    xo = data_apoyo{:,6};
    yo = data_apoyo{:,7};
    xa = data_apoyo{:,2};
    ya = data_apoyo{:,3};

    theta_raw = atan2(yo - ya, xo - xa);
    theta_deg = rad2deg(unwrap(theta_raw));

    rodilla_k      = theta_deg - 5.85;
    rodilla_k_filt = sgolayfilt(rodilla_k, sgolay_orden, sgolay_window);

    raw_apoyo_cell{k}  = rodilla_k;
    filt_apoyo_cell{k} = rodilla_k_filt;

    pct_ap = linspace(0, 60, length(rodilla_k_filt));
    trials_apoyo_norm(:,k) = interp1(pct_ap, rodilla_k_filt, ...
        eje_norm(idx_apoyo), 'pchip');
end
%% =======================
% CARGA 10 ENSAYOS - BALANCEO (selección múltiple)
%% =======================
[files_balanceo, path_balanceo] = uigetfile('*.csv', ...
    'Seleccione los 10 archivos de BALANCEO (Ctrl+Click)', ...
    'MultiSelect','on');

if ~iscell(files_balanceo)
    error('Debe seleccionar los 10 archivos de balanceo.');
end
files_balanceo = sort(files_balanceo);
if numel(files_balanceo) ~= n_ensayos
    error('El número de archivos de balanceo (%d) no coincide con apoyo (%d).', ...
        numel(files_balanceo), n_ensayos);
end

trials_balanceo_norm = zeros(n_pts_balanceo, n_ensayos);
raw_balanceo_cell     = cell(1, n_ensayos);
filt_balanceo_cell    = cell(1, n_ensayos);
t_balanceo_cell        = cell(1, n_ensayos);
t_balanceo_vec         = zeros(1, n_ensayos);

for k = 1:n_ensayos
    data_balanceo = readtable(fullfile(path_balanceo, files_balanceo{k}), ...
        'VariableNamingRule','preserve','Delimiter',';');

    t_bal = data_balanceo{:,1};
    if max(t_bal) > 10, t_bal = t_bal / 1000; end
    t_bal = t_bal - t_bal(1);
    t_balanceo_vec(k)  = t_bal(end);
    t_balanceo_cell{k} = t_bal;

    xo = data_balanceo{:,6};
    yo = data_balanceo{:,7};
    xa = data_balanceo{:,2};
    ya = data_balanceo{:,3};

    theta_raw = atan2(yo - ya, xo - xa);
    theta_deg = rad2deg(unwrap(theta_raw));

    rodilla_k      = theta_deg;
    rodilla_k_filt = sgolayfilt(rodilla_k, sgolay_orden, sgolay_window);

    raw_balanceo_cell{k}  = rodilla_k;
    filt_balanceo_cell{k} = rodilla_k_filt;

    pct_bal = linspace(60, 100, length(rodilla_k_filt));
    trials_balanceo_norm(:,k) = interp1(pct_bal, rodilla_k_filt, ...
        eje_norm(idx_balanceo), 'pchip');
end

%% =======================
% CURVAS MEDIAS + TIEMPOS
%% =======================
rodilla_apoyo_norm    = mean(trials_apoyo_norm,    2);
rodilla_balanceo_norm = mean(trials_balanceo_norm, 2);
sd_sim_apoyo          = std(trials_apoyo_norm,    0, 2);
sd_sim_balanceo       = std(trials_balanceo_norm, 0, 2);

tiempo_apoyo_sim    = mean(t_apoyo_vec);
tiempo_balanceo_sim = mean(t_balanceo_vec);
duracion_sim        = tiempo_apoyo_sim + tiempo_balanceo_sim;
error_apoyo_t       = tiempo_apoyo_sim    - tiempo_apoyo_ref;
error_balanceo_t    = tiempo_balanceo_sim - tiempo_balanceo_ref;
error_total_t       = duracion_sim        - duracion_ref;

%% ===================================================
% VENTANA 1 - PROCESO + VALIDACIÓN VISUAL POR FASES
%% ===================================================
colores_trials = lines(n_ensayos);

figure('Name','Proceso y Validación por Fases','NumberTitle','off', ...
       'Position',[50 50 1400 700])
tiledlayout(2, 3, 'TileSpacing','compact','Padding','compact')

eje_ap  = eje_norm(idx_apoyo);
eje_bal = eje_norm(idx_balanceo);
ref_ap  = rodilla_exp_norm(idx_apoyo);
ref_bal = rodilla_exp_norm(idx_balanceo);
sd_ap   = sd_exp(idx_apoyo);
sd_bal  = sd_exp(idx_balanceo);

% ===================== APOYO =====================

% (1,1) Crudas vs Filtradas — 5 ensayos
nexttile; hold on
for k = 1:n_ensayos
    plot(t_apoyo_cell{k}, raw_apoyo_cell{k},  ':', ...
         'Color',[colores_trials(k,:) 0.35], 'LineWidth',1)
    plot(t_apoyo_cell{k}, filt_apoyo_cell{k}, '-', ...
         'Color', colores_trials(k,:), 'LineWidth',1.4)
end
h = gobjects(1,n_ensayos);
for k = 1:n_ensayos
    h(k) = plot(nan,nan,'-','Color',colores_trials(k,:),'LineWidth',1.6);
end
legend(h, arrayfun(@(k)sprintf('E%d',k),1:n_ensayos,'UniformOutput',false), ...
    'Location','best','FontSize',7)
title('Apoyo: Cruda vs Filtrada (5 ensayos)')
xlabel('Tiempo (s)'); ylabel('Ángulo (°)'); grid on

% (1,2) Trials normalizados + Media
nexttile; hold on
for k = 1:n_ensayos
    plot(eje_ap, trials_apoyo_norm(:,k), '-', ...
         'Color',[colores_trials(k,:) 0.45],'LineWidth',1)
end
plot(eje_ap, rodilla_apoyo_norm,'k-','LineWidth',2.2)
legend([arrayfun(@(k)sprintf('E%d',k),1:n_ensayos,'UniformOutput',false),{'Media'}], ...
    'Location','best','FontSize',7)
title('Apoyo: Normalizada — trials + media (0–60%)')
xlabel('% Ciclo de Marcha'); ylabel('Ángulo (°)'); grid on

% (1,3) Simulador vs Referencia ±1SD
nexttile
x_fill = [eje_ap(:)', fliplr(eje_ap(:)')];
y_fill = [(ref_ap(:)+sd_ap(:))', fliplr((ref_ap(:)-sd_ap(:))')];
fill(x_fill, y_fill, [0.85 0.85 0.85],'EdgeColor','none','FaceAlpha',0.6); hold on
plot(eje_ap, ref_ap, 'k-', 'LineWidth',2.2)
plot(eje_ap, rodilla_apoyo_norm, 'r--','LineWidth',2)
legend({'±1SD Ref','Reference ','Simulator mean)'},'Location','best','FontSize',8)
title('Stance phase: simulator vs Reference')
xlabel('Gait Cycle (%)'); ylabel('Inclination Angle (°)'); grid on

% ===================== BALANCEO =====================

% (2,1) Crudas vs Filtradas — 5 ensayos
nexttile; hold on
for k = 1:n_ensayos
    plot(t_balanceo_cell{k}, raw_balanceo_cell{k},  ':', ...
         'Color',[colores_trials(k,:) 0.35],'LineWidth',1)
    plot(t_balanceo_cell{k}, filt_balanceo_cell{k}, '-', ...
         'Color', colores_trials(k,:),'LineWidth',1.4)
end
h = gobjects(1,n_ensayos);
for k = 1:n_ensayos
    h(k) = plot(nan,nan,'-','Color',colores_trials(k,:),'LineWidth',1.6);
end
legend(h, arrayfun(@(k)sprintf('E%d',k),1:n_ensayos,'UniformOutput',false), ...
    'Location','best','FontSize',7)
title('Balanceo: Cruda vs Filtrada (5 ensayos)')
xlabel('Tiempo (s)'); ylabel('Ángulo (°)'); grid on

% (2,2) Trials normalizados + Media
nexttile; hold on
for k = 1:n_ensayos
    plot(eje_bal, trials_balanceo_norm(:,k), '-', ...
         'Color',[colores_trials(k,:) 0.45],'LineWidth',1)
end
plot(eje_bal, rodilla_balanceo_norm,'k-','LineWidth',2.2)
legend([arrayfun(@(k)sprintf('E%d',k),1:n_ensayos,'UniformOutput',false),{'Media'}], ...
    'Location','best','FontSize',7)
title('Balanceo: Normalizada — trials + media (60–100%)')
xlabel('% Ciclo de Marcha'); ylabel('Ángulo (°)'); grid on

% (2,3) Simulador vs Referencia ±1SD
nexttile
x_fill = [eje_bal(:)', fliplr(eje_bal(:)')];
y_fill = [(ref_bal(:)+sd_bal(:))', fliplr((ref_bal(:)-sd_bal(:))')];
fill(x_fill, y_fill, [0.85 0.85 0.85],'EdgeColor','none','FaceAlpha',0.6); hold on
plot(eje_bal, ref_bal,              'k-', 'LineWidth',2.2)
plot(eje_bal, rodilla_balanceo_norm,'r--','LineWidth',2)
legend({'±1SD Ref','Referencia','Simulador (media)'},'Location','best','FontSize',8)
title('Balanceo: Simulador vs Referencia')
xlabel('% Ciclo de Marcha'); ylabel('Ángulo (°)'); grid on

%% =======================
% VALIDACIÓN ESTADÍSTICA
%% =======================
idx_apoyo    = eje_norm <= 60;
idx_balanceo = eje_norm > 60;

resultados = cell(2, 17);

error_apoyo      = rodilla_apoyo_norm - rodilla_exp_norm(idx_apoyo);
error_norm_apoyo = error_apoyo ./ sd_exp(idx_apoyo);

resultados(1,:) = calcular_estadistica( ...
    rodilla_apoyo_norm, rodilla_exp_norm(idx_apoyo), ...
    error_apoyo, error_norm_apoyo, sd_exp(idx_apoyo), ...
    true(size(rodilla_apoyo_norm)), "Apoyo", trials_apoyo_norm);

error_balanceo      = rodilla_balanceo_norm - rodilla_exp_norm(idx_balanceo);
error_norm_balanceo = error_balanceo ./ sd_exp(idx_balanceo);

resultados(2,:) = calcular_estadistica( ...
    rodilla_balanceo_norm, rodilla_exp_norm(idx_balanceo), ...
    error_balanceo, error_norm_balanceo, sd_exp(idx_balanceo), ...
    true(size(rodilla_balanceo_norm)), "Balanceo", trials_balanceo_norm);

%% =======================
% VENTANA 2 - TABLA ESTADÍSTICA
%% =======================
fig2 = uifigure('Name','Validación Estadística - Plataforma', ...
                'Position',[100 100 1020 340]);

tabla_visual = cell(2, 12);
for i = 1:2
    tabla_visual{i,1}  = char(resultados{i,1});
    tabla_visual{i,2}  = double(resultados{i,2});
    tabla_visual{i,3}  = double(resultados{i,3});
    tabla_visual{i,4}  = double(resultados{i,4});
    tabla_visual{i,5}  = double(resultados{i,6});
    tabla_visual{i,6}  = double(resultados{i,7});
    tabla_visual{i,7}  = double(resultados{i,8});
    tabla_visual{i,8}  = double(resultados{i,9});
    tabla_visual{i,9}  = double(resultados{i,10});
    if i == 1
        tabla_visual{i,10} = double(tiempo_apoyo_sim);
        tabla_visual{i,11} = double(tiempo_apoyo_ref);
        tabla_visual{i,12} = double(error_apoyo_t);
    else
        tabla_visual{i,10} = double(tiempo_balanceo_sim);
        tabla_visual{i,11} = double(tiempo_balanceo_ref);
        tabla_visual{i,12} = double(error_balanceo_t);
    end
end

fmt_metricas = '%.4f';
fmt_tiempo   = '%.3f';

columnas = {'Phase', 'RMSE_{norm}', 'r', '% ±1SD', ...
            'ROM_{sim} (°)', 'ROM_{exp} (°)', '\DeltaROM (°)', ...
            'CMC', 'ICC(3,1)', ...
            'T_{sim} (s)', 'T_{ref} (s)', '\DeltaT (s)'};

tabla_fmt = cell(2, 12);
for i = 1:2
    tabla_fmt{i,1}  = tabla_visual{i,1};
    tabla_fmt{i,2}  = sprintf(fmt_metricas, tabla_visual{i,2});
    tabla_fmt{i,3}  = sprintf(fmt_metricas, tabla_visual{i,3});
    tabla_fmt{i,4}  = sprintf('%.2f',       tabla_visual{i,4});
    tabla_fmt{i,5}  = sprintf('%.2f',       tabla_visual{i,5});
    tabla_fmt{i,6}  = sprintf('%.2f',       tabla_visual{i,6});
    tabla_fmt{i,7}  = sprintf('%.2f',       tabla_visual{i,7});
    tabla_fmt{i,8}  = sprintf(fmt_metricas, tabla_visual{i,8});
    tabla_fmt{i,9}  = sprintf(fmt_metricas, tabla_visual{i,9});
    tabla_fmt{i,10} = sprintf(fmt_tiempo,   tabla_visual{i,10});
    tabla_fmt{i,11} = sprintf(fmt_tiempo,   tabla_visual{i,11});
    tabla_fmt{i,12} = sprintf(fmt_tiempo,   tabla_visual{i,12});
end

uitbl = uitable(fig2, ...
    'Data',        tabla_fmt, ...
    'ColumnName',  columnas, ...
    'RowName',     {}, ...
    'Position',    [20 80 980 200], ...
    'FontSize',    12, ...
    'ColumnWidth', {75, 90, 70, 70, 85, 85, 80, 70, 75, 75, 75, 65});

verde    = uistyle('BackgroundColor',[0.75 1.00 0.75]);
amarillo = uistyle('BackgroundColor',[1.00 1.00 0.60]);
rojo     = uistyle('BackgroundColor',[1.00 0.70 0.70]);

for i = 1:2
    aplicar_color(uitbl, resultados{i,11}, i, 2, verde, amarillo, rojo)  % RMSE
    aplicar_color(uitbl, resultados{i,12}, i, 3, verde, amarillo, rojo)  % r
    aplicar_color(uitbl, resultados{i,13}, i, 4, verde, amarillo, rojo)  % %±1SD
    aplicar_color(uitbl, resultados{i,15}, i, 7, verde, amarillo, rojo)  % ΔROM
    aplicar_color(uitbl, resultados{i,16}, i, 8, verde, amarillo, rojo)  % CMC
    aplicar_color(uitbl, resultados{i,17}, i, 9, verde, amarillo, rojo)  % ICC
end

%% LEYENDA
leyendaData = {
    'RMSE_{norm}', '< 1',      '1 – 1.5',    '1.5 – 2',    '> 2';
    'r',           '> 0.9',    '0.8 – 0.9',  '0.7 – 0.8',  '< 0.7';
    '% ±1SD',      '> 85',     '75 – 85',    '65 – 75',    '< 65';
    '\DeltaROM',   '|Δ| ≤ 1°', '|Δ| ≤ 2°',   '|Δ| ≤ 3°',   '|Δ| > 3°';
    'CMC',         '> 0.95',   '0.85 – 0.95','0.75 – 0.85','< 0.75';
    'ICC(3,1)',    '> 0.90',   '0.75 – 0.90','0.50 – 0.75','< 0.50'};

figLeyenda = uifigure('Name','Interpretation Criteria','Position',[100 30 860 230]);

uilabel(figLeyenda,'Text','Excellent', ...
    'Position',[178 195 160 22],'FontWeight','bold', ...
    'BackgroundColor',[0.75 1.00 0.75],'HorizontalAlignment','center');
uilabel(figLeyenda,'Text','Good', ...
    'Position',[338 195 160 22],'FontWeight','bold', ...
    'BackgroundColor',[0.75 1.00 0.75],'HorizontalAlignment','center');
uilabel(figLeyenda,'Text','Acceptable', ...
    'Position',[498 195 160 22],'FontWeight','bold', ...
    'BackgroundColor',[1.00 1.00 0.60],'HorizontalAlignment','center');
uilabel(figLeyenda,'Text','Poor', ...
    'Position',[658 195 160 22],'FontWeight','bold', ...
    'BackgroundColor',[1.00 0.70 0.70],'HorizontalAlignment','center');

tLey = uitable(figLeyenda, ...
    'Data',       leyendaData, ...
    'ColumnName', {'Metric','Excellent','Good','Acceptable','Poor'}, ...
    'ColumnWidth',{100, 160, 160, 160, 160}, ...
    'FontSize',   11, ...
    'Position',   [10 10 830 182]);

verde_ley    = uistyle('BackgroundColor',[0.75 1.00 0.75]);
amarillo_ley = uistyle('BackgroundColor',[1.00 1.00 0.60]);
rojo_ley     = uistyle('BackgroundColor',[1.00 0.70 0.70]);
for row = 1:6
    addStyle(tLey, verde_ley,    'cell', [row 2])
    addStyle(tLey, verde_ley,    'cell', [row 3])
    addStyle(tLey, amarillo_ley, 'cell', [row 4])
    addStyle(tLey, rojo_ley,     'cell', [row 5])
end

%% ===================================================
% FUNCIONES
%% ===================================================

function fila = calcular_estadistica(sim, exp, error_total, error_norm, sd, idx, fase, trials)
x = sim(idx);
y = exp(idx);

RMSE_norm = sqrt(mean((error_norm(idx)).^2));
ROM_sim   = max(x) - min(x);
ROM_exp   = max(y) - min(y);
delta_ROM = ROM_sim - ROM_exp;

CMC_val = sqrt(1 - sum((x-y).^2) / sum((y-mean(y)).^2));
ICC_val = calcular_icc31(trials);

xm = mean(x); ym = mean(y);
r  = sum((x-xm).*(y-ym)) / sqrt(sum((x-xm).^2)*sum((y-ym).^2));

porc_1sd = sum(abs(error_total(idx)) <= sd(idx)) / length(x) * 100;

nivel_rmse   = clasificar_rmse(RMSE_norm);
nivel_r      = clasificar_r(abs(r));
nivel_sd     = clasificar_sd(porc_1sd);
nivel_global = max([nivel_rmse nivel_r nivel_sd]);
clas_global  = texto_nivel(nivel_global);

nivel_rom = clasificar_rom(delta_ROM);
nivel_cmc = clasificar_cmc(CMC_val);
nivel_icc = clasificar_icc(ICC_val);

fila = {char(fase), RMSE_norm, r, porc_1sd, char(clas_global), ...
        ROM_sim, ROM_exp, delta_ROM, CMC_val, ICC_val, ...
        nivel_rmse, nivel_r, nivel_sd, nivel_global, ...
        nivel_rom, nivel_cmc, nivel_icc};
end

function nivel = clasificar_rmse(v)
    if v < 1, nivel=1; elseif v<1.5, nivel=2; elseif v<2, nivel=3; else, nivel=4; end
end
function nivel = clasificar_r(v)
    if v>0.9, nivel=1; elseif v>0.8, nivel=2; elseif v>0.7, nivel=3; else, nivel=4; end
end
function nivel = clasificar_sd(v)
    if v>85, nivel=1; elseif v>75, nivel=2; elseif v>65, nivel=3; else, nivel=4; end
end
function txt = texto_nivel(n)
    switch n; case 1, txt='Excelente'; case 2, txt='Buena';
              case 3, txt='Aceptable'; case 4, txt='Deficiente'; end
end
function aplicar_color(tbl, nivel, fila, col, verde, amarillo, rojo)
    switch nivel
        case {1,2}, addStyle(tbl, verde,    'cell',[fila col])
        case 3,     addStyle(tbl, amarillo, 'cell',[fila col])
        case 4,     addStyle(tbl, rojo,     'cell',[fila col])
    end
end
function nivel = clasificar_rom(v)
    if v>=-1&&v<=1, nivel=1; elseif abs(v)<=2, nivel=2;
    elseif abs(v)<=3, nivel=3; else, nivel=4; end
end
function nivel = clasificar_cmc(v)
    if v>0.95, nivel=1; elseif v>0.85, nivel=2; elseif v>0.75, nivel=3; else, nivel=4; end
end
function nivel = clasificar_icc(v)
    if v>0.90, nivel=1; elseif v>0.75, nivel=2; elseif v>0.50, nivel=3; else, nivel=4; end
end

function icc_val = calcular_icc31(trials)
    % ICC(3,1) — Modelo mixto dos vías, acuerdo absoluto
    % Koo & Mae (2016), J Chiropr Med
    [n, k]     = size(trials);
    grand_mean = mean(trials(:));
    row_means  = mean(trials, 2);
    col_means  = mean(trials, 1);
    SS_rows  = k * sum((row_means - grand_mean).^2);
    SS_cols  = n * sum((col_means  - grand_mean).^2);
    SS_total = sum((trials(:)     - grand_mean).^2);
    SS_error = SS_total - SS_rows - SS_cols;
    MS_rows  = SS_rows  / (n - 1);
    MS_error = SS_error / ((n-1)*(k-1));
    icc_val  = (MS_rows - MS_error) / (MS_rows + (k-1)*MS_error);
end