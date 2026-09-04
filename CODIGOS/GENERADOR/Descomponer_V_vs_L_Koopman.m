function Descomponer_V_vs_L_Koopman()
% DESCOMPONER_V_VS_L_KOOPMAN  02-sep-2026: separa, en Koopman2014_Core.m,
%                   cuanto de la dependencia con TALLA del angulo tibial
%                   viene del termino de VELOCIDAD (b1*v+b2*v^2) vs. del
%                   termino de TALLA DIRECTA (b3*l) de cada regresion
%                   publicada.
%
% POR QUE EXISTE: un primer diagnostico (01-sep-2026) atribuyo TODA la
% dependencia espuria con talla del angulo tibial a que la velocidad
% Froude-estimada cae fuera del rango que Koopman 2014 valido (0.5-5 kph).
% Ese diagnostico usaba corr(v_froude, crudo) - pero eso es exactamente
% LA MISMA correlacion que corr(talla, crudo), porque v_froude es una
% funcion deterministica de talla (Estimar_Velocidad_Froude_Core.m) - no
% distingue nada, es circular. Este script rompe esa colinealidad
% variando v y l POR SEPARADO, cada uno con el otro fijo.
%
% RESULTADO (verificado 02-sep-2026, ver GUIA_INTERPRETACION.md #10 y
% informe tecnico, Limitaciones): ambos terminos contribuyen, en
% proporcion variable segun el tramo del ciclo - saturar solo v
% (Saturar_Velocidad_Koopman_Core.m) no bastaba por si solo
% (corr(talla,crudo) se quedaba en 0.96-0.99 con cualquier margen). La
% correccion real fue congelar AMBOS (opcion congelar_vl_angulo de
% Koopman2014_Core.m).
% ==========================================================================

addpath(fileparts(mfilename('fullpath')));
opt = struct('nMuestras',101,'margen_saturacion_kph',1);

tallas = 1.61:0.02:1.87;  % rango real de Kuopio
n = numel(tallas);

% --- Experimento A: l VARIA, v FIJO (v=3 kph, centro del rango Koopman) ---
curvas_A = nan(n,101);
warning('off','all');
for i=1:n
    K = Koopman2014_Core(3.0, tallas(i), opt);
    curvas_A(i,:) = K.theta_tibia_via_rodilla_deg;
end

% --- Experimento B: v VARIA (Froude real por talla), l FIJO (l=1.74) ---
curvas_B = nan(n,101);
for i=1:n
    v_ms = Estimar_Velocidad_Froude_Core(tallas(i));
    K = Koopman2014_Core(v_ms*3.6, 1.74, opt);
    curvas_B(i,:) = K.theta_tibia_via_rodilla_deg;
end

% --- Experimento C: ambos varian juntos (como en produccion, sin congelar) ---
curvas_C = nan(n,101);
for i=1:n
    v_ms = Estimar_Velocidad_Froude_Core(tallas(i));
    K = Koopman2014_Core(v_ms*3.6, tallas(i), opt);
    curvas_C(i,:) = K.theta_tibia_via_rodilla_deg;
end
warning('on','all');

pct = linspace(0,100,101);
fprintf('%%ciclo | SD(solo l, v fijo) | SD(solo v, l fijo) | SD(ambos, sin congelar)\n');
for p = [0 10 20 30 40 50 60 70 80 90 100]
    [~,idx]=min(abs(pct-p));
    fprintf('%3d%%   |  %6.3f            |  %6.3f            |  %6.3f\n', p, std(curvas_A(:,idx)), std(curvas_B(:,idx)), std(curvas_C(:,idx)));
end
fprintf('\nSD promedio ciclo completo: solo-l=%.3f  solo-v=%.3f  ambos=%.3f\n', ...
    mean(std(curvas_A,0,1)), mean(std(curvas_B,0,1)), mean(std(curvas_C,0,1)));
end
