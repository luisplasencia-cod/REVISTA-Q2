function [th_muslo, th_tibia, tempo] = Obtener_Angulos_Candidato(candidato, antro, tempo, n)
% OBTENER_ANGULOS_CANDIDATO  Devuelve theta_muslo Y theta_tibia (rad) por
%                   fase, para cualquiera de los candidatos - insumo de
%                   Cadena_Completa_Core.m (24-ago-2026).
%                   Complementa a Obtener_Theta_Tibia_Candidato.m, que
%                   solo daba la tibia.
%
%   theta_muslo: angulo ABSOLUTO del muslo (0 = vertical). Se toma del
%   angulo de CADERA de cada modelo, bajo el supuesto ya establecido y
%   verificado a texto completo en el proyecto (Zhao 2026 pag.8, citado en
%   Yun2014_Wrapper.m): "the angle of the pelvis in the sagittal plane is
%   zero during walking; thus theta_hip = phi_hip" - es decir, con pelvis
%   vertical, el angulo absoluto del muslo coincide con el angulo articular
%   de cadera. Supuesto declarado, no inventado aqui.
%
% SALIDA: th_muslo y th_tibia son structs con .apoyo y .balanceo [1 x n]

if nargin < 4 || isempty(n), n = 101; end

switch lower(candidato)
    case 'koopman'
        K = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, struct('nMuestras', n));
        tempo.tiempo_ciclo_s = K.tiempo_ciclo_s;
        m_full = deg2rad(K.cadera_flexext.angulo_deg);
        t_full = K.theta_tibia_via_rodilla_rad;   % via rodilla (ver Obtener_Theta_Tibia_Candidato.m)

    case 'zhao'
        Z = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/tempo.tiempo_ciclo_s, struct('nMuestras', n));
        m_full = Z.phi_cadera_rad;
        t_full = Z.theta_tibia_rad;

    case 'yun'
        Y = Yun2014_Wrapper(vector14_desde_antropometria(antro));
        tempo.tiempo_ciclo_s = Y.periodo_s;
        m_full = deg2rad(Y.R_hip_extension.mean);
        % CORREGIDO 26-ago-2026 (el usuario detecto que esta figura daba un
        % angulo tibial distinto al de Evaluar_Mejor_Modelo_Rodilla.m para
        % el mismo candidato): la via_rodilla para Yun esta MARCADA COMO NO
        % CONFIABLE por E2 (defasaje del pico de flexion de rodilla, ver
        % Obtener_Theta_Tibia_Candidato.m) - esta funcion usaba via_rodilla
        % de todos modos, inconsistente con la regla ya establecida. Se usa
        % via_tobillo (Y.theta_tibia_via_tobillo_R_rad, ya calculado por el
        % propio wrapper), igual que Obtener_Theta_Tibia_Candidato.m.
        t_full = Y.theta_tibia_via_tobillo_R_rad;

    otherwise
        error('candidato debe ser Koopman, Zhao o Yun. Se recibio: %s', mat2str(candidato));
end

% Recortar a las ventanas de fase (mismo patron que Generar_Trayectoria.m)
pct_nat  = linspace(0, 100, numel(t_full));
pct_corte = tempo.frac_apoyo * 100;
pct_ap  = linspace(0, pct_corte, n);
pct_bal = linspace(pct_corte, 100, n);

th_muslo = struct('apoyo',    interp1(pct_nat, m_full, pct_ap,  'pchip'), ...
                  'balanceo', interp1(pct_nat, m_full, pct_bal, 'pchip'));
th_tibia = struct('apoyo',    interp1(pct_nat, t_full, pct_ap,  'pchip'), ...
                  'balanceo', interp1(pct_nat, t_full, pct_bal, 'pchip'));

end

% ==========================================================================
function p14 = vector14_desde_antropometria(antro)
if ~isfield(antro,'edad_anios') || isempty(antro.edad_anios), antro.edad_anios = 25; end
if ~isfield(antro,'sexo'), antro.sexo = 'M'; end
sexo01 = double(upper(antro.sexo(1)) == 'M');
p14 = [antro.edad_anios, antro.talla_m*100, antro.masa_kg, sexo01, ...
       antro.long_muslo_m*100, antro.long_tibia_m*100, ...
       32.8, 29.7, 25.5, 10, antro.long_pie_m*100, 7.30, 7.10, 9.80];
end
