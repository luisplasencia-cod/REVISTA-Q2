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
%   candidato       'Koopman' (default) | 'Yun' | 'Zhao' | 'Combinado'
%                   (NUEVO 24-ago-2026, Combinar_Candidatos_Core.m: promedio
%                   simple de los 4 candidatos a nivel de POSICION - ver
%                   docs/planificacion/plan_ensamble_multimodelo.md Sec.4.
%                   RESTRICCION: con 'Combinado', opciones.punto_seguimiento_m
%                   NO puede ser distinto de la rodilla anatomica (long_tibia_m) -
%                   Romero-Sorozabal solo publica posicion de articulaciones
%                   completas, no de un punto intermedio del segmento; ver
%                   Combinar_Candidatos_Core.m Restriccion #1.)
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
%   - Rotacion pura del segmento tibial sobre un pivote (tobillo) via
%     Cadena_Cinematica_Core.m (modelo de pendulo invertido, estandar en
%     literatura de marcha, p.ej. Kuo 2007).
%   - CORREGIDO 24-ago-2026 (antes: TRASLACION solo en balanceo, tobillo
%     perfectamente fijo en apoyo): se agrega una TRASLACION horizontal
%     lineal a la velocidad ya estimada (E4, Froude o medida) sobre la
%     rotacion pura EN LAS DOS FASES (apoyo y balanceo) - verificado
%     contra el avance real de rodilla/tobillo de Camargo AB06
%     (Verificar_Pipeline_Completo_vs_Real.m): el tobillo real NO esta
%     perfectamente fijo durante el apoyo, avanza de forma continua
%     (aunque mas lento que en balanceo) - sin esta traslacion en apoyo,
%     el X generado no avanzaba monotono (bajaba y volvia a subir),
%     inconsistente con el dato real. Aproximacion declarada (velocidad
%     constante x tiempo, misma formula en ambas fases) - NO reemplaza la
%     cadena de muslo completa (diferida, GUIA #5-ter, modelaria el
%     avance real de la cadera en vez de una velocidad constante
%     asumida); es la correccion de primer orden mas simple y defendible,
%     elegida explicitamente por el usuario sobre la alternativa mas
%     rigurosa.
% ==========================================================================

if nargin < 1 || ~isstruct(antropometria) || ~isfield(antropometria,'talla_m')
    error('antropometria debe ser un struct con al menos el campo talla_m.');
end
if nargin < 2 || isempty(candidato), candidato = 'Koopman'; end
if ~any(strcmpi(candidato, {'Koopman','Yun','Zhao','Combinado'}))
    error('candidato debe ser ''Koopman'', ''Yun'', ''Zhao'' o ''Combinado''. Se recibio: %s', mat2str(candidato));
end
if nargin < 3, opciones = struct(); end

% --- E3: completar antropometria ---
antro = Estimar_Antropometria_Core(antropometria);

% --- E4: temporizacion (velocidad, duracion de ciclo, particion) ---
% 'Combinado' usa Koopman como referencia temporal (mismo criterio que
% Combinar_Candidatos_Core.m documenta) - Temporizacion_Core no conoce
% 'Combinado' como candidato valido, asi que se pide con 'Koopman'.
tempo = Temporizacion_Core(antro, char(regexprep(candidato, '(?i)^Combinado$', 'Koopman')));

n = 101;  % puntos por fase, mismo patron que el resto del proyecto
L_tibia_m = antro.long_tibia_m;
if ~isfield(opciones,'punto_seguimiento_m') || isempty(opciones.punto_seguimiento_m)
    punto_seguimiento_m = L_tibia_m;  % default: rodilla anatomica (comportamiento previo)
else
    punto_seguimiento_m = opciones.punto_seguimiento_m;
end

if strcmpi(candidato, 'Combinado')
    if abs(punto_seguimiento_m - L_tibia_m) > 1e-9
        error(['candidato=''Combinado'' solo admite la rodilla anatomica ' ...
               '(punto_seguimiento_m = long_tibia_m = %.4f m) - Romero-Sorozabal no ' ...
               'publica posicion de un punto intermedio del segmento. ' ...
               'Se recibio punto_seguimiento_m=%.4f m. Ver Combinar_Candidatos_Core.m, Restriccion #1.'], ...
               L_tibia_m, punto_seguimiento_m);
    end

    % --- E2-E5 combinados (Combinar_Candidatos_Core.m: promedio simple a
    %     nivel de posicion de los 4 candidatos - Sec.4 del plan de ensamble) ---
    [comb, tempo] = Combinar_Candidatos_Core(antro, tempo, n);
    pos_ap  = struct('x_cm', comb.apoyo.x_cm,    'y_cm', comb.apoyo.y_cm);
    pos_bal = struct('x_cm', comb.balanceo.x_cm, 'y_cm', comb.balanceo.y_cm);
    % Angulo "equivalente" del segmento tobillo->punto combinado, SOLO para
    % reportar/graficar (no es un theta modelado directamente, es el que
    % resulta de la posicion ya promediada) - misma convencion atan2 que
    % Segmento_Posicion_Core.m/Cadena_Cinematica_Core.m (0=vertical).
    theta_ap_rad  = atan2(-pos_ap.x_cm/100,  pos_ap.y_cm/100);
    theta_bal_rad = atan2(-pos_bal.x_cm/100, pos_bal.y_cm/100);
else
    % --- Correr el candidato y obtener theta_tibia por fase (regla E2) ---
    % (24-ago-2026: extraido a Obtener_Theta_Tibia_Candidato.m para que
    % Combinar_Candidatos_Core.m reuse la MISMA regla sin duplicarla - ver ese
    % archivo para el detalle completo por candidato/fase)
    [theta_apoyo, theta_balanceo, tempo] = Obtener_Theta_Tibia_Candidato(candidato, antro, tempo, n);

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
    cc_opts = struct('punto_seguimiento_m', punto_seguimiento_m);
    pos_ap  = Cadena_Cinematica_Core(theta_ap_rad,  L_tibia_m, cc_opts);
    pos_bal = Cadena_Cinematica_Core(theta_bal_rad, L_tibia_m, cc_opts);
end

tempo.tiempo_apoyo_s    = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
tempo.tiempo_balanceo_s = (1 - tempo.frac_apoyo) * tempo.tiempo_ciclo_s;

% --- E6: amplitud anatomica - traslacion horizontal (apoyo Y balanceo) ---
% CORREGIDO 24-ago-2026 (verificado contra Camargo AB06 real, ver
% Verificar_Pipeline_Completo_vs_Real.m): originalmente esta traslacion
% solo se sumaba en balanceo, con el supuesto de que el tobillo esta
% perfectamente fijo durante TODO el apoyo. Comparado contra el avance
% real de rodilla/tobillo de Camargo, eso produce un X que NO avanza
% monotono en apoyo (baja y vuelve a subir) - el avance real, aunque
% chico al principio del apoyo, es continuo. Aproximacion simple elegida
% (velocidad de marcha constante x tiempo, MISMA formula que ya usaba
% balanceo) - decision del usuario: arreglo rapido con lo que ya existe,
% no un modelo nuevo de avance de cadera (esa alternativa, "cadena de
% muslo completa", queda anotada como pendiente mas riguroso, ver
% Cadena_Cinematica_Core.m). Con esto el tobillo YA NO queda perfectamente
% fijo en apoyo - se declara como cambio de supuesto, no se oculta.
t_ap  = linspace(0, tempo.tiempo_apoyo_s,    n);
t_bal = linspace(0, tempo.tiempo_balanceo_s, n);
pos_ap.x_cm  = pos_ap.x_cm  + tempo.velocidad_ms * 100 * t_ap;   % v en cm/s * t
pos_bal.x_cm = pos_bal.x_cm + tempo.velocidad_ms * 100 * t_bal;

% --- Ensamblar salida ---
% Apoyo: normalizado a (0,0) en su 1ra muestra (MISMA convencion que
% normalizeDisp de Desplazamientos.m L12, sin cambios).
% Balanceo: CAMBIADO 24-ago-2026 (decision del usuario) - antes tambien
% arrancaba en (0,0), lo que producia un salto vertical del X justo en el
% cambio de fase al graficar el ciclo completo (heredado del formato del
% CSV original, que guarda apoyo y balanceo como series independientes).
% Ahora el balanceo CONTINUA donde termino el apoyo, para que el ciclo
% completo sea continuo y comparable con el avance real de Camargo. Si se
% necesita el formato de series independientes (cada fase desde 0), restar
% out.balanceo.x_cm(1)/y_cm(1) al exportar.
out = struct();
out.apoyo.t_s        = linspace(0, tempo.tiempo_apoyo_s, n);
out.apoyo.x_cm        = pos_ap.x_cm - pos_ap.x_cm(1);
out.apoyo.y_cm        = pos_ap.y_cm - pos_ap.y_cm(1);
out.apoyo.angulo_deg  = rad2deg(theta_ap_rad);

out.balanceo.t_s       = linspace(0, tempo.tiempo_balanceo_s, n);
out.balanceo.x_cm       = (pos_bal.x_cm - pos_bal.x_cm(1)) + out.apoyo.x_cm(end);
out.balanceo.y_cm       = (pos_bal.y_cm - pos_bal.y_cm(1)) + out.apoyo.y_cm(end);
out.balanceo.angulo_deg = rad2deg(theta_bal_rad);

out.metadatos = struct('candidato', candidato, 'antropometria', antro, 'temporizacion', tempo, ...
    'punto_seguimiento_m', punto_seguimiento_m);

end
