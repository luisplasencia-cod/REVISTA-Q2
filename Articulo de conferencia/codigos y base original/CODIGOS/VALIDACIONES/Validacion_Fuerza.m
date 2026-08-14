% ===================================================
% PROTOCOLO DE VALIDACIÓN  FUERZA
% VALIDACION FUERZA 
% ===================================================

clear
clc
close all
close all force
delete(findall(0,'Type','figure','-and','WindowStyle','normal'))

%% CONFIGURACIÓN
fs_sim = 120;        
fcorte_cinematica = 6;     

%% =======================
% CARGA BASE DE DATOS
%% =======================

[file_bd,path_bd] = uigetfile('*.mat','Seleccione BaseDatos_Rodilla.mat');
datosBD = load(fullfile(path_bd,file_bd));

rodilla_exp_norm = datosBD.media(:);
sd_exp           = datosBD.sd(:);
eje_norm         = datosBD.x_ref(:);

%% =======================
% SEGUNDA BASE DE DATOS (REFERENCIA 2)
%% =======================

[file_bd2,path_bd2] = uigetfile('*.mat','Seleccione segunda base de datos (.mat)');
datosBD2 = load(fullfile(path_bd2,file_bd2));

rodilla_exp_norm2 = datosBD2.media(:);
sd_exp2           = datosBD2.sd(:);

%% =======================
% CARGA 5 ENSAYOS (.TXT - FUERZA VERTICAL)
%% =======================

% -------- Parámetros --------
fs           = 1000;
dt           = 1/fs;
respuesta = inputdlg('Ingrese el peso corporal simulado (kg):', ...
                     'Peso Corporal', 1, {'80'});
if isempty(respuesta)
    error('No se ingresó el peso corporal. Ejecución cancelada.');
end
BW_kg = str2double(respuesta{1});
if isnan(BW_kg) || BW_kg <= 0
    error('Peso inválido ingresado: "%s". Debe ser un número positivo.', respuesta{1});
end
BW_N = BW_kg * 9.81;
fc           = 15;
orden        = 4;
umbral_N     = 20;
min_muestras = 20;

[b,a] = butter(orden, fc/(fs/2), 'low');



% -------- Selección múltiple inicial --------
[files_sim, path_sim] = uigetfile('*.txt', ...
    'Seleccione los ensayos .txt (puede elegir varios)', ...
    'MultiSelect', 'on');

if isequal(files_sim, 0)
    error('Carga cancelada por el usuario.');
end

if ischar(files_sim)
    files_sim = {files_sim};
end

n_archivos = numel(files_sim);
n_pts      = sum(eje_norm <= 60);

% Guardar señales para Ventana 1 (tamaño = archivos seleccionados)
raw_cell    = cell(1, n_archivos);
filt_cell   = cell(1, n_archivos);
filt_N_cell = cell(1, n_archivos);
t_cell      = cell(1, n_archivos);
trials_norm = nan(n_pts, n_archivos);   % NaN = se descartan al final

k = 0;  % contador de ensayos VÁLIDOS aceptados

for idx_archivo = 1:n_archivos

    file_sim = files_sim{idx_archivo};

    data_sim = readmatrix(fullfile(path_sim, file_sim));
    Fz_raw   = data_sim(:,3);
    N        = length(Fz_raw);
    t_s      = (0:N-1)*dt;

    % PASO 1: Conversión lbf → N
    if max(Fz_raw) < 500
        Fz_raw = Fz_raw * 4.44822;
    end

    % PASO 2: Remoción de offset
    offset_k = mean(Fz_raw(1:100));
    Fz_N     = Fz_raw - offset_k;

    % PASO 3: Filtrado
    Fz_filt_N = filtfilt(b, a, Fz_N);

    % PASO 4: Detección IC
    idx_IC = [];
    for k2 = 2:length(Fz_filt_N)-min_muestras
        if Fz_filt_N(k2-1) < umbral_N && Fz_filt_N(k2) >= umbral_N
            if all(Fz_filt_N(k2:k2+min_muestras-1) >= umbral_N)
                t_cruce = (k2-1) + (umbral_N - Fz_filt_N(k2-1)) / ...
                                    (Fz_filt_N(k2) - Fz_filt_N(k2-1));
                idx_IC = round(t_cruce);
                break
            end
        end
    end
    if isempty(idx_IC)
        for k2 = 1:length(Fz_filt_N)-min_muestras
            if Fz_filt_N(k2) > umbral_N && Fz_filt_N(k2-1) <= umbral_N
                if all(Fz_filt_N(k2:k2+min_muestras-1) > umbral_N)
                    t_cruce = (k2-1) + (umbral_N - Fz_filt_N(k2-1)) / ...
                                        (Fz_filt_N(k2) - Fz_filt_N(k2-1));
                    idx_IC = round(t_cruce);
                    break
                end
            end
        end
    end

    % PASO 5: Detección TO
    idx_TO = [];
    if ~isempty(idx_IC)
        for k2 = idx_IC+1:length(Fz_filt_N)-min_muestras
            if Fz_filt_N(k2-1) >= umbral_N && Fz_filt_N(k2) < umbral_N
                if all(Fz_filt_N(k2:k2+min_muestras-1) < umbral_N)
                    t_cruce = (k2-1) + (umbral_N - Fz_filt_N(k2-1)) / ...
                                        (Fz_filt_N(k2) - Fz_filt_N(k2-1));
                    idx_TO = round(t_cruce);
                    break
                end
            end
        end
    end

    % PASO 6–8: Recorte, normalización %BW y criterios de calidad
    valido        = true;
    razon_rechazo = '';

    if isempty(idx_IC) || isempty(idx_TO)
        valido        = false;
        razon_rechazo = 'No se detectó IC o TO';
    else
        Fz_recorte_N = Fz_filt_N(idx_IC:idx_TO);
        duracion_ms  = (idx_TO - idx_IC) * dt * 1000;
        Fz_apoyo     = (Fz_recorte_N / BW_N) * 100;

        if duracion_ms < 300
            valido        = false;
            razon_rechazo = sprintf('Duración %.0f ms < 300 ms', duracion_ms);
        elseif length(Fz_apoyo) < 50
            valido        = false;
            razon_rechazo = sprintf('Longitud %d pts < 50', length(Fz_apoyo));
        elseif max(Fz_apoyo) < 80
            valido        = false;
            razon_rechazo = sprintf('Pico máximo %.1f %%BW < 80', max(Fz_apoyo));
        else
            [pks,~] = findpeaks(Fz_apoyo);
            if length(pks) < 2
                valido        = false;
                razon_rechazo = sprintf('Solo %d pico(s) detectado(s), se requieren ≥2', length(pks));
            else
                margen     = round(length(Fz_apoyo) * 0.05);
                zona_media = Fz_apoyo(margen:end-margen);
                umbral_BW  = (umbral_N / BW_N) * 100;
                if any(zona_media < umbral_BW)
                    valido        = false;
                    razon_rechazo = 'Señal cae por debajo del umbral en zona media';
                end
            end
        end
    end

    % ---- Resultado de la validación ----
    if ~valido
        fprintf('Archivo "%s" DESCARTADO. Motivo: %s\n', file_sim, razon_rechazo);
        continue   % simplemente se salta, no pide reemplazo
    end

    % ---- Ensayo válido: guardar ----
    k = k + 1;
    fprintf('Ensayo %d aceptado: %s  (dur=%.0fms, pico=%.1f%%BW)\n', ...
            k, file_sim, duracion_ms, max(Fz_apoyo));

    t_norm60 = linspace(0, 60, length(Fz_apoyo));
    trials_norm(:,k) = interp1(t_norm60, Fz_apoyo, ...
                               eje_norm(eje_norm <= 60), 'pchip');

    raw_cell{k}     = Fz_N;
    filt_cell{k}    = Fz_filt_N;
    filt_N_cell{k}  = Fz_filt_N;
    t_cell{k}       = t_s;
end

n_ensayos = k;   % número final = solo los válidos

if n_ensayos == 0
    error('Ningún archivo seleccionado pasó los criterios de validación.');
end

% Recortar las estructuras al tamaño real de ensayos válidos
raw_cell    = raw_cell(1:n_ensayos);
filt_cell   = filt_cell(1:n_ensayos);
filt_N_cell = filt_N_cell(1:n_ensayos);
t_cell      = t_cell(1:n_ensayos);
trials_norm = trials_norm(:,1:n_ensayos);
% Aquí trials_norm tiene exactamente 5 columnas válidas, sin NaN
rodilla_sim_norm = mean(trials_norm, 2);
sd_sim           = std(trials_norm, 0, 2);
ensayos_validos  = true(1, n_ensayos);   % todos son válidos por construcción
%% =================================================== 
% VENTANA 1 – PROCESO DEL SIMULADOR
%% ===================================================

colores_trials = lines(n_ensayos);

figure('Name','Proceso del Simulador','NumberTitle','off', ...
       'Position',[50 50 1500 750])
tiledlayout(2, 4, 'TileSpacing','compact','Padding','compact')

titles = {
    'Fz Cruda (N)'
    'Fz Normalizada (%BW)'
    'Fz Filtrada (%BW)'
    'Contacto Inicial (IC)'
    'Fin de Apoyo (TO)'
    'Recorte IC–TO'
    'Normalizado 0–60%'
    '5 Ensayos + Media Interpolada'
};

for k = 1:8
    nexttile(k)
    hold on
    grid on
    title(titles{k})
end

% -------- Paneles 1–7: todos los ensayos superpuestos --------

% 1. Señal cruda
nexttile(1)
for k = 1:n_ensayos
    plot(t_cell{k}, raw_cell{k}, '-', ...
         'Color',[colores_trials(k,:) 0.5], 'LineWidth',1)
end
xlabel('Tiempo (s)'), ylabel('N')

% 2. Normalizada (%BW)
nexttile(2)
for k = 1:n_ensayos
    Fz_pct_k = raw_cell{k};
    plot(t_cell{k}, Fz_pct_k, '-', ...
         'Color',[colores_trials(k,:) 0.5], 'LineWidth',1)
end
xlabel('Tiempo (s)'), ylabel('N')

% 3. Filtrada
nexttile(3)
for k = 1:n_ensayos
    plot(t_cell{k}, filt_cell{k}, '-', ...
         'Color',[colores_trials(k,:) 0.5], 'LineWidth',1)
end
xlabel('Tiempo (s)'), ylabel('N')

% 4. IC — marcador en cada ensayo
% 4. IC — marcador en cada ensayo
nexttile(4)
for k = 1:n_ensayos
    plot(t_cell{k}, filt_cell{k}, '-', ...
         'Color',[colores_trials(k,:) 0.4], 'LineWidth',1)
end
yline(umbral_N,'--r','LineWidth',1.5)
for k = 1:n_ensayos
    Fz_k = filt_N_cell{k};
    t_k  = t_cell{k};
    ic_k = [];
    for k2 = 2:length(Fz_k)-min_muestras
        if Fz_k(k2-1) < umbral_N && Fz_k(k2) >= umbral_N
            if all(Fz_k(k2:k2+min_muestras-1) >= umbral_N)
                tc = (k2-1) + (umbral_N - Fz_k(k2-1))/(Fz_k(k2)-Fz_k(k2-1));
                ic_k = round(tc); break
            end
        end
    end
    if ~isempty(ic_k)
        plot(t_k(ic_k), umbral_N, 'o', ...
             'Color', colores_trials(k,:), 'LineWidth', 2, 'MarkerSize', 6)
    end
end
xlabel('Tiempo (s)'), ylabel('N')

% 5. TO — marcador en cada ensayo
nexttile(5)
for k = 1:n_ensayos
    plot(t_cell{k}, filt_cell{k}, '-', ...
         'Color',[colores_trials(k,:) 0.4], 'LineWidth',1)
end
yline(umbral_N,'--r','LineWidth',1.5)
for k = 1:n_ensayos
    Fz_k = filt_N_cell{k};
    t_k  = t_cell{k};
    ic_k = [];
    for k2 = 2:length(Fz_k)-min_muestras
        if Fz_k(k2-1) < umbral_N && Fz_k(k2) >= umbral_N
            if all(Fz_k(k2:k2+min_muestras-1) >= umbral_N)
                tc = (k2-1) + (umbral_N - Fz_k(k2-1))/(Fz_k(k2)-Fz_k(k2-1));
                ic_k = round(tc); break
            end
        end
    end
    to_k = [];
    if ~isempty(ic_k)
        for k2 = ic_k+1:length(Fz_k)-min_muestras
            if Fz_k(k2-1) >= umbral_N && Fz_k(k2) < umbral_N
                if all(Fz_k(k2:k2+min_muestras-1) < umbral_N)
                    tc = (k2-1) + (umbral_N - Fz_k(k2-1))/(Fz_k(k2)-Fz_k(k2-1));
                    to_k = round(tc); break
                end
            end
        end
    end
    if ~isempty(to_k)
        plot(t_k(to_k), umbral_N, 's', ...
             'Color', colores_trials(k,:), 'LineWidth', 2, 'MarkerSize', 6)
    end
end
xlabel('Tiempo (s)'), ylabel('N')

% 6. Recorte IC–TO de cada ensayo
% 6. Recorte IC–TO de cada ensayo
nexttile(6)
for k = 1:n_ensayos
    Fz_k = filt_N_cell{k};
    t_k  = t_cell{k};
    ic_k = [];
    for k2 = 2:length(Fz_k)-min_muestras
        if Fz_k(k2-1) < umbral_N && Fz_k(k2) >= umbral_N
            if all(Fz_k(k2:k2+min_muestras-1) >= umbral_N)
                tc = (k2-1) + (umbral_N - Fz_k(k2-1))/(Fz_k(k2)-Fz_k(k2-1));
                ic_k = round(tc); break
            end
        end
    end
    to_k = [];
    if ~isempty(ic_k)
        for k2 = ic_k+1:length(Fz_k)-min_muestras
            if Fz_k(k2-1) >= umbral_N && Fz_k(k2) < umbral_N
                if all(Fz_k(k2:k2+min_muestras-1) < umbral_N)
                    tc = (k2-1) + (umbral_N - Fz_k(k2-1))/(Fz_k(k2)-Fz_k(k2-1));
                    to_k = round(tc); break
                end
            end
        end
    end
    if ~isempty(ic_k) && ~isempty(to_k)
        plot(t_k(ic_k:to_k), Fz_k(ic_k:to_k), '-', ...
             'Color', colores_trials(k,:), 'LineWidth', 1.4)
    end
end
xlabel('Tiempo (s)'), ylabel('N')

% 7. Normalización 0–60% de cada ensayo
% 7. Normalización 0–60% de cada ensayo
nexttile(7)
for k = 1:n_ensayos
    Fz_k = filt_N_cell{k};
    ic_k = [];
    for k2 = 2:length(Fz_k)-min_muestras
        if Fz_k(k2-1) < umbral_N && Fz_k(k2) >= umbral_N
            if all(Fz_k(k2:k2+min_muestras-1) >= umbral_N)
                tc = (k2-1) + (umbral_N - Fz_k(k2-1))/(Fz_k(k2)-Fz_k(k2-1));
                ic_k = round(tc); break
            end
        end
    end
    to_k = [];
    if ~isempty(ic_k)
        for k2 = ic_k+1:length(Fz_k)-min_muestras
            if Fz_k(k2-1) >= umbral_N && Fz_k(k2) < umbral_N
                if all(Fz_k(k2:k2+min_muestras-1) < umbral_N)
                    tc = (k2-1) + (umbral_N - Fz_k(k2-1))/(Fz_k(k2)-Fz_k(k2-1));
                    to_k = round(tc); break
                end
            end
        end
    end
    if ~isempty(ic_k) && ~isempty(to_k)
        Fz_ap_k  = (Fz_k(ic_k:to_k) / BW_N) * 100;
        t_norm_k = linspace(0, 60, length(Fz_ap_k));
        plot(t_norm_k, Fz_ap_k, '-', ...
             'Color', colores_trials(k,:), 'LineWidth', 1.4)
    end
end
xlabel('% Ciclo de Marcha'), ylabel('%BW')
% 8. 5 ensayos interpolados + media
nexttile(8)
eje_ap = eje_norm(eje_norm <= 60);
for k = 1:n_ensayos
    plot(eje_ap, trials_norm(:,k), '-', ...
         'Color',[colores_trials(k,:) 0.45], 'LineWidth',1)
end
plot(eje_ap, rodilla_sim_norm, 'k-', 'LineWidth',2.2)
legend([arrayfun(@(k)sprintf('E%d',k),1:n_ensayos,'UniformOutput',false), ...
        {'Media'}], 'Location','best','FontSize',7)
xlabel('% Ciclo de Marcha'), ylabel('%BW')

%% ===================================================
% VENTANA 2 – VALIDACIÓN PRIMARIA
%% ===================================================

idx_apoyo    = eje_norm <= 60;
idx_balanceo = false(size(eje_norm));

figure('Name','Validacion Primaria','NumberTitle','off')
tiledlayout(2,2)

nexttile
plot(eje_norm(idx_apoyo), rodilla_sim_norm,'r','LineWidth',2)
title('Señal Media Normalizada Final')
xlabel('Porcentaje Ciclo de Marcha (%)')
ylabel('%BW')
grid on

nexttile
x_fill = [eje_norm(idx_apoyo)', fliplr(eje_norm(idx_apoyo)')];
y_fill = [(rodilla_exp_norm(idx_apoyo)+sd_exp(idx_apoyo))', ...
           fliplr((rodilla_exp_norm(idx_apoyo)-sd_exp(idx_apoyo))')];
fill(x_fill, y_fill, [0.9 0.9 0.9],'EdgeColor','none'); hold on
plot(eje_norm(idx_apoyo), rodilla_exp_norm(idx_apoyo),'k','LineWidth',2)
plot(eje_norm(idx_apoyo), rodilla_sim_norm,            'r--','LineWidth',2)
title('Fase Apoyo (0–60%)')
xlabel('Porcentaje Ciclo de Marcha (%)')
ylabel('%BW')
legend({'±1SD Ref1','Ref1','Simulador (media)'},'Location','best')
grid on

nexttile
x_fill = [eje_norm(idx_apoyo)', fliplr(eje_norm(idx_apoyo)')];
y_fill = [(rodilla_exp_norm2(idx_apoyo)+sd_exp2(idx_apoyo))', ...
           fliplr((rodilla_exp_norm2(idx_apoyo)-sd_exp2(idx_apoyo))')];
fill(x_fill, y_fill, [0.85 0.85 1],'EdgeColor','none'); hold on
plot(eje_norm(idx_apoyo), rodilla_exp_norm2(idx_apoyo),'b','LineWidth',2)
plot(eje_norm(idx_apoyo), rodilla_sim_norm,             'r--','LineWidth',2)
title('Fase Apoyo (Referencia 2)')
xlabel('Porcentaje Ciclo de Marcha (%)')
ylabel('%BW')
legend({'±1SD Ref2','Ref2','Simulador (media)'},'Location','best')
grid on

nexttile
hold on
x_fill = [eje_norm(idx_apoyo)', fliplr(eje_norm(idx_apoyo)')];
y1 = [(rodilla_exp_norm(idx_apoyo)+sd_exp(idx_apoyo))', ...
       fliplr((rodilla_exp_norm(idx_apoyo)-sd_exp(idx_apoyo))')];
y2 = [(rodilla_exp_norm2(idx_apoyo)+sd_exp2(idx_apoyo))', ...
       fliplr((rodilla_exp_norm2(idx_apoyo)-sd_exp2(idx_apoyo))')];
fill(x_fill, y1, [0.9 0.9 0.9],'EdgeColor','none')
fill(x_fill, y2, [0.8 0.8 1],  'EdgeColor','none','FaceAlpha',0.5)
plot(eje_norm(idx_apoyo), rodilla_exp_norm(idx_apoyo), 'k',   'LineWidth',2)
plot(eje_norm(idx_apoyo), rodilla_exp_norm2(idx_apoyo),'b',   'LineWidth',2)
plot(eje_norm(idx_apoyo), rodilla_sim_norm,             'r--','LineWidth',2)
title('Comparación Global (2 Referencias)')
xlabel('Porcentaje Ciclo de Marcha (%)')
ylabel('%BW')
legend({'SD Ref1','SD Ref2','Ref1','Ref2','Simulador (media)'},'Location','best')
grid on

%% =======================
% VALIDACIÓN ESTADÍSTICA
%% =======================
idx_apoyo    = eje_norm <= 60;
idx_balanceo = eje_norm > 60;

error_total  = rodilla_sim_norm - rodilla_exp_norm;
error_norm_v = error_total ./ sd_exp;
resultados   = cell(2, 17);

% BD1
resultados(1,:) = calcular_estadistica( ...
    rodilla_sim_norm, rodilla_exp_norm, ...
    error_total, error_norm_v, sd_exp, ...
    idx_apoyo, "Apoyo BD1", trials_norm);

% BD2
error_total_2  = rodilla_sim_norm - rodilla_exp_norm2;
error_norm_v2  = error_total_2 ./ sd_exp2;

resultados(2,:) = calcular_estadistica( ...
    rodilla_sim_norm, rodilla_exp_norm2, ...
    error_total_2, error_norm_v2, sd_exp2, ...
    idx_apoyo, "Apoyo BD2", trials_norm);

%% =======================
% VENTANA 3 - TABLA ESTADÍSTICA
%% =======================
fig2 = uifigure('Name','Validación Estadística - Fuerza', ...
                'Position',[100 100 1020 340]);

tabla_visual = cell(2, 12);
for i = 1:2
    tabla_visual{i,1} = char(resultados{i,1});
    tabla_visual{i,2} = double(resultados{i,2});
    tabla_visual{i,3} = double(resultados{i,3});
    tabla_visual{i,4} = double(resultados{i,4});
    tabla_visual{i,5} = double(resultados{i,6});
    tabla_visual{i,6} = double(resultados{i,7});
    tabla_visual{i,7} = double(resultados{i,8});
    tabla_visual{i,8} = double(resultados{i,9});
    tabla_visual{i,9} = double(resultados{i,10});
    % Fuerza no tiene tiempos de fase — se deja vacío
    tabla_visual{i,10} = 0;
    tabla_visual{i,11} = 0;
    tabla_visual{i,12} = 0;
end

fmt_metricas = '%.4f';

columnas = {'Phase', 'RMSE_{norm}', 'r', '% ±1SD', ...
            'ROM_{sim} (%BW)', 'ROM_{exp} (%BW)', '\DeltaROM (%BW)', ...
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
    tabla_fmt{i,10} = '—';
    tabla_fmt{i,11} = '—';
    tabla_fmt{i,12} = '—';
end

uitbl = uitable(fig2, ...
    'Data',        tabla_fmt, ...
    'ColumnName',  columnas, ...
    'RowName',     {}, ...
    'Position',    [20 80 980 200], ...
    'FontSize',    12, ...
    'ColumnWidth', {80, 90, 70, 70, 95, 95, 85, 70, 75, 70, 70, 65});

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
    '\DeltaROM',   '|Δ| ≤ 1',  '|Δ| ≤ 2',    '|Δ| ≤ 3',    '|Δ| > 3';
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