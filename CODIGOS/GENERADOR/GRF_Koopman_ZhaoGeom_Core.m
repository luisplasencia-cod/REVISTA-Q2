function out = GRF_Koopman_ZhaoGeom_Core(antropometria, opciones)
% GRF_KOOPMAN_ZHAOGEOM_CORE  29-ago-2026: combina la cinematica de Koopman
% 2014 (el modelo que gana en angulo contra 5 bases de datos reales, ver
% docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md) con la geometria
% FIEL de Zhao 2026 para GRF (GRF_Zhao2026_Fiel_Core.m: pierna de apoyo
% como 1 solo rigido, sin necesitar la separacion entre pasos X_step).
%
% RESULTADO (29-ago-2026, mismo dia): probada contra Kuopio real (N=13),
% r=0.002 - el PEOR de los 6 intentos basados en cinematica articular de
% esta sesion (peor que la cinematica de Zhao pura, r=0.10, y muy por
% debajo del hibrido Koopman+geometria propia, r=0.40). La simplificacion
% "sin flexion de rodilla en apoyo" de Zhao no generaliza bien a los
% angulos de Koopman - hallazgo real, no un bug de implementacion. Se deja
% como evidencia documentada - ver GUIA_INTERPRETACION.md #8-ter para la
% comparativa completa. NINGUNO de los 6 intentos basados en angulos
% articulares es el modelo vigente hoy - superado por el modelo empirico
% de Fukuchi (r=0.866, GUIA_INTERPRETACION.md #8-quinquies).
%
% POR QUE: se probaron 2 versiones puras en esta sesion -
%   - GRF_Newton_ApoyoSimple_Core.m: cinematica de Koopman (buena) +
%     geometria propia de 2 segmentos + X_step asumido -> picos y
%     sobreimpulso en el doble apoyo (r=0.40 contra Kuopio real).
%   - GRF_Zhao2026_Fiel_Core.m: cinematica de Zhao (floja, defecto de fase
%     ya documentado) + geometria fiel de Zhao (limpia, sin X_step) ->
%     curva bien acotada (59-155%BW) pero mal correlacionada (r=0.10).
% Esta funcion prueba la combinacion que faltaba: la geometria BUENA
% (la de Zhao, que evita el problema de raiz porque Y nunca necesita
% X_step) con la cinematica BUENA (la de Koopman, calibrada LOSO contra
% Kuopio, Calibracion_Koopman_Kuopio_Core.m).
%
% DIFERENCIA CON GRF_Zhao2026_Fiel_Core.m: la pierna contralateral no usa
% el desfase de fase +j*pi nativo de Zhao (Koopman no tiene ese mecanismo)
% - se construye igual que en GRF_Newton_ApoyoSimple_Core.m, extendiendo la
% serie de angulo un periodo y evaluando en t+T/2 (aproximacion de marcha
% simetrica, misma que usa el resto del proyecto).
%
% ALCANCE: solo Fz, igual que las otras 2 funciones de GRF de esta linea.
% ==========================================================================

if nargin < 1 || ~isstruct(antropometria) || ~isfield(antropometria,'talla_m')
    error('antropometria debe ser un struct con al menos el campo talla_m.');
end
if ~isfield(antropometria,'masa_kg') || ~(isnumeric(antropometria.masa_kg) && isscalar(antropometria.masa_kg) && antropometria.masa_kg>0)
    error('antropometria.masa_kg es obligatorio (escalar positivo).');
end
if ~isfield(antropometria,'sexo') || isempty(antropometria.sexo)
    error('antropometria.sexo es obligatorio (''M'' o ''F'').');
end
if nargin < 2, opciones = struct(); end
if ~isfield(opciones,'n') || isempty(opciones.n), opciones.n = 101; end
if ~isfield(opciones,'N_uniforme') || isempty(opciones.N_uniforme), opciones.N_uniforme = 201; end
if ~isfield(opciones,'calibrar_koopman') || isempty(opciones.calibrar_koopman), opciones.calibrar_koopman = true; end
n = opciones.n; N = opciones.N_uniforme; G = 9.80665;

antro = Estimar_Antropometria_Core(antropometria);
masaSeg = MasaSegmentaria_DeLeva1996_Core(struct('masa_kg', antro.masa_kg, 'sexo', antro.sexo));
M_total = antro.masa_kg;

tempo = Temporizacion_Core(antro, 'Koopman');
opts_cal = struct('calibrar_koopman', opciones.calibrar_koopman);
[theta_tibia_full, ~, tempo, theta_muslo_full, ~] = Obtener_Theta_Tibia_Candidato('Koopman', antro, tempo, n, opts_cal);
% theta_tibia_full == theta_muslo_full en tamano y en base de tiempo (0-100%
% del ciclo COMPLETO, no solo la fase de apoyo) - misma convencion ya
% establecida en GRF_Newton_ApoyoSimple_Core.m para Koopman/Zhao.
pct_ciclo_nativo = linspace(0, 100, numel(theta_tibia_full));

T = tempo.tiempo_ciclo_s;
t_u = linspace(0, T, N);
pct_u = 100*t_u/T;
theta_muslo_trackeada = interp1(pct_ciclo_nativo, theta_muslo_full, pct_u, 'pchip');
theta_tibia_trackeada = interp1(pct_ciclo_nativo, theta_tibia_full, pct_u, 'pchip');

% --- Contralateral: misma serie, desfasada medio ciclo (aproximacion de
% marcha simetrica, igual que GRF_Newton_ApoyoSimple_Core.m) ---
t_ext = [t_u(1:end-1)-T, t_u, t_u(2:end)+T];
thm_ext = [theta_muslo_trackeada(1:end-1), theta_muslo_trackeada, theta_muslo_trackeada(2:end)];
tht_ext = [theta_tibia_trackeada(1:end-1), theta_tibia_trackeada, theta_tibia_trackeada(2:end)];
theta_muslo_contra = interp1(t_ext, thm_ext, t_u+T/2, 'pchip');
theta_tibia_contra = interp1(t_ext, tht_ext, t_u+T/2, 'pchip');
% phi_rodilla implicito (para reusar el mismo helper de GRF_Zhao2026_Fiel_
% Core.m, que espera "phi_hip" y "phi_knee" por separado, no theta_tibia
% ya reducido): phi_rodilla = theta_muslo - theta_tibia (definicion de la
% reduccion via-rodilla, Sec.2.6 de Zhao, ya usada en todo el proyecto).
phi_knee_trackeada = theta_muslo_trackeada - theta_tibia_trackeada;
phi_knee_contra    = theta_muslo_contra    - theta_tibia_contra;

Lt_cm = antro.long_tibia_m*100;
Lm_cm = antro.long_muslo_m*100;
fc_m  = masaSeg.muslo_com_frac;
fc_p  = masaSeg.pierna_com_frac;

frac_apoyo = tempo.frac_apoyo;
tiempo_apoyo_s = frac_apoyo*T;
T_DT = tiempo_apoyo_s - T/2;
if T_DT <= 0
    error('GRF_Koopman_ZhaoGeom_Core:fracApoyoInvalida', 'frac_apoyo debe ser > 0.5.');
end

fase = mod(t_u, T);
en_apoyo_trackeada = fase <= tiempo_apoyo_s;
fase_contra = mod(t_u+T/2, T);
contra_en_apoyo = fase_contra <= tiempo_apoyo_s;

m_simple_trackeada = en_apoyo_trackeada & ~contra_en_apoyo;
m_simple_contra    = contra_en_apoyo & ~en_apoyo_trackeada;
m_doble            = en_apoyo_trackeada & contra_en_apoyo;

Y_hip_rod        = @(th1) (Lt_cm+Lm_cm).*cos(th1);
Y_com_muslo_rod  = @(th1) (Lt_cm + Lm_cm*(1-fc_m)) .* cos(th1);
Y_com_pierna_rod = @(th1) Lt_cm*(1-fc_p) .* cos(th1);

Y_hip = nan(1,N);
Y_hip(m_simple_trackeada) = Y_hip_rod(theta_muslo_trackeada(m_simple_trackeada));
Y_hip(m_simple_contra)    = Y_hip_rod(theta_muslo_contra(m_simple_contra));
Y_hip(m_doble) = 0.5*( Y_hip_rod(theta_muslo_trackeada(m_doble)) + Y_hip_rod(theta_muslo_contra(m_doble)) );
if any(isnan(Y_hip))
    error('GRF_Koopman_ZhaoGeom_Core:mascaraIncompleta', 'Las 3 mascaras de fase no cubrieron el ciclo completo.');
end

[Y_muslo_trackeada, Y_pierna_trackeada, Y_tobillo_trackeada] = contribucion_pierna_local2( ...
    en_apoyo_trackeada, theta_muslo_trackeada, phi_knee_trackeada, Y_hip, Lt_cm, Lm_cm, fc_m, fc_p, Y_com_muslo_rod, Y_com_pierna_rod);
[Y_muslo_contra, Y_pierna_contra, Y_tobillo_contra] = contribucion_pierna_local2( ...
    contra_en_apoyo, theta_muslo_contra, phi_knee_contra, Y_hip, Lt_cm, Lm_cm, fc_m, fc_p, Y_com_muslo_rod, Y_com_pierna_rod);

mH = masaSeg.hat_masa_frac; mMu = masaSeg.muslo_masa_frac;
mPi = masaSeg.pierna_masa_frac; mPie = masaSeg.pie_masa_frac;
suma_frac = mH + 2*mMu + 2*mPi + 2*mPie;

Y_com_cm = (mH*Y_hip + mMu*(Y_muslo_trackeada+Y_muslo_contra) + mPi*(Y_pierna_trackeada+Y_pierna_contra) + mPie*(Y_tobillo_trackeada+Y_tobillo_contra)) / suma_frac;
Y_com_m = Y_com_cm/100;

dt = t_u(2)-t_u(1);
y_ext = [Y_com_m(1:end-1), Y_com_m, Y_com_m(2:end)];
framelen = 2*floor(N/10) + 1;
y_ext = sgolayfilt(y_ext, 3, framelen);
ay_ext = gradient(gradient(y_ext, dt), dt);
ay_u = ay_ext(N:2*N-1);

GRF_v = M_total*(G+ay_u);
BW_N = M_total*G;

out = struct();
out.t_s = t_u;
out.pct_ciclo = pct_u;
out.GRF_vertical_N = GRF_v;
out.GRF_vertical_pctBW = 100*GRF_v/BW_N;
out.Y_hip_cm = Y_hip;
out.apoyo_simple_mask = m_simple_trackeada;
out.doble_apoyo_mask = m_doble;
out.verificacion_media_vGRF_pctBW = mean(GRF_v)/BW_N*100;
out.masaSeg = masaSeg;
out.antro = antro;
out.tempo = tempo;

end

% --------------------------------------------------------------------
function [Y_muslo, Y_pierna, Y_tobillo] = contribucion_pierna_local2(en_apoyo, theta_muslo, phi_knee, Y_hip, Lt_cm, Lm_cm, fc_m, fc_p, Y_com_muslo_rod, Y_com_pierna_rod)
N = numel(theta_muslo);
Y_muslo = nan(1,N); Y_pierna = nan(1,N); Y_tobillo = nan(1,N);

Y_muslo(en_apoyo)  = Y_com_muslo_rod(theta_muslo(en_apoyo));
Y_pierna(en_apoyo) = Y_com_pierna_rod(theta_muslo(en_apoyo));
Y_tobillo(en_apoyo) = 0;

ib = ~en_apoyo;
theta_muslo_bal = theta_muslo(ib);
theta_tibia_bal = theta_muslo(ib) - phi_knee(ib);
Y_knee_bal = Y_hip(ib) - Lm_cm*cos(theta_muslo_bal);
Y_tobillo(ib) = Y_knee_bal - Lt_cm*cos(theta_tibia_bal);
Y_muslo(ib)  = Y_hip(ib) - fc_m*Lm_cm*cos(theta_muslo_bal);
Y_pierna(ib) = Y_knee_bal - fc_p*Lt_cm*cos(theta_tibia_bal);
end
