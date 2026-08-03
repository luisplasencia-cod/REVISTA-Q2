% ===================================================
% APLICAR SPM1D SOBRE LAS CURVAS QUE YA EXISTEN HOY
% (angulo de plataforma y Fz, simulador vs. referencia Kinovea/AMTI)
% ===================================================
%
% Que es esto: la tarea de Semana 1 del plan ("Correr SPM1D sobre
% curvas existentes... Correr Bland-Altman sobre esas mismas curvas")
% aplicada con datos que YA existen en el repo, sin esperar a ninguna
% captura nueva ni a la aprobacion de etica.
%
% Este script es NUEVO y autocontenido. Los scripts que ya se usaron
% para reportar los resultados de la conferencia
% (CODIGOS/VALIDACIONES/Validacion_Plataforma.m y Validacion_Fuerza.m)
% NO se tocan ni se llaman desde aqui - quedan como referencia de como
% se cargaron y procesaron los datos originalmente. Este script vuelve
% a cargar los mismos archivos crudos con la misma logica de
% procesamiento (misma convencion atan2, mismo filtro, misma deteccion
% de IC/TO) para no introducir ninguna diferencia metodologica, pero
% el analisis estadistico que corre encima es nuevo: SPM1D_Core.m en
% vez de (o ademas de) RMSE/r/%1SD/ICC.
%
% -----------------------------------------------------------------
% HALLAZGO IMPORTANTE (por que este script NO corre Bland-Altman):
% Bland-Altman compara pares de mediciones de DOS METODOS/INSTRUMENTOS
% sobre las MISMAS unidades de analisis. Los archivos de referencia
% actuales (BaseDatos_Plataforma_Apoyo.mat, BaseDatos_Plataforma_
% Balanceo.mat, BaseDatos_FuerzaVertical.mat) solo guardan la curva
% MEDIA +- SD del sujeto original - no los ensayos individuales de
% Kinovea. Sin ensayos individuales del "otro metodo" no hay pares
% que comparar: no se puede hacer Bland-Altman honesto contra esta
% referencia, solo contra la referencia resumida.
% Lo que SI es valido hoy es un SPM{t} de UNA MUESTRA: se compara cada
% ensayo del simulador contra la curva de referencia (fija, conocida)
% - exactamente el mismo tipo de comparacion que ya hacen RMSEnorm/r/
% ICC en Validacion_Plataforma.m y Validacion_Fuerza.m, solo que ahora
% punto a punto en vez de resumido en un numero.
% Bland-Altman instrumento-vs-instrumento queda para cuando existan
% ensayos pareados de dos metodos (Kinovea vs. STT-IWS, IMU de
% Alessandro vs. STT-IWS) - ver CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md
% y la Comparacion 1/2 de la matriz en el plan de 5 semanas.
% -----------------------------------------------------------------

clear; clc; close all
close all force
delete(findall(0,'Type','figure','-and','WindowStyle','normal'))

carpeta_resultados = fullfile(pwd, 'Resultados_SPM1D_CurvasExistentes');

%% =======================
% PARTE 1 - ANGULO DE PLATAFORMA (apoyo y balanceo)
%% =======================
fprintf('\n### PARTE 1: ANGULO DE PLATAFORMA ###\n');

sgolay_orden = 3; sgolay_window = 9;

[file_bd_ap, path_bd_ap] = uigetfile('*.mat','Seleccione BaseDatos_Plataforma_Apoyo.mat');
if isequal(file_bd_ap,0), error('Carga cancelada.'); end
bd_ap = load(fullfile(path_bd_ap, file_bd_ap));

[file_bd_bal, path_bd_bal] = uigetfile('*.mat','Seleccione BaseDatos_Plataforma_Balanceo.mat');
if isequal(file_bd_bal,0), error('Carga cancelada.'); end
bd_bal = load(fullfile(path_bd_bal, file_bd_bal));

eje_ap  = linspace(0, 60, 101)';
eje_bal = linspace(60, 100, 101)';
ref_ap  = interp1(linspace(0,60,length(bd_ap.media_plat_apoyo)),    bd_ap.media_plat_apoyo,    eje_ap,  'pchip');
ref_bal = interp1(linspace(60,100,length(bd_bal.media_plat_balanceo)), bd_bal.media_plat_balanceo, eje_bal, 'pchip');

[files_apoyo, path_apoyo] = uigetfile('*.csv', ...
    'Seleccione los archivos de APOYO del simulador (Ctrl+Click)', 'MultiSelect','on');
if ~iscell(files_apoyo), error('Debe seleccionar los archivos de apoyo.'); end
files_apoyo = sort(files_apoyo);
n_apoyo = numel(files_apoyo);

trials_apoyo = nan(101, n_apoyo);
for k = 1:n_apoyo
    d = readtable(fullfile(path_apoyo, files_apoyo{k}), 'VariableNamingRule','preserve','Delimiter',';');
    xo = d{:,6}; yo = d{:,7}; xa = d{:,2}; ya = d{:,3};
    theta = rad2deg(unwrap(atan2(yo - ya, xo - xa))) - 5.85;   % misma convencion atan2, mismo offset -5.85 que Validacion_Plataforma.m
    theta_filt = sgolayfilt(theta, sgolay_orden, sgolay_window);
    pct = linspace(0, 60, length(theta_filt));
    trials_apoyo(:,k) = interp1(pct, theta_filt, eje_ap, 'pchip');
end

[files_bal, path_bal] = uigetfile('*.csv', ...
    'Seleccione los archivos de BALANCEO del simulador (Ctrl+Click)', 'MultiSelect','on');
if ~iscell(files_bal), error('Debe seleccionar los archivos de balanceo.'); end
files_bal = sort(files_bal);
n_bal = numel(files_bal);

trials_bal = nan(101, n_bal);
for k = 1:n_bal
    d = readtable(fullfile(path_bal, files_bal{k}), 'VariableNamingRule','preserve','Delimiter',';');
    xo = d{:,6}; yo = d{:,7}; xa = d{:,2}; ya = d{:,3};
    theta = rad2deg(unwrap(atan2(yo - ya, xo - xa)));   % sin offset -5.85 en balanceo, igual que Validacion_Plataforma.m
    theta_filt = sgolayfilt(theta, sgolay_orden, sgolay_window);
    pct = linspace(60, 100, length(theta_filt));
    trials_bal(:,k) = interp1(pct, theta_filt, eje_bal, 'pchip');
end

fprintf('\n--- SPM1D: Angulo APOYO, simulador (n=%d ensayos) vs. referencia Kinovea (curva fija) ---\n', n_apoyo);
r_ap = SPM1D_Core(trials_apoyo, repmat(ref_ap,1,n_apoyo), struct( ...
    'eje_x', eje_ap, 'nombre_A','Simulador','nombre_B','Referencia Kinovea', ...
    'guardar_en', fullfile(carpeta_resultados,'Angulo_Apoyo')));

fprintf('\n--- SPM1D: Angulo BALANCEO, simulador (n=%d ensayos) vs. referencia Kinovea (curva fija) ---\n', n_bal);
r_bal = SPM1D_Core(trials_bal, repmat(ref_bal,1,n_bal), struct( ...
    'eje_x', eje_bal, 'nombre_A','Simulador','nombre_B','Referencia Kinovea', ...
    'guardar_en', fullfile(carpeta_resultados,'Angulo_Balanceo')));

%% =======================
% PARTE 2 - FUERZA VERTICAL (Fz, fase de apoyo)
%% =======================
fprintf('\n### PARTE 2: FUERZA VERTICAL (Fz) ###\n');

[file_bd_fz, path_bd_fz] = uigetfile('*.mat','Seleccione BaseDatos_FuerzaVertical.mat');
if isequal(file_bd_fz,0), error('Carga cancelada.'); end
bd_fz = load(fullfile(path_bd_fz, file_bd_fz));

eje_fz = bd_fz.x_ref(:);
ref_fz = bd_fz.media(:);
n_pts_fz = numel(eje_fz);

respuesta = inputdlg('Ingrese el peso corporal simulado (kg):', 'Peso Corporal', 1, {'80'});
if isempty(respuesta), error('No se ingreso el peso corporal.'); end
BW_kg = str2double(respuesta{1});
if isnan(BW_kg) || BW_kg <= 0, error('Peso invalido: "%s".', respuesta{1}); end
BW_N = BW_kg * 9.81;

fs = 1000; dt = 1/fs; fc = 15; orden = 4; umbral_N = 20; min_muestras = 20;
[b,a] = butter(orden, fc/(fs/2), 'low');

[files_fz, path_fz] = uigetfile('*.txt', 'Seleccione los ensayos .txt de Fz (Ctrl+Click)', 'MultiSelect','on');
if isequal(files_fz,0), error('Carga cancelada.'); end
if ischar(files_fz), files_fz = {files_fz}; end

trials_fz = nan(n_pts_fz, numel(files_fz));
k_ok = 0;
for idx = 1:numel(files_fz)
    data = readmatrix(fullfile(path_fz, files_fz{idx}));
    Fz_raw = data(:,3);
    if max(abs(Fz_raw)) < 500, Fz_raw = Fz_raw * 4.44822; end   % misma heuristica lbf->N que Validacion_Fuerza.m
    Fz_N = Fz_raw - mean(Fz_raw(1:100));
    Fz_filt = filtfilt(b, a, Fz_N);

    idx_IC = local_detectar_cruce(Fz_filt, umbral_N, min_muestras, 1, 'subida');
    if isempty(idx_IC), fprintf('Archivo "%s" DESCARTADO: sin IC detectado.\n', files_fz{idx}); continue; end
    idx_TO = local_detectar_cruce(Fz_filt, umbral_N, min_muestras, idx_IC+1, 'bajada');
    if isempty(idx_TO), fprintf('Archivo "%s" DESCARTADO: sin TO detectado.\n', files_fz{idx}); continue; end

    Fz_apoyo_pct = (Fz_filt(idx_IC:idx_TO) / BW_N) * 100;
    if (idx_TO-idx_IC)*dt*1000 < 300 || numel(Fz_apoyo_pct) < 50 || max(Fz_apoyo_pct) < 80
        fprintf('Archivo "%s" DESCARTADO: no cumple criterios de calidad.\n', files_fz{idx});
        continue
    end

    k_ok = k_ok + 1;
    t_norm = linspace(0, 60, numel(Fz_apoyo_pct));
    trials_fz(:,k_ok) = interp1(t_norm, Fz_apoyo_pct, eje_fz(eje_fz<=60), 'pchip');
end
trials_fz = trials_fz(:, 1:k_ok);
if k_ok == 0, error('Ningun archivo de Fz paso los criterios de validacion.'); end

idx_apoyo_fz = eje_fz <= 60;
fprintf('\n--- SPM1D: Fz APOYO, simulador (n=%d ensayos validos) vs. referencia (curva fija) ---\n', k_ok);
r_fz = SPM1D_Core(trials_fz(idx_apoyo_fz,:), repmat(ref_fz(idx_apoyo_fz),1,k_ok), struct( ...
    'eje_x', eje_fz(idx_apoyo_fz), 'nombre_A','Simulador','nombre_B','Referencia', ...
    'unidad_y','%BW', 'guardar_en', fullfile(carpeta_resultados,'Fz_Apoyo')));

%% =======================
% RESUMEN
%% =======================
fprintf('\n==================================================================\n');
fprintf('RESUMEN SPM1D - CURVAS EXISTENTES\n');
fprintf('==================================================================\n');
fprintf('Angulo apoyo:    %.1f%% del ciclo con diferencia significativa\n', r_ap.pct_ciclo_significativo);
fprintf('Angulo balanceo: %.1f%% del ciclo con diferencia significativa\n', r_bal.pct_ciclo_significativo);
fprintf('Fz apoyo:        %.1f%% del ciclo con diferencia significativa\n', r_fz.pct_ciclo_significativo);
fprintf('Resultados exportados en: %s\n', carpeta_resultados);
fprintf('Bland-Altman: NO evaluado (ver nota al inicio del script) - pendiente de datos pareados de dos instrumentos.\n');
fprintf('==================================================================\n');

%% ===================================================
% FUNCION LOCAL - deteccion de cruce de umbral (IC/TO), misma logica
% que Validacion_Fuerza.m, factorizada para no repetirla 2 veces aqui.
%% ===================================================
function idx_cruce = local_detectar_cruce(Fz, umbral, min_muestras, idx_inicio, tipo)
idx_cruce = [];
for k2 = max(idx_inicio,2):length(Fz)-min_muestras
    if strcmp(tipo,'subida')
        cruza = Fz(k2-1) < umbral && Fz(k2) >= umbral;
        sostenido = all(Fz(k2:k2+min_muestras-1) >= umbral);
    else
        cruza = Fz(k2-1) >= umbral && Fz(k2) < umbral;
        sostenido = all(Fz(k2:k2+min_muestras-1) < umbral);
    end
    if cruza && sostenido
        t_cruce = (k2-1) + (umbral - Fz(k2-1)) / (Fz(k2) - Fz(k2-1));
        idx_cruce = round(t_cruce);
        return
    end
end
end
