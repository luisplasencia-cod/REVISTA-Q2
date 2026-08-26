function [T, D] = Evaluar_vs_Kuopio_Avance(hacer_figura)
% EVALUAR_VS_KUOPIO_AVANCE  25-ago-2026: posicion ABSOLUTA (marco de
%                   laboratorio, overground real) de la rodilla, en los
%                   2 ejes, con calibracion de GANANCIA (LOSO) final.
%
%   HORIZONTAL (avance): X(t) = velocidad_real*t + X_relativa_a_cadera(t)
%     Probado con Ferber (cinta) primero -> descartado (no hay avance neto
%     real que reconstruir en cinta). Con Kuopio (overground real) ->
%     r_x=0.996 geometrico.
%
%   VERTICAL: Y(t) = cadera_vertical_bob(t) + Y_relativa_a_cadera(t)
%     cadera_vertical_bob(t): plantilla EMPIRICA (LOSO, sin Ferber - el
%     usuario objeto correctamente que Ferber es cinta, mismo problema que
%     el avance horizontal) + cierre de ciclo.
%
%   CALIBRACION AL NIVEL DEL ANGULO, NO DE LA POSICION (25-ago-2026,
%   reemplaza la calibracion de ganancia sobre X/Y que habia antes):
%   Koopman reproduce la FORMA del ciclo casi exacta (r=0.971 contra el
%   angulo de muslo real de Kuopio) pero SOBREESTIMA la excursion angular
%   ~21% en esta poblacion (amplitud 39.2 grados vs 32.5 real). Se corrige
%   con una calibracion afin theta_real = a + b*theta_Koopman ajustada por
%   LOSO (a,b de cada sujeto salen de los OTROS 14) - misma tecnica y misma
%   magnitud que ya se habia encontrado de forma independiente para el
%   angulo tibial (ganancia 0.811, ver INCLINACION_TIBIAL/) - es UN SOLO
%   defecto del modelo publicado, no uno por eje.
%
%   POR QUE ESTO REEMPLAZA A LA CALIBRACION DE POSICION: al calibrar la
%   POSICION ya sumada al vaiven de cadera se mezclaban dos errores
%   distintos, y la ganancia resultante (b=0.361) aplastaba la curva -
%   el modelo reproducia solo el 51% de la excursion vertical real, con un
%   RMSE que parecia bueno solo porque la senal es chica. Calibrando el
%   angulo (donde esta el error) la amplitud sube a 82% del real Y ademas
%   mejoran r y RMSE en los dos ejes: Y r 0.887->0.920, RMSE 1.01->0.72cm;
%   X r 0.996->0.998, RMSE 4.85->3.97cm. Ya no hay ninguna calibracion a
%   nivel de posicion.
%
%   PROBADO Y DESCARTADO (mismo dia): agregar una plantilla LOSO de la
%   desviacion horizontal de la cadera respecto de velocidad constante
%   (amplitud real 6.9cm, consistencia entre sujetos solo r=0.61) -
%   EMPEORA X (RMSE 3.97 -> 4.27cm). Se mantiene el avance a velocidad
%   constante, que es ademas lo que el generador puede usar sin datos
%   medidos.
%
%   RMSEnorm NO se usa aqui: estas curvas estan forzadas a 0 en pct=0 para
%   todo sujeto (SD entre sujetos ~0 en los primeros %ciclo), lo que
%   distorsiona esa normalizacion - se reporta RMSE en cm.
%
%   Antropometria REAL por sujeto (S.muslo_mm de Kuopio, medida, no
%   estimada). Velocidad y duracion de ciclo REALES (S.speed_ms,
%   S.T_ciclo_s). N=15 sujetos piloto, 3 trials 'comf' c/u, eventos de
%   Zeni et al. 2008 (Cargar_Kuopio2024_Core.m).
%
%   SALIDAS
%     T : tabla por sujeto (metricas + antropometria)
%     D : struct con las curvas por sujeto (pct, sub_id, sexo, talla_cm,
%         masa_kg, X_real, X_pred, Y_real, Y_pred) - lo consume
%         Evaluar_Individual_Kuopio.m para que exista UNA SOLA
%         implementacion del modelo (el individual no puede divergir del
%         que reportan estas estadisticas).
%
%   hacer_figura (opcional, default true): false para reusar el calculo
%   sin generar/sobrescribir la figura de grupo.
%
%   NOTA SOBRE LA FIGURA (25-ago-2026, objecion correcta del usuario):
%   los paneles ya NO grafican media(real) vs media(predicho). Promediar
%   curvas de sujetos con talla/masa distintas mezcla trayectorias que no
%   son directamente comparables entre si. En su lugar cada sujeto se
%   muestra PAREADO con su propia prediccion (que usa SU antropometria y
%   SU velocidad medida), mas las curvas de error por sujeto - ambas
%   validas con antropometria heterogenea.

if nargin < 1 || isempty(hacer_figura), hacer_figura = true; end

addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..'));
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
addpath(fileparts(mfilename('fullpath')));

carpeta = fileparts(mfilename('fullpath'));
Tmeta = readtable(fullfile(carpeta, 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id;
n = numel(ids);

pct = 0:100; pct_frac = pct/100;

% --- Paso 1: cargar los 15 sujetos, angulo de muslo REAL y de Koopman ---
Sarr = cell(n,1);
Th_real = nan(n,101);   % angulo de muslo REAL (grados, 0=vertical)
Th_koop = nan(n,101);   % angulo de muslo de Koopman, misma malla
sub_id = zeros(n,1); sexo = strings(n,1); talla_cm = zeros(n,1); masa_kg = zeros(n,1);
n_ciclos = zeros(n,1); speed_ms = nan(n,1); T_ciclo_s = nan(n,1);
ok = false(n,1);

for i = 1:n
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1));
        antro = Estimar_Antropometria_Core(antro_in);
        % velocidad REAL medida (S.speed_ms), NO Froude (ver CIERRE_TOBILLO.md #4)
        K = Koopman2014_Core(S.speed_ms*3.6, antro.talla_m);
        pct_K = linspace(0,100,numel(K.cadera_flexext.angulo_deg));
        Th_koop(i,:) = interp1(pct_K, K.cadera_flexext.angulo_deg, pct, 'pchip');
        % angulo de muslo real: vector cadera-rodilla, 0=vertical, misma
        % convencion (atan2) que el angulo tibial de INCLINACION_TIBIAL/
        Th_real(i,:) = rad2deg(atan2(-S.dx_muslo_cm, S.dy_muslo_cm));

        Sarr{i} = S;
        sub_id(i) = sid; sexo(i) = S.sexo; talla_cm(i) = S.talla_cm; masa_kg(i) = S.masa_kg;
        n_ciclos(i) = S.n_ciclos; speed_ms(i) = S.speed_ms; T_ciclo_s(i) = S.T_ciclo_s;
        ok(i) = true;
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
    end
end

idx_ok = find(ok);
n_ok = numel(idx_ok);

% --- Paso 2: calibracion AFIN LOSO del ANGULO de muslo ---
Th_cal = nan(n,101); ganancia_ang = nan(n,1); offset_ang = nan(n,1);
r_ang = nan(n,1); rmse_ang_crudo = nan(n,1); rmse_ang_cal = nan(n,1);
for k = 1:n_ok
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
    p = polyfit(reshape(Th_koop(otros,:),1,[]), reshape(Th_real(otros,:),1,[]), 1);
    ganancia_ang(i) = p(1); offset_ang(i) = p(2);
    Th_cal(i,:) = polyval(p, Th_koop(i,:));
    r_ang(i) = corr(Th_real(i,:)', Th_koop(i,:)');
    rmse_ang_crudo(i) = sqrt(mean((Th_koop(i,:)-Th_real(i,:)).^2));
    rmse_ang_cal(i)   = sqrt(mean((Th_cal(i,:) -Th_real(i,:)).^2));
end

% --- Paso 3: geometria -> posicion absoluta (SIN calibracion de posicion) ---
X_real_all = nan(n,101); X_pred_all = nan(n,101);
Y_real_all = nan(n,101); Y_pred_all = nan(n,101);
r_x_abs = nan(n,1); rmse_x_abs = nan(n,1);
r_y_abs = nan(n,1); rmse_y_abs = nan(n,1);

for k = 1:n_ok
    i = idx_ok(k); S = Sarr{i};
    L_m_cm = S.muslo_mm / 10;
    th = deg2rad(Th_cal(i,:));
    dx = L_m_cm * sin(th);          dx = dx - dx(1);
    dy = L_m_cm * (1 - cos(th));    dy = dy - dy(1);

    % X: avance a velocidad constante + rodilla relativa a cadera
    avance_cm = S.speed_ms * pct_frac * S.T_ciclo_s * 100;
    x_pred = avance_cm + dx;

    % Y: plantilla LOSO del vaiven vertical de la cadera + rodilla rel.cadera
    otros = idx_ok(idx_ok ~= i);
    bob_loso = zeros(1,101);
    for j = otros(:)', bob_loso = bob_loso + Sarr{j}.y_vert_hip_cm; end
    bob_loso = bob_loso / numel(otros);
    y_pred = bob_loso + dy;

    % CIERRE DE CICLO (25-ago-2026, mismo hallazgo que en TOBILLO - ver
    % CIERRE_TOBILLO.md #7-bis): en marcha periodica la rodilla debe
    % terminar el ciclo a la misma altura de donde partio. Restriccion
    % fisica exacta (periodicidad), no un ajuste arbitrario. X no cierra
    % (avanza una zancada real por ciclo) y por eso no se le aplica.
    y_pred = y_pred + linspace(0, -y_pred(end), 101);

    X_real_all(i,:) = S.x_horiz_cm; X_pred_all(i,:) = x_pred;
    Y_real_all(i,:) = S.y_vert_cm;  Y_pred_all(i,:) = y_pred;

    r_x_abs(i) = corr(X_real_all(i,:)', x_pred(:));
    rmse_x_abs(i) = sqrt(mean((X_real_all(i,:)-x_pred).^2));
    r_y_abs(i) = corr(Y_real_all(i,:)', y_pred(:));
    rmse_y_abs(i) = sqrt(mean((Y_real_all(i,:)-y_pred).^2));
end

T = table(sub_id, sexo, talla_cm, masa_kg, n_ciclos, speed_ms, T_ciclo_s, ...
    r_ang, rmse_ang_crudo, rmse_ang_cal, ganancia_ang, offset_ang, ...
    r_x_abs, rmse_x_abs, r_y_abs, rmse_y_abs);
T = T(ok,:);

D = struct('pct', pct, 'sub_id', sub_id(ok), 'sexo', sexo(ok), ...
    'talla_cm', talla_cm(ok), 'masa_kg', masa_kg(ok), ...
    'X_real', X_real_all(ok,:), 'X_pred', X_pred_all(ok,:), ...
    'Y_real', Y_real_all(ok,:), 'Y_pred', Y_pred_all(ok,:));

ampR_y = mean(max(Y_real_all(ok,:),[],2)-min(Y_real_all(ok,:),[],2));
ampP_y = mean(max(Y_pred_all(ok,:),[],2)-min(Y_pred_all(ok,:),[],2));

fprintf('\n=== RODILLA, MODELO FINAL (angulo calibrado LOSO -> geometria) : %d/%d sujetos OK ===\n', n_ok, n);
fprintf('ANGULO de muslo: r=%.3f, RMSE %.2f -> %.2f grados | ganancia=%.3f, offset=%.2f grados\n', ...
    mean(T.r_ang), mean(T.rmse_ang_crudo), mean(T.rmse_ang_cal), mean(T.ganancia_ang), mean(T.offset_ang));
fprintf('HORIZONTAL: r=%.3f (SD=%.3f), RMSE=%.2fcm\n', mean(T.r_x_abs), std(T.r_x_abs), mean(T.rmse_x_abs));
fprintf('VERTICAL:   r=%.3f (SD=%.3f), RMSE=%.2fcm | amplitud modelo/real=%.2f\n', ...
    mean(T.r_y_abs), std(T.r_y_abs), mean(T.rmse_y_abs), ampP_y/ampR_y);

writetable(T, fullfile(carpeta, 'Evaluar_vs_Kuopio_Avance_resultados.csv'));
fprintf('Tabla guardada en: %s\n', fullfile(carpeta, 'Evaluar_vs_Kuopio_Avance_resultados.csv'));

if ~hacer_figura, return; end

% ---------------- Figura de grupo (PAREADA, sin promediar sujetos) ------
col_x = [0.85 0.33 0.10]; col_y = [0.20 0.45 0.70];
fig = figure('Name','Rodilla vs Kuopio 2024 (overground real, N=15)','Position',[40 20 1250 1050],'Color','w');

subplot(3,2,1); hold on; grid on; box on;
for k=1:n_ok, i=idx_ok(k); plot(pct, X_real_all(i,:), '-', 'Color',[0.55 0.55 0.55 0.85], 'LineWidth',1.1); end
for k=1:n_ok, i=idx_ok(k); plot(pct, X_pred_all(i,:), '-', 'Color',[col_x 0.85], 'LineWidth',1.1); end
xlabel('% ciclo'); ylabel('X horizontal ABSOLUTO [cm]');
title(sprintf('X: cada sujeto con SU prediccion (r=%.3f, RMSE=%.2fcm)', mean(T.r_x_abs), mean(T.rmse_x_abs)));
legend({'real (por sujeto)','modelo (por sujeto)'},'Location','northwest');

subplot(3,2,2); hold on; grid on; box on;
for k=1:n_ok, i=idx_ok(k); plot(pct, Y_real_all(i,:), '-', 'Color',[0.55 0.55 0.55 0.85], 'LineWidth',1.1); end
for k=1:n_ok, i=idx_ok(k); plot(pct, Y_pred_all(i,:), '-', 'Color',[col_y 0.85], 'LineWidth',1.1); end
xlabel('% ciclo'); ylabel('Y vertical ABSOLUTO [cm]');
title(sprintf('Y: cada sujeto con SU prediccion (r=%.3f, RMSE=%.2fcm)', mean(T.r_y_abs), mean(T.rmse_y_abs)));
legend({'real (por sujeto)','modelo (por sujeto)'},'Location','northwest');

Ex = X_pred_all(idx_ok,:) - X_real_all(idx_ok,:);
Ey = Y_pred_all(idx_ok,:) - Y_real_all(idx_ok,:);
dibujar_error(subplot(3,2,3), pct, Ex, col_x, 'Error X (modelo - real) [cm]');
dibujar_error(subplot(3,2,4), pct, Ey, col_y, 'Error Y (modelo - real) [cm]');

subplot(3,2,5); hold on; grid on; box on;
histogram(T.r_x_abs, 10, 'FaceColor',col_x);
xlabel('r horizontal, por sujeto'); ylabel('N sujetos'); xlim(rango_r(T.r_x_abs));
title(sprintf('Distribucion r horizontal, N=%d', n_ok));

subplot(3,2,6); hold on; grid on; box on;
histogram(T.r_y_abs, 10, 'FaceColor',col_y);
xlabel('r vertical, por sujeto'); ylabel('N sujetos'); xlim(rango_r(T.r_y_abs));
title(sprintf('Distribucion r vertical, N=%d', n_ok));

sgtitle(sprintf('RODILLA vs Kuopio 2024 (overground, N=%d) - angulo de Koopman calibrado (afin, LOSO) -> geometria', n_ok), 'FontWeight','bold');

out_png = fullfile(carpeta, 'Evaluar_vs_Kuopio_Avance_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura guardada en: %s\n', out_png);

end

% ------------------------------------------------------------------------
function lim = rango_r(r)
% Limites del histograma de r ajustados a los datos. Con xlim([-1 1]) fijo,
% 15 sujetos todos entre 0.99 y 1.00 salen como una sola barra pegada al
% borde, ilegible - se pierde justamente la dispersion que el panel deberia
% mostrar. Se deja un piso en 0 para que siga siendo evidente el signo.
lo = min(r); hi = max(r);
margen = max(0.02, 0.15*(hi-lo));
lim = [max(0, lo-margen), min(1, hi+margen)];
if diff(lim) < 0.02, lim = [max(0, lim(1)-0.01), min(1, lim(2)+0.01)]; end
end

% ------------------------------------------------------------------------
function dibujar_error(ax, pct, E, col, etiqueta)
% Curvas de error por sujeto + banda media+-SD. Valida con antropometria
% heterogenea (a diferencia de promediar las trayectorias en si).
axes(ax); hold on; grid on; box on; %#ok<LAXES>
m = mean(E,1); s = std(E,0,1);
fill([pct fliplr(pct)], [m+s fliplr(m-s)], col, 'FaceAlpha',0.18, 'EdgeColor','none');
plot(pct, E', '-', 'Color',[0.55 0.55 0.55 0.7], 'LineWidth',0.8);
plot(pct, m, '-', 'Color',col, 'LineWidth',2.5);
yline(0,'k--');
xlabel('% ciclo'); ylabel(etiqueta);
title(sprintf('%s  |  media+-SD entre sujetos', etiqueta));
end
