function resultado = Calibracion_Offset_Core(folder, peso_ref_kg, opciones)
% CALIBRACION_OFFSET_CORE  Nucleo analitico de la calibracion de offset vertical.
%
%   resultado = Calibracion_Offset_Core(folder, peso_ref_kg)
%   resultado = Calibracion_Offset_Core(folder, peso_ref_kg, opciones)
%
% Sin dialogos - se puede llamar tanto desde el script interactivo
% (Calibracion_Offset_Vertical.m) como desde pruebas automatizadas
% (Test_Calibracion_Offset.m, con datos sinteticos).
%
% ENTRADA
%   folder       carpeta con los archivos "Offset_<mm>_<n>.txt"
%   peso_ref_kg  masa de la carga de referencia usada (kg)
%   opciones     struct opcional con cualquiera de estos campos:
%     .fs                     (default 1000)  Hz
%     .fc                     (default 10)    Hz, corte del filtro pasabajos
%     .orden_filtro           (default 4)
%     .ventana_estable_s      (default 1.0)   s, ventana movil para detectar meseta
%     .umbral_variabilidad_N  (default 3.0)   N, SD maxima para considerar "estable"
%     .alpha                  (default 0.05)  nivel de significancia (IC 95%)
%     .graficar               (default true)
%     .guardar_en             (default '')    carpeta de exportacion; '' = no exporta
%
% METODOLOGIA ESTADISTICA (nivel curva de calibracion de instrumento,
% no solo un ajuste lineal de cortesia):
%   1. Regresion lineal simple offset(mm) -> Fz(N), ajustada sobre TODOS
%      los ensayos individuales (no sobre promedios por offset), para
%      preservar los grados de libertad reales del error.
%   2. Intervalos de confianza (95% por defecto) de pendiente e intercepto.
%   3. R^2 y R^2 ajustado.
%   4. Prueba F global de significancia de la regresion.
%   5. Prueba de falta de ajuste (lack-of-fit) via descomposicion
%      error puro / falta de ajuste, cuando hay replicas en >=3 niveles
%      de offset (Draper & Smith, "Applied Regression Analysis", 1998;
%      mismo principio que ISO 8466-1 para linealidad de curvas de
%      calibracion). Contrasta si el modelo lineal es adecuado en vez
%      de solo asumirlo.
%   6. Prediccion inversa del offset optimo (el x que hace y = Fz
%      esperado) con su intervalo de confianza propagado mediante la
%      formula clasica de calibracion inversa (Miller & Miller,
%      "Statistics for Analytical Chemistry") - no solo un valor puntual.
%   7. Diagnostico de normalidad de residuos (prueba de Jarque-Bera)
%      como chequeo complementario del supuesto de la regresion, no
%      como criterio unico de aceptacion.
%
% SALIDA: struct `resultado` con todos los campos anteriores, listo
% para citar directamente en la seccion de Metodos/Resultados.
%
% Requiere: Signal Processing Toolbox (butter, filtfilt) y
%           Statistics and Machine Learning Toolbox (tinv, tcdf, fcdf, jbtest).
% ==========================================================================

if nargin < 3, opciones = struct(); end
def = struct('fs',1000,'fc',10,'orden_filtro',4,'ventana_estable_s',1.0, ...
             'umbral_variabilidad_N',3.0,'alpha',0.05,'graficar',true,'guardar_en','');
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

fs = opciones.fs; dt = 1/fs; %#ok<NASGU>
[flt_b, flt_a] = butter(opciones.orden_filtro, opciones.fc/(fs/2), 'low');

Fz_esperado_N = peso_ref_kg * 9.81;

files = dir(fullfile(folder, 'Offset_*.txt'));
if isempty(files)
    error(['No se encontraron archivos "Offset_*.txt" en "%s". ' ...
           'Revisar la convencion de nombres.'], folder);
end

n_files = numel(files);
offset_mm   = nan(1,n_files);
Fz_media_N  = nan(1,n_files);
Fz_sd_N     = nan(1,n_files);
n_muestras_estables = nan(1,n_files);
nombres     = strings(1,n_files);
descartados = {};

%% ---- PROCESAMIENTO POR ARCHIVO (deteccion de meseta estable) ----
for i = 1:n_files
    fname = files(i).name;
    tok = regexp(fname, 'Offset_([+-]?\d+(\.\d+)?)_', 'tokens');
    if isempty(tok)
        warning('No se pudo interpretar el offset en "%s" - se omite.', fname);
        descartados{end+1} = fname; %#ok<AGROW>
        continue
    end
    off_val = str2double(tok{1}{1});

    data = readmatrix(fullfile(folder, fname));
    Fz_raw = data(:,3);
    if max(abs(Fz_raw)) < 500
        Fz_raw = Fz_raw * 4.44822;   % heuristica lbf->N (ver advertencia en el script interactivo)
    end
    Fz_filt = filtfilt(flt_b, flt_a, Fz_raw);

    n_ventana = round(opciones.ventana_estable_s * fs);
    if length(Fz_filt) < n_ventana
        warning('Archivo "%s" mas corto que la ventana de estabilidad - se omite.', fname);
        descartados{end+1} = fname; %#ok<AGROW>
        continue
    end

    n_pasos = length(Fz_filt) - n_ventana + 1;
    sd_movil = nan(1, n_pasos);
    for k = 1:n_pasos
        sd_movil(k) = std(Fz_filt(k:k+n_ventana-1));
    end

    idx_estables = find(sd_movil < opciones.umbral_variabilidad_N);
    if isempty(idx_estables)
        warning('Archivo "%s": no se encontro meseta estable (SD minima=%.2f N, umbral=%.2f N).', ...
                fname, min(sd_movil), opciones.umbral_variabilidad_N);
        descartados{end+1} = fname; %#ok<AGROW>
        continue
    end

    d = diff(idx_estables);
    cortes = find(d > 1);
    inicios = [idx_estables(1), idx_estables(cortes+1)];
    finales = [idx_estables(cortes), idx_estables(end)];
    [~, idx_mejor] = max(finales - inicios);
    ini = inicios(idx_mejor);
    fin = finales(idx_mejor) + n_ventana - 1;

    % Se usa solo la SEGUNDA MITAD del tramo estable detectado, no el
    % tramo completo: el arranque de la meseta puede incluir una cola
    % residual del transitorio de asentamiento que no se distingue del
    % ruido con el umbral de SD, y ese sesgo escala con la magnitud de
    % Fz (por tanto con el offset), generando una curvatura sistematica
    % espuria en la regresion. Confirmado con Test_Calibracion_Offset.m:
    % sin este ajuste, la prueba de falta de ajuste detectaba una
    % curvatura significativa que desaparecio al promediar solo la
    % mitad mas cercana al regimen permanente.
    punto_medio = ini + floor((fin-ini)/2);
    tramo_estable = Fz_filt(punto_medio:fin);

    offset_mm(i)  = off_val;
    Fz_media_N(i) = mean(tramo_estable);
    Fz_sd_N(i)    = std(tramo_estable);
    n_muestras_estables(i) = length(tramo_estable);
    nombres(i)    = string(fname);
end

valido = ~isnan(offset_mm);
offset_mm  = offset_mm(valido);
Fz_media_N = Fz_media_N(valido);
Fz_sd_N    = Fz_sd_N(valido);
n_muestras_estables = n_muestras_estables(valido);
nombres    = nombres(valido);

n = numel(offset_mm);
if n < 3
    error(['Se necesitan al menos 3 ensayos validos para ajustar una recta ' ...
           'con grados de libertad para estimar el error. Descartados: %s'], ...
          strjoin(descartados, ', '));
end

x = offset_mm(:);      % offset, mm  (ensayos individuales, no promedios)
y = Fz_media_N(:);     % Fz media de la meseta estable de cada ensayo, N

%% ---- REGRESION LINEAL SIMPLE ----
xbar = mean(x); ybar = mean(y);
Sxx = sum((x-xbar).^2);
Sxy = sum((x-xbar).*(y-ybar));

if Sxx == 0
    error('Todos los ensayos tienen el mismo offset - no se puede ajustar una recta. Se necesita variar el offset entre ensayos.');
end

b1 = Sxy/Sxx;                 % pendiente, N/mm
b0 = ybar - b1*xbar;          % intercepto, N

yhat  = b0 + b1*x;
resid = y - yhat;
SSE = sum(resid.^2);
SST = sum((y-ybar).^2);
SSR = SST - SSE;

df_res = n - 2;
s2 = SSE/df_res;
s  = sqrt(s2);

SE_b1 = s/sqrt(Sxx);
SE_b0 = s*sqrt(1/n + xbar^2/Sxx);

R2 = SSR/SST;
R2adj = 1 - (1-R2)*(n-1)/max(df_res,1);

alpha = opciones.alpha;
tcrit = tinv(1-alpha/2, df_res);

CI_b1 = b1 + [-1 1]*tcrit*SE_b1;
CI_b0 = b0 + [-1 1]*tcrit*SE_b0;

t_b1 = b1/SE_b1;
p_b1 = 2*(1 - tcdf(abs(t_b1), df_res));

if df_res > 0 && SSE > 0
    F_global = (SSR/1)/(SSE/df_res);
    p_F = 1 - fcdf(F_global, 1, df_res);
else
    F_global = Inf; p_F = 0;
end

%% ---- PRUEBA DE FALTA DE AJUSTE (lack-of-fit), si hay replicas ----
offsets_unicos_x = unique(x);
c = numel(offsets_unicos_x);
lof.disponible = (n > c) && (c >= 3);
lof.F = NaN; lof.p = NaN; lof.df_lof = NaN; lof.df_pe = NaN;
if lof.disponible
    SS_pe = 0;
    for j = 1:c
        idx = x == offsets_unicos_x(j);
        if sum(idx) > 1
            SS_pe = SS_pe + sum((y(idx) - mean(y(idx))).^2);
        end
    end
    df_pe  = n - c;
    SS_lof = SSE - SS_pe;
    df_lof = c - 2;
    if df_lof > 0 && df_pe > 0 && SS_pe > 0
        MS_lof = SS_lof/df_lof;
        MS_pe  = SS_pe/df_pe;
        lof.F  = MS_lof/MS_pe;
        lof.p  = 1 - fcdf(lof.F, df_lof, df_pe);
        lof.df_lof = df_lof; lof.df_pe = df_pe;
    else
        lof.disponible = false;
    end
end

%% ---- PREDICCION INVERSA: OFFSET OPTIMO ----
% x0 tal que b0 + b1*x0 = Fz_esperado_N
x0 = (Fz_esperado_N - b0)/b1;
% Formula clasica de calibracion inversa (Miller & Miller, "Statistics
% for Analytical Chemistry"). Se asume Fz_esperado_N conocido sin
% incertidumbre relevante (masa de referencia calibrada, m0 -> Inf en
% la formula general), por eso no aparece el termino 1/m0.
SE_x0 = (s/abs(b1)) * sqrt(1/n + ((x0-xbar)^2)/Sxx);
CI_x0 = x0 + [-1 1]*tcrit*SE_x0;

extrapolado = (x0 < min(x)) || (x0 > max(x));

%% ---- DIAGNOSTICO DE NORMALIDAD DE RESIDUOS (Jarque-Bera) ----
h_jb = NaN; p_jb = NaN;
if n >= 4
    try
        [h_jb, p_jb] = jbtest(resid, alpha);
    catch
        % Statistics Toolbox podria no estar disponible en otra maquina;
        % no se detiene el analisis principal por esto.
    end
end

%% ---- REPETIBILIDAD POR NIVEL DE OFFSET ----
Fz_prom_por_offset = nan(size(offsets_unicos_x));
Fz_sd_por_offset    = nan(size(offsets_unicos_x));
n_por_offset        = nan(size(offsets_unicos_x));
for j = 1:c
    idx = x == offsets_unicos_x(j);
    Fz_prom_por_offset(j) = mean(y(idx));
    Fz_sd_por_offset(j)   = std(y(idx));
    n_por_offset(j)       = sum(idx);
end
CV_repetibilidad_pct = 100 * mean(Fz_sd_por_offset ./ abs(Fz_prom_por_offset), 'omitnan');

%% ---- ARMAR STRUCT DE SALIDA ----
resultado = struct();
resultado.n_ensayos           = n;
resultado.n_niveles_offset    = c;
resultado.descartados         = {descartados};
resultado.offset_mm           = x;
resultado.Fz_media_N          = y;
resultado.nombres             = nombres;
resultado.Fz_esperado_N       = Fz_esperado_N;
resultado.peso_ref_kg         = peso_ref_kg;

resultado.b0 = b0; resultado.b1 = b1;
resultado.CI_b0 = CI_b0; resultado.CI_b1 = CI_b1;
resultado.SE_b0 = SE_b0; resultado.SE_b1 = SE_b1;
resultado.t_b1 = t_b1; resultado.p_b1 = p_b1;
resultado.R2 = R2; resultado.R2adj = R2adj;
resultado.F_global = F_global; resultado.p_F = p_F;
resultado.s = s; resultado.df_res = df_res;

resultado.lof = lof;

resultado.offset_optimo_mm = x0;
resultado.SE_offset_optimo = SE_x0;
resultado.CI95_offset_optimo = CI_x0;
resultado.extrapolado = extrapolado;

resultado.jarque_bera_h = h_jb; resultado.jarque_bera_p = p_jb;
resultado.residuos = resid;

resultado.offsets_unicos = offsets_unicos_x;
resultado.Fz_prom_por_offset = Fz_prom_por_offset;
resultado.Fz_sd_por_offset = Fz_sd_por_offset;
resultado.n_por_offset = n_por_offset;
resultado.CV_repetibilidad_pct = CV_repetibilidad_pct;

%% ---- REPORTE EN CONSOLA ----
fprintf('\n==================================================================\n');
fprintf('CALIBRACION DE OFFSET VERTICAL - REPORTE ESTADISTICO\n');
fprintf('==================================================================\n');
fprintf('Carga de referencia: %.2f kg (Fz esperado = %.2f N)\n', peso_ref_kg, Fz_esperado_N);
fprintf('Ensayos validos: %d  |  Niveles de offset distintos: %d  |  Descartados: %d\n', ...
        n, c, numel(descartados));
fprintf('\n--- Regresion lineal: Fz(N) = b0 + b1*offset(mm) ---\n');
fprintf('b1 (pendiente) = %.4f N/mm   IC95%% = [%.4f, %.4f]   p = %.2e\n', b1, CI_b1(1), CI_b1(2), p_b1);
fprintf('b0 (intercepto) = %.4f N     IC95%% = [%.4f, %.4f]\n', b0, CI_b0(1), CI_b0(2));
fprintf('R^2 = %.4f   R^2 ajustado = %.4f\n', R2, R2adj);
fprintf('F(1,%d) = %.2f, p = %.2e (significancia global de la regresion)\n', df_res, F_global, p_F);
fprintf('Error estandar residual s = %.3f N (df = %d)\n', s, df_res);
if lof.disponible
    veredicto_lof = 'NO se rechaza linealidad';
    if lof.p < alpha, veredicto_lof = 'SE RECHAZA linealidad - revisar modelo'; end
    fprintf('Falta de ajuste: F(%d,%d) = %.2f, p = %.3f -> %s\n', lof.df_lof, lof.df_pe, lof.F, lof.p, veredicto_lof);
else
    fprintf('Falta de ajuste: no evaluable (se necesitan replicas en >=3 niveles de offset)\n');
end
if ~isnan(p_jb)
    fprintf('Normalidad de residuos (Jarque-Bera): p = %.3f (%s)\n', p_jb, ternary(p_jb<alpha,'se rechaza normalidad','no se rechaza normalidad'));
end
fprintf('\n--- Offset optimo (prediccion inversa) ---\n');
fprintf('Offset optimo = %.3f mm   IC95%% = [%.3f, %.3f] mm   (SE = %.3f mm)\n', ...
        x0, CI_x0(1), CI_x0(2), SE_x0);
if extrapolado
    warning('El offset optimo (%.2f mm) cae FUERA del rango barrido [%.1f, %.1f] mm - ampliar el rango antes de dar este resultado por bueno.', ...
            x0, min(x), max(x));
end
fprintf('Repetibilidad: CV medio entre replicas del mismo offset = %.2f%%\n', CV_repetibilidad_pct);
if ~isempty(descartados)
    fprintf('\nArchivos descartados: %s\n', strjoin(descartados, ', '));
end
fprintf('==================================================================\n');

%% ---- GRAFICAS (estilo figura de articulo) ----
% Paleta accesible a daltonismo (azul/naranja, skill dataviz interno),
% y ademas distinguible en blanco y negro por estilo de linea, porque
% POI puede imprimir figuras sin color.
col_datos     = [0.165 0.471 0.839];   % azul  #2a78d6
col_banda     = [0.718 0.827 0.965];   % azul claro  #b7d3f6
col_objetivo  = [0.922 0.408 0.204];   % naranja  #eb6834
col_neutro    = [0.337 0.337 0.329];   % gris tinta secundaria  #52514e
col_hairline  = [0.882 0.878 0.851];   % gris hairline de grilla #e1e0d9

if opciones.graficar
    fig1 = figure('Name','Calibracion offset vertical - curva de calibracion', ...
                   'Color','w','Position',[100 100 640 480]);
    ax = axes(fig1); hold(ax,'on');

    x_fit = linspace(min(x), max(x), 200);
    y_fit = b0 + b1*x_fit;
    se_fit = s*sqrt(1/n + ((x_fit-xbar).^2)/Sxx);

    % Banda IC 95% de la recta (fondo, sin borde, ~10% opacidad visual)
    fill(ax, [x_fit fliplr(x_fit)], [y_fit+tcrit*se_fit, fliplr(y_fit-tcrit*se_fit)], ...
         col_banda, 'FaceAlpha', 0.35, 'EdgeColor','none', 'DisplayName','IC 95% de la recta')

    % Recta ajustada (2px)
    plot(ax, x_fit, y_fit, '-', 'Color', col_datos, 'LineWidth', 2, 'DisplayName','Ajuste lineal')

    % Fz esperado: linea de referencia, discontinua, con etiqueta directa (no solo leyenda)
    yline(ax, Fz_esperado_N, '--', 'Color', col_objetivo, 'LineWidth', 1.5, 'HandleVisibility','off')
    text(ax, min(x), Fz_esperado_N, sprintf('  Fz esperado (%.1f kg)', peso_ref_kg), ...
         'Color', col_objetivo, 'FontSize', 9, 'VerticalAlignment','bottom')

    % Offset optimo: linea vertical discontinua (estilo distinto para
    % que se distinga en B/N), con etiqueta directa que incluye el IC 95%
    xline(ax, x0, '-.', 'Color', col_neutro, 'LineWidth', 1.3, 'HandleVisibility','off')
    text(ax, x0, min(y_fit), sprintf(' Offset optimo\n %.2f mm [%.2f, %.2f]', x0, CI_x0(1), CI_x0(2)), ...
         'Color', col_neutro, 'FontSize', 9, 'VerticalAlignment','bottom', 'HorizontalAlignment','left')

    % Datos: media +- SD por nivel de offset, marcador >=8px con anillo de superficie
    errorbar(ax, offsets_unicos_x, Fz_prom_por_offset, Fz_sd_por_offset, 'o', ...
        'Color', col_datos, 'MarkerFaceColor', col_datos, 'MarkerEdgeColor','w', ...
        'MarkerSize', 8, 'LineWidth', 1.2, 'CapSize', 4, 'DisplayName','Datos (media \pm SD)')

    xlabel(ax, 'Offset vertical (mm)', 'FontSize', 11)
    ylabel(ax, 'F_z (N)', 'FontSize', 11)
    text(ax, 0.02, 0.96, sprintf('R^2 = %.3f    n = %d ensayos, %d niveles', R2, n, c), ...
         'Units','normalized', 'FontSize', 9, 'Color', col_neutro, 'VerticalAlignment','top')

    ax.Box = 'off'; ax.TickDir = 'out'; ax.FontName = 'Arial'; ax.FontSize = 10;
    ax.GridColor = col_hairline; ax.GridAlpha = 1; ax.XColor = col_neutro; ax.YColor = col_neutro;
    grid(ax,'on')
    legend(ax, 'Location','southoutside', 'Orientation','horizontal', 'Box','off', 'FontSize',8.5)

    % --- Panel de diagnostico de residuos: dos graficas estandar de regresion ---
    fig2 = figure('Name','Calibracion offset vertical - diagnostico de residuos', ...
                   'Color','w','Position',[100 100 720 340]);
    t = tiledlayout(fig2, 1, 2, 'TileSpacing','compact', 'Padding','compact');

    ax1 = nexttile(t);
    scatter(ax1, x, resid, 36, col_datos, 'filled', 'MarkerEdgeColor','w'); hold(ax1,'on')
    yline(ax1, 0, '-', 'Color', col_neutro, 'LineWidth', 1)
    xlabel(ax1, 'Offset (mm)'); ylabel(ax1, 'Residuo (N)');
    title(ax1, 'Residuos vs. offset', 'FontWeight','normal', 'FontSize', 10)
    ax1.Box='off'; ax1.TickDir='out'; ax1.GridColor = col_hairline; grid(ax1,'on')

    ax2 = nexttile(t);
    if exist('qqplot','file') == 2
        h = qqplot(ax2, resid);
        h(1).Marker = 'o'; h(1).MarkerFaceColor = col_datos; h(1).MarkerEdgeColor = 'w'; h(1).MarkerSize = 6;
        h(2).Color = col_neutro; h(2).LineWidth = 1.3;
        h(3).Color = col_neutro; h(3).LineStyle = '--';
        title(ax2, 'QQ-plot de residuos vs. normal', 'FontWeight','normal', 'FontSize', 10)
    else
        histogram(ax2, resid, max(5,round(n/2)), 'FaceColor', col_datos, 'EdgeColor','w');
        xlabel(ax2, 'Residuo (N)'); ylabel(ax2, 'Frecuencia');
        title(ax2, 'Distribucion de residuos', 'FontWeight','normal', 'FontSize', 10)
    end
    ax2.Box='off'; ax2.TickDir='out'; ax2.GridColor = col_hairline; grid(ax2,'on')
else
    fig1 = []; fig2 = [];
end

%% ---- EXPORTAR ----
if ~isempty(opciones.guardar_en)
    save_folder = opciones.guardar_en;
    if ~exist(save_folder, 'dir'), mkdir(save_folder); end

    T = table(nombres', x, y, Fz_sd_N(:), n_muestras_estables(:), resid, ...
        'VariableNames', {'Archivo','Offset_mm','Fz_media_N','Fz_SD_N','N_muestras_estables','Residuo_N'});
    writetable(T, fullfile(save_folder, 'calibracion_offset_detalle.csv'));

    save(fullfile(save_folder, 'calibracion_offset_resultado.mat'), 'resultado');

    if opciones.graficar
        if ~isempty(fig1), saveas(fig1, fullfile(save_folder,'calibracion_offset_curva.png')); end
        if ~isempty(fig2), saveas(fig2, fullfile(save_folder,'calibracion_offset_residuos.png')); end
    end
    fprintf('\nResultados exportados a: %s\n', save_folder);
end

end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end
