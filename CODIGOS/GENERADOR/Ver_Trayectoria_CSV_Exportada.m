function out = Ver_Trayectoria_CSV_Exportada(antro_in, opciones)
% VER_TRAYECTORIA_CSV_EXPORTADA  Grafica EXACTAMENTE lo que Generar_
%   Trayectoria.m/Escribir_CSV_Simulador.m escribirian al CSV real (02-sep
%   -2026, pedido del usuario tras conectar el pipeline nuevo al
%   exportador) - para comparar visualmente contra la vista de App_
%   Animacion_Cadera_Rodilla_Tobillo.m (que usa la MISMA convencion de
%   signo, ya que se verifico que este pipeline no necesita inversion de
%   X/Y - ver cabecera de Generar_Trayectoria.m y Verificar_Signo_X_
%   PenduloDoble.m).
%
%   Ver_Trayectoria_CSV_Exportada()                          % talla 1.73m
%   Ver_Trayectoria_CSV_Exportada(antro_in)                  % antropometria propia
%   Ver_Trayectoria_CSV_Exportada(antro_in, opciones)        % + punto_seguimiento_m
%
% ENTRADA (todas opcionales)
%   antro_in   struct .talla_m/.masa_kg/.sexo, ver Generar_Trayectoria.m
%   opciones   struct .punto_seguimiento_m, ver Generar_Trayectoria.m
%
% SALIDA: out = la misma salida de Generar_Trayectoria.m (para inspeccion
%   adicional en la consola si hace falta).
% ==========================================================================
if nargin < 1 || isempty(antro_in)
    antro_in = struct('talla_m', 1.73, 'masa_kg', 70, 'sexo', 'M');
end
if nargin < 2, opciones = struct(); end

out = Generar_Trayectoria(antro_in, opciones);

t_completo   = [out.apoyo.t_s, out.apoyo.t_s(end) + out.balanceo.t_s(2:end)];
x_completo   = [out.apoyo.x_cm, out.balanceo.x_cm(2:end)];
y_completo   = [out.apoyo.y_cm, out.balanceo.y_cm(2:end)];
ang_completo = [out.apoyo.angulo_deg, out.balanceo.angulo_deg(2:end)];
n_ap = numel(out.apoyo.t_s);

fig = figure('Name', 'Trayectoria tal cual se exportaria al CSV', 'Position', [80 80 1150 780]);

ax1 = subplot(2,2,1, 'Parent', fig);
plot(ax1, t_completo, x_completo, '-', 'LineWidth', 1.6); hold(ax1, 'on');
xline(ax1, out.apoyo.t_s(end), '--', 'Color', [0.5 0.5 0.5]);
plot(ax1, t_completo(1:n_ap), x_completo(1:n_ap), '-', 'LineWidth', 2.2, 'Color', [0.15 0.35 0.75]);
plot(ax1, t_completo(n_ap:end), x_completo(n_ap:end), '-', 'LineWidth', 2.2, 'Color', [0.75 0.30 0.15]);
title(ax1, 'Posicion X (cm) - convencion del CSV real, sin invertir'); xlabel(ax1, 'tiempo (s)'); ylabel(ax1, 'X (cm)');
legend(ax1, {'', 'corte apoyo/balanceo', 'apoyo', 'balanceo'}, 'Location', 'best'); grid(ax1, 'on');

ax2 = subplot(2,2,2, 'Parent', fig);
plot(ax2, t_completo(1:n_ap), y_completo(1:n_ap), '-', 'LineWidth', 2.2, 'Color', [0.15 0.35 0.75]); hold(ax2, 'on');
plot(ax2, t_completo(n_ap:end), y_completo(n_ap:end), '-', 'LineWidth', 2.2, 'Color', [0.75 0.30 0.15]);
xline(ax2, out.apoyo.t_s(end), '--', 'Color', [0.5 0.5 0.5]);
title(ax2, 'Posicion Y (cm) - convencion del CSV real'); xlabel(ax2, 'tiempo (s)'); ylabel(ax2, 'Y (cm)');
legend(ax2, {'apoyo', 'balanceo'}, 'Location', 'best'); grid(ax2, 'on');

ax3 = subplot(2,2,3, 'Parent', fig);
plot(ax3, t_completo(1:n_ap), ang_completo(1:n_ap), '-', 'LineWidth', 2.2, 'Color', [0.15 0.35 0.75]); hold(ax3, 'on');
plot(ax3, t_completo(n_ap:end), ang_completo(n_ap:end), '-', 'LineWidth', 2.2, 'Color', [0.75 0.30 0.15]);
xline(ax3, out.apoyo.t_s(end), '--', 'Color', [0.5 0.5 0.5]);
title(ax3, 'Angulo tibial exportado (deg)'); xlabel(ax3, 'tiempo (s)'); ylabel(ax3, 'angulo (deg)');
legend(ax3, {'apoyo', 'balanceo'}, 'Location', 'best'); grid(ax3, 'on');

ax4 = subplot(2,2,4, 'Parent', fig);
plot(ax4, x_completo(1:n_ap), y_completo(1:n_ap), '-o', 'MarkerSize', 2, 'LineWidth', 1.6, 'Color', [0.15 0.35 0.75]); hold(ax4, 'on');
plot(ax4, x_completo(n_ap:end), y_completo(n_ap:end), '-o', 'MarkerSize', 2, 'LineWidth', 1.6, 'Color', [0.75 0.30 0.15]);
axis(ax4, 'equal'); grid(ax4, 'on');
title(ax4, 'Mapa sagital (X vs Y) - lo que ejecutaria el simulador'); xlabel(ax4, 'X (cm)'); ylabel(ax4, 'Y (cm)');
legend(ax4, {'apoyo', 'balanceo'}, 'Location', 'best');

sgtitle(fig, sprintf('talla=%.2fm, punto\\_seguimiento=%.3fm - convencion CSV real (sin inversion, verificado 02-sep-2026)', ...
    antro_in.talla_m, out.metadatos.punto_seguimiento_m), 'FontWeight', 'bold');

end
