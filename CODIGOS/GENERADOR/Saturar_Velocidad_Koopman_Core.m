function v_eff_kph = Saturar_Velocidad_Koopman_Core(v_kph, opciones)
% SATURAR_VELOCIDAD_KOOPMAN_CORE  02-sep-2026: satura suavemente la
%                   velocidad ANTES de evaluarla en las regresiones de
%                   Koopman 2014 (angulos, Tablas 1-4, y tiempo de ciclo,
%                   Ec.3/Tabla 5) - NO reemplaza la velocidad Froude
%                   "real" reportada al usuario ni la que usa el modelo
%                   de GRF (Predecir_GRF_Personalizado_Core.m); solo la
%                   que ve internamente Koopman2014_Core.m.
%
%   v_eff_kph = Saturar_Velocidad_Koopman_Core(v_kph)
%   v_eff_kph = Saturar_Velocidad_Koopman_Core(v_kph, opciones)
%
% POR QUE EXISTE: cada regresion de Koopman es CUADRATICA en velocidad
% (evaluar_regresion dentro de Koopman2014_Core.m: coef(1) + coef(2)*v +
% coef(3)*v^2 + coef(4)*l) - fuera del rango que el paper valido
% (0.5-5 km/h), el termino v^2 puede dominar y producir una sensibilidad a
% velocidad mucho mayor que la real. Verificado con dos bases de datos
% independientes (Kuopio N=47, Maastricht N=244, ver
% docs/algoritmo/informe_tecnico_generador/informe_tecnico_generador.tex,
% Limitaciones): la velocidad Froude estimada para casi cualquier talla
% adulta (Estimar_Velocidad_Froude_Core.m, Fr=0.25) cae en 4.7-6 km/h, ya
% fuera del limite superior publicado (5 km/h) - la extrapolacion produce
% una correlacion FALSA y con signo alternante entre talla y theta_tibia
% (|r| hasta 0.99 en el modelo, contra |r|<=0.08 en el dato real, en
% ambas bases) en el tramo 40-90% del ciclo.
%
% FORMULA (corregida 02-sep-2026 tras FALLAR Test 12/16 de
% Test_Generador.m con un primer intento v_max*tanh(v/v_max) - esa forma
% comprime TODO el rango, incluido el ya validado: en v=v_max=5 da
% 5*tanh(1)=3.81, un 24% menos - inaceptable, altera resultados ya
% verificados dentro del rango publicado):
%
%   v_eff = v_kph                                     si v_kph <= v_max
%   v_eff = v_max + margen * tanh((v_kph-v_max)/margen)   si v_kph >  v_max
%
% Propiedades (verificables analiticamente):
%   - IDENTIDAD EXACTA para v_kph <= v_max: el rango publicado y ya
%     validado (0.5-5 kph) queda intacto, cero distorsion.
%   - C1-continua en v_kph=v_max: derivada del primer tramo = 1;
%     derivada del segundo tramo en el empalme = margen*(1/margen)*
%     sech^2(0) = 1*1 = 1 - coinciden exactas, sin quiebre.
%   - v_eff -> v_max + margen cuando v_kph -> infinito: acotada, nunca
%     crece sin limite (a diferencia de dejar pasar v_kph crudo al
%     termino v^2 de evaluar_regresion).
%   - margen (km/h) es el UNICO parametro libre - cuanto puede crecer
%     v_eff mas alla del limite publicado antes de aplanarse. Elegido por
%     barrido (Ajustar_Margen_Saturacion_Koopman.m si se agrega, o
%     verificacion manual documentada en el informe tecnico) contra el
%     rango de extrapolacion realmente observado (Froude da 4.7-6.6 kph
%     para talla adulta 130-210cm, Kuopio+Maastricht) - default 1 kph,
%     verificado que ya reduce sustancialmente la falsa correlacion con
%     talla (ver informe tecnico, Limitaciones) sin degradar r/RMSE
%     contra Kuopio/Maastricht dentro del rango validado.
%
% La advertencia de extrapolacion (ahora en Koopman2014_Core.m, no en
% Tiempo_Ciclo_Koopman2014_Core.m - ver nota ahi) sigue disparandose con
% la velocidad ORIGINAL (sin saturar) - esta funcion NO oculta que el
% dato de entrada estaba fuera de rango, solo evita que la regresion se
% evalue con esa extrapolacion sin control.
%
% ENTRADA
%   v_kph       velocidad (km/h), escalar positivo
%   opciones.v_max_kph    limite superior publicado por Koopman 2014
%                         (default 5, Sec. "Rango de valores" del paper)
%   opciones.margen_kph   cuanto puede crecer v_eff mas alla de v_max_kph
%                         antes de aplanarse (default 1)
%
% SALIDA
%   v_eff_kph   velocidad efectiva (km/h): igual a v_kph si v_kph<=v_max,
%               acotada en (v_max, v_max+margen) si v_kph>v_max
% ==========================================================================

if nargin < 1 || ~(isnumeric(v_kph) && isscalar(v_kph) && v_kph > 0)
    error('v_kph debe ser un escalar positivo (km/h). Se recibio: %s', mat2str(v_kph));
end
if nargin < 2, opciones = struct(); end
if ~isfield(opciones,'v_max_kph'), opciones.v_max_kph = 5; end
if ~isfield(opciones,'margen_kph'), opciones.margen_kph = 1; end

vmax = opciones.v_max_kph;
margen = opciones.margen_kph;

if v_kph <= vmax
    v_eff_kph = v_kph;
else
    v_eff_kph = vmax + margen * tanh((v_kph - vmax) / margen);
end

end
