% ANALISIS_CORRECCION_FASE6_COMBOSUAVE  31-ago-2026: combinacion final -
% angulo LOSO (ciclo completo) -> geometria (pendulo doble) -> correccion
% de posicion SUAVE (Fourier, K=14, elegido de la meseta estable de la
% Fase5). Compara contra combo con 16 tramos (Fase4 Parte1) y contra
% suave solo (sin angulo LOSO, Fase4 Parte2/Fase5). Todo LOSO real N=44.

carpeta = fileparts(mfilename('fullpath'));
load(fullfile(carpeta, 'Analisis_Correccion_resultados.mat'), 'Real','S_all','pct');
N = numel(S_all); n = numel(pct);
campos_curva = {'RodX','RodY','TobX','TobY'};
nombres_curva = {'RODILLA X','RODILLA Y','TOBILLO X','TOBILLO Y'};
pts_norm = 2:n;
K = 14;

SD = struct();
for c = 1:4, SD.(campos_curva{c}) = std(Real.(campos_curva{c}), 0, 1); end

for c = 1:4, ComboSuave.(campos_curva{c}) = nan(N,n); end

for i = 1:N
    otros = setdiff(1:N, i);
    s = S_all(i);

    [a1,b1] = fit_afin(cell2mat(arrayfun(@(k) S_all(k).theta1_koop, otros, 'uni',0)'), ...
                        cell2mat(arrayfun(@(k) S_all(k).theta1_real, otros, 'uni',0)'));
    [a2,b2] = fit_afin(cell2mat(arrayfun(@(k) S_all(k).theta2_koop, otros, 'uni',0)'), ...
                        cell2mat(arrayfun(@(k) S_all(k).theta2_real, otros, 'uni',0)'));

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

    for c = 1:4
        camp = campos_curva{c};
        reales_otros = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), otros, 'uni', 0)');
        coef = fit_fourier_afin(pct, pos_otros.(camp), reales_otros, K);
        ComboSuave.(camp)(i,:) = aplicar_fourier_afin(pct, pos_i.(camp), coef, K);
    end
end

fprintf('\n=== Angulo LOSO + geometria + correccion SUAVE (K=%d), combinado ===\n', K);
fprintf('%-12s %10s %10s\n', 'Curva', 'r', 'RMSEnorm');
resumen = struct();
for c = 1:4
    camp = campos_curva{c};
    pred = ComboSuave.(camp); real = Real.(camp);
    r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:N);
    err_norm = (pred(:,pts_norm) - real(:,pts_norm)) ./ SD.(camp)(pts_norm);
    rmsenorm = mean(sqrt(mean(err_norm.^2, 2)));
    fprintf('%-12s %10.3f %10.2f\n', nombres_curva{c}, mean(r), rmsenorm);
    resumen.(camp) = [mean(r), rmsenorm];
end

save(fullfile(carpeta, 'Analisis_Correccion_Fase6_resultados.mat'), 'ComboSuave', 'resumen', 'K');

fprintf('\n=== Comparacion de las 4 variantes finales ===\n');
fprintf('%-12s %22s %22s %22s %22s\n', 'Curva', 'Solo posicion (escal)', 'Combo (escal)', 'Solo posicion (suave)', 'Combo (suave)');
solo_pos_escal = struct('RodX',[0.998 0.47],'RodY',[0.931 0.91],'TobX',[0.998 0.66],'TobY',[0.979 1.02]);
combo_escal     = struct('RodX',[0.998 0.48],'RodY',[0.929 0.91],'TobX',[0.997 0.69],'TobY',[0.983 0.98]);
solo_pos_suave  = struct('RodX',[0.998 0.53],'RodY',[0.946 0.87],'TobX',[0.997 0.77],'TobY',[0.981 0.89]); % K=14 aprox (Fase5)
for c = 1:4
    camp = campos_curva{c};
    fprintf('%-12s %13s %13s %13s %13s\n', nombres_curva{c}, ...
        sprintf('r=%.3f n=%.2f', solo_pos_escal.(camp)(1), solo_pos_escal.(camp)(2)), ...
        sprintf('r=%.3f n=%.2f', combo_escal.(camp)(1), combo_escal.(camp)(2)), ...
        sprintf('r=%.3f n=%.2f', solo_pos_suave.(camp)(1), solo_pos_suave.(camp)(2)), ...
        sprintf('r=%.3f n=%.2f', resumen.(camp)(1), resumen.(camp)(2)));
end

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
Nsuj = size(crudos,1);
Phi = fourier_base(pct, K);
Xdes = []; Ydes = [];
for k = 1:Nsuj
    Xdes = [Xdes; [Phi, Phi .* crudos(k,:)']]; %#ok<AGROW>
    Ydes = [Ydes; reales(k,:)']; %#ok<AGROW>
end
coef = Xdes \ Ydes;
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
