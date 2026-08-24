function out = Generar_Trayectoria(antropometria, candidato, opciones)
% GENERAR_TRAYECTORIA  Funcion de contrato del generador (E1 de
%                       plan_100_generador.md, docs/algoritmo/
%                       contrato_generador.md): desde antropometria,
%                       produce la trayectoria de apoyo y balanceo lista
%                       para Escribir_CSV_Simulador.m. Orquesta E2-E7.
%
%   out = Generar_Trayectoria(antropometria)
%   out = Generar_Trayectoria(antropometria, candidato)
%   out = Generar_Trayectoria(antropometria, candidato, opciones)
%
% ENTRADA
%   antropometria   struct: .talla_m (obligatorio), .masa_kg, .sexo,
%                   .edad_anios, .long_muslo_m, .long_tibia_m,
%                   .velocidad_ms (todos opcionales - se completan con
%                   Estimar_Antropometria_Core.m / Estimar_Velocidad_
%                   Froude_Core.m si faltan, D1/D2 de plan_100_generador.md)
%   candidato       'Koopman' (default) | 'Yun' | 'Zhao'
%   opciones.punto_seguimiento_m   (NUEVO 23-ago-2026, 2ª pasada, pedido
%                   explicito del usuario) distancia (m) desde el TOBILLO,
%                   a lo largo del segmento tibial, hasta el punto que se
%                   quiere seguir - default = long_tibia_m (la rodilla
%                   anatomica, extremo del segmento, comportamiento previo
%                   a este cambio). Se pasa tal cual a
%                   Cadena_Cinematica_Core.m para AMBAS fases (apoyo y
%                   balanceo) - el mismo punto fisico del segmento se
%                   sigue en todo el ciclo. Motivo: el usuario senalo que
%                   el marcador/sensor real de Control_apoyo_Luis_V4.csv
%                   no estaba en la rodilla exacta, sino a ~0.38 m del
%                   tobillo - ver Cadena_Cinematica_Core.m para la
%                   derivacion geometrica completa y el detalle de
%                   trazabilidad (por que no se fijo 0.38 como default:
%                   no se conoce la longitud de tibia real de ese sujeto
%                   para confirmar que 0.38 sigue siendo un punto valido
%                   de SU segmento especifico, y esta funcion no debe
%                   inventar ese default para todos los sujetos).
%
% SALIDA: struct `out`
%   .apoyo.t_s, .apoyo.x_cm, .apoyo.y_cm, .apoyo.angulo_deg
%   .balanceo.t_s, .balanceo.x_cm, .balanceo.y_cm, .balanceo.angulo_deg
%   .metadatos: candidato, antropometria completa (con fuentes),
%               temporizacion completa
%
% Amplitud horizontal: 100% anatomica, SIN recorte (decision D1 de
% plan_100_generador.md #3 - "puramente anatomica, olvidate de la
% restriccion de 45cm, eso se ve despues al ejecutarlo"). El ajuste a
% los limites reales del banco es tarea de la ETAPA DE EJECUCION, fuera
% de esta funcion.
%
% MODELO CINEMATICO (declarado, E5/E6 - ver Cadena_Cinematica_Core.m y
% GUIA_INTERPRETACION.md para el detalle completo):
%   - theta_tibia(t) por candidato, via la regla de E2 (que camino usar
%     por candidato y por fase).
%   - Rotacion pura del segmento tibial sobre un pivote (tobillo) fijo
%     en APOYO (modelo de pendulo invertido, estandar en literatura de
%     marcha, p.ej. Kuo 2007).
%   - En BALANCEO, se agrega una TRASLACION horizontal lineal a la
%     velocidad ya estimada (E4, Froude o medida) sobre la rotacion
%     pura - aproximacion declarada de que la pierna avanza en el
%     espacio durante el balanceo (no solo rota sobre un punto fijo);
%     no reemplaza la cadena de muslo completa (diferida, GUIA
%     #5-ter), es la correccion de primer orden mas simple y
%     defendible para el efecto que domina el error de "tobillo fijo"
%     durante esta fase.
% ==========================================================================

if nargin < 1 || ~isstruct(antropometria) || ~isfield(antropometria,'talla_m')
    error('antropometria debe ser un struct con al menos el campo talla_m.');
end
if nargin < 2 || isempty(candidato), candidato = 'Koopman'; end
if ~any(strcmpi(candidato, {'Koopman','Yun','Zhao'}))
    error('candidato debe ser ''Koopman'', ''Yun'' o ''Zhao''. Se recibio: %s', mat2str(candidato));
end
if nargin < 3, opciones = struct(); end

% --- E3: completar antropometria ---
antro = Estimar_Antropometria_Core(antropometria);

% --- E4: temporizacion (velocidad, duracion de ciclo, particion) ---
tempo = Temporizacion_Core(antro, candidato);

% --- Correr el candidato y obtener theta_tibia por fase (regla E2) ---
n = 101;  % puntos por fase, mismo patron que el resto del proyecto
switch lower(candidato)
    case 'koopman'
        v_kph = tempo.velocidad_ms * 3.6;
        K = Koopman2014_Core(v_kph, antro.talla_m, struct('nMuestras', n));
        theta_apoyo    = K.theta_tibia_via_tobillo_rad;
        theta_balanceo = K.theta_tibia_via_rodilla_rad;
        tempo.tiempo_ciclo_s = K.tiempo_ciclo_s;  % usa el propio de Koopman (consistente)

    case 'zhao'
        f_zancada = 1 / tempo.tiempo_ciclo_s;
        Z = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, f_zancada, struct('nMuestras', n));
        theta_apoyo    = Z.theta_tibia_rad;
        theta_balanceo = Z.theta_tibia_rad;

    case 'yun'
        p14 = vector14_desde_antropometria(antro);
        Y = Yun2014_Wrapper(p14);
        % Yun tiene su propio numero de muestras (101 por defecto del
        % toolbox) - remuestrear si hiciera falta (aqui coincide, n=101)
        theta_apoyo    = Y.theta_tibia_via_tobillo_R_rad;
        theta_balanceo = Y.theta_tibia_via_tobillo_R_rad;  % via_rodilla marcada no confiable, E2
        tempo.tiempo_ciclo_s = Y.periodo_s;  % periodo propio del toolbox
end

tempo.tiempo_apoyo_s    = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
tempo.tiempo_balanceo_s = (1 - tempo.frac_apoyo) * tempo.tiempo_ciclo_s;

% Recortar/indexar cada theta a su ventana de %ciclo correspondiente
% (0 a frac_apoyo*100 para apoyo, frac_apoyo*100 a 100 para balanceo),
% remuestreado a n puntos cada uno - mismo patron que el CSV real
% (Desplazamientos.m: apoyo 0-60%, balanceo 60-100%).
pct_ciclo_completo = linspace(0, 100, numel(theta_apoyo));
pct_corte = tempo.frac_apoyo * 100;

pct_ap  = linspace(0, pct_corte, n);
pct_bal = linspace(pct_corte, 100, n);

theta_ap_rad  = interp1(pct_ciclo_completo, theta_apoyo,    pct_ap,  'pchip');
theta_bal_rad = interp1(pct_ciclo_completo, theta_balanceo, pct_bal, 'pchip');

% --- E5: cadena cinematica (posicion del punto seguido, relativa a tobillo) ---
L_tibia_m = antro.long_tibia_m;
if ~isfield(opciones,'punto_seguimiento_m') || isempty(opciones.punto_seguimiento_m)
    punto_seguimiento_m = L_tibia_m;  % default: rodilla anatomica (comportamiento previo)
else
    punto_seguimiento_m = opciones.punto_seguimiento_m;
end
cc_opts = struct('punto_seguimiento_m', punto_seguimiento_m);
pos_ap  = Cadena_Cinematica_Core(theta_ap_rad,  L_tibia_m, cc_opts);
pos_bal = Cadena_Cinematica_Core(theta_bal_rad, L_tibia_m, cc_opts);

% --- E6: amplitud anatomica - traslacion horizontal en balanceo ---
t_bal = linspace(0, tempo.tiempo_balanceo_s, n);
x_traslacion_cm = tempo.velocidad_ms * 100 * t_bal;  % v en cm/s * t
pos_bal.x_cm = pos_bal.x_cm + x_traslacion_cm;

% --- Ensamblar salida, normalizando cada fase a (0,0) en la 1ra muestra
%     (MISMA convencion que normalizeDisp de Desplazamientos.m L12) ---
out = struct();
out.apoyo.t_s        = linspace(0, tempo.tiempo_apoyo_s, n);
out.apoyo.x_cm        = pos_ap.x_cm - pos_ap.x_cm(1);
out.apoyo.y_cm        = pos_ap.y_cm - pos_ap.y_cm(1);
out.apoyo.angulo_deg  = rad2deg(theta_ap_rad);

out.balanceo.t_s       = linspace(0, tempo.tiempo_balanceo_s, n);
out.balanceo.x_cm       = pos_bal.x_cm - pos_bal.x_cm(1);
out.balanceo.y_cm       = pos_bal.y_cm - pos_bal.y_cm(1);
out.balanceo.angulo_deg = rad2deg(theta_bal_rad);

out.metadatos = struct('candidato', candidato, 'antropometria', antro, 'temporizacion', tempo, ...
    'punto_seguimiento_m', punto_seguimiento_m);

end

% ==========================================================================
function p14 = vector14_desde_antropometria(antro)
% Arma el vector de 14 parametros que pide Yun2014_Wrapper.m, con lo
% disponible de Estimar_Antropometria_Core.m y valores por defecto del
% propio demo del toolbox (docs/literatura/pdfs/yun2014_toolbox/
% demo_Gait_Pred.m) para los campos que este generador no estima
% todavia (anchos biiliaco/bitrocantereo, ASIS, diametro de rodilla,
% maleolo) - declarado, no oculto: son campos de MENOR peso en la
% regresion de Yun (el propio paper no reporta ranking de importancia,
% docs/algoritmo/diseno_matematico_generador.md), y usar el default del
% demo es mas seguro que inventar una estimacion sin respaldo para
% ellos.
if ~isfield(antro,'edad_anios') || isempty(antro.edad_anios), antro.edad_anios = 25; end
if ~isfield(antro,'sexo'), antro.sexo = 'M'; end
sexo01 = double(upper(antro.sexo(1)) == 'M');

talla_cm = antro.talla_m * 100;
muslo_cm = antro.long_muslo_m * 100;
tibia_cm = antro.long_tibia_m * 100;
pie_cm   = antro.long_pie_m   * 100;

% Defaults del demo del toolbox (proporcion tipica adulto, declarados).
% Orden de los 14 parametros (demo_Gait_Pred.m, comentario de cabecera):
% 1.Edad 2.Talla(cm) 3.Masa(kg) 4.Sexo 5.Muslo 6.Pantorrilla
% 7.AnchoBitroc 8.AnchoBiiliaco 9.ASIS 10.DiametroRodilla 11.LongPie
% 12.AlturaMaleolo 13.AnchoMaleolo 14.AnchoPie
p14 = [antro.edad_anios, talla_cm, antro.masa_kg, sexo01, ...
       muslo_cm, tibia_cm, ...
       32.8, 29.7, 25.5, ...    % anchos bitrocantereo/biiliaco/ASIS (default demo)
       10, ...                  % diametro de rodilla (default demo)
       pie_cm, ...
       7.30, 7.10, 9.80];       % altura/ancho maleolo, ancho pie (default demo)
end
