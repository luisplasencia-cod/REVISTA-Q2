function Ver_Resultado_Final(antro_in, candidato)
% VER_RESULTADO_FINAL  Grafica final pedida por el usuario (24-ago-2026):
%                   coordenadas X e Y (altura) de RODILLA y TOBILLO, mas
%                   el angulo de inclinacion tibial, con el ciclo YA
%                   CONTINUO (sin el salto en el cambio de fase) y con el
%                   avance sumado en ambas fases.
%
%   Ver_Resultado_Final()                        % Koopman, talla 1.71m
%   Ver_Resultado_Final(antro_in)                % antropometria propia
%   Ver_Resultado_Final(antro_in, 'Zhao')        % otro candidato
%
% ENTRADA (ambas opcionales)
%   antro_in   struct con .talla_m (obligatorio si se pasa), .masa_kg,
%              .sexo, .long_muslo_m, .long_tibia_m - TODO el resultado
%              varia con estos valores (Estimar_Antropometria_Core.m
%              completa lo que falte con las fracciones de Winter/
%              Drillis&Contini ya verificadas).
%   candidato  'Koopman' (default) | 'Zhao' | 'Yun' | 'Combinado'
%
% NOTA: el TOBILLO aqui es el pivote del modelo de cadena cinematica
% (Cadena_Cinematica_Core.m) mas la traslacion de avance - es decir, en
% este marco el tobillo NO se queda en (0,0) como antes del cambio del
% 24-ago-2026, sino que avanza con el cuerpo. Se dibuja explicitamente
% para que se vea, ya que era justo el punto que el usuario queria
% verificar.

if nargin < 1 || isempty(antro_in)
    antro_in = struct('talla_m', 1.71, 'masa_kg', 68, 'sexo', 'M');
end
if nargin < 2 || isempty(candidato), candidato = 'Koopman'; end

r = Generar_Trayectoria(antro_in, candidato);
antro = r.metadatos.antropometria;
tempo = r.metadatos.temporizacion;

n = numel(r.apoyo.x_cm);
pct_ap  = linspace(0, tempo.frac_apoyo*100, n);
pct_bal = linspace(tempo.frac_apoyo*100, 100, n);
% ciclo completo continuo (se omite la 1ra muestra del balanceo, que
% coincide exacto con la ultima del apoyo tras el cambio a ciclo continuo)
pct   = [pct_ap, pct_bal(2:end)];
rod_x = [r.apoyo.x_cm, r.balanceo.x_cm(2:end)];
rod_y = [r.apoyo.y_cm, r.balanceo.y_cm(2:end)];
ang   = [r.apoyo.angulo_deg, r.balanceo.angulo_deg(2:end)];

% Tobillo = extremo proximal del segmento: se recupera restando el vector
% tibia (misma trigonometria de Cadena_Cinematica_Core.m, convencion
% theta=0 -> vertical, X invertido segun G7).
L_cm = antro.long_tibia_m * 100;
tob_x = rod_x + L_cm * sind(ang);
tob_y = rod_y - L_cm * cosd(ang);

% OFFSET DE VISUALIZACION (pedido del usuario, revision del informe):
% la trayectoria exportada sigue normalizada a (0,0) en el primer punto
% (no se toca nada de eso, Desplazamientos.m/normalizeDisp sin cambios) -
% esto es SOLO para que los paneles de Y muestren una altura sobre el
% suelo anatomicamente plausible en vez de un origen arbitrario. Se usa
% la fraccion de Drillis & Contini ya documentada en el Paso 1 del
% informe (altura de rodilla = 0.285*H sobre el suelo) como offset
% constante - por construccion (0.285-0.039=0.246=fraccion de tibia), el
% mismo offset deja tambien al tobillo cerca de su altura real
% (0.039*H), sin necesidad de un segundo ajuste independiente.
FRAC_ALTURA_RODILLA = 0.285;   % Drillis & Contini 1966, ver Paso 1 del informe
y_offset_cm = FRAC_ALTURA_RODILLA * antro.talla_m * 100;
rod_y_vis = rod_y + y_offset_cm;
tob_y_vis = tob_y + y_offset_cm;

fig = figure('Name','Resultado final: rodilla, tobillo y angulo tibial', ...
    'Position',[80 60 1400 800], 'Color','w');
c_rod = [0.85 0.33 0.10];
c_tob = [0.10 0.40 0.75];

% --- Panel 1: X vs %ciclo ---
subplot(2,2,1); hold on; grid on; box on;
plot(pct, rod_x, '-', 'Color', c_rod, 'LineWidth', 2.5);
plot(pct, tob_x, '-', 'Color', c_tob, 'LineWidth', 2.5);
xline(tempo.frac_apoyo*100, ':k', 'apoyo|balanceo');
xlabel('% ciclo de marcha'); ylabel('X [cm] (avance)');
title('X (avance) - rodilla y tobillo');
legend({'rodilla','tobillo'}, 'Location','best');

% --- Panel 2: Y (altura) vs %ciclo --- altura sobre el suelo (offset de
% visualizacion, ver nota arriba), NO la Y normalizada que exporta el CSV
subplot(2,2,2); hold on; grid on; box on;
plot(pct, rod_y_vis, '-', 'Color', c_rod, 'LineWidth', 2.5);
plot(pct, tob_y_vis, '-', 'Color', c_tob, 'LineWidth', 2.5);
yline(0, ':', 'suelo');
xline(tempo.frac_apoyo*100, ':k', 'apoyo|balanceo');
xlabel('% ciclo de marcha'); ylabel('Y [cm] (altura sobre el suelo, estimada)');
title('Y (altura sobre el suelo) - rodilla y tobillo');
legend({'rodilla','tobillo'}, 'Location','best');

% --- Panel 3: vista sagital (X vs Y), la trayectoria en el plano ---
% altura sobre el suelo (offset de visualizacion, ver nota arriba)
subplot(2,2,3); hold on; grid on; box on; axis equal;
plot(rod_x, rod_y_vis, '-', 'Color', c_rod, 'LineWidth', 2.5);
plot(tob_x, tob_y_vis, '-', 'Color', c_tob, 'LineWidth', 2.5);
yline(0, ':', 'suelo');
% dibujar el segmento tibial cada 10% de ciclo, para ver la postura
idx_post = round(linspace(1, numel(pct), 11));
for k = idx_post
    plot([tob_x(k) rod_x(k)], [tob_y_vis(k) rod_y_vis(k)], '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1);
end
xlabel('X [cm] (avance)'); ylabel('Y [cm] (altura sobre el suelo, estimada)');
title('Vista sagital - trayectoria + segmento tibial cada 10% del ciclo');
legend({'rodilla','tobillo'}, 'Location','best');

% --- Panel 4: angulo de inclinacion tibial ---
subplot(2,2,4); hold on; grid on; box on;
plot(pct, ang, 'k-', 'LineWidth', 2.5);
yline(0, ':', 'tibia vertical');
xline(tempo.frac_apoyo*100, ':k', 'apoyo|balanceo');
xlabel('% ciclo de marcha'); ylabel('\theta_{tibia} [deg] (0 = vertical)');
title('Angulo de inclinacion tibial');

% CORREGIDO (observacion del usuario, revision del informe): masa_kg no
% se usa en ningun calculo de este pipeline (Generar_Trayectoria.m no la
% consume para posicion/angulo, ver docs/algoritmo/informe_tecnico_
% generador.tex, "Trazabilidad de las 3 entradas") - mostrarla en el
% titulo sugeria falsamente que influye en el resultado. Se quita, y se
% marca explicitamente si v es medida o estimada por Froude
% (tempo.fuente_velocidad, Temporizacion_Core.m).
if strcmp(tempo.fuente_velocidad, 'medida')
    v_txt = sprintf('v=%.2f m/s (medida)', tempo.velocidad_ms);
else
    v_txt = sprintf('v=%.2f m/s (estimada, Froude)', tempo.velocidad_ms);
end
sgtitle(sprintf('%s -- talla=%.2f m, %s, tibia=%.1f cm (estimada, Drillis-Contini)', ...
    candidato, antro.talla_m, v_txt, L_cm), 'FontWeight','bold');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Ver_Resultado_Final_figura.png');
try
    exportgraphics(fig, out_png, 'Resolution', 150);
    fprintf('Figura guardada en: %s\n', out_png);
catch ME
    fprintf('  [aviso] no se pudo exportar PNG: %s\n', ME.message);
end

end
