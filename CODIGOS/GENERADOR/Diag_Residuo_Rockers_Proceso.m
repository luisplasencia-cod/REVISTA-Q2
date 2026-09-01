function Diag_Residuo_Rockers_Proceso()
% DIAG_RESIDUO_ROCKERS_PROCESO  30-ago-2026: diagnostico de un solo uso,
%                   pedido explicito del usuario para el informe tecnico -
%                   el residuo de rockers aparecia en la Figura 4/14 ya
%                   como "la curva" (el promedio), sin mostrar de donde
%                   sale. Esta figura muestra el PROCESO: las 13 curvas
%                   REALES del tobillo (Kuopio, cada sujeto, apoyo) y su
%                   promedio simple = exactamente lo que Residuo_Rockers_
%                   Tobillo_Kuopio_Core.m devuelve y lo que se SUMA a la
%                   posicion idealizada del pendulo (Ec. residuo_rockers).
%
%   Punto clave a mostrar visualmente: el residuo NO sale de ningun
%   modelo geometrico ni de Koopman - es dato empirico puro (posicion real
%   promedio), independiente de que el pivote de apoyo se elija en el
%   tobillo o en la cadera. Lo que SI cambiaria con otro pivote es CONTRA
%   QUE se compara ese dato real para definir "el residuo que falta" - ver
%   docstring de Residuo_Rockers_Tobillo_Kuopio_Core.m y CIERRE_TOBILLO.md
%   / TOBILLO/Evaluar_ApoyoCaderaAncla_vs_Kuopio.m para el resultado ya
%   probado de anclar en la cadera (peor: tobillo X r=0.44 vs 0.998).
%
%   No genera tabla ni test - una sola figura.

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta); addpath(fullfile(carpeta, 'RODILLA', 'Kuopio'));

ids = [1,4,13,19,22,25,28,31,37,40,43,46,49];   % MISMOS 13 sujetos que Residuo_Rockers_Tobillo_Kuopio_Core.m
pct_full = 0:100;

Xall = nan(numel(ids), 101); Yall = nan(numel(ids), 101);
ok = false(numel(ids),1);
for k = 1:numel(ids)
    try
        S = Cargar_Kuopio2024_Core(ids(k));
        Xall(k,:) = S.x_horiz_tobillo_cm;
        Yall(k,:) = S.y_vert_tobillo_cm;
        ok(k) = true;
    catch ME
        fprintf('FALLO sujeto %d: %s\n', ids(k), ME.message);
    end
end
idx_ok = find(ok); n_ok = numel(idx_ok);

pc = 61;   % 0-60% = apoyo (frac_apoyo generico del proyecto = 0.60)
pct_ap = pct_full(1:pc);

Xmean = mean(Xall(idx_ok,:), 1);
Ymean = mean(Yall(idx_ok,:), 1);

% chequeo: reproduce EXACTAMENTE Residuo_Rockers_Tobillo_Kuopio_Core.m
res = Residuo_Rockers_Tobillo_Kuopio_Core();
err_x = max(abs(Xmean - res.x_cm));
err_y = max(abs(Ymean - res.y_cm));
fprintf('Chequeo contra Residuo_Rockers_Tobillo_Kuopio_Core.m: error max X=%.2e cm, Y=%.2e cm (debe ser ~0)\n', err_x, err_y);
fprintf('N sujetos: %d/%d\n', n_ok, numel(ids));

col_ind = [0.6 0.6 0.6]; col_mean = [0.20 0.55 0.30];

fig = figure('Name','De donde sale el residuo de rockers','Position',[40 40 1350 900],'Color','w');

subplot(2,2,1); hold on; grid on; box on;
for k = 1:n_ok, i = idx_ok(k); plot(pct_ap, Xall(i,1:pc), '-', 'Color', [col_ind 0.6], 'LineWidth', 0.9); end
plot(pct_ap, Xmean(1:pc), '-', 'Color', col_mean, 'LineWidth', 3);
xlabel('% ciclo (apoyo, 0-60%)'); ylabel('X real del tobillo [cm]');
title(sprintf('PASO 1a - X real de %d sujetos (Kuopio)', n_ok));
legend({'sujeto individual','promedio = residuo'}, 'Location','best');

subplot(2,2,2); hold on; grid on; box on;
for k = 1:n_ok, i = idx_ok(k); plot(pct_ap, Yall(i,1:pc), '-', 'Color', [col_ind 0.6], 'LineWidth', 0.9); end
plot(pct_ap, Ymean(1:pc), '-', 'Color', col_mean, 'LineWidth', 3);
yline(0,'k--','HandleVisibility','off');
xlabel('% ciclo (apoyo, 0-60%)'); ylabel('Y real del tobillo [cm]');
title(sprintf('PASO 1b - Y real de %d sujetos (Kuopio)', n_ok));
legend({'sujeto individual','promedio = residuo'}, 'Location','best');

subplot(2,2,3); hold on; grid on; box on;
plot(pct_ap, zeros(1,pc), 'k--', 'LineWidth', 1.5);
plot(pct_ap, Xmean(1:pc), '-', 'Color', col_mean, 'LineWidth', 2.5);
xlabel('% ciclo'); ylabel('X del tobillo en apoyo [cm]');
title('PASO 2a - Lo que usa el generador: pivote (0,0) SIN residuo vs. CON residuo (X)');
legend({'idealizacion (pivote fijo, sin corregir)','+ residuo = lo que se exporta'}, 'Location','best');

subplot(2,2,4); hold on; grid on; box on;
plot(pct_ap, zeros(1,pc), 'k--', 'LineWidth', 1.5);
plot(pct_ap, Ymean(1:pc), '-', 'Color', col_mean, 'LineWidth', 2.5);
xlabel('% ciclo'); ylabel('Y del tobillo en apoyo [cm]');
title('PASO 2b - Lo mismo, eje Y');
legend({'idealizacion (pivote fijo, sin corregir)','+ residuo = lo que se exporta'}, 'Location','best');

sgtitle('De donde sale el residuo de rockers: promedio de la posicion REAL del tobillo (Kuopio, N=13)', 'FontWeight','bold', 'FontSize', 12);

out_png = fullfile(carpeta, 'Diag_Residuo_Rockers_Proceso_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura guardada en: %s\n', out_png);

end
