function resumen = Ver_GRF_Multicaso(casos, candidato)
% VER_GRF_MULTICASO  28-ago-2026: corre Ver_GRF_y_Trayectoria.m sobre
% varios casos antropometricos y los junta en UN SOLO PNG (pedido del
% usuario: "todo en un mismo png para visualizarlo mas rapido"), acotado a
% SOLO apoyo (0-60%, pedido del usuario el mismo dia: el balanceo del pie
% trackeado no aporta nada nuevo a la GRF).
%
%   Ver_GRF_Multicaso()                  % 6 casos default (ver abajo)
%   Ver_GRF_Multicaso(casos)             % casos = cell Nx2 {antro, tag}
%
% Cada fila hace su propia verificacion (periodicidad, consistencia entre
% pipelines, Fz nunca negativo, magnitud contra literatura) via
% Ver_GRF_y_Trayectoria.m (hacer_figura=false) - misma logica, sin
% duplicarla, solo se cambia como se dibuja.
%
% SOLO 2 COLUMNAS (trayectoria + Fz), NO se dibuja GRF horizontal (28-ago-
% 2026, pedido del usuario: "yo solo mediré Fz [con la plataforma real]").
% GRF horizontal SIGUE calculandose adentro de GRF_Newton_ApoyoSimple_
% Core.m (Newton en 2D: F_x=M*a_x y F_y=M*(g+a_y) son componentes
% independientes, no se puede omitir a_x sin dejar de resolver la cadena
% cinematica completa) y se sigue usando como parte del criterio fisico
% que limpia apoyo_simple_mask_estricta (un GRF horizontal implausible es
% evidencia de artefacto numerico ahi tambien) - solo se deja de MOSTRAR
% como panel propio, porque no es lo que se va a comparar contra la
% plataforma real.
% ==========================================================================

if nargin < 1 || isempty(casos)
    casos = {
        struct('talla_m',1.55, 'masa_kg',52,   'sexo','F'),  'F 1.55m/52kg'
        struct('talla_m',1.71, 'masa_kg',68,   'sexo','M'),  'M 1.71m/68kg'
        struct('talla_m',1.866,'masa_kg',90.4, 'sexo','M'),  'M 1.87m/90kg (real, Kuopio37)'
        struct('talla_m',1.836,'masa_kg',136.1,'sexo','M'),  'M 1.84m/136kg (real, Kuopio40)'
        struct('talla_m',1.90, 'masa_kg',95,   'sexo','M'),  'M 1.90m/95kg'
        struct('talla_m',1.48, 'masa_kg',45,   'sexo','F'),  'F 1.48m/45kg (extremo, stress-test)'
    };
end
if nargin < 2 || isempty(candidato), candidato = 'Koopman'; end

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta);

nc = size(casos,1);
fig = figure('Color','w', 'Position', [40 20 1050 230*nc]);
col_koop = [0.00 0.45 0.70];

resumen = cell(nc,6);
for i = 1:nc
    antro = casos{i,1}; tag = casos{i,2};
    fprintf('\n--- Caso %d/%d: %s ---\n', i, nc, tag);
    out = Ver_GRF_y_Trayectoria(antro, candidato, false);
    tr = out.trayectoria; gr = out.grf; BW_N = out.BW_N; pct_corte = out.pct_corte_apoyo;
    mask_ok = gr.apoyo_simple_mask_estricta;
    idx_ap = gr.pct_ciclo <= pct_corte;

    vert = gr.GRF_vertical_pctBW; vert_v = vert; vert_i = vert;
    vert_v(~mask_ok) = NaN; vert_i(mask_ok) = NaN;
    horiz = gr.GRF_horizontal_pctBW; horiz_v = horiz; horiz_i = horiz;
    horiz_v(~mask_ok) = NaN; horiz_i(mask_ok) = NaN;

    n_fz_neg = sum(gr.GRF_vertical_N(mask_ok) < 0);
    vmin = min(vert(mask_ok)); vmax = max(vert(mask_ok));
    hmin = min(horiz(mask_ok)); hmax = max(horiz(mask_ok));
    resumen(i,:) = {tag, out.chequeo_periodicidad_ok, out.chequeo_consistencia_ok, n_fz_neg==0, [vmin vmax], [hmin hmax]};

    % --- columna 1: trayectoria (apoyo) ---
    subplot(nc,2,(i-1)*2+1); hold on; box on;
    plot(tr.apoyo.x_cm, tr.apoyo.y_cm, '-', 'Color', col_koop, 'LineWidth', 1.6);
    plot(tr.apoyo.x_cm(1), tr.apoyo.y_cm(1), 'ko', 'MarkerFaceColor','k', 'MarkerSize', 4);
    ylabel({tag, 'Y (cm)'}, 'FontSize', 8, 'FontWeight','bold');
    if i==1, title('Trayectoria (apoyo)'); end
    if i==nc, xlabel('X (cm)'); end
    axis equal; grid on; set(gca,'FontSize',8);

    % --- columna 2: Fz = GRF vertical (apoyo, dual N/%BW) - unica GRF que
    % se mide con la plataforma real, ver cabecera ---
    ax = subplot(nc,2,(i-1)*2+2); hold on; box on;
    yyaxis left
    ylims_grf = [min(vert_v)-8, max(vert_v)+8];
    plot(gr.pct_ciclo(idx_ap), vert_i(idx_ap), ':', 'Color',[0.6 0.6 0.6], 'LineWidth',1);
    plot(gr.pct_ciclo(idx_ap), vert_v(idx_ap), '-', 'Color', col_koop, 'LineWidth',1.8);
    yline(100,'--','Color',[0.5 0.5 0.5]);
    ylim(ylims_grf); ylabel('%BW','FontSize',9);
    ax.YAxis(1).Color = col_koop;
    yyaxis right
    ylim(ylims_grf/100*BW_N); ylabel('N','FontSize',9);
    ax.YAxis(2).Color = [0.35 0.35 0.35];
    xlim([0 pct_corte]); grid on; set(gca,'FontSize',8);
    if i==1, title('Fz - GRF vertical (apoyo)'); end
    if i==nc, xlabel('% ciclo'); end
    text(0.02,0.06, sprintf('Fz<0: %s', ternario(n_fz_neg==0,'no','SI')), 'Units','normalized', 'FontSize',7, 'Color',ternario(n_fz_neg==0,[0.2 0.5 0.2],[0.75 0.1 0.1]));
end

sgtitle(sprintf('%s | solo apoyo (0-%.0f%%) | calibrado LOSO->Kuopio | mascara con criterio fisico Fz>=0', candidato, pct_corte), ...
    'FontSize', 10, 'Interpreter', 'none');

out_png = fullfile(carpeta, 'Ver_GRF_Multicaso_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('\n\nGuardado: %s\n', out_png);

fprintf('\n=== RESUMEN ===\n');
fprintf('%-38s %10s %10s %8s %18s %18s\n', 'Caso','periodo_ok','consist_ok','Fz>=0','vertical%BW','horizontal%BW');
for i=1:nc
    fprintf('%-38s %10d %10d %8d [%5.1f,%5.1f] [%6.1f,%5.1f]\n', resumen{i,1}, resumen{i,2}, resumen{i,3}, resumen{i,4}, resumen{i,5}(1), resumen{i,5}(2), resumen{i,6}(1), resumen{i,6}(2));
end

end

function v = ternario(cond, a, b)
if cond, v = a; else, v = b; end
end
