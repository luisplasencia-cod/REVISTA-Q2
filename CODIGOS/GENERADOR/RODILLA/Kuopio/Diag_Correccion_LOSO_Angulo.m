function Resumen = Diag_Correccion_LOSO_Angulo(hacer_figura)
% DIAG_CORRECCION_LOSO_ANGULO  30-ago-2026: diagnostico de un solo uso,
%                   pedido explicito del usuario - que entrega Koopman
%                   ANTES de la calibracion afin LOSO (Th_koop crudo) y
%                   cuanto "pesa" esa correccion (ganancia, offset, RMSE,
%                   r) separado en apoyo (0-60% ciclo), balanceo (60-100%)
%                   y ciclo completo.
%
%   Reusa EXACTAMENTE la misma carga y el mismo ajuste afin LOSO que
%   Evaluar_vs_Kuopio_Avance.m (mismo angulo de muslo, mismo polyfit
%   leave-one-subject-out) - no diverge de el, solo agrega el desglose
%   por fase que ese script no reporta y expone Th_koop crudo, que ese
%   script tampoco devuelve (D solo trae posicion, no angulo).
%
%   Split apoyo/balanceo puesto en 60% del ciclo: es la convencion
%   GENERICA que ya usa el resto del proyecto (Temporizacion_Core.m,
%   frac_apoyo default=0.60), no el evento especifico de Koopman por
%   sujeto (que varia con velocidad/talla y no cae siempre en el mismo
%   %ciclo - ver Koopman2014_Core.m).
%
%   No genera tabla ni test - es un diagnostico de una sola figura, mismo
%   patron que DIAG_ferber_lados.m / Diag_Pico_DobleApoyo.m.
%
%   hacer_figura (opcional, default true): false para reusar el calculo
%   (Diag_Resumen_Correccion_Fases.m) sin generar/sobrescribir la figura.
%
%   Resumen (salida opcional): struct con r_antes/r_despues/rmse_antes/
%   rmse_despues [3x1, uno por fase: apoyo/balanceo/completo] y
%   nombres_fase - agregado 30-ago-2026 para que Diag_Resumen_Correccion_
%   Fases.m pueda construir un panel comparativo sin duplicar este calculo.

if nargin < 1 || isempty(hacer_figura), hacer_figura = true; end

addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..'));
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
addpath(fileparts(mfilename('fullpath')));

carpeta = fileparts(mfilename('fullpath'));
Tmeta = readtable(fullfile(carpeta, 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id;
n = numel(ids);
pct = 0:100;
idx_apoyo    = pct <= 60;
idx_balanceo = pct > 60;

% --- Paso 1: cargar sujetos, angulo de muslo REAL y de Koopman CRUDO ---
Th_real = nan(n,101);
Th_koop = nan(n,101);   % <- salida de Koopman ANTES de cualquier correccion
ok = false(n,1);
for i = 1:n
    try
        S = Cargar_Kuopio2024_Core(ids(i));
        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1));
        antro = Estimar_Antropometria_Core(antro_in);
        K = Koopman2014_Core(S.speed_ms*3.6, antro.talla_m);
        pct_K = linspace(0,100,numel(K.cadera_flexext.angulo_deg));
        Th_koop(i,:) = interp1(pct_K, K.cadera_flexext.angulo_deg, pct, 'pchip');
        Th_real(i,:) = rad2deg(atan2(-S.dx_muslo_cm, S.dy_muslo_cm));
        ok(i) = true;
    catch ME
        fprintf('FALLO sujeto %d: %s\n', ids(i), ME.message);
    end
end
idx_ok = find(ok); n_ok = numel(idx_ok);

% --- Paso 2: calibracion afin LOSO, IDENTICA a Evaluar_vs_Kuopio_Avance.m ---
Th_cal = nan(n,101); ganancia = nan(n,1); offset = nan(n,1);
for k = 1:n_ok
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
    p = polyfit(reshape(Th_koop(otros,:),1,[]), reshape(Th_real(otros,:),1,[]), 1);
    ganancia(i) = p(1); offset(i) = p(2);
    Th_cal(i,:) = polyval(p, Th_koop(i,:));
end

fprintf('\n=== Correccion LOSO del angulo de muslo (Koopman vs Kuopio real), N=%d/%d sujetos ===\n', n_ok, n);
fprintf('ganancia media = %.3f (SD %.3f)  [1.000 = sin correccion de amplitud]\n', mean(ganancia(idx_ok)), std(ganancia(idx_ok)));
fprintf('offset medio   = %.2f grados (SD %.2f)  [0.00 = sin corrimiento]\n', mean(offset(idx_ok)), std(offset(idx_ok)));

fases = struct('nombre', {'Apoyo (0-60%)','Balanceo (60-100%)','Ciclo completo (0-100%)'}, ...
               'idx', {idx_apoyo, idx_balanceo, true(1,101)});

r_antes=nan(3,1); r_despues=nan(3,1); rmse_antes=nan(3,1); rmse_despues=nan(3,1); delta_media=nan(3,1); delta_sd=nan(3,1);
for f = 1:3
    m = fases(f).idx;
    r_a=nan(n_ok,1); r_d=nan(n_ok,1); e_a=nan(n_ok,1); e_d=nan(n_ok,1); dm=nan(n_ok,1);
    for k = 1:n_ok
        i = idx_ok(k);
        r_a(k) = corr(Th_real(i,m)', Th_koop(i,m)');
        r_d(k) = corr(Th_real(i,m)', Th_cal(i,m)');
        e_a(k) = sqrt(mean((Th_koop(i,m)-Th_real(i,m)).^2));
        e_d(k) = sqrt(mean((Th_cal(i,m) -Th_real(i,m)).^2));
        dm(k)  = mean(Th_cal(i,m) - Th_koop(i,m));  % con signo: cuanto y hacia donde mueve la correccion
    end
    r_antes(f)=mean(r_a); r_despues(f)=mean(r_d);
    rmse_antes(f)=mean(e_a); rmse_despues(f)=mean(e_d);
    delta_media(f)=mean(dm); delta_sd(f)=std(dm);
    fprintf('%-26s r %.3f -> %.3f | RMSE %5.2f -> %5.2f grados | correccion media (con signo) = %+.2f grados (SD %.2f)\n', ...
        fases(f).nombre, r_antes(f), r_despues(f), rmse_antes(f), rmse_despues(f), delta_media(f), delta_sd(f));
end

Resumen = struct('nombres_fase', {{fases.nombre}}, 'r_antes', r_antes, 'r_despues', r_despues, ...
    'rmse_antes', rmse_antes, 'rmse_despues', rmse_despues, 'unidad', 'grados');

if ~hacer_figura, return; end

% ---------------- Figura --------------------------------------------
col_koop = [0.85 0.33 0.10]; col_cal = [0.20 0.55 0.30]; col_real=[0.45 0.45 0.45];
fig = figure('Name','Correccion LOSO del angulo de muslo - antes vs despues','Position',[30 20 1500 950],'Color','w');

subplot(2,3,1); hold on; grid on; box on;
xr = [0 60 60 0]; yl = ylim_seguro(Th_real,Th_koop);
patch(xr,[yl(1) yl(1) yl(2) yl(2)],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
for k=1:n_ok, i=idx_ok(k); plot(pct, Th_real(i,:), '-', 'Color',[col_real 0.6], 'LineWidth',1); end
for k=1:n_ok, i=idx_ok(k); plot(pct, Th_koop(i,:), '-', 'Color',[col_koop 0.75], 'LineWidth',1); end
xlabel('% ciclo'); ylabel('Angulo de muslo [grados]');
title(sprintf('ANTES (Koopman crudo): r=%.3f, RMSE=%.2f grados', r_antes(3), rmse_antes(3)));
legend({'apoyo (0-60%)','real (por sujeto)','Koopman crudo'},'Location','best');

subplot(2,3,2); hold on; grid on; box on;
patch(xr,[yl(1) yl(1) yl(2) yl(2)],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
for k=1:n_ok, i=idx_ok(k); plot(pct, Th_real(i,:), '-', 'Color',[col_real 0.6], 'LineWidth',1); end
for k=1:n_ok, i=idx_ok(k); plot(pct, Th_cal(i,:), '-', 'Color',[col_cal 0.75], 'LineWidth',1); end
xlabel('% ciclo'); ylabel('Angulo de muslo [grados]');
title(sprintf('DESPUES (calibrado LOSO): r=%.3f, RMSE=%.2f grados', r_despues(3), rmse_despues(3)));
legend({'apoyo (0-60%)','real (por sujeto)','Koopman + LOSO'},'Location','best');

subplot(2,3,3); hold on; grid on; box on;
patch(xr,[-100 -100 100 100],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
Dcorr = Th_cal(idx_ok,:) - Th_koop(idx_ok,:);
m = mean(Dcorr,1); s = std(Dcorr,0,1);
fill([pct fliplr(pct)], [m+s fliplr(m-s)], [0.3 0.3 0.3], 'FaceAlpha',0.18, 'EdgeColor','none');
plot(pct, Dcorr', '-', 'Color',[0.6 0.6 0.6 0.5], 'LineWidth',0.7);
plot(pct, m, '-', 'Color','k', 'LineWidth',2.5);
yline(0,'k--');
ylim(padded_ylim(m,s));
xlabel('% ciclo'); ylabel('Correccion aplicada [grados] (cal - crudo)');
title('Tamano de la correccion a lo largo del ciclo');

etiquetas_cortas = {'Apoyo','Balanceo','Completo'};

subplot(2,3,4); hold on; grid on; box on;
Xb = [rmse_antes'; rmse_despues']';
b = bar(Xb, 'grouped');
b(1).FaceColor = col_koop; b(2).FaceColor = col_cal;
set(gca,'XTick',1:3,'XTickLabel',etiquetas_cortas);
ylabel('RMSE [grados]'); legend({'antes (crudo)','despues (LOSO)'},'Location','best');
title('RMSE por fase');
for f=1:3
    text(f-0.15, rmse_antes(f), sprintf('%.2f',rmse_antes(f)), 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',8);
    text(f+0.15, rmse_despues(f), sprintf('%.2f',rmse_despues(f)), 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',8);
end

subplot(2,3,5); hold on; grid on; box on;
Xr = [r_antes'; r_despues']';
b2 = bar(Xr, 'grouped');
b2(1).FaceColor = col_koop; b2(2).FaceColor = col_cal;
set(gca,'XTick',1:3,'XTickLabel',etiquetas_cortas);
ylabel('r (Pearson)'); ylim([min(0,min(r_antes)-0.1) 1]); legend({'antes (crudo)','despues (LOSO)'},'Location','best');
title('r por fase (invariante a la correccion afin: r no cambia)');
for f=1:3
    text(f-0.15, r_antes(f), sprintf('%.3f',r_antes(f)), 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',8);
    text(f+0.15, r_despues(f), sprintf('%.3f',r_despues(f)), 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',8);
end

% Resumen ganancia/offset: con N=47 el ajuste LOSO es casi identico entre
% sujetos (SD~0.002/0.07, ver consola) - 47 barras individuales no
% aportaban nada que el resumen media+-SD no diga ya, mas legible.
subplot(2,3,6); hold on; grid on; box on;
errorbar(1, mean(ganancia(idx_ok)), std(ganancia(idx_ok)), 'o', 'Color',col_koop, 'MarkerFaceColor',col_koop, 'MarkerSize',10, 'LineWidth',2, 'CapSize',12);
yline(1,'--','Color',col_koop);
text(1.15, mean(ganancia(idx_ok)), sprintf('ganancia = %.3f (SD %.3f)', mean(ganancia(idx_ok)), std(ganancia(idx_ok))), 'FontSize',9, 'Color',col_koop);
xlim([0.5 3]); ylim([0 1.3]);
set(gca,'XTick',[]);
yyaxis right
errorbar(2, mean(offset(idx_ok)), std(offset(idx_ok)), 's', 'Color',col_cal, 'MarkerFaceColor',col_cal, 'MarkerSize',10, 'LineWidth',2, 'CapSize',12);
yline(0,'--','Color',col_cal);
text(2.15, mean(offset(idx_ok)), sprintf('offset = %+.2f grados (SD %.2f)', mean(offset(idx_ok)), std(offset(idx_ok))), 'FontSize',9, 'Color',col_cal);
ylim([-5 5]);
ax = gca; ax.YAxis(1).Color = col_koop; ax.YAxis(2).Color = col_cal;
title(sprintf('Parametros LOSO, resumen N=%d sujetos (dispersion entre sujetos casi nula)', n_ok));

sgtitle('Angulo de muslo (Koopman 2014): salida CRUDA vs calibracion afin LOSO, vs Kuopio 2024 (N=15 real)', 'FontWeight','bold');

out_png = fullfile(carpeta, 'Diag_Correccion_LOSO_Angulo_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('\nFigura guardada en: %s\n', out_png);

end

% ------------------------------------------------------------------------
function yl = ylim_seguro(A, B)
v = [A(:); B(:)]; v = v(~isnan(v));
lo = min(v); hi = max(v); pad = 0.05*(hi-lo);
yl = [lo-pad, hi+pad];
end

function yl = padded_ylim(m, s)
lo = min(m-s); hi = max(m+s); pad = max(0.5, 0.15*(hi-lo));
yl = [lo-pad, hi+pad];
end
