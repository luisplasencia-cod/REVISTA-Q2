function S = Cargar_Fukuchi2018_GRF_Core(sub_id, opts)
% CARGAR_FUKUCHI2018_GRF_CORE  29-ago-2026: carga la fuerza de reaccion
% vertical REAL (columna GRFY - ver nota de convencion de ejes mas abajo),
% YA SEPARADA POR PIERNA y YA NORMALIZADA a 0-100%
% del ciclo de marcha por los propios autores (Fukuchi, Fukuchi & Duarte
% 2018, PeerJ 6:e4640) - archivo *Cknt.txt ("kinetics", no el *Cgrf.txt
% crudo de plataforma que necesitaria deteccion de eventos y asignacion de
% pie-por-placa, ya resuelto por los autores).
%
% POR QUE ESTE ARCHIVO Y NO *Cgrf.txt (pedido del usuario, 29-ago-2026,
% tras notar que %BW deberia tener una forma "verificada" que se puede
% tomar de datos reales en vez de derivar de un modelo teorico): *Cknt.txt
% ya trae RGRFZ/LGRFZ - la fuerza vertical de CADA pierna por separado,
% ciclo completo 0-100%, en N/kg (confirmado contra wbdsExploratoryDA.m,
% units={'[°]','[Nm/kg]','[N/kg]'}) - N/kg = Newtons por kilogramo de masa
% corporal, o sea ya viene dividido por la masa (no por el peso): para
% %BW hay que dividir ademas por g (%BW = valor_N/kg / g * 100). Esto
% evita CUALQUIER version de los problemas de doble apoyo/geometria de 2
% piernas que dominaron el resto de esta sesion - los autores ya
% resolvieron eso con su propia dinamica inversa, publicada y revisada por
% pares.
%
%   S = Cargar_Fukuchi2018_GRF_Core(sub_id)
%   S = Cargar_Fukuchi2018_GRF_Core(sub_id, struct('pierna','R'))
%
% ENTRADA
%   sub_id        ID numerico del sujeto (1-42)
%   opts.pierna   'R' (default) o 'L' - cual pierna usar. Bajo el supuesto
%                 de marcha simetrica (ya usado en todo el proyecto para
%                 la pierna contralateral), ambas deberian ser
%                 comparables - se deja elegible para poder usar las 2
%                 (efectivamente N=84 en vez de N=42) si se necesita.
%
% SALIDA: struct S (condicion FIJA: overground, comoda - 'O'/'C', mismo
%   criterio ya usado por Cargar_Fukuchi2018_Core.m)
%   .sub_id, .sexo, .edad_anios, .talla_cm, .masa_kg, .speed_ms (real, WBDSinfo)
%   .pct              0:100
%   .GRF_vertical_pctBW   [1x101], %BW = (N/kg)/g*100
%   .GRF_vertical_Npkg    [1x101], valor nativo del archivo, sin convertir
% ==========================================================================

if nargin < 2, opts = struct(); end
if ~isfield(opts,'pierna') || isempty(opts.pierna), opts.pierna = 'R'; end
if ~any(strcmpi(opts.pierna, {'R','L'}))
    error('opts.pierna debe ser ''R'' o ''L''. Se recibio: %s', mat2str(opts.pierna));
end
G = 9.80665;

carpeta = fileparts(mfilename('fullpath'));
dir_raw = fullfile(carpeta, 'raw');

persistent Tinfo
if isempty(Tinfo)
    Tinfo = readtable(fullfile(dir_raw, 'WBDSinfo.xlsx'));
end

subLabel = sprintf('WBDS%02d', sub_id);
filerow = startsWith(Tinfo.FileName, [subLabel 'walkO']) & endsWith(Tinfo.FileName, 'C.c3d');
filas = find(filerow);
if isempty(filas)
    error('No se encontro metadata para sujeto %d, overground, comoda.', sub_id);
end
fila = filas(1);

S = struct();
S.sub_id = sub_id;
S.sexo = Tinfo.Gender{fila};
S.edad_anios = Tinfo.Age(fila);
S.talla_cm = Tinfo.Height(fila);
S.masa_kg = Tinfo.Mass(fila);
gs = mean(Tinfo.('GaitSpeed_m_s_')(filas), 'omitnan');
if isnan(gs)
    error('GaitSpeed no disponible para sujeto %d.', sub_id);
end
S.speed_ms = gs;

fname_knt = sprintf('%swalkOCknt.txt', subLabel);
ruta_knt = fullfile(dir_raw, 'WBDSascii', fname_knt);
if ~isfile(ruta_knt)
    error('No se encontro el archivo de kinetica: %s (extraer de raw/WBDSascii.zip primero)', ruta_knt);
end
X = importdata(ruta_knt);
hdr = X.colheaders;

pct_raw = X.data(:,1);
S.pct = 0:100;

% CORREGIDO 29-ago-2026: en este dataset "Y" es la VERTICAL, no "Z" -
% confirmado en wbdsExploratoryDA.m (script de los propios autores):
% dirGRF={'ANTERIOR-POSTERIOR','VERTICAL','MEDIAL-LATERAL'} con
% orderXYZ=[3 1 2] mapeando columna-Y (xyz=3) -> dirGRF{2}='VERTICAL'.
% Primer intento uso "GRFZ" por la convencion de ANGULOS del mismo dataset
% (donde Z SI es flexo-extension sagital) - la convencion de GRF es
% distinta, verificado aqui contra el codigo fuente, no asumido.
col_grfy = find(strcmp(hdr, sprintf('%sGRFY', upper(opts.pierna))), 1);
if isempty(col_grfy)
    error('No se encontro la columna %sGRFY en %s', upper(opts.pierna), ruta_knt);
end

grfy_Npkg = interp1(pct_raw, X.data(:,col_grfy), S.pct, 'pchip');
S.GRF_vertical_Npkg = grfy_Npkg;
S.GRF_vertical_pctBW = 100 * grfy_Npkg / G;

end
