function S = Cargar_Fukuchi2018_Core(sub_id, opts)
% CARGAR_FUKUCHI2018_CORE  27-ago-2026: carga UN sujeto/trial del dataset
%                   de Fukuchi, Fukuchi & Duarte 2018 (PeerJ 6:e4640,
%                   DOI 10.7717/peerj.4640) - Universidade Federal do
%                   ABC, Brasil. N=42 (24 jovenes + 18 mayores),
%                   overground Y treadmill, antropometria real por
%                   sujeto (edad/talla/masa/sexo/largo de pierna),
%                   velocidad real medida.
%
%                   HALLAZGO 27-ago-2026 (ver docs/algoritmo/
%                   JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md #11-bis): es la
%                   base sudamericana (Brasil) que representa la
%                   poblacion peruana con mucha mas fidelidad que Kuopio
%                   (74% de los 42 sujetos caen dentro del P5-P95 real
%                   peruano, Asgari et al 2019 N=3134, vs 40% de Kuopio).
%
%                   A DIFERENCIA de Kuopio/Ferber, este dataset entrega
%                   ANGULOS ARTICULARES YA CALCULADOS (Hip/Knee/Ankle,
%                   plano sagital = eje Z de los archivos *ang.txt),
%                   normalizados a 0-100% del ciclo de marcha - NO hace
%                   falta deteccion de eventos ni reconstruccion de
%                   posicion 3D desde marcadores para comparar contra
%                   los angulos nativos de Koopman/Zhao/Yun (comparacion
%                   mas directa que Kuopio/Ferber, que si necesitaron
%                   convertir angulo->posicion o detectar eventos).
%
%                   Fuente de la convencion de columnas: WBDSexploratoryDA.m
%                   (script de los propios autores, Fukuchi/raw/) -
%                   varName = 'R'+Joint+'Angle'+eje, eje='Z' es flexo-
%                   extension (sagital) para Hip/Knee/Ankle (confirmado
%                   por el orden de graficas del propio script: dirA
%                   lista flexo-extension como 3er item de cada terna,
%                   y orderXYZ=[3 1 2] mapea la columna Z cruda a esa
%                   3ra posicion).
%
%                   IMPORTANTE - NO circularidad: este dataset entrena
%                   los coeficientes de Romero-Sorozabal 2024 (candidato
%                   de posicion 3D directa) - por eso NO se usa aqui
%                   para validar Romero-Sorozabal (ya excluido de la
%                   comparacion de candidatos ganadores por la anomalia
%                   de su eje Z). Para Koopman/Zhao/Yun, que nunca
%                   tocaron este dataset, es un examen 100% independiente.
%
%   S = Cargar_Fukuchi2018_Core(sub_id)
%   S = Cargar_Fukuchi2018_Core(sub_id, struct('condicion','O','velocidad','C'))
%
% ENTRADA
%   sub_id          ID numerico del sujeto (1-42)
%   opts.condicion  'O' (overground, DEFAULT - mismo criterio que Kuopio,
%                   preferencia por marcha real sobre cinta) o 'T' (treadmill)
%   opts.velocidad  para 'O': 'S'/'C'/'F' (lenta/comoda/rapida), default 'C'
%                   (mismo criterio "comf" que Kuopio). Para 'T': 1-8.
%
% SALIDA: struct S
%   .sub_id, .sexo ('M'/'F'), .edad_anios, .talla_cm, .masa_kg
%   .long_pierna_m      LegLength de WBDSinfo (m) - dato REAL medido
%   .speed_ms           velocidad real de ESTE trial especifico (m/s)
%   .pct                0:100 (grid ya normalizado por los propios autores)
%   .ang_cadera_deg, .ang_rodilla_deg, .ang_tobillo_deg   [1x101], grados,
%                   plano sagital, columna Z de *ang.txt (RHipAngleZ,
%                   RKneeAngleZ, RAnkleAngleZ) - convencion propia del
%                   dataset (Vicon Plug-in Gait estandar), NO
%                   necesariamente el mismo signo que el resto del
%                   proyecto - se declara el signo verificado en
%                   Evaluar_vs_Fukuchi2018_Angulos.m, no aqui.

if nargin < 2, opts = struct(); end
if ~isfield(opts,'condicion'), opts.condicion = 'O'; end
if ~isfield(opts,'velocidad'), opts.velocidad = 'C'; end

carpeta = fileparts(mfilename('fullpath'));
dir_raw = fullfile(carpeta, 'raw');

persistent Tinfo
if isempty(Tinfo)
    Tinfo = readtable(fullfile(dir_raw, 'WBDSinfo.xlsx'));  % NO 'preserve': se necesita el nombre sanitizado GaitSpeed_m_s_
end

subLabel = sprintf('WBDS%02d', sub_id);

% NOTA (27-ago-2026): el .c3d crudo tiene VARIOS trials por sujeto+velocidad
% (ej. WBDS01walkO01S.c3d ... WBDS01walkO10S.c3d, numero de trial ANTES de
% la letra de velocidad) - pero el archivo PROCESADO *ang.txt es UNO SOLO
% por sujeto+velocidad (los propios autores lo redujeron/promediaron). Por
% eso aqui se toma el promedio de GaitSpeed entre TODOS los trials crudos
% que comparten sujeto+velocidad, no un trial especifico.
switch upper(opts.condicion)
    case 'O'
        fname_ang = sprintf('%swalkO%sang.txt', subLabel, opts.velocidad);
        filerow = startsWith(Tinfo.FileName, [subLabel 'walkO']) & endsWith(Tinfo.FileName, [opts.velocidad '.c3d']);
    case 'T'
        fname_ang = sprintf('%swalkT0%dang.txt', subLabel, opts.velocidad);
        filerow = startsWith(Tinfo.FileName, sprintf('%swalkT0%d', subLabel, opts.velocidad)) & endsWith(Tinfo.FileName, '.c3d');
    otherwise
        error('opts.condicion debe ser ''O'' o ''T''. Se recibio: %s', opts.condicion);
end

filas = find(filerow);
if isempty(filas)
    error('No se encontro metadata para sujeto %d, condicion %s, velocidad %s', sub_id, opts.condicion, mat2str(opts.velocidad));
end
fila = filas(1);

S = struct();
S.sub_id = sub_id;
S.sexo = Tinfo.Gender{fila};
S.edad_anios = Tinfo.Age(fila);
S.talla_cm = Tinfo.Height(fila);
S.masa_kg = Tinfo.Mass(fila);
S.long_pierna_m = Tinfo.LegLength(fila);
gs = mean(Tinfo.('GaitSpeed_m_s_')(filas), 'omitnan');
if isnan(gs)
    error('GaitSpeed no disponible para sujeto %d en este trial (columna vacia en WBDSinfo)', sub_id);
end
S.speed_ms = gs;

ruta_ang = fullfile(dir_raw, 'WBDSascii', fname_ang);
if ~isfile(ruta_ang)
    error('No se encontro el archivo de angulos: %s', ruta_ang);
end
X = importdata(ruta_ang);
hdr = X.colheaders;

pct_raw = X.data(:,1);
S.pct = 0:100;

col_cadera = find(strcmp(hdr, 'RHipAngleZ'), 1);
col_rodilla = find(strcmp(hdr, 'RKneeAngleZ'), 1);
col_tobillo = find(strcmp(hdr, 'RAnkleAngleZ'), 1);
if isempty(col_cadera) || isempty(col_rodilla) || isempty(col_tobillo)
    error('No se encontraron las columnas RHipAngleZ/RKneeAngleZ/RAnkleAngleZ en %s', ruta_ang);
end

S.ang_cadera_deg = interp1(pct_raw, X.data(:,col_cadera), S.pct, 'pchip');
S.ang_rodilla_deg = interp1(pct_raw, X.data(:,col_rodilla), S.pct, 'pchip');
S.ang_tobillo_deg = interp1(pct_raw, X.data(:,col_tobillo), S.pct, 'pchip');

end
