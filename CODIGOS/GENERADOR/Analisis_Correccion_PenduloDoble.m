% ANALISIS_CORRECCION_PENDULODOBLE  Pedido explicito del usuario
% (31-ago-2026): la geometria (cadera oscilatoria + pendulo doble) queda
% FIJA - lo que se busca de cero es la mejor CORRECCION, comparando
% varias estrategias con LOSO real (N=44, refit propio, no reusar los
% coeficientes viejos calculados con N=13 para un proposito distinto).
%
% Observaciones del usuario que motivan esto:
%   - En X, el LOSO de angulo YA EXISTENTE empeora r y RMSE en los dos
%     segmentos (rodilla y tobillo) - sospecha razonable de que no es
%     valido ahi.
%   - En rodilla Y no ayuda tampoco.
%   - En tobillo Y ayuda en RMSE/r promedio, pero hay un desajuste real
%     de FORMA entre 0-40% del ciclo (un bulto hacia arriba en lo
%     predicho donde el dato real es un valle ancho, casi plano) - a
%     verificar antes de aceptar la mejora como completa.
%
% ESTRATEGIAS COMPARADAS (todas via LOSO real, N=44, nunca con el propio
% sujeto en el ajuste):
%   E0 CRUDO              sin ninguna correccion
%   E1 ANGULO, ciclo completo    afin sobre theta1/theta2, 1 par de coef.
%   E2 ANGULO, por fase          afin separado apoyo/balanceo
%   E3 POSICION, ciclo completo  afin sobre Xk/Yk/Xa/Ya ya generados
%   E4 POSICION, por fase        afin separado apoyo/balanceo
%   E5 AMPLITUD DE CADERA (A)    A personalizada por regresion vs talla,
%                                 en vez de 2.25cm fijo para todos
%
% Se reporta r y RMSE de las 4 curvas finales (rodilla X/Y, tobillo X/Y)
% para cada estrategia, y se guarda una figura de forma (real vs cada
% estrategia) para inspeccionar visualmente el ajuste temprano del ciclo
% que senalo el usuario.

carpeta = fullfile(fileparts(mfilename('fullpath')), 'RODILLA', 'Kuopio');
addpath(carpeta);
archivos = dir(fullfile(carpeta, 'raw', '*_l_comf_01.csv'));
ids = sort(cellfun(@(s) str2double(s(1:2)), {archivos.name}));
n = 101; pct = linspace(0,100,n);

% ---------- Paso 1: cargar TODO una sola vez (real + crudo por sujeto) ----------
S_all = struct('id',{},'theta1_koop',{},'theta2_koop',{},'theta1_real',{},'theta2_real',{}, ...
    'L1_cm',{},'L2_cm',{},'talla_cm',{},'zancada_cm',{},'frac_apoyo',{}, ...
    'RealRodX',{},'RealRodY',{},'RealTobX',{},'RealTobY',{});

for i = 1:numel(ids)
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
    catch
        continue;
    end
    if numel(S.x_horiz_cm) ~= n, continue; end

    antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, ...
        'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000, ...
        'velocidad_ms', S.speed_ms);
    antro = Estimar_Antropometria_Core(antro_in);
    tempo = Temporizacion_Core(antro, 'Koopman');
    K = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, struct('nMuestras', n));
    theta1_koop = deg2rad(K.cadera_flexext.angulo_deg(:).');
    theta2_koop = K.theta_tibia_via_rodilla_rad(:).';

    % Angulo REAL: theta = atan2(-dx, dy) - dx/dy son (cadera-rodilla) y
    % (rodilla-tobillo), ver derivacion geometrica en la cabecera del
    % analisis (misma convencion que Cinematica_DoblePendulo_Core.m:
    % Xk=Xh+L*sin(theta), Yk=Yh-L*cos(theta) -> vector hip->knee =
    % (L sin th, -L cos th); dx_muslo/dy_muslo = cadera-rodilla =
    % -(hip->knee) = (-L sin th, L cos th)).
    theta1_real = atan2(-S.dx_muslo_cm, S.dy_muslo_cm);
    theta2_real = atan2(-S.dx_tibia_cm, S.dy_tibia_cm);

    k = numel(S_all) + 1;
    S_all(k).id = sid;
    S_all(k).theta1_koop = theta1_koop; S_all(k).theta2_koop = theta2_koop;
    S_all(k).theta1_real = theta1_real; S_all(k).theta2_real = theta2_real;
    S_all(k).L1_cm = antro.long_muslo_m*100; S_all(k).L2_cm = antro.long_tibia_m*100;
    S_all(k).talla_cm = S.talla_cm;
    S_all(k).zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;
    S_all(k).frac_apoyo = tempo.frac_apoyo;
    S_all(k).RealRodX = S.x_horiz_cm(:).'; S_all(k).RealRodY = S.y_vert_cm(:).';
    S_all(k).RealTobX = S.x_horiz_tobillo_cm(:).'; S_all(k).RealTobY = S.y_vert_tobillo_cm(:).';
end
N = numel(S_all);
fprintf('N sujetos cargados: %d\n', N);

% ---------- Sanity check: rango de theta_real vs theta_koop (deg) ----------
m1r = rad2deg(mean(cell2mat(arrayfun(@(s) s.theta1_real, S_all, 'uni', 0)'), 1));
m1k = rad2deg(mean(cell2mat(arrayfun(@(s) s.theta1_koop, S_all, 'uni', 0)'), 1));
m2r = rad2deg(mean(cell2mat(arrayfun(@(s) s.theta2_real, S_all, 'uni', 0)'), 1));
m2k = rad2deg(mean(cell2mat(arrayfun(@(s) s.theta2_koop, S_all, 'uni', 0)'), 1));
fprintf('SANITY: theta1 real [%.1f,%.1f]deg vs koop [%.1f,%.1f]deg\n', min(m1r),max(m1r), min(m1k),max(m1k));
fprintf('SANITY: theta2 real [%.1f,%.1f]deg vs koop [%.1f,%.1f]deg\n', min(m2r),max(m2r), min(m2k),max(m2k));
fprintf('SANITY: corr(theta1_real_mean, theta1_koop_mean) = %.3f\n', corr(m1r(:), m1k(:)));
fprintf('SANITY: corr(theta2_real_mean, theta2_koop_mean) = %.3f\n', corr(m2r(:), m2k(:)));

% ==========================================================================
% ESTRATEGIAS (todas via LOSO, N sujetos)
% ==========================================================================
Res = struct();
campos_curva = {'RodX','RodY','TobX','TobY'};
for c = 1:4, Res.(['E0_' campos_curva{c}]).pred = nan(N,n); end
for c = 1:4, Res.(['E1_' campos_curva{c}]).pred = nan(N,n); end
for c = 1:4, Res.(['E2_' campos_curva{c}]).pred = nan(N,n); end
for c = 1:4, Res.(['E3_' campos_curva{c}]).pred = nan(N,n); end
for c = 1:4, Res.(['E4_' campos_curva{c}]).pred = nan(N,n); end
for c = 1:4, Res.(['E5_' campos_curva{c}]).pred = nan(N,n); end
Real = struct('RodX',nan(N,n),'RodY',nan(N,n),'TobX',nan(N,n),'TobY',nan(N,n));

% ---------- precomputo (una sola vez, NO depende de que sujeto se deja
% afuera en cada pliegue LOSO - evita recalcular lo mismo miles de veces) ----------
pos0_all = arrayfun(@(k) correr_pendulo(S_all(k).theta1_koop, S_all(k).theta2_koop, S_all(k), pct), 1:N);
A_optima_all = arrayfun(@(k) A_optima_sujeto(S_all(k), pct), 1:N);
fprintf('A optima por sujeto: media=%.2fcm SD=%.2f min=%.2f max=%.2f\n', ...
    mean(A_optima_all), std(A_optima_all), min(A_optima_all), max(A_optima_all));

for i = 1:N
    otros = setdiff(1:N, i);
    s = S_all(i);
    idx_ap = pct <= s.frac_apoyo*100;
    idx_bal = ~idx_ap;

    Real.RodX(i,:)=s.RealRodX; Real.RodY(i,:)=s.RealRodY;
    Real.TobX(i,:)=s.RealTobX; Real.TobY(i,:)=s.RealTobY;

    % ---------- E0: crudo ----------
    pos0 = correr_pendulo(s.theta1_koop, s.theta2_koop, s, pct);
    for c = 1:4, Res.(['E0_' campos_curva{c}]).pred(i,:) = pos0.(campos_curva{c}); end

    % ---------- E1: angulo, ciclo completo, LOSO ----------
    [a1,b1] = fit_afin_loso(S_all, otros, 'theta1_koop', 'theta1_real', []);
    [a2,b2] = fit_afin_loso(S_all, otros, 'theta2_koop', 'theta2_real', []);
    th1 = a1 + b1*s.theta1_koop; th2 = a2 + b2*s.theta2_koop;
    pos1 = correr_pendulo(th1, th2, s, pct);
    for c = 1:4, Res.(['E1_' campos_curva{c}]).pred(i,:) = pos1.(campos_curva{c}); end

    % ---------- E2: angulo, por fase, LOSO ----------
    [a1ap,b1ap] = fit_afin_loso(S_all, otros, 'theta1_koop', 'theta1_real', idx_ap);
    [a1bl,b1bl] = fit_afin_loso(S_all, otros, 'theta1_koop', 'theta1_real', idx_bal);
    [a2ap,b2ap] = fit_afin_loso(S_all, otros, 'theta2_koop', 'theta2_real', idx_ap);
    [a2bl,b2bl] = fit_afin_loso(S_all, otros, 'theta2_koop', 'theta2_real', idx_bal);
    th1 = s.theta1_koop; th2 = s.theta2_koop;
    th1(idx_ap) = a1ap + b1ap*th1(idx_ap); th1(idx_bal) = a1bl + b1bl*th1(idx_bal);
    th2(idx_ap) = a2ap + b2ap*th2(idx_ap); th2(idx_bal) = a2bl + b2bl*th2(idx_bal);
    pos2 = correr_pendulo(th1, th2, s, pct);
    for c = 1:4, Res.(['E2_' campos_curva{c}]).pred(i,:) = pos2.(campos_curva{c}); end

    % ---------- E3: posicion, ciclo completo, LOSO ----------
    % (se ajusta afin de "pos0(otros) crudo" vs "real(otros)", por curva)
    pos3 = struct();
    for c = 1:4
        camp = campos_curva{c};
        crudos_otros = cell2mat(arrayfun(@(k) pos0_all(k).(camp), otros, 'uni', 0)');
        reales_otros = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), otros, 'uni', 0)');
        pr = polyfit(crudos_otros(:), reales_otros(:), 1);
        pos3.(camp) = pr(2) + pr(1)*pos0.(camp);
    end
    for c = 1:4, Res.(['E3_' campos_curva{c}]).pred(i,:) = pos3.(campos_curva{c}); end

    % ---------- E4: posicion, por fase, LOSO ----------
    pos4 = struct();
    for c = 1:4
        camp = campos_curva{c};
        crudos_otros_ap = cell2mat(arrayfun(@(k) applyidx(pos0_all(k).(camp), idx_ap), otros, 'uni', 0)');
        reales_otros_ap = cell2mat(arrayfun(@(k) applyidx(S_all(k).(['Real' camp]), idx_ap), otros, 'uni', 0)');
        crudos_otros_bl = cell2mat(arrayfun(@(k) applyidx(pos0_all(k).(camp), idx_bal), otros, 'uni', 0)');
        reales_otros_bl = cell2mat(arrayfun(@(k) applyidx(S_all(k).(['Real' camp]), idx_bal), otros, 'uni', 0)');
        prap = polyfit(crudos_otros_ap(:), reales_otros_ap(:), 1);
        prbl = polyfit(crudos_otros_bl(:), reales_otros_bl(:), 1);
        v = pos0.(camp);
        v(idx_ap)  = prap(2) + prap(1)*v(idx_ap);
        v(idx_bal) = prbl(2) + prbl(1)*v(idx_bal);
        pos4.(camp) = v;
    end
    for c = 1:4, Res.(['E4_' campos_curva{c}]).pred(i,:) = pos4.(campos_curva{c}); end

    % ---------- E5: amplitud de cadera personalizada por talla, LOSO ----------
    tallas_otros = [S_all(otros).talla_cm];
    A_otros = A_optima_all(otros);
    pr = polyfit(tallas_otros, A_otros, 1);
    A_i = max(0, pr(2) + pr(1)*s.talla_cm);
    pos5 = correr_pendulo(s.theta1_koop, s.theta2_koop, s, pct, A_i);
    for c = 1:4, Res.(['E5_' campos_curva{c}]).pred(i,:) = pos5.(campos_curva{c}); end
end

% ==========================================================================
% Reporte
% ==========================================================================
etiquetas = {'E0 crudo','E1 angulo ciclo completo','E2 angulo por fase', ...
             'E3 posicion ciclo completo','E4 posicion por fase','E5 amplitud A por talla'};
codigos = {'E0','E1','E2','E3','E4','E5'};
nombres_curva = {'RODILLA X','RODILLA Y','TOBILLO X','TOBILLO Y'};

fprintf('\n%-28s', 'Estrategia');
for c = 1:4, fprintf('%16s', nombres_curva{c}); end
fprintf('\n');
for e = 1:numel(codigos)
    fprintf('%-28s', etiquetas{e});
    for c = 1:4
        camp = campos_curva{c};
        pred = Res.([codigos{e} '_' camp]).pred;
        real = Real.(camp);
        r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:N);
        rmse = sqrt(mean((pred-real).^2,2));
        fprintf('  r=%.3f/e=%.1f', mean(r), mean(rmse));
    end
    fprintf('\n');
end

save(fullfile(fileparts(mfilename('fullpath')), 'Analisis_Correccion_resultados.mat'), 'Res','Real','S_all','pct');

% ---------- figura de forma: real vs cada estrategia (medias) ----------
f = figure('Position',[40 40 1500 850], 'Color','w');
colores = lines(numel(codigos));
for c = 1:4
    subplot(2,2,c); hold on; grid on; box on;
    camp = campos_curva{c};
    plot(pct, mean(Real.(camp),1), 'k', 'LineWidth', 2.6);
    leyendas = {'real'};
    for e = 1:numel(codigos)
        pred = Res.([codigos{e} '_' camp]).pred;
        plot(pct, mean(pred,1), 'Color', colores(e,:), 'LineWidth', 1.4);
        leyendas{end+1} = etiquetas{e}; %#ok<AGROW>
    end
    title(nombres_curva{c});
    xlabel('% ciclo'); ylabel('cm');
    if c==1, legend(leyendas, 'Location','southoutside', 'FontSize',7, 'NumColumns',2); end
end
sgtitle('Comparacion de estrategias de correccion (medias, N=44)', 'FontWeight','bold');
out_png = fullfile(fileparts(mfilename('fullpath')), 'Analisis_Correccion_figura.png');
exportgraphics(f, out_png, 'Resolution', 150);
fprintf('\nGuardado: %s\n', out_png);

% ==========================================================================
function pos = correr_pendulo(theta1, theta2, s, pct, A_cm)
if nargin < 5, A_cm = 2.25; end
cad = Trayectoria_Cadera_Core(pct, s.zancada_cm, A_cm, 0);
p = Cinematica_DoblePendulo_Core(theta1, theta2, s.L1_cm, s.L2_cm, cad.Xh_cm, cad.Yh_cm);
pos = struct();
pos.RodX = p.Xk - p.Xk(1); pos.RodY = p.Yk - p.Yk(1);
pos.TobX = p.Xa - p.Xa(1); pos.TobY = p.Ya - p.Ya(1);
end

function v = applyidx(vec, idx)
v = vec(idx);
end

function [a,b] = fit_afin_loso(S_all, otros, campo_koop, campo_real, idx)
xk = cell2mat(arrayfun(@(k) S_all(k).(campo_koop), otros, 'uni', 0)');
xr = cell2mat(arrayfun(@(k) S_all(k).(campo_real), otros, 'uni', 0)');
if ~isempty(idx)
    xk = xk(:,idx); xr = xr(:,idx);
end
p = polyfit(xk(:), xr(:), 1);
b = p(1); a = p(2);
end

function A = A_optima_sujeto(s, pct)
cands = 0:0.25:6;
best = inf; A = 2.25;
for k = 1:numel(cands)
    cad = Trayectoria_Cadera_Core(pct, s.zancada_cm, cands(k), 0);
    p = Cinematica_DoblePendulo_Core(s.theta1_koop, s.theta2_koop, s.L1_cm, s.L2_cm, cad.Xh_cm, cad.Yh_cm);
    yk = p.Yk - p.Yk(1); ya = p.Ya - p.Ya(1);
    e = mean((yk-s.RealRodY).^2) + mean((ya-s.RealTobY).^2);
    if e < best, best = e; A = cands(k); end
end
end
