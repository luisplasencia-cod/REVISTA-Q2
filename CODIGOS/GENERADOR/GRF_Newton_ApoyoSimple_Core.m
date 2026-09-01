function out = GRF_Newton_ApoyoSimple_Core(antropometria, candidato, opciones)
% GRF_NEWTON_APOYOSIMPLE_CORE  Fuerza de reaccion del piso (GRF) vertical
%                          y anteroposterior, PARA LA VENTANA DE APOYO
%                          SIMPLE UNICAMENTE, a partir de la trayectoria ya
%                          generada por este proyecto + la 2da ley de
%                          Newton sobre el centro de masa (CoM) de CUERPO
%                          COMPLETO. 27-ago-2026.
%
% POR QUE ESTE MODELO Y NO LAS ECUACIONES PUBLICADAS DE ZHAO 2026 (Sec.2.4-
% 2.6, Ecs.5-10): esas ecuaciones dependen de la derivacion de energia
% cinetica/potencial del modelo, que el propio paper remite a "supplemental
% materials" no disponibles en este proyecto - implementarlas adivinando
% como se pondera cada termino es alto riesgo (error silencioso de signo o
% de que masa va con que aceleracion, dificil de detectar). Se usa en su
% lugar la 2da ley de Newton sobre el CoM de cuerpo completo, que es EXACTA
% por definicion (no una aproximacion del modelo de Zhao) y totalmente
% verificable termino a termino con lo que este proyecto ya tiene
% construido y validado. Decision del usuario, 27-ago-2026 ("hazlo lo mejor
% que puedas sin tomar alto riesgo").
%
% MODELO
%   GRF_vertical(t)      = M_total * (g + a_CoM_y(t))
%   GRF_anteroposterior(t) = M_total * a_CoM_x(t)
% donde CoM de cuerpo completo se aproxima como la suma ponderada de:
%   - HAT (cabeza+tronco+2 brazos, "m" en la notacion de Zhao 2026 Sec.2.4)
%     -> se aproxima con la posicion/aceleracion de la CADERA (misma
%     simplificacion YA declarada y usada en Cadena_Completa_Core.m para
%     la altura de cadera en balanceo: "el vaiven vertical real de cadera
%     no se modela aqui, se declara, no se inventa").
%   - Muslo y pierna (shank) de la pierna TRACKEADA (apoyo) -> CoM real via
%     MasaSegmentaria_DeLeva1996_Core.m (posicion del CoM dentro del
%     segmento, no el punto medio).
%   - Muslo, pierna y pie de la pierna CONTRALATERAL -> NO se genera un
%     segundo modelo de marcha completo. Se usa la MISMA serie de angulos
%     (theta_muslo, theta_tibia) que ya genero este pipeline para la
%     pierna trackeada, evaluada medio ciclo (50%) despues - aproximacion
%     de marcha simetrica, estandar en la literatura, y ademas ya
%     verificada como un mecanismo REAL en este proyecto (el hallazgo del
%     "desfase de fase de 50%" en el parametro `lado` de Zhao/Yun, ver
%     docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md #6.7). La pierna
%     contralateral se reconstruye colgando de la MISMA cadera real
%     (formula identica a la que ya usa Cadena_Completa_Core.m para el
%     balanceo: rodilla = cadera + L*(sin(theta_muslo),-cos(theta_muslo)),
%     tobillo = rodilla + L*(sin(theta_tibia),-cos(theta_tibia)) - se
%     verifico que esta MISMA formula es la que usa el apoyo tambien,
%     solo recorrida en sentido inverso, ver comentario en el codigo).
%   - Pie de la pierna trackeada -> CoM aproximado en el TOBILLO (no se
%     modela el pie como segmento propio en este generador; simplificacion
%     declarada, masa de pie es ~1.3-1.4% del cuerpo por lado).
%
% ALCANCE DECLARADO (v1, "riesgo bajo"): la formula de arriba da la fuerza
% TOTAL bajo AMBOS pies (out.GRF_vertical_pctBW). Durante apoyo simple
% verdadero (solo la pierna trackeada toca el piso) esa fuerza total ES
% EXACTAMENTE la fuerza bajo esa pierna - no hace falta repartir nada.
% ACTUALIZADO 28-ago-2026 (ya NO es cierto que el doble apoyo quede sin
% repartir): se agrego el reparto de doble apoyo (Zhao Ec.9, SOLO
% componente vertical) mas abajo en este archivo - ver
% out.GRF_vertical_trackeada_pctBW y out.mask_confiable_trackeada, que
% extienden la ventana comparable contra una plataforma de un pie a casi
% todo el ciclo de apoyo, no solo al tramo de apoyo simple.
%
% ESTADO VIGENTE (29-ago-2026): este pipeline completo (cinematica de
% Koopman + geometria propia + reparto de doble apoyo) da r=0.40 contra
% Kuopio real - QUEDO SUPERADO por un modelo empirico basado en datos
% reales medidos (Fukuchi et al. 2018, sin pasar por ningun angulo
% articular), r=0.866 - ver Predecir_GRF_Personalizado_Core.m y
% GUIA_INTERPRETACION.md #8-quinquies. Esta funcion y su cadena de
% dependencias (Cadera_Continua_Zhao_Core.m, etc.) se conservan como
% evidencia documentada de lo que se probo, no como el camino recomendado.
%
% ENTRADA
%   antropometria   struct: .talla_m, .masa_kg (OBLIGATORIO aqui, a
%                   diferencia de Generar_Trayectoria.m - sin masa no hay
%                   fuerza), .sexo (OBLIGATORIO, MasaSegmentaria_DeLeva1996_
%                   Core.m lo necesita), + opcionales de siempre
%                   (long_muslo_m, long_tibia_m, velocidad_ms)
%   candidato       'Koopman' (default) | 'Yun' | 'Zhao' (NO 'Combinado' -
%                   Combinar_Candidatos_Core.m no expone theta_muslo/
%                   theta_tibia por separado, solo posicion ya promediada)
%   opciones.n      puntos por fase para la generacion de angulos (default
%                   101, igual que el resto del proyecto)
%   opciones.N_uniforme   puntos del grid uniforme de tiempo para derivar
%                   (default 201) - mas puntos = derivada mas suave pero
%                   mas lento
%
% SALIDA: struct `out`
%   .t_s, .pct_ciclo         grid uniforme de tiempo, un ciclo completo
%   .GRF_vertical_N, .GRF_horizontal_N     fuerza total bajo ambos pies (N)
%   .GRF_vertical_pctBW, .GRF_horizontal_pctBW   idem, % de peso corporal
%   .apoyo_simple_mask       true donde SOLO la pierna trackeada toca el
%                            piso (la contralateral esta en su propio
%                            balanceo) - fuera de esta mascara, ver aviso
%                            de alcance arriba
%   .apoyo_simple_mask_estricta   como .apoyo_simple_mask pero erosionada
%                            ~framelen/2 muestras desde cada borde (excluye
%                            la franja donde el suavizado Savitzky-Golay
%                            todavia mezcla puntos de la transicion de
%                            doble apoyo) - USAR ESTA, no la de arriba,
%                            para comparar valores de GRF contra datos
%                            reales (ver Test 8 de Test_GRF_Newton_
%                            ApoyoSimple.m, que encontro la contaminacion
%                            de borde el 28-ago-2026)
%   .verificacion_media_vGRF_pctBW   promedio de GRF_vertical_pctBW en
%                            el ciclo completo - debe dar ~100%BW (la
%                            aceleracion media de un ciclo PERIODICO es
%                            cero por definicion, así que la fuerza
%                            vertical media debe igualar el peso corporal
%                            exactamente; sirve de autochequeo numerico,
%                            no depende de datos reales de ninguna base)
%   .masaSeg, .antro, .tempo    structs intermedios, para trazabilidad
% ==========================================================================

if nargin < 1 || ~isstruct(antropometria) || ~isfield(antropometria,'talla_m')
    error('antropometria debe ser un struct con al menos el campo talla_m.');
end
if ~isfield(antropometria,'masa_kg') || ~(isnumeric(antropometria.masa_kg) && isscalar(antropometria.masa_kg) && antropometria.masa_kg>0)
    error('antropometria.masa_kg es obligatorio para GRF (masa_kg, escalar positivo). Se recibio: %s', mat2str(getfield_safe(antropometria,'masa_kg')));
end
if ~isfield(antropometria,'sexo') || isempty(antropometria.sexo)
    error('antropometria.sexo es obligatorio para GRF (''M'' o ''F'').');
end
if nargin < 2 || isempty(candidato), candidato = 'Koopman'; end
if ~any(strcmpi(candidato, {'Koopman','Yun','Zhao'}))
    error('candidato debe ser ''Koopman'', ''Yun'' o ''Zhao'' (''Combinado'' no soportado aqui - no expone theta_muslo/theta_tibia por separado). Se recibio: %s', mat2str(candidato));
end
if nargin < 3, opciones = struct(); end
if ~isfield(opciones,'n') || isempty(opciones.n), opciones.n = 101; end
if ~isfield(opciones,'N_uniforme') || isempty(opciones.N_uniforme), opciones.N_uniforme = 201; end
% CALIBRACION AFIN KOOPMAN (28-ago-2026, default ON, mismo criterio que
% Generar_Trayectoria.m - ver Calibracion_Koopman_Kuopio_Core.m) ---
if ~isfield(opciones,'calibrar_koopman') || isempty(opciones.calibrar_koopman)
    opciones.calibrar_koopman = true;
end
n = opciones.n;
N = opciones.N_uniforme;
G_MS2 = 9.80665;

% --- Antropometria + masa segmentaria ---
antro = Estimar_Antropometria_Core(antropometria);
masaSeg = MasaSegmentaria_DeLeva1996_Core(struct('masa_kg', antro.masa_kg, 'sexo', antro.sexo));
M_total = antro.masa_kg;

% --- Temporizacion + angulos, UNA SOLA llamada al modelo del candidato
% (28-ago-2026, corrige H8 de _REVISION/detalle/03_codigo.md: la version
% anterior llamaba Obtener_Theta_Tibia_Candidato Y Obtener_Angulos_
% Candidato, cada una re-corriendo el modelo completo del candidato desde
% cero - caro para Yun, que corre una regresion GPR de terceros con I/O de
% 30 archivos por llamada. Obtener_Theta_Tibia_Candidato.m ahora expone
% tambien el angulo de muslo/cadera, que ya calculaba internamente, en 2
% outputs opcionales adicionales - ver su cabecera) ---
tempo = Temporizacion_Core(antro, candidato);
opts_cal = struct('calibrar_koopman', opciones.calibrar_koopman);
[theta_apoyo, theta_balanceo, tempo, muslo_full, ~] = Obtener_Theta_Tibia_Candidato(candidato, antro, tempo, n, opts_cal);
pct_ciclo_completo = linspace(0, 100, numel(theta_apoyo));
pct_corte = tempo.frac_apoyo * 100;
pct_ap  = linspace(0, pct_corte, n);
pct_bal = linspace(pct_corte, 100, n);
theta_ap_rad  = interp1(pct_ciclo_completo, theta_apoyo,    pct_ap,  'pchip');
theta_bal_rad = interp1(pct_ciclo_completo, theta_balanceo, pct_bal, 'pchip');
theta_muslo_ap_rad  = interp1(pct_ciclo_completo, muslo_full, pct_ap,  'pchip');
theta_muslo_bal_rad = interp1(pct_ciclo_completo, muslo_full, pct_bal, 'pchip');

tempo.tiempo_apoyo_s    = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
tempo.tiempo_balanceo_s = (1 - tempo.frac_apoyo) * tempo.tiempo_ciclo_s;

% --- Angulos (muslo, tibia) de la pierna TRACKEADA, ciclo completo
% (29-ago-2026: YA NO se pasa por Cadena_Completa_Core.m para la cadera -
% ver Cadera_Continua_Zhao_Core.m para el porque completo. Cadena_Completa_
% Core.m sigue intacta y sigue siendo la fuente de verdad para RODILLA/
% TOBILLO, que ya estan validados contra Kuopio con ella; esta funcion solo
% deja de USARLA para su propio calculo interno de GRF) ---
t_ap  = linspace(0, tempo.tiempo_apoyo_s,    n);
t_bal = linspace(0, tempo.tiempo_balanceo_s, n) + tempo.tiempo_apoyo_s;
t_nu  = [t_ap, t_bal(2:end)];

th_m_nu  = [theta_muslo_ap_rad,        theta_muslo_bal_rad(2:end)];
th_t_nu  = [theta_ap_rad,              theta_bal_rad(2:end)];

% --- Grid uniforme de tiempo (necesario para diferenciar sin ruido de
% paso no-uniforme) ---
T = tempo.tiempo_ciclo_s;
t_u = linspace(0, T, N);
th_m_u  = interp1(t_nu, th_m_nu,  t_u, 'pchip');
th_t_u  = interp1(t_nu, th_t_nu,  t_u, 'pchip');

% --- Pierna CONTRALATERAL: mismas series de angulo, desfasadas medio
% ciclo (aproximacion de marcha simetrica), extendidas 1 periodo antes y
% despues para poder interpolar el desfase sin efecto de borde ---
t_ext   = [t_u(1:end-1) - T, t_u, t_u(2:end) + T];
thm_ext = [th_m_u(1:end-1), th_m_u, th_m_u(2:end)];
tht_ext = [th_t_u(1:end-1), th_t_u, th_t_u(2:end)];
th_m_contra_u = interp1(t_ext, thm_ext, t_u + T/2, 'pchip');
th_t_contra_u = interp1(t_ext, tht_ext, t_u + T/2, 'pchip');

% --- Geometria: rodilla/tobillo de AMBAS piernas colgando de la MISMA
% cadera real ---
Lm_cm = antro.long_muslo_m * 100;
Lt_cm = antro.long_tibia_m * 100;

% --- CADERA CONTINUA (29-ago-2026, Cadera_Continua_Zhao_Core.m - Zhao et
% al. 2026 Ecs.3-4, Fig.1-3): una sola regla geometrica para todo el ciclo
% (rotacion sobre el tobillo FIJO de la pierna que este en el piso en cada
% instante, con la ventana de doble apoyo mezclada linealmente, mismo
% principio de reparto lineal que la Ec.9 de Zhao) en vez de "rotacion en
% apoyo + traslacion a velocidad constante en balanceo" (Cadena_Completa_
% Core.m) - esa costura producia un salto de VELOCIDAD en los dos empalmes
% del ciclo (60% y 0%/100%) que, al derivar dos veces para la GRF, se
% convertia en un pico numerico de cientos de %BW (diagnosticado con
% Diag_Pico_DobleApoyo.m, ver docs/algoritmo/JUSTIFICACION_MODELOS_Y_
% ESTADO_Q1.md). X_step_cm = media zancada (separacion horizontal entre
% apoyos alternados, marcha simetrica, misma zancada que ya usa TOBILLO
% para su cierre de ciclo en X). NO se aplica aqui el residuo empirico de
% "rockers" de TOBILLO (Residuo_Rockers_Tobillo_Kuopio_Core.m) - queda
% declarado como simplificacion de esta v1 (rotacion pura sobre tobillo
% fijo, sin el pequeno desplazamiento real de rodillo talon-antepie) para
% no reintroducir una discontinuidad nueva al pegarlo de forma asimetrica
% en cadera Y contralateral; es una mejora futura, no un dato que se
% esconda.
zancada_cm = tempo.velocidad_ms * T * 100;
X_step_cm = zancada_cm / 2;
[cad_x_u, cad_y_u] = Cadera_Continua_Zhao_Core(t_u, T, tempo.tiempo_apoyo_s, ...
    th_m_u, th_t_u, th_m_contra_u, th_t_contra_u, Lm_cm, Lt_cm, X_step_cm);

rod_x_stance = cad_x_u + Lm_cm*sin(th_m_u);      rod_y_stance = cad_y_u - Lm_cm*cos(th_m_u);
tob_x_stance = rod_x_stance + Lt_cm*sin(th_t_u); tob_y_stance = rod_y_stance - Lt_cm*cos(th_t_u);

rod_x_contra = cad_x_u + Lm_cm*sin(th_m_contra_u);      rod_y_contra = cad_y_u - Lm_cm*cos(th_m_contra_u);
tob_x_contra = rod_x_contra + Lt_cm*sin(th_t_contra_u); tob_y_contra = rod_y_contra - Lt_cm*cos(th_t_contra_u);

% --- CoM de muslo/pierna (fraccion desde extremo proximal, Table 4) ---
fc_m = masaSeg.muslo_com_frac;   % desde cadera hacia rodilla
fc_p = masaSeg.pierna_com_frac;  % desde rodilla hacia tobillo

com_muslo_stance_x = cad_x_u + fc_m*(rod_x_stance-cad_x_u);  com_muslo_stance_y = cad_y_u + fc_m*(rod_y_stance-cad_y_u);
com_pierna_stance_x = rod_x_stance + fc_p*(tob_x_stance-rod_x_stance); com_pierna_stance_y = rod_y_stance + fc_p*(tob_y_stance-rod_y_stance);

com_muslo_contra_x = cad_x_u + fc_m*(rod_x_contra-cad_x_u);  com_muslo_contra_y = cad_y_u + fc_m*(rod_y_contra-cad_y_u);
com_pierna_contra_x = rod_x_contra + fc_p*(tob_x_contra-rod_x_contra); com_pierna_contra_y = rod_y_contra + fc_p*(tob_y_contra-rod_y_contra);

% --- CoM de cuerpo completo (cm -> m), ponderado por masa ---
mH = masaSeg.hat_masa_frac; mMu = masaSeg.muslo_masa_frac; mPi = masaSeg.pierna_masa_frac; mPie = masaSeg.pie_masa_frac;
suma_frac = mH + 2*mMu + 2*mPi + 2*mPie;  % ~1.0, ver verificacion_suma_pct

com_x_cm = (mH*cad_x_u + mMu*(com_muslo_stance_x+com_muslo_contra_x) + mPi*(com_pierna_stance_x+com_pierna_contra_x) + mPie*(tob_x_stance+tob_x_contra)) / suma_frac;
com_y_cm = (mH*cad_y_u + mMu*(com_muslo_stance_y+com_muslo_contra_y) + mPi*(com_pierna_stance_y+com_pierna_contra_y) + mPie*(tob_y_stance+tob_y_contra)) / suma_frac;

com_x_m = com_x_cm/100; com_y_m = com_y_cm/100;

% --- Derivadas 2das sobre grid uniforme, extendido 1 periodo cada lado
% para evitar artefactos de borde (senal periodica). X tiene deriva neta
% de avance por ciclo -> se extiende sumando/restando esa deriva; Y es
% periodico -> se extiende directo. ---
dt = t_u(2)-t_u(1);
deriva_x = com_x_m(end) - com_x_m(1);   % avance neto por ciclo (X no es periodico)
x_ext = [com_x_m(1:end-1) - deriva_x, com_x_m, com_x_m(2:end) + deriva_x];  % Y SI es periodico -> extension directa
y_ext = [com_y_m(1:end-1),            com_y_m, com_y_m(2:end)];

% Suavizado ANTES de derivar (Savitzky-Golay, orden 3, ventana ~10% del
% ciclo). CORREGIDO 29-ago-2026 (el comentario original describia el
% defecto de Cadena_Completa_Core.m -velocidad discontinua en el empalme
% apoyo->balanceo- que YA NO aplica aqui: cad_x_u/cad_y_u vienen de
% Cadera_Continua_Zhao_Core.m desde esta misma sesion, que da continuidad
% de VALOR en las 2 costuras del ciclo por construccion). El suavizado
% sigue siendo necesario por una razon mas chica pero real: la mezcla
% lineal de doble apoyo (Cadera_Continua_Zhao_Core.m V1) todavia deja un
% pequeno quiebre de PENDIENTE en los 4 bordes internos de esa mezcla (ver
% cabecera de esa funcion) - sin suavizar, ese quiebre produce un pico
% numerico al derivar dos veces (una discontinuidad real de fuerza
% instantanea no es fisicamente posible en un sistema con masa finita).
framelen = 2*floor(N/10) + 1;  % ~10% del ciclo, impar
x_ext = sgolayfilt(x_ext, 3, framelen);
y_ext = sgolayfilt(y_ext, 3, framelen);

ax_ext = gradient(gradient(x_ext, dt), dt);
ay_ext = gradient(gradient(y_ext, dt), dt);
ax_u = ax_ext(N:2*N-1);
ay_u = ay_ext(N:2*N-1);

% --- GRF ---
GRF_v = M_total * (G_MS2 + ay_u);
GRF_h = M_total * ax_u;
BW_N  = M_total * G_MS2;

% --- Mascara de apoyo simple verdadero: la contralateral esta en SU
% PROPIO balanceo, es decir su fase local (t+T/2 mod T) cae en la ventana
% de balanceo, Y la trackeada esta en apoyo ---
fase_trackeada = mod(t_u, T);
en_apoyo_trackeada = fase_trackeada <= tempo.tiempo_apoyo_s;
fase_contra = mod(t_u + T/2, T);
contra_en_balanceo = fase_contra > tempo.tiempo_apoyo_s;
apoyo_simple_mask = en_apoyo_trackeada & contra_en_balanceo;

% --- REPARTO DE DOBLE APOYO (28-ago-2026, Zhao et al. 2026, PLOS ONE,
% DOI 10.1371/journal.pone.0338041, Sec.2.5 "Novel double-support phase
% modeling", Ecs. 9-10 - SOLO se implementa la componente VERTICAL (Ec.9),
% no la horizontal (Ec.10, pedido del usuario: "yo solo medire Fz")).
%
% POR QUE: hasta aqui, GRF_v/GRF_h son la fuerza TOTAL bajo AMBOS pies
% (alcance v1 declarado arriba) - fuera de apoyo_simple_mask (doble apoyo,
% ~20% del ciclo en los dos extremos del apoyo) no se puede comparar
% contra una plataforma de UN pie. Esta seccion reparte esa fuerza total
% entre la pierna TRACKEADA y la CONTRALATERAL usando el modelo de Zhao:
% durante el doble apoyo la carga se transfiere LINEALMENTE de la pierna
% trasera (trailing) a la delantera (leading), de 100% a 0% del peso que
% soportaba. Extiende la ventana comparable contra datos reales de un
% pie a (casi) todo el ciclo de apoyo, no solo al tramo de apoyo simple.
%
% ADAPTACION DECLARADA respecto al paper (no inventada, si justificada):
% Zhao usa (mt+ms) [solo muslo+pierna] como masa de "la pierna" y una
% aceleracion ÿs unica sin definir exactamente que punto la genera. Este
% proyecto ya tiene el pie como segmento propio (mPie, aproximado en el
% tobillo, ver cabecera arriba) - se extiende la masa de "la pierna" a
% (mMu+mPi+mPie) y su aceleracion se toma del CoM combinado de esos 3
% segmentos (mismo criterio de ponderacion por masa que ya usa este
% archivo para el CoM de cuerpo completo) - mas fiel a la propia
% decomposicion de este proyecto que forzar el punto no especificado de
% Zhao. La aceleracion de "m" (HAT) usa la MISMA aproximacion cadera=HAT
% ya declarada y usada en el resto de este archivo.
%
% T_DT (duracion del doble apoyo) NO se importa del paper (Zhao reporta
% 12%/38% de un medio-ciclo con simetria total, numero no verificado como
% aplicable a este generador) - se DERIVA de los mismos supuestos de fase
% que ya usa apoyo_simple_mask (frac_apoyo=0.6 de Koopman, calibrado
% contra Kuopio): T_DT = tiempo_apoyo_s - T/2 -> para frac_apoyo=0.6, T_DT
% = 0.1*T (10% del ciclo), consistente con el rango tipico de literatura
% (~10-12%) sin necesitar el numero especifico de Zhao.
m_leg_total_kg = (mMu+mPi+mPie) * M_total;
m_hat_kg = mH * M_total;

leg_trackeada_y_m = (mMu*com_muslo_stance_y + mPi*com_pierna_stance_y + mPie*tob_y_stance) / (mMu+mPi+mPie) / 100;
leg_contra_y_m    = (mMu*com_muslo_contra_y + mPi*com_pierna_contra_y + mPie*tob_y_contra) / (mMu+mPi+mPie) / 100;
cad_y_m           = cad_y_u / 100;

% mismo procedimiento EXACTO (extender 1 periodo, suavizar, derivar 2
% veces, recortar) que ya se aplico arriba a y_ext/com_y_m - Y es
% periodica en las 3 series (cadera, pierna trackeada, pierna
% contralateral), igual que el CoM combinado.
ay_c_u        = extender_suavizar_derivar(cad_y_m, dt, framelen, N);
ay_trackeada_u = extender_suavizar_derivar(leg_trackeada_y_m, dt, framelen, N);
ay_contra_u    = extender_suavizar_derivar(leg_contra_y_m, dt, framelen, N);

T_DT = tempo.tiempo_apoyo_s - T/2;
GRF_v_trackeada = nan(1,N);
doble_apoyo_mask = en_apoyo_trackeada & ~contra_en_balanceo;   % ambas piernas en el piso
temprano = doble_apoyo_mask & (fase_trackeada < T/4);          % trackeada = leading (s2), recien aterrizo
tardio   = doble_apoyo_mask & (fase_trackeada >= T/4);         % trackeada = trailing (s1), por despegar

tau_temprano = fase_trackeada(temprano);                       % t - t_heelstrike_s2, ya que t_heelstrike_s2=0 en fase trackeada aqui
GRF_v_trackeada(temprano) = G_MS2*(2*m_leg_total_kg+m_hat_kg).*(tau_temprano/T_DT) ...
    + m_hat_kg*ay_c_u(temprano)/2 + m_leg_total_kg*ay_trackeada_u(temprano);

tau_tardio = fase_trackeada(tardio) - T/2;                     % t - t_heelstrike_s2 (contralateral aterrizo en fase_trackeada=T/2)
GRF_v_trackeada(tardio) = G_MS2*(2*m_leg_total_kg+m_hat_kg) - G_MS2*(2*m_leg_total_kg+m_hat_kg).*(tau_tardio/T_DT) ...
    + m_hat_kg*ay_c_u(tardio)/2 + m_leg_total_kg*ay_trackeada_u(tardio);

GRF_v_trackeada(apoyo_simple_mask) = GRF_v(apoyo_simple_mask);  % en apoyo simple, la formula de "ambos pies" YA es la de un pie
GRF_v_trackeada_pctBW = 100*GRF_v_trackeada/BW_N;

% --- Mascara ERODIDA (28-ago-2026, hallazgo de Test 8 de Test_GRF_Newton_
% ApoyoSimple.m): el suavizado Savitzky-Golay usa una ventana de ancho
% `framelen` CENTRADA en cada punto - cerca de los bordes de apoyo_simple_
% mask, esa ventana mezcla puntos de DENTRO (apoyo simple limpio) con
% puntos de FUERA (transicion de doble apoyo, con el pico numerico ya
% declarado arriba) - contamina una franja de ~framelen/2 muestras hacia
% adentro del borde. apoyo_simple_mask sigue siendo la definicion FISICA
% correcta (que pierna toca el piso); esta version erosionada es la que
% hay que usar para comparar NUMEROS contra datos reales, hasta que se
% resuelva la causa raiz de fondo (el quiebre de PENDIENTE en los bordes
% de la mezcla lineal de doble apoyo, ver Cadera_Continua_Zhao_Core.m y
% comentario de sgolayfilt mas arriba) con algo mejor que un suavizado
% post-hoc. ---
margen = floor(framelen/2);
mask_ext = [apoyo_simple_mask(1:end-1), apoyo_simple_mask, apoyo_simple_mask(2:end)];
mask_erosionada_ext = movmin(double(mask_ext), 2*margen+1);
apoyo_simple_mask_erosion_muestras = logical(mask_erosionada_ext(N:2*N-1));

% --- CRITERIO FISICO, no solo erosion por muestras (28-ago-2026, hallazgo
% del usuario: "Fz solo puede ser positiva, esta caminando sobre la
% plataforma" - correcto, una plataforma de apoyo unilateral NUNCA puede
% jalar hacia abajo, Fz<0 es fisicamente imposible por definicion). La
% erosion de arriba (fraccion FIJA de muestras, ~10% del ciclo) resulto
% INSUFICIENTE para sujetos de ciclo mas corto (tipicamente menor talla/
% masa, marcha mas rapida): verificado con 3 casos reales que la misma
% erosion en % de muestras deja un residuo de GRF horizontal MAYOR cuanto
% mas corto es el ciclo (T=0.92s->residuo -46.8%BW, T=1.01s->-23.8%BW,
% T=1.07s->+1.1%BW, practicamente limpio) - el artefacto numerico de la
% transicion (2da derivada de un quiebre de velocidad, ver comentario de
% sgolayfilt arriba) escala en magnitud con 1/dt^2, no con % de ciclo.
%
% Se agrega un segundo filtro ANCLADO A LA FISICA, no a una fraccion
% arbitraria: cualquier muestra con Fz<0 es POR DEFINICION invalida (no
% hace falta ajustar ningun umbral para esto, es una violacion de una
% restriccion fisica dura). Ademas, GRF horizontal >40%BW se trata igual
% de invalida por ser fisiologicamente implausible incluso en el caso mas
% extremo de la literatura ya revisada en este proyecto (docs/literatura/
% literatura_GRF_protesica.md: tipico +-15-20%BW, sin ningun reporte por
% encima de eso ni siquiera en marcha rapida de amputados) - un valor mas
% alla de eso es evidencia de artefacto numerico, no de fisiologia real.
% Se DILATA la exclusion por el mismo `margen` ya usado arriba (mismo
% ancho que la ventana de suavizado) porque el artefacto no queda
% perfectamente contenido en el punto exacto donde Fz cruza cero - el
% componente horizontal (distinta combinacion de derivadas) puede seguir
% contaminado unos puntos mas alla, mismo origen, no cero por casualidad.
UMBRAL_GRF_H_IMPLAUSIBLE_PCTBW = 40;
mask_fisica = (GRF_v >= 0) & (abs(100*GRF_h/BW_N) <= UMBRAL_GRF_H_IMPLAUSIBLE_PCTBW);
% Margen de DILATACION reducido (28-ago-2026, 2da correccion el mismo dia:
% con el margen completo -igual al de la erosion por muestras ya
% eliminada arriba- se seguia tirando pct~40-49% sin necesidad, mismo
% problema con otro nombre. Se verifico que la transicion real (Fh cruza
% de -13%BW a -56%BW) ocurre en <=1 muestra, no es una cola larga - un
% margen chico (5 muestras ~2.5% de ciclo) alcanza para cubrir cualquier
% resabio real del suavizado sin sacrificar tramos limpios. Reverificado
% con Test 8 (banda [20,250]) y los 6 casos antropometricos de la
% conversacion (ninguno con Fz<0 ni GRF horizontal fuera de banda).
margen_fisica = min(margen, 5);
excl_ext = [~mask_fisica(1:end-1), ~mask_fisica, ~mask_fisica(2:end)];
excl_dilatada_ext = movmax(double(excl_ext), 2*margen_fisica+1);
mask_fisica_dilatada = ~logical(excl_dilatada_ext(N:2*N-1));

% NO se combina con apoyo_simple_mask_erosion_muestras (28-ago-2026,
% hallazgo real comparando contra la curva real de 86kg del proyecto,
% PERSONA SANA/FUERZA GRF: la erosion fija de ~10% de muestras excluia
% ~pct 40-49% del ciclo aunque ahi Fz es perfectamente suave (73-78%BW,
% sin violacion fisica ninguna) solo por estar cerca del borde de fase -
% esa zona limpia se estaba tirando sin necesidad, justo donde la curva
% real empieza a subir hacia el segundo pico. El filtro fisico
% (mask_fisica, dilatado por el mismo margen que antes) ya captura los
% picos numericos reales (verificado: excluye correctamente pct~48-60,
% donde Fz SI se dispara a 160%BW y GRF horizontal a 47%BW) sin necesidad
% del criterio ciego de "N muestras desde el borde".
apoyo_simple_mask_estricta = apoyo_simple_mask & mask_fisica_dilatada;

out = struct();
out.t_s = t_u;
out.pct_ciclo = 100*t_u/T;
out.GRF_vertical_N = GRF_v;
out.GRF_horizontal_N = GRF_h;
out.GRF_vertical_pctBW = 100*GRF_v/BW_N;
out.GRF_horizontal_pctBW = 100*GRF_h/BW_N;
out.apoyo_simple_mask = apoyo_simple_mask;
out.apoyo_simple_mask_estricta = apoyo_simple_mask_estricta;
out.verificacion_media_vGRF_pctBW = mean(GRF_v)/BW_N*100;
out.masaSeg = masaSeg;
out.antro = antro;
out.tempo = tempo;
out.candidato = candidato;
out.calibrar_koopman = opciones.calibrar_koopman;

% --- Posicion de la pierna TRACKEADA (28-ago-2026, aditivo, para que quien
% consuma esta funcion pueda graficar la trayectoria junto a la GRF sin
% recalcularla por su cuenta - Cadena_Completa_Core.m ya la calculo arriba
% para el CoM, solo se expone lo que ya existia en memoria) ---
out.cadera_x_cm = cad_x_u;   out.cadera_y_cm = cad_y_u;
out.rodilla_x_cm = rod_x_stance; out.rodilla_y_cm = rod_y_stance;
out.tobillo_x_cm = tob_x_stance; out.tobillo_y_cm = tob_y_stance;

% --- GRF vertical de la pierna TRACKEADA SOLA, ciclo completo (28-ago-
% 2026, Zhao et al. 2026 Ec.9 en doble apoyo + esta misma formula ya
% coincide con GRF_v en apoyo simple) - esto es lo que se compara contra
% UNA plataforma de un pie en (casi) todo el apoyo, no solo en el tramo
% de apoyo simple. Ver comentario grande mas arriba para la derivacion y
% las adaptaciones declaradas respecto al paper original.
out.GRF_vertical_trackeada_N = GRF_v_trackeada;
out.GRF_vertical_trackeada_pctBW = GRF_v_trackeada_pctBW;
out.doble_apoyo_mask = doble_apoyo_mask;
% Mascara de confianza para la pierna trackeada = apoyo simple (ya
% confiable) MAS doble apoyo con el mismo criterio fisico (Fz de ESE pie
% no puede ser negativa) - NO se reusa mask_fisica_dilatada de arriba
% porque esa es sobre la fuerza de AMBOS pies, no sobre la trackeada sola.
mask_fisica_trackeada = GRF_v_trackeada >= 0;
excl_ext_t = [~mask_fisica_trackeada(1:end-1), ~mask_fisica_trackeada, ~mask_fisica_trackeada(2:end)];
excl_dil_t = movmax(double(excl_ext_t), 2*margen_fisica+1);
mask_fisica_trackeada_dilatada = ~logical(excl_dil_t(N:2*N-1));
out.mask_confiable_trackeada = mask_fisica_trackeada_dilatada;

end

% --------------------------------------------------------------------
function a_u = extender_suavizar_derivar(y_u, dt, framelen, N)
% Extiende 1 periodo a cada lado (senal periodica, Y de posicion vertical
% - mismo supuesto que ya usa este archivo para com_y_m), suaviza
% (Savitzky-Golay, mismo framelen que el resto del archivo, por la misma
% razon: el quiebre de velocidad en el empalme apoyo->balanceo) y deriva
% dos veces, devolviendo solo el tramo central (1 periodo).
y_ext = [y_u(1:end-1), y_u, y_u(2:end)];
y_ext = sgolayfilt(y_ext, 3, framelen);
a_ext = gradient(gradient(y_ext, dt), dt);
a_u = a_ext(N:2*N-1);
end

% --------------------------------------------------------------------
function v = getfield_safe(s, campo)
if isfield(s, campo), v = s.(campo); else, v = []; end
end
