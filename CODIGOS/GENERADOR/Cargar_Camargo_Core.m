function out = Cargar_Camargo_Core(sujeto_dir, sesion, trial_relpath)
% CARGAR_CAMARGO_CORE  Carga un ensayo real de Camargo, Ramanathan,
%                      Flanagan & Young 2021 (Journal of Biomechanics,
%                      DOI 10.1016/j.jbiomech.2021.110320 - base de
%                      validacion externa ya decidida en P-24,
%                      docs/DISCUSION_Q2.md #4-sexies) y lo deja listo
%                      para los Niveles A y B de validacion
%                      (docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md
%                      #7.1).
%
%                      IMPORTANTE: theta_tibia_real_deg se calcula DIRECTO
%                      de los marcadores 3D crudos (R_Knee_Lat, R_Ankle_Lat)
%                      con la MISMA convencion atan2 que ya usa el
%                      proyecto (ver CODIGOS/GENERAR CURVS DE REFERENCIA/
%                      Angulo_Control_Plataforma.m linea 84) - NO se deriva
%                      del algebra interna de los frames de OpenSim
%                      (offset frames, SpatialTransform), que resulto
%                      ambigua de interpretar sin la API real de OpenSim.
%                      Marcadores > convencion propia > nada de "caja
%                      negra" de terceros para el numero que sostiene la
%                      validacion central del articulo.
%
%   out = Cargar_Camargo_Core(sujeto_dir, sesion, trial_relpath)
%
% ENTRADA
%   sujeto_dir      carpeta del sujeto ya descomprimida, p.ej.
%                   'docs/literatura/pdfs/camargo2021_piloto/AB06'
%   sesion          subcarpeta de fecha, p.ej. '10_09_18' (varia por sujeto)
%   trial_relpath   nombre de archivo del ensayo dentro de
%                   levelground/{markers,ik,gcRight}, p.ej.
%                   'levelground_ccw_normal_01_01.mat'
%
% SALIDA: struct `out`
%   .pct_ciclo_R          0-100%, del canal HeelStrike de gcRight/<trial>
%                         (fase continua ya calculada por Camargo, no se
%                         re-detectan eventos)
%   .theta_tibia_real_deg  angulo absoluto del segmento tibial derecho,
%                         atan2(avance_rodilla-avance_tobillo,
%                         vertical_rodilla-vertical_tobillo) - 0 grados =
%                         tibia vertical, positivo/negativo segun la
%                         inclinacion (convencion verificada contra
%                         REFERENCIAS/Control_apoyo_Luis_V4.csv y
%                         CurvaPromedio_Plataforma_Apoyo_*.csv del propio
%                         proyecto, que van de -50 a +22 grados - NO es
%                         angulo respecto a la horizontal como el atan2
%                         crudo de Angulo_Control_Plataforma.m linea 84,
%                         que da ~90 grados para una tibia vertical).
%                         IMPORTANTE: "avance" NO es el eje X crudo del
%                         laboratorio (Camargo camina en circuito curvo,
%                         cw/ccw - X y Z ambos tienen recorrido de
%                         metros) - es el desplazamiento horizontal
%                         proyectado sobre la direccion neta de avance
%                         del tobillo EN ESTE ensayo. Antes de
%                         comparar directo con REFERENCIAS/ del proyecto
%                         (plano imagen 2D de Kinovea), confirmar que las
%                         convenciones de signo coinciden - no asumido
%                         igual solo porque ambos usan atan2
%   .avance_rodilla_mm, .avance_tobillo_mm    coordenada de avance 1D
%                         (mm) usada arriba, por si se necesita aparte
%   .vertical_rodilla_mm, .vertical_tobillo_mm   = Y crudo (mm), vertical
%   .hip_flexion_r_deg, .knee_angle_r_deg, .ankle_angle_r_deg
%                         angulos articulares relativos REALES (tabla ik
%                         de OpenSim, canales estandar), para Nivel A
%                         (comparar contra Yun2014_Wrapper/Zhao2026_Core)
%                         y para alimentar Reduccion_Winter_Core.m como
%                         chequeo cruzado con .theta_tibia_real_deg
%   .long_tibia_r_m       longitud del segmento tibial derecho (m),
%                         distancia 3D entre R_Knee_Lat y R_Ankle_Lat en
%                         el ensayo ESTATICO del mismo sujeto/sesion
%                         (promedio de todos los frames del estatico)
%   .t_s                  tiempo (s) de la tabla ik/markers, sin normalizar
%
% Fuente de las variables de marcadores/angulos: confirmado abriendo los
% .mat reales en MATLAB (23-ago-2026) - no supuesto de la documentacion
% publica del dataset, que en un punto resulto imprecisa (no existe
% SubjectInfo.mat dentro del .zip de cada sujeto individual, a diferencia
% de lo que sugeria blog.jcamargo.co). Ver CODIGOS/GENERADOR/
% GUIA_INTERPRETACION.md #5 para el detalle completo.
% ==========================================================================

if nargin < 3
    error('Se requieren sujeto_dir, sesion y trial_relpath. Ver ayuda de esta funcion.');
end

dir_lg = fullfile(sujeto_dir, sesion, 'levelground');
f_markers = fullfile(dir_lg, 'markers', trial_relpath);
f_ik      = fullfile(dir_lg, 'ik', trial_relpath);
f_gc      = fullfile(dir_lg, 'gcRight', trial_relpath);
f_static  = fullfile(sujeto_dir, sesion, 'static', 'markers');

for f = {f_markers, f_ik, f_gc}
    if ~isfile(f{1})
        error('No se encontro el archivo esperado: %s', f{1});
    end
end
if ~isfolder(f_static)
    error('No se encontro la carpeta de marcadores estaticos: %s', f_static);
end

d_markers = load(f_markers);
d_ik      = load(f_ik);
d_gc      = load(f_gc);

tab_m  = d_markers.data;
tab_ik = d_ik.data;
tab_gc = d_gc.data;

% --- theta_tibia_real, directo de marcadores crudos, convencion atan2 ---
% CORREGIDO 23-ago-2026: el eje X crudo del laboratorio NO es la
% direccion de avance en este dataset (Camargo camina en un circuito
% curvo, condiciones 'cw'/'ccw' - X y Z tienen ambos recorrido de
% metros a lo largo del ensayo completo, Y es la unica vertical clara,
% verificado con el trial real: rango X~3.3m, Z~6.7m, Y~0.19m). Usar X
% crudo como si fuera anteroposterior daba un angulo tibial sin sentido
% fisico (dominado por una componente casi plana). Se proyecta el
% desplazamiento horizontal (X,Z) del tobillo sobre su propia direccion
% neta de avance en ESTE ensayo (primer a ultimo frame) para obtener una
% coordenada de "avance" 1D valida en el plano sagital del propio
% caminar - metodo estandar para trayectorias curvas (cambia de tramo a
% tramo, no es una constante fija del dataset).
% CAVEAT declarado (23-ago-2026): la direccion de avance se estima UNA
% VEZ para todo el archivo (primer a ultimo frame). Si el archivo cubre
% varias zancadas sobre un tramo curvo del circuito, la direccion real
% rota un poco de zancada a zancada y esta aproximacion introduce un
% sesgo lateral pequeno en "avance" (no en la forma de theta_tibia(t),
% que depende sobre todo del movimiento vertical relativo rodilla-tobillo,
% no del avance horizontal). Suficiente para una demo/chequeo visual; si
% se usa para el numero final de validacion (Nivel A/B), conviene
% recalcular la direccion por zancada individual en vez de por archivo.
xz0 = [tab_m.R_Ankle_Lat_x(1), tab_m.R_Ankle_Lat_z(1)];
xz1 = [tab_m.R_Ankle_Lat_x(end), tab_m.R_Ankle_Lat_z(end)];
dir_avance = xz1 - xz0;
dir_avance = dir_avance / norm(dir_avance);

avance_rodilla  = (tab_m.R_Knee_Lat_x  - xz0(1))*dir_avance(1) + (tab_m.R_Knee_Lat_z  - xz0(2))*dir_avance(2);
avance_tobillo  = (tab_m.R_Ankle_Lat_x - xz0(1))*dir_avance(1) + (tab_m.R_Ankle_Lat_z - xz0(2))*dir_avance(2);
y_rodilla = tab_m.R_Knee_Lat_y; y_tobillo = tab_m.R_Ankle_Lat_y;

% CORREGIDO 23-ago-2026 (segunda vez): la convencion real del proyecto no
% es atan2(vertical, avance) tal cual usa Angulo_Control_Plataforma.m linea
% 84 - esa formula da el angulo respecto a la HORIZONTAL (una tibia
% casi vertical sale ~90 grados). Verificado contra los CSV reales que
% lee el simulador (REFERENCIAS/Control_apoyo_Luis_V4.csv,
% CurvaPromedio_Plataforma_Apoyo_*.csv): los valores reales van de -50 a
% +22 grados, centrados en 0 - es decir, el proyecto usa el angulo
% respecto a la VERTICAL (0 = tibia vertical), no respecto a la
% horizontal. Esto es coherente porque el "Angle 1" de Kinovea del
% dataset original se armo con la camara/ejes orientados de forma que
% "vertical real" cae cerca de 0 en su atan2 - no es la misma
% orientacion de ejes que los marcadores 3D de Camargo. Se intercambian
% los argumentos del atan2 (equivalente a medir desde el eje Y en vez
% del eje X): 0 = tibia vertical, positivo/negativo segun hacia donde se
% inclina.
theta_tibia_real_rad = atan2(avance_rodilla - avance_tobillo, y_rodilla - y_tobillo);
theta_tibia_real_rad = unwrap(theta_tibia_real_rad);

out = struct();
out.t_s = tab_m.Header;
out.pct_ciclo_R = tab_gc.HeelStrike;
out.theta_tibia_real_deg = rad2deg(theta_tibia_real_rad);
out.avance_rodilla_mm = avance_rodilla;
out.avance_tobillo_mm = avance_tobillo;
out.vertical_rodilla_mm = y_rodilla;
out.vertical_tobillo_mm = y_tobillo;
out.hip_flexion_r_deg  = tab_ik.hip_flexion_r;
out.knee_angle_r_deg   = tab_ik.knee_angle_r;
out.ankle_angle_r_deg  = tab_ik.ankle_angle_r;

% --- longitud real del segmento tibial, del ensayo estatico ---
f_static_files = dir(fullfile(f_static, '*.mat'));
if isempty(f_static_files)
    error('No se encontraron archivos .mat en la carpeta estatica: %s', f_static);
end
d_static = load(fullfile(f_static, f_static_files(1).name));
tab_s = d_static.data;

dx = tab_s.R_Knee_Lat_x - tab_s.R_Ankle_Lat_x;
dy = tab_s.R_Knee_Lat_y - tab_s.R_Ankle_Lat_y;
dz = tab_s.R_Knee_Lat_z - tab_s.R_Ankle_Lat_z;
dist_mm_por_frame = sqrt(dx.^2 + dy.^2 + dz.^2);
out.long_tibia_r_m = mean(dist_mm_por_frame) / 1000;

end
