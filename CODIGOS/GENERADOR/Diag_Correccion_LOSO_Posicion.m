function Resumen = Diag_Correccion_LOSO_Posicion(hacer_figura)
% DIAG_CORRECCION_LOSO_POSICION  30-ago-2026: diagnostico de un solo uso,
%                   pedido explicito del usuario - extiende
%                   Diag_Correccion_LOSO_Angulo.m (que solo miraba el
%                   angulo de muslo) a la POSICION: X e Y de RODILLA y de
%                   TOBILLO, antes vs despues de la calibracion afin LOSO
%                   de los angulos de Koopman, separado en apoyo (0-60%),
%                   balanceo (60-100%) y ciclo completo.
%
%   REUSA, SIN DIVERGIR, el mismo pipeline de:
%     - RODILLA/Kuopio/Evaluar_vs_Kuopio_Avance.m (geometria de rodilla:
%       avance a velocidad constante + muslo relativo a cadera, plantilla
%       LOSO del vaiven de cadera, cierre de ciclo en Y)
%     - TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases.m (Cadena_Completa_Core +
%       residuo empirico de rockers LOSO + cierre de ciclo en Y + cierre
%       de zancada en X)
%   La UNICA diferencia: aqui se corre el mismo pipeline dos veces por
%   sujeto - una con el angulo CRUDO de Koopman (th_koop, sin calibrar) y
%   otra con el angulo CALIBRADO (LOSO, igual que los scripts originales)
%   - todo lo demas (residuo de rockers, cierres) es IDENTICO en ambas
%   corridas, para aislar especificamente cuanto pesa la calibracion del
%   angulo, no una mezcla de varias correcciones a la vez.
%
%   Split apoyo/balanceo en 60% (convencion generica del proyecto,
%   Temporizacion_Core.m, frac_apoyo default=0.60) para el reporte por
%   fase - no depende de que la corrida "cruda" y la "calibrada" tengan el
%   mismo frac_apoyo (Koopman fija frac_apoyo por antropometria/velocidad,
%   antes de tocar el angulo, asi que es el mismo en las dos corridas).
%
%   No genera tabla ni test - dos figuras (rodilla, tobillo), mismo patron
%   que Diag_Correccion_LOSO_Angulo.m.
%
%   hacer_figura (opcional, default true): false para reusar el calculo
%   (Diag_Resumen_Correccion_Fases.m) sin generar/sobrescribir las 2
%   figuras.
%
%   Resumen (salida opcional): struct 1x4 (Rodilla-X, Rodilla-Y,
%   Tobillo-X, Tobillo-Y), cada uno con los mismos campos que devuelve
%   Diag_Correccion_LOSO_Angulo.m (r_antes/r_despues/rmse_antes/
%   rmse_despues [3x1] + nombres_fase) - agregado 30-ago-2026 para
%   Diag_Resumen_Correccion_Fases.m.

if nargin < 1 || isempty(hacer_figura), hacer_figura = true; end

carpeta = fileparts(mfilename('fullpath'));
dir_kuopio = fullfile(carpeta, 'RODILLA', 'Kuopio');
dir_tobillo = fullfile(carpeta, 'TOBILLO');
addpath(carpeta); addpath(dir_kuopio); addpath(dir_tobillo);

Tmeta = readtable(fullfile(dir_kuopio, 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id; n = numel(ids); npts = 101;
pct = 0:100; pct_frac = pct/100;
idx_apoyo = pct <= 60; idx_balanceo = pct > 60;

% --- Paso 1: cargar sujetos + angulos crudos de Koopman (muslo, tibia via rodilla) ---
Sarr = cell(n,1); Antro = cell(n,1); Tempo = cell(n,1);
Thm_s = cell(n,1); Tht_s = cell(n,1); pct_nat_arr = cell(n,1);
Thm_koop = nan(n,101); Tht_koop = nan(n,101);
Thm_real = nan(n,101); Tht_real = nan(n,101);
pct_corte_arr = nan(n,1);
ok = false(n,1);

for i = 1:n
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, ...
            'sexo', S.sexo(1), 'velocidad_ms', S.speed_ms, ...
            'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000);
        antro = Estimar_Antropometria_Core(antro_in);
        tempo = Temporizacion_Core(antro, 'Koopman');
        [th_m, th_t, tempo] = Obtener_Angulos_Candidato('Koopman', antro, tempo, npts);
        tempo.tiempo_ciclo_s = S.T_ciclo_s;
        tempo.tiempo_apoyo_s = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
        tempo.tiempo_balanceo_s = (1-tempo.frac_apoyo) * tempo.tiempo_ciclo_s;

        pct_corte = tempo.frac_apoyo*100;
        pct_ap  = linspace(0, pct_corte, npts);
        pct_bal = linspace(pct_corte, 100, npts);
        pct_nat = [pct_ap, pct_bal(2:end)];

        Thm_koop(i,:) = interp1(pct_nat, rad2deg([th_m.apoyo th_m.balanceo(2:end)]), pct, 'pchip');
        Tht_koop(i,:) = interp1(pct_nat, rad2deg([th_t.apoyo th_t.balanceo(2:end)]), pct, 'pchip');
        Thm_real(i,:) = rad2deg(atan2(-S.dx_muslo_cm, S.dy_muslo_cm));
        Tht_real(i,:) = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));

        Sarr{i}=S; Antro{i}=antro; Tempo{i}=tempo;
        Thm_s{i}=th_m; Tht_s{i}=th_t; pct_nat_arr{i}=pct_nat;
        pct_corte_arr(i) = pct_corte;
        ok(i) = true;
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
    end
end
idx_ok = find(ok); n_ok = numel(idx_ok);

% --- Paso 2: calibracion afin LOSO de los DOS angulos, IDENTICA a
% TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases.m ---
gan_muslo = nan(n,1); off_muslo = nan(n,1); gan_tibia = nan(n,1); off_tibia = nan(n,1);
for k = 1:n_ok
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
    pm = polyfit(reshape(Thm_koop(otros,:),1,[]), reshape(Thm_real(otros,:),1,[]), 1);
    pt = polyfit(reshape(Tht_koop(otros,:),1,[]), reshape(Tht_real(otros,:),1,[]), 1);
    gan_muslo(i)=pm(1); off_muslo(i)=pm(2);
    gan_tibia(i)=pt(1); off_tibia(i)=pt(2);
end
fprintf('\nCalibracion LOSO: muslo ganancia=%.3f offset=%.2f | tibia ganancia=%.3f offset=%.2f (grados)\n', ...
    mean(gan_muslo(idx_ok)), mean(off_muslo(idx_ok)), mean(gan_tibia(idx_ok)), mean(off_tibia(idx_ok)));

% ================== RODILLA: X,Y antes vs despues ==========================
Xk_real=nan(n,101); Xk_raw=nan(n,101); Xk_cal=nan(n,101);
Yk_real=nan(n,101); Yk_raw=nan(n,101); Yk_cal=nan(n,101);

for k = 1:n_ok
    i = idx_ok(k); S = Sarr{i};
    L_m_cm = S.muslo_mm / 10;
    th_raw = deg2rad(Thm_koop(i,:));
    th_cal = deg2rad(off_muslo(i)) + gan_muslo(i)*th_raw;

    dx_raw = L_m_cm*sin(th_raw); dx_raw = dx_raw - dx_raw(1);
    dy_raw = L_m_cm*(1-cos(th_raw)); dy_raw = dy_raw - dy_raw(1);
    dx_cal = L_m_cm*sin(th_cal); dx_cal = dx_cal - dx_cal(1);
    dy_cal = L_m_cm*(1-cos(th_cal)); dy_cal = dy_cal - dy_cal(1);

    avance_cm = S.speed_ms * pct_frac * S.T_ciclo_s * 100;
    x_raw = avance_cm + dx_raw;
    x_cal = avance_cm + dx_cal;

    otros = idx_ok(idx_ok ~= i);
    bob_loso = zeros(1,101);
    for j = otros(:)', bob_loso = bob_loso + Sarr{j}.y_vert_hip_cm; end
    bob_loso = bob_loso / numel(otros);

    y_raw = bob_loso + dy_raw;  y_raw = y_raw + linspace(0, -y_raw(end), 101);
    y_cal = bob_loso + dy_cal;  y_cal = y_cal + linspace(0, -y_cal(end), 101);

    Xk_real(i,:)=S.x_horiz_cm; Xk_raw(i,:)=x_raw; Xk_cal(i,:)=x_cal;
    Yk_real(i,:)=S.y_vert_cm;  Yk_raw(i,:)=y_raw; Yk_cal(i,:)=y_cal;
end

% ================== TOBILLO: X,Y antes vs despues ===========================
Xt_real=nan(n,101); Xt_raw=nan(n,101); Xt_cal=nan(n,101);
Yt_real=nan(n,101); Yt_raw=nan(n,101); Yt_cal=nan(n,101);

for k = 1:n_ok
    i = idx_ok(k); S = Sarr{i};
    th_m = Thm_s{i}; th_t = Tht_s{i};

    th_m_cal = struct('apoyo', deg2rad(off_muslo(i)) + gan_muslo(i)*th_m.apoyo, ...
                       'balanceo', deg2rad(off_muslo(i)) + gan_muslo(i)*th_m.balanceo);
    th_t_cal = struct('apoyo', deg2rad(off_tibia(i)) + gan_tibia(i)*th_t.apoyo, ...
                       'balanceo', deg2rad(off_tibia(i)) + gan_tibia(i)*th_t.balanceo);

    cc_raw = Cadena_Completa_Core(th_m, th_t, Antro{i}.long_muslo_m, Antro{i}.long_tibia_m, Tempo{i}, npts);
    cc_cal = Cadena_Completa_Core(th_m_cal, th_t_cal, Antro{i}.long_muslo_m, Antro{i}.long_tibia_m, Tempo{i}, npts);

    tob_x_raw = interp1(pct_nat_arr{i}, [cc_raw.apoyo.tobillo_x_cm, cc_raw.balanceo.tobillo_x_cm(2:end)], pct, 'pchip');
    tob_y_raw = interp1(pct_nat_arr{i}, [cc_raw.apoyo.tobillo_y_cm, cc_raw.balanceo.tobillo_y_cm(2:end)], pct, 'pchip');
    tob_x_cal = interp1(pct_nat_arr{i}, [cc_cal.apoyo.tobillo_x_cm, cc_cal.balanceo.tobillo_x_cm(2:end)], pct, 'pchip');
    tob_y_cal = interp1(pct_nat_arr{i}, [cc_cal.apoyo.tobillo_y_cm, cc_cal.balanceo.tobillo_y_cm(2:end)], pct, 'pchip');

    % residuo de rockers (LOSO sobre el dato REAL - no depende de raw/cal, IDENTICO en ambas)
    pc = round(pct_corte_arr(i)) + 1;
    otros = idx_ok(idx_ok ~= i);
    residuo_x_ap = zeros(1, pc); residuo_y_ap = zeros(1, pc);
    for j = otros(:)'
        residuo_x_ap = residuo_x_ap + Sarr{j}.x_horiz_tobillo_cm(1:pc);
        residuo_y_ap = residuo_y_ap + Sarr{j}.y_vert_tobillo_cm(1:pc);
    end
    residuo_x_ap = residuo_x_ap / numel(otros);
    residuo_y_ap = residuo_y_ap / numel(otros);

    zancada_cm = S.speed_ms * S.T_ciclo_s * 100;
    [tob_x_raw, tob_y_raw] = aplicar_rockers_y_cierres(tob_x_raw, tob_y_raw, pc, residuo_x_ap, residuo_y_ap, zancada_cm);
    [tob_x_cal, tob_y_cal] = aplicar_rockers_y_cierres(tob_x_cal, tob_y_cal, pc, residuo_x_ap, residuo_y_ap, zancada_cm);

    Xt_real(i,:)=S.x_horiz_tobillo_cm; Xt_raw(i,:)=tob_x_raw; Xt_cal(i,:)=tob_x_cal;
    Yt_real(i,:)=S.y_vert_tobillo_cm;  Yt_raw(i,:)=tob_y_raw; Yt_cal(i,:)=tob_y_cal;
end

% ================== metricas por fase + figuras =============================
fases = struct('nombre', {'Apoyo (0-60%)','Balanceo (60-100%)','Ciclo completo'}, ...
               'idx', {idx_apoyo, idx_balanceo, true(1,101)});

fprintf('\n=== RODILLA - X (horizontal) ===\n');
Rk_x = reportar_fases(Xk_real(idx_ok,:), Xk_raw(idx_ok,:), Xk_cal(idx_ok,:), fases, 'cm');
fprintf('\n=== RODILLA - Y (vertical) ===\n');
Rk_y = reportar_fases(Yk_real(idx_ok,:), Yk_raw(idx_ok,:), Yk_cal(idx_ok,:), fases, 'cm');
fprintf('\n=== TOBILLO - X (horizontal) ===\n');
Rt_x = reportar_fases(Xt_real(idx_ok,:), Xt_raw(idx_ok,:), Xt_cal(idx_ok,:), fases, 'cm');
fprintf('\n=== TOBILLO - Y (vertical) ===\n');
Rt_y = reportar_fases(Yt_real(idx_ok,:), Yt_raw(idx_ok,:), Yt_cal(idx_ok,:), fases, 'cm');

Resumen = [Rk_x, Rk_y, Rt_x, Rt_y];
Resumen(1).etiqueta='Rodilla X'; Resumen(2).etiqueta='Rodilla Y';
Resumen(3).etiqueta='Tobillo X'; Resumen(4).etiqueta='Tobillo Y';

if ~hacer_figura, return; end

dibujar_figura_articulacion('RODILLA', pct, idx_apoyo, Xk_real(idx_ok,:), Xk_raw(idx_ok,:), Xk_cal(idx_ok,:), ...
    Yk_real(idx_ok,:), Yk_raw(idx_ok,:), Yk_cal(idx_ok,:), n_ok, fullfile(carpeta, 'Diag_Correccion_LOSO_Posicion_Rodilla_figura.png'));

dibujar_figura_articulacion('TOBILLO', pct, idx_apoyo, Xt_real(idx_ok,:), Xt_raw(idx_ok,:), Xt_cal(idx_ok,:), ...
    Yt_real(idx_ok,:), Yt_raw(idx_ok,:), Yt_cal(idx_ok,:), n_ok, fullfile(carpeta, 'Diag_Correccion_LOSO_Posicion_Tobillo_figura.png'));

end

% ==========================================================================
function [tob_x, tob_y] = aplicar_rockers_y_cierres(tob_x, tob_y, pc, residuo_x_ap, residuo_y_ap, zancada_cm)
tob_x(1:pc) = tob_x(1:pc) + residuo_x_ap;  tob_x(pc+1:end) = tob_x(pc+1:end) + residuo_x_ap(end);
tob_y(1:pc) = tob_y(1:pc) + residuo_y_ap;  tob_y(pc+1:end) = tob_y(pc+1:end) + residuo_y_ap(end);

exceso = tob_y(end); n_bal = numel(tob_y) - pc;
tob_y(pc+1:end) = tob_y(pc+1:end) + linspace(0, -exceso, n_bal);

w = (tob_x - tob_x(1)) / max(tob_x(end) - tob_x(1), eps);
tob_x = tob_x + (zancada_cm - tob_x(end)) * w;
end

% ==========================================================================
function R = reportar_fases(Real, Raw, Cal, fases, unidad)
r_antes=nan(3,1); r_despues=nan(3,1); rmse_antes=nan(3,1); rmse_despues=nan(3,1);
for f = 1:3
    m = fases(f).idx;
    r_a = arrayfun(@(k) corr(Real(k,m)', Raw(k,m)'), 1:size(Real,1));
    r_d = arrayfun(@(k) corr(Real(k,m)', Cal(k,m)'), 1:size(Real,1));
    e_a = arrayfun(@(k) sqrt(mean((Raw(k,m)-Real(k,m)).^2)), 1:size(Real,1));
    e_d = arrayfun(@(k) sqrt(mean((Cal(k,m)-Real(k,m)).^2)), 1:size(Real,1));
    dm  = arrayfun(@(k) mean(Cal(k,m)-Raw(k,m)), 1:size(Real,1));
    r_antes(f)=mean(r_a); r_despues(f)=mean(r_d);
    rmse_antes(f)=mean(e_a); rmse_despues(f)=mean(e_d);
    fprintf('%-20s r %.3f -> %.3f | RMSE %6.2f -> %6.2f %s | correccion media (con signo) = %+.2f %s\n', ...
        fases(f).nombre, r_antes(f), r_despues(f), rmse_antes(f), rmse_despues(f), unidad, mean(dm), unidad);
end
R = struct('nombres_fase', {{fases.nombre}}, 'r_antes', r_antes, 'r_despues', r_despues, ...
    'rmse_antes', rmse_antes, 'rmse_despues', rmse_despues, 'unidad', unidad);
end

% ==========================================================================
function dibujar_figura_articulacion(nombre, pct, idx_apoyo, Xreal, Xraw, Xcal, Yreal, Yraw, Ycal, n_ok, out_png)
col_raw = [0.85 0.33 0.10]; col_cal = [0.20 0.55 0.30]; col_real = [0.45 0.45 0.45];
xr = [0 60 60 0];

fig = figure('Name',sprintf('%s: posicion antes/despues de LOSO',nombre),'Position',[20 20 1550 850],'Color','w');

% --- fila 1: X ---
yl = ylim_seguro(Xreal, [Xraw;Xcal]);
subplot(2,3,1); hold on; grid on; box on;
patch(xr,[yl(1) yl(1) yl(2) yl(2)],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
plot(pct, Xreal', '-', 'Color',[col_real 0.5],'LineWidth',0.9);
plot(pct, Xraw', '-', 'Color',[col_raw 0.7],'LineWidth',0.9);
xlabel('% ciclo'); ylabel('X horizontal [cm]');
title(sprintf('%s X - ANTES (crudo)', nombre));

subplot(2,3,2); hold on; grid on; box on;
patch(xr,[yl(1) yl(1) yl(2) yl(2)],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
plot(pct, Xreal', '-', 'Color',[col_real 0.5],'LineWidth',0.9);
plot(pct, Xcal', '-', 'Color',[col_cal 0.7],'LineWidth',0.9);
xlabel('% ciclo'); ylabel('X horizontal [cm]');
title(sprintf('%s X - DESPUES (LOSO)', nombre));

subplot(2,3,3); hold on; grid on; box on;
patch(xr,[-1000 -1000 1000 1000],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
Dx = Xcal - Xraw; m=mean(Dx,1); s=std(Dx,0,1);
fill([pct fliplr(pct)], [m+s fliplr(m-s)], [0.3 0.3 0.3],'FaceAlpha',0.18,'EdgeColor','none');
plot(pct, Dx', '-', 'Color',[0.6 0.6 0.6 0.5],'LineWidth',0.6);
plot(pct, m, '-', 'Color','k','LineWidth',2.2); yline(0,'k--');
ylim(padded_ylim(m,s));
xlabel('% ciclo'); ylabel('Correccion en X [cm] (cal - crudo)');
title(sprintf('%s: tamano de la correccion en X', nombre));

% --- fila 2: Y ---
yl2 = ylim_seguro(Yreal, [Yraw;Ycal]);
subplot(2,3,4); hold on; grid on; box on;
patch(xr,[yl2(1) yl2(1) yl2(2) yl2(2)],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
plot(pct, Yreal', '-', 'Color',[col_real 0.5],'LineWidth',0.9);
plot(pct, Yraw', '-', 'Color',[col_raw 0.7],'LineWidth',0.9);
xlabel('% ciclo'); ylabel('Y vertical [cm]');
title(sprintf('%s Y - ANTES (crudo)', nombre));
legend({'apoyo (0-60%)','real (por sujeto)','crudo (por sujeto)'},'Location','best');

subplot(2,3,5); hold on; grid on; box on;
patch(xr,[yl2(1) yl2(1) yl2(2) yl2(2)],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
plot(pct, Yreal', '-', 'Color',[col_real 0.5],'LineWidth',0.9);
plot(pct, Ycal', '-', 'Color',[col_cal 0.7],'LineWidth',0.9);
xlabel('% ciclo'); ylabel('Y vertical [cm]');
title(sprintf('%s Y - DESPUES (LOSO)', nombre));
legend({'apoyo (0-60%)','real (por sujeto)','LOSO (por sujeto)'},'Location','best');

subplot(2,3,6); hold on; grid on; box on;
patch(xr,[-1000 -1000 1000 1000],[0.9 0.95 1],'EdgeColor','none','FaceAlpha',0.6);
Dy = Ycal - Yraw; m2=mean(Dy,1); s2=std(Dy,0,1);
fill([pct fliplr(pct)], [m2+s2 fliplr(m2-s2)], [0.3 0.3 0.3],'FaceAlpha',0.18,'EdgeColor','none');
plot(pct, Dy', '-', 'Color',[0.6 0.6 0.6 0.5],'LineWidth',0.6);
plot(pct, m2, '-', 'Color','k','LineWidth',2.2); yline(0,'k--');
ylim(padded_ylim(m2,s2));
xlabel('% ciclo'); ylabel('Correccion en Y [cm] (cal - crudo)');
title(sprintf('%s: tamano de la correccion en Y', nombre));

sgtitle(sprintf('%s vs Kuopio 2024 (N=%d real): posicion ANTES (Koopman crudo) vs DESPUES (angulo calibrado LOSO)', nombre, n_ok), 'FontWeight','bold');

exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura guardada en: %s\n', out_png);
end

% ==========================================================================
function yl = ylim_seguro(A, B)
v = [A(:); B(:)]; v = v(~isnan(v));
lo = min(v); hi = max(v); pad = 0.05*(hi-lo);
yl = [lo-pad, hi+pad];
end

function yl = padded_ylim(m, s)
lo = min(m-s); hi = max(m+s); pad = max(0.3, 0.15*(hi-lo));
yl = [lo-pad, hi+pad];
end
