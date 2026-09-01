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
% CALIBRACION AFIN KOOPMAN (28-ago-2026, default ON): Koopman2014_Core.m
% sobreestima la excursion angular ~19-24% (validado contra Kuopio 2024,
% LOSO, ver Calibracion_Koopman_Kuopio_Core.m) - se corrige por defecto
% para que la trayectoria EXPORTADA sea la mejor estimacion disponible, no
% la version cruda sin corregir. Se puede apagar explicitamente
% (opciones.calibrar_koopman=false) para reproducir el comportamiento
% previo a esta fecha (p.ej. comparar contra resultados ya publicados en
% docs/algoritmo/pipeline_koopman_kuopio/, que usan la version cruda).
if ~isfield(opciones,'calibrar_koopman') || isempty(opciones.calibrar_koopman)
    opciones.calibrar_koopman = true;
end
opts_cal = struct('calibrar_koopman', opciones.calibrar_koopman);

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

    tempo.tiempo_apoyo_s    = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
    tempo.tiempo_balanceo_s = (1 - tempo.frac_apoyo) * tempo.tiempo_ciclo_s;
    t_ap  = linspace(0, tempo.tiempo_apoyo_s,    n);
    t_bal = linspace(0, tempo.tiempo_balanceo_s, n);
    pos_ap.x_cm  = pos_ap.x_cm  + tempo.velocidad_ms * 100 * t_ap;   % v en cm/s * t
    pos_bal.x_cm = pos_bal.x_cm + tempo.velocidad_ms * 100 * t_bal;
else
    % --- theta_tibia por fase (E2, regla ya establecida por candidato -
    % SIN CAMBIOS, ver Obtener_Theta_Tibia_Candidato.m) ---
    [theta_apoyo, theta_balanceo, tempo] = Obtener_Theta_Tibia_Candidato(candidato, antro, tempo, n, opts_cal);
    pct_ciclo_completo = linspace(0, 100, numel(theta_apoyo));
    pct_corte = tempo.frac_apoyo * 100;
    pct_ap  = linspace(0, pct_corte, n);
    pct_bal = linspace(pct_corte, 100, n);
    theta_ap_rad  = interp1(pct_ciclo_completo, theta_apoyo,    pct_ap,  'pchip');
    theta_bal_rad = interp1(pct_ciclo_completo, theta_balanceo, pct_bal, 'pchip');

    % --- theta_muslo por fase (NUEVO 26-ago-2026, solo para reconstruir el
    % balanceo - ver comentario grande mas abajo). Se pide con
    % Obtener_Angulos_Candidato.m pero se DESCARTA su theta_tibia (usa
    % via_rodilla para Yun, que E2 marca como no confiable para ese
    % candidato) - solo se usa su theta_muslo, que no depende de esa
    % eleccion de "via".
    [th_muslo_full, ~, ~] = Obtener_Angulos_Candidato(candidato, antro, tempo, n, opts_cal);
    theta_muslo_ap_rad  = th_muslo_full.apoyo;
    theta_muslo_bal_rad = th_muslo_full.balanceo;

    tempo.tiempo_apoyo_s    = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
    tempo.tiempo_balanceo_s = (1 - tempo.frac_apoyo) * tempo.tiempo_ciclo_s;
    t_ap  = linspace(0, tempo.tiempo_apoyo_s,    n);
    t_bal = linspace(0, tempo.tiempo_balanceo_s, n);

    % --- E5, APOYO: cadena de un segmento, tobillo pivote fijo + E6
    % (traslacion horizontal). MAGNITUD CORREGIDA 26-ago-2026 (segundo
    % hallazgo del usuario el mismo dia, comparando esta figura contra las
    % de validacion de TOBILLO/ vs Kuopio): la version anterior aplicaba
    % la traslacion a VELOCIDAD COMPLETA durante todo el apoyo (v*t_apoyo),
    % dando ~90cm de avance para un punto cercano al tobillo - la realidad
    % medida (Kuopio, N=15, Cargar_Kuopio2024_Core.m) es que el tobillo
    % real solo avanza el 7.9% (SD 1.8%) de la zancada total durante el
    % apoyo (media 8.16cm, SD 3.00, rango 3.07-13.04cm) - el resto del
    % avance de la zancada ocurre en el balanceo, no en el apoyo (el pie
    % esta practicamente plantado). Se reemplaza v*t_apoyo (que asumia que
    % TODO el cuerpo rigido, incluido el "tobillo", viaja a la velocidad
    % de marcha completa durante el apoyo) por esta fraccion, que SI tiene
    % respaldo en datos reales (promedio de poblacion, no LOSO por sujeto -
    % LOSO no aplica aqui, un sujeto nuevo del generador no tiene "los
    % otros 14" de quien tomar el promedio; se usa el promedio de los 15
    % como constante general, igual que Fr=0.25 en Estimar_Velocidad_
    % Froude_Core.m es una constante poblacional, no ajustada por sujeto).
    % NOTA: se mantiene NO-CERO (a diferencia de antes de la correccion
    % del 24-ago) porque sin ninguna traslacion la rotacion sola podia
    % hacer retroceder el X localmente - ver Test 15 y verificacion mas
    % abajo de que la monotonia se mantiene con este valor mas chico.
    % REEMPLAZADO 28-ago-2026 (mismo dia, sesion de GRF): el FRAC_AVANCE_
    % APOYO=0.079 de una sola recta era una aproximacion de UN NUMERO al
    % avance real del tobillo. Ya existe algo mejor: el residuo de rockers
    % completo (X Y, 101 puntos, promedio N=13 Kuopio) construido para
    % GRF_Newton_ApoyoSimple_Core.m el mismo dia (ver Residuo_Rockers_
    % Tobillo_Kuopio_Core.m) - reproduce tambien el rocker de ANTEPIE al
    % final del apoyo (el tobillo SUBE unos cm antes del despegue, no solo
    % avanza) que la recta no capturaba, y aporta el mismo eje Y que antes
    % no tenia NINGUNA correccion en apoyo (pos_ap.y_cm era pura rotacion
    % sobre tobillo fijo). Se usa la MISMA funcion que GRF_Newton_
    % ApoyoSimple_Core.m para que los dos pipelines queden consistentes
    % (chequeo de consistencia de Ver_GRF_y_Trayectoria.m, discrepancia
    % antes de este cambio: 6.41cm, reintroducida al agregar el residuo
    % solo del lado de GRF).
    rockers = Residuo_Rockers_Tobillo_Kuopio_Core();
    pct_ap_gt = linspace(0, tempo.frac_apoyo*100, n);
    resid_x_ap = interp1(rockers.pct_ciclo, rockers.x_cm, pct_ap_gt, 'pchip');
    resid_y_ap = interp1(rockers.pct_ciclo, rockers.y_cm, pct_ap_gt, 'pchip');

    cc_opts = struct('punto_seguimiento_m', punto_seguimiento_m);
    pos_ap  = Cadena_Cinematica_Core(theta_ap_rad, L_tibia_m, cc_opts);
    pos_ap.x_cm = pos_ap.x_cm + resid_x_ap;
    pos_ap.y_cm = pos_ap.y_cm + resid_y_ap;

    % --- E5, BALANCEO: CORREGIDO 26-ago-2026 (hallazgo del usuario: la
    % rodilla "retrocedia" en X en tramos del ciclo generado por defecto,
    % visible en docs/algoritmo/pipeline_koopman_kuopio/figuras/
    % 05_generador_salida_koopman.png). Causa raiz: el balanceo usaba la
    % MISMA rotacion-sobre-tobillo-fijo que el apoyo mas una traslacion
    % lineal simple - la rotacion de la tibia sola puede localmente restar
    % mas de lo que la traslacion constante suma, dando movimiento hacia
    % atras (fisicamente implausible). Limitacion ya declarada y dejada
    % pendiente el 24-ago-2026 en Obtener_Theta_Tibia_Candidato.m
    % ("PENDIENTE, decision de modelado del usuario... falta la cadena de
    % muslo completa"). Se resuelve replicando la formula de
    % Cadena_Completa_Core.m (24-ago-2026, ya usada para validar tobillo
    % contra Kuopio, CIERRE_TOBILLO.md #6) SIN llamar a esa funcion
    % directamente, para no alterar su comportamiento ya validado (que no
    % incluye la traslacion de apoyo E6, especifica de este generador): en
    % balanceo la CADERA avanza a la velocidad estimada, y la cadena se
    % construye HACIA ABAJO desde ahi (cadera->rodilla->tobillo) - el punto
    % seguido ya no depende solo de la rotacion de un segmento, tambien de
    % que la cadera avanza monotonamente, lo que elimina el retroceso.
    %
    % Se reconstruye la posicion de la cadera al final del apoyo (nunca
    % calculada hasta ahora, porque el apoyo solo trackea el punto seguido
    % sobre el segmento tibial) para que el balanceo arranque del lugar
    % geometrico correcto: la MISMA traslacion de apoyo (E6) se le aplica
    % a la rodilla (rod_ap_rot, aqui) porque es un cuerpo rigido en
    % traslacion - luego cadera = rodilla - L_muslo*(sin,-cos), formula
    % identica a la que usa Cadena_Completa_Core.m para su propio apoyo.
    % La altura de cadera se mantiene constante durante el balanceo (misma
    % simplificacion ya aceptada en Cadena_Completa_Core.m - el vaiven
    % vertical real de cadera NO se modela aqui, se declara, no se inventa).
    L_muslo_m = antro.long_muslo_m;
    rod_ap_rot = Cadena_Cinematica_Core(theta_ap_rad, L_tibia_m, struct('punto_seguimiento_m', L_tibia_m));
    rod_ap_x = rod_ap_rot.x_cm + resid_x_ap;   % mismo residuo de rockers que arriba (E6)
    rod_ap_y = rod_ap_rot.y_cm + resid_y_ap;
    cad_ap_x_end = rod_ap_x(end) - L_muslo_m*100*sin(theta_muslo_ap_rad(end));
    cad_ap_y_end = rod_ap_y(end) + L_muslo_m*100*cos(theta_muslo_ap_rad(end));

    cad_bal_x = cad_ap_x_end + tempo.velocidad_ms * 100 * t_bal;
    cad_bal_y = cad_ap_y_end * ones(1, n);
    rod_bal_x = cad_bal_x + L_muslo_m*100*sin(theta_muslo_bal_rad);
    rod_bal_y = cad_bal_y - L_muslo_m*100*cos(theta_muslo_bal_rad);
    tob_bal_x = rod_bal_x + L_tibia_m*100*sin(theta_bal_rad);
    tob_bal_y = rod_bal_y - L_tibia_m*100*cos(theta_bal_rad);

    f_pt = punto_seguimiento_m / L_tibia_m;   % fraccion del segmento tibial: 0=tobillo, 1=rodilla (extremo)
    pos_bal = struct('x_cm', tob_bal_x + f_pt*(rod_bal_x - tob_bal_x), ...
                      'y_cm', tob_bal_y + f_pt*(rod_bal_y - tob_bal_y));
end

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
    'punto_seguimiento_m', punto_seguimiento_m, 'calibrar_koopman', opciones.calibrar_koopman);

end
