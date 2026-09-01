% ANALISIS_CORRECCION_FASE5_FOURIERK  31-ago-2026: continuacion directa
% de la Fase 4 Parte 2 - el barrido de K (armonicos de Fourier) no habia
% terminado de converger en K=10. Se extiende hasta encontrar el pico
% real (mismo criterio LOSO que ya encontro 16 tramos), para poder
% comparar en serio la version suave contra la de 16 tramos (escalon).

carpeta = fileparts(mfilename('fullpath'));
load(fullfile(carpeta, 'Analisis_Correccion_resultados.mat'), 'Real','S_all','pct');
N = numel(S_all); n = numel(pct);
campos_curva = {'RodX','RodY','TobX','TobY'};
nombres_curva = {'RODILLA X','RODILLA Y','TOBILLO X','TOBILLO Y'};
pts_norm = 2:n;

pos0_all = arrayfun(@(k) correr_pendulo(S_all(k).theta1_koop, S_all(k).theta2_koop, S_all(k), pct), 1:N);
SD = struct();
for c = 1:4, SD.(campos_curva{c}) = std(Real.(campos_curva{c}), 0, 1); end

Klista = [10 12 14 16 18 20 25 30 35 40];
tabla_r = nan(numel(Klista),4); tabla_n = nan(numel(Klista),4);

fprintf('%-6s', 'K');
for c = 1:4, fprintf('%22s', nombres_curva{c}); end
fprintf('\n');

for ik = 1:numel(Klista)
    K = Klista(ik);
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
        tabla_r(ik,c) = mean(r); tabla_n(ik,c) = rmsenorm;
        fprintf('  r=%.3f n=%.2f', mean(r), rmsenorm);
    end
    fprintf('\n');
end

save(fullfile(carpeta, 'Analisis_Correccion_Fase5_resultados.mat'), 'Klista','tabla_r','tabla_n');

f = figure('Position',[60 60 1200 500], 'Color','w');
subplot(1,2,1); hold on; grid on; box on;
for c = 1:4, plot(Klista, tabla_n(:,c), '-o', 'LineWidth', 1.6); end
yline(1,'--k'); yline(1.5,':k');
xlabel('K (armonicos de Fourier)'); ylabel('RMSEnorm (LOSO)');
legend(nombres_curva, 'Location','best'); title('RMSEnorm vs. K');
subplot(1,2,2); hold on; grid on; box on;
for c = 1:4, plot(Klista, tabla_r(:,c), '-o', 'LineWidth', 1.6); end
xlabel('K'); ylabel('r (LOSO)');
legend(nombres_curva, 'Location','best'); title('r vs. K');
sgtitle('Busqueda del numero de armonicos optimo (correccion suave, LOSO N=44)', 'FontWeight','bold');
exportgraphics(f, fullfile(carpeta, 'Analisis_Correccion_Fase5_figura.png'), 'Resolution', 150);
fprintf('Guardado figura.\n');

function pos = correr_pendulo(theta1, theta2, s, pct)
cad = Trayectoria_Cadera_Core(pct, s.zancada_cm, 2.25, 0);
p = Cinematica_DoblePendulo_Core(theta1, theta2, s.L1_cm, s.L2_cm, cad.Xh_cm, cad.Yh_cm);
pos = struct();
pos.RodX = p.Xk - p.Xk(1); pos.RodY = p.Yk - p.Yk(1);
pos.TobX = p.Xa - p.Xa(1); pos.TobY = p.Ya - p.Ya(1);
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
