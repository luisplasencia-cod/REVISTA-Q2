function resultado = Procesar_Multisujeto_Core(datosSujetos, trayectoria_fija, opciones)
% PROCESAR_MULTISUJETO_CORE  Motor de calculo por lote para sujetos
%                              nuevos (preparado para 15-20 sujetos).
%                              Sin dialogos - se puede llamar desde
%                              pruebas automatizadas con datos sinteticos
%                              (Test_Procesar_Multisujeto.m) o desde
%                              Cargar_Sujetos_CSV.m con datos reales.
%
%   resultado = Procesar_Multisujeto_Core(datosSujetos)
%   resultado = Procesar_Multisujeto_Core(datosSujetos, trayectoria_fija)
%   resultado = Procesar_Multisujeto_Core(datosSujetos, trayectoria_fija, opciones)
%
% ENTRADA
%   datosSujetos       struct array (1 x nSujetos), cada elemento:
%     .id                texto identificador del sujeto
%     .eje_x             vector [nPuntos x 1], %ciclo o %fase - MISMO
%                        para todos los sujetos (mismo recorte de fase)
%     .trials_propios    matriz [nPuntos x nEnsayos] - captura natural
%                        del sujeto (la que se usaria para programar su
%                        propio CSV)
%     .trials_simulador  matriz [nPuntos x nEnsayos_sim], o [] - salida
%                        del simulador YA reprogramado con el CSV de
%                        este sujeto (Comparacion 3). Vacio = todavia no
%                        se reprogramo a este sujeto; se calculan solo
%                        las metricas que no lo requieren.
%   trayectoria_fija   matriz [nPuntos x nEnsayosFija] con los ensayos de
%                       la salida FIJA del simulador (la trayectoria del
%                       sujeto original, SIN reprogramar) - o [] para
%                       saltar la Comparacion 4 por completo.
%   opciones            struct opcional:
%     .alpha            (default 0.05), pasa a SPM1D_Core
%     .n_perm           (default 10000), pasa a SPM1D_Core
%     .semilla          (default 12345), pasa a SPM1D_Core
%     .graficar         (default true)
%     .guardar_en       (default '') carpeta de exportacion; '' = no exporta
%
% SALIDA: struct `resultado` con:
%   .por_sujeto            tabla resumen, una fila por sujeto: RMSEnorm,
%                          r, %+-1SD, ICC(3,1), clasificacion global y
%                          %ciclo significativo de SPM1D (Comparacion 3 -
%                          robustez de la fidelidad de seguimiento)
%   .spm_por_sujeto        cell array con el struct completo de
%                          SPM1D_Core por sujeto (clusters, figura, etc.)
%   .spm_comparacion4      resultado de SPM1D_Core en diseno
%                          INDEPENDIENTE, todos los sujetos agrupados vs.
%                          trayectoria_fija (representatividad) - [] si
%                          trayectoria_fija no se proporciono
%   .variabilidad_grupo    struct con media/SD/CV de pico y ROM entre
%                          sujetos (variabilidad natural del grupo,
%                          contexto de la Comparacion 6)
%   .n_sujetos             numero de sujetos procesados
%   .tiempo_ejecucion_seg  tiempo total de computo - se reporta para
%                          verificar que el pipeline escala bien a
%                          15-20 sujetos (ver Test_Procesar_Multisujeto.m,
%                          prueba de escala)
%
% Reutiliza, no duplica:
%   CODIGOS/VALIDACIONES/Calcular_Metricas_Curva.m  (RMSEnorm, r, %+-1SD, ICC)
%   CODIGOS/ESTADISTICA/SPM1D_Core.m                (SPM no parametrico)
%   CODIGOS/ESTADISTICA/Extraer_Features0D.m        (pico/ROM/tiempo-al-pico)
%
% Ver CODIGOS/MULTISUJETO/GUIA_INTERPRETACION.md para el significado de
% cada campo de salida, checklist de confiabilidad y ejemplos de texto
% para el manuscrito.
% ==========================================================================

tic_total = tic;

% ---- localizar y agregar las carpetas de las que depende (funciona sin
% importar cual sea el directorio de trabajo actual de MATLAB) ----
carpeta_actual       = fileparts(mfilename('fullpath'));
carpeta_validaciones = fullfile(carpeta_actual, '..', 'VALIDACIONES');
carpeta_estadistica  = fullfile(carpeta_actual, '..', 'ESTADISTICA');
if exist(carpeta_validaciones, 'dir'), addpath(carpeta_validaciones); end
if exist(carpeta_estadistica,  'dir'), addpath(carpeta_estadistica);  end

if nargin < 2, trayectoria_fija = []; end
if nargin < 3, opciones = struct(); end

def = struct('alpha',0.05, 'n_perm',10000, 'semilla',12345, ...
             'graficar',true, 'guardar_en','');
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

nSujetos = numel(datosSujetos);
if nSujetos < 1
    error('datosSujetos debe tener al menos un sujeto.');
end

nPuntos = numel(datosSujetos(1).eje_x);
for s = 1:nSujetos
    if numel(datosSujetos(s).eje_x) ~= nPuntos || size(datosSujetos(s).trials_propios,1) ~= nPuntos
        error('Sujeto %s: eje_x/trials_propios no tiene %d puntos. Todos los sujetos deben compartir el mismo eje_x (mismo recorte de fase).', ...
              char(string(datosSujetos(s).id)), nPuntos);
    end
end
eje_x = datosSujetos(1).eje_x(:);

opciones_spm = struct('alpha',opciones.alpha, 'n_perm',opciones.n_perm, ...
                       'semilla',opciones.semilla, 'eje_x',eje_x, ...
                       'graficar',opciones.graficar, 'unidad_y','');

%% ---- POR SUJETO: Comparacion 3 (robustez de la fidelidad de seguimiento) ----
filas          = cell(nSujetos, 1);
spm_por_sujeto = cell(nSujetos, 1);
pico_sujeto    = nan(nSujetos,1);
rom_sujeto     = nan(nSujetos,1);

for s = 1:nSujetos
    suj      = datosSujetos(s);
    id_str   = char(string(suj.id));
    exp_fase = mean(suj.trials_propios, 2);
    sd_fase  = std(suj.trials_propios, 0, 2);
    sd_fase(sd_fase==0) = eps;   % evita division entre cero si un sujeto no tiene variabilidad en algun punto (mismo criterio que SPM1D_Core)

    feat           = Extraer_Features0D(suj.trials_propios, eje_x);
    pico_sujeto(s) = mean(feat.pico);
    rom_sujeto(s)  = mean(feat.ROM);

    tiene_sim = isfield(suj,'trials_simulador') && ~isempty(suj.trials_simulador);

    if tiene_sim
        sim_fase = mean(suj.trials_simulador, 2);
        m = calcular_metricas_curva(sim_fase, exp_fase, sd_fase, suj.trials_simulador, id_str);

        % Mismo patron ya documentado para "SPM de una muestra" en
        % CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md: la referencia (la
        % captura propia del sujeto) no tiene estructura de ensayos
        % propia aqui, asi que se repite como columna constante para
        % poder usar el branch pareado de SPM1D_Core (cada ensayo del
        % simulador se compara contra el mismo objetivo fijo).
        nA_sim      = size(suj.trials_simulador,2);
        curvasB_rep = repmat(exp_fase, 1, nA_sim);

        opc_s          = opciones_spm;
        opc_s.pareado  = true;
        opc_s.nombre_A = [id_str ' (simulador)'];
        opc_s.nombre_B = [id_str ' (captura propia)'];
        if ~isempty(opciones.guardar_en)
            opc_s.guardar_en = fullfile(opciones.guardar_en, 'Comparacion3_por_sujeto', id_str);
        end
        spm_s = SPM1D_Core(suj.trials_simulador, curvasB_rep, opc_s);
        spm_pct = spm_s.pct_ciclo_significativo;
    else
        m = struct('RMSEnorm',NaN, 'r',NaN, 'pct_1sd',NaN, 'ICC',NaN, ...
                    'clasificacion_global','Sin reprogramar aun');
        spm_s   = [];
        spm_pct = NaN;
    end

    filas{s}          = {id_str, m.RMSEnorm, m.r, m.pct_1sd, m.ICC, m.clasificacion_global, spm_pct};
    spm_por_sujeto{s}  = spm_s;
end

tabla_resumen = cell2table(vertcat(filas{:}), 'VariableNames', ...
    {'Sujeto','RMSEnorm','r','pct_1SD','ICC','Clasificacion','SPM_pct_ciclo_signif'});

%% ---- GRUPO: Comparacion 4 (representatividad, diseno independiente) ----
if ~isempty(trayectoria_fija)
    pool_propios = [datosSujetos.trials_propios];   % concatena las columnas de todos los sujetos

    opc_g          = opciones_spm;
    opc_g.pareado  = false;   % forzado: los grupos no se corresponden 1 a 1 aunque coincida el conteo de columnas
    opc_g.nombre_A = 'Sujetos nuevos (captura natural, agrupados)';
    opc_g.nombre_B = 'Trayectoria fija del simulador';
    if ~isempty(opciones.guardar_en)
        opc_g.guardar_en = fullfile(opciones.guardar_en, 'Comparacion4_representatividad');
    end
    spm_comparacion4 = SPM1D_Core(pool_propios, trayectoria_fija, opc_g);
else
    spm_comparacion4 = [];
end

%% ---- GRUPO: variabilidad natural entre sujetos (contexto de Comparacion 6) ----
variabilidad_grupo = struct( ...
    'pico_media',  mean(pico_sujeto), 'pico_SD', std(pico_sujeto), ...
    'pico_CV_pct', 100*std(pico_sujeto)/mean(pico_sujeto), ...
    'ROM_media',   mean(rom_sujeto),  'ROM_SD',  std(rom_sujeto), ...
    'ROM_CV_pct',  100*std(rom_sujeto)/mean(rom_sujeto), ...
    'n_sujetos',   nSujetos);

%% ---- FIGURA DE PEQUENOS MULTIPLOS (un panel por sujeto) ----
fig_resumen = [];
if opciones.graficar
    nCols = ceil(sqrt(nSujetos));
    nRows = ceil(nSujetos/nCols);
    fig_resumen = figure('Name','Resumen multi-sujeto','Color','w', ...
                          'Position',[80 80 320*nCols 260*nRows]);
    for s = 1:nSujetos
        suj = datosSujetos(s);
        subplot(nRows, nCols, s); hold on
        exp_fase = mean(suj.trials_propios,2);
        sd_fase  = std(suj.trials_propios,0,2);
        fill([eje_x' fliplr(eje_x')], [(exp_fase+sd_fase)' fliplr((exp_fase-sd_fase)')], ...
             [0.85 0.85 0.85], 'EdgeColor','none', 'FaceAlpha',0.6, 'HandleVisibility','off');
        plot(eje_x, exp_fase, 'k-', 'LineWidth',1.8, 'DisplayName','Captura propia');
        if isfield(suj,'trials_simulador') && ~isempty(suj.trials_simulador)
            plot(eje_x, mean(suj.trials_simulador,2), 'r--', 'LineWidth',1.6, 'DisplayName','Simulador');
        end
        title(char(string(suj.id)), 'FontSize', 10)
        grid on, box off
        if s == 1, legend('Location','best','FontSize',7); end
    end
end

%% ---- SALIDA ----
resultado = struct();
resultado.por_sujeto           = tabla_resumen;
resultado.spm_por_sujeto       = spm_por_sujeto;
resultado.spm_comparacion4     = spm_comparacion4;
resultado.variabilidad_grupo   = variabilidad_grupo;
resultado.n_sujetos            = nSujetos;
resultado.tiempo_ejecucion_seg = toc(tic_total);

fprintf('\n==================================================================\n');
fprintf('MULTISUJETO - resumen de %d sujeto(s) | tiempo de computo: %.2f s\n', nSujetos, resultado.tiempo_ejecucion_seg);
fprintf('==================================================================\n');
disp(tabla_resumen)
if ~isempty(spm_comparacion4)
    fprintf('Comparacion 4 (representatividad, diseno independiente): %.1f%% del ciclo con diferencia significativa\n', ...
            spm_comparacion4.pct_ciclo_significativo);
end
fprintf('Variabilidad natural entre sujetos: pico CV=%.1f%%, ROM CV=%.1f%%\n', ...
        variabilidad_grupo.pico_CV_pct, variabilidad_grupo.ROM_CV_pct);

%% ---- EXPORTAR ----
if ~isempty(opciones.guardar_en)
    if ~exist(opciones.guardar_en, 'dir'), mkdir(opciones.guardar_en); end
    writetable(tabla_resumen, fullfile(opciones.guardar_en, 'resumen_por_sujeto.csv'));
    save(fullfile(opciones.guardar_en, 'resultado_multisujeto.mat'), 'resultado');
    if ~isempty(fig_resumen)
        saveas(fig_resumen, fullfile(opciones.guardar_en, 'resumen_pequenos_multiplos.png'));
    end
    fprintf('Resultados exportados a: %s\n', opciones.guardar_en);
end

end
