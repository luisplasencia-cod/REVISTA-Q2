function [out, tempo] = Combinar_Candidatos_Core(antro, tempo, n)
% COMBINAR_CANDIDATOS_CORE  Promedio simple, a nivel de POSICION (x,z),
%                   de los 4 candidatos del generador (Koopman 2014, Zhao
%                   2026, Yun 2014, Romero-Sorozabal 2024) - decision del
%                   usuario, 24-ago-2026, ver
%                   docs/planificacion/plan_ensamble_multimodelo.md Sec.4:
%                   promedio simple (no mediana, no pesos optimizados,
%                   peso IGUAL para los 4), aplicado sobre POSICION del
%                   punto seguido, no sobre angulo.
%
%   [out, tempo] = Combinar_Candidatos_Core(antro, tempo, n)
%
% ENTRADA
%   antro   antropometria ya completada (Estimar_Antropometria_Core.m)
%   tempo   temporizacion ya calculada (Temporizacion_Core.m) - esta
%           funcion SIEMPRE usa Koopman como referencia temporal (mismo
%           comportamiento que Generar_Trayectoria.m ya tiene cuando
%           candidato='Koopman': tempo.tiempo_ciclo_s se sobreescribe con
%           el propio de Koopman). Se necesita UNA sola referencia de
%           frac_apoyo/tiempo_ciclo_s para recortar los 4 candidatos a
%           las mismas ventanas de fase - Koopman se eligio por ser ya el
%           candidato por defecto del proyecto (Generar_Trayectoria.m).
%   n       puntos por fase (mismo remuestreo que el resto del proyecto)
%
% SALIDA
%   out.apoyo.x_cm, out.apoyo.y_cm, out.balanceo.x_cm, out.balanceo.y_cm
%       posicion COMBINADA del punto seguido, relativa al tobillo (cm) -
%       MISMO formato/convencion que Cadena_Cinematica_Core.m (para que
%       Generar_Trayectoria.m pueda usarla como una 5ta rama del switch,
%       "Combinado", sin cambiar el resto del pipeline E6/normalizacion).
%       SIN el termino de traslacion de balanceo (E6) ni la normalizacion
%       a (0,0) - eso lo aplica el llamador, igual que a los otros 4.
%   out.detalle   struct con la curva INDIVIDUAL de cada candidato (antes
%       de promediar) - x_koopman_cm, x_zhao_cm, x_yun_cm, x_romero_cm,
%       z_koopman_cm, z_zhao_cm, z_yun_cm (Romero-Sorozabal NO tiene z,
%       ver restriccion abajo) - para diagnostico/visualizacion, no para
%       el pipeline.
%
% RESTRICCION DECLARADA #1 - COMBINACION SOLO EN LA RODILLA ANATOMICA:
%   Romero-Sorozabal solo publica posicion de cadera/rodilla/tobillo
%   (articulaciones completas), no de un punto arbitrario a mitad del
%   segmento tibial. Por eso esta funcion combina SIEMPRE en el extremo
%   del segmento (punto_seguimiento_m = long_tibia_m, la rodilla
%   anatomica) - IGNORA cualquier punto_seguimiento_m distinto que se
%   use en Generar_Trayectoria.m para un candidato individual (p.ej. el
%   ~0.38m de Control_apoyo_Luis_V4.csv). Si se necesita el ensamble en
%   un punto intermedio del segmento, Romero-Sorozabal queda fuera de esa
%   combinacion especifica (no hay como interpolar su dato para un punto
%   que el paper no mide).
%
% RESTRICCION DECLARADA #2 - EJE Z DE RODILLA/TOBILLO DE ROMERO-SOROZABAL
%   EXCLUIDO (ver "ANOMALIA CONOCIDA" en el encabezado de
%   Romero_Sorozabal2024_Core.m y plan_ensamble_multimodelo.md Sec.2.1-bis):
%   el eje Z (vertical) del ensamble promedia SOLO Koopman/Zhao/Yun (3
%   candidatos, no 4). El eje X (sagital) SI promedia los 4.
%
% RESTRICCION DECLARADA #3 - DESAJUSTE TOBILLO-FIJO vs. DATO REAL (SIN
%   RESOLVER, documentado explicitamente en vez de ocultarse): Koopman/
%   Zhao/Yun modelan la fase de APOYO como rotacion pura del segmento
%   tibial sobre un tobillo FIJO (pendulo invertido, Cadena_Cinematica_Core.m).
%   Romero-Sorozabal, en cambio, da la posicion REAL medida de rodilla y
%   tobillo (su tobillo SI se mueve un poco durante el apoyo, como en la
%   marcha real). Promediar ambos tipos de dato introduce un desajuste de
%   modelado que esta funcion NO resuelve ni oculta - queda como
%   limitacion abierta (candidata a refinarse cuando se conecte la cadena
%   de muslo completa, GUIA_INTERPRETACION.md #5-ter).
%
% Fuente: promedio simple ya justificado en plan_ensamble_multimodelo.md
% Sec.3 (forecast combination puzzle, Clements & Vasnev 2024, HAR de 3
% predictores). Reduccion angulo->posicion: Cadena_Cinematica_Core.m
% (ya construido y probado). Posicion nativa: Romero_Sorozabal2024_Core.m.
% ==========================================================================

if nargin < 3 || isempty(n), n = 101; end

L_tibia_m = antro.long_tibia_m;

% --- Referencia temporal: Koopman (mismo criterio que el candidato por
%     defecto de Generar_Trayectoria.m) ---
[theta_apoyo_koop, theta_balanceo_koop, tempo] = Obtener_Theta_Tibia_Candidato('Koopman', antro, tempo, n);
[theta_apoyo_zhao, theta_balanceo_zhao, ~]      = Obtener_Theta_Tibia_Candidato('Zhao',    antro, tempo, n);
[theta_apoyo_yun,  theta_balanceo_yun,  ~]      = Obtener_Theta_Tibia_Candidato('Yun',     antro, tempo, n);

pct_corte = tempo.frac_apoyo * 100;
pct_ap  = linspace(0, pct_corte, n);
pct_bal = linspace(pct_corte, 100, n);

% Recortar cada candidato a sus ventanas de fase (mismo patron que
% Generar_Trayectoria.m, con el pct_ciclo nativo de CADA candidato -
% Zhao/Koopman/Yun devuelven su propio numero de muestras nativo, no
% necesariamente n)
theta_ap_koop  = recortar_a_fase(theta_apoyo_koop,    pct_ap);
theta_bal_koop = recortar_a_fase(theta_balanceo_koop, pct_bal);
theta_ap_zhao  = recortar_a_fase(theta_apoyo_zhao,    pct_ap);
theta_bal_zhao = recortar_a_fase(theta_balanceo_zhao, pct_bal);
theta_ap_yun   = recortar_a_fase(theta_apoyo_yun,     pct_ap);
theta_bal_yun  = recortar_a_fase(theta_balanceo_yun,  pct_bal);

% --- Posicion (rotacion pura sobre tobillo fijo), rodilla anatomica ---
cc_opts = struct('punto_seguimiento_m', L_tibia_m);
pos_ap_koop  = Cadena_Cinematica_Core(theta_ap_koop,  L_tibia_m, cc_opts);
pos_bal_koop = Cadena_Cinematica_Core(theta_bal_koop, L_tibia_m, cc_opts);
pos_ap_zhao  = Cadena_Cinematica_Core(theta_ap_zhao,  L_tibia_m, cc_opts);
pos_bal_zhao = Cadena_Cinematica_Core(theta_bal_zhao, L_tibia_m, cc_opts);
pos_ap_yun   = Cadena_Cinematica_Core(theta_ap_yun,   L_tibia_m, cc_opts);
pos_bal_yun  = Cadena_Cinematica_Core(theta_bal_yun,  L_tibia_m, cc_opts);

% --- Romero-Sorozabal: rodilla relativa al tobillo (resta pelvis-relativo,
%     cancela la referencia de pelvis), SOLO eje X ---
v_kph_rs = tempo.velocidad_ms * 3.6;
RS = Romero_Sorozabal2024_Core(v_kph_rs, antro.talla_m, struct('nMuestras', n));
x_rodilla_rel_tobillo_m = RS.rodilla.x_m - RS.tobillo.x_m;
pct_rs = RS.rodilla.pct_ciclo;  % 0-100%, mismo pct_ciclo para las 3 articulaciones
x_ap_rs_m  = recortar_a_fase(x_rodilla_rel_tobillo_m, pct_ap,  pct_rs);
x_bal_rs_m = recortar_a_fase(x_rodilla_rel_tobillo_m, pct_bal, pct_rs);
x_ap_rs_cm  = x_ap_rs_m  * 100;
x_bal_rs_cm = x_bal_rs_m * 100;

% --- Promedio simple, peso igual (Sec.3/4 del plan) ---
out = struct();
out.apoyo.x_cm    = mean([pos_ap_koop.x_cm; pos_ap_zhao.x_cm; pos_ap_yun.x_cm; x_ap_rs_cm], 1);
out.apoyo.y_cm     = mean([pos_ap_koop.y_cm; pos_ap_zhao.y_cm; pos_ap_yun.y_cm], 1);
out.balanceo.x_cm = mean([pos_bal_koop.x_cm; pos_bal_zhao.x_cm; pos_bal_yun.x_cm; x_bal_rs_cm], 1);
out.balanceo.y_cm  = mean([pos_bal_koop.y_cm; pos_bal_zhao.y_cm; pos_bal_yun.y_cm], 1);

out.detalle = struct( ...
    'x_koopman_apoyo_cm', pos_ap_koop.x_cm, 'x_zhao_apoyo_cm', pos_ap_zhao.x_cm, ...
    'x_yun_apoyo_cm', pos_ap_yun.x_cm, 'x_romero_apoyo_cm', x_ap_rs_cm, ...
    'x_koopman_balanceo_cm', pos_bal_koop.x_cm, 'x_zhao_balanceo_cm', pos_bal_zhao.x_cm, ...
    'x_yun_balanceo_cm', pos_bal_yun.x_cm, 'x_romero_balanceo_cm', x_bal_rs_cm, ...
    'y_koopman_apoyo_cm', pos_ap_koop.y_cm, 'y_zhao_apoyo_cm', pos_ap_zhao.y_cm, 'y_yun_apoyo_cm', pos_ap_yun.y_cm, ...
    'y_koopman_balanceo_cm', pos_bal_koop.y_cm, 'y_zhao_balanceo_cm', pos_bal_zhao.y_cm, 'y_yun_balanceo_cm', pos_bal_yun.y_cm);

end

% ==========================================================================
function y_recortado = recortar_a_fase(y, pct_destino, pct_fuente)
% Remuestrea y (definido sobre 0-100% nativo del candidato) a los puntos
% pct_destino (ventana de fase ya recortada), via interpolacion pchip -
% mismo metodo que Generar_Trayectoria.m ya usa.
if nargin < 3 || isempty(pct_fuente)
    pct_fuente = linspace(0, 100, numel(y));
end
y_recortado = interp1(pct_fuente, y, pct_destino, 'pchip');
end
