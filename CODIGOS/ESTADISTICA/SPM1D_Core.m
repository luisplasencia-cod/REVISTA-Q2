function resultado = SPM1D_Core(curvasA, curvasB, opciones)
% SPM1D_CORE  Statistical Parametric Mapping 1D, version no parametrica
%             (permutacion), para comparar dos conjuntos de curvas de
%             ciclo de marcha punto a punto.
%
%   resultado = SPM1D_Core(curvasA, curvasB)
%   resultado = SPM1D_Core(curvasA, curvasB, opciones)
%
% Sin dialogos - se puede llamar tanto desde un script interactivo como
% desde pruebas automatizadas (Test_SPM1D_BlandAltman.m, con datos
% sinteticos) o desde cualquier script futuro que ya tenga sus dos
% matrices de curvas cargadas (Kinovea vs STT-IWS, IMU Alessandro vs
% STT-IWS, sujeto reprogramado vs captura propia, etc.).
%
% ENTRADA
%   curvasA, curvasB   matrices [nPuntos x nEnsayos], mismo nPuntos.
%                       - Diseno PAREADO (mismo ensayo/ciclo medido por
%                         ambos metodos, o simulador vs referencia
%                         ensayo-a-ensayo): curvasA y curvasB deben tener
%                         el mismo numero de columnas Y estar en el
%                         mismo orden (columna k de A corresponde a
%                         columna k de B).
%                       - Diseno INDEPENDIENTE (dos grupos que no se
%                         corresponden 1 a 1, p.ej. sujetos nuevos vs.
%                         trayectoria fija del simulador): nA y nB
%                         pueden diferir.
%   opciones           struct opcional con cualquiera de estos campos:
%     .pareado         (default: true si nA==nB, false si no)
%     .alpha           (default 0.05)
%     .n_perm          (default 10000) maximo de permutaciones si no se
%                       hace enumeracion exacta
%     .eje_x           (default linspace(0,100,nPuntos)') vector de
%                       %ciclo de marcha para reportar clusters
%     .semilla         (default 12345) para reproducibilidad del
%                       muestreo Monte Carlo cuando no hay enumeracion
%                       exacta
%     .graficar        (default true)
%     .guardar_en      (default '') carpeta de exportacion; '' = no exporta
%     .nombre_A        (default 'A') para leyendas/reporte
%     .nombre_B        (default 'B')
%     .unidad_y        (default '') para etiqueta del eje Y de la figura
%
% METODOLOGIA
%   SPM no parametrico por permutacion (Nichols & Holmes, 2002,
%   "Nonparametric permutation tests for functional neuroimaging: a
%   primer with examples", Human Brain Mapping) en vez de la version
%   parametrica clasica de random field theory (Friston et al., el
%   paquete spm1d de Pataky). Se elige la version por permutacion
%   porque el supuesto de estimacion de suavizado (FWHM) del RFT
%   parametrico es poco confiable con el tamano de muestra esperado en
%   este proyecto (5-10 ensayos por sujeto, 2-3 sujetos nuevos); el
%   propio Pataky recomienda permutacion para n chico
%   (Pataky, Vanrenterghem & Robinson, 2015, J Biomech, "Zero- vs.
%   one-dimensional, parametric vs. non-parametric, and confidence
%   interval vs. hypothesis testing procedures in veterinary
%   biomechanics").
%
%   1. Estadistico observado t(i) en cada punto i del ciclo:
%        - Pareado:      t(i) = mean(diff(i,:)) / (std(diff(i,:))/sqrt(n))
%        - Independiente: t(i) de dos muestras, varianza combinada
%          (pooled), formula clasica de Student.
%   2. Distribucion nula del estadistico MAXIMO |t| a lo largo de todo
%      el ciclo, generada por permutacion:
%        - Pareado:       se invierte el signo de cada diferencia por
%                          ensayo al azar (sign-flip), 2^n combinaciones
%                          posibles.
%        - Independiente: se reasignan al azar las etiquetas de grupo
%                          entre las nA+nB curvas combinadas.
%      Si el numero de combinaciones posibles es manejable (<=20000) se
%      enumeran TODAS (prueba exacta); si no, se muestrean n_perm al azar
%      (Monte Carlo).
%   3. El umbral critico es el cuantil (1-alpha) de esa distribucion del
%      maximo -> controla el error familiar (FWER) a lo largo de las
%      101 (o nPuntos) comparaciones simultaneas, sin asumir nada sobre
%      la suavidad de la curva.
%   4. Clusters supraumbral: tramos contiguos donde |t_obs| supera el
%      umbral. El p-valor de cada cluster es la proporcion de la
%      distribucion nula del maximo que iguala o supera el pico |t| de
%      ese cluster (mismo principio que el "height threshold" de
%      spm1d con correccion FWE, sin descomposicion cluster-mass/RESEL
%      completa - queda documentado como tal en la Guia de
%      interpretacion, no se presenta como spm1d parametrico clasico).
%
% SALIDA: struct `resultado` con el estadistico, el umbral, los
% clusters detectados (inicio/fin en %ciclo, pico, p-valor) y el
% porcentaje del ciclo con diferencia significativa - listo para citar
% en Metodos/Resultados.
%
% Requiere: solo MATLAB base (sin toolboxes adicionales).
% ==========================================================================

if nargin < 3, opciones = struct(); end

[nPuntos_A, nA] = size(curvasA);
[nPuntos_B, nB] = size(curvasB);
if nPuntos_A ~= nPuntos_B
    error('curvasA y curvasB deben tener el mismo numero de puntos por curva (filas). Se recibio %d vs %d.', nPuntos_A, nPuntos_B);
end
nPuntos = nPuntos_A;

def = struct('pareado', nA==nB, 'alpha', 0.05, 'n_perm', 10000, ...
             'eje_x', linspace(0,100,nPuntos)', 'semilla', 12345, ...
             'graficar', true, 'guardar_en', '', ...
             'nombre_A', 'A', 'nombre_B', 'B', 'unidad_y', '');
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

if opciones.pareado && nA ~= nB
    error('Diseno pareado solicitado pero curvasA (%d ensayos) y curvasB (%d ensayos) no tienen el mismo numero de columnas.', nA, nB);
end
if opciones.pareado && nA < 5
    warning('Diseno pareado con solo %d ensayos: la prueba exacta por signo tendra muy pocas combinaciones (2^%d = %d) y el umbral sera poco sensible. Interpretar con cautela.', nA, nA, 2^nA);
end

rng(opciones.semilla);
eje_x = opciones.eje_x(:);
alpha = opciones.alpha;

%% ---- ESTADISTICO OBSERVADO Y PERMUTACIONES ----
if opciones.pareado
    n = nA;
    dif = curvasA - curvasB;                      % [nPuntos x n]
    t_obs = local_t_pareado(dif);

    n_combin_exacta = 2^n;
    usar_exacta = n_combin_exacta <= 20000;
    if usar_exacta
        n_perm_efectivas = n_combin_exacta;
        signos_todos = local_enumerar_signos(n);   % [n_combin x n], +-1
    else
        n_perm_efectivas = opciones.n_perm;
    end

    t_max_nulo = nan(n_perm_efectivas,1);
    for p = 1:n_perm_efectivas
        if usar_exacta
            s = signos_todos(p,:);
        else
            s = sign(rand(1,n) - 0.5); s(s==0) = 1;
        end
        dif_perm = dif .* s;
        t_perm = local_t_pareado(dif_perm);
        t_max_nulo(p) = max(abs(t_perm));
    end
else
    n = nA + nB;
    pool = [curvasA, curvasB];                     % [nPuntos x n]
    t_obs = local_t_independiente(curvasA, curvasB);

    n_combin_exacta = nchoosek(n, nA);
    usar_exacta = n_combin_exacta <= 20000;
    if usar_exacta
        n_perm_efectivas = n_combin_exacta;
        combos = nchoosek(1:n, nA);
    else
        n_perm_efectivas = opciones.n_perm;
    end

    t_max_nulo = nan(n_perm_efectivas,1);
    for p = 1:n_perm_efectivas
        if usar_exacta
            idxA = combos(p,:);
        else
            ord = randperm(n);
            idxA = ord(1:nA);
        end
        idxB = setdiff(1:n, idxA);
        t_perm = local_t_independiente(pool(:,idxA), pool(:,idxB));
        t_max_nulo(p) = max(abs(t_perm));
    end
end

umbral = quantile(t_max_nulo, 1-alpha);

%% ---- DETECCION DE CLUSTERS SUPRAUMBRAL ----
supra = abs(t_obs) > umbral;
clusters = struct('idx_ini',{},'idx_fin',{},'x_ini',{},'x_fin',{},'t_pico',{},'p_valor',{});
if any(supra)
    d = diff([0; supra(:); 0]);
    inicios = find(d==1);
    finales = find(d==-1) - 1;
    for c = 1:numel(inicios)
        ini = inicios(c); fin = finales(c);
        t_pico = max(abs(t_obs(ini:fin)));
        p_valor = (sum(t_max_nulo >= t_pico) + 1) / (n_perm_efectivas + 1);
        clusters(end+1) = struct( ...
            'idx_ini', ini, 'idx_fin', fin, ...
            'x_ini', eje_x(ini), 'x_fin', eje_x(fin), ...
            't_pico', t_pico, 'p_valor', p_valor); %#ok<AGROW>
    end
end
pct_ciclo_significativo = 100 * sum(supra) / nPuntos;

%% ---- STRUCT DE SALIDA ----
resultado = struct();
resultado.pareado = opciones.pareado;
resultado.nA = nA; resultado.nB = nB;
resultado.eje_x = eje_x;
resultado.t_obs = t_obs;
resultado.umbral = umbral;
resultado.alpha = alpha;
resultado.n_perm_efectivas = n_perm_efectivas;
resultado.prueba_exacta = usar_exacta;
resultado.t_max_nulo = t_max_nulo;
resultado.clusters = clusters;
resultado.pct_ciclo_significativo = pct_ciclo_significativo;
resultado.nombre_A = opciones.nombre_A;
resultado.nombre_B = opciones.nombre_B;

%% ---- REPORTE EN CONSOLA ----
fprintf('\n==================================================================\n');
fprintf('SPM1D NO PARAMETRICO (permutacion) - REPORTE\n');
fprintf('==================================================================\n');
fprintf('%s vs %s | diseno %s | nA=%d, nB=%d\n', opciones.nombre_A, opciones.nombre_B, ...
        ternary(opciones.pareado,'pareado','independiente'), nA, nB);
fprintf('Permutaciones: %d (%s) | alpha = %.3f | umbral critico |t| = %.3f\n', ...
        n_perm_efectivas, ternary(usar_exacta,'exactas','Monte Carlo'), alpha, umbral);
if isempty(clusters)
    fprintf('Sin clusters supraumbral: ninguna diferencia significativa en todo el ciclo.\n');
else
    fprintf('%d cluster(es) supraumbral | %.1f%% del ciclo con diferencia significativa:\n', ...
            numel(clusters), pct_ciclo_significativo);
    for c = 1:numel(clusters)
        fprintf('  [%d] %.1f%% - %.1f%% del ciclo | t_pico = %.3f | p = %.4f\n', ...
                c, clusters(c).x_ini, clusters(c).x_fin, clusters(c).t_pico, clusters(c).p_valor);
    end
end
fprintf('==================================================================\n');

%% ---- GRAFICA (estilo figura de articulo, misma paleta que CALIBRACION) ----
col_datos    = [0.165 0.471 0.839];   % azul  #2a78d6
col_banda    = [0.718 0.827 0.965];   % azul claro  #b7d3f6
col_objetivo = [0.922 0.408 0.204];   % naranja  #eb6834
col_neutro   = [0.337 0.337 0.329];   % gris tinta secundaria  #52514e
col_hairline = [0.882 0.878 0.851];   % gris hairline de grilla #e1e0d9

if opciones.graficar
    fig1 = figure('Name', sprintf('SPM1D - %s vs %s', opciones.nombre_A, opciones.nombre_B), ...
                   'Color','w','Position',[100 100 640 480]);
    ax = axes(fig1); hold(ax,'on');

    plot(ax, eje_x, t_obs, '-', 'Color', col_datos, 'LineWidth', 2, 'DisplayName','SPM\{t\}')
    yline(ax, umbral, '--', 'Color', col_objetivo, 'LineWidth', 1.3, 'HandleVisibility','off')
    yline(ax, -umbral, '--', 'Color', col_objetivo, 'LineWidth', 1.3, 'HandleVisibility','off')
    text(ax, eje_x(1), umbral, sprintf('  umbral critico (\\alpha=%.2f)', alpha), ...
         'Color', col_objetivo, 'FontSize', 9, 'VerticalAlignment','bottom')

    for c = 1:numel(clusters)
        xx = [clusters(c).x_ini, clusters(c).x_fin, clusters(c).x_fin, clusters(c).x_ini];
        yl = ylim(ax);
        yy = [yl(1) yl(1) yl(2) yl(2)];
        fill(ax, xx, yy, col_banda, 'FaceAlpha', 0.35, 'EdgeColor','none', 'HandleVisibility','off')
    end

    xlabel(ax, 'Ciclo de marcha (%)', 'FontSize', 11)
    ylabel(ax, 'SPM\{t\}', 'FontSize', 11)
    text(ax, 0.02, 0.96, sprintf('%.1f%% del ciclo significativo (%d cluster(es))', ...
         pct_ciclo_significativo, numel(clusters)), ...
         'Units','normalized', 'FontSize', 9, 'Color', col_neutro, 'VerticalAlignment','top')

    ax.Box = 'off'; ax.TickDir = 'out'; ax.FontName = 'Arial'; ax.FontSize = 10;
    ax.GridColor = col_hairline; ax.GridAlpha = 1; ax.XColor = col_neutro; ax.YColor = col_neutro;
    grid(ax,'on')
    legend(ax, 'Location','southoutside', 'Orientation','horizontal', 'Box','off', 'FontSize',8.5)
else
    fig1 = [];
end

%% ---- EXPORTAR ----
if ~isempty(opciones.guardar_en)
    save_folder = opciones.guardar_en;
    if ~exist(save_folder, 'dir'), mkdir(save_folder); end

    T = table(eje_x, t_obs, 'VariableNames', {'PctCiclo','SPM_t'});
    writetable(T, fullfile(save_folder, 'spm1d_curva.csv'));

    if ~isempty(clusters)
        Tc = struct2table(clusters);
        writetable(Tc, fullfile(save_folder, 'spm1d_clusters.csv'));
    end

    save(fullfile(save_folder, 'spm1d_resultado.mat'), 'resultado');

    if opciones.graficar && ~isempty(fig1)
        saveas(fig1, fullfile(save_folder,'spm1d_curva.png'));
    end
    fprintf('\nResultados exportados a: %s\n', save_folder);
end

end

%% ===================================================
% FUNCIONES LOCALES
%% ===================================================

function t = local_t_pareado(dif)
% dif: [nPuntos x n]. t(i) = mean(dif(i,:)) / (std(dif(i,:))/sqrt(n))
% Cuando la varianza entre ensayos es exactamente cero en algun punto
% (diferencia identica en todos los ensayos - solo pasa con datos
% sinteticos sin ruido, o sensores duplicados), dividir por sd~eps
% produce un t astronomico sin significado practico (ver Test 2 de
% Test_SPM1D_BlandAltman.m). Se acota |t| a T_MAX: no cambia ninguna
% conclusion (con datos reales el ruido nunca es exactamente cero, y
% cualquier |t| de esa magnitud ya cae en el extremo de cualquier
% distribucion nula), pero mantiene los numeros interpretables en el
% reporte, la figura y los CSV exportados.
T_MAX = 1000;
n = size(dif,2);
m = mean(dif,2);
sd = std(dif,0,2);
sd(sd==0) = eps;
t = m ./ (sd/sqrt(n));
t = max(min(t, T_MAX), -T_MAX);
end

function t = local_t_independiente(A, B)
% A: [nPuntos x nA], B: [nPuntos x nB]. t de dos muestras, varianza pooled.
% Mismo acotamiento que local_t_pareado y por la misma razon.
T_MAX = 1000;
nA = size(A,2); nB = size(B,2);
mA = mean(A,2); mB = mean(B,2);
vA = var(A,0,2); vB = var(B,0,2);
sp2 = ((nA-1)*vA + (nB-1)*vB) / (nA+nB-2);
sp2(sp2==0) = eps;
t = (mA - mB) ./ sqrt(sp2*(1/nA + 1/nB));
t = max(min(t, T_MAX), -T_MAX);
end

function signos = local_enumerar_signos(n)
% Enumera las 2^n combinaciones de +-1 para el sign-flip exacto.
n_combin = 2^n;
signos = ones(n_combin, n);
for i = 1:n
    bloque = 2^(i-1);
    patron = [-ones(bloque,1); ones(bloque,1)];
    signos(:,i) = repmat(patron, n_combin/(2*bloque), 1);
end
end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end
