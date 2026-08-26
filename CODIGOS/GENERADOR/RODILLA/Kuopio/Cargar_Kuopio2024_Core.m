function S = Cargar_Kuopio2024_Core(sub_id, opts)
% CARGAR_KUOPIO2024_CORE  25-ago-2026: reconstruye la posicion 3D real
%                   (avance horizontal Y + vertical Z) de cadera/rodilla/
%                   tobillo de UN sujeto del Kuopio Gait Dataset
%                   (Lavikainen et al. 2024, Data Brief 56:110841, DOI
%                   10.5281/zenodo.10559504, CC-BY-4.0) - la unica base
%                   real disponible en el proyecto con marcha OVERGROUND
%                   confirmada (3 plataformas de fuerza en el piso, NO
%                   cinta - a diferencia de Ferber, ver Evaluar_vs_Ferber_
%                   Avance.m) + antropometria real MEDIDA por sujeto
%                   (sexo/talla/masa/largo de muslo y tibia, no estimada).
%
%                   Los CSV de entrada ya vienen extraidos de los .c3d
%                   crudos por extraer_kuopio.py (Python "tonto", solo
%                   filtra frames ocluidos y vuelca Y/Z de los 3 CENTROS
%                   ARTICULARES FUNCIONALES que Vicon Nexus ya calcula
%                   (Pelvis_RFemur_score=cadera, RKnee=rodilla,
%                   RTibia_RFoot_score=tobillo, metodo SCoRE/SARA) - toda
%                   la biomecanica (deteccion de eventos, ciclos, marco de
%                   referencia) vive AQUI, no en Python, mismo criterio
%                   que el resto del proyecto.
%
%                   Deteccion de eventos: metodo cinematico de Zeni et al.
%                   2008 (J Biomech 41:1425) - el contacto inicial (heel
%                   strike) del pie ocurre en el maximo local de la
%                   posicion del tobillo RELATIVA a la cadera en la
%                   direccion de avance. Se usa porque, a diferencia de
%                   Ferber (que traia gait_steps() oficial) y del propio
%                   proyecto con Control_Luis, Kuopio no trae eventos
%                   pre-calculados - es el metodo estandar de la
%                   literatura para esto sin plataforma de fuerza en cada
%                   zancada.
%
%   S = Cargar_Kuopio2024_Core(sub_id)
%   S = Cargar_Kuopio2024_Core(sub_id, struct('dist_min_s', 0.6))
%
% ENTRADA
%   sub_id      ID numerico del sujeto (1-51), debe tener CSVs ya
%               extraidos en Kuopio/raw/<sub_id>_<trial>.csv
%   opts.dist_min_s   separacion minima entre heel-strikes candidatos (s),
%               default 0.6 (a cadencia rapida ~120 pasos/min = 0.5s/paso;
%               0.6 da margen sin fusionar dos zancadas reales)
%
% SALIDA: struct S, MISMOS CAMPOS que Cargar_Ferber2024_Core.m (misma
% interfaz, para reusar Evaluar_vs_Ferber_Avance.m con cambios minimos):
%   S.pct_ciclo, S.x_horiz_cm, S.y_vert_cm, S.x_horiz_relhip_cm,
%   S.y_vert_relhip_cm, S.n_ciclos, S.speed_ms, S.T_ciclo_s,
%   S.x_horiz_todos_cm, S.y_vert_todos_cm
%   + S.dx_tibia_cm, S.dy_tibia_cm (25-ago-2026): vector tibial real
%     (rodilla MENOS tobillo), SIN normalizar a 0 en pct=0 - a diferencia
%     de todo lo demas (que mide desplazamiento desde el inicio del
%     ciclo), esto preserva la distancia geometrica real entre rodilla y
%     tobillo en cada instante, necesaria para theta_tibia = atan2(dx,dy)
%     (ver INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial.m)
%   + S.talla_cm, S.masa_kg, S.muslo_mm, S.tibia_mm, S.sexo (antropometria
%     REAL medida de info_participants.xlsx, no estimada)
% ==========================================================================

if nargin < 2 || isempty(opts), opts = struct(); end
if ~isfield(opts, 'dist_min_s'), opts.dist_min_s = 0.6; end

carpeta = fileparts(mfilename('fullpath'));
dir_raw = fullfile(carpeta, 'raw');

Tmeta = readtable(fullfile(dir_raw, 'subjects_meta.csv'));
fila = Tmeta(Tmeta.sub_id == sub_id, :);
if height(fila) ~= 1
    error('sub_id %d no encontrado (o duplicado) en subjects_meta.csv', sub_id);
end

archivos = dir(fullfile(dir_raw, sprintf('%02d_*.csv', sub_id)));
if isempty(archivos)
    error('No se encontraron CSV de trials para el sujeto %d en %s', sub_id, dir_raw);
end

pct = 0:100;
Xabs_todos = []; Yabs_todos = [];
Xrel_todos = []; Yrel_todos = [];
XabsTob_todos = []; YabsTob_todos = [];   % TOBILLO absoluto (25-ago-2026)
XrelTob_todos = []; YrelTob_todos = [];   % TOBILLO relativo a cadera (25-ago-2026)
DxTib_todos = []; DyTib_todos = [];       % vector TIBIAL real (rodilla-tobillo), sin normalizar (25-ago-2026)
DxMus_todos = []; DyMus_todos = [];       % vector del MUSLO real (cadera-rodilla), sin normalizar (25-ago-2026)
Yhip_todos = [];   % vaiven vertical de la CADERA sola (25-ago-2026, para LOSO de Y)
Xhip_todos = [];   % avance horizontal de la CADERA sola (25-ago-2026, para LOSO de X)
speed_todos = []; Tciclo_todos = [];

for k = 1:numel(archivos)
    Ttr = readtable(fullfile(dir_raw, archivos(k).name));
    fr = 1 / median(diff(Ttr.t_s));   % Hz real del trial

    cad_y = Ttr.cadera_y_mm; cad_z = Ttr.cadera_z_mm;
    rod_y = Ttr.rodilla_y_mm; rod_z = Ttr.rodilla_z_mm;
    tob_y = Ttr.tobillo_y_mm; tob_z = Ttr.tobillo_z_mm;
    t_s = Ttr.t_s;

    % --- Zeni 2008: heel strike = maximo local de (tobillo - cadera) en Y ---
    senal = tob_y - cad_y;
    dist_min_muestras = round(opts.dist_min_s * fr);
    idx_picos = picos_locales(senal, dist_min_muestras);

    if numel(idx_picos) < 2
        continue   % trial demasiado corto para un ciclo completo
    end

    for c = 1:(numel(idx_picos)-1)
        i0 = idx_picos(c); i1 = idx_picos(c+1);
        n_muestras = i1 - i0 + 1;
        if n_muestras < round(0.4*fr) || n_muestras > round(2.5*fr)
            continue   % ciclo fisiologicamente implausible, descartar
        end
        idx = i0:i1;
        tt = linspace(0, 100, numel(idx));

        xi = interp1(tt, (rod_y(idx) - rod_y(i0))/10, pct, 'pchip');        % absoluto, cm
        yi = interp1(tt, (rod_z(idx) - rod_z(i0))/10, pct, 'pchip');
        xih = interp1(tt, ((rod_y(idx)-cad_y(idx)) - (rod_y(i0)-cad_y(i0)))/10, pct, 'pchip');  % rel. cadera, cm
        yih = interp1(tt, ((rod_z(idx)-cad_z(idx)) - (rod_z(i0)-cad_z(i0)))/10, pct, 'pchip');
        yhipi = interp1(tt, (cad_z(idx) - cad_z(i0))/10, pct, 'pchip');   % cadera sola, cm
        xhipi = interp1(tt, (cad_y(idx) - cad_y(i0))/10, pct, 'pchip');   % avance horizontal de la CADERA sola, cm (25-ago-2026)

        xit = interp1(tt, (tob_y(idx) - tob_y(i0))/10, pct, 'pchip');     % TOBILLO absoluto, cm
        yit = interp1(tt, (tob_z(idx) - tob_z(i0))/10, pct, 'pchip');
        xitr = interp1(tt, ((tob_y(idx)-cad_y(idx)) - (tob_y(i0)-cad_y(i0)))/10, pct, 'pchip');  % TOBILLO rel. cadera, cm
        yitr = interp1(tt, ((tob_z(idx)-cad_z(idx)) - (tob_z(i0)-cad_z(i0)))/10, pct, 'pchip');

        % Vector TIBIAL real (rodilla-tobillo), SIN normalizar a 0 en
        % pct=0 (25-ago-2026, para INCLINACION_TIBIAL) - a diferencia de
        % todo lo demas arriba (que se normaliza porque mide DESPLAZAMIENTO
        % desde el inicio del ciclo, util para posicion/avance), aqui se
        % necesita la distancia GEOMETRICA real entre rodilla y tobillo en
        % cada instante para calcular el angulo (atan2) - normalizar cada
        % segmento a su propio cero por separado borra el offset real
        % entre ambos y da un angulo sin sentido (bug encontrado y
        % corregido el mismo dia en Evaluar_vs_Kuopio_AnguloTibial.m).
        dx_tib = interp1(tt, (rod_y(idx) - tob_y(idx))/10, pct, 'pchip');
        dy_tib = interp1(tt, (rod_z(idx) - tob_z(idx))/10, pct, 'pchip');

        % Vector del MUSLO real (cadera-rodilla), tambien SIN normalizar,
        % por el mismo motivo que el tibial (25-ago-2026). Permite calibrar
        % el angulo de cadera de Koopman contra el real, que es DONDE esta
        % el error de amplitud (ver CIERRE_RODILLA.md #8) - en vez de
        % calibrar la posicion ya sumada al vaiven de cadera, que mezcla
        % dos errores distintos y aplasta la amplitud del resultado.
        dx_mus = interp1(tt, (cad_y(idx) - rod_y(idx))/10, pct, 'pchip');
        dy_mus = interp1(tt, (cad_z(idx) - rod_z(idx))/10, pct, 'pchip');

        Xabs_todos(end+1,:) = xi; Yabs_todos(end+1,:) = yi; %#ok<AGROW>
        Xrel_todos(end+1,:) = xih; Yrel_todos(end+1,:) = yih; %#ok<AGROW>
        XabsTob_todos(end+1,:) = xit; YabsTob_todos(end+1,:) = yit; %#ok<AGROW>
        XrelTob_todos(end+1,:) = xitr; YrelTob_todos(end+1,:) = yitr; %#ok<AGROW>
        DxTib_todos(end+1,:) = dx_tib; DyTib_todos(end+1,:) = dy_tib; %#ok<AGROW>
        DxMus_todos(end+1,:) = dx_mus; DyMus_todos(end+1,:) = dy_mus; %#ok<AGROW>
        Yhip_todos(end+1,:) = yhipi; %#ok<AGROW>
        Xhip_todos(end+1,:) = xhipi; %#ok<AGROW>
        speed_todos(end+1) = (cad_y(i1)-cad_y(i0))/1000 / (t_s(i1)-t_s(i0)); %#ok<AGROW>
        Tciclo_todos(end+1) = t_s(i1)-t_s(i0); %#ok<AGROW>
    end
end

if isempty(Xabs_todos)
    error('Sujeto %d: no se extrajo ningun ciclo completo valido de %d trials.', sub_id, numel(archivos));
end

S = struct();
S.pct_ciclo = pct;
S.x_horiz_cm = mean(Xabs_todos,1);
S.y_vert_cm  = mean(Yabs_todos,1);
S.x_horiz_relhip_cm = mean(Xrel_todos,1);
S.y_vert_relhip_cm  = mean(Yrel_todos,1);
S.y_vert_hip_cm = mean(Yhip_todos,1);   % vaiven vertical de la cadera SOLA, cm (rel. inicio ciclo)
S.x_horiz_hip_cm = mean(Xhip_todos,1);  % avance horizontal de la cadera SOLA, cm (rel. inicio ciclo)
S.x_horiz_tobillo_cm = mean(XabsTob_todos,1);
S.y_vert_tobillo_cm  = mean(YabsTob_todos,1);
S.x_horiz_relhip_tobillo_cm = mean(XrelTob_todos,1);
S.y_vert_relhip_tobillo_cm  = mean(YrelTob_todos,1);
S.dx_muslo_cm = mean(DxMus_todos,1);   % vector del muslo real (cadera-rodilla), SIN normalizar - para calibrar el angulo de cadera
S.dy_muslo_cm = mean(DyMus_todos,1);
S.dx_tibia_cm = mean(DxTib_todos,1);   % vector tibial real (rodilla-tobillo), SIN normalizar - para angulo (INCLINACION_TIBIAL)
S.dy_tibia_cm = mean(DyTib_todos,1);
S.n_ciclos = size(Xabs_todos,1);
S.speed_ms = mean(speed_todos);
S.T_ciclo_s = mean(Tciclo_todos);
S.x_horiz_todos_cm = Xabs_todos;
S.y_vert_todos_cm = Yabs_todos;

S.sexo = fila.sexo{1};
S.talla_cm = fila.talla_cm;
S.masa_kg = fila.masa_kg;
S.muslo_mm = fila.muslo_mm;
S.tibia_mm = fila.tibia_mm;

end

% ==========================================================================
function idx = picos_locales(x, dist_min)
% Maximos locales de x, con separacion minima dist_min muestras entre
% picos consecutivos aceptados (evita findpeaks/toolbox - portable).
x = x(:);
n = numel(x);
cand = find(x(2:end-1) > x(1:end-2) & x(2:end-1) > x(3:end)) + 1;
if isempty(cand), idx = []; return; end
idx = cand(1);
for i = 2:numel(cand)
    if cand(i) - idx(end) >= dist_min
        idx(end+1) = cand(i); %#ok<AGROW>
    elseif x(cand(i)) > x(idx(end))
        idx(end) = cand(i);   % se queda con el pico mas alto de los cercanos
    end
end
end
