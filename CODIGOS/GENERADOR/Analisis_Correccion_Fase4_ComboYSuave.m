% ANALISIS_CORRECCION_FASE4_COMBOYSUAVE  31-ago-2026, pedido explicito
% del usuario:
%   (1) Comparar r: LOSO-de-angulo + correccion-de-posicion-16-tramos
%       (combinado) vs. solo la correccion de posicion de 16 tramos.
%   (2) Suavizar la costura de los 16 tramos - matematica mas compleja
%       autorizada explicitamente por el usuario: se prueba una
%       correccion CONTINUA (a(t), b(t) como series de Fourier
%       periodicas del %ciclo, en vez de 16 constantes por tramo),
%       ajustada por regresion lineal (el modelo sigue siendo
%       corregido(t)=a(t)+b(t)*crudo(t), pero a(t) y b(t) ya no son
%       escalones sino curvas suaves) y el numero de armonicos elegido
%       por el mismo criterio LOSO que ya eligio 16 tramos.
%
% TODO con LOSO real (N=44), nunca con el propio sujeto en el ajuste.

carpeta = fileparts(mfilename('fullpath'));
load(fullfile(carpeta, 'Analisis_Correccion_resultados.mat'), 'Real','S_all','pct');
N = numel(S_all); n = numel(pct);
campos_curva = {'RodX','RodY','TobX','TobY'};
nombres_curva = {'RODILLA X','RODILLA Y','TOBILLO X','TOBILLO Y'};
pts_norm = 2:n;

pos0_all = arrayfun(@(k) correr_pendulo(S_all(k).theta1_koop, S_all(k).theta2_koop, S_all(k), pct), 1:N);
SD = struct();
for c = 1:4
    camp = campos_curva{c};
    SD.(camp) = std(Real.(camp), 0, 1);
end

% ==========================================================================
% PARTE 1: combinado (angulo LOSO ciclo completo) + (posicion 16 tramos)
% ==========================================================================
bordes16 = linspace(0, 100, 17);
for c = 1:4, Combo.(campos_curva{c}) = nan(N,n); end

for i = 1:N
    otros = setdiff(1:N, i);
    s = S_all(i);

    % --- angulo LOSO, ciclo completo (mismo criterio que E1) ---
    [a1,b1] = fit_afin(cell2mat(arrayfun(@(k) S_all(k).theta1_koop, otros, 'uni',0)'), ...
                        cell2mat(arrayfun(@(k) S_all(k).theta1_real, otros, 'uni',0)'));
    [a2,b2] = fit_afin(cell2mat(arrayfun(@(k) S_all(k).theta2_koop, otros, 'uni',0)'), ...
                        cell2mat(arrayfun(@(k) S_all(k).theta2_real, otros, 'uni',0)'));

    % --- posicion post-angulo-calibrado, para TODOS (i y otros), este fold ---
    th1_i = a1 + b1*s.theta1_koop; th2_i = a2 + b2*s.theta2_koop;
    pos_i = correr_pendulo(th1_i, th2_i, s, pct);

    pos_otros = struct('RodX',nan(numel(otros),n),'RodY',nan(numel(otros),n), ...
                        'TobX',nan(numel(otros),n),'TobY',nan(numel(otros),n));
    for jj = 1:numel(otros)
        k = otros(jj);
        th1_k = a1 + b1*S_all(k).theta1_koop; th2_k = a2 + b2*S_all(k).theta2_koop;
        pk = correr_pendulo(th1_k, th2_k, S_all(k), pct);
        for c = 1:4, pos_otros.(campos_curva{c})(jj,:) = pk.(campos_curva{c}); end
    end

    % --- correccion de posicion, 16 tramos, ajustada sobre el post-angulo ---
    for c = 1:4
        camp = campos_curva{c};
        v = pos_i.(camp);
        reales_otros = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), otros, 'uni', 0)');
        for q = 1:16
            idxq = pct >= bordes16(q) & pct <= bordes16(q+1);
            pr = polyfit(reshape(pos_otros.(camp)(:,idxq),1,[]), reshape(reales_otros(:,idxq),1,[]), 1);
            v(idxq) = pr(2) + pr(1)*v(idxq);
        end
        Combo.(camp)(i,:) = v;
    end
end

fprintf('\n=== PARTE 1: combinado (angulo LOSO + posicion 16 tramos) vs. solo posicion 16 tramos ===\n');
fprintf('%-12s %28s %28s\n', 'Curva', 'Solo posicion (ya conocido)', 'Combinado angulo+posicion');
solo_pos = struct('RodX',[0.998 0.47],'RodY',[0.931 0.91],'TobX',[0.998 0.66],'TobY',[0.979 1.02]); % de Fase3, N=44, 16 tramos
for c = 1:4
    camp = campos_curva{c};
    pred = Combo.(camp); real = Real.(camp);
    r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:N);
    err_norm = (pred(:,pts_norm) - real(:,pts_norm)) ./ SD.(camp)(pts_norm);
    rmsenorm = mean(sqrt(mean(err_norm.^2, 2)));
    fprintf('%-12s r=%.3f n=%.2f %28s r=%.3f n=%.2f\n', nombres_curva{c}, ...
        solo_pos.(camp)(1), solo_pos.(camp)(2), '', mean(r), rmsenorm);
end

save(fullfile(carpeta, 'Analisis_Correccion_Fase4_Combo_resultados.mat'), 'Combo');

% ==========================================================================
% PARTE 2: correccion SUAVE (Fourier periodico) vs. 16 tramos (escalon)
% ==========================================================================
Kmax_lista = [1 2 3 4 5 6 8 10];
fprintf('\n=== PARTE 2: correccion suave (Fourier), barrido de armonicos K ===\n');
fprintf('%-6s', 'K');
for c = 1:4, fprintf('%22s', nombres_curva{c}); end
fprintf('\n');

mejor = struct();
for c = 1:4, mejor.(campos_curva{c}) = struct('K',1,'rmsenorm',inf); end

for K = Kmax_lista
    for c = 1:4, PredF.(campos_curva{c}) = nan(N,n); end
    for i = 1:N
        otros = setdiff(1:N, i);
        for c = 1:4
            camp = campos_curva{c};
            crudos_otros = cell2mat(arrayfun(@(k) pos0_all(k).(camp), otros, 'uni', 0)');
            reales_otros = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), otros, 'uni', 0)');
            coef = fit_fourier_afin(pct, crudos_otros, reales_otros, K);
            PredF.(camp)(i,:) = aplicar_fourier_afin(pct, pos0_all(i).(camp), coef, K);
        end
    end
    fprintf('K=%-4d', K);
    for c = 1:4
        camp = campos_curva{c};
        pred = PredF.(camp); real = Real.(camp);
        r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:N);
        err_norm = (pred(:,pts_norm) - real(:,pts_norm)) ./ SD.(camp)(pts_norm);
        rmsenorm = mean(sqrt(mean(err_norm.^2, 2)));
        fprintf('  r=%.3f n=%.2f', mean(r), rmsenorm);
        if rmsenorm < mejor.(camp).rmsenorm
            mejor.(camp).rmsenorm = rmsenorm; mejor.(camp).K = K; mejor.(camp).r = mean(r);
            mejor.(camp).pred = pred;
        end
    end
    fprintf('\n');
end

fprintf('\nMejor K por curva (suave):\n');
for c = 1:4
    camp = campos_curva{c};
    fprintf('%-12s K=%d  r=%.3f  RMSEnorm=%.2f\n', nombres_curva{c}, mejor.(camp).K, mejor.(camp).r, mejor.(camp).rmsenorm);
end

save(fullfile(carpeta, 'Analisis_Correccion_Fase4_Suave_resultados.mat'), 'mejor', 'Kmax_lista');

% ---------- figura: 16 tramos (escalon) vs. suave (Fourier, mejor K) vs. real ----------
load(fullfile(carpeta, 'Analisis_Correccion_Fase3_resultados.mat'), 'RMSEnorm_tabla', 'num_tramos_lista'); %#ok<NASGU>
% recomputar prediccion de 16 tramos (para graficar) con la misma rutina que Correccion_Posicion_PenduloDoble_Core
for c = 1:4
    camp = campos_curva{c};
    Pred16.(camp) = nan(N,n);
end
for i = 1:N
    p0 = pos0_all(i);
    cc = Correccion_Posicion_PenduloDoble_Core(pct, p0.RodX, p0.RodY, p0.TobX, p0.TobY);
    Pred16.RodX(i,:)=cc.Xk; Pred16.RodY(i,:)=cc.Yk; Pred16.TobX(i,:)=cc.Xa; Pred16.TobY(i,:)=cc.Ya;
end

f = figure('Position',[40 40 1500 850], 'Color','w');
for c = 1:4
    camp = campos_curva{c};
    subplot(2,2,c); hold on; grid on; box on;
    plot(pct, mean(Real.(camp),1), 'k', 'LineWidth', 2.6);
    plot(pct, mean(Pred16.(camp),1), 'Color', [0.85 0.33 0.10], 'LineWidth', 1.6);
    plot(pct, mean(mejor.(camp).pred,1), 'Color', [0.00 0.45 0.74], 'LineWidth', 1.8);
    title(sprintf('%s (16 tramos: RMSEnorm=%.2f | suave K=%d: RMSEnorm=%.2f)', ...
        nombres_curva{c}, solo_pos.(camp)(2), mejor.(camp).K, mejor.(camp).rmsenorm), 'FontSize', 9);
    xlabel('% ciclo'); ylabel('cm');
    if c==1, legend({'real','16 tramos (escalon)','suave (Fourier)'}, 'Location','southoutside', 'FontSize',8); end
end
sgtitle('Correccion por tramos (escalon) vs. correccion suave (Fourier periodico)', 'FontWeight','bold');
exportgraphics(f, fullfile(carpeta, 'Analisis_Correccion_Fase4_figura.png'), 'Resolution', 150);
fprintf('\nGuardado: %s\n', fullfile(carpeta, 'Analisis_Correccion_Fase4_figura.png'));

% ==========================================================================
function pos = correr_pendulo(theta1, theta2, s, pct)
cad = Trayectoria_Cadera_Core(pct, s.zancada_cm, 2.25, 0);
p = Cinematica_DoblePendulo_Core(theta1, theta2, s.L1_cm, s.L2_cm, cad.Xh_cm, cad.Yh_cm);
pos = struct();
pos.RodX = p.Xk - p.Xk(1); pos.RodY = p.Yk - p.Yk(1);
pos.TobX = p.Xa - p.Xa(1); pos.TobY = p.Ya - p.Ya(1);
end

function [a,b] = fit_afin(xk, xr)
p = polyfit(xk(:), xr(:), 1);
b = p(1); a = p(2);
end

function coef = fit_fourier_afin(pct, crudos, reales, K)
% corregido(t) = a(t) + b(t)*crudo(t), con a(t)=A.Phi(t), b(t)=B.Phi(t),
% Phi(t) = [1, cos(2pi t/100), sin(2pi t/100), ..., cos(2pi K t/100), sin(2pi K t/100)]
% Regresion lineal: real(t) = Phi(t).A + (crudo(t)*Phi(t)).B
% crudos, reales: [Nsujetos x n] (misma malla pct para todas las filas)
n = numel(pct);
Nsuj = size(crudos,1);
Phi = fourier_base(pct, K);      % [n x (2K+1)]
Xdes = []; Ydes = [];
for k = 1:Nsuj
    Xdes = [Xdes; [Phi, Phi .* crudos(k,:)']]; %#ok<AGROW>
    Ydes = [Ydes; reales(k,:)']; %#ok<AGROW>
end
theta = Xdes \ Ydes;   % minimos cuadrados
coef = theta;
end

function pred = aplicar_fourier_afin(pct, crudo, coef, K)
Phi = fourier_base(pct, K);
m = size(Phi,2);
A = coef(1:m); B = coef(m+1:end);
at = Phi*A; bt = Phi*B;
pred = at(:).' + bt(:).' .* crudo;
end

function Phi = fourier_base(pct, K)
n = numel(pct);
Phi = ones(n, 2*K+1);
w = 2*pi*pct(:)/100;
for k = 1:K
    Phi(:, 2*k)   = cos(k*w);
    Phi(:, 2*k+1) = sin(k*w);
end
end
