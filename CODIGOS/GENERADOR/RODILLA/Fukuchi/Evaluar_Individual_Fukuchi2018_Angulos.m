function [T, D] = Evaluar_Individual_Fukuchi2018_Angulos(hacer_figura)
% EVALUAR_INDIVIDUAL_FUKUCHI2018_ANGULOS  27-ago-2026: version reducida a
%                   6 sujetos diversos de Fukuchi 2018 (mismo criterio ya
%                   usado en RODILLA/TOBILLO/INCLINACION_TIBIAL para las
%                   pruebas individuales de Kuopio) - necesaria porque
%                   Yun2014_Wrapper es lento y la maquina esta con carga
%                   pesada ahora mismo (Defender escaneando el zip recien
%                   bajado + otras apps), sin margen para los 42 sujetos
%                   completos en una sola sesion de MATLAB antes de que
%                   el entorno mate el proceso en background.
%
%   Sujetos elegidos (ver WBDSinfo.xlsx, antropometria real):
%     40  F Older 68a 147.0cm 49.2kg   - la mas baja del dataset
%     11  M Young 32a 192.0cm 77.6kg   - el mas alto del dataset
%     14  F Young 31a 153.0cm 65.0kg   - cerca del promedio FEMENINO peruano (152.9cm)
%     34  M Older 62a 164.5cm 70.5kg   - cerca del promedio MASCULINO peruano (165.3cm)
%      1  M Young 25a 172.5cm 74.3kg   - hombre de talla media
%     42  F Older 63a 161.2cm 59.9kg   - mujer mayor de talla media
%
%   Reusa Cargar_Fukuchi2018_Core.m sin modificar. Checkpoint propio
%   (checkpoint_fukuchi_individual.mat), independiente del de la corrida
%   completa N=42 (Evaluar_vs_Fukuchi2018_Angulos.m / checkpoint_fukuchi.mat).

if nargin < 1 || isempty(hacer_figura), hacer_figura = true; end

carpeta = fileparts(mfilename('fullpath'));
dir_generador = fullfile(carpeta, '..', '..');
addpath(dir_generador);
addpath(carpeta);

ids = [40 11 14 34 1 42];
n = numel(ids);
pct = 0:100;

ruta_ckpt = fullfile(carpeta, 'checkpoint_fukuchi_individual.mat');
if isfile(ruta_ckpt)
    load(ruta_ckpt, 'sub_id','sexo','talla_cm','masa_kg','speed_ms', ...
        'Real_cadera','Real_rodilla','Real_tobillo','Pred_cadera','Pred_rodilla','Pred_tobillo','ok');
    fprintf('Checkpoint cargado: %d/%d sujetos ya procesados.\n', sum(ok), n);
else
    sub_id = ids(:);
    sexo = strings(n,1); talla_cm = nan(n,1); masa_kg = nan(n,1); speed_ms = nan(n,1);
    Real_cadera = nan(n,101); Real_rodilla = nan(n,101); Real_tobillo = nan(n,101);
    Pred_cadera = struct('Koopman', nan(n,101), 'Zhao', nan(n,101), 'Yun', nan(n,101));
    Pred_rodilla = struct('Koopman', nan(n,101), 'Zhao', nan(n,101), 'Yun', nan(n,101));
    Pred_tobillo = struct('Koopman', nan(n,101), 'Yun', nan(n,101));
    ok = false(n,1);
end

for k = 1:n
    if ok(k), continue; end
    i = ids(k);
    try
        S = Cargar_Fukuchi2018_Core(i, struct('condicion','O','velocidad','C'));
        sexo(k) = S.sexo; talla_cm(k) = S.talla_cm; masa_kg(k) = S.masa_kg; speed_ms(k) = S.speed_ms;
        Real_cadera(k,:) = S.ang_cadera_deg;
        Real_rodilla(k,:) = S.ang_rodilla_deg;
        Real_tobillo(k,:) = S.ang_tobillo_deg;

        antro = Estimar_Antropometria_Core(struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1)));
        antro.velocidad_ms = S.speed_ms;

        K = Koopman2014_Core(S.speed_ms*3.6, antro.talla_m);
        pct_K = linspace(0,100,numel(K.cadera_flexext.angulo_deg));
        Pred_cadera.Koopman(k,:) = interp1(pct_K, K.cadera_flexext.angulo_deg, pct, 'pchip');
        Pred_rodilla.Koopman(k,:) = interp1(pct_K, K.rodilla_flexext.angulo_deg, pct, 'pchip');
        Pred_tobillo.Koopman(k,:) = interp1(pct_K, K.tobillo_flexext.angulo_deg, pct, 'pchip');

        tempoZ = Temporizacion_Core(antro, 'Zhao');
        Z = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/tempoZ.tiempo_ciclo_s, struct());
        pct_Z = linspace(0,100,numel(Z.phi_cadera_rad));
        Pred_cadera.Zhao(k,:) = interp1(pct_Z, rad2deg(Z.phi_cadera_rad), pct, 'pchip');
        Pred_rodilla.Zhao(k,:) = interp1(pct_Z, rad2deg(Z.phi_rodilla_rad), pct, 'pchip');

        antro14 = antro; antro14.edad_anios = S.edad_anios;
        p14 = [antro14.edad_anios, antro14.talla_m*100, antro14.masa_kg, double(upper(antro14.sexo(1))=='M'), ...
               antro14.long_muslo_m*100, antro14.long_tibia_m*100, ...
               32.8, 29.7, 25.5, 10, antro14.long_pie_m*100, 7.30, 7.10, 9.80];
        Y = Yun2014_Wrapper(p14);
        pct_Y = linspace(0,100,numel(Y.R_hip_extension.mean));
        Pred_cadera.Yun(k,:) = interp1(pct_Y, Y.R_hip_extension.mean, pct, 'pchip');
        Pred_rodilla.Yun(k,:) = interp1(pct_Y, Y.R_knee_flexion.mean, pct, 'pchip');
        Pred_tobillo.Yun(k,:) = interp1(pct_Y, Y.R_ankle_plantarflexion.mean, pct, 'pchip');

        ok(k) = true;
        fprintf('Sujeto %d OK (%d/%d)\n', i, k, n);
    catch ME
        fprintf('FALLO sujeto %d: %s\n', i, ME.message);
    end
    save(ruta_ckpt, 'sub_id','sexo','talla_cm','masa_kg','speed_ms', ...
        'Real_cadera','Real_rodilla','Real_tobillo','Pred_cadera','Pred_rodilla','Pred_tobillo','ok');
end
idx_ok = find(ok);

articulaciones = {'cadera','rodilla','tobillo'};
Real = struct('cadera', Real_cadera, 'rodilla', Real_rodilla, 'tobillo', Real_tobillo);
Pred = struct('cadera', Pred_cadera, 'rodilla', Pred_rodilla, 'tobillo', Pred_tobillo);

R = table();
fprintf('\n=== KOOPMAN/ZHAO/YUN vs FUKUCHI 2018 - MUESTRA DE %d SUJETOS DIVERSOS ===\n', numel(idx_ok));
for a = 1:numel(articulaciones)
    art = articulaciones{a};
    cands = fieldnames(Pred.(art));
    for c = 1:numel(cands)
        cand = cands{c};
        r_crudo = nan(n,1); rmse_crudo = nan(n,1);
        for kk = 1:numel(idx_ok)
            k = idx_ok(kk);
            real_i = Real.(art)(k,:); pred_i = Pred.(art).(cand)(k,:);
            r_crudo(k) = corr(real_i(:), pred_i(:));
            rmse_crudo(k) = sqrt(mean((pred_i-real_i).^2));
        end
        fprintf('%-10s %-10s r=%.3f (rango %.3f a %.3f)  RMSE=%.2f grados\n', art, cand, ...
            mean(r_crudo(idx_ok)), min(r_crudo(idx_ok)), max(r_crudo(idx_ok)), mean(rmse_crudo(idx_ok)));
        Rc = table(sub_id(idx_ok), repmat(string(art),numel(idx_ok),1), repmat(string(cand),numel(idx_ok),1), ...
            r_crudo(idx_ok), rmse_crudo(idx_ok), ...
            'VariableNames', {'sub_id','articulacion','candidato','r_crudo','rmse_crudo'});
        R = [R; Rc]; %#ok<AGROW>
    end
end

T = R;
writetable(T, fullfile(carpeta, 'Evaluar_Individual_Fukuchi2018_Angulos_resultados.csv'));
fprintf('\nTabla: %s\n', fullfile(carpeta, 'Evaluar_Individual_Fukuchi2018_Angulos_resultados.csv'));

D = struct('pct', pct, 'sub_id', sub_id(idx_ok), 'sexo', sexo(idx_ok), 'talla_cm', talla_cm(idx_ok), ...
    'masa_kg', masa_kg(idx_ok), 'speed_ms', speed_ms(idx_ok), 'Real', Real, 'Pred', Pred, 'idx_ok', idx_ok);

if ~hacer_figura || numel(idx_ok) < n, return; end

col = struct('Koopman',[0.85 0.33 0.10],'Zhao',[0.20 0.60 0.20],'Yun',[0.20 0.45 0.70]);
fig = figure('Name','Fukuchi2018 individual vs candidatos','Position',[20 10 1500 1100],'Color','w');
for k = 1:n
    for a = 1:numel(articulaciones)
        art = articulaciones{a};
        subplot(n, 3, (k-1)*3+a); hold on; grid on; box on;
        plot(pct, Real.(art)(k,:), 'k-', 'LineWidth', 2);
        cands = fieldnames(Pred.(art));
        for c = 1:numel(cands)
            cand = cands{c};
            plot(pct, Pred.(art).(cand)(k,:), '-', 'Color', col.(cand), 'LineWidth', 1.3);
        end
        if k==1, title(art); end
        if a==1, ylabel(sprintf('sub%d %s %.0fcm', sub_id(k), char(sexo(k)), talla_cm(k))); end
        if k==n, xlabel('% ciclo'); end
    end
end
sgtitle('Fukuchi 2018 (Brasil) — 6 sujetos diversos: real (negro) vs Koopman/Zhao/Yun', 'FontWeight','bold');
out_png = fullfile(carpeta, 'Evaluar_Individual_Fukuchi2018_Angulos_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura: %s\n', out_png);

end
