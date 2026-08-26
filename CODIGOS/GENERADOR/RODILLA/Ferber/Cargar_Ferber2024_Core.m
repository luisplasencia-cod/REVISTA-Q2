function S = Cargar_Ferber2024_Core(json_path, opts)
% CARGAR_FERBER2024_CORE  25-ago-2026: reconstruye la posicion 3D GLOBAL
%                   real de la rodilla (horizontal + vertical), por %ciclo
%                   de marcha completo, a partir de un archivo crudo del
%                   dataset Ferber et al. 2024 (Scientific Data, n=1798,
%                   Figshare+ 10.25452/figshare.plus.24255795.v1).
%
%                   El dataset NO trae la posicion de rodilla ya calculada
%                   como curva continua (solo picos/timing discretos en
%                   dv_w/dv_r, mismo problema que Moissenet 2019). Para
%                   obtener la curva real hay que correr el pipeline de
%                   procesamiento oficial de los autores (gait_kinematics.m
%                   + gait_steps.m, en esta misma carpeta, MIT license,
%                   SIN MODIFICAR - referencia de terceros) sobre los
%                   marcadores crudos de los clusters rigidos, y luego
%                   reconstruir la posicion GLOBAL del centro articular de
%                   rodilla combinando la rotacion del segmento (R.*_shank)
%                   y el offset local calibrado (djc.*_knee) que esas
%                   mismas funciones ya calculan mas no exponen como
%                   trayectoria - formula verificada empiricamente: la
%                   velocidad de marcha derivada de gait_steps() coincide
%                   con el speed_w de walk_data_meta.csv del propio
%                   dataset (sujeto 100560: 1.323 vs 1.322763 m/s).
%
%   S = Cargar_Ferber2024_Core(json_path)
%   S = Cargar_Ferber2024_Core(json_path, struct('lado','R'))
%
%   INPUT
%   -----
%   json_path : ruta al .json crudo de UN sujeto (carpeta
%               reformat_data/<sub_id>/<timestamp>.json del ZIP ric_data,
%               22.75GB - se descarga SOLO el archivo del sujeto via
%               remotezip, no el ZIP completo).
%   opts.lado : 'R' (default, consistente con Maastricht "RKneeFlex") o 'L'.
%
%   OUTPUT (struct S)
%   -----------------
%   S.pct_ciclo       : 1x101, 0:100
%   S.x_horiz_cm       : 1x101, posicion horizontal GLOBAL/lab (direccion
%                        de avance, -Z del dataset), rel. al inicio del
%                        ciclo. ADVERTENCIA (25-ago-2026, diagnosticado
%                        con datos reales): NO comparable directo contra
%                        Cadena_Cinematica_Core.m (que asume tobillo FIJO
%                        todo el ciclo) - en marco de laboratorio real el
%                        tobillo SI se desplaza en el balanceo (r=-0.45,
%                        RMSE~44cm probado). Usar x_horiz_relhip_cm.
%   S.y_vert_cm        : 1x101, posicion vertical GLOBAL/lab (Y), idem
%                        advertencia.
%   S.x_horiz_relhip_cm, S.y_vert_relhip_cm : 1x101, posicion de la
%                        rodilla RELATIVA A LA CADERA (cancela la
%                        traslacion de todo el cuerpo/tobillo movil) -
%                        mismo principio ya validado en Evaluar_vs_Winter.m
%                        ("rodilla relativa a cadera", no al tobillo, para
%                        comparar contra datos de marco de laboratorio).
%                        Esta es la comparacion correcta para este dataset.
%   S.n_ciclos         : numero de ciclos completos usados en el promedio.
%   S.label            : 'walk' o 'run' (clasificador propio de gait_steps).
%   S.speed_ms         : velocidad de marcha calculada por gait_steps.
%   S.T_ciclo_s        : duracion REAL de un ciclo (s), promedio de los
%                        ciclos usados (TD a TD, via out.hz_w) - agregado
%                        25-ago-2026 para reconstruir avance absoluto
%                        (velocidad x tiempo) sin asumir cadencia modelada.
%   S.x_horiz_todos_cm, S.y_vert_todos_cm : matrices [n_ciclos x 101],
%                        curvas individuales (para SD/dispersion si hace falta).

if nargin < 2 || isempty(opts), opts = struct(); end
if ~isfield(opts,'lado'), opts.lado = 'R'; end
lado = upper(opts.lado);

fid = fopen(json_path);
if fid < 0, error('No se pudo abrir: %s', json_path); end
raw = fread(fid, inf);
fclose(fid);
out = jsondecode(char(raw'));

if ~isfield(out,'walking') || ~isstruct(out.walking) || isempty(fieldnames(out.walking))
    error('El archivo no tiene datos de CAMINATA (walking vacio): %s', json_path);
end

% reformato exigido por el pipeline oficial (processing_code_example.m):
% jsondecode no recrea la orientacion de out.joints/out.neutral del .mat original.
fields = fieldnames(out.joints);
for j = 1:numel(fields)
    out.joints.(fields{j}) = transpose(out.joints.(fields{j}));
end
fields = fieldnames(out.neutral);
for j = 1:numel(fields)
    out.neutral.(fields{j}) = transpose(out.neutral.(fields{j}));
end

[w_angles, w_velocities, ~, w_R, w_djc] = gait_kinematics(out.joints, out.neutral, out.walking, out.hz_w, 0); %#ok<ASGLU>
[~, ~, w_events, ~, ~, w_speed, ~, w_label] = gait_steps(out.neutral, out.walking, w_angles, w_velocities, out.hz_w, 0);

seg_shank = sprintf('%s_shank', lado);
seg_TD_col = 1;               % events(:,1)=L_TD, (:,3)=R_TD (ver gait_steps.m linea 666-669)
if strcmp(lado,'R'), seg_TD_col = 3; end
TD = round(w_events(:, seg_TD_col));
TD = TD(isfinite(TD));
TD = sort(TD);

m1 = sprintf('%s_shank_1', lado); m2 = sprintf('%s_shank_2', lado);
m3 = sprintf('%s_shank_3', lado); m4 = sprintf('%s_shank_4', lado);
nF = size(out.walking.(m1), 1);

% --- Reconstruccion GLOBAL de la rodilla Y la cadera, frame a frame ---
% (vectorizado por segmento: RODILLA se ancla al segmento SHANK, CADERA
% al segmento THIGH - mismo criterio que gait_kinematics.m usa para sus
% propios djc.*_knee / djc.*_hip, ver L84-88/202-217/287/306).
t1 = sprintf('%s_thigh_1',lado); t2 = sprintf('%s_thigh_2',lado);
t3 = sprintf('%s_thigh_3',lado); t4 = sprintf('%s_thigh_4',lado);

avg_shank = (out.walking.(m1) + out.walking.(m2) + out.walking.(m3) + out.walking.(m4)) / 4;
avg_thigh = (out.walking.(t1) + out.walking.(t2) + out.walking.(t3) + out.walking.(t4)) / 4;
Rshank = w_R.(seg_shank);
Rthigh = w_R.(sprintf('%s_thigh', lado));
djc_knee = w_djc.(sprintf('%s_knee', lado));   % [3x1], relativo al SHANK
djc_hip  = w_djc.(sprintf('%s_hip', lado));    % [3x1], relativo al THIGH
knee_lab = zeros(nF, 3);
hip_lab  = zeros(nF, 3);
for i = 1:nF
    knee_lab(i,:) = (Rshank(1:3,1:3,i) * djc_knee)' + avg_shank(i,:);
    hip_lab(i,:)  = (Rthigh(1:3,1:3,i) * djc_hip)'   + avg_thigh(i,:);
end

% Convencion del dataset (comentario de cabecera en gait_kinematics.m):
% eje1(index2)=Y=vertical hacia arriba; eje2(index3)=Z=opuesto a la
% direccion de avance -> horizontal de avance = -Z.
x_horiz_mm_all = -knee_lab(:,3);
y_vert_mm_all  =  knee_lab(:,2);
y_vert_hip_mm_all = hip_lab(:,2);   % vaiven vertical de la PROPIA cadera (25-ago-2026, para modelar el "double-bump" que Koopman no da - ver Kuopio/Modelo_Cadera_Vertical_Core.m)

% Rodilla RELATIVA A LA CADERA - cancela la traslacion de todo el cuerpo
% (incluida la del tobillo durante el balanceo, que NO esta fijo en el
% laboratorio real aunque Cadena_Cinematica_Core lo asuma asi) - mismo
% principio ya validado contra Winter (Evaluar_vs_Winter.m, "rodilla
% relativa a cadera" en vez de relativa al tobillo, unica forma valida de
% comparar contra datos de laboratorio en marco GLOBAL/lab, no relativo
% al simulador).
x_relhip_mm_all = -(knee_lab(:,3) - hip_lab(:,3));
y_relhip_mm_all =   knee_lab(:,2) - hip_lab(:,2);

% --- Segmentar en ciclos COMPLETOS: TD(i) a TD(i+1)-1 (no solo apoyo) ---
n_ciclos = numel(TD) - 1;
if n_ciclos < 1
    error('No se detectaron ciclos completos de %s en %s', lado, json_path);
end
pct = 0:100;
X = nan(n_ciclos, 101); Y = nan(n_ciclos, 101);
Xh = nan(n_ciclos, 101); Yh = nan(n_ciclos, 101);
Yhip = nan(n_ciclos, 101);   % vaiven vertical de la cadera (25-ago-2026)
T_ciclo_s_all = nan(n_ciclos, 1);   % duracion REAL de cada ciclo, TD a TD (25-ago-2026)
for c = 1:n_ciclos
    i0 = TD(c); i1 = TD(c+1) - 1;
    if i1 <= i0 || i1 > nF, continue; end
    idx = i0:i1;
    t = linspace(0, 100, numel(idx));
    xi = interp1(t, x_horiz_mm_all(idx), pct, 'pchip');
    yi = interp1(t, y_vert_mm_all(idx), pct, 'pchip');
    X(c,:) = (xi - xi(1)) / 10;   % relativo al inicio del ciclo, mm->cm
    Y(c,:) = (yi - yi(1)) / 10;
    xih = interp1(t, x_relhip_mm_all(idx), pct, 'pchip');
    yih = interp1(t, y_relhip_mm_all(idx), pct, 'pchip');
    Xh(c,:) = (xih - xih(1)) / 10;
    Yh(c,:) = (yih - yih(1)) / 10;
    yhipi = interp1(t, y_vert_hip_mm_all(idx), pct, 'pchip');
    Yhip(c,:) = (yhipi - yhipi(1)) / 10;
    T_ciclo_s_all(c) = (i1 - i0) / out.hz_w;
end
ok = all(isfinite(X),2) & all(isfinite(Y),2) & all(isfinite(Xh),2) & all(isfinite(Yh),2) & all(isfinite(Yhip),2);
X = X(ok,:); Y = Y(ok,:); Xh = Xh(ok,:); Yh = Yh(ok,:); Yhip = Yhip(ok,:);
T_ciclo_s_all = T_ciclo_s_all(ok);

S = struct();
S.pct_ciclo = pct;
S.x_horiz_cm = mean(X,1);
S.y_vert_cm  = mean(Y,1);
S.x_horiz_relhip_cm = mean(Xh,1);
S.y_vert_relhip_cm  = mean(Yh,1);
S.y_vert_hip_cm = mean(Yhip,1);   % curva de vaiven vertical de la cadera SOLA (cm, rel. inicio ciclo)
S.n_ciclos = size(X,1);
S.label = w_label;
S.speed_ms = w_speed;
S.T_ciclo_s = mean(T_ciclo_s_all);   % duracion REAL de ciclo (s), promedio de los ciclos usados
S.x_horiz_todos_cm = X;
S.y_vert_todos_cm = Y;

end
