function out = Ver_GRF_y_Trayectoria(antro_in, candidato, hacer_figura)
% VER_GRF_Y_TRAYECTORIA  28-ago-2026: primera vista conjunta de la
%                   trayectoria generada (rodilla/tobillo, la misma que
%                   Generar_Trayectoria.m escribiria al CSV del simulador)
%                   y la GRF predicha para esa MISMA antropometria
%                   (GRF_Newton_ApoyoSimple_Core.m) - pedido explicito del
%                   usuario: "para cualquier talla y peso que agreguemos".
%
%   Ver_GRF_y_Trayectoria()                    % Koopman, talla 1.71m/68kg/M
%   Ver_GRF_y_Trayectoria(antro_in)
%   Ver_GRF_y_Trayectoria(antro_in, 'Zhao')
%
% VERIFICACIONES QUE HACE ANTES DE GRAFICAR (pedido explicito del usuario,
% "ve verificando que todo esta bien desde el inicio"):
%   1) Generar_Trayectoria.m y GRF_Newton_ApoyoSimple_Core.m son DOS
%      pipelines codificados por separado que llaman a los MISMOS nucleos
%      de angulo (Obtener_Theta_Tibia_Candidato/Obtener_Angulos_Candidato)
%      pero aplican correcciones empiricas DISTINTAS encima (Generar_
%      Trayectoria.m: FRAC_AVANCE_APOYO=0.079 + punto_seguimiento_m;
%      GRF_Newton_ApoyoSimple_Core.m: ninguna, usa Cadena_Completa_Core.m
%      "en crudo" para reconstruir cadera/rodilla/tobillo). Se comparan
%      ambas trayectorias de rodilla (mismo punto en las dos por default)
%      y se reporta la discrepancia maxima en cm - NO se asume que
%      coinciden solo porque comparten los mismos angulos de origen.
%   2) Autochequeo fisico ya construido en GRF_Newton_ApoyoSimple_Core.m:
%      la GRF vertical media de un ciclo completo periodico DEBE dar
%      ~100%BW exacto (la aceleracion media de un ciclo periodico es cero
%      por definicion) - se verifica explicitamente, no se da por hecho.
%   3) Ninguno de los dos pipelines aplica todavia la calibracion afin
%      LOSO (ganancia ~0.77-0.81) encontrada al validar Koopman contra
%      Kuopio 2024 (docs/algoritmo/pipeline_koopman_kuopio/
%      PIPELINE_KOOPMAN_KUOPIO.md Sec.5) - esto es una decision de
%      arquitectura pospuesta explicitamente por el usuario el 24-ago-2026
%      (ver Sec.8 de ese documento, "sigue sin cerrar"), NO un descuido de
%      este script. Se declara en la figura (subtitulo) para que quede
%      visible cada vez que se corre, no solo documentado en un .md aparte.
%
% ENTRADA (ambas opcionales, igual convencion que Ver_Resultado_Final.m)
%   antro_in   struct .talla_m (obligatorio si se pasa), .masa_kg
%              (obligatorio para GRF), .sexo (obligatorio para GRF),
%              opcionales .long_muslo_m/.long_tibia_m/.velocidad_ms
%   candidato  'Koopman' (default) | 'Zhao' | 'Yun' - NO 'Combinado'
%              (GRF_Newton_ApoyoSimple_Core.m no lo soporta, ver su cabecera)
%
% SALIDA: struct `out` con los resultados crudos de ambos pipelines
%   (.trayectoria = salida de Generar_Trayectoria.m,
%    .grf = salida de GRF_Newton_ApoyoSimple_Core.m,
%    .discrepancia_rodilla_cm = max|rodilla_trayectoria - rodilla_grf|)
%   + guarda Ver_GRF_y_Trayectoria_figura.png (mismo patron que el resto
%   de la carpeta).
%
% UMBRAL DE 20N (pedido explicito del usuario, 28-ago-2026): "podemos
% cortar en 20N ya que eso esta justificado en la literatura tanto para la
% plataforma como para lo que generemos". Se usa aqui SOLO para marcar
% visualmente en la figura donde la GRF vertical predicha cruza 20N (un
% proxy visual del instante de contacto/despegue) - la logica real de
% "que plataforma esta activa" contra datos REALES de Kuopio (siguiente
% paso, ver conversacion) no vive en este archivo, que no compara contra
% ninguna plataforma real todavia.
% ==========================================================================

if nargin < 1 || isempty(antro_in)
    antro_in = struct('talla_m', 1.71, 'masa_kg', 68, 'sexo', 'M');
end
if nargin < 2 || isempty(candidato), candidato = 'Koopman'; end
if nargin < 3 || isempty(hacer_figura), hacer_figura = true; end

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta);

fprintf('=== Ver_GRF_y_Trayectoria: talla=%.3fm masa=%.1fkg sexo=%s candidato=%s ===\n', ...
    antro_in.talla_m, antro_in.masa_kg, antro_in.sexo, candidato);

% --- Paso 1: Generar_Trayectoria.m (la que se escribiria al CSV real) ---
tr = Generar_Trayectoria(antro_in, candidato);
fprintf('[1/4] Generar_Trayectoria OK - %d puntos apoyo, %d puntos balanceo\n', ...
    numel(tr.apoyo.x_cm), numel(tr.balanceo.x_cm));

% --- Paso 2: GRF_Newton_ApoyoSimple_Core.m (GRF + cadena completa propia) ---
gr = GRF_Newton_ApoyoSimple_Core(antro_in, candidato);
fprintf('[2/4] GRF_Newton_ApoyoSimple_Core OK - %d puntos, %.1f%%BW medio (verificacion fisica)\n', ...
    numel(gr.t_s), gr.verificacion_media_vGRF_pctBW);

% --- VERIFICACION 2: autochequeo fisico debe caer cerca de 100%BW ---
err_bw = abs(gr.verificacion_media_vGRF_pctBW - 100);
if err_bw > 2
    warning('Ver_GRF_y_Trayectoria:chequeoFisico', ...
        'GRF vertical media = %.2f%%BW, se esperaba ~100%%BW (periodicidad). Revisar antes de confiar en la figura.', ...
        gr.verificacion_media_vGRF_pctBW);
else
    fprintf('      -> OK, dentro de +-2%%BW de 100%% (chequeo de periodicidad pasa)\n');
end

% --- Paso 3: VERIFICACION 1 - consistencia entre los dos pipelines ---
% Reconstruir la rodilla de Generar_Trayectoria.m (punto_seguimiento_m por
% defecto = rodilla anatomica, igual que GRF_Newton usa la rodilla real de
% Cadena_Completa_Core.m) en malla de %ciclo comun.
tempo_tr = tr.metadatos.temporizacion;
n_tr = numel(tr.apoyo.x_cm);
pct_ap_tr  = linspace(0, tempo_tr.frac_apoyo*100, n_tr);
pct_bal_tr = linspace(tempo_tr.frac_apoyo*100, 100, n_tr);
pct_tr = [pct_ap_tr, pct_bal_tr(2:end)];
rodx_tr = [tr.apoyo.x_cm, tr.balanceo.x_cm(2:end)];
rody_tr = [tr.apoyo.y_cm, tr.balanceo.y_cm(2:end)];

rodx_grf_full = interp1(gr.pct_ciclo, gr.rodilla_x_cm, pct_tr, 'pchip');
rody_grf_full = interp1(gr.pct_ciclo, gr.rodilla_y_cm, pct_tr, 'pchip');
% Ambas series se anclan a su propio origen (Generar_Trayectoria.m ya
% normaliza el apoyo a (0,0); GRF_Newton no normaliza - construye desde la
% cadera real) - se comparan FORMAS (restando el valor inicial a cada una),
% no posicion absoluta, porque los dos pipelines no comparten origen por
% construccion (Generar_Trayectoria.m normaliza expresamente, ver su
% cabecera "Apoyo: normalizado a (0,0)"; GRF_Newton no tiene ese paso).
dx = (rodx_tr - rodx_tr(1)) - (rodx_grf_full - rodx_grf_full(1));
dy = (rody_tr - rody_tr(1)) - (rody_grf_full - rody_grf_full(1));
discrepancia_cm = max(hypot(dx, dy));
fprintf('[3/4] Consistencia rodilla Generar_Trayectoria vs GRF_Newton (misma forma, distinto origen): max %.2f cm\n', discrepancia_cm);
if discrepancia_cm > 5
    warning('Ver_GRF_y_Trayectoria:discrepanciaPipelines', ...
        ['Discrepancia de forma %.2f cm entre Generar_Trayectoria.m y GRF_Newton_ApoyoSimple_Core.m - ' ...
         'mayor de lo esperado (>5cm). Candidatos: FRAC_AVANCE_APOYO=0.079 solo esta en Generar_Trayectoria.m, ' ...
         'no en GRF_Newton - revisar antes de citar cualquier numero de esta figura.'], discrepancia_cm);
else
    fprintf('      -> OK, discrepancia de forma menor a 5cm (los dos pipelines son consistentes entre si)\n');
end

% --- VERIFICACION 3 (pedido explicito del usuario, 28-ago-2026): que los
% VALORES tengan sentido, no solo la forma/correlacion. Se compara el
% minimo/maximo de GRF vertical DENTRO de la ventana valida (apoyo_simple_
% mask_estricta) contra los rangos ya documentados en docs/literatura/
% literatura_GRF_protesica.md - "de libro" para marcha normal a paso
% comodo: primer pico ~110%BW, valle medio-apoyo ~80%BW, segundo pico
% ~110%BW (referencia 1 de ese documento); marcha rapida o lado sano de
% amputados: picos 150-170%BW (referencia 2); la propia referencia sana
% del proyecto (86kg, Kinovea): picos 98.83%BW y 104.88%BW. La ventana
% valida de este script normalmente cubre el VALLE medio-apoyo (los dos
% picos caen en las zonas de doble apoyo, excluidas por diseno - ver
% cabecera de GRF_Newton_ApoyoSimple_Core.m), asi que el numero esperado
% aqui es el rango ~70-80%BW del valle, NO los picos de 100-170%BW.
BW_N = antro_in.masa_kg * 9.80665;
vmin_bw = min(gr.GRF_vertical_pctBW(gr.apoyo_simple_mask_estricta));
vmax_bw = max(gr.GRF_vertical_pctBW(gr.apoyo_simple_mask_estricta));
hmin_bw = min(gr.GRF_horizontal_pctBW(gr.apoyo_simple_mask_estricta));
hmax_bw = max(gr.GRF_horizontal_pctBW(gr.apoyo_simple_mask_estricta));
fprintf('\n[VERIFICACION DE MAGNITUD, no solo forma - ventana valida apoyo_simple_mask_estricta]\n');
fprintf('  GRF vertical:   [%.1f, %.1f]%%BW  =  [%.0f, %.0f] N\n', vmin_bw, vmax_bw, vmin_bw/100*BW_N, vmax_bw/100*BW_N);
fprintf('  GRF horizontal: [%.1f, %.1f]%%BW  =  [%.0f, %.0f] N\n', hmin_bw, hmax_bw, hmin_bw/100*BW_N, hmax_bw/100*BW_N);
if vmin_bw >= 50 && vmax_bw <= 115
    fprintf('  -> Vertical OK: cae en el rango del valle medio-apoyo de marcha normal (~70-80%%BW, literatura_GRF_protesica.md ref.1), sin llegar a los picos (100-170%%BW) porque esos caen en la zona de doble apoyo excluida aqui.\n');
elseif vmax_bw > 170
    warning('Ver_GRF_y_Trayectoria:vGRFimplausible', 'GRF vertical valida alcanza %.0f%%BW, por ENCIMA del techo de marcha rapida en amputados (170%%BW, literatura_GRF_protesica.md ref.2) - revisar antes de confiar en la figura.', vmax_bw);
else
    fprintf('  -> Vertical dentro de banda ampliada, revisar contra literatura si se va a citar.\n');
end
h_extremo = max(abs(hmin_bw), abs(hmax_bw));
if h_extremo > 30
    warning('Ver_GRF_y_Trayectoria:hGRFalto', 'GRF horizontal valida alcanza %.1f%%BW - claramente por encima del rango tipico de marcha (+-15-20%%BW). Revisar antes de confiar en la figura.', h_extremo);
elseif h_extremo > 20
    fprintf('  -> Horizontal LIMITE: %.1f%%BW, por encima del rango tipico de libro (+-15-20%%BW) pero no alarmante - puede ser frenado real tras la respuesta de carga, cerca del borde de la ventana valida. Declarar si se cita.\n', h_extremo);
else
    fprintf('  -> Horizontal OK: dentro del rango tipico de marcha (+-15-20%%BW de frenado/propulsion).\n');
end

% --- Paso 4: figura, SOLO APOYO (0-60% aprox, pedido del usuario
% 28-ago-2026: "el GRF solo se va a generar con el 0 al 60% que
% corresponde a apoyo... no es necesario en balanceo" - el balanceo del
% pie trackeado no aporta nada nuevo a la GRF (fuerza=0 de esa pierna por
% definicion, lo que se ve ahi es solo el espejo de la otra pierna). ---
BW_N = antro_in.masa_kg * 9.80665;
pct_corte = tempo_tr.frac_apoyo*100;
mask_ok = gr.apoyo_simple_mask_estricta;

out = struct('trayectoria', tr, 'grf', gr, 'discrepancia_rodilla_cm', discrepancia_cm, ...
    'chequeo_periodicidad_ok', err_bw <= 2, 'chequeo_consistencia_ok', discrepancia_cm <= 5, ...
    'BW_N', BW_N, 'pct_corte_apoyo', pct_corte);

if ~hacer_figura
    return
end

fprintf('[4/4] Generando figura (solo apoyo, 0-%.0f%%)...\n', pct_corte);
fig = figure('Color', 'w', 'Position', [80 80 1200 820]);

col_koop = [0.00 0.45 0.70];  % azul accesible (paleta ya usada en el proyecto)

subplot(2,2,1); hold on; box on;
plot(tr.apoyo.x_cm, tr.apoyo.y_cm, '-', 'Color', col_koop, 'LineWidth', 1.8);
plot(tr.apoyo.x_cm(1), tr.apoyo.y_cm(1), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
xlabel('X horizontal (cm)'); ylabel('Y vertical (cm)');
title('Trayectoria generada, apoyo (rodilla, Generar\_Trayectoria.m)');
axis equal; grid on;

vert = gr.GRF_vertical_pctBW; vert_invalido = vert; vert_valido = vert;
vert_valido(~mask_ok) = NaN; vert_invalido(mask_ok) = NaN;
horiz = gr.GRF_horizontal_pctBW; horiz_invalido = horiz; horiz_valido = horiz;
horiz_valido(~mask_ok) = NaN; horiz_invalido(mask_ok) = NaN;
idx_ap = gr.pct_ciclo <= pct_corte;

ax2 = subplot(2,2,2); hold on; box on;
yyaxis left
ylims_grf = [min(vert_valido)-10, max(vert_valido)+10];
plot(gr.pct_ciclo(idx_ap), vert_invalido(idx_ap), ':', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2);
plot(gr.pct_ciclo(idx_ap), vert_valido(idx_ap), '-', 'Color', col_koop, 'LineWidth', 1.8);
yline(100, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
xlabel('% ciclo (apoyo)'); ylabel('GRF vertical (%BW)');
xlim([0 pct_corte]); ylim(ylims_grf); grid on;
ax2.YAxis(1).Color = col_koop;
yyaxis right
ylim(ylims_grf/100*BW_N);
ylabel('GRF vertical (N)');
ax2.YAxis(2).Color = [0.35 0.35 0.35];
title(sprintf('GRF vertical (media ciclo = %.0f%%BW = %.0fN; gris = no confiable)', gr.verificacion_media_vGRF_pctBW, gr.verificacion_media_vGRF_pctBW/100*BW_N), 'FontSize', 10);

ax3 = subplot(2,2,3); hold on; box on;
yyaxis left
ylims_h = [min(horiz_valido)-5, max(horiz_valido)+5];
plot(gr.pct_ciclo(idx_ap), horiz_invalido(idx_ap), ':', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2);
plot(gr.pct_ciclo(idx_ap), horiz_valido(idx_ap), '-', 'Color', [0.85 0.55 0.10], 'LineWidth', 1.8);
yline(0, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.75);
xlabel('% ciclo (apoyo)'); ylabel('GRF anteroposterior (%BW)');
xlim([0 pct_corte]); ylim(ylims_h); grid on;
ax3.YAxis(1).Color = [0.85 0.55 0.10];
yyaxis right
ylim(ylims_h/100*BW_N);
ylabel('GRF anteroposterior (N)');
ax3.YAxis(2).Color = [0.35 0.35 0.35];
title('GRF horizontal, apoyo (gris punteado = zona no confiable)');

subplot(2,2,4); hold on; box on;
plot(linspace(0,pct_corte,numel(tr.apoyo.angulo_deg)), tr.apoyo.angulo_deg, '-', 'Color', [0.30 0.30 0.30], 'LineWidth', 1.8);
yline(0, '-', 'Color', [0.7 0.7 0.7]);
xlabel('% ciclo (apoyo)'); ylabel('Angulo tibial (deg, 0=vertical)');
title('Angulo de inclinacion tibial, apoyo');
xlim([0 pct_corte]); grid on;

cal_txt = 'calibrado LOSO->Kuopio (Calibracion_Koopman_Kuopio_Core.m)';
if isfield(gr,'calibrar_koopman') && ~gr.calibrar_koopman
    cal_txt = 'SIN calibrar (ganancia LOSO no aplicada, opciones.calibrar_koopman=false)';
end
sgtitle({sprintf('%s | talla=%.2fm masa=%.0fkg %s | %s | solo apoyo (0-%.0f%%)', ...
    candidato, antro_in.talla_m, antro_in.masa_kg, antro_in.sexo, cal_txt, pct_corte), ...
    sprintf('Discrepancia de forma entre pipelines: %.2fcm | GRF vertical media: %.1f%%BW (esperado ~100%%)', discrepancia_cm, gr.verificacion_media_vGRF_pctBW)}, ...
    'FontSize', 9, 'Color', [0.3 0.3 0.3], 'Interpreter', 'none');

out_png = fullfile(carpeta, 'Ver_GRF_y_Trayectoria_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Guardado: %s\n', out_png);

end
