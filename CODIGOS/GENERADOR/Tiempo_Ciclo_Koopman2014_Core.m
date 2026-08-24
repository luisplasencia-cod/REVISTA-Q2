function [tiempo_ciclo_s, step_ratio] = Tiempo_Ciclo_Koopman2014_Core(v_kph, l_m)
% TIEMPO_CICLO_KOOPMAN2014_CORE  Duracion real del ciclo de marcha desde
%                                 velocidad y talla, con la regresion YA
%                                 PUBLICADA de Koopman et al. 2014
%                                 (Tabla 5, Ec.3) - extraida de
%                                 Koopman2014_Core.m (23-ago-2026, E4 de
%                                 plan_100_generador.md) para reusarla
%                                 como motor de temporizacion COMPARTIDO
%                                 por los tres candidatos, no solo por
%                                 Koopman: es una regresion general de
%                                 tiempo de paso desde velocidad+talla,
%                                 no algo especifico de las curvas
%                                 articulares propias de Koopman.
%
%   [tiempo_ciclo_s, step_ratio] = Tiempo_Ciclo_Koopman2014_Core(v_kph, l_m)
%
% ENTRADA
%   v_kph   velocidad de marcha (km/h). Rango validado por el paper: 0.5-5 kph.
%   l_m     talla corporal (m)
%
% SALIDA
%   tiempo_ciclo_s   duracion de un ciclo completo de marcha (s)
%   step_ratio       parametro intermedio de la Ec.3 (adimensional)
%
% Fuente: docs/literatura/pdfs/koomap.pdf, Tabla 5 (verificada con
% pdfplumber, ver docs/algoritmo/diseno_matematico_generador.md #2).
% ==========================================================================

if ~(isnumeric(v_kph) && isscalar(v_kph) && v_kph > 0)
    error('v_kph debe ser un escalar positivo (km/h). Se recibio: %s', mat2str(v_kph));
end
if ~(isnumeric(l_m) && isscalar(l_m) && l_m > 0)
    error('l_m debe ser un escalar positivo (m). Se recibio: %s', mat2str(l_m));
end
if v_kph < 0.5 || v_kph > 5
    warning('Tiempo_Ciclo_Koopman2014_Core:fueraDeRango', ...
        'v_kph=%.2f esta fuera del rango validado por el paper (0.5-5 kph) - extrapolacion.', v_kph);
end

% step_ratio = beta0 + beta1*v + beta3*l  (sin termino v^2 en esta fila, Tabla 5)
coef_step_ratio = [-0.532, 0.020, 0, 0.47];
step_ratio = coef_step_ratio(1) + coef_step_ratio(2)*v_kph + coef_step_ratio(3)*v_kph^2 + coef_step_ratio(4)*l_m;
tiempo_ciclo_s = 2 * sqrt(step_ratio / (v_kph/3.6));

end
