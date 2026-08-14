function resultado = PotenciaApriori_Core(curva_base, sd_trial, opciones)
% POTENCIAAPRIORI_CORE  Potencia estadistica a priori, por simulacion
%                        Monte Carlo, para la Comparacion 4 del articulo
%                        (representatividad: sujetos nuevos agrupados vs.
%                        trayectoria fija del simulador, diseno
%                        independiente, SPM1D_Core.m).
%
%   resultado = PotenciaApriori_Core(curva_base, sd_trial)
%   resultado = PotenciaApriori_Core(curva_base, sd_trial, opciones)
%
% Sin dialogos - pensado para correr hoy con la variabilidad de las
% curvas de referencia YA existentes (sd_plat_apoyo, sd_plat_balanceo,
% sd de BaseDatos_FuerzaVertical.mat), antes de tener ningun sujeto
% nuevo capturado. Ver DISCUSION_Q2.md P-3 (candidato A) y
% ESTADO_Y_RUMBO.md - la ventana para decidir el tamano de muestra a
% priori se cierra el dia que empiece la campana de captura.
%
% ENTRADA
%   curva_base   [nPuntos x 1] forma de la curva de referencia (p.ej.
%                media_plat_apoyo, media_plat_balanceo, o media de
%                BaseDatos_FuerzaVertical.mat) - es la trayectoria fija
%                del simulador, el "grupo B" de la Comparacion 4.
%   sd_trial     [nPuntos x 1] o escalar. SD punto a punto disponible
%                HOY (sd_plat_apoyo, sd_plat_balanceo, sd de
%                BaseDatos_FuerzaVertical.mat) - variabilidad
%                ENSAYO-A-ENSAYO de un unico sujeto (el original), no
%                variabilidad ENTRE sujetos distintos. Ver advertencia
%                critica en GUIA_INTERPRETACION.md seccion 2: esta
%                simulacion probablemente SOBRESTIMA la potencia real
%                porque la variabilidad entre 15-50 personas distintas
%                suele ser mayor que la variabilidad ensayo-a-ensayo de
%                una sola persona. Recalcular en cuanto existan ~5
%                sujetos nuevos reales.
%   opciones     struct opcional con cualquiera de estos campos:
%     .efectos          vector de desplazamientos aditivos a simular,
%                        mismas unidades que curva_base (default [1 2 3 5])
%     .Ns               vector de tamanos de muestra (numero de sujetos
%                        nuevos) a evaluar (default [5 10 15 20 30 40 50])
%     .n_trials_sujeto  ensayos por sujeto nuevo simulado (default 5)
%     .n_trials_ref     ensayos de la trayectoria fija, grupo B (default 10)
%     .factor_intersujeto  factor multiplicativo sobre sd_trial para
%                        aproximar la variabilidad ENTRE sujetos, ademas
%                        de la variabilidad ensayo-a-ensayo (default 1.5,
%                        una inflacion conservadora documentada en
%                        GUIA_INTERPRETACION.md - no es un numero de la
%                        literatura, es un supuesto de trabajo explicito)
%     .n_iter           iteraciones Monte Carlo por combinacion (N,efecto)
%                        (default 200)
%     .alpha            (default 0.05)
%     .n_perm           permutaciones de SPM1D_Core dentro de cada
%                        iteracion (default 1000 - mas bajo que el
%                        default de SPM1D_Core para que la simulacion
%                        completa termine en minutos, no horas)
%     .semilla          (default 12345)
%     .graficar         (default true)
%     .guardar_en       (default '') carpeta de exportacion
%     .unidad           (default '') para etiquetas de figura/reporte
%     .potencia_objetivo (default 0.80)
%
% METODOLOGIA
%   No existe formula cerrada de potencia para el SPM no parametrico por
%   permutacion (a diferencia de una prueba t clasica) - la practica
%   estandar es estimarla por simulacion: se genera repetidamente un
%   escenario con una diferencia CONOCIDA impuesta, se corre la misma
%   prueba que se va a usar en Resultados (SPM1D_Core.m, diseno
%   independiente, igual que resultado.spm_comparacion4 de
%   Procesar_Multisujeto_Core.m), y se mide la proporcion de
%   repeticiones en que la prueba detecta la diferencia. Esa proporcion
%   ES la potencia empirica para ese (N, efecto).
%
%   Para cada combinacion de tamano de muestra N y magnitud de efecto:
%     1. Se simulan N sujetos nuevos: cada uno es curva_base + efecto
%        (desplazamiento poblacional, lo que se quiere poder detectar)
%        + un desplazamiento propio de ese sujeto (variabilidad entre
%        sujetos, sd_trial*factor_intersujeto) + ruido ensayo-a-ensayo
%        (sd_trial) en cada uno de sus n_trials_sujeto ensayos.
%     2. Se simula el grupo de referencia: n_trials_ref ensayos de
%        curva_base + ruido ensayo-a-ensayo (sd_trial), sin
%        desplazamiento - es la trayectoria fija tal cual.
%     3. Se corre SPM1D_Core en diseno independiente sobre los dos
%        conjuntos y se registra si detecto al menos un cluster
%        supraumbral.
%     4. Se repite n_iter veces y se promedia -> potencia empirica.
%   Se repite para cada (N, efecto) del grid solicitado.
%
% SALIDA: struct `resultado` con la matriz de potencia, el N minimo
% estimado para 80% de potencia por cada efecto (interpolado sobre el
% grid), la figura de curvas de potencia vs. N, y el tiempo de computo.
%
% Requiere: solo MATLAB base + SPM1D_Core.m (mismo requisito que ese
% archivo: sin toolboxes adicionales).
% ==========================================================================

if nargin < 3, opciones = struct(); end

curva_base = curva_base(:);
nPuntos = numel(curva_base);
if isscalar(sd_trial)
    sd_trial = repmat(sd_trial, nPuntos, 1);
else
    sd_trial = sd_trial(:);
    if numel(sd_trial) ~= nPuntos
        error('sd_trial debe ser escalar o tener el mismo numero de puntos que curva_base (%d). Se recibio %d.', nPuntos, numel(sd_trial));
    end
end

def = struct('efectos', [1 2 3 5], 'Ns', [5 10 15 20 30 40 50], ...
             'n_trials_sujeto', 5, 'n_trials_ref', 10, ...
             'factor_intersujeto', 1.5, 'n_iter', 200, 'alpha', 0.05, ...
             'n_perm', 1000, 'semilla', 12345, 'graficar', true, ...
             'guardar_en', '', 'unidad', '', 'potencia_objetivo', 0.80);
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

rng(opciones.semilla);
efectos = opciones.efectos(:)';
Ns = opciones.Ns(:)';
nEfectos = numel(efectos);
nNs = numel(Ns);
sd_entre = sd_trial * opciones.factor_intersujeto;

opc_spm = struct('pareado', false, 'alpha', opciones.alpha, ...
                  'n_perm', opciones.n_perm, 'graficar', false, ...
                  'guardar_en', '');

potencia = nan(nEfectos, nNs);
tic_total = tic;

fprintf('\n==================================================================\n');
fprintf('POTENCIA A PRIORI POR SIMULACION - %d efecto(s) x %d tamano(s) de muestra x %d iteraciones\n', ...
        nEfectos, nNs, opciones.n_iter);
fprintf('==================================================================\n');

for ie = 1:nEfectos
    efecto = efectos(ie);
    for in = 1:nNs
        N = Ns(in);
        n_detectados = 0;
        for it = 1:opciones.n_iter
            % ---- grupo A: N sujetos nuevos, n_trials_sujeto ensayos cada uno ----
            grupoA = nan(nPuntos, N*opciones.n_trials_sujeto);
            col = 1;
            for s = 1:N
                offset_sujeto = sd_entre .* randn(nPuntos,1);
                for t = 1:opciones.n_trials_sujeto
                    grupoA(:,col) = curva_base + efecto + offset_sujeto + sd_trial.*randn(nPuntos,1);
                    col = col + 1;
                end
            end
            % ---- grupo B: trayectoria fija, n_trials_ref ensayos ----
            grupoB = curva_base + sd_trial.*randn(nPuntos, opciones.n_trials_ref);

            r = SPM1D_Core(grupoA, grupoB, opc_spm);
            if ~isempty(r.clusters)
                n_detectados = n_detectados + 1;
            end
        end
        potencia(ie,in) = n_detectados / opciones.n_iter;
    end
    fprintf('Efecto = %.2f%s: potencia %.2f (N=%d) -> %.2f (N=%d)\n', efecto, opciones.unidad, ...
            potencia(ie,1), Ns(1), potencia(ie,end), Ns(end));
end
tiempo_ejecucion_seg = toc(tic_total);

%% ---- N MINIMO PARA POTENCIA OBJETIVO (interpolado sobre el grid) ----
N_para_objetivo = nan(1,nEfectos);
for ie = 1:nEfectos
    fila = potencia(ie,:);
    idx = find(fila >= opciones.potencia_objetivo, 1, 'first');
    if isempty(idx)
        N_para_objetivo(ie) = NaN;   % ni el N mas grande del grid alcanza el objetivo
    elseif idx == 1
        N_para_objetivo(ie) = Ns(1);
    else
        % interpolacion lineal simple entre los dos puntos del grid que rodean el cruce
        N_para_objetivo(ie) = interp1(fila(idx-1:idx), Ns(idx-1:idx), opciones.potencia_objetivo);
    end
end

%% ---- STRUCT DE SALIDA ----
resultado = struct();
resultado.Ns = Ns;
resultado.efectos = efectos;
resultado.potencia = potencia;
resultado.N_para_objetivo = N_para_objetivo;
resultado.potencia_objetivo = opciones.potencia_objetivo;
resultado.factor_intersujeto = opciones.factor_intersujeto;
resultado.n_iter = opciones.n_iter;
resultado.tiempo_ejecucion_seg = tiempo_ejecucion_seg;

fprintf('------------------------------------------------------------------\n');
for ie = 1:nEfectos
    if isnan(N_para_objetivo(ie))
        fprintf('Efecto = %.2f%s: NINGUN N del grid alcanza %.0f%% de potencia (maximo evaluado: N=%d -> %.2f)\n', ...
                efectos(ie), opciones.unidad, 100*opciones.potencia_objetivo, Ns(end), potencia(ie,end));
    else
        fprintf('Efecto = %.2f%s: N minimo estimado para %.0f%% de potencia = %.1f\n', ...
                efectos(ie), opciones.unidad, 100*opciones.potencia_objetivo, N_para_objetivo(ie));
    end
end
fprintf('Tiempo de computo: %.1f s\n', tiempo_ejecucion_seg);
fprintf('==================================================================\n');

%% ---- FIGURA: curvas de potencia vs. N, una linea por efecto ----
col_datos    = [0.165 0.471 0.839];
col_objetivo = [0.922 0.408 0.204];
col_neutro   = [0.337 0.337 0.329];
col_hairline = [0.882 0.878 0.851];
paleta = [0.165 0.471 0.839; 0.204 0.596 0.318; 0.702 0.373 0.780; 0.847 0.678 0.129; 0.878 0.318 0.318];

fig1 = [];
if opciones.graficar
    fig1 = figure('Name','Potencia a priori vs. N','Color','w','Position',[100 100 640 480]);
    ax = axes(fig1); hold(ax,'on');
    for ie = 1:nEfectos
        c = paleta(mod(ie-1,size(paleta,1))+1,:);
        plot(ax, Ns, potencia(ie,:), '-o', 'Color', c, 'LineWidth', 1.8, 'MarkerFaceColor', c, ...
             'DisplayName', sprintf('efecto = %.2g%s', efectos(ie), opciones.unidad));
    end
    yline(ax, opciones.potencia_objetivo, '--', 'Color', col_objetivo, 'LineWidth', 1.3, ...
          'Label', sprintf('objetivo %.0f%%', 100*opciones.potencia_objetivo), 'LabelHorizontalAlignment','left');
    xlabel(ax, 'Tamano de muestra (N sujetos nuevos)', 'FontSize', 11)
    ylabel(ax, 'Potencia empirica (P deteccion)', 'FontSize', 11)
    ylim(ax, [0 1.02])
    ax.Box = 'off'; ax.TickDir = 'out'; ax.FontName = 'Arial'; ax.FontSize = 10;
    ax.GridColor = col_hairline; ax.GridAlpha = 1; ax.XColor = col_neutro; ax.YColor = col_neutro;
    grid(ax,'on')
    legend(ax, 'Location','southoutside', 'Orientation','horizontal', 'Box','off', 'FontSize',8.5)
end
resultado.figura = fig1;

%% ---- EXPORTAR ----
if ~isempty(opciones.guardar_en)
    save_folder = opciones.guardar_en;
    if ~exist(save_folder, 'dir'), mkdir(save_folder); end
    T = array2table([Ns(:) potencia'], 'VariableNames', ...
        [{'N'}, arrayfun(@(e) sprintf('potencia_efecto_%g', e), efectos, 'UniformOutput', false)]);
    writetable(T, fullfile(save_folder, 'potencia_apriori.csv'));
    save(fullfile(save_folder, 'potencia_apriori_resultado.mat'), 'resultado');
    if opciones.graficar && ~isempty(fig1)
        saveas(fig1, fullfile(save_folder, 'potencia_apriori_curva.png'));
    end
    fprintf('Resultados exportados a: %s\n', save_folder);
end

end
