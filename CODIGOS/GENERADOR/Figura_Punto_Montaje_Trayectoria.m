function Figura_Punto_Montaje_Trayectoria(talla_m, d_montaje_cm)
% FIGURA_PUNTO_MONTAJE_TRAYECTORIA  02-sep-2026: genera la figura del
%                   informe tecnico que explica COMO se obtiene la
%                   trayectoria del PUNTO DE MONTAJE PROTESICO a partir de
%                   la distancia tobillo->montaje (longitud del eje de la
%                   protesis), que es el dato que la app pide ademas de la
%                   talla (App_Animacion_Cadera_Rodilla_Tobillo.m, campo
%                   "Punto de montaje (cm desde tobillo)").
%
%   Figura_Punto_Montaje_Trayectoria()                 % talla 1.71 m, d=20 cm
%   Figura_Punto_Montaje_Trayectoria(talla_m, d_cm)
%
% QUE MUESTRA (3 paneles):
%   (a) Cadena sagital cadera-rodilla-tobillo en varios instantes del
%       ciclo, con el punto de montaje marcado SOBRE el segmento tibial a
%       distancia d del tobillo (Aplicar_Punto_Montaje_Core.m).
%   (b) Trayectoria (x,y) de rodilla, tobillo y punto de montaje - se ve
%       que el montaje describe una curva INTERMEDIA entre tobillo y
%       rodilla, tanto mas parecida a la rodilla cuanto mayor es d.
%   (c) Desplazamiento X e Y del punto de montaje vs %ciclo (lo que
%       finalmente ejecutaria el simulador para ese punto).
%
% PIPELINE USADO: identico al de produccion/la app con las dos
% correcciones activas - talla -> antropometria (Drillis&Contini) ->
% temporizacion (Froude) -> Koopman con v/l CONGELADOS
% (congelar_vl_angulo, ver GUIA_INTERPRETACION.md #10) -> calibracion afin
% LOSO -> pendulo doble -> correccion hibrida (warp+PAVA en X, Fourier en
% Y) -> Aplicar_Punto_Montaje_Core.
% ==========================================================================

if nargin < 1 || isempty(talla_m), talla_m = 1.71; end
if nargin < 2 || isempty(d_montaje_cm), d_montaje_cm = 20; end

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta);
n = 101; pct = linspace(0,100,n);
cal = Calibracion_Koopman_Kuopio_Core();

antro = Estimar_Antropometria_Core(struct('talla_m', talla_m));
tempo = Temporizacion_Core(antro, 'Koopman');
K1 = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, ...
    struct('nMuestras', n, 'congelar_vl_angulo', true, 'v_ref_kph', 5.0, 'l_ref_m', 1.735));
theta1 = deg2rad(K1.cadera_flexext.angulo_deg(:).');
theta2 = K1.theta_tibia_via_rodilla_rad(:).';
theta1c = deg2rad(cal.off_muslo_deg) + cal.gan_muslo*theta1;
theta2c = deg2rad(cal.off_tibia_deg) + cal.gan_tibia*theta2;
L1 = antro.long_muslo_m*100; L2 = antro.long_tibia_m*100;
zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;
cad = Trayectoria_Cadera_Core(pct, zancada_cm, 2.25, 0);
p = Cinematica_DoblePendulo_Core(theta1c, theta2c, L1, L2, cad.Xh_cm, cad.Yh_cm);
c = Correccion_Hibrida_PenduloDoble_Core(pct, p.Xk-p.Xk(1), p.Yk-p.Yk(1), ...
    p.Xa-p.Xa(1), p.Ya-p.Ya(1), tempo.velocidad_ms);

% Reponer los offsets que la normalizacion a cero quita, para trabajar en
% coordenadas geometricas reales (misma trampa documentada en
% INCLINACION_TIBIAL/CIERRE_INCLINACION_TIBIAL.md Sec.3).
Xk = c.Xk + p.Xk(1); Yk = c.Yk + p.Yk(1);
Xa = c.Xa + p.Xa(1); Ya = c.Ya + p.Ya(1);
Xh = cad.Xh_cm;      Yh = cad.Yh_cm;

pm = Aplicar_Punto_Montaje_Core(Xa, Ya, Xk, Yk, d_montaje_cm);
Xm = pm.Xm_cm; Ym = pm.Ym_cm;

col_rod = [0.00 0.30 0.70]; col_tob = [0.85 0.33 0.10]; col_mon = [0.10 0.60 0.25];
fig = figure('Position',[60 60 1300 520], 'Color','w');

% ---- (a) cadena sagital en varios instantes ----
subplot(1,3,1); hold on; grid on; box on; axis equal;
inst = round(linspace(1, n, 7));
for k = inst
    plot([Xh(k) Xk(k) Xa(k)], [Yh(k) Yk(k) Ya(k)], '-', 'Color',[0.6 0.6 0.6 0.7], 'LineWidth',1.2);
    plot(Xm(k), Ym(k), 'o', 'MarkerSize',5, 'MarkerFaceColor',col_mon, 'MarkerEdgeColor','none');
end
plot(Xk, Yk, '-', 'Color',col_rod, 'LineWidth',1.6);
plot(Xa, Ya, '-', 'Color',col_tob, 'LineWidth',1.6);
plot(Xm, Ym, '-', 'Color',col_mon, 'LineWidth',2.2);
xlabel('x (cm)'); ylabel('y (cm)');
title(sprintf('(a) Cadena sagital + punto de montaje\n(d=%.0f cm desde tobillo, L_{tibia}=%.1f cm)', d_montaje_cm, L2));
legend({'cadena (instantes)','montaje'}, 'Location','northwest', 'FontSize',7);

% ---- (b) trayectorias comparadas ----
subplot(1,3,2); hold on; grid on; box on; axis equal;
plot(Xk, Yk, '-', 'Color',col_rod, 'LineWidth',2, 'DisplayName','rodilla');
plot(Xa, Ya, '-', 'Color',col_tob, 'LineWidth',2, 'DisplayName','tobillo');
plot(Xm, Ym, '-', 'Color',col_mon, 'LineWidth',2.4, 'DisplayName',sprintf('montaje (d=%.0f cm)', d_montaje_cm));
xlabel('x (cm)'); ylabel('y (cm)');
title('(b) Trayectoria: el montaje queda entre tobillo y rodilla');
legend('Location','best','FontSize',7);

% ---- (c) desplazamiento vs %ciclo del punto de montaje ----
subplot(1,3,3); hold on; grid on; box on;
plot(pct, Xm - Xm(1), '-', 'Color',col_mon, 'LineWidth',2.2, 'DisplayName','montaje X');
plot(pct, Ym - Ym(1), '--', 'Color',col_mon, 'LineWidth',2.2, 'DisplayName','montaje Y');
plot(pct, Xa - Xa(1), '-', 'Color',[col_tob 0.5], 'LineWidth',1.3, 'DisplayName','tobillo X');
plot(pct, Ya - Ya(1), '--', 'Color',[col_tob 0.5], 'LineWidth',1.3, 'DisplayName','tobillo Y');
xlabel('% ciclo'); ylabel('desplazamiento (cm, relativo a 0%)');
title(sprintf('(c) Salida final del punto de montaje\n(avance %.1f cm, ROM vertical %.1f cm)', Xm(end)-Xm(1), range(Ym)));
legend('Location','northwest','FontSize',7);

sgtitle(sprintf('Trayectoria del PUNTO DE MONTAJE protesico -- talla %.2f m, d=%.0f cm desde el tobillo', ...
    talla_m, d_montaje_cm), 'FontWeight','bold','FontSize',11);

out_png = fullfile(carpeta, 'Figura_Punto_Montaje_Trayectoria.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura: %s\n', out_png);

% --- Chequeos numericos que acompañan a la figura (van al informe) ---
% Definicion vigente desde 03-sep-2026: el punto se calcula sobre el
% segmento REAL rodilla-tobillo (ver Aplicar_Punto_Montaje_Core.m), asi
% que las dos propiedades de abajo son EXACTAS por construccion, no una
% aproximacion - se imprimen igual para dejar el numero verificado en el
% log de esta figura.
d_real = sqrt((Xm-Xa).^2 + (Ym-Ya).^2);
d_seg  = pm.L_segmento_cm;   % longitud REAL del segmento rodilla-tobillo tras la correccion
fuera_seg = abs((Xk-Xa).*(Ym-Ya) - (Yk-Ya).*(Xm-Xa)) ./ d_seg;  % distancia del punto a la recta
fprintf('Distancia montaje->tobillo: %.4f-%.4f cm (pedido %.1f, err max %.2e) -- EXACTA por construccion\n', ...
    min(d_real), max(d_real), d_montaje_cm, max(abs(d_real-d_montaje_cm)));
fprintf('Longitud REAL del segmento rodilla-tobillo tras la correccion: %.1f-%.1f cm (nominal L_tibia=%.1f cm, se desvia hasta %.1f%% por la correccion de posicion)\n', ...
    min(d_seg), max(d_seg), L2, 100*max(abs(d_seg-L2))/L2);
fprintf('Distancia del punto de montaje a la recta rodilla-tobillo: max %.2e cm -- SOBRE el segmento por construccion\n', max(fuera_seg));
fprintf('Retrocesos en X del montaje: %d de %d pasos\n', sum(diff(Xm)<-1e-9), n-1);
end
