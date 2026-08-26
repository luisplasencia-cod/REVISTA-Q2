function [theta_apoyo_rad, theta_balanceo_rad, tempo] = Obtener_Theta_Tibia_Candidato(candidato, antro, tempo, n)
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
%
% Fuente: misma logica exacta que tenia el switch-case de
% Generar_Trayectoria.m (E2 de plan_100_generador.md) - solo se movio de
% archivo, no se cambio ningun coeficiente ni regla.
% ==========================================================================

if ~any(strcmpi(candidato, {'Koopman','Yun','Zhao'}))
    error('candidato debe ser ''Koopman'', ''Yun'' o ''Zhao''. Se recibio: %s', mat2str(candidato));
end

switch lower(candidato)
    case 'koopman'
        v_kph = tempo.velocidad_ms * 3.6;
        K = Koopman2014_Core(v_kph, antro.talla_m, struct('nMuestras', n));
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

    case 'zhao'
        f_zancada = 1 / tempo.tiempo_ciclo_s;
        Z = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, f_zancada, struct('nMuestras', n));
        theta_apoyo_rad    = Z.theta_tibia_rad;
        theta_balanceo_rad = Z.theta_tibia_rad;

    case 'yun'
        p14 = vector14_desde_antropometria(antro);
        Y = Yun2014_Wrapper(p14);
        theta_apoyo_rad    = Y.theta_tibia_via_tobillo_R_rad;
        theta_balanceo_rad = Y.theta_tibia_via_tobillo_R_rad;  % via_rodilla marcada no confiable, E2
        tempo.tiempo_ciclo_s = Y.periodo_s;  % periodo propio del toolbox
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
