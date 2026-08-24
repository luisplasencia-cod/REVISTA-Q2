function out = Temporizacion_Core(antropometria, candidato, opciones)
% TEMPORIZACION_CORE  Calcula la temporizacion real del ciclo de marcha
%                      generado desde antropometria: velocidad (D2:
%                      derivada por defecto, medida si se da), duracion
%                      de ciclo, y particion apoyo/balanceo. E4 de
%                      plan_100_generador.md.
%
%   out = Temporizacion_Core(antropometria, candidato)
%   out = Temporizacion_Core(antropometria, candidato, opciones)
%
% ENTRADA
%   antropometria   struct con AL MENOS .talla_m. Si trae .velocidad_ms,
%                   ese valor tiene prioridad sobre la estimacion (regla
%                   del contrato: medido > estimado).
%   candidato       'Yun' | 'Koopman' | 'Zhao' - determina de donde sale
%                   la duracion del ciclo:
%                     'Yun'     -> periodo propio del toolbox (GPR,
%                                  ya predicho internamente, no necesita
%                                  velocidad como entrada separada)
%                     'Koopman' -> Tiempo_Ciclo_Koopman2014_Core.m
%                                  (Ec.3 del paper, necesita v+talla)
%                     'Zhao'    -> Zhao2026_Core.m necesita cadencia
%                                  (zancadas/s) como entrada; se deriva
%                                  con la MISMA regresion de Koopman
%                                  (Tiempo_Ciclo_Koopman2014_Core.m) por
%                                  ser una relacion general de tiempo de
%                                  paso desde v+talla, no especifica de
%                                  las curvas articulares de Koopman -
%                                  Zhao 2026 no publica su propia
%                                  regresion de duracion de ciclo (solo
%                                  toma la cadencia como dato de entrada
%                                  ya conocido, ver Zhao2026_Core.m).
%   opciones.frac_apoyo   fraccion del ciclo en apoyo (default 0.60 -
%                  verificado: 60% apoyo / 40% balanceo es el valor
%                  estandar de marcha normal, citado consistentemente en
%                  Perry & Burnfield "Gait Analysis: Normal and
%                  Pathological Function" y coincidente en multiples
%                  fuentes independientes de la literatura de marcha).
%
% SALIDA: struct `out`
%   .velocidad_ms, .fuente_velocidad ('medida'|'estimada_Froude')
%   .tiempo_ciclo_s, .fuente_tiempo_ciclo
%   .tiempo_apoyo_s, .tiempo_balanceo_s, .frac_apoyo
%
% Fuentes: Estimar_Velocidad_Froude_Core.m (Froude, Alexander/Raichlen),
% Tiempo_Ciclo_Koopman2014_Core.m (Koopman 2014 Tabla 5/Ec.3), Yun2014
% (periodo propio del toolbox), Perry & Burnfield (60/40 apoyo/balanceo).
% ==========================================================================

if nargin < 1 || ~isstruct(antropometria) || ~isfield(antropometria,'talla_m')
    error('antropometria debe ser un struct con al menos el campo talla_m.');
end
if nargin < 2 || ~any(strcmpi(candidato, {'Yun','Koopman','Zhao'}))
    error('candidato debe ser ''Yun'', ''Koopman'' o ''Zhao''. Se recibio: %s', mat2str(candidato));
end
if nargin < 3, opciones = struct(); end
if ~isfield(opciones,'frac_apoyo'), opciones.frac_apoyo = 0.60; end

out = struct();

% --- Velocidad: medida tiene prioridad sobre estimada (D2) ---
if isfield(antropometria,'velocidad_ms') && ~isempty(antropometria.velocidad_ms)
    out.velocidad_ms = antropometria.velocidad_ms;
    out.fuente_velocidad = 'medida';
else
    out.velocidad_ms = Estimar_Velocidad_Froude_Core(antropometria.talla_m);
    out.fuente_velocidad = 'estimada_Froude';
end
v_kph = out.velocidad_ms * 3.6;

% --- Duracion de ciclo: depende del candidato ---
switch lower(candidato)
    case 'yun'
        % El periodo se obtiene corriendo Yun2014_Wrapper por separado
        % (necesita el vector completo de 14 parametros, no solo
        % talla+velocidad) - aqui se deja como NaN y el llamador (E5/E8)
        % debe tomar out.periodo_s de Yun2014_Wrapper directamente.
        out.tiempo_ciclo_s = NaN;
        out.fuente_tiempo_ciclo = 'usar_periodo_s_de_Yun2014_Wrapper';
    case 'koopman'
        out.tiempo_ciclo_s = Tiempo_Ciclo_Koopman2014_Core(v_kph, antropometria.talla_m);
        out.fuente_tiempo_ciclo = 'Koopman2014_Ec3';
    case 'zhao'
        out.tiempo_ciclo_s = Tiempo_Ciclo_Koopman2014_Core(v_kph, antropometria.talla_m);
        out.fuente_tiempo_ciclo = 'Koopman2014_Ec3_reusada_para_Zhao';
end

% --- Particion apoyo/balanceo ---
out.frac_apoyo = opciones.frac_apoyo;
if ~isnan(out.tiempo_ciclo_s)
    out.tiempo_apoyo_s = out.frac_apoyo * out.tiempo_ciclo_s;
    out.tiempo_balanceo_s = (1 - out.frac_apoyo) * out.tiempo_ciclo_s;
else
    out.tiempo_apoyo_s = NaN;
    out.tiempo_balanceo_s = NaN;
end

end
