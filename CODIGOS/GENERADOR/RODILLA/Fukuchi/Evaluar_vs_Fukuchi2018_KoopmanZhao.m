function [T, D] = Evaluar_vs_Fukuchi2018_KoopmanZhao(hacer_figura)
% EVALUAR_VS_FUKUCHI2018_KOOPMANZHAO  27-ago-2026: version SOLO Koopman +
%                   Zhao (formula cerrada, rapida) contra los 42 sujetos
%                   completos de Fukuchi 2018 - Yun se deja pendiente por
%                   separado (Evaluar_vs_Fukuchi2018_Angulos.m, con
%                   checkpoint) porque su regresion GP es lenta y la
%                   maquina esta con memoria bajo presion ahora mismo
%                   (Zoom+Chrome+WSL+VSCode+multiples Claude corriendo a
%                   la vez) - cada intento de Yun salio MAS lento que el
%                   anterior (1 figura/10min en el ultimo intento vs 8
%                   figuras/10min en el primero), senal de degradacion
%                   por presion de memoria, no un bug de este codigo.
%
%   Yun viene perdiendo consistentemente en las 3 piezas ya evaluadas
%   (RODILLA/TOBILLO/INCLINACION_TIBIAL) - su ausencia aqui no cambia el
%   hallazgo central (Koopman gana), solo deja incompleta la tabla de 3
%   candidatos hasta que se pueda correr con mas margen de maquina.
%
%   Mismo metodo/interfaz que Evaluar_vs_Fukuchi2018_Angulos.m (ver ese
%   archivo para el detalle completo de justificacion/no-circularidad),
%   sin el bloque de Yun.

if nargin < 1 || isempty(hacer_figura), hacer_figura = true; end

carpeta = fileparts(mfilename('fullpath'));
dir_generador = fullfile(carpeta, '..', '..');
addpath(dir_generador);
addpath(carpeta);

n = 42;
pct = 0:100;

sub_id = (1:n)';
sexo = strings(n,1); talla_cm = nan(n,1); masa_kg = nan(n,1); speed_ms = nan(n,1);
Real_cadera = nan(n,101); Real_rodilla = nan(n,101); Real_tobillo = nan(n,101);
Pred_cadera = struct('Koopman', nan(n,101), 'Zhao', nan(n,101));
Pred_rodilla = struct('Koopman', nan(n,101), 'Zhao', nan(n,101));
Pred_tobillo = struct('Koopman', nan(n,101));  % Zhao no predice tobillo
ok = false(n,1);

for i = 1:n
    try
        S = Cargar_Fukuchi2018_Core(i, struct('condicion','O','velocidad','C'));
        sexo(i) = S.sexo; talla_cm(i) = S.talla_cm; masa_kg(i) = S.masa_kg; speed_ms(i) = S.speed_ms;
        Real_cadera(i,:) = S.ang_cadera_deg;
        Real_rodilla(i,:) = S.ang_rodilla_deg;
        Real_tobillo(i,:) = S.ang_tobillo_deg;

        antro = Estimar_Antropometria_Core(struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1)));
        antro.velocidad_ms = S.speed_ms;

        K = Koopman2014_Core(S.speed_ms*3.6, antro.talla_m);
        pct_K = linspace(0,100,numel(K.cadera_flexext.angulo_deg));
        Pred_cadera.Koopman(i,:) = interp1(pct_K, K.cadera_flexext.angulo_deg, pct, 'pchip');
        Pred_rodilla.Koopman(i,:) = interp1(pct_K, K.rodilla_flexext.angulo_deg, pct, 'pchip');
        Pred_tobillo.Koopman(i,:) = interp1(pct_K, K.tobillo_flexext.angulo_deg, pct, 'pchip');

        tempoZ = Temporizacion_Core(antro, 'Zhao');
        Z = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/tempoZ.tiempo_ciclo_s, struct());
        pct_Z = linspace(0,100,numel(Z.phi_cadera_rad));
        Pred_cadera.Zhao(i,:) = interp1(pct_Z, rad2deg(Z.phi_cadera_rad), pct, 'pchip');
        Pred_rodilla.Zhao(i,:) = interp1(pct_Z, rad2deg(Z.phi_rodilla_rad), pct, 'pchip');

        ok(i) = true;
        fprintf('Sujeto %d OK (%d/%d)\n', i, i, n);
    catch ME
        fprintf('FALLO sujeto %d: %s\n', i, ME.message);
    end
end
idx_ok = find(ok);

articulaciones = {'cadera','rodilla','tobillo'};
Real = struct('cadera', Real_cadera, 'rodilla', Real_rodilla, 'tobillo', Real_tobillo);
Pred = struct('cadera', Pred_cadera, 'rodilla', Pred_rodilla, 'tobillo', Pred_tobillo);

R = table();
fprintf('\n=== KOOPMAN/ZHAO vs FUKUCHI 2018 (Brasil, N=%d, angulos articulares nativos) - Yun PENDIENTE ===\n', numel(idx_ok));
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
writetable(T, fullfile(carpeta, 'Evaluar_vs_Fukuchi2018_KoopmanZhao_resultados.csv'));
fprintf('\nTabla: %s\n', fullfile(carpeta, 'Evaluar_vs_Fukuchi2018_KoopmanZhao_resultados.csv'));

D = struct('pct', pct, 'sub_id', sub_id(idx_ok), 'sexo', sexo(idx_ok), 'talla_cm', talla_cm(idx_ok), ...
    'masa_kg', masa_kg(idx_ok), 'speed_ms', speed_ms(idx_ok), 'Real', Real, 'Pred', Pred, 'idx_ok', idx_ok);

if ~hacer_figura, return; end

col = struct('Koopman',[0.85 0.33 0.10],'Zhao',[0.20 0.60 0.20]);
fig = figure('Name','Fukuchi2018 vs Koopman/Zhao','Position',[30 20 1400 900],'Color','w');
sp = 0;
for a = 1:numel(articulaciones)
    art = articulaciones{a};
    sp = sp+1; subplot(3,1,sp); hold on; grid on; box on;
    for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Real.(art)(i,:), '-','Color',[0.6 0.6 0.6 0.4],'LineWidth',0.7); end
    plot(pct, mean(Real.(art)(idx_ok,:),1), 'k-','LineWidth',2.5);
    cands = fieldnames(Pred.(art));
    leyenda = {'individual real','media real'};
    for c = 1:numel(cands)
        cand = cands{c};
        plot(pct, mean(Pred.(art).(cand)(idx_ok,:),1), '-', 'Color', col.(cand), 'LineWidth', 2);
        leyenda{end+1} = cand; %#ok<AGROW>
    end
    xlabel('% ciclo'); ylabel([art ' [grados]']);
    title(sprintf('%s: real (N=%d, Fukuchi 2018 Brasil) vs Koopman/Zhao (crudo, media)', art, numel(idx_ok)));
    legend(leyenda, 'Location','best');
end
sgtitle('Koopman/Zhao vs Fukuchi 2018 (Brasil) — Yun pendiente (regresion GP lenta, ver script separado)', 'FontWeight','bold');
out_png = fullfile(carpeta, 'Evaluar_vs_Fukuchi2018_KoopmanZhao_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura: %s\n', out_png);

end
