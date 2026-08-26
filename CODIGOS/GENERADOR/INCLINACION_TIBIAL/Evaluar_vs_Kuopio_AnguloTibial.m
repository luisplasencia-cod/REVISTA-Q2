function [T, D] = Evaluar_vs_Kuopio_AnguloTibial(hacer_figura)
% EVALUAR_VS_KUOPIO_ANGULOTIBIAL  25-ago-2026: valida el ANGULO de
%                   inclinacion tibial (theta_tibia, 0=vertical) contra
%                   Kuopio 2024 (overground real, N=15), con velocidad
%                   REAL medida como entrada a Koopman2014_Core (misma
%                   metodologia ya establecida en RODILLA/TOBILLO).
%
%   MODELO FINAL: Koopman (angulo crudo) + CALIBRACION AFIN, LOSO.
%   Motivo: la forma ya es casi perfecta (r=0.992) pero con un sesgo
%   SISTEMATICO y consistente entre sujetos - offset medio +10.09 grados
%   (SD=2.07, poco disperso) y ganancia media 0.802 (SD=0.096, Koopman
%   sobreestima el rango ~20%). Como el sesgo es consistente (no ruido),
%   se corrige con una calibracion afin (theta_final = a + b*theta_koopman)
%   ajustada por LOSO (los coeficientes a,b de cada sujeto salen de
%   los OTROS 14, nunca de si mismo - sin circularidad, misma tecnica ya
%   usada en RODILLA/TOBILLO para el vaiven de cadera).
%
%   Resultado (RMSEnorm = escala del PROPIO proyecto, ver
%   CODIGOS/VALIDACIONES/Calcular_Metricas_Curva.m - normaliza el error
%   por el SD entre sujetos en cada %ciclo):
%     Sin calibrar:      RMSE=11.24 grados, RMSEnorm=3.53 -> "Deficiente"
%     Con calibracion:   RMSE=3.50 grados,  RMSEnorm=0.92 -> "Excelente"
%     (r=0.992 en ambos casos - una transformacion afin no cambia r)
%
%   MAPEO:
%   - DE KOOPMAN 2014 (sin modificar): theta_tibia_via_rodilla_deg.
%   - NUESTRO APORTE: calibracion afin LOSO (offset+ganancia) - corrige un
%     sesgo sistematico real, no inventado (ver bias/ganancia por sujeto
%     en la tabla de resultados) - metodologicamente identico al
%     principio de correccion de offset ya usado en CODIGOS/CALIBRACION/
%     del proyecto (calibracion de instrumento con IC), aplicado aqui a
%     la salida del modelo en vez de al sensor.
%   - KUOPIO: dato real (angulo derivado por geometria de S.dx_tibia_cm/
%     S.dy_tibia_cm, ver Cargar_Kuopio2024_Core.m) - fuente tanto de la
%     validacion final como de los coeficientes LOSO de calibracion.
%
%   SALIDAS
%     T : tabla por sujeto. D : struct con las curvas por sujeto - lo
%     consume Evaluar_Individual_Kuopio_AnguloTibial.m para que exista UNA
%     SOLA implementacion del modelo.
%   hacer_figura (opcional, default true): false para reusar el calculo sin
%   generar/sobrescribir la figura de grupo.
%
%   NOTA SOBRE LA FIGURA (25-ago-2026, objecion correcta del usuario): los
%   paneles ya NO grafican media(real) vs media(predicho) - promediar
%   curvas de sujetos con talla/masa/velocidad distintas mezcla
%   trayectorias que no son comparables entre si, y el modelo se alimenta
%   justamente de esos datos. Se muestran pares por sujeto y curvas de
%   error, ambos validos con antropometria heterogenea.

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

% --- Paso 1: angulo real y prediccion cruda (Koopman, velocidad real) ---
for i = 1:n
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
        theta_real_deg = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));

        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1));
        antro = Estimar_Antropometria_Core(antro_in);
        K = Koopman2014_Core(S.speed_ms*3.6, antro.talla_m);
        t_K = K.theta_tibia_via_rodilla_deg;
        pct_K = linspace(0,100,numel(t_K));
        theta_pred_deg = interp1(pct_K, t_K, pct, 'pchip');

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

fprintf('\n=== ANGULO TIBIAL vs Kuopio 2024, N=%d ===\n', sum(ok));
fprintf('SIN calibrar:  r=%.3f, RMSE=%.2f grados, RMSEnorm=%.3f\n', mean(T.r_crudo), mean(T.rmse_crudo), mean(T.rmsenorm_crudo));
fprintf('CALIBRADO (afin LOSO): r=%.3f, RMSE=%.2f grados, RMSEnorm=%.3f\n', mean(T.r_cal), mean(T.rmse_cal), mean(T.rmsenorm_cal));
fprintf('Coeficientes de calibracion (media entre sujetos): ganancia=%.3f, offset=%.2f grados\n', mean(T.ganancia_b), mean(T.offset_a));

writetable(T, fullfile(carpeta, 'Evaluar_vs_Kuopio_AnguloTibial_resultados.csv'));
fprintf('Tabla: %s\n', fullfile(carpeta, 'Evaluar_vs_Kuopio_AnguloTibial_resultados.csv'));

D = struct('pct', pct, 'sub_id', sub_id(ok), 'sexo', sexo(ok), ...
    'talla_cm', talla_cm(ok), 'masa_kg', masa_kg(ok), 'sd_fase', sd_fase, ...
    'Ang_real', Ang_real_all(ok,:), 'Ang_crudo', Ang_pred_crudo_all(ok,:), ...
    'Ang_cal', Ang_pred_cal_all(ok,:));

if ~hacer_figura, return; end

% ---------------- Figura de grupo (PAREADA, sin promediar sujetos) ------
col_c = [0.85 0.33 0.10]; col_k = [0.20 0.45 0.70];
fig = figure('Name','Angulo tibial vs Kuopio 2024 - MODELO FINAL calibrado','Position',[40 20 1250 1050],'Color','w');

subplot(3,2,1); hold on; grid on; box on;
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Ang_real_all(i,:), '-','Color',[0.55 0.55 0.55 0.85],'LineWidth',1.1); end
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Ang_pred_crudo_all(i,:), '-','Color',[col_c 0.85],'LineWidth',1.1); end
xlabel('% ciclo'); ylabel('\theta_{tibia} [grados]');
title(sprintf('SIN calibrar: cada sujeto con SU prediccion (r=%.3f, RMSEnorm=%.2f)', mean(T.r_crudo), mean(T.rmsenorm_crudo)));
legend({'real (por sujeto)','Koopman crudo (por sujeto)'},'Location','northwest');

subplot(3,2,2); hold on; grid on; box on;
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Ang_real_all(i,:), '-','Color',[0.55 0.55 0.55 0.85],'LineWidth',1.1); end
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Ang_pred_cal_all(i,:), '-','Color',[col_k 0.85],'LineWidth',1.1); end
xlabel('% ciclo'); ylabel('\theta_{tibia} [grados]');
title(sprintf('MODELO FINAL calibrado LOSO (r=%.3f, RMSEnorm=%.2f)', mean(T.r_cal), mean(T.rmsenorm_cal)));
legend({'real (por sujeto)','Koopman calibrado (por sujeto)'},'Location','northwest');

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

sgtitle(sprintf('ANGULO TIBIAL vs Kuopio 2024 (overground, N=%d) - Koopman crudo vs calibrado (afin, LOSO)', sum(ok)), 'FontWeight','bold');
out_png = fullfile(carpeta, 'Evaluar_vs_Kuopio_AnguloTibial_figura.png');
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
