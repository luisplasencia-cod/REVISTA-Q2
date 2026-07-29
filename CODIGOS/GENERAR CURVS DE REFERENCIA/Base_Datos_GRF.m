clc
clear
close all

%% ================== PARÁMETROS ==================
fs          = 1000;              % Frecuencia de muestreo (Hz)
dt          = 1/fs;
fc          = 15;                % Frecuencia de corte Butterworth (Hz)
orden       = 4;                 % Orden del filtro
umbral_N    = 20;                % Umbral IC/TO en Newtons (Tirosh & Sparrow, 2003)
min_muestras = 20;               % Ventana mínima para TO robusto (20 ms)

[b,a] = butter(orden, fc/(fs/2), 'low');

%% ================== SELECCIÓN MÚLTIPLE DE CARPETAS ==================
carpetas  = {};
BW_lista  = [];
seguir    = true;

while seguir

    folder = uigetdir(pwd, 'Selecciona una carpeta con archivos TXT');
    if folder == 0
        error('No se seleccionó carpeta');
    end
    carpetas{end+1} = folder;

    prompt   = {'Ingrese el peso del sujeto (kg):'};
    dlgtitle = 'Peso del sujeto';
    dims     = [1 35];
    definput = {'70'};
    answer   = inputdlg(prompt, dlgtitle, dims, definput);
    if isempty(answer)
        error('No se ingresó el peso');
    end
    BW_lista(end+1) = str2double(answer{1});

    opcion = questdlg('¿Deseas agregar otra base de datos?', ...
                      'Continuar', 'Sí','No','No');
    if strcmp(opcion,'No')
        seguir = false;
    end

end

%% ================== FIGURA 2x4 (7 gráficas activas) ==================
% Nueva lógica de gráficas:
% 1: Fz Cruda (N)
% 2: Fz Filtrada (N)
% 3: Detección IC/TO con línea 20 N
% 4: Recorte IC–TO (N)
% 5: Recorte normalizado (%BW)
% 6: Normalizado 0–60% ciclo
% 7: Curva Promedio ± SD (Base Normativa)
% 8: (vacío)

figure('Name','Pipeline Completo - Fuerza Vertical','NumberTitle','off')
tiledlayout(2,4)

titles = {
    'Fz Cruda (N)'
    'Fz Filtrada (N)'
    'Detección IC/TO — Umbral 20 N'
    'Recorte IC–TO (N)'
    'Recorte Normalizado (%BW)'
    'Normalizado 0–60% Ciclo'
    'Curva Promedio ± SD (Base Normativa)'
};

for k = 1:7
    nexttile(k)
    hold on
    grid on
    title(titles{k})
end

%% ================== BASE NORMATIVA ==================
x_ref           = linspace(0,60,61);
matriz_apoyos   = [];
duraciones_ms   = [];
nombres_archivos = {};

%% ================== LOOP PRINCIPAL ==================
for c = 1:length(carpetas)

    folder = carpetas{c};
    BW_kg  = BW_lista(c);
    BW_N   = BW_kg * 9.81;

    files = dir(fullfile(folder, '*.txt'));
    if isempty(files)
        warning(['No hay archivos en: ' folder]);
        continue
    end

    for i = 1:length(files)

        filename = fullfile(folder, files(i).name);
        data     = readmatrix(filename);
        Fz       = data(:,3);

        % ---- Detección automática de unidades ----
        if max(Fz) < 500        % probable lbf → convertir a N
            Fz = Fz * 4.44822;
        end

        N = length(Fz);
        t = (0:N-1)*dt;

        % ---- PASO 1: Filtrar en Newtons ----
        Fz_filt_N = filtfilt(b, a, Fz);

        % ---- PASO 2: Detectar IC en Newtons ----
        % ---- Detectar IC: buscar subida pronunciada y retroceder a cruce 20N ----
        idx_IC = [];
        pendiente_min = 50;          % N en 10 ms mínimo para considerar subida real
        n_pendiente   = round(0.01 * fs);   % 10 ms
        
        for k2 = 1:length(Fz_filt_N)-n_pendiente
            % Condición 1: pendiente pronunciada aquí
            pendiente = Fz_filt_N(k2 + n_pendiente) - Fz_filt_N(k2);
            if pendiente > pendiente_min
                % Condición 2: retroceder hasta cruce de 20 N
                idx_cruce = k2;
                for k3 = k2:-1:1
                    if Fz_filt_N(k3) < umbral_N
                        idx_cruce = k3 + 1;
                        break
                    end
                end
                % Condición 3: ventana sostenida desde el cruce
                if idx_cruce + min_muestras <= length(Fz_filt_N)
                    ventana_IC = Fz_filt_N(idx_cruce:idx_cruce+min_muestras-1);
                    if all(ventana_IC > umbral_N)
                        idx_IC = idx_cruce;
                        break
                    end
                end
            end
        end

        % ---- PASO 3: Detectar TO robusto en Newtons ----
        idx_TO = [];
        if ~isempty(idx_IC)
            for k2 = idx_IC : length(Fz_filt_N)-min_muestras
                if Fz_filt_N(k2) < umbral_N
                    ventana = Fz_filt_N(k2 : k2+min_muestras-1);
                    if all(ventana < umbral_N)
                        idx_TO = k2;
                        break
                    end
                end
            end
        end

        % ---- Gráfica 1: Fz cruda en N ----
        nexttile(1)
        plot(t, Fz)
        xlabel('Tiempo (s)'), ylabel('N')

        % ---- Gráfica 2: Fz filtrada en N ----
        nexttile(2)
        plot(t, Fz_filt_N)
        xlabel('Tiempo (s)'), ylabel('N')

        % ---- Gráfica 3: Detección IC/TO con umbral 20 N ----
        nexttile(3)
        plot(t, Fz_filt_N)
        yline(umbral_N, '--r', '20 N')
        if ~isempty(idx_IC)
            plot(t(idx_IC), Fz_filt_N(idx_IC), 'go', 'LineWidth', 2, 'DisplayName','IC')
        end
        if ~isempty(idx_TO)
            plot(t(idx_TO), Fz_filt_N(idx_TO), 'ro', 'LineWidth', 2, 'DisplayName','TO')
        end
        xlabel('Tiempo (s)'), ylabel('N')

        if ~isempty(idx_IC) && ~isempty(idx_TO)

            % ---- PASO 4: Recorte en Newtons ----
            Fz_recorte_N = Fz_filt_N(idx_IC:idx_TO);
            t_apoyo      = t(idx_IC:idx_TO);

            % ---- Duración de apoyo ----
            duracion_seg = (idx_TO - idx_IC) * dt;
            duracion_ms  = duracion_seg * 1000;

            % ---- Gráfica 4: Recorte en N ----
            nexttile(4)
            plot(t_apoyo, Fz_recorte_N, 'LineWidth', 2)
            xlabel('Tiempo (s)'), ylabel('N')

            % ---- PASO 5: Normalizar recorte a %BW ----
            Fz_apoyo = (Fz_recorte_N / BW_N) * 100;

            % ---- Validación de calidad sobre señal en %BW ----
            valido = true;

            if duracion_ms < 300
                valido = false;
            end
            if length(Fz_apoyo) < 50
                valido = false;
            end
            if max(Fz_apoyo) < 80
                valido = false;
            end
            [pks, ~] = findpeaks(Fz_apoyo);
            if length(pks) < 2
                valido = false;
            end
            % 5. Verificar continuidad: la señal no debe caer bajo umbral en zona media
            % Excluye el 5% inicial y final para no penalizar flancos de subida/bajada
            margen = round(length(Fz_apoyo) * 0.05);
            zona_media = Fz_apoyo(margen:end-margen);
            umbral_BW = (umbral_N / BW_N) * 100;   % convertir 20N a %BW para comparar
            
            if any(zona_media < umbral_BW)
                valido = false;
            end
            if ~valido
                fprintf('Archivo %s descartado por mala calidad\n', files(i).name);
                continue
            end

            % ---- Guardar duración válida ----
            duraciones_ms        = [duraciones_ms; duracion_ms];
            nombres_archivos{end+1} = files(i).name;

            % ---- Gráfica 5: Recorte normalizado %BW ----
            nexttile(5)
            plot(t_apoyo, Fz_apoyo, 'LineWidth', 2)
            xlabel('Tiempo (s)'), ylabel('%BW')

            % ---- PASO 6: Normalización temporal 0–60% ----
            t_norm60  = linspace(0, 60, length(Fz_apoyo));

            % ---- Gráfica 6: Normalizado 0–60% ----
            nexttile(6)
            plot(t_norm60, Fz_apoyo, 'LineWidth', 2)
            xlabel('% Ciclo de Marcha'), ylabel('%BW')

            % ---- Interpolación a 61 puntos para matriz normativa ----
            Fz_interp     = interp1(t_norm60, Fz_apoyo, x_ref, 'linear');
            matriz_apoyos = [matriz_apoyos; Fz_interp];

        end

    end
end

%% ================== GRÁFICA 7: Curva Promedio ± SD ==================
if ~isempty(matriz_apoyos)

    media = mean(matriz_apoyos, 1);
    sd    = std(matriz_apoyos, 0, 1);

    nexttile(7)
    fill([x_ref fliplr(x_ref)], ...
         [media+sd fliplr(media-sd)], ...
         [0.85 0.85 0.85], 'EdgeColor','none')
    hold on
    plot(x_ref, media, 'k', 'LineWidth', 2)
    xlabel('% Ciclo de Marcha')
    ylabel('%BW')

end

%% ================== TABLA FINAL ==================
if ~isempty(duraciones_ms)

    promedio_ms = mean(duraciones_ms);
    sd_ms       = std(duraciones_ms);

    T = table(nombres_archivos', duraciones_ms, ...
        'VariableNames', {'Ensayo','Duracion_Apoyo_ms'});

    disp(' ')
    disp('===== DURACIÓN DE FASE DE APOYO =====')
    disp(T)

    fprintf('\nPromedio apoyo (Base Normativa): %.2f ms\n', promedio_ms)
    fprintf('Desviación estándar:             %.2f ms\n', sd_ms)

end

%% ================== PARÁMETROS BIOMECÁNICOS ==================
if ~isempty(matriz_apoyos)

    % Pico 1 (impacto)
    [peak1_val, peak1_idx]       = max(media(1:25));
    peak1_time                   = x_ref(peak1_idx);

    % Pico 2 (propulsión)
    [peak2_val, peak2_idx_rel]   = max(media(30:end));
    peak2_idx                    = peak2_idx_rel + 29;
    peak2_time                   = x_ref(peak2_idx);

    % Valle intermedio
    [valley_val, valley_idx_rel] = min(media(peak1_idx:peak2_idx));
    valley_idx                   = valley_idx_rel + peak1_idx - 1;
    valley_time                  = x_ref(valley_idx);

    % Impulso vertical
    impulso     = trapz(x_ref, media);

    % SD promedio global
    sd_promedio = mean(sd);

    disp(' ')
    disp('===== PARÁMETROS BIOMECÁNICOS (CURVA PROMEDIO) =====')
    fprintf('Pico 1 (Impacto):    %.2f %%BW  @ %.2f %% apoyo\n', peak1_val, peak1_time)
    fprintf('Pico 2 (Propulsión): %.2f %%BW  @ %.2f %% apoyo\n', peak2_val, peak2_time)
    fprintf('Valle intermedio:    %.2f %%BW  @ %.2f %% apoyo\n', valley_val, valley_time)
    fprintf('Impulso vertical:    %.2f (%%BW·%%apoyo)\n',         impulso)
    fprintf('SD promedio global:  %.2f %%BW\n',                   sd_promedio)

end

%% ================== EXPORTAR BASE DE DATOS ==================
disp(' ')
disp('Seleccione carpeta donde se guardará la Base de Datos procesada')

save_folder = uigetdir(pwd, 'Selecciona carpeta para guardar la base procesada');
if save_folder == 0
    error('No se seleccionó carpeta de guardado')
end

save(fullfile(save_folder,'BaseDatos_FuerzaVertical.mat'), ...
    'media','sd','x_ref', ...
    'peak1_val','peak1_time', ...
    'peak2_val','peak2_time', ...
    'valley_val','valley_time', ...
    'impulso','sd_promedio')

disp(' ')
disp('Base de datos exportada correctamente: BaseDatos_FuerzaVertical.mat')