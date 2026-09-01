function Diag_Reduccion_Tibial_Proceso()
% DIAG_REDUCCION_TIBIAL_PROCESO  30-ago-2026: diagnostico de un solo uso,
%                   pedido explicito del usuario para el informe tecnico -
%                   la Figura 12 (reduccion_angulo_tibial_esquema.png) es
%                   solo un ESQUEMA (angulos ilustrativos, no un caso
%                   numerico real) y la Figura 6 (generador_salida_
%                   koopman.png) muestra theta_tibia ya calculado, sin
%                   mostrar de donde sale. Falta una figura intermedia con
%                   CURVAS REALES: theta_muslo(t) y phi_rodilla(t) (los
%                   dos insumos que Koopman SI publica directamente) y
%                   theta_tibia(t)=theta_muslo-phi_rodilla (el resultado,
%                   que Koopman NO publica) - el proceso completo, no solo
%                   el insumo ni solo el resultado.
%
%   Mismo caso que las Figuras 6 y 13 del informe (v=3.5 km/h,
%   talla=1.71 m) para que las tres figuras sean directamente comparables.
%
%   Formula: Koopman2014_Core.m linea 107 (via Reduccion_Winter_Core.m),
%   theta_tibia_via_rodilla = theta_muslo - phi_rodilla (via rodilla,
%   ganadora con r=0.982 vs r=-0.435 de la via tobillo contra el registro
%   real del proyecto - ver Seccion "Reduccion a angulo de inclinacion
%   tibial" del informe).
%
%   No genera tabla ni test - una sola figura, mismo patron que los demas
%   Diag_*.m de esta sesion.

addpath(fileparts(mfilename('fullpath')));

v_kph = 3.5; talla_m = 1.71;   % mismo caso que Figuras 6/13 del informe

K = Koopman2014_Core(v_kph, talla_m);
pct = linspace(0, 100, numel(K.cadera_flexext.angulo_deg));

theta_muslo_deg  = K.cadera_flexext.angulo_deg;
phi_rodilla_deg  = K.rodilla_flexext.angulo_deg;
theta_tibia_deg  = K.theta_tibia_via_rodilla_deg;

% chequeo exacto de la formula (no solo confiar en el campo ya calculado)
resta_deg = theta_muslo_deg - phi_rodilla_deg;
err_max = max(abs(resta_deg - theta_tibia_deg));
fprintf('Chequeo formula theta_tibia = theta_muslo - phi_rodilla: error maximo = %.2e grados (debe ser ~0)\n', err_max);

col_muslo = [0.20 0.45 0.70]; col_rodilla = [0.85 0.33 0.10]; col_tibia = [0.20 0.55 0.30];

fig = figure('Name','Proceso: de los angulos de Koopman al angulo tibial','Position',[60 60 1100 800],'Color','w');

subplot(2,1,1); hold on; grid on; box on;
plot(pct, theta_muslo_deg, '-', 'Color', col_muslo, 'LineWidth', 2.2);
plot(pct, phi_rodilla_deg, '-', 'Color', col_rodilla, 'LineWidth', 2.2);
xline(60, 'k--', 'HandleVisibility','off');
xlabel('% ciclo'); ylabel('Angulo [grados]');
legend({'\theta_{muslo} (cadera flexo-extension, Koopman Tabla 2)', ...
        '\phi_{rodilla} (rodilla flexo-extension, Koopman Tabla 3)'}, ...
        'Location','best');
title(sprintf('PASO 1 - Insumos publicados DIRECTAMENTE por Koopman (v=%.1f km/h, talla=%.2f m)', v_kph, talla_m));

subplot(2,1,2); hold on; grid on; box on;
plot(pct, theta_muslo_deg, ':', 'Color', [col_muslo 0.5], 'LineWidth', 1.3);
plot(pct, phi_rodilla_deg, ':', 'Color', [col_rodilla 0.5], 'LineWidth', 1.3);
plot(pct, theta_tibia_deg, '-', 'Color', col_tibia, 'LineWidth', 2.6);
xline(60, 'k--', 'HandleVisibility','off');
xlabel('% ciclo'); ylabel('Angulo [grados]');
legend({'\theta_{muslo} (insumo, referencia)', '\phi_{rodilla} (insumo, referencia)', ...
        '\theta_{tibia} = \theta_{muslo} - \phi_{rodilla}  (RESULTADO, no publicado por Koopman)'}, ...
        'Location','best');
title('PASO 2 - Reduccion geometrica (via rodilla, Ec. de este informe): el angulo tibial resulta de RESTAR las dos curvas de arriba');

sgtitle('De los angulos publicados por Koopman al angulo de inclinacion tibial que usa el simulador', 'FontWeight','bold');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Diag_Reduccion_Tibial_Proceso_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura guardada en: %s\n', out_png);

end
