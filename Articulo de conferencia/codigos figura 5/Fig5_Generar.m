% ===================================================
% Fig5_Generar.m  —  TODO EL ASPECTO VISUAL DE LA FIGURA 5 VIVE AQUI
%
% Responde a R2-7, que pide anadir a la Figura 5:
%   (1) bandas de variabilidad del simulador   -> los tres paneles
%   (2) valores pico                           -> panel (c)
%   (3) anotaciones temporales                 -> panel (c)
%   (4) una curva de error o residual          -> los tres paneles
%
% Ademas, el panel (c) lleva un segundo eje vertical en NEWTONS, que
% contesta R2-8 ("report GRF in both Newtons and percentage of body
% weight") sin gastar una sola palabra del texto. No es un grafico de
% doble eje: es la MISMA magnitud en dos unidades, ligadas por BW_N.
%
% NO calcula nada: lee los .mat que producen Fig5_Datos_Plataforma.m y
% Fig5_Datos_Fuerza.m, cuya logica es identica a los scripts originales.
%
% MAQUETA MANUAL, a proposito: con tiledlayout, yyaxis recortaba el
% panel (c) al 95 % del apoyo y OuterPosition no fijaba el hueco de la
% leyenda. Con posiciones explicitas el resultado es reproducible.
% ===================================================

clear; clc; close all;

AQUI = fileparts(mfilename('fullpath'));

%% ---------------- PARAMETROS DE MAQUETA ----------------
% El ancho es el de una figura a dos columnas de IEEE. Lo que decide el
% tamano en el paper es la RELACION DE ASPECTO: LaTeX escala la figura al
% ancho de las dos columnas (463 pt medidos en el PDF compilado).
% Para ganar sitio en el articulo, bajar FIG_ALTO_IN.
FIG_ANCHO_IN = 7.16;
FIG_ALTO_IN  = 2.18;

% Margenes, en fraccion de la figura
M_IZQ   = 0.050;   % etiqueta del eje y del panel (a)
M_DER   = 0.052;   % etiquetas en newtons del panel (c)
M_SUP   = 0.105;   % franja de la leyenda
M_INF   = 0.150;   % 'Gait cycle (%)' + numeros
G_COL   = 0.076;   % separacion entre columnas (aloja las etiquetas y)
G_FIL   = 0.022;   % separacion panel principal / tira residual
H_RESID = 0.185;   % altura de la tira residual

FS     = 7;
LW_REF = 1.1;
LW_SIM = 1.1;

% Paleta
C_REF    = [0.10 0.10 0.10];      % referencia: tinta
C_REF_BD = [0.78 0.78 0.78];      % banda +-1SD de la referencia
C_SIM    = [1.00 0.00 0.00];      % rojo de la figura original (peticion del
                                  % usuario). Validado: pasa los 5 checks
                                  % frente al azul (dE 22.1 protan / 38.5 normal)
C_SIM_BD = [1.00 0.78 0.78];
C_RES    = [0.00 0.447 0.698];    % #0072B2, curva residual
C_GRID   = [0.85 0.85 0.85];

%% ---------------- DATOS ----------------
P = load(fullfile(AQUI,'Fig5_datos_plataforma.mat'));
F = load(fullfile(AQUI,'Fig5_datos_fuerza.mat'));

paneles = struct( ...
  'x',      {P.eje_ap,      P.eje_bal,      F.eje}, ...
  'ref',    {P.ref_ap,      P.ref_bal,      F.ref_media_ap}, ...
  'refsd',  {P.ref_sd_ap,   P.ref_sd_bal,   F.ref_sd_ap}, ...
  'sim',    {P.sim_ap,      P.sim_bal,      F.sim_media}, ...
  'simsd',  {P.sd_sim_ap,   P.sd_sim_bal,   F.sim_sd}, ...
  'res',    {P.residual_ap, P.residual_bal, F.residual}, ...
  'ylab',   {'Inclination angle (\circ)','Inclination angle (\circ)','F_z (%BW)'}, ...
  'reslab', {'\Delta (\circ)','\Delta (\circ)','\Delta (%BW)'}, ...
  'tag',    {'(a)','(b)','(c)'});

%% ---------------- GEOMETRIA ----------------
ANCHO_COL = (1 - M_IZQ - M_DER - 2*G_COL)/3;
ALTO_MAIN = 1 - M_SUP - M_INF - G_FIL - H_RESID;

fig = figure('Units','inches','Position',[1 1 FIG_ANCHO_IN FIG_ALTO_IN], ...
             'Color','w','PaperUnits','inches', ...
             'PaperSize',[FIG_ANCHO_IN FIG_ALTO_IN], ...
             'PaperPosition',[0 0 FIG_ANCHO_IN FIG_ALTO_IN]);

ejes_main = gobjects(1,3);

for p = 1:3
    d   = paneles(p);
    x   = d.x(:);   ref = d.ref(:);  refsd = d.refsd(:);
    sim = d.sim(:); simsd = d.simsd(:); res = d.res(:);
    xx  = [x; flipud(x)];

    izq      = M_IZQ + (p-1)*(ANCHO_COL + G_COL);
    pos_main = [izq, M_INF + H_RESID + G_FIL, ANCHO_COL, ALTO_MAIN];
    pos_res  = [izq, M_INF,                   ANCHO_COL, H_RESID];

    % ================= panel principal =================
    ax = axes('Parent',fig,'Position',pos_main); %#ok<LAXES>
    ejes_main(p) = ax;
    hold(ax,'on'); box(ax,'on'); grid(ax,'on');
    set(ax,'FontSize',FS,'LineWidth',0.5,'GridColor',C_GRID, ...
           'GridAlpha',1,'Layer','bottom','TickDir','out','XTickLabel',[]);

    hRefBand = fill(ax, xx, [ref+refsd; flipud(ref-refsd)], C_REF_BD, ...
                    'EdgeColor','none','FaceAlpha',0.85);
    hSimBand = fill(ax, xx, [sim+simsd; flipud(sim-simsd)], C_SIM_BD, ...
                    'EdgeColor','none','FaceAlpha',0.70);
    hRef = plot(ax, x, ref, '-',  'Color',C_REF, 'LineWidth',LW_REF);
    hSim = plot(ax, x, sim, '--', 'Color',C_SIM, 'LineWidth',LW_SIM);

    xlim(ax,[min(x) max(x)]);
    ylabel(ax, d.ylab, 'FontSize',FS);
    text(ax, 0.035, 0.93, d.tag, 'Units','normalized', ...
         'FontSize',FS+1,'FontWeight','bold','VerticalAlignment','top');

    % ---------- (b) minimos: hacen visible el limite mecanico ----------
    % El eje de rotacion sagital llega a -44 deg, y la Discusion ya explica
    % por eso la desviacion del inicio del balanceo. Anotarlo NO abre nada
    % nuevo: pone cifra a una afirmacion que el paper ya hace.
    if p == 2
        ylim(ax,[-60 40]);
        [rv,ri] = min(ref); [sv,si] = min(sim);
        % Mismo estilo que el panel (c): marcador + linea guia al hueco
        % libre. Los minimos caen al 66 %, junto al borde izquierdo, asi
        % que el hueco limpio esta justo encima: alli van las etiquetas.
        guia(ax, x(si), sv, 72, -4,  C_SIM, ...
             sprintf('%.1f\\circ (%.0f %%)',sv,x(si)), FS, C_REF);
        guia(ax, x(ri), rv, 72, -18, C_REF, ...
             sprintf('%.1f\\circ (%.0f %%)',rv,x(ri)), FS, C_REF);
    end

    % ---------- valores pico y anotaciones temporales: panel (c) ----------
    if p == 3
        ylim(ax,[0 218]);

        % Etiquetas en DOS bandas separadas para que no se amontonen:
        % las del simulador arriba (sobre la curva roja) y las de la
        % referencia abajo (bajo la curva negra), con linea guia.
        % Ambas zonas estan vacias, asi que ninguna guia cruza una curva.

        % --- los DOS maximos locales del simulador ---
        % Decision del usuario (09-ago): se marcan ambos. Cada etiqueta
        % lleva el valor MEDIDO en ese punto; se reporta el dato, no se
        % interpreta el patron.
        [pv,pi] = max(sim); pt = x(pi);
        [pk_s, lc_s] = findpeaks(sim, x);
        prev = find(lc_s < pt);
        if ~isempty(prev)
            [~,q] = max(pk_s(prev)); q = prev(q);
            guia(ax, lc_s(q), pk_s(q), 17, 196, C_SIM, ...
                 sprintf('%.1f (%.0f %%)',pk_s(q),lc_s(q)), FS, C_REF);
        end
        guia(ax, pt, pv, 45, 196, C_SIM, ...
             sprintf('%.1f %%BW (%.0f %%)',pv,pt), FS, C_REF);

        % --- picos y valle de la referencia (venian en el .mat original) ---
        guia(ax, F.ref_peak1_time,  F.ref_peak1_val,  17, 55, C_REF, ...
             sprintf('%.1f (%.0f %%)',F.ref_peak1_val,F.ref_peak1_time), FS, C_REF);
        guia(ax, F.ref_valley_time, F.ref_valley_val, 29, 28, C_REF, ...
             sprintf('%.1f (%.0f %%)',F.ref_valley_val,F.ref_valley_time), FS, C_REF);
        guia(ax, F.ref_peak2_time,  F.ref_peak2_val,  44, 55, C_REF, ...
             sprintf('%.1f (%.0f %%)',F.ref_peak2_val,F.ref_peak2_time), FS, C_REF);
    end

    % ================= tira residual =================
    axr = axes('Parent',fig,'Position',pos_res); %#ok<LAXES>
    hold(axr,'on'); box(axr,'on'); grid(axr,'on');
    set(axr,'FontSize',FS,'LineWidth',0.5,'GridColor',C_GRID, ...
            'GridAlpha',1,'Layer','bottom','TickDir','out');

    fill(axr, xx, [res; zeros(size(res))], C_RES, ...
         'EdgeColor','none','FaceAlpha',0.35);
    plot(axr, x, res, '-', 'Color',C_RES, 'LineWidth',0.9);
    yline(axr, 0, '-', 'Color',[0.45 0.45 0.45], 'LineWidth',0.5);

    xlim(axr,[min(x) max(x)]);
    m = max(abs(res)); ylim(axr,[-1.15*m 1.15*m]);
    ylabel(axr, d.reslab, 'FontSize',FS);
    xlabel(axr, 'Gait cycle (%)', 'FontSize',FS);

    % ---------- segundo eje en NEWTONS, solo el panel de fuerza ----------
    % Ejes superpuestos SIN datos: solo dibujan la regla derecha. Se hace
    % asi, y no con yyaxis, porque yyaxis recortaba el contenido.
    if p == 3
        eje_newtons(fig, ax,  pos_main, ylim(ax) /100*F.BW_N, 'F_z (N)',    FS, C_REF);
        eje_newtons(fig, axr, pos_res,  ylim(axr)/100*F.BW_N, '\Delta (N)', FS, C_REF);
    end
end

%% ---------------- LEYENDA, PEGADA A LOS PANELES ----------------
lg = legend(ejes_main(1), [hRefBand hRef hSimBand hSim], ...
     {'Reference \pm1 SD','Reference mean','Simulator \pm1 SD','Simulator mean'}, ...
     'FontSize',FS-1,'Orientation','horizontal','Box','off');
drawnow;
lg.Units = 'normalized';
lp = lg.Position;
lg.Position = [(1-lp(3))/2, 1 - M_SUP + (M_SUP-lp(4))/2 - 0.015, lp(3), lp(4)];
drawnow;

%% ---------------- EXPORTAR ----------------
png = fullfile(AQUI,'fig5_revisada.png');
pdf = fullfile(AQUI,'fig5_revisada.pdf');
exportgraphics(fig, png, 'Resolution',600);
exportgraphics(fig, pdf, 'ContentType','vector');

fprintf('Figura exportada:\n  %s\n  %s\n', png, pdf);
fprintf('n ensayos: angulo %d, fuerza %d\n', P.n_ensayos, F.n_ensayos);
ANCHO_COLOCADO_PT = 463;
alto = ANCHO_COLOCADO_PT * (FIG_ALTO_IN/FIG_ANCHO_IN);
fprintf('Alto al colocarla a %d pt de ancho: %.1f pt  (original 147.9 pt -> %+.1f pt)\n', ...
        ANCHO_COLOCADO_PT, alto, alto-147.9);
fprintf('Residual maximo: %.2f deg | %.2f deg | %.2f %%BW (= %.0f N)\n', ...
        max(abs(P.residual_ap)), max(abs(P.residual_bal)), ...
        max(abs(F.residual)), max(abs(F.residual))/100*F.BW_N);

%% ---------------- AUXILIARES ----------------
function guia(ax, xm, ym, xl, yl, cmark, etiqueta, FS, ctxt)
% Marca un punto y lleva su etiqueta a una zona libre con una linea guia,
% en vez de pegarla al punto. Es lo que descongestiona el panel (c).
    plot(ax, [xm xl], [ym yl], '-', 'Color',[0.55 0.55 0.55], ...
         'LineWidth',0.4, 'HandleVisibility','off');
    plot(ax, xm, ym, 'o', 'MarkerSize',3.2, 'MarkerFaceColor',cmark, ...
         'MarkerEdgeColor','w', 'LineWidth',0.4, 'HandleVisibility','off');
    text(ax, xl, yl, etiqueta, 'FontSize',FS-1, ...
         'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
         'Color',ctxt, 'BackgroundColor',[1 1 1], 'Margin',0.6);
end

function eje_newtons(fig, ax_ref, pos, ylim_N, etiqueta, FS, color)
    axN = axes('Parent',fig,'Position',pos,'Color','none', ...
               'XTick',[],'YAxisLocation','right','Box','off', ...
               'XLim',[0 1],'YLim',ylim_N,'FontSize',FS, ...
               'TickDir','out','LineWidth',0.5,'XColor','none', ...
               'YColor',color,'HitTest','off');
    ylabel(axN, etiqueta, 'FontSize',FS);
    uistack(axN,'bottom');
    linkprop([ax_ref axN],'Position');
end
