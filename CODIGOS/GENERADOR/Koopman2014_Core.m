function out = Koopman2014_Core(v_kph, l_m, opciones)
% KOOPMAN2014_CORE  Genera trayectorias articulares (cadera ab/aduccion,
%                   cadera flex/ext, rodilla flex/ext, tobillo plantar/
%                   dorsiflexion) con el metodo de Koopman, van Asseldonk
%                   & van der Kooij 2014 (Journal of Biomechanics
%                   47:1447-1458, DOI 10.1016/j.jbiomech.2014.01.037):
%                   splines quinticos por tramos entre 6 "eventos clave"
%                   por articulacion, cuyos 4 parametros (timing, angulo,
%                   velocidad, aceleracion angular) se predicen con
%                   regresion lineal YA PUBLICADA (Tablas 1-5) sobre
%                   velocidad de marcha y talla corporal - sin ajustar
%                   ningun coeficiente (regla P-23, docs/DISCUSION_Q2.md).
%
%   out = Koopman2014_Core(v_kph, l_m)
%   out = Koopman2014_Core(v_kph, l_m, opciones)
%
% ENTRADA
%   v_kph   velocidad de marcha (km/h). Rango validado por el paper: 0.5-5 kph.
%   l_m     talla corporal (m) - OJO: es TALLA, no longitud de pierna
%           (Zhao2026_Core.m usa "l" para longitud de pierna - variables
%           distintas con el mismo simbolo, ver GUIA_INTERPRETACION.md #2).
%   opciones (struct opcional):
%     .nMuestras   puntos por ciclo, 0-100% (default 101)
%
% SALIDA: struct `out` con 4 campos (uno por articulacion), cada uno con
%   .pct_ciclo (1 x nMuestras) y .angulo_deg (1 x nMuestras):
%   .cadera_abaduccion, .cadera_flexext, .rodilla_flexext, .tobillo_flexext
%   Signo: "(dorsi-) flexion and abduction are defined positive" (Fig. 1
%   del paper, convencion clinica clasica) - NO verificado si esto
%   coincide con la convencion de Zhao 2026 para cadera/rodilla; no
%   combinar sin revisar signos (ver GUIA_INTERPRETACION.md).
%
%   .theta_tibia_via_tobillo_rad/deg   reduccion (Reduccion_Winter_Core.m),
%   supuesto pie plano en apoyo (theta_pie=0), MISMO patron que
%   Yun2014_Wrapper.m. Signo aplicado: -1 (no +1 como en Yun), porque
%   Koopman define su canal de tobillo con "dorsiflexion positiva"
%   (Fig.1 del paper) mientras que el canal de Yun es "Ankle P.flex."
%   (positivo = PLANTARflexion, la convencion opuesta) - se invierte el
%   signo de Koopman para que las dos reducciones queden en el mismo
%   sentido fisico. Basado en la semantica declarada de cada paper, NO
%   verificado independientemente contra la definicion cruda de eje de
%   cada dataset - revisar antes de promediar/comparar numericamente los
%   dos candidatos en el articulo final.
%
% Fuente: docs/literatura/pdfs/koomap.pdf, Tablas 1-5 (verificadas con
% pdfplumber para recuperar signos negativos que el extractor de texto
% estandar perdia - ver docs/algoritmo/diseno_matematico_generador.md #2
% y CODIGOS/GENERADOR/GUIA_INTERPRETACION.md #2 para el detalle completo
% de esa verificacion, incluida la unica celda ambigua de la fuente
% (Tabla 4, Min.stance, coeficiente de talla del parametro Index).
% ==========================================================================

if nargin < 3, opciones = struct(); end
if ~isfield(opciones,'nMuestras'), opciones.nMuestras = 101; end

if ~(isnumeric(v_kph) && isscalar(v_kph) && v_kph > 0)
    error('v_kph debe ser un escalar positivo (velocidad en km/h). Se recibio: %s', mat2str(v_kph));
end
if ~(isnumeric(l_m) && isscalar(l_m) && l_m > 0)
    error('l_m debe ser un escalar positivo (talla corporal en metros). Se recibio: %s', mat2str(l_m));
end
% La advertencia de rango (0.5-5 kph) se dispara dentro de
% Tiempo_Ciclo_Koopman2014_Core.m (23-ago-2026, E4 de
% plan_100_generador.md) - no se duplica aqui para no generar dos
% advertencias con distinto id por la misma condicion.

tablas = tablas_koopman();
pct_ciclo = linspace(0, 100, opciones.nMuestras);

out = struct();
campos_salida = {'cadera_abaduccion','cadera_flexext','rodilla_flexext','tobillo_flexext'};
for k = 1:numel(tablas)
    T = tablas(k);
    angulo = reconstruir_curva(T, v_kph, l_m, pct_ciclo);
    out.(campos_salida{k}) = struct('pct_ciclo', pct_ciclo, 'angulo_deg', angulo);
end

% --- Tabla 5: tiempo real de ciclo (Ec. 3 del paper) ---
% Extraido a Tiempo_Ciclo_Koopman2014_Core.m (23-ago-2026, E4) para
% reusarlo como motor de temporizacion compartido - misma formula, sin
% duplicar el coeficiente.
[out.tiempo_ciclo_s, out.step_ratio] = Tiempo_Ciclo_Koopman2014_Core(v_kph, l_m);

% --- Reduccion via tobillo (Reduccion_Winter_Core.m), pie plano en apoyo ---
theta_pie_cero = zeros(size(pct_ciclo));
phi_tobillo_rad = deg2rad(out.tobillo_flexext.angulo_deg);
red = Reduccion_Winter_Core(struct( ...
    'theta_pie_rad', theta_pie_cero, ...
    'phi_tobillo_rad', phi_tobillo_rad, ...
    'signo_tobillo', -1));  % ver nota de signo en el encabezado de esta funcion
out.theta_tibia_via_tobillo_rad = red.theta_tibia_via_tobillo_rad;
out.theta_tibia_via_tobillo_deg = rad2deg(red.theta_tibia_via_tobillo_rad);

% --- Reduccion via rodilla (NUEVO 23-ago-2026, E2 de plan_100_generador.md) ---
% cadera_flexext YA declarado "flexion positive" por el propio paper
% (Fig.1: "(dorsi-)flexion and abduction are defined positive") y
% confirmado empiricamente (forma de curva contra hitos de marcha normal
% de Perry & Burnfield/Winter, ver GUIA_INTERPRETACION.md #3) - MISMO
% signo que Zhao 2026 (theta_tibia = theta_muslo - phi_rodilla, Sec.2.6,
% con theta_muslo ~= phi_cadera bajo pelvis-vertical=0). Sin inversion
% de signo necesaria para este camino (a diferencia del tobillo, arriba).
theta_muslo_rad = deg2rad(out.cadera_flexext.angulo_deg);
phi_rodilla_rad = deg2rad(out.rodilla_flexext.angulo_deg);
red_rod = Reduccion_Winter_Core(struct( ...
    'theta_muslo_rad', theta_muslo_rad, ...
    'phi_rodilla_rad', phi_rodilla_rad));
out.theta_tibia_via_rodilla_rad = red_rod.theta_tibia_via_rodilla_rad;
out.theta_tibia_via_rodilla_deg = rad2deg(red_rod.theta_tibia_via_rodilla_rad);

% --- Chequeo cruzado rodilla vs tobillo ---
red_ambos = Reduccion_Winter_Core(struct( ...
    'theta_muslo_rad', theta_muslo_rad, 'phi_rodilla_rad', phi_rodilla_rad, ...
    'theta_pie_rad', theta_pie_cero, 'phi_tobillo_rad', phi_tobillo_rad, ...
    'signo_tobillo', -1));
out.chequeo_cruzado_max_abs_deg = red_ambos.diferencia_max_abs_deg;

end

% ==========================================================================
function angulo = reconstruir_curva(T, v, l, pct_ciclo)
% Calcula los 4 parametros (x,y,y',y'') de cada uno de los 6 eventos
% clave con las regresiones ya publicadas, arma el 7mo punto (= copia del
% 1ro, en x=100, Fig.4 del paper), y ajusta splines quinticos de Hermite
% por tramos (valor + 1a + 2a derivada en ambos extremos de cada tramo).

nEventos = numel(T.eventos);
x  = zeros(1,nEventos); y  = zeros(1,nEventos);
dy = zeros(1,nEventos); d2y = zeros(1,nEventos);

for i = 1:nEventos
    ev = T.eventos(i);
    if ev.x_fijo_uno
        x(i) = 1;
    else
        x(i) = evaluar_regresion(T.coef_x(i,:), v, l);
    end
    y(i) = evaluar_regresion(T.coef_y(i,:), v, l);
    if ev.velocidad_cero
        dy(i) = 0;
    else
        dy(i) = evaluar_regresion(T.coef_v(i,:), v, l);
    end
    if ev.aceleracion_cero
        d2y(i) = 0;
    else
        d2y(i) = evaluar_regresion(T.coef_a(i,:), v, l);
    end
end

[x, orden] = sort(x);
y = y(orden); dy = dy(orden); d2y = d2y(orden);

% 7mo punto: copia del 1ro, en x=100 (Fig.4 del paper: "the y, dy/dx, and
% d2y/dx2 parameter of the 7th key-event (at 100% of the gait cycle) is
% equal to the first 1st key-event (at 0% of the gait cycle)")
x  = [x, 100];
y  = [y, y(1)];
dy = [dy, dy(1)];
d2y = [d2y, d2y(1)];

angulo = nan(size(pct_ciclo));
for seg = 1:(numel(x)-1)
    if seg == 1
        idx = pct_ciclo <= x(seg+1);
    elseif seg == numel(x)-1
        idx = pct_ciclo > x(seg) & pct_ciclo <= 100.0001;
    else
        idx = pct_ciclo > x(seg) & pct_ciclo <= x(seg+1);
    end
    if ~any(idx), continue; end
    c = hermite_quintico(x(seg), y(seg), dy(seg), d2y(seg), x(seg+1), y(seg+1), dy(seg+1), d2y(seg+1));
    t = pct_ciclo(idx) - x(seg);
    angulo(idx) = polyval(fliplr(c), t);
end

% puntos antes del primer evento (pct_ciclo < x(1), tipicamente <1%):
% extrapolacion natural del primer tramo, mismo polinomio ya ajustado
if any(pct_ciclo < x(1))
    idx0 = pct_ciclo < x(1);
    c = hermite_quintico(x(1), y(1), dy(1), d2y(1), x(2), y(2), dy(2), d2y(2));
    t = pct_ciclo(idx0) - x(1);
    angulo(idx0) = polyval(fliplr(c), t);
end

end

% ==========================================================================
function val = evaluar_regresion(coef, v, l)
% coef = [b0 b1(v) b2(v^2) b3(l)]
val = coef(1) + coef(2)*v + coef(3)*v^2 + coef(4)*l;
end

% ==========================================================================
function c = hermite_quintico(x0,y0,dy0,d2y0,x1,y1,dy1,d2y1)
% Resuelve el polinomio de grado 5 p(t) = c1 + c2*t + ... + c6*t^5, con
% t = x - x0, que cumple p(0)=y0, p'(0)=dy0, p''(0)=d2y0, p(h)=y1,
% p'(h)=dy1, p''(h)=d2y1, con h = x1-x0. Sistema lineal 6x6 directo
% (sin funciones base especiales) - robusto para h no unitario.
h = x1 - x0;
if h <= 0
    error('hermite_quintico: x1 debe ser mayor que x0 (x0=%.3f, x1=%.3f).', x0, x1);
end
A = [1 0    0     0      0       0;
     0 1    0     0      0       0;
     0 0    2     0      0       0;
     1 h    h^2   h^3    h^4     h^5;
     0 1    2*h   3*h^2  4*h^3   5*h^4;
     0 0    2     6*h    12*h^2  20*h^3];
b = [y0; dy0; d2y0; y1; dy1; d2y1];
c = (A\b)';
end

% ==========================================================================
function tablas = tablas_koopman()
% Coeficientes YA PUBLICADOS (Koopman et al. 2014, Tablas 1-5, verificados
% con pdfplumber - ver docs/algoritmo/diseno_matematico_generador.md #2).
% Cada tabla: 6 eventos, cada fila de coef_* = [b0 b1(v) b2(v^2) b3(l)].
% ev.x_fijo_uno = true solo para "Heel contact" (x=1 por definicion).
% ev.velocidad_cero = true para eventos que son extremos de POSICION
%   (su nombre NO contiene "dy/dx") - la velocidad ahi es 0 por definicion.
% ev.aceleracion_cero = true para eventos que son extremos de VELOCIDAD
%   (su nombre SI contiene "dy/dx") - la aceleracion ahi es 0 por definicion.

% ---- Tabla 1: Cadera ab-/aduccion ----
T1.nombre = 'cadera_abaduccion';
T1.eventos = struct('nombre', ...
    {'HeelContact','MinStance','MinDyDxStance','MaxDyDxSwing','MaxSwing','MinDyDxSwing'}, ...
    'x_fijo_uno',     {true,  false, false, false, false, false}, ...
    'velocidad_cero', {false, true,  false, false, true,  false}, ...
    'aceleracion_cero',{false,false, true,  true,  false, true});
T1.coef_x = [ 0        0      0      0;
             33.360    0      0     -7.319;
             30.158   -2.038  0     11.832;
             52.727   -1.613  0      9.393;
             83.318   -6.031  0.762  0;
             68.490   -1.847  0     10.898];
T1.coef_y = [-0.783    0      0.056  0;
             -1.641   -0.879  0      0;
              0.121   -0.652  0      0;
              3.090    0      0      0;
              4.441    0.557  0      0;
              1.860    0.657  0      0];
T1.coef_v = [-0.689    0     -0.010  0.424;
              0        0      0      0;
             -0.015    0      0      0;
              0.350    0.075  0      0;
              0        0      0      0;
             -0.399    0      0      0];
T1.coef_a = [ 0.019    0      0      0;
              0.043    0      0.002  0;
              0        0      0      0;
              0        0      0      0;
             -0.082    0      0      0;
              0        0      0      0];

% ---- Tabla 2: Cadera flexion/extension ----
T2.nombre = 'cadera_flexext';
T2.eventos = struct('nombre', ...
    {'HeelContact','MaxStance','x50Stance','Min','MaxDyDxSwing','MaxSwing'}, ...
    'x_fijo_uno',     {true,  false, false, false, false, false}, ...
    'velocidad_cero', {false, true,  false, true,  false, true}, ...
    'aceleracion_cero',{false,false, false, false, true,  false});
T2.coef_x = [ 0        0      0      0;
            -10.809    0      0     11.762;
             24.512   -2.021  0.195  5.109;
             48.879   -3.854  0.355  9.891;
             80.562   -6.432  0.885  0;
             94.280   -0.601  0      0];
T2.coef_y = [20.354    1.934  0      0;
             18.917    2.583  0      0;
              4.845    1.718  0      0;
             -2.026   -2.090  0      0;
             20.030    0      0     -7.732;
             21.447    2.318  0      0];
T2.coef_v = [-2.062    0      0      1.112;
              0        0      0      0;
             -0.240   -0.224  0      0;
              0        0      0      0;
              0.472    0.096  0      0.633;
              0        0      0      0];
T2.coef_a = [-0.068    0.031  0      0;
             -0.112    0      0      0;
              0.026   -0.010  0      0;
             -0.117    0.059 -0.007  0.098;
              0        0      0      0;
             -0.083    0     -0.002  0];

% ---- Tabla 3: Rodilla flexion/extension ----
T3.nombre = 'rodilla_flexext';
T3.eventos = struct('nombre', ...
    {'HeelContact','MaxStance','MinStance','MaxDyDxSwing','MaxSwing','MinDyDxSwing'}, ...
    'x_fijo_uno',     {true,  false, false, false, false, false}, ...
    'velocidad_cero', {false, true,  true,  false, true,  false}, ...
    'aceleracion_cero',{false,false, false, true,  false, true});
T3.coef_x = [ 0        0      0      0;
             17.103    0      0      0;
             48.542   -0.998  0      0;
             68.947   -6.096  0.611  5.967;
             85.816   -4.480  0.519  0;
             92.489    0      0      0];
T3.coef_y = [31.595   -4.311  0.494 -13.050;
              5.995    3.028  0      0;
            -10.037    0      0      7.594;
             29.618    3.803 -0.486  0;
             38.110    9.744 -1.105  0;
             24.631   -0.967  0      0];
T3.coef_v = [-3.581    0      0      1.977;
              0        0      0      0;
              0        0      0      0;
              3.276    0      0      0;
              0        0      0      0;
             -0.446   -0.032  0     -1.696]; % beta2(v^2) ambiguo en la
             % fuente (celda vacia en dos extracciones independientes,
             % ver GUIA_INTERPRETACION.md #2) - tratado como 0/sin
             % contribucion, no verificado a texto completo con mas detalle
T3.coef_a = [ 0.301    0.073  0      0;
             -0.094    0     -0.005  0;
              0.042    0      0.004  0;
              0        0      0      0;
             -0.784    0.225 -0.026  0;
              0        0      0      0];

% ---- Tabla 4: Tobillo plantar-/dorsiflexion ----
T4.nombre = 'tobillo_flexext';
T4.eventos = struct('nombre', ...
    {'HeelContact','MinStance','MinDyDxStance','Max','MinSwing','MaxSwing'}, ...
    'x_fijo_uno',     {true,  false, false, false, false, false}, ...
    'velocidad_cero', {false, true,  false, true,  true,  true}, ...
    'aceleracion_cero',{false,false, true,  false, false, false});
% Fila 2 (MinStance): beta3(l) ambiguo/vacio en la fuente - celda en
% blanco en dos extracciones independientes del PDF (texto estandar y
% pdfplumber), ver GUIA_INTERPRETACION.md #2 - tratado como 0/sin
% contribucion, no verificado con mas detalle.
T4.coef_x = [ 0        0      0      0;
              8.145    0.331  0      0;
             12.005    0      0     13.754;
             67.686   -5.469  0.493  0;
             73.460   -6.699  0.744  6.463;
             87.621    0      0.132  0];
T4.coef_y = [18.645    0.554  0    -13.246;
             17.309    0      0    -14.173;
              0.836    0.812  0      0;
            -15.523    0      0     14.494;
             21.984   -3.425  0    -12.522;
              4.860   -0.655  0      0];
T4.coef_v = [-0.145    0     -0.020  0;
              0        0      0      0;
             -0.991    0      0      0.620;
              0        0      0      0;
              0        0      0      0;
              0        0      0      0];
T4.coef_a = [ 0.145   -0.137  0.015  0;
             -0.556    0      0      0.492;
              0        0      0      0;
              0.055   -0.019  0     -0.089;
              0.433    0      0      0;
              0.412    0.087 -0.012 -0.425];

tablas = [T1, T2, T3, T4];

end
