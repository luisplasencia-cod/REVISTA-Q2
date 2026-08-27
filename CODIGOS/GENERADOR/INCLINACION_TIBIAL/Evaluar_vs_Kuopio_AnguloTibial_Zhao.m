function [T, D] = Evaluar_vs_Kuopio_AnguloTibial_Zhao(hacer_figura)
% EVALUAR_VS_KUOPIO_ANGULOTIBIAL_ZHAO  27-ago-2026: replica EXACTA de
%                   Evaluar_vs_Kuopio_AnguloTibial.m (Koopman) pero con
%                   Zhao 2026 como candidato. Ver PLAN_ZHAO_YUN.md,
%                   seccion INCLINACION_TIBIAL, y DECISIONES.md D2 - se
%                   usa el default NATIVO de Zhao2026_Core.m
%                   (opciones.lado='izquierda'), SIN "truco de lado".
%                   Si el resultado sale con r bajo/negativo por el
%                   defasaje de fase ya documentado en
%                   RODILLA/CIERRE_RODILLA.md, es el resultado esperado y
%                   se reporta tal cual - no se fuerza una correccion.
%
%   MODELO EVALUADO: Zhao (angulo tibial nativo, theta_tibia_rad =
%   phi_cadera - phi_rodilla, Sec.2.6 del paper) + CALIBRACION AFIN LOSO
%   (mismo procedimiento que Koopman, para que la comparacion entre
%   candidatos sea igual de justa - la calibracion no cambia r, solo
%   escala/offset).
%
%   DIFERENCIA CLAVE vs. Koopman (unica diferencia real del pipeline):
%     Koopman: K = Koopman2014_Core(S.speed_ms*3.6, antro.talla_m);
%              t_K = K.theta_tibia_via_rodilla_deg;
%     Zhao:    Z = Zhao2026_Core(antro.long_muslo_m+antro.long_tibia_m, ...
%                  1/S.T_ciclo_s);
%              t_Z = rad2deg(Z.theta_tibia_rad);
%              (cadencia REAL medida del sujeto, 1/S.T_ciclo_s, no
%              estimada - D2: dato medido > estimado. long de pierna =
%              muslo+tibia, ya calculados por Estimar_Antropometria_Core).
%   Todo lo demas (angulo real vs Kuopio, calibracion afin LOSO,
%   metricas r/RMSE/RMSEnorm, figura pareada 3x2) es IDENTICO en
%   estructura al script de Koopman.
%
%   SALIDAS
%     T : tabla por sujeto. D : struct con las curvas por sujeto - lo
%     consume Evaluar_Individual_Kuopio_AnguloTibial_Zhao.m para que
%     exista UNA SOLA implementacion del modelo.
%   hacer_figura (opcional, default true): false para reusar el calculo sin
%   generar/sobrescribir la figura de grupo.

if nargin < 1 || isempty(hacer_figura), hacer_figura = true; end

carpeta = fileparts(mfilename('fullpath'));
dir_generador = fullfile(carpeta, '..');
dir_kuopio = fullfile(carpeta, '..', 'RODILLA', 'Kuopio');
addpath(dir_generador);
addpath(dir_kuopio);

Tmeta = readtable(fullfile(dir_kuopio, 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id;
n = numel(ids);
pct = 0:100;

sub_id = zeros(n,1); sexo = strings(n,1); talla_cm = zeros(n,1); masa_kg = zeros(n,1);
Ang_real_all = nan(n,101); Ang_pred_crudo_all = nan(n,101);
ok = false(n,1);

% --- Paso 1: angulo real y prediccion cruda (Zhao, cadencia real) ---
for i = 1:n
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
        theta_real_deg = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));

        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1));
        antro = Estimar_Antropometria_Core(antro_in);
        Z = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/S.T_ciclo_s);
        t_Z = rad2deg(Z.theta_tibia_rad);
        pct_Z = linspace(0,100,numel(t_Z));
        theta_pred_deg = interp1(pct_Z, t_Z, pct, 'pchip');

        Ang_real_all(i,:) = theta_real_deg; Ang_pred_crudo_all(i,:) = theta_pred_deg;
        sub_id(i)=sid; sexo(i)=S.sexo; talla_cm(i)=S.talla_cm; masa_kg(i)=S.masa_kg;
        ok(i) = true;
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
    end
end
idx_ok = find(ok);

% --- Paso 2: calibracion afin LOSO + metricas (crudo y calibrado) ---
r_crudo = nan(n,1); rmse_crudo = nan(n,1); rmsenorm_crudo = nan(n,1);
r_cal = nan(n,1); rmse_cal = nan(n,1); rmsenorm_cal = nan(n,1);
offset_a = nan(n,1); ganancia_b = nan(n,1);
Ang_pred_cal_all = nan(n,101);

sd_fase = std(Ang_real_all(idx_ok,:), 0, 1);
sd_fase(sd_fase < 1e-6) = 1e-6;

for k = 1:numel(idx_ok)
    i = idx_ok(k);
    real_i = Ang_real_all(i,:); pred_i = Ang_pred_crudo_all(i,:);

    r_crudo(i) = corr(real_i(:), pred_i(:));
    err_crudo = pred_i - real_i;
    rmse_crudo(i) = sqrt(mean(err_crudo.^2));
    rmsenorm_crudo(i) = sqrt(mean((err_crudo./sd_fase).^2));

    otros = idx_ok(idx_ok ~= i);
    p = polyfit(reshape(Ang_pred_crudo_all(otros,:),1,[]), reshape(Ang_real_all(otros,:),1,[]), 1);
    offset_a(i) = p(2); ganancia_b(i) = p(1);

    pred_cal = polyval(p, pred_i);
    Ang_pred_cal_all(i,:) = pred_cal;
    r_cal(i) = corr(real_i(:), pred_cal(:));
    err_cal = pred_cal - real_i;
    rmse_cal(i) = sqrt(mean(err_cal.^2));
    rmsenorm_cal(i) = sqrt(mean((err_cal./sd_fase).^2));
end

T = table(sub_id, sexo, talla_cm, masa_kg, r_crudo, rmse_crudo, rmsenorm_crudo, ...
    ganancia_b, offset_a, r_cal, rmse_cal, rmsenorm_cal);
T = T(ok,:);

fprintf('\n=== ANGULO TIBIAL (ZHAO 2026) vs Kuopio 2024, N=%d ===\n', sum(ok));
fprintf('SIN calibrar:  r=%.3f, RMSE=%.2f grados, RMSEnorm=%.3f\n', mean(T.r_crudo), mean(T.rmse_crudo), mean(T.rmsenorm_crudo));
fprintf('CALIBRADO (afin LOSO): r=%.3f, RMSE=%.2f grados, RMSEnorm=%.3f\n', mean(T.r_cal), mean(T.rmse_cal), mean(T.rmsenorm_cal));
fprintf('Coeficientes de calibracion (media entre sujetos): ganancia=%.3f, offset=%.2f grados\n', mean(T.ganancia_b), mean(T.offset_a));

writetable(T, fullfile(carpeta, 'Evaluar_vs_Kuopio_AnguloTibial_Zhao_resultados.csv'));
fprintf('Tabla: %s\n', fullfile(carpeta, 'Evaluar_vs_Kuopio_AnguloTibial_Zhao_resultados.csv'));

D = struct('pct', pct, 'sub_id', sub_id(ok), 'sexo', sexo(ok), ...
    'talla_cm', talla_cm(ok), 'masa_kg', masa_kg(ok), 'sd_fase', sd_fase, ...
    'Ang_real', Ang_real_all(ok,:), 'Ang_crudo', Ang_pred_crudo_all(ok,:), ...
    'Ang_cal', Ang_pred_cal_all(ok,:));

if ~hacer_figura, return; end

% ---------------- Figura de grupo (PAREADA, sin promediar sujetos) ------
col_c = [0.85 0.33 0.10]; col_k = [0.20 0.45 0.70];
fig = figure('Name','Angulo tibial (Zhao 2026) vs Kuopio 2024','Position',[40 20 1250 1050],'Color','w');

subplot(3,2,1); hold on; grid on; box on;
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Ang_real_all(i,:), '-','Color',[0.55 0.55 0.55 0.85],'LineWidth',1.1); end
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Ang_pred_crudo_all(i,:), '-','Color',[col_c 0.85],'LineWidth',1.1); end
xlabel('% ciclo'); ylabel('\theta_{tibia} [grados]');
title(sprintf('SIN calibrar: cada sujeto con SU prediccion (r=%.3f, RMSEnorm=%.2f)', mean(T.r_crudo), mean(T.rmsenorm_crudo)));
legend({'real (por sujeto)','Zhao crudo (por sujeto)'},'Location','northwest');

subplot(3,2,2); hold on; grid on; box on;
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Ang_real_all(i,:), '-','Color',[0.55 0.55 0.55 0.85],'LineWidth',1.1); end
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Ang_pred_cal_all(i,:), '-','Color',[col_k 0.85],'LineWidth',1.1); end
xlabel('% ciclo'); ylabel('\theta_{tibia} [grados]');
title(sprintf('MODELO calibrado LOSO (r=%.3f, RMSEnorm=%.2f)', mean(T.r_cal), mean(T.rmsenorm_cal)));
legend({'real (por sujeto)','Zhao calibrado (por sujeto)'},'Location','northwest');

Ec = Ang_pred_crudo_all(idx_ok,:) - Ang_real_all(idx_ok,:);
Ek = Ang_pred_cal_all(idx_ok,:)   - Ang_real_all(idx_ok,:);
lim_e = max(abs([Ec(:); Ek(:)]));
dibujar_error_ang(subplot(3,2,3), pct, Ec, col_c, 'Error SIN calibrar [grados]', lim_e);
dibujar_error_ang(subplot(3,2,4), pct, Ek, col_k, 'Error CALIBRADO [grados]', lim_e);

subplot(3,2,5); hold on; grid on; box on;
histogram(T.rmsenorm_crudo,10,'FaceColor',col_c);
xline(1,'k--'); xline(2,'k:');
xlabel('RMSEnorm por sujeto'); ylabel('N sujetos');
title('RMSEnorm SIN calibrar (<1 Excelente, >2 Deficiente)');

subplot(3,2,6); hold on; grid on; box on;
histogram(T.rmsenorm_cal,10,'FaceColor',col_k);
xline(1,'k--'); xline(2,'k:');
xlabel('RMSEnorm por sujeto'); ylabel('N sujetos');
title('RMSEnorm CALIBRADO (escala del proyecto)');

sgtitle(sprintf('ANGULO TIBIAL (ZHAO 2026) vs Kuopio 2024 (overground, N=%d) - crudo vs calibrado (afin, LOSO)', sum(ok)), 'FontWeight','bold');
out_png = fullfile(carpeta, 'Evaluar_vs_Kuopio_AnguloTibial_Zhao_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura: %s\n', out_png);

end

% ------------------------------------------------------------------------
function dibujar_error_ang(ax, pct, E, col, etiqueta, lim_e)
axes(ax); hold on; grid on; box on; %#ok<LAXES>
m = mean(E,1); s = std(E,0,1);
fill([pct fliplr(pct)], [m+s fliplr(m-s)], col, 'FaceAlpha',0.18, 'EdgeColor','none');
plot(pct, E', '-', 'Color',[0.55 0.55 0.55 0.7], 'LineWidth',0.8);
plot(pct, m, '-', 'Color',col, 'LineWidth',2.5);
yline(0,'k--');
xlabel('% ciclo'); ylabel(etiqueta); ylim([-lim_e lim_e]);   % misma escala en ambos paneles
title(sprintf('%s  |  media+-SD entre sujetos', etiqueta));
end
