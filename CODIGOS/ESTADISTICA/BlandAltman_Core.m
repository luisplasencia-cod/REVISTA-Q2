function resultado = BlandAltman_Core(x, y, opciones)
% BLANDALTMAN_CORE  Analisis de concordancia Bland-Altman entre dos
%                    metodos de medicion, sobre pares de valores 0D
%                    (picos, ROM, tiempos, o cualquier metrica escalar
%                    extraida de una curva - ver Extraer_Features0D.m).
%
%   resultado = BlandAltman_Core(x, y)
%   resultado = BlandAltman_Core(x, y, opciones)
%
% Sin dialogos - se puede llamar desde un script interactivo o desde
% pruebas automatizadas (Test_SPM1D_BlandAltman.m, con datos sinteticos).
%
% ENTRADA
%   x, y     vectores columna o fila, misma longitud n, PAREADOS (el
%            elemento k de x y el elemento k de y son la misma unidad
%            de analisis -mismo ensayo, mismo sujeto- medida por el
%            metodo A y el metodo B respectivamente). Ejemplos de uso
%            en este proyecto: pico de Fz (%BW) de cada ensayo medido
%            por AMTI vs. el mismo ensayo re-derivado; ROM de rodilla
%            de cada sujeto medido por Kinovea vs. STT-IWS; pico de
%            inclinacion tibial del IMU de Alessandro vs. STT-IWS.
%   opciones struct opcional con cualquiera de estos campos:
%     .alpha            (default 0.05) nivel -> limites de acuerdo 95%
%     .nombre_A         (default 'Metodo A')
%     .nombre_B         (default 'Metodo B')
%     .unidad           (default '') para etiquetas de ejes, p.ej. '%BW' o 'grados'
%     .graficar         (default true)
%     .guardar_en       (default '') carpeta de exportacion; '' = no exporta
%
% METODOLOGIA (Bland & Altman, 1986, Lancet, "Statistical methods for
% assessing agreement between two methods of clinical measurement";
% formulas de IC de Bland & Altman, 1999, Stat Methods Med Res,
% "Measuring agreement in method comparison studies"):
%   1. Diferencia por par: dif = x - y
%   2. Sesgo (bias) = media(dif); SD de las diferencias = sd(dif)
%   3. Limites de acuerdo (LoA): bias +- z*SD, con z = valor critico
%      normal para 1-alpha/2 (1.96 para alpha=0.05).
%   4. IC del bias: bias +- t(n-1,1-alpha/2) * SD/sqrt(n)
%   5. IC de cada limite de acuerdo: LoA +- t(n-1,1-alpha/2) * SD*sqrt(3/n)
%      (formula de Bland & Altman 1999 para el error estandar de un LoA).
%   6. Chequeo de sesgo proporcional: regresion lineal simple de
%      dif contra la media del par (media_pares = (x+y)/2). Si la
%      pendiente es significativa (p<alpha), el sesgo NO es constante
%      en todo el rango de medicion y los LoA fijos pueden no ser
%      representativos - se reporta como advertencia, siguiendo la
%      misma recomendacion de Bland & Altman (1999).
%   7. Diagnostico de normalidad de las diferencias (Jarque-Bera) como
%      chequeo complementario del supuesto detras de bias +- 1.96*SD.
%
% SALIDA: struct `resultado` con bias, LoA, sus IC, el resultado del
% chequeo de sesgo proporcional y el diagnostico de normalidad - listo
% para citar en Metodos/Resultados.
%
% Requiere: Statistics and Machine Learning Toolbox (tinv, tcdf, norminv, jbtest).
% ==========================================================================

if nargin < 3, opciones = struct(); end

x = x(:); y = y(:);
if numel(x) ~= numel(y)
    error('x e y deben tener la misma longitud (mediciones pareadas). Se recibio %d vs %d.', numel(x), numel(y));
end
n = numel(x);
if n < 3
    error('Se necesitan al menos 3 pares para un analisis de concordancia con incertidumbre estimable.');
end

def = struct('alpha', 0.05, 'nombre_A', 'Metodo A', 'nombre_B', 'Metodo B', ...
             'unidad', '', 'graficar', true, 'guardar_en', '');
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end
alpha = opciones.alpha;

%% ---- BIAS Y LIMITES DE ACUERDO ----
dif = x - y;
media_pares = (x + y)/2;

bias = mean(dif);
sd_dif = std(dif);

z = norminv(1 - alpha/2);
LoA_sup = bias + z*sd_dif;
LoA_inf = bias - z*sd_dif;

tcrit = tinv(1-alpha/2, n-1);
SE_bias = sd_dif/sqrt(n);
CI_bias = bias + [-1 1]*tcrit*SE_bias;

SE_LoA = sd_dif*sqrt(3/n);   % Bland & Altman (1999)
CI_LoA_sup = LoA_sup + [-1 1]*tcrit*SE_LoA;
CI_LoA_inf = LoA_inf + [-1 1]*tcrit*SE_LoA;

%% ---- SESGO PROPORCIONAL (regresion dif ~ media_pares) ----
xbar = mean(media_pares); ybar = mean(dif);
Sxx = sum((media_pares-xbar).^2);
if Sxx == 0
    sesgo_prop.evaluable = false;
    sesgo_prop.pendiente = NaN; sesgo_prop.CI = [NaN NaN]; sesgo_prop.p = NaN;
    sesgo_prop.detectado = false;
else
    Sxy = sum((media_pares-xbar).*(dif-ybar));
    c1 = Sxy/Sxx;
    c0 = ybar - c1*xbar;
    resid_prop = dif - (c0 + c1*media_pares);
    df_res = n - 2;
    s2 = sum(resid_prop.^2)/df_res;
    SE_c1 = sqrt(s2/Sxx);
    t_c1 = c1/SE_c1;
    p_c1 = 2*(1 - tcdf(abs(t_c1), df_res));
    tcrit_prop = tinv(1-alpha/2, df_res);

    sesgo_prop.evaluable = true;
    sesgo_prop.pendiente = c1;
    sesgo_prop.intercepto = c0;
    sesgo_prop.CI = c1 + [-1 1]*tcrit_prop*SE_c1;
    sesgo_prop.p = p_c1;
    sesgo_prop.detectado = p_c1 < alpha;
end

%% ---- NORMALIDAD DE LAS DIFERENCIAS (Jarque-Bera) ----
h_jb = NaN; p_jb = NaN;
if n >= 4
    try
        [h_jb, p_jb] = jbtest(dif, alpha);
    catch
        % Statistics Toolbox podria no estar disponible; no detiene el analisis principal.
    end
end

%% ---- STRUCT DE SALIDA ----
resultado = struct();
resultado.n = n;
resultado.x = x; resultado.y = y;
resultado.dif = dif; resultado.media_pares = media_pares;
resultado.bias = bias; resultado.sd_dif = sd_dif;
resultado.CI_bias = CI_bias; resultado.SE_bias = SE_bias;
resultado.LoA_sup = LoA_sup; resultado.LoA_inf = LoA_inf;
resultado.CI_LoA_sup = CI_LoA_sup; resultado.CI_LoA_inf = CI_LoA_inf;
resultado.SE_LoA = SE_LoA;
resultado.sesgo_proporcional = sesgo_prop;
resultado.jarque_bera_h = h_jb; resultado.jarque_bera_p = p_jb;
resultado.alpha = alpha;
resultado.nombre_A = opciones.nombre_A; resultado.nombre_B = opciones.nombre_B;
resultado.unidad = opciones.unidad;

%% ---- REPORTE EN CONSOLA ----
fprintf('\n==================================================================\n');
fprintf('BLAND-ALTMAN - REPORTE: %s vs %s\n', opciones.nombre_A, opciones.nombre_B);
fprintf('==================================================================\n');
fprintf('n = %d pares\n', n);
fprintf('Bias (media de diferencias) = %.4f %s   IC95%% = [%.4f, %.4f]\n', ...
        bias, opciones.unidad, CI_bias(1), CI_bias(2));
fprintf('SD de diferencias = %.4f %s\n', sd_dif, opciones.unidad);
fprintf('Limites de acuerdo (%.0f%%): [%.4f, %.4f] %s\n', 100*(1-alpha), LoA_inf, LoA_sup, opciones.unidad);
fprintf('  IC95%% del LoA superior = [%.4f, %.4f] %s\n', CI_LoA_sup(1), CI_LoA_sup(2), opciones.unidad);
fprintf('  IC95%% del LoA inferior = [%.4f, %.4f] %s\n', CI_LoA_inf(1), CI_LoA_inf(2), opciones.unidad);
if sesgo_prop.evaluable
    veredicto_prop = ternary(sesgo_prop.detectado, ...
        'SE DETECTA sesgo proporcional - LoA fijos pueden no ser representativos en todo el rango', ...
        'no se detecta sesgo proporcional');
    fprintf('Sesgo proporcional: pendiente = %.4f, IC95%% = [%.4f, %.4f], p = %.4f -> %s\n', ...
            sesgo_prop.pendiente, sesgo_prop.CI(1), sesgo_prop.CI(2), sesgo_prop.p, veredicto_prop);
else
    fprintf('Sesgo proporcional: no evaluable (sin variabilidad en la media de los pares)\n');
end
if ~isnan(p_jb)
    fprintf('Normalidad de las diferencias (Jarque-Bera): p = %.3f (%s)\n', p_jb, ...
            ternary(p_jb<alpha,'se rechaza normalidad - interpretar LoA con cautela','no se rechaza normalidad'));
end
fprintf('==================================================================\n');

%% ---- GRAFICA (estilo figura de articulo, misma paleta que CALIBRACION) ----
col_datos    = [0.165 0.471 0.839];   % azul  #2a78d6
col_banda    = [0.718 0.827 0.965];   % azul claro  #b7d3f6
col_objetivo = [0.922 0.408 0.204];   % naranja  #eb6834
col_neutro   = [0.337 0.337 0.329];   % gris tinta secundaria  #52514e
col_hairline = [0.882 0.878 0.851];   % gris hairline de grilla #e1e0d9

if opciones.graficar
    fig1 = figure('Name', sprintf('Bland-Altman - %s vs %s', opciones.nombre_A, opciones.nombre_B), ...
                   'Color','w','Position',[100 100 640 480]);
    ax = axes(fig1); hold(ax,'on');

    xr = [min(media_pares) max(media_pares)];
    if diff(xr) == 0, xr = xr + [-1 1]; end
    xr_pad = xr + 0.05*diff(xr)*[-1 1];

    fill(ax, [xr_pad fliplr(xr_pad)], ...
         [CI_LoA_sup(1) CI_LoA_sup(1) CI_LoA_sup(2) CI_LoA_sup(2)], ...
         col_banda, 'FaceAlpha', 0.25, 'EdgeColor','none', 'HandleVisibility','off')
    fill(ax, [xr_pad fliplr(xr_pad)], ...
         [CI_LoA_inf(1) CI_LoA_inf(1) CI_LoA_inf(2) CI_LoA_inf(2)], ...
         col_banda, 'FaceAlpha', 0.25, 'EdgeColor','none', 'HandleVisibility','off')

    yline(ax, bias, '-', 'Color', col_datos, 'LineWidth', 1.8, 'HandleVisibility','off')
    yline(ax, LoA_sup, '--', 'Color', col_objetivo, 'LineWidth', 1.3, 'HandleVisibility','off')
    yline(ax, LoA_inf, '--', 'Color', col_objetivo, 'LineWidth', 1.3, 'HandleVisibility','off')

    scatter(ax, media_pares, dif, 40, col_datos, 'filled', 'MarkerEdgeColor','w', 'DisplayName','Pares')

    text(ax, xr_pad(1), bias, sprintf('  bias = %.3f', bias), ...
         'Color', col_datos, 'FontSize', 9, 'VerticalAlignment','bottom')
    text(ax, xr_pad(1), LoA_sup, sprintf('  +%.0f%% LoA = %.3f', 100*(1-alpha), LoA_sup), ...
         'Color', col_objetivo, 'FontSize', 9, 'VerticalAlignment','bottom')
    text(ax, xr_pad(1), LoA_inf, sprintf('  -%.0f%% LoA = %.3f', 100*(1-alpha), LoA_inf), ...
         'Color', col_objetivo, 'FontSize', 9, 'VerticalAlignment','top')

    xlabel(ax, sprintf('Media de %s y %s%s', opciones.nombre_A, opciones.nombre_B, ...
           ternary(isempty(opciones.unidad),'',[' (' opciones.unidad ')'])), 'FontSize', 11)
    ylabel(ax, sprintf('%s \x2212 %s%s', opciones.nombre_A, opciones.nombre_B, ...
           ternary(isempty(opciones.unidad),'',[' (' opciones.unidad ')'])), 'FontSize', 11)
    text(ax, 0.02, 0.02, sprintf('n = %d pares', n), ...
         'Units','normalized', 'FontSize', 9, 'Color', col_neutro, 'VerticalAlignment','bottom')

    ax.Box = 'off'; ax.TickDir = 'out'; ax.FontName = 'Arial'; ax.FontSize = 10;
    ax.GridColor = col_hairline; ax.GridAlpha = 1; ax.XColor = col_neutro; ax.YColor = col_neutro;
    xlim(ax, xr_pad);
    grid(ax,'on')
else
    fig1 = [];
end

%% ---- EXPORTAR ----
if ~isempty(opciones.guardar_en)
    save_folder = opciones.guardar_en;
    if ~exist(save_folder, 'dir'), mkdir(save_folder); end

    T = table(media_pares, dif, x, y, 'VariableNames', ...
        {'Media_par','Diferencia', matlab.lang.makeValidName(opciones.nombre_A), matlab.lang.makeValidName(opciones.nombre_B)});
    writetable(T, fullfile(save_folder, 'bland_altman_pares.csv'));

    save(fullfile(save_folder, 'bland_altman_resultado.mat'), 'resultado');

    if opciones.graficar && ~isempty(fig1)
        saveas(fig1, fullfile(save_folder,'bland_altman.png'));
    end
    fprintf('\nResultados exportados a: %s\n', save_folder);
end

end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end
