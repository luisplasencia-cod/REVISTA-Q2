function [theta_apoyo_rad, theta_balanceo_rad, tempo, theta_muslo_apoyo_rad, theta_muslo_balanceo_rad] = Obtener_Theta_Tibia_Candidato(candidato, antro, tempo, n, opciones)
% OBTENER_THETA_TIBIA_CANDIDATO  Corre UN candidato (Koopman/Zhao/Yun) y
%                     devuelve theta_tibia(t) por fase, aplicando la regla
%                     E2 de que "camino" usar por candidato y por fase
%                     (GUIA_INTERPRETACION.md #3-bis). Extraido de
%                     Generar_Trayectoria.m (24-ago-2026, sesion de
%                     continuacion de plan_ensamble_multimodelo.md) para
%                     que Combinar_Candidatos_Core.m pueda reusar
%                     EXACTAMENTE la misma regla por candidato sin
%                     duplicarla - si la regla E2 cambia, se cambia en un
%                     solo lugar.
%
%   [theta_apoyo_rad, theta_balanceo_rad, tempo] = ...
%       Obtener_Theta_Tibia_Candidato(candidato, antro, tempo, n)
%
% ENTRADA
%   candidato   'Koopman' | 'Zhao' | 'Yun' (no 'Combinado' - eso lo maneja
%               Combinar_Candidatos_Core.m, no esta funcion)
%   antro       antropometria ya completada (salida de Estimar_Antropometria_Core.m)
%   tempo       temporizacion ya calculada (salida de Temporizacion_Core.m) -
%               esta funcion puede sobreescribir tempo.tiempo_ciclo_s con
%               el propio del candidato (Koopman/Yun tienen su propio
%               motor de tiempo de ciclo, mismo comportamiento que ya
%               tenia Generar_Trayectoria.m)
%   n           puntos por fase (mismo remuestreo que el resto del proyecto)
%
% SALIDA
%   theta_apoyo_rad, theta_balanceo_rad   [1 x n_nativo del candidato]
%                     (SIN recortar/remuestrear a la ventana de fase final -
%                     eso lo sigue haciendo el llamador, igual que antes)
%   tempo             tempo de entrada, con .tiempo_ciclo_s posiblemente
%                     actualizado al valor propio del candidato
%   theta_muslo_apoyo_rad, theta_muslo_balanceo_rad   (NUEVO 28-ago-2026,
%                     opcionales - un llamador con nargout<=3 no los recibe
%                     y no paga costo extra) angulo de cadera/muslo, misma
%                     fuente y "via" que usa Obtener_Angulos_Candidato.m,
%                     extraido del MISMO K/Z/Y ya calculado para la tibia -
%                     evita la 2da llamada al modelo del candidato que
%                     GRF_Newton_ApoyoSimple_Core.m necesitaba antes (H8,
%                     _REVISION/detalle/03_codigo.md, 28-ago-2026). SIN
%                     recortar a fase, igual que los otros dos.
%
% Fuente: misma logica exacta que tenia el switch-case de
% Generar_Trayectoria.m (E2 de plan_100_generador.md) - solo se movio de
% archivo, no se cambio ningun coeficiente ni regla.
% ==========================================================================

if ~any(strcmpi(candidato, {'Koopman','Yun','Zhao'}))
    error('candidato debe ser ''Koopman'', ''Yun'' o ''Zhao''. Se recibio: %s', mat2str(candidato));
end
if nargin < 5 || isempty(opciones), opciones = struct(); end
if ~isfield(opciones,'calibrar_koopman'), opciones.calibrar_koopman = false; end
if opciones.calibrar_koopman && ~strcmpi(candidato,'koopman')
    warning('Obtener_Theta_Tibia_Candidato:calibracionNoAplicable', ...
        'opciones.calibrar_koopman=true pedido con candidato=''%s'' - la calibracion afin (Calibracion_Koopman_Kuopio_Core.m) solo se derivo para Koopman, se ignora para este candidato.', candidato);
end
% CONGELAR_VL_ANGULO (02-sep-2026): default TRUE aqui (esta funcion es la
% que usa el pipeline de PRODUCCION, Generar_Trayectoria.m/la app) -
% Koopman2014_Core.m mismo mantiene su default en false para no alterar
% scripts de comparacion de candidatos (Evaluar_vs_Maastricht.m y
% similares, que necesitan el comportamiento nativo del paper). Motivo:
% verificado (Kuopio N=47 + Maastricht N=244, ver informe tecnico,
% Limitaciones) que evaluar Koopman con la v/talla REALES de cada sujeto
% produce una dependencia con talla que NO existe en el dato real
% (|corr(talla,real)|<=0.08, contra |corr(talla,crudo)| hasta 0.99) - la
% talla real sigue entrando al generador, pero solo por la via geometrica
% ya validada (Paso 4, escalamiento de L_muslo/L_tibia), no por los
% coeficientes de v/l de Koopman. Verificado SIN degradar ninguna metrica
% ya publicada (Rodilla X/Y, Tobillo X/Y, Angulo tibial - clasificacion
% RMSEnorm identica en las 5, Bueno/Excelente en todas, diferencias <0.06).
if ~isfield(opciones,'congelar_vl_angulo'), opciones.congelar_vl_angulo = true; end
if ~isfield(opciones,'v_ref_kph'), opciones.v_ref_kph = 5.0; end
if ~isfield(opciones,'l_ref_m'), opciones.l_ref_m = 1.735; end
opciones_koopman = struct('nMuestras', n, 'congelar_vl_angulo', opciones.congelar_vl_angulo, ...
    'v_ref_kph', opciones.v_ref_kph, 'l_ref_m', opciones.l_ref_m);

switch lower(candidato)
    case 'koopman'
        v_kph = tempo.velocidad_ms * 3.6;
        K = Koopman2014_Core(v_kph, antro.talla_m, opciones_koopman);
        % CORREGIDO 24-ago-2026 (Comparar_Caminos_vs_ControlLuis.m, con
        % dato PROPIO del proyecto - REFERENCIAS/Control_apoyo_Luis_V4.csv
        % + Control_balanceo_Luis_V4.csv, NO Camargo, que queda reservado
        % para la validacion externa final):
        % ANTES: via_tobillo en apoyo, via_rodilla en balanceo (regla E2
        % original). Eso producia (a) un salto de ~37 deg del angulo en el
        % cambio de fase, y (b) por herencia, un escalon vertical
        % fisicamente imposible en la posicion del tobillo.
        % EVIDENCIA: contra el ciclo completo real de Control_Luis,
        %   via rodilla: r=0.982, RMSE=5.4 deg, rango 79 deg
        %   via tobillo: r=-0.435 (correlacion NEGATIVA), RMSE=26.8 deg,
        %                rango 27 deg (el real es ~60-67 deg)
        % via_tobillo no solo es peor: va en sentido contrario durante el
        % balanceo. Se usa via_rodilla en AMBAS fases - ademas de ser mas
        % fiel, elimina el salto de raiz al no empalmar dos curvas
        % distintas. El dato real igual tiene un salto propio de ~4.9 deg
        % en el cambio de fase, asi que un salto pequeno ahi es normal.
        %
        % TRADE-OFF DECLARADO (Test 15 de Test_Generador_Trayectoria.m
        % FALLA a proposito tras este cambio - NO se ajusto el test para
        % taparlo): contra Control_apoyo_Luis_V4.csv real, este cambio
        %   MEJORA  corr(angulo, X): -0.89 -> -0.99 (real: -0.99, casi exacto)
        %   EMPEORA corr(angulo, Y): +0.45 -> -0.03 (real: +0.53)
        % CAUSA (no es un bug del cambio, lo hace VISIBLE): con el modelo
        % de pendulo de tobillo fijo, Y = L*cos(theta), que es una funcion
        % PAR - simetrica alrededor de theta=0. Con via_tobillo el rango de
        % theta en apoyo era chico (~0..-9 deg, todo del mismo lado del
        % cero), asi que cos() salia monotono y correlacionaba. Con
        % via_rodilla el rango real es mucho mayor (+30..-35 deg) y CRUZA
        % el cero, con lo que la correlacion lineal con theta se anula por
        % simetria. El dato real, en cambio, SI correlaciona (+0.53)
        % aunque su angulo tambien cruza el cero (+15..-44) - o sea, la Y
        % real NO se comporta como un pendulo puro sobre tobillo fijo.
        % Es la MISMA causa raiz de las otras dos limitaciones abiertas
        % (altura del tobillo constante durante el balanceo, y el bucle en
        % la vista sagital): falta la cadena de muslo completa (GUIA
        % #5-ter), que modelaria el avance/elevacion real en vez de asumir
        % un pivote rigido. Resolver eso es lo que arregla los tres a la
        % vez - PENDIENTE, decision de modelado del usuario, no se inventa
        % aqui una correccion de Y sin respaldo.
        theta_apoyo_rad    = K.theta_tibia_via_rodilla_rad;
        theta_balanceo_rad = K.theta_tibia_via_rodilla_rad;
        tempo.tiempo_ciclo_s = K.tiempo_ciclo_s;  % usa el propio de Koopman (consistente)
        m_full = deg2rad(K.cadera_flexext.angulo_deg);  % ver nota theta_muslo_* abajo

    case 'zhao'
        f_zancada = 1 / tempo.tiempo_ciclo_s;
        Z = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, f_zancada, struct('nMuestras', n));
        theta_apoyo_rad    = Z.theta_tibia_rad;
        theta_balanceo_rad = Z.theta_tibia_rad;
        m_full = Z.phi_cadera_rad;

    case 'yun'
        p14 = vector14_desde_antropometria(antro);
        Y = Yun2014_Wrapper(p14);
        theta_apoyo_rad    = Y.theta_tibia_via_tobillo_R_rad;
        theta_balanceo_rad = Y.theta_tibia_via_tobillo_R_rad;  % via_rodilla marcada no confiable, E2
        tempo.tiempo_ciclo_s = Y.periodo_s;  % periodo propio del toolbox
        m_full = deg2rad(Y.R_hip_extension.mean);
end

% theta_muslo_apoyo_rad/theta_muslo_balanceo_rad (NUEVO 28-ago-2026, H8 de
% _REVISION/detalle/03_codigo.md): mismo angulo de cadera/muslo que ya
% calcula Obtener_Angulos_Candidato.m (identica fuente por candidato:
% K.cadera_flexext.angulo_deg / Z.phi_cadera_rad / Y.R_hip_extension.mean),
% extraido aqui del MISMO K/Z/Y ya calculado arriba para theta_tibia - CERO
% llamadas nuevas al modelo del candidato. Se devuelve SIN recortar a fase
% (mismo patron que theta_apoyo_rad/theta_balanceo_rad de esta funcion: el
% llamador recorta con su propio pct_ap/pct_bal). Un llamador que solo pide
% los primeros 3 outputs (todo el codigo existente antes de hoy) no paga
% ningun costo extra - estas 2 lineas ya se ejecutaban para theta_tibia,
% solo se expone tambien el dato de muslo que ya estaba en memoria.
theta_muslo_apoyo_rad    = m_full;
theta_muslo_balanceo_rad = m_full;

% --- Calibracion afin LOSO->agrupada, SOLO Koopman, SOLO si se pide
% (28-ago-2026, ver Calibracion_Koopman_Kuopio_Core.m para la trazabilidad
% completa) - se aplica DESPUES de fijar theta_apoyo/balanceo/muslo, sobre
% el angulo (no la posicion), consistente con el hallazgo de PIPELINE_
% KOOPMAN_KUOPIO.md Sec.5.2. Comportamiento DEFAULT sin cambios (calibrar_
% koopman=false) - los scripts de evaluacion existentes (TOBILLO/RODILLA/
% INCLINACION_TIBIAL, que hacen su PROPIA calibracion LOSO para validar)
% siguen recibiendo el angulo crudo tal como antes, sin doble-calibrar.
if opciones.calibrar_koopman && strcmpi(candidato,'koopman')
    cal = Calibracion_Koopman_Kuopio_Core();
    theta_apoyo_rad    = deg2rad(cal.off_tibia_deg) + cal.gan_tibia * theta_apoyo_rad;
    theta_balanceo_rad = deg2rad(cal.off_tibia_deg) + cal.gan_tibia * theta_balanceo_rad;
    theta_muslo_apoyo_rad    = deg2rad(cal.off_muslo_deg) + cal.gan_muslo * theta_muslo_apoyo_rad;
    theta_muslo_balanceo_rad = deg2rad(cal.off_muslo_deg) + cal.gan_muslo * theta_muslo_balanceo_rad;
end

end

% ==========================================================================
function p14 = vector14_desde_antropometria(antro)
% Identico al helper local que tenia Generar_Trayectoria.m - ver ahi para
% la nota completa sobre los defaults del demo del toolbox de Yun.
if ~isfield(antro,'edad_anios') || isempty(antro.edad_anios), antro.edad_anios = 25; end
if ~isfield(antro,'sexo'), antro.sexo = 'M'; end
sexo01 = double(upper(antro.sexo(1)) == 'M');

talla_cm = antro.talla_m * 100;
muslo_cm = antro.long_muslo_m * 100;
tibia_cm = antro.long_tibia_m * 100;
pie_cm   = antro.long_pie_m   * 100;

p14 = [antro.edad_anios, talla_cm, antro.masa_kg, sexo01, ...
       muslo_cm, tibia_cm, ...
       32.8, 29.7, 25.5, ...    % anchos bitrocantereo/biiliaco/ASIS (default demo)
       10, ...                  % diametro de rodilla (default demo)
       pie_cm, ...
       7.30, 7.10, 9.80];       % altura/ancho maleolo, ancho pie (default demo)
end
