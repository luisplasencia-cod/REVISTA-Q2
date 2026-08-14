% ===================================================
% Fig5_Datos_Fuerza.m
%
% COPIA de CODIGOS/VALIDACIONES/Validacion_Fuerza.m con la LOGICA DE
% CALCULO INTACTA (mismo filtro, mismo umbral, misma deteccion IC/TO,
% misma normalizacion, mismos criterios de rechazo).
%
% Lo unico que cambia respecto al original:
%   1. Se eliminan los dialogos uigetfile/inputdlg -> rutas y BW fijos,
%      para que la figura del articulo sea reproducible.
%   2. Se elimina todo el bloque de figuras -> aqui solo se calcula y
%      se guarda. Todo lo visual vive en Fig5_Generar.m.
%   3. Se anade un diagnostico de picos (R2-7: valores pico y
%      anotaciones temporales; P3.2: si hay o no doble pico).
%
% Autorizado por el usuario (P-R2-7.5, 09-ago-2026).
% ===================================================

clear; clc;

%% ---------------- CONFIGURACION ----------------
BASE = fullfile(fileparts(fileparts(mfilename('fullpath'))), ...
                'codigos y base original');

BW_kg = 86;                      % confirmado por el usuario (P-R2-7.3)
BW_N  = BW_kg * 9.81;

fs           = 1000;             % identico al original
dt           = 1/fs;
fc           = 15;
orden        = 4;
umbral_N     = 20;
min_muestras = 20;

[b,a] = butter(orden, fc/(fs/2), 'low');

%% ---------------- CARGA BASE DE DATOS DE REFERENCIA ----------------
datosBD = load(fullfile(BASE,'REFERENCIAS','BaseDatos_FuerzaVertical.mat'));

ref_media = datosBD.media(:);
ref_sd    = datosBD.sd(:);
eje_norm  = datosBD.x_ref(:);

% Picos de la referencia: ya vienen calculados en el .mat original
ref_peak1_val  = datosBD.peak1_val;
ref_peak1_time = datosBD.peak1_time;
ref_peak2_val  = datosBD.peak2_val;
ref_peak2_time = datosBD.peak2_time;
ref_valley_val = datosBD.valley_val;
ref_valley_time= datosBD.valley_time;

%% ---------------- CARGA DE LOS ENSAYOS DEL SIMULADOR ----------------
% Los 10 ensayos, tal cual se presentaron en el articulo (decision del
% usuario: los duplicados son un fallo del software de captura y se
% mantienen porque asi se reportaron).
dir_sim   = fullfile(BASE,'SIMULADOR','FUERZA GRF - SIM');
listado   = dir(fullfile(dir_sim,'*.txt'));
files_sim = sort({listado.name});

n_archivos = numel(files_sim);
n_pts      = sum(eje_norm <= 60);

trials_norm = nan(n_pts, n_archivos);
dur_ms      = nan(1, n_archivos);
nombres_ok  = strings(1, n_archivos);

k = 0;
fprintf('=== CARGA DE ENSAYOS (BW = %g kg) ===\n', BW_kg);

for idx_archivo = 1:n_archivos

    file_sim = files_sim{idx_archivo};
    data_sim = readmatrix(fullfile(dir_sim, file_sim));
    Fz_raw   = data_sim(:,3);
    N        = length(Fz_raw);

    % PASO 1: Conversion lbf -> N
    if max(Fz_raw) < 500
        Fz_raw = Fz_raw * 4.44822;
    end

    % PASO 2: Remocion de offset
    offset_k = mean(Fz_raw(1:100));
    Fz_N     = Fz_raw - offset_k;

    % PASO 3: Filtrado
    Fz_filt_N = filtfilt(b, a, Fz_N);

    % PASO 4: Deteccion IC
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

    % PASO 5: Deteccion TO
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

    % PASO 6-8: Recorte, normalizacion %BW y criterios de calidad
    valido = true; razon = '';
    if isempty(idx_IC) || isempty(idx_TO)
        valido = false; razon = 'No se detecto IC o TO';
    else
        Fz_recorte_N = Fz_filt_N(idx_IC:idx_TO);
        duracion_ms  = (idx_TO - idx_IC) * dt * 1000;
        Fz_apoyo     = (Fz_recorte_N / BW_N) * 100;

        if duracion_ms < 300
            valido = false; razon = sprintf('Duracion %.0f ms < 300', duracion_ms);
        elseif length(Fz_apoyo) < 50
            valido = false; razon = sprintf('Longitud %d < 50', length(Fz_apoyo));
        elseif max(Fz_apoyo) < 80
            valido = false; razon = sprintf('Pico %.1f %%BW < 80', max(Fz_apoyo));
        else
            pks = findpeaks(Fz_apoyo);
            if numel(pks) < 2
                valido = false; razon = sprintf('Solo %d pico(s), se requieren >=2', numel(pks));
            else
                margen     = round(length(Fz_apoyo) * 0.05);
                zona_media = Fz_apoyo(margen:end-margen);
                umbral_BW  = (umbral_N / BW_N) * 100;
                if any(zona_media < umbral_BW)
                    valido = false; razon = 'Cae bajo el umbral en zona media';
                end
            end
        end
    end

    if ~valido
        fprintf('  %s  DESCARTADO: %s\n', file_sim, razon);
        continue
    end

    k = k + 1;
    fprintf('  %s  aceptado (dur=%.0f ms, pico=%.2f %%BW)\n', ...
            file_sim, duracion_ms, max(Fz_apoyo));

    t_norm60 = linspace(0, 60, length(Fz_apoyo));
    trials_norm(:,k) = interp1(t_norm60, Fz_apoyo, ...
                               eje_norm(eje_norm <= 60), 'pchip');
    dur_ms(k)     = duracion_ms;
    nombres_ok(k) = string(file_sim);
end

n_ensayos   = k;
trials_norm = trials_norm(:,1:n_ensayos);
dur_ms      = dur_ms(1:n_ensayos);
nombres_ok  = nombres_ok(1:n_ensayos);

sim_media = mean(trials_norm, 2);
sim_sd    = std(trials_norm, 0, 2);      % <-- ya existia en el original,
                                         %     nunca se dibujo (R2-7)

idx_apoyo = eje_norm <= 60;
eje       = eje_norm(idx_apoyo);
ref_media_ap = ref_media(idx_apoyo);
ref_sd_ap    = ref_sd(idx_apoyo);

residual = sim_media - ref_media_ap;      % R2-7: curva residual

fprintf('\nEnsayos validos: %d de %d\n', n_ensayos, n_archivos);

%% ---------------- DIAGNOSTICO DE PICOS (P3.2 / P3.3) ----------------
fprintf('\n=== REFERENCIA (del .mat original) ===\n');
fprintf('  Pico 1 : %7.2f %%BW  al %5.2f %% del ciclo\n', ref_peak1_val, ref_peak1_time);
fprintf('  Valle  : %7.2f %%BW  al %5.2f %%\n',            ref_valley_val, ref_valley_time);
fprintf('  Pico 2 : %7.2f %%BW  al %5.2f %%\n',            ref_peak2_val, ref_peak2_time);
fprintf('  Profundidad del valle: %.2f %%BW (pico1) / %.2f %%BW (pico2)\n', ...
        ref_peak1_val-ref_valley_val, ref_peak2_val-ref_valley_val);

fprintf('\n=== SIMULADOR (curva media, %d ensayos) ===\n', n_ensayos);
fprintf('  Maximo absoluto: %.2f %%BW al %.2f %% del ciclo  (= %.1f N)\n', ...
        max(sim_media), eje(sim_media==max(sim_media)), max(sim_media)/100*BW_N);

[pk, lc, wd, pr] = findpeaks(sim_media, eje);
fprintf('\n  Todos los maximos locales de la curva media:\n');
fprintf('  %-8s %-10s %-12s %-10s\n','%ciclo','valor %BW','prominencia','anchura');
for i = 1:numel(pk)
    fprintf('  %-8.2f %-10.2f %-12.3f %-10.2f\n', lc(i), pk(i), pr(i), wd(i));
end
fprintf('\n  Maximos con prominencia >= 1 %%BW (los que se verian en una figura):\n');
sel = pr >= 1;
if any(sel)
    for i = find(sel)'
        fprintf('    %.2f %%BW al %.2f %% (prominencia %.2f)\n', pk(i), lc(i), pr(i));
    end
else
    fprintf('    NINGUNO -> la curva media tiene un solo maximo relevante\n');
end

%% ---------------- GUARDAR ----------------
save(fullfile(fileparts(mfilename('fullpath')),'Fig5_datos_fuerza.mat'), ...
     'eje','ref_media_ap','ref_sd_ap','sim_media','sim_sd','trials_norm', ...
     'residual','n_ensayos','BW_kg','BW_N','dur_ms','nombres_ok', ...
     'ref_peak1_val','ref_peak1_time','ref_peak2_val','ref_peak2_time', ...
     'ref_valley_val','ref_valley_time');

fprintf('\nGuardado: Fig5_datos_fuerza.mat\n');
