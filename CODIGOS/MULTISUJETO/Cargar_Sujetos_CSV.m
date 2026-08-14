function datosSujetos = Cargar_Sujetos_CSV(opciones)
% CARGAR_SUJETOS_CSV  Interfaz interactiva: arma el struct que necesita
%                      Procesar_Multisujeto_Core.m a partir de archivos
%                      CSV reales, un sujeto a la vez, reutilizando el
%                      MISMO parseo (columnas, atan2, filtro
%                      Savitzky-Golay) que ya usa
%                      VALIDACIONES/Validacion_Plataforma.m - no inventa
%                      una convencion nueva.
%
%   datosSujetos = Cargar_Sujetos_CSV()
%   datosSujetos = Cargar_Sujetos_CSV(opciones)
%
% ESTE ES EL ARCHIVO A AJUSTAR el dia que el equipo defina el formato
% final de carpetas/nombres para los 15-20 sujetos futuros (hoy ese
% formato todavia no esta decidido). El resto del pipeline
% (Procesar_Multisujeto_Core.m) no se ve afectado por ese cambio: solo
% depende del struct que esta funcion produce, no del formato de archivo
% en disco.
%
% opciones (struct opcional):
%   .fase_ini                 (default 0)  inicio de la fase a normalizar (%)
%   .fase_fin                 (default 60) fin de la fase a normalizar (%)
%   .n_puntos                 (default 61) puntos del eje normalizado
%   .sgolay_orden              (default 3)
%   .sgolay_window             (default 9)
%   .offset_calibracion_deg    (default 0)  ADVERTENCIA: Validacion_Plataforma.m
%                              resta 5.85 grados para el sujeto original,
%                              solo en la fase de apoyo - ese numero es
%                              especifico de la calibracion de marcadores
%                              de ESE montaje y NO debe reutilizarse a
%                              ciegas para sujetos nuevos ni para otro
%                              instrumento. Dejar en 0 salvo que el
%                              equipo repita esa calibracion para el
%                              nuevo montaje y confirme el valor.
%
% SALIDA: struct array listo para Procesar_Multisujeto_Core.m (ver el
% encabezado de ese archivo para el detalle de cada campo). Cada sujeto
% cargado aqui pide, por separado, sus CSV de captura propia y (si ya
% existen) los de la salida del simulador reprogramado con su CSV.
% ==========================================================================

if nargin < 1, opciones = struct(); end
def = struct('fase_ini',0, 'fase_fin',60, 'n_puntos',61, ...
             'sgolay_orden',3, 'sgolay_window',9, 'offset_calibracion_deg',0);
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

eje_x = linspace(opciones.fase_ini, opciones.fase_fin, opciones.n_puntos)';

datosSujetos = struct('id',{}, 'eje_x',{}, 'trials_propios',{}, 'trials_simulador',{});

s = 0;
agregar_otro = true;
while agregar_otro
    s = s + 1;

    carpeta_sujeto = uigetdir(pwd, sprintf('Sujeto %d: seleccione su carpeta', s));
    if isequal(carpeta_sujeto, 0)
        s = s - 1;
        break
    end

    [~, nombre_carpeta] = fileparts(carpeta_sujeto);
    resp_id = inputdlg('Identificador del sujeto:', 'ID de sujeto', 1, {nombre_carpeta});
    if isempty(resp_id)
        s = s - 1;
        break
    end
    id_sujeto = resp_id{1};

    trials_propios = cargar_y_normalizar_csv( ...
        sprintf('Sujeto %s: seleccione los CSV de su captura propia (Ctrl+Click)', id_sujeto), ...
        carpeta_sujeto, eje_x, opciones);

    if isempty(trials_propios)
        warning('Sujeto %s: no se seleccionaron archivos de captura propia, se descarta este sujeto.', id_sujeto);
        s = s - 1;
    else
        resp_sim = questdlg( ...
            sprintf('Sujeto %s: ¿ya existe la salida del simulador reprogramado con su CSV?', id_sujeto), ...
            'Salida del simulador', 'Si','No (todavia no)','No (todavia no)');
        trials_simulador = [];
        if strcmp(resp_sim, 'Si')
            trials_simulador = cargar_y_normalizar_csv( ...
                sprintf('Sujeto %s: seleccione los CSV de salida del simulador (Ctrl+Click)', id_sujeto), ...
                carpeta_sujeto, eje_x, opciones);
        end

        datosSujetos(s).id               = id_sujeto;
        datosSujetos(s).eje_x            = eje_x;
        datosSujetos(s).trials_propios   = trials_propios;
        datosSujetos(s).trials_simulador = trials_simulador;
    end

    resp = questdlg('¿Agregar otro sujeto?', 'Continuar', 'Si','No, terminar','Si');
    agregar_otro = strcmp(resp, 'Si');
end

fprintf('Cargar_Sujetos_CSV: %d sujeto(s) listos para Procesar_Multisujeto_Core.\n', numel(datosSujetos));

end

% ===================================================
% FUNCIONES LOCALES
% ===================================================

function trials_norm = cargar_y_normalizar_csv(titulo_dialogo, carpeta_sujeto, eje_x, opciones)
% Mismo parseo que Validacion_Plataforma.m: columnas 1 (tiempo), 2-3
% (marcador fijo xa,ya), 6-7 (marcador movil xo,yo), atan2, unwrap,
% sgolayfilt. opciones.offset_calibracion_deg se resta despues del
% filtro (ver advertencia en el encabezado de este archivo).

[files, path_sel] = uigetfile('*.csv', titulo_dialogo, carpeta_sujeto, 'MultiSelect','on');
if isequal(files, 0)
    trials_norm = [];
    return
end
if ~iscell(files), files = {files}; end
files = sort(files);
n_ensayos = numel(files);

trials_norm = zeros(numel(eje_x), n_ensayos);

for k = 1:n_ensayos
    data = readtable(fullfile(path_sel, files{k}), 'VariableNamingRule','preserve','Delimiter',';');

    xa = data{:,2}; ya = data{:,3};
    xo = data{:,6}; yo = data{:,7};

    theta_raw = atan2(yo - ya, xo - xa);
    theta_deg = rad2deg(unwrap(theta_raw)) - opciones.offset_calibracion_deg;

    theta_filt = sgolayfilt(theta_deg, opciones.sgolay_orden, opciones.sgolay_window);

    pct_ciclo = linspace(opciones.fase_ini, opciones.fase_fin, numel(theta_filt));
    trials_norm(:,k) = interp1(pct_ciclo, theta_filt, eje_x, 'pchip');
end

end
