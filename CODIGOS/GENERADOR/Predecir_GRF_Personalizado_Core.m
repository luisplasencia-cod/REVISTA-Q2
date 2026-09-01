function out = Predecir_GRF_Personalizado_Core(antropometria, modelo)
% PREDECIR_GRF_PERSONALIZADO_CORE  29-ago-2026: aplica el modelo
% personalizado (Personalizar_Plantilla_Fukuchi_GRF_Core.m, regresion
% punto-a-punto vs velocidad [+talla]) a una antropometria nueva.
%
% MISMA VELOCIDAD QUE EL GENERADOR DE TRAYECTORIAS (pedido explicito del
% usuario, 29-ago-2026, "para guardar cierta relacion de lo que se
% espera"): si no se da antropometria.velocidad_ms medida, se estima con
% EXACTAMENTE el mismo motor que usa Generar_Trayectoria.m (Estimar_
% Velocidad_Froude_Core.m via Temporizacion_Core.m) - no una estimacion
% de velocidad distinta para GRF y para la trayectoria.
%
%   out = Predecir_GRF_Personalizado_Core(antropometria)
%   out = Predecir_GRF_Personalizado_Core(antropometria, modelo)  % modelo ya cargado, evita releer el .mat
%
% ENTRADA
%   antropometria.talla_m, .masa_kg (obligatorios); .velocidad_ms (opcional)
%   modelo    struct de Personalizar_Plantilla_Fukuchi_GRF_Core.m (opcional,
%             si no se da se carga Modelo_Personalizado_Fukuchi_GRF.mat)
%
% SALIDA: struct out con .pct, .GRF_vertical_pctBW, .GRF_vertical_N,
%   .velocidad_ms_usada (para trazabilidad - confirma que es la misma que
%   usaria el generador), .fuera_de_rango_velocidad / _talla (bool, avisa
%   si se esta extrapolando fuera de los sujetos jovenes de Fukuchi usados
%   para ajustar el modelo (<40 anios, ambas piernas, N=48), sin
%   bloquear el calculo - mismo criterio que Koopman2014_Core.m)
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
if nargin < 2 || isempty(modelo)
    S = load(fullfile(carpeta,'Modelo_Personalizado_Fukuchi_GRF.mat'), 'modelo');
    modelo = S.modelo;
end

antro = Estimar_Antropometria_Core(antropometria);
% Motor de velocidad COMPARTIDO con el generador de trayectorias (mismo
% Temporizacion_Core.m que usa Generar_Trayectoria.m/GRF_Newton_ApoyoSimple_
% Core.m) - si antropometria.velocidad_ms viene medida, Temporizacion_Core
% la respeta tal cual; si no, la estima por Froude, IDENTICO criterio.
tempo = Temporizacion_Core(antro, 'Koopman');
v = tempo.velocidad_ms;
talla_m = antro.talla_m;

if v < modelo.rango_velocidad_ms(1) || v > modelo.rango_velocidad_ms(2)
    warning('Predecir_GRF_Personalizado_Core:velocidadFueraDeRango', ...
        'velocidad=%.2fm/s fuera del rango de los sujetos jovenes de Fukuchi (<40 anios, ambas piernas) usados para ajustar el modelo (%.2f-%.2fm/s) - extrapolacion.', ...
        v, modelo.rango_velocidad_ms(1), modelo.rango_velocidad_ms(2));
    fuera_v = true;
else
    fuera_v = false;
end
fuera_t = false;
if modelo.incluye_talla
    if talla_m < modelo.rango_talla_m(1) || talla_m > modelo.rango_talla_m(2)
        warning('Predecir_GRF_Personalizado_Core:tallaFueraDeRango', ...
            'talla=%.2fm fuera del rango de los sujetos jovenes de Fukuchi (<40 anios, ambas piernas) (%.2f-%.2fm) - extrapolacion.', ...
            talla_m, modelo.rango_talla_m(1), modelo.rango_talla_m(2));
        fuera_t = true;
    end
    pred_pctBW = modelo.a + modelo.b*v + modelo.c*talla_m;
else
    pred_pctBW = modelo.a + modelo.b*v;
end
pred_pctBW = max(pred_pctBW, 0);  % Fz no puede ser negativa (misma restriccion fisica ya usada en GRF_Newton_ApoyoSimple_Core.m)

out = struct();
out.pct = modelo.pct;
out.GRF_vertical_pctBW = pred_pctBW;
out.GRF_vertical_N = pred_pctBW/100 * antro.masa_kg * 9.80665;
out.velocidad_ms_usada = v;
out.fuera_de_rango_velocidad = fuera_v;
out.fuera_de_rango_talla = fuera_t;
out.modelo_incluye_talla = modelo.incluye_talla;

end
