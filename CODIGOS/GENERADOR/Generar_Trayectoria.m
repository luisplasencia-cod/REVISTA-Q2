function out = Generar_Trayectoria(antropometria, opciones)
% GENERAR_TRAYECTORIA  Funcion de contrato del generador (E1 de
%                       plan_100_generador.md, docs/algoritmo/
%                       contrato_generador.md): desde antropometria,
%                       produce la trayectoria de apoyo y balanceo lista
%                       para Escribir_CSV_Simulador.m.
%
% REEMPLAZO COMPLETO (02-sep-2026, pedido explicito del usuario: "la
% exportacion del CSV debe ser el ultimo pipeline que tengo actual en mi
% MATLAB, nada mas, lo anterior ya no me interesa"). Version anterior:
% rotacion de un solo segmento (Cadena_Cinematica_Core.m) + soporte
% multi-candidato (Koopman/Yun/Zhao/Combinado) + correcciones ad-hoc
% (residuo de "rockers" en apoyo, reconstruccion manual de cadera en
% balanceo) - NO era el modelo que el informe tecnico documenta como
% validado. Ahora usa EXCLUSIVAMENTE el pipeline ya validado (el mismo
% que usa App_Animacion_Cadera_Rodilla_Tobillo.m, r=0.999/0.953/0.989 etc.
% contra Kuopio LOSO N=47, ver informe_tecnico_generador.tex):
%   Koopman2014_Core.m (calibrado LOSO, congelar_vl_angulo) ->
%   Cinematica_DoblePendulo_Core.m (cadera->rodilla->tobillo) +
%   Trayectoria_Cadera_Core.m (cadera: avance lineal + doble giba) ->
%   Correccion_Hibrida_PenduloDoble_Core.m (warp+PAVA en X, Fourier en Y).
% Ya no hay parametro `candidato` - Koopman es el unico modelo vigente,
% ganador confirmado en los 3 segmentos (ver CLAUDE.md, banner de pivote;
% comparacion ya cerrada en RODILLA/CIERRE_RODILLA.md, TOBILLO/
% CIERRE_TOBILLO.md, que se conservan como evidencia, no se repiten aqui).
%
%   out = Generar_Trayectoria(antropometria)
%   out = Generar_Trayectoria(antropometria, opciones)
%
% ENTRADA
%   antropometria   struct: .talla_m (obligatorio), .masa_kg, .sexo,
%                   .edad_anios, .long_muslo_m, .long_tibia_m,
%                   .velocidad_ms (todos opcionales - se completan con
%                   Estimar_Antropometria_Core.m / Estimar_Velocidad_
%                   Froude_Core.m si faltan)
%   opciones.punto_seguimiento_m   distancia (m) desde el TOBILLO, a lo
%                   largo del segmento tibial, hasta el punto que se
%                   quiere seguir - default = long_tibia_m (la rodilla
%                   anatomica, extremo del segmento). Misma semantica que
%                   la version anterior (G7-bis, ver GUIA_INTERPRETACION.md
%                   #3-quinquies) - motivo: el marcador/sensor real de
%                   Control_apoyo_Luis_V4.csv no esta en la rodilla exacta,
%                   sino a una distancia del tobillo dada por el montaje
%                   fisico del equipo. Calculado con Aplicar_Punto_
%                   Montaje_Core.m (misma formula geometrica que antes
%                   vivia en Cadena_Cinematica_Core.m, aplicada ahora
%                   sobre el tobillo/angulo tibial del pendulo doble).
%
% SALIDA: struct `out`
%   .apoyo.t_s, .apoyo.x_cm, .apoyo.y_cm, .apoyo.angulo_deg
%   .balanceo.t_s, .balanceo.x_cm, .balanceo.y_cm, .balanceo.angulo_deg
%   .metadatos: antropometria completa (con fuentes), temporizacion
%               completa, punto_seguimiento_m usado
%
% Amplitud horizontal: 100% anatomica, SIN recorte (decision D1 de
% plan_100_generador.md #3). El ajuste a los limites reales del banco es
% tarea de la ETAPA DE EJECUCION, fuera de esta funcion.
%
% CONVENCION DE SIGNO PARA EL CSV REAL - VERIFICADO EMPIRICAMENTE
% (02-sep-2026, Verificar_Signo_X_PenduloDoble.m), NO POR ANALOGIA CON
% Cadena_Cinematica_Core.m/G7: la inversion de X que G7 encontro necesaria
% se verifico sobre una formula de rotacion PURA alrededor de un tobillo
% fijo (sin avance de cadera mezclado en el numero) - este pipeline nuevo
% SUMA el avance de cadera (siempre creciente) dentro de la misma
% coordenada X (Cinematica_DoblePendulo_Core.m: Xa = Xh + L1*sin(theta1) +
% L2*sin(theta2)), asi que la regla de G7 NO se traspasa por analogia.
% Verificado de nuevo con el mismo metodo (correlacion angulo-vs-posicion
% contra Control_apoyo_Luis_V4.csv real): NI X NI Y necesitan inversion con
% este pipeline (mismo signo de correlacion en ambos ejes, y magnitud de
% avance en X consistente: real=44.27cm vs. generado=42.97cm para
% talla=1.73m) - ver el bloque de codigo mas abajo para el detalle
% numerico completo de esta verificacion.
% ==========================================================================

if nargin < 1 || ~isstruct(antropometria) || ~isfield(antropometria,'talla_m')
    error('antropometria debe ser un struct con al menos el campo talla_m.');
end
if nargin < 2, opciones = struct(); end

n = 101;  % puntos por ciclo (0-100%), mismo grid que Koopman2014_Core/la app

% --- Antropometria y temporizacion (E3/E4, sin cambios) ---
antro = Estimar_Antropometria_Core(antropometria);
tempo = Temporizacion_Core(antro, 'Koopman');

L_tibia_m = antro.long_tibia_m;
% usar_rodilla_directa (03-sep-2026): el default "rodilla anatomica" pide
% el PUNTO rodilla, no una distancia d=L_tibia_m sobre el segmento
% corregido - despues de la correccion hibrida el segmento real puede
% medir MENOS que L_tibia_m en algun instante del ciclo (se desvia hasta
% 5.2%), asi que pedir d=L_tibia_m como distancia podia fallar la
% validacion de rango de Aplicar_Punto_Montaje_Core.m aunque "la rodilla"
% siempre existe trivialmente (es uno de los dos puntos de entrada). Se
% resuelve al nivel de la semantica, no relajando la validacion.
if ~isfield(opciones,'punto_seguimiento_m') || isempty(opciones.punto_seguimiento_m)
    punto_seguimiento_m = L_tibia_m;  % default: rodilla anatomica
else
    punto_seguimiento_m = opciones.punto_seguimiento_m;
end
% pedir la rodilla explicitamente (punto_seguimiento_m == L_tibia_m, con
% margen de punto flotante) tiene que dar EXACTAMENTE lo mismo que el
% default - no solo cuando se omite el campo.
usar_rodilla_directa = abs(punto_seguimiento_m - L_tibia_m) < 1e-9;

pct = linspace(0, 100, n);

% --- Angulos: Koopman calibrado (LOSO + congelar_vl_angulo), IDENTICO a
% App_Animacion_Cadera_Rodilla_Tobillo.m con ambos checkboxes activos (el
% unico camino ya validado contra Kuopio/Maastricht, ver GUIA #10) ---
K = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, ...
    struct('nMuestras', n, 'congelar_vl_angulo', true, 'v_ref_kph', 5.0, 'l_ref_m', 1.735));

theta1_full = deg2rad(K.cadera_flexext.angulo_deg(:).');       % muslo
theta2_full = K.theta_tibia_via_rodilla_rad(:).';               % tibia

cal = Calibracion_Koopman_Kuopio_Core();
theta1_full = deg2rad(cal.off_muslo_deg) + cal.gan_muslo * theta1_full;
theta2_full = deg2rad(cal.off_tibia_deg) + cal.gan_tibia * theta2_full;

% --- Cinematica directa: cadera (avance lineal + doble giba vertical) +
% pendulo doble cadera->rodilla->tobillo ---
L1_cm = antro.long_muslo_m * 100;
L2_cm = antro.long_tibia_m * 100;
A_cm  = 2.25;  % amplitud vertical de cadera, default de literatura (Trayectoria_Cadera_Core.m)
zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;

cad = Trayectoria_Cadera_Core(pct, zancada_cm, A_cm, 0);
Xh_full = cad.Xh_cm; Yh_full = cad.Yh_cm;

pos = Cinematica_DoblePendulo_Core(theta1_full, theta2_full, L1_cm, L2_cm, Xh_full, Yh_full);
Xk_full = pos.Xk; Yk_full = pos.Yk;
Xa_full = pos.Xa; Ya_full = pos.Ya;

% --- Correccion hibrida de produccion (warp+PAVA en X, Fourier en Y) -
% opera sobre la posicion normalizada a (0,0) en t=0, igual que la app ---
Xk_n = Xk_full - Xk_full(1); Yk_n = Yk_full - Yk_full(1);
Xa_n = Xa_full - Xa_full(1); Ya_n = Ya_full - Ya_full(1);
corr = Correccion_Hibrida_PenduloDoble_Core(pct, Xk_n, Yk_n, Xa_n, Ya_n, tempo.velocidad_ms);
Xk_full = Xk_full + (corr.Xk - Xk_n);
Yk_full = Yk_full + (corr.Yk - Yk_n);
Xa_full = Xa_full + (corr.Xa - Xa_n);
Ya_full = Ya_full + (corr.Ya - Ya_n);

% --- Punto de seguimiento (G7-bis): tobillo, rodilla, o cualquier punto
% intermedio del segmento tobillo-rodilla YA corregidos - misma logica de
% Aplicar_Punto_Montaje_Core.m ya usada por la app.
%
% FIRMA CORREGIDA 03-sep-2026 (Aplicar_Punto_Montaje_Core.m cambio de firma
% el mismo dia): ya NO se usa theta2_full (el angulo del MODELO) como
% direccion - se usa el vector tobillo->rodilla de los puntos YA
% corregidos (Xa_full/Ya_full, Xk_full/Yk_full). Motivo: tras la
% correccion hibrida el segmento ya no mide L_tibia ni apunta en direccion
% theta2_full (se desvia hasta 5.2%/7.6 grados, informe tecnico
% Limitaciones) - con la formula vieja el punto quedaba fuera del segmento
% hasta 2.5cm. Con el vector real, la distancia d y "sobre el segmento" se
% cumplen las dos EXACTAS, sin importar que el segmento ya no sea rigido
% (Test_Punto_Montaje.m Test 7, 8/8 pruebas). Ver GUIA_INTERPRETACION.md #12-bis.
if usar_rodilla_directa
    % la rodilla siempre existe (es uno de los dos puntos de entrada) -
    % no pasa por la validacion de distancia, que compara contra L_tibia
    % NOMINAL y puede ser mas larga que el segmento YA corregido en algun
    % instante (ver nota arriba).
    Xp_full = Xk_full; Yp_full = Yk_full;
else
    d_cm = punto_seguimiento_m * 100;
    pm = Aplicar_Punto_Montaje_Core(Xa_full, Ya_full, Xk_full, Yk_full, d_cm);
    Xp_full = pm.Xm_cm; Yp_full = pm.Ym_cm;
end

% --- Signo de X/Y para el CSV real: VERIFICADO EMPIRICAMENTE (02-sep-2026,
% Verificar_Signo_X_PenduloDoble.m, mismo metodo que el G7 original de
% Cadena_Cinematica_Core.m: correlacion angulo-vs-posicion contra Control_
% apoyo_Luis_V4.csv real, 95 filas validas) - NO se asumio por analogia con
% Cadena_Cinematica_Core.m. La inversion de X de G7 se verifico sobre una
% formula de rotacion PURA alrededor de un tobillo fijo (sin avance de
% cadera mezclado); este pipeline nuevo suma el avance de cadera (Xh,
% siempre creciente) DENTRO de la misma coordenada X (Cinematica_
% DoblePendulo_Core.m: Xa = Xh + L1*sin(theta1) + L2*sin(theta2)) - invertir
% "todo X" aqui invertiria tambien ese avance (de creciente a decreciente,
% lo opuesto de lo que el CSV real registra). Resultado de la verificacion:
% corr(ang,X) real=-0.993 vs. generado SIN invertir=-0.998 (mismo signo);
% corr(ang,Y) real=+0.529 vs. generado SIN invertir=+0.928 (mismo signo);
% avance neto de X en apoyo: real=44.27cm vs. generado=42.97cm (magnitud
% consistente, no solo el signo). CONCLUSION: NO se invierte X ni Y con
% este pipeline - ninguna de las dos coordenadas necesita el ajuste de
% signo que si necesitaba el modelo de rotacion pura anterior.
theta_deg_full = rad2deg(theta2_full);  % angulo exportado = angulo del segmento seguido (tibia)

% --- Particion apoyo/balanceo (mismo criterio que la version anterior) ---
pct_corte = tempo.frac_apoyo * 100;
pct_ap  = linspace(0, pct_corte, n);
pct_bal = linspace(pct_corte, 100, n);

x_ap  = interp1(pct, Xp_full, pct_ap, 'pchip');
y_ap  = interp1(pct, Yp_full, pct_ap, 'pchip');
ang_ap = interp1(pct, theta_deg_full, pct_ap, 'pchip');

x_bal  = interp1(pct, Xp_full, pct_bal, 'pchip');
y_bal  = interp1(pct, Yp_full, pct_bal, 'pchip');
ang_bal = interp1(pct, theta_deg_full, pct_bal, 'pchip');

% --- Ensamblar salida (MISMO contrato de formato que la version anterior,
% no se toca): apoyo normalizado a (0,0) en su 1ra muestra; balanceo
% CONTINUA donde termino el apoyo (evita el salto artificial en el cambio
% de fase, decision del 24-ago-2026, ver historial) ---
out = struct();
out.apoyo.t_s       = linspace(0, tempo.tiempo_apoyo_s, n);
out.apoyo.x_cm       = x_ap - x_ap(1);
out.apoyo.y_cm       = y_ap - y_ap(1);
out.apoyo.angulo_deg = ang_ap;

out.balanceo.t_s       = linspace(0, tempo.tiempo_balanceo_s, n);
out.balanceo.x_cm       = (x_bal - x_bal(1)) + out.apoyo.x_cm(end);
out.balanceo.y_cm       = (y_bal - y_bal(1)) + out.apoyo.y_cm(end);
out.balanceo.angulo_deg = ang_bal;

out.metadatos = struct('antropometria', antro, 'temporizacion', tempo, ...
    'punto_seguimiento_m', punto_seguimiento_m);

end
