function out = Yun2014_Wrapper(test_body_parameter, toolbox_dir)
% YUN2014_WRAPPER  Corre el toolbox real de Yun, Kim, Shin, Lee, Deshpande
%                  & Kim 2014 (Gait_Pred.m, Gaussian Process Regression
%                  con hiperparametros YA OPTIMIZADOS, sin reentrenar -
%                  NUNCA llama a Gait_Model.m, ver regla P-23) y extrae
%                  los canales sagitales relevantes para la reduccion
%                  tibial.
%
%                  No modifica Gait_Pred.m ni ningun archivo del toolbox
%                  (queda intacto como en docs/literatura/pdfs/
%                  yun2014_toolbox/, mismo criterio que VALIDACIONES/ del
%                  proyecto: codigo de terceros ya verificado, se usa tal
%                  cual). Efecto colateral conocido: Gait_Pred.m guarda
%                  15 archivos .mat y 15 .png dentro de su propia carpeta
%                  y abre figuras - viene asi del toolbox original, no se
%                  suprime aqui.
%
%   out = Yun2014_Wrapper(test_body_parameter)
%   out = Yun2014_Wrapper(test_body_parameter, toolbox_dir)
%
% ENTRADA
%   test_body_parameter   vector 1x14: [Edad, Talla(cm), Masa(kg),
%       Sexo(0:f 1:m), Long.Muslo(mm), Long.Pantorrilla(mm),
%       Ancho Bi-trocantereo(mm), Ancho Bi-iliaco(mm), ASIS(mm),
%       Diametro Rodilla(mm), Long.Pie(mm), Altura Maleolo(mm),
%       Ancho Maleolo(mm), Ancho Pie(mm)] - mismo orden que
%       docs/literatura/pdfs/yun2014_toolbox/demo_Gait_Pred.m
%   toolbox_dir   ruta a la carpeta del toolbox (default:
%       '../../docs/literatura/pdfs/yun2014_toolbox' relativo a esta
%       funcion, es decir docs/literatura/pdfs/yun2014_toolbox/ en la
%       raiz del repo)
%
% SALIDA: struct `out`, con .pct_ciclo (0-100%, 101 puntos por defecto del
%   toolbox) y, por cada canal, .mean (deg) y .std (deg):
%   .R_hip_extension, .L_hip_extension     (NUEVO respecto a la nota previa
%       de docs/algoritmo/diseno_matematico_generador.md #3.3: el toolbox
%       SI da cadera sagital, no solo rodilla+tobillo - canales 6 y 11 de
%       14, etiquetados "Hip Extension" en Gait_Pred.m linea 39-41)
%   .R_knee_flexion, .L_knee_flexion
%   .R_ankle_plantarflexion, .L_ankle_plantarflexion
%   .periodo_s        periodo de marcha predicho (canal 15)
%   .theta_tibia_via_tobillo_R_rad, .theta_tibia_via_tobillo_L_rad
%       Reduccion via tobillo (Reduccion_Winter_Core), asumiendo pie
%       plano en apoyo (theta_pie = 0) - supuesto declarado, no dato
%       medido. Camino "via rodilla" (usando Hip Extension) NO se calcula
%       aqui todavia: el signo/convencion de "Hip Extension" de Yun no
%       esta verificado contra la convencion de Reduccion_Winter_Core -
%       usar .R_hip_extension/.L_hip_extension directo si se quiere
%       intentarlo, con el signo como parametro explicito.
%
% Fuente: docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md
% #4.5, docs/algoritmo/diseno_matematico_generador.md #3.
% ==========================================================================

if nargin < 1 || ~(isnumeric(test_body_parameter) && numel(test_body_parameter) == 14)
    error('test_body_parameter debe ser un vector 1x14. Ver ayuda de esta funcion.');
end
if nargin < 2 || isempty(toolbox_dir)
    aqui = fileparts(mfilename('fullpath'));
    toolbox_dir = fullfile(aqui, '..', '..', 'docs', 'literatura', 'pdfs', 'yun2014_toolbox');
end
if ~isfolder(toolbox_dir)
    error('No se encontro la carpeta del toolbox en: %s', toolbox_dir);
end
if ~isfile(fullfile(toolbox_dir, 'database', 'Data_x.mat'))
    error(['Falta database/Data_x.mat (y/o Data_y.mat) en %s. ' ...
           'Esta gitignored por licencia KIST - ver docs/configuracion/setup_nueva_laptop.md #5.'], toolbox_dir);
end

dir_original = pwd;
cleaner = onCleanup(@() cd(dir_original)); %#ok<NASGU> vuelve al cwd aunque algo falle
cd(toolbox_dir);

Gait_Kinematics = Gait_Pred(test_body_parameter(:).', 'database', 'hyp');
close all;

etiquetas = {'PelvisXDisp','PelvisYDisp','PelvisZDisp','PelvisRot', ...
    'R_hip_adduction','R_hip_extension','R_hip_medial_rot','R_knee_flexion', ...
    'R_ankle_plantarflexion','L_hip_abduction','L_hip_extension','L_hip_lateral_rot', ...
    'L_knee_flexion','L_ankle_plantarflexion'};

out = struct();
n = numel(Gait_Kinematics{1}.mean);
out.pct_ciclo = linspace(0, 100, n);

for M = 1:14
    campo = etiquetas{M};
    out.(campo) = struct('mean', Gait_Kinematics{M}.mean(:).', 'std', sqrt(abs(Gait_Kinematics{M}.std(:).')));
end

out.periodo_s = Gait_Kinematics{15}.ys;
out.periodo_std_s = Gait_Kinematics{15}.yv2;

% --- Reduccion via tobillo (supuesto pie plano: theta_pie = 0) ---
theta_pie_cero = zeros(1, n);

red_R = Reduccion_Winter_Core(struct( ...
    'theta_pie_rad', theta_pie_cero, ...
    'phi_tobillo_rad', deg2rad(out.R_ankle_plantarflexion.mean)));
out.theta_tibia_via_tobillo_R_rad = red_R.theta_tibia_via_tobillo_rad;

red_L = Reduccion_Winter_Core(struct( ...
    'theta_pie_rad', theta_pie_cero, ...
    'phi_tobillo_rad', deg2rad(out.L_ankle_plantarflexion.mean)));
out.theta_tibia_via_tobillo_L_rad = red_L.theta_tibia_via_tobillo_rad;

end
