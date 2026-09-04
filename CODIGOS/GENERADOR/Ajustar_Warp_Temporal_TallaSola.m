% AJUSTAR_WARP_TEMPORAL_TALLASOLA  31-ago-2026 / 01-sep-2026: ajusta los
% coeficientes del warp temporal (Warp_Temporal_Core.m) + afin CONSTANTE,
% para las curvas de AVANCE (RodX, TobX) - reemplaza a Correccion_
% Posicion_Suave_PenduloDoble_Core.m SOLO para esas 2 curvas (Rodilla Y /
% Tobillo Y se quedan con Fourier, ver Correccion_Hibrida_PenduloDoble_
% Core.m). SOLO TALLA como entrada (igual regla que Refit_
% CorreccionFinal_TallaSola.m, mismo patron: LOSO real primero para
% validar honesto, ajuste agrupado N=44 despues para desplegar).
%
% Motivo del cambio (comparacion completa con Fourier/16-tramos en
% docs/algoritmo/informe_tecnico_generador/informe_tecnico_generador.tex,
% seccion "Corrección de posición"): la correccion de amplitud (Fourier)
% puede introducir retrocesos (hasta 22/100 pasos en tobillo X) porque
% nada en su formulacion impide que b(t) cambie de signo o crezca
% localmente. El warp temporal SI lo impide, por construccion
% matematica (Warp_Temporal_Core.m).
%
% CAMBIO 01-sep-2026 (pedido del usuario, "no me parece logico que una
% persona de menor estatura tenga mayor desplazamiento que una mas alta"):
% la version anterior usaba un afin DEPENDIENTE de velocidad, alpha(v)=
% a0+a1*v, beta(v)=b0+b1*v (v=velocidad Froude-estimada desde la talla).
% Se encontro que el avance REAL (X al 100% del ciclo) no correlaciona
% con la talla ni con v_froude dentro de los 44 sujetos de Kuopio (r=
% -0.01), asi que el ajuste de minimos cuadrados aprendia una beta(v) que
% CANCELABA la escala natural con talla del crudo (que si es r=1.000 con
% talla, por construccion geometrica) - el resultado final quedaba casi
% constante entre sujetos de distinta talla, e incluso en algun caso el
% sujeto MAS BAJO terminaba con mayor avance que uno MAS ALTO -
% fisicamente ilogico aunque fuera el optimo de RMSE contra Kuopio.
%
% SOLUCION: se elimino la dependencia de velocidad/talla del afin -
% ahora es CONSTANTE (a0, b0 fijos, un solo b0>0 para todos los sujetos).
% Como el crudo(100%) SI es monotono en talla (r=1.000, geometria pura),
% y una transformacion afin con b0>0 preserva el orden, el resultado
% final queda GARANTIZADO monotono en talla (a mas talla, igual o mas
% avance) - una propiedad matematica, no una casualidad del ajuste.
% Probado y descartado (01-sep-2026, ver Comparar_Talla_vs_V_Covariable.m
% en el historial de la sesion): agregar talla como covariable de alpha
% con la restriccion a1>=0 (que hubiera preservado la monotonia igual
% que esto) - el optimizador convergio a a1=0.0000 exacto, es decir el
% mejor ajuste POSIBLE que no rompe la monotonia YA es este modelo
% constante - no hay una covariable derivada de la talla que ayude sin
% romper el orden fisico.
% Costo de este cambio: RMSE en cm practicamente igual (11.44 vs 11.54cm
% rodilla, 9.52 vs 9.48cm tobillo - diferencia despreciable), RMSEnorm
% pasa de 0.96/0.98 (Excelente) a 1.10/1.17 (Bueno, sigue bien lejos de
% Deficiente).

% CORREGIDO 01-sep-2026 (el usuario senalo la inconsistencia con N=51):
% antes la lista de sujetos se armaba con dir('*_l_comf_01.csv'), que
% exige exactamente el trial numero 01 - 3 sujetos (02, 30, 39) SI tienen
% datos utilizables en disco pero con otro numero de trial (su comf_01
% nunca existio en la fuente, ver RODILLA/Kuopio/raw/
% _extraccion_28ago_51sujetos_log.txt), y quedaban excluidos sin motivo
% real. Se cambia a la MISMA regla que ya usan Cargar_Kuopio2024_Core.m y
% Evaluar_vs_Kuopio_AnguloTibial.m: intentar los 51 ids de subjects_meta.csv
% y descartar solo los que de verdad fallan al cargar. Sube N de 44 a 47 -
% el limite real (4 sujetos, 07/09/10/24, sin el marcador RTibia_RFoot_score
% en NINGUN trial, ver mismo log) no lo mueve ningun cambio de codigo.
carpeta = fileparts(mfilename('fullpath'));
carpeta_kuopio = fullfile(carpeta, 'RODILLA', 'Kuopio');
addpath(carpeta_kuopio);
Tmeta_ids = readtable(fullfile(carpeta_kuopio, 'raw', 'subjects_meta.csv'));
ids = Tmeta_ids.sub_id(:).';
n = 101; pct = linspace(0,100,n); pts_norm = 2:n;
K_WARP = 2;   % elegido por barrido LOSO real N=44 (K=2,4,6,8,10,12) -
              % RMSEnorm ya en su meseta desde K=2, ver GUIA_INTERPRETACION.md
cal = Calibracion_Koopman_Kuopio_Core();
campos = {'RodX','TobX'};
nombres = {'RODILLA X','TOBILLO X'};

% ---------- cargar TODO con SOLO TALLA (igual que la app) ----------
S_all = struct('id',{},'pos_cal',{},'RealRodX',{},'RealTobX',{});
for i = 1:numel(ids)
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
    catch
        continue;
    end
    if numel(S.x_horiz_cm) ~= n, continue; end

    antro = Estimar_Antropometria_Core(struct('talla_m', S.talla_cm/100));
    tempo = Temporizacion_Core(antro, 'Koopman');
    % congelar_vl_angulo=true (02-sep-2026): mismo motivo que en
    % Refit_CorreccionFinal_TallaSola.m - el warp se ajusta sobre el crudo
    % que produccion realmente genera. Ver GUIA_INTERPRETACION.md #10.
    Kd = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, ...
        struct('nMuestras', n, 'congelar_vl_angulo', true, 'v_ref_kph', 5.0, 'l_ref_m', 1.735));
    theta1 = deg2rad(Kd.cadera_flexext.angulo_deg(:).');
    theta2 = Kd.theta_tibia_via_rodilla_rad(:).';
    theta1c = deg2rad(cal.off_muslo_deg) + cal.gan_muslo*theta1;
    theta2c = deg2rad(cal.off_tibia_deg) + cal.gan_tibia*theta2;
    L1_cm = antro.long_muslo_m*100; L2_cm = antro.long_tibia_m*100;
    zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;
    cadT = Trayectoria_Cadera_Core(pct, zancada_cm, 2.25, 0);
    posc = Cinematica_DoblePendulo_Core(theta1c, theta2c, L1_cm, L2_cm, cadT.Xh_cm, cadT.Yh_cm);

    k = numel(S_all) + 1;
    S_all(k).id = sid;
    S_all(k).pos_cal = struct('RodX', posc.Xk-posc.Xk(1), 'TobX', posc.Xa-posc.Xa(1));
    S_all(k).RealRodX = S.x_horiz_cm(:).'; S_all(k).RealTobX = S.x_horiz_tobillo_cm(:).';
end
N = numel(S_all);
fprintf('N sujetos: %d\n', N);

Real = struct();
for c = 1:2, Real.(campos{c}) = cell2mat(arrayfun(@(k) S_all(k).(['Real' campos{c}]), 1:N, 'uni',0)'); end
SD = struct();
for c = 1:2, SD.(campos{c}) = std(Real.(campos{c}), 0, 1); end

opts_lsq = optimoptions('lsqnonlin', 'Display', 'off', 'MaxFunctionEvaluations', 5000);
lb = []; % sin restriccion explicita de signo en el ajuste (b0>0 sale solo del ajuste,
         % verificado abajo) - K_WARP=2 y el termino b0 ya domina la escala.

% ---------- LOSO real para validar ----------
for c = 1:2, PredLOSO.(campos{c}) = nan(N,n); end
for i = 1:N
    otros = setdiff(1:N, i);
    for c = 1:2
        camp = campos{c};
        crudos_otros = cell2mat(arrayfun(@(k) S_all(k).pos_cal.(camp), otros, 'uni', 0)');
        reales_otros = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), otros, 'uni', 0)');
        p0 = zeros(2*K_WARP+2, 1); p0(2*K_WARP+2) = 1;
        fun = @(p) residuo_warp(p, pct, K_WARP, crudos_otros, reales_otros);
        p_fit = lsqnonlin(fun, p0, lb, [], opts_lsq);
        PredLOSO.(camp)(i,:) = aplicar_warp_afin(p_fit, pct, K_WARP, S_all(i).pos_cal.(camp));
    end
end

fprintf('\n=== SOLO TALLA, WARP TEMPORAL + AFIN CONSTANTE (LOSO real, N=%d, K=%d) ===\n', N, K_WARP);
for c = 1:2
    camp = campos{c};
    pred = PredLOSO.(camp); real = Real.(camp);
    r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:N);
    rmse = sqrt(mean((pred-real).^2,2));
    sd_use = SD.(camp); sd_use(sd_use<1e-6)=1e-6;
    err_norm = (pred(:,pts_norm) - real(:,pts_norm)) ./ sd_use(pts_norm);
    rmsenorm = mean(sqrt(mean(err_norm.^2, 2)));
    d = diff(pred, 1, 2);
    fprintf('%-12s r=%.3f  RMSE=%.1fcm  RMSEnorm=%.2f  retrocesos=%.1f/100 (promedio/sujeto)\n', ...
        nombres{c}, mean(r), mean(rmse), rmsenorm, mean(sum(d<0,2)));
end

% ---------- coeficientes de PRODUCCION (N completo) ----------
coefWarp = struct();
for c = 1:2
    camp = campos{c};
    crudos = cell2mat(arrayfun(@(k) S_all(k).pos_cal.(camp), 1:N, 'uni', 0)');
    reales = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), 1:N, 'uni', 0)');
    p0 = zeros(2*K_WARP+2, 1); p0(2*K_WARP+2) = 1;
    fun = @(p) residuo_warp(p, pct, K_WARP, crudos, reales);
    coefWarp.(camp) = lsqnonlin(fun, p0, lb, [], opts_lsq);
    b0 = coefWarp.(camp)(2*K_WARP+2);
    fprintf('%s: a0=%.4f  b0=%.4f  (b0>0 => monotono en talla garantizado: %d)\n', ...
        camp, coefWarp.(camp)(2*K_WARP+1), b0, b0>0);
end
K = K_WARP;
save(fullfile(carpeta, 'Coeficientes_Warp_Temporal.mat'), 'coefWarp', 'K');
fprintf('\nCoeficientes de produccion (SOLO TALLA, warp temporal, afin CONSTANTE) guardados en Coeficientes_Warp_Temporal.mat\n');

save(fullfile(carpeta, 'Ajustar_Warp_Temporal_resultados.mat'), 'S_all','Real','PredLOSO','pct');

f = figure('Position',[80 80 1150 480], 'Color','w');
for c = 1:2
    camp = campos{c};
    subplot(1,2,c); hold on; grid on; box on;
    crudo_m = mean(cell2mat(arrayfun(@(k) S_all(k).pos_cal.(camp), 1:N, 'uni',0)'), 1);
    plot(pct, mean(Real.(camp),1), 'k', 'LineWidth', 2.4);
    plot(pct, crudo_m, '--', 'Color', [0.55 0.55 0.55], 'LineWidth', 2.0);
    plot(pct, mean(PredLOSO.(camp),1), 'Color', [0.00 0.55 0.30], 'LineWidth', 2.2);
    title(nombres{c}); xlabel('% ciclo'); ylabel('cm');
    if c==1, legend({'real','crudo (solo talla)','WARP TEMPORAL + afin constante, LOSO'}, 'Location','best','FontSize',8); end
end
sgtitle(sprintf('Warp temporal (K=%d) + afin CONSTANTE - LOSO real N=%d - SOLO TALLA', K_WARP, N), 'FontWeight','bold');
exportgraphics(f, fullfile(carpeta, 'Ajustar_Warp_Temporal_figura.png'), 'Resolution', 150);
fprintf('Guardado figura.\n');

function res = residuo_warp(p, pct, K, crudos, reales)
Nsuj = size(crudos,1);
res = zeros(Nsuj, numel(pct));
for k = 1:Nsuj
    pred = aplicar_warp_afin(p, pct, K, crudos(k,:));
    res(k,:) = pred - reales(k,:);
end
res = res(:);
end

function pred = aplicar_warp_afin(p, pct, K, crudo)
gcoef = p(1:2*K);
a0 = p(2*K+1); b0 = p(2*K+2);
tau = Warp_Temporal_Core(pct, gcoef, K);
crudo_warp = interp1(pct, crudo, tau, 'pchip');
pred = a0 + b0 .* crudo_warp;
end
