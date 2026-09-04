function out = Cadena_Cinematica_Core(theta_tibia_rad, L_tibia_m, opciones)
% CADENA_CINEMATICA_CORE  Posicion de un punto del SEGMENTO TIBIAL en el
%                          plano sagital, relativa a un origen fijo en el
%                          TOBILLO (pivote), desde el angulo absoluto del
%                          segmento y su longitud. E5 de
%                          plan_100_generador.md. Generalizado 23-ago-2026
%                          (2ª pasada, pedido explicito del usuario) para
%                          seguir CUALQUIER punto del segmento, no solo
%                          la rodilla anatomica.
%
%                          Por que hacia falta esto: el usuario senalo que
%                          el marcador/sensor real de Control_apoyo_
%                          Luis_V4.csv no estaba puesto en la articulacion
%                          de la rodilla, sino a una distancia aproximada
%                          de 38 cm del tobillo A LO LARGO de la tibia -
%                          un detalle de colocacion fisica del marcador,
%                          no un dato de literatura (no requiere cita,
%                          es informacion operativa del propio montaje
%                          del equipo, dada directamente por el usuario).
%                          Antes de este cambio, el generador SIEMPRE
%                          asumia que el punto seguido era la rodilla
%                          exacta (extremo del segmento, distancia=L).
%
%                          Supuesto declarado: el tobillo actua como
%                          pivote aproximadamente fijo tanto en apoyo
%                          (modelo de pendulo invertido de la pierna de
%                          apoyo - estandar en literatura de marcha,
%                          p.ej. Kuo 2007) como, por extension, en
%                          balanceo (el CSV del simulador solo necesita
%                          la posicion del punto seguido RELATIVA al
%                          inicio de cada fase - normalizeDisp resta la
%                          primera muestra, Desplazamientos.m L12 - asi
%                          que un corrimiento absoluto del tobillo real
%                          no afecta la FORMA de la trayectoria
%                          exportada, solo su offset, que de todos modos
%                          se anula).
%
%   out = Cadena_Cinematica_Core(theta_tibia_rad, L_tibia_m)
%   out = Cadena_Cinematica_Core(theta_tibia_rad, L_tibia_m, opciones)
%
% ENTRADA
%   theta_tibia_rad   [1 x n] angulo absoluto del segmento tibial (rad),
%                     convencion atan2(avance,vertical) - 0 = tibia
%                     vertical, MISMA convencion que Reduccion_Winter_Core
%                     y Segmento_Posicion_Core.m (theta=0 -> vertical).
%   L_tibia_m         longitud ANATOMICA de tibia (m), tobillo a rodilla -
%                     medida o de Estimar_Antropometria_Core.m. Se usa
%                     para validar que punto_seguimiento_m sea fisicamente
%                     posible (0 <= punto <= L_tibia_m), y como default si
%                     no se da punto_seguimiento_m.
%   opciones.punto_seguimiento_m   distancia (m) desde el TOBILLO, a lo
%                     largo del segmento, hasta el punto que se quiere
%                     seguir - default = L_tibia_m (el extremo, es decir
%                     la rodilla anatomica, comportamiento previo a este
%                     cambio). Usar un valor MENOR para replicar un
%                     marcador/sensor real que no llega hasta la
%                     articulacion (p.ej. ~0.38 m para aproximar
%                     Control_apoyo_Luis_V4.csv, segun lo indicado por el
%                     usuario 23-ago-2026 - NO verificado con la longitud
%                     de tibia real de ese sujeto, que no esta
%                     documentada en el proyecto; si se consigue esa
%                     longitud despues, se puede refinar).
%   opciones.origen_cm   [x0 y0] offset del origen (default [0 0])
%
% SALIDA: struct `out`
%   .x_cm, .y_cm   posicion del punto seguido, relativa al tobillo (cm),
%                  X=avance (horizontal), Y=vertical - MISMA convencion
%                  que Posicion_cm_X/Y del CSV real del simulador.
%
% GEOMETRIA (derivacion directa, sin literatura nueva - es trigonometria
% de un segmento rigido rotando sobre un pivote fijo): si la rodilla
% (extremo, distancia L_tibia_m del tobillo) queda en
% (-L*sin(theta), L*cos(theta)) relativa al tobillo fijo en (0,0) - ver
% nota de signo abajo - entonces CUALQUIER punto a distancia d <= L del
% tobillo, sobre el MISMO segmento rigido, queda en
% (-d*sin(theta), d*cos(theta)): misma formula, se reemplaza L por d.
% Se puede verificar por semejanza de triangulos / interpolacion lineal
% a lo largo del segmento (el punto a fraccion d/L del camino tobillo->
% rodilla escala linealmente ambas componentes por d/L).
%
% NOTA DE SIGNO (G7 CERRADO, 23-ago-2026 - verificado con datos reales,
% no supuesto). Se comparo la correlacion angulo-vs-posicion del
% generador contra Control_apoyo_Luis_V4.csv real (95 filas validas, se
% excluyo una fila final con NaN del propio archivo). Resultado, EN
% TERMINOS DE LA SALIDA YA CORREGIDA (x_m=-vec.x, y_m=vec.y, como hace
% el codigo abajo) frente a la salida CRUDA de Segmento_Posicion_Core.m
% (vec.x=d*sin(theta), vec.y=d*cos(theta)):
%   - EJE X: la salida cruda de Segmento_Posicion_Core.m SI necesito
%     invertirse (x_m=-vec.x) para que el signo coincidiera con el real:
%     corr(ang,X) real=-0.993, generado (ya con la inversion)=-1.000.
%   - EJE Y: la salida cruda de Segmento_Posicion_Core.m NO necesito
%     ningun cambio (y_m=vec.y tal cual) - antes de saber esto se probo
%     invertida por error y dio corr(ang,Y) real=+0.529 vs.
%     generado=-0.450 (signo opuesto, esa version SI estaba mal); sin
%     invertir, coincide.
% En resumen: X invertido respecto a Segmento_Posicion_Core.m, Y no
% invertido - exactamente lo que hace el codigo mas abajo (linea
% "Mismo signo verificado en G7"). Un reflejo sobre el eje X preserva
% distancias, por eso no rompio ninguna prueba de distancia ya validada,
% y esta generalizacion a "cualquier punto del segmento" hereda el mismo
% signo ya verificado (es la misma direccion angular, solo cambia cuanto
% se avanza por ella).
%
% Fuente: Segmento_Posicion_Core.m (ya construido y probado, 23-ago-2026)
% hace la trigonometria de base; esta funcion fija el marco de referencia
% (tobillo como origen), el punto del segmento a seguir, y la conversion
% de unidades (m -> cm, la unidad del CSV real del simulador).
%
% REGLA POR CANDIDATO para elegir que theta_tibia_rad pasar aqui (E2,
% GUIA_INTERPRETACION.md #3-bis) - responsabilidad del LLAMADOR, no de
% esta funcion (que es agnostica al candidato):
%   Koopman: via_tobillo en apoyo, via_rodilla en balanceo (las dos
%            vias verificadas por forma para este candidato - unico de
%            los tres sin el defasaje de rodilla encontrado en E2)
%   Yun:     via_tobillo en AMBAS fases (via_rodilla marcada no confiable
%            por el defasaje de pico de flexion de rodilla, E2)
%   Zhao:    theta_tibia_rad nativo en AMBAS fases (no publica camino
%            via tobillo - solo tiene el camino equivalente a "via
%            rodilla", con el mismo defasaje declarado como limitacion
%            heredada del modelo publicado, no corregible aqui)
% ==========================================================================

if nargin < 2
    error('Se requieren theta_tibia_rad y L_tibia_m.');
end
if nargin < 3, opciones = struct(); end
if ~isfield(opciones,'origen_cm'), opciones.origen_cm = [0 0]; end

if ~(isnumeric(L_tibia_m) && isscalar(L_tibia_m) && L_tibia_m > 0)
    error('L_tibia_m debe ser un escalar positivo (m). Se recibio: %s', mat2str(L_tibia_m));
end

if ~isfield(opciones,'punto_seguimiento_m') || isempty(opciones.punto_seguimiento_m)
    d_m = L_tibia_m;  % default: extremo del segmento = rodilla anatomica
else
    d_m = opciones.punto_seguimiento_m;
    if ~(isnumeric(d_m) && isscalar(d_m) && d_m >= 0)
        error('opciones.punto_seguimiento_m debe ser un escalar >= 0 (m). Se recibio: %s', mat2str(d_m));
    end
    if d_m > L_tibia_m
        error(['opciones.punto_seguimiento_m (%.4f m) no puede ser mayor que L_tibia_m (%.4f m) - ' ...
               'el punto seguido tiene que estar SOBRE el segmento tobillo-rodilla, no mas alla.'], d_m, L_tibia_m);
    end
end

% Caso borde: punto_seguimiento_m=0 es el tobillo mismo (fijo en origen)
% - Segmento_Posicion_Core exige L>0, asi que este caso se resuelve
% directo sin llamarla, sin necesidad de literatura ni supuestos nuevos.
if d_m == 0
    n = numel(theta_tibia_rad);
    x_m = zeros(1,n);
    y_m = zeros(1,n);
else
    % Vector tobillo->punto_seguido (misma direccion que tobillo->rodilla,
    % escalada por d_m en vez de L_tibia_m - ver derivacion geometrica arriba)
    vec = Segmento_Posicion_Core(theta_tibia_rad, d_m);  % vec.x, vec.y en METROS, con L=d_m
    % Mismo signo verificado en G7: X invertido, Y no invertido.
    x_m = -vec.x;
    y_m = vec.y;
end

out = struct();
out.x_cm = x_m * 100 + opciones.origen_cm(1);
out.y_cm = y_m * 100 + opciones.origen_cm(2);
out.punto_seguimiento_m = d_m;  % trazabilidad: que distancia se uso

end
