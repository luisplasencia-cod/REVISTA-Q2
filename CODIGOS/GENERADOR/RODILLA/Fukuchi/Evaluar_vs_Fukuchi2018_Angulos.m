function [T, D] = Evaluar_vs_Fukuchi2018_Angulos(hacer_figura)
% EVALUAR_VS_FUKUCHI2018_ANGULOS  27-ago-2026: compara los 3 candidatos
%                   (Koopman/Zhao/Yun) contra los ANGULOS ARTICULARES
%                   REALES de cadera/rodilla/tobillo del dataset de
%                   Fukuchi, Fukuchi & Duarte 2018 (PeerJ 6:e4640) -
%                   N=42, Brasil, marcha overground comoda ('C').
%
%   POR QUE ESTA BASE (ver docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_
%   Q1.md #11-bis): es la unica base sudamericana real del proyecto con
%   antropometria individual completa, y representa la poblacion peruana
%   con mucha mas fidelidad que Kuopio (74% de N=42 dentro del P5-P95
%   real peruano - Asgari et al 2019, N=3134 - vs 40% de Kuopio N=15).
%
%   POR QUE ES LA COMPARACION MAS DIRECTA DEL PROYECTO: Fukuchi entrega
%   angulo ARTICULAR (Hip/Knee/Ankle, no segmento absoluto) ya
%   normalizado a 0-100% del ciclo - se compara DIRECTO contra el angulo
%   articular nativo de cada candidato (cadera_flexext, rodilla_flexext,
%   tobillo_flexext de Koopman; phi_cadera/phi_rodilla de Zhao, sin
%   tobillo - Zhao no predice tobillo en cinematica, declarado en su
%   propio paper; R_hip_extension/R_knee_flexion/R_ankle_plantarflexion
%   de Yun) - SIN pasar por Cadena_Cinematica_Core.m ni por ningun
%   supuesto geometrico adicional.
%
%   NO CIRCULARIDAD: Fukuchi entrena los coeficientes de Romero-
%   Sorozabal 2024 - por eso NO se usa para evaluar ese candidato (ya
%   excluido de la comparacion de candidatos ganadores de todos modos,
%   por la anomalia de su eje Z). Koopman/Zhao/Yun nunca tocaron este
%   dataset - examen 100% independiente para ellos.
%
%   METODO: identico en espiritu a Evaluar_vs_Maastricht.m - se corre
%   cada candidato UNA vez por sujeto (con su propia antropometria real:
%   talla, velocidad medida - long_muslo/long_tibia estimadas por
%   Estimar_Antropometria_Core.m porque Fukuchi solo da largo de pierna
%   TOTAL, no el desglose, igual que Ferber), se calibra afin LOSO
%   (misma tecnica ya validada en RODILLA/TOBILLO/INCLINACION_TIBIAL) y
%   se reportan r/RMSE crudos y calibrados por candidato y articulacion.
%
%   SALIDAS
%     T : tabla larga (sub_id, candidato, articulacion, r_crudo, r_cal, rmse_cal)
%     D : struct con las curvas reales y predichas de los 42 sujetos
%   hacer_figura (opcional, default true)

if nargin < 1 || isempty(hacer_figura), hacer_figura = true; end

carpeta = fileparts(mfilename('fullpath'));
dir_generador = fullfile(carpeta, '..', '..');
addpath(dir_generador);
addpath(carpeta);

n = 42;
pct = 0:100;

% CHECKPOINT (27-ago-2026): Yun tarda ~1-2 min/sujeto (regresion GP) - un
% proceso MATLAB de ~70min para los 42 sujetos excede el limite de
% ejecucion en background del entorno. Se guarda progreso por sujeto en
% un .mat y se retoma donde quedo si el script se relanza - mismo
% principio que la descarga reanudable con curl -C -.
ruta_ckpt = fullfile(carpeta, 'checkpoint_fukuchi.mat');
if isfile(ruta_ckpt)
    load(ruta_ckpt, 'sub_id','sexo','talla_cm','masa_kg','speed_ms', ...
        'Real_cadera','Real_rodilla','Real_tobillo','Pred_cadera','Pred_rodilla','Pred_tobillo','ok');
    fprintf('Checkpoint cargado: %d/%d sujetos ya procesados.\n', sum(ok), n);
else
    sub_id = (1:n)';
    sexo = strings(n,1); talla_cm = nan(n,1); masa_kg = nan(n,1); speed_ms = nan(n,1);
    Real_cadera = nan(n,101); Real_rodilla = nan(n,101); Real_tobillo = nan(n,101);
    Pred_cadera = struct('Koopman', nan(n,101), 'Zhao', nan(n,101), 'Yun', nan(n,101));
    Pred_rodilla = struct('Koopman', nan(n,101), 'Zhao', nan(n,101), 'Yun', nan(n,101));
    Pred_tobillo = struct('Koopman', nan(n,101), 'Yun', nan(n,101));  % Zhao no predice tobillo
    ok = false(n,1);
end

for i = 1:n
    if ok(i), continue; end   % ya procesado en una corrida anterior
    try
        S = Cargar_Fukuchi2018_Core(i, struct('condicion','O','velocidad','C'));
        sexo(i) = S.sexo; talla_cm(i) = S.talla_cm; masa_kg(i) = S.masa_kg; speed_ms(i) = S.speed_ms;
        Real_cadera(i,:) = S.ang_cadera_deg;
        Real_rodilla(i,:) = S.ang_rodilla_deg;
        Real_tobillo(i,:) = S.ang_tobillo_deg;

        antro = Estimar_Antropometria_Core(struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1)));
        antro.velocidad_ms = S.speed_ms;  % velocidad REAL medida (regla D2: medido > estimado, ver #6.3 del doc Q1)

        % --- Koopman ---
        K = Koopman2014_Core(S.speed_ms*3.6, antro.talla_m);
        pct_K = linspace(0,100,numel(K.cadera_flexext.angulo_deg));
        Pred_cadera.Koopman(i,:) = interp1(pct_K, K.cadera_flexext.angulo_deg, pct, 'pchip');
        Pred_rodilla.Koopman(i,:) = interp1(pct_K, K.rodilla_flexext.angulo_deg, pct, 'pchip');
        Pred_tobillo.Koopman(i,:) = interp1(pct_K, K.tobillo_flexext.angulo_deg, pct, 'pchip');

        % --- Zhao (lado nativo 'izquierda', sin truco de lado - misma regla D2 del proyecto) ---
        % Cadencia real no disponible directo (Fukuchi da velocidad, no cadencia) -> Temporizacion_Core
        tempoZ = Temporizacion_Core(antro, 'Zhao');
        Z = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/tempoZ.tiempo_ciclo_s, struct());
        pct_Z = linspace(0,100,numel(Z.phi_cadera_rad));
        Pred_cadera.Zhao(i,:) = interp1(pct_Z, rad2deg(Z.phi_cadera_rad), pct, 'pchip');
        Pred_rodilla.Zhao(i,:) = interp1(pct_Z, rad2deg(Z.phi_rodilla_rad), pct, 'pchip');

        % --- Yun ---
        antro14 = antro; antro14.edad_anios = S.edad_anios;
        p14 = [antro14.edad_anios, antro14.talla_m*100, antro14.masa_kg, double(upper(antro14.sexo(1))=='M'), ...
               antro14.long_muslo_m*100, antro14.long_tibia_m*100, ...
               32.8, 29.7, 25.5, 10, antro14.long_pie_m*100, 7.30, 7.10, 9.80];
        Y = Yun2014_Wrapper(p14);
        pct_Y = linspace(0,100,numel(Y.R_hip_extension.mean));
        Pred_cadera.Yun(i,:) = interp1(pct_Y, Y.R_hip_extension.mean, pct, 'pchip');
        Pred_rodilla.Yun(i,:) = interp1(pct_Y, Y.R_knee_flexion.mean, pct, 'pchip');
        Pred_tobillo.Yun(i,:) = interp1(pct_Y, Y.R_ankle_plantarflexion.mean, pct, 'pchip');

        ok(i) = true;
        fprintf('Sujeto %d OK (%d/%d)\n', i, i, n);
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
fprintf('\n=== KOOPMAN/ZHAO/YUN vs FUKUCHI 2018 (Brasil, N=%d, angulos articulares nativos) ===\n', numel(idx_ok));
for a = 1:numel(articulaciones)
    art = articulaciones{a};
    cands = fieldnames(Pred.(art));
    for c = 1:numel(cands)
        cand = cands{c};
        r_crudo = nan(n,1); r_cal = nan(n,1); rmse_cal = nan(n,1);
        for k = 1:numel(idx_ok)
            i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
            real_i = Real.(art)(i,:); pred_i = Pred.(art).(cand)(i,:);
            r_crudo(i) = corr(real_i(:), pred_i(:));
            p = polyfit(reshape(Pred.(art).(cand)(otros,:),1,[]), reshape(Real.(art)(otros,:),1,[]), 1);
            pred_cal = polyval(p, pred_i);
            r_cal(i) = corr(real_i(:), pred_cal(:));
            rmse_cal(i) = sqrt(mean((pred_cal-real_i).^2));
        end
        fprintf('%-10s %-10s r_crudo=%.3f  r_cal=%.3f  RMSE_cal=%.2f grados\n', art, cand, ...
            mean(r_crudo(idx_ok)), mean(r_cal(idx_ok)), mean(rmse_cal(idx_ok)));
        Rc = table(sub_id(idx_ok), repmat(string(art),numel(idx_ok),1), repmat(string(cand),numel(idx_ok),1), ...
            r_crudo(idx_ok), r_cal(idx_ok), rmse_cal(idx_ok), ...
            'VariableNames', {'sub_id','articulacion','candidato','r_crudo','r_cal','rmse_cal'});
        R = [R; Rc]; %#ok<AGROW>
    end
end

T = R;
writetable(T, fullfile(carpeta, 'Evaluar_vs_Fukuchi2018_Angulos_resultados.csv'));
fprintf('\nTabla: %s\n', fullfile(carpeta, 'Evaluar_vs_Fukuchi2018_Angulos_resultados.csv'));

D = struct('pct', pct, 'sub_id', sub_id(idx_ok), 'sexo', sexo(idx_ok), 'talla_cm', talla_cm(idx_ok), ...
    'masa_kg', masa_kg(idx_ok), 'speed_ms', speed_ms(idx_ok), 'Real', Real, 'Pred', Pred, 'idx_ok', idx_ok);

if ~hacer_figura, return; end

col = struct('Koopman',[0.85 0.33 0.10],'Zhao',[0.20 0.60 0.20],'Yun',[0.20 0.45 0.70]);
fig = figure('Name','Fukuchi2018 vs candidatos','Position',[30 20 1400 900],'Color','w');
sp = 0;
for a = 1:numel(articulaciones)
    art = articulaciones{a};
    sp = sp+1; subplot(3,1,sp); hold on; grid on; box on;
    for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Real.(art)(i,:), '-','Color',[0.6 0.6 0.6 0.5],'LineWidth',0.8); end
    plot(pct, mean(Real.(art)(idx_ok,:),1), 'k-','LineWidth',2.5);
    cands = fieldnames(Pred.(art));
    leyenda = {'individual real','media real'};
    for c = 1:numel(cands)
        cand = cands{c};
        plot(pct, mean(Pred.(art).(cand)(idx_ok,:),1), '-', 'Color', col.(cand), 'LineWidth', 2);
        leyenda{end+1} = cand; %#ok<AGROW>
    end
    xlabel('% ciclo'); ylabel([art ' [grados]']);
    title(sprintf('%s: real (N=%d, Fukuchi 2018 Brasil) vs candidatos (crudo, media)', art, numel(idx_ok)));
    legend(leyenda, 'Location','best');
end
sgtitle('Koopman/Zhao/Yun vs Fukuchi 2018 (Brasil, overground comodo) — angulos articulares nativos', 'FontWeight','bold');
out_png = fullfile(carpeta, 'Evaluar_vs_Fukuchi2018_Angulos_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura: %s\n', out_png);

end
