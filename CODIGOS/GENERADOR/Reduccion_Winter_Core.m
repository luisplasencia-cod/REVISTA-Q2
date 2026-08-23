function out = Reduccion_Winter_Core(entrada)
% REDUCCION_WINTER_CORE  Relacion clasica angulo relativo (articular) <->
%                        angulo absoluto (de segmento), aplicada al
%                        segmento tibial. Respaldo bibliografico: Winter,
%                        "Biomechanics and Motor Control of Human
%                        Movement" (ver docs/planificacion/
%                        analisis_escalamiento_Q1_generador_trayectorias.md
%                        #5-bis) y OpenSim como referencia metodologica
%                        establecida del campo.
%
%                        theta_tibia = theta_muslo  -+ phi_rodilla   (via rodilla)
%                        theta_tibia = theta_pie    +- phi_tobillo   (via tobillo)
%
%                        Cuando se conocen ambos caminos (p.ej. con la
%                        salida de Yun 2014, que da cadera+rodilla+tobillo
%                        - ver Yun2014_Wrapper.m), esta funcion calcula
%                        los dos y los cruza como chequeo de consistencia
%                        interno, gratis, antes de comparar contra ninguna
%                        base de datos externa (docs/algoritmo/
%                        diseno_matematico_generador.md #5).
%
%   out = Reduccion_Winter_Core(entrada)
%
% ENTRADA: struct `entrada`, con AL MENOS UNO de los dos caminos:
%   Camino rodilla (opcional):
%     .theta_muslo_rad     angulo absoluto del muslo (rad), [1 x n]
%     .phi_rodilla_rad     angulo relativo de rodilla (rad), [1 x n]
%     .signo_rodilla       +1 o -1 (default -1, convencion Zhao: theta_tibia = theta_muslo - phi_rodilla)
%   Camino tobillo (opcional):
%     .theta_pie_rad       angulo absoluto del pie (rad), [1 x n]. Si no
%                          se mide, usar el supuesto de pie plano en
%                          apoyo (theta_pie = 0) - declarar como supuesto,
%                          no dato medido (ver GUIA_INTERPRETACION.md).
%     .phi_tobillo_rad     angulo relativo de tobillo/plantarflexion (rad), [1 x n]
%     .signo_tobillo       +1 o -1 (default +1)
%
% SALIDA: struct `out`
%   .theta_tibia_via_rodilla_rad   (solo si se dio el camino rodilla)
%   .theta_tibia_via_tobillo_rad   (solo si se dio el camino tobillo)
%   .diferencia_rad                via_rodilla - via_tobillo, punto a
%                                   punto (solo si AMBOS caminos estan
%                                   presentes)
%   .diferencia_max_abs_deg        max(abs(diferencia)) en grados -
%                                   metrica resumen del chequeo cruzado
%   .caminos_usados                cell array, cuales caminos se calcularon
%
% Nota de signos: los signos por defecto siguen la convencion que Zhao
% 2026 deja explicita en su seccion 2.6 para el camino rodilla
% (theta_cadera = phi_cadera; theta_rodilla = theta_cadera - phi_rodilla).
% NO hay verificacion a texto completo todavia de que el mismo signo
% aplique al camino tobillo, ni de que la convencion de "Hip
% Extension"/"Knee Flexion"/"Ankle P.flex." de Yun 2014 coincida con la de
% Zhao - por eso ambos signos son parametros explicitos, no supuestos
% ocultos. Confirmar antes de usar esto contra datos reales.
% ==========================================================================

if nargin < 1 || ~isstruct(entrada)
    error('Se requiere un struct de entrada. Ver ayuda de esta funcion (help Reduccion_Winter_Core).');
end

tiene_rodilla = isfield(entrada,'theta_muslo_rad') && isfield(entrada,'phi_rodilla_rad');
tiene_tobillo = isfield(entrada,'theta_pie_rad') && isfield(entrada,'phi_tobillo_rad');

if ~tiene_rodilla && ~tiene_tobillo
    error(['Se necesita al menos un camino completo: ' ...
           '(theta_muslo_rad + phi_rodilla_rad) o (theta_pie_rad + phi_tobillo_rad).']);
end

out = struct();
out.caminos_usados = {};

if tiene_rodilla
    signo_rodilla = -1;
    if isfield(entrada,'signo_rodilla'), signo_rodilla = entrada.signo_rodilla; end
    if ~ismember(signo_rodilla, [1,-1])
        error('signo_rodilla debe ser +1 o -1. Se recibio: %s', mat2str(signo_rodilla));
    end
    out.theta_tibia_via_rodilla_rad = entrada.theta_muslo_rad + signo_rodilla*entrada.phi_rodilla_rad;
    out.caminos_usados{end+1} = 'rodilla';
end

if tiene_tobillo
    signo_tobillo = 1;
    if isfield(entrada,'signo_tobillo'), signo_tobillo = entrada.signo_tobillo; end
    if ~ismember(signo_tobillo, [1,-1])
        error('signo_tobillo debe ser +1 o -1. Se recibio: %s', mat2str(signo_tobillo));
    end
    out.theta_tibia_via_tobillo_rad = entrada.theta_pie_rad + signo_tobillo*entrada.phi_tobillo_rad;
    out.caminos_usados{end+1} = 'tobillo';
end

if tiene_rodilla && tiene_tobillo
    if numel(out.theta_tibia_via_rodilla_rad) ~= numel(out.theta_tibia_via_tobillo_rad)
        error('Los dos caminos tienen distinto numero de muestras (%d vs %d) - no se pueden cruzar punto a punto.', ...
              numel(out.theta_tibia_via_rodilla_rad), numel(out.theta_tibia_via_tobillo_rad));
    end
    out.diferencia_rad = out.theta_tibia_via_rodilla_rad - out.theta_tibia_via_tobillo_rad;
    out.diferencia_max_abs_deg = max(abs(rad2deg(out.diferencia_rad)));
end

end
