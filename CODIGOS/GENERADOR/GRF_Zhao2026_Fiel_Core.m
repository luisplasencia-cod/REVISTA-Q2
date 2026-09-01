function out = GRF_Zhao2026_Fiel_Core(antropometria, opciones)
% GRF_ZHAO2026_FIEL_CORE  29-ago-2026: replica FIEL del modelo de Zhao et
% al. 2026 (Secs.2.2-2.5) para la fuerza de reaccion VERTICAL del piso.
%
% RESULTADO (29-ago-2026, mismo dia): probada contra Kuopio real (N=13),
% r=0.10 - PEOR que el hibrido GRF_Newton_ApoyoSimple_Core.m (r=0.40). La
% curva sale bien acotada (59-155%BW, sin picos), pero la cinematica
% propia de Zhao tiene el defecto de fase ya documentado en este proyecto
% (JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md #6.7-6.8) - geometria limpia con
% angulos malos. Se deja como evidencia documentada de que SI se probo la
% formula de Zhao completa (no solo un hibrido) - ver GUIA_INTERPRETACION.md
% #8-ter para la comparativa completa. NINGUNO de los intentos basados en
% angulos articulares (esta funcion incluida) es el modelo vigente hoy -
% superado por el modelo empirico de Fukuchi, r=0.866 (#8-quinquies).
%
% -----------------------------------------------------------------------
% a diferencia de GRF_Newton_ApoyoSimple_Core.m (que mezcla la cinematica
% de Koopman con una geometria de 2 segmentos propia del proyecto y una
% separacion de pasos X_step asumida), esta funcion usa SOLO piezas de
% Zhao: su propia cinematica (Zhao2026_Core.m, Ecs.1-2, la MISMA formula
% para las 2 piernas, desfasada por el termino +j*pi de la Ec.2 - no un
% desfase de tiempo hecho a mano) y su propia simplificacion geometrica
% declarada (Sec.2.3): "the standing leg is simplified as a rigid rod
% fixed to the ground... the swinging leg is simplified as two articulated
% rigid links".
%
% POR QUE ESTA FUNCION EXISTE (pedido explicito del usuario, 29-ago-2026):
% al ver que GRF_Newton_ApoyoSimple_Core.m sobreestima en los bordes del
% doble apoyo, el usuario pregunto directamente si la formula PUBLICADA de
% Zhao de verdad funciona o no. Respuesta: nunca se corrio la formula de
% Zhao completa - se armo un hibrido (cinematica de Koopman + geometria de
% 2 segmentos + X_step asumido) que mezcla piezas nunca validadas juntas.
% Esta funcion corre la pieza de Zhao SOLA, tal como el la publico, antes
% de decidir que ajustes hacer.
%
% EL HALLAZGO CLAVE que motiva intentar esto de nuevo (verificado en esta
% sesion con GRF_Newton_ApoyoSimple_Core.m): la fuerza VERTICAL solo
% necesita la posicion VERTICAL (Y) de cada segmento, medida desde el
% tobillo de ESA MISMA pierna (que siempre esta en Y=0 cuando toca el
% piso, sin importar en que X este) - a diferencia de la posicion
% horizontal, la vertical NUNCA necesita saber la separacion entre los dos
% tobillos (X_step). Ese fue exactamente el origen del error grande (~100cm)
% encontrado en la version anterior. Replicando a Zhao (sin el X_step
% inventado, y con la pierna de apoyo como UN SOLO rigido en vez de 2
% segmentos con flexion de rodilla) esta funcion evita esa fuente de error
% por construccion, no por parche.
%
% ALCANCE DECLARADO: SOLO fuerza vertical (Fz) - igual que
% GRF_Newton_ApoyoSimple_Core.m, decision ya tomada del usuario ("yo solo
% medire Fz"). No calcula GRF horizontal ni momentos articulares (Sec.2.6,
% que si necesita las "supplemental materials" no disponibles - eso sigue
% sin implementarse, con razon).
%
% PARAMETROS DE ZHAO QUE NO ESTAN PUBLICADOS Y SE SUSTITUYEN, DECLARADO:
%   - p1,p2,p3 (distancia centroide-origen de cada segmento, Fig.2): Zhao
%     no publica valores numericos. Se usan las fracciones de de Leva 1996
%     ya usadas en el resto del proyecto (MasaSegmentaria_DeLeva1996_Core.m)
%     aplicadas a lo largo del segmento (o del "rod" completo en apoyo).
%   - frac_apoyo (12%/38% doble/simple por medio-ciclo en Zhao Fig.1): se
%     reusa el mismo 0.6 de frac_apoyo ya calibrado contra Kuopio para
%     Koopman en el resto del proyecto (misma decision ya declarada en
%     GRF_Newton_ApoyoSimple_Core.m) - Zhao publica una particion fija que
%     no se verifico como aplicable a este generador.
%   - Durante el doble apoyo, la altura de cadera (Y_hip, proxy de HAT) se
%     aproxima como el PROMEDIO de la altura que da el "rod" de cada
%     pierna por separado (ninguna de las dos es mas correcta que la
%     otra ya que ambas deberian coincidir si el modelo fuera perfecto).
%
% ENTRADA
%   antropometria   struct con .talla_m, .masa_kg (obligatorio), .sexo
%                   (obligatorio), + opcionales de siempre
%   opciones.n              puntos por fase temporal (default 101)
%   opciones.N_uniforme     puntos del grid uniforme para derivar (default 201)
%
% SALIDA: struct `out` con .t_s, .pct_ciclo, .GRF_vertical_pctBW,
%   .Y_hip_cm, .verificacion_media_vGRF_pctBW (debe dar ~100%BW)
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
if ~isfield(opciones,'N_uniforme') || isempty(opciones.N_uniforme), opciones.N_uniforme = 201; end
N = opciones.N_uniforme;
G = 9.80665;

antro = Estimar_Antropometria_Core(antropometria);
masaSeg = MasaSegmentaria_DeLeva1996_Core(struct('masa_kg', antro.masa_kg, 'sexo', antro.sexo));
M_total = antro.masa_kg;

% Motor de temporizacion compartido (mismo criterio que el resto del
% proyecto - Zhao no publica su propio T(v,talla) verificado para este
% generador, ver GUIA_INTERPRETACION.md):
tempo = Temporizacion_Core(antro, 'Koopman');
T = tempo.tiempo_ciclo_s;
f = 1/T;
l = antro.long_muslo_m + antro.long_tibia_m;

Zi = Zhao2026_Core(l, f, struct('lado','izquierda','nMuestras', N));
Zd = Zhao2026_Core(l, f, struct('lado','derecha',  'nMuestras', N));
t_u = Zi.t;  % [0,T), N puntos - grid ya uniforme, sin re-muestreo por fases

phi_hip_trackeada  = Zi.phi_cadera_rad;
phi_knee_trackeada = Zi.phi_rodilla_rad;
phi_hip_contra     = Zd.phi_cadera_rad;
phi_knee_contra    = Zd.phi_rodilla_rad;

Lt_cm = antro.long_tibia_m*100;
Lm_cm = antro.long_muslo_m*100;
fc_m  = masaSeg.muslo_com_frac;   % fraccion desde cadera hacia rodilla
fc_p  = masaSeg.pierna_com_frac;  % fraccion desde rodilla hacia tobillo

frac_apoyo = tempo.frac_apoyo;
tiempo_apoyo_s = frac_apoyo * T;
T_DT = tiempo_apoyo_s - T/2;
if T_DT <= 0
    error('GRF_Zhao2026_Fiel_Core:fracApoyoInvalida', 'frac_apoyo debe ser > 0.5 para que haya doble apoyo real.');
end

fase = mod(t_u, T);
en_apoyo_trackeada = fase <= tiempo_apoyo_s;
fase_contra = mod(t_u + T/2, T);
contra_en_apoyo = fase_contra <= tiempo_apoyo_s;

m_simple_trackeada = en_apoyo_trackeada & ~contra_en_apoyo;   % trackeada=rod, contra=cadena
m_simple_contra    = contra_en_apoyo & ~en_apoyo_trackeada;   % contra=rod, trackeada=cadena
m_doble            = en_apoyo_trackeada & contra_en_apoyo;    % ambas=rod

% --- "Rod" (Sec.2.3, pierna de apoyo = 1 segmento rigido, SIN flexion de
% rodilla): Y medida desde el propio tobillo de esa pierna (fijo en Y=0). ---
Y_hip_rod         = @(th1) (Lt_cm+Lm_cm).*cos(th1);
Y_com_muslo_rod   = @(th1) (Lt_cm + Lm_cm*(1-fc_m)) .* cos(th1);
Y_com_pierna_rod  = @(th1) Lt_cm*(1-fc_p) .* cos(th1);

% --- Altura de cadera (Y_hip, proxy de HAT en todo el archivo) ---
Y_hip = nan(1,N);
Y_hip(m_simple_trackeada) = Y_hip_rod(phi_hip_trackeada(m_simple_trackeada));
Y_hip(m_simple_contra)    = Y_hip_rod(phi_hip_contra(m_simple_contra));
Y_hip(m_doble) = 0.5*( Y_hip_rod(phi_hip_trackeada(m_doble)) + Y_hip_rod(phi_hip_contra(m_doble)) );
if any(isnan(Y_hip))
    error('GRF_Zhao2026_Fiel_Core:mascaraIncompleta', 'Las 3 mascaras de fase no cubrieron el ciclo completo.');
end

% --- Contribucion Y de CADA pierna (trackeada, contralateral) segun su
% propio rol en cada instante: "rod" si esa pierna esta en apoyo, "cadena
% de 2 segmentos colgando de Y_hip" (Sec.2.3, pierna oscilante) si no. ---
[Y_muslo_trackeada, Y_pierna_trackeada, Y_tobillo_trackeada] = contribucion_pierna_local( ...
    en_apoyo_trackeada, phi_hip_trackeada, phi_knee_trackeada, Y_hip, Lt_cm, Lm_cm, fc_m, fc_p, ...
    Y_com_muslo_rod, Y_com_pierna_rod);
[Y_muslo_contra, Y_pierna_contra, Y_tobillo_contra] = contribucion_pierna_local( ...
    contra_en_apoyo, phi_hip_contra, phi_knee_contra, Y_hip, Lt_cm, Lm_cm, fc_m, fc_p, ...
    Y_com_muslo_rod, Y_com_pierna_rod);

% --- CoM de cuerpo completo (HAT aproximado en la cadera, mismo criterio
% ya declarado y usado en GRF_Newton_ApoyoSimple_Core.m) ---
mH = masaSeg.hat_masa_frac; mMu = masaSeg.muslo_masa_frac;
mPi = masaSeg.pierna_masa_frac; mPie = masaSeg.pie_masa_frac;
suma_frac = mH + 2*mMu + 2*mPi + 2*mPie;

Y_com_cm = (mH*Y_hip + mMu*(Y_muslo_trackeada+Y_muslo_contra) + mPi*(Y_pierna_trackeada+Y_pierna_contra) + mPie*(Y_tobillo_trackeada+Y_tobillo_contra)) / suma_frac;
Y_com_m = Y_com_cm/100;

% --- Derivar (extension periodica + suavizado, mismo procedimiento que
% GRF_Newton_ApoyoSimple_Core.m - Y es periodica, sin deriva neta) ---
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
out.pct_ciclo = 100*t_u/T;
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
function [Y_muslo, Y_pierna, Y_tobillo] = contribucion_pierna_local(en_apoyo, phi_hip, phi_knee, Y_hip, Lt_cm, Lm_cm, fc_m, fc_p, Y_com_muslo_rod, Y_com_pierna_rod)
% Contribucion Y de UNA pierna: "rod" (Sec.2.3, sin flexion de rodilla) si
% esta en apoyo; cadena de 2 segmentos colgando de Y_hip (con la flexion
% de rodilla real, via-rodilla: theta_tibia=phi_hip-phi_knee, mismo
% convenio que el resto del proyecto) si esta en balanceo.
N = numel(phi_hip);
Y_muslo = nan(1,N); Y_pierna = nan(1,N); Y_tobillo = nan(1,N);

Y_muslo(en_apoyo)  = Y_com_muslo_rod(phi_hip(en_apoyo));
Y_pierna(en_apoyo) = Y_com_pierna_rod(phi_hip(en_apoyo));
Y_tobillo(en_apoyo) = 0;  % tobillo fijo en el piso mientras esta en apoyo

ib = ~en_apoyo;
theta_muslo_bal = phi_hip(ib);
theta_tibia_bal = phi_hip(ib) - phi_knee(ib);
Y_knee_bal = Y_hip(ib) - Lm_cm*cos(theta_muslo_bal);
Y_tobillo(ib) = Y_knee_bal - Lt_cm*cos(theta_tibia_bal);
Y_muslo(ib)  = Y_hip(ib) - fc_m*Lm_cm*cos(theta_muslo_bal);
Y_pierna(ib) = Y_knee_bal - fc_p*Lt_cm*cos(theta_tibia_bal);
end
