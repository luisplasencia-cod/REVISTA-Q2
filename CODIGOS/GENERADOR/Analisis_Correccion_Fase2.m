% ANALISIS_CORRECCION_FASE2  Continuacion de Analisis_Correccion_
% PenduloDoble.m (mismo dia, 31-ago-2026): objetivo explicito del
% usuario via /loop - encontrar la MEJOR correccion posible, apuntando a
% RMSEnorm (no solo RMSE crudo) en la escala del proyecto (<1 Excelente,
% <1.5 Bueno, <2 Aceptable, >2 Deficiente, misma Ec. que angulo tibial,
% Seccion "Metricas" del informe tecnico) y r lo mas alto posible, para
% las 4 curvas (rodilla/tobillo X/Y), TODO via LOSO real (N=44) - nunca
% con el propio sujeto en el ajuste.
%
% Parte de E4 (posicion, por fase, LOSO) - ganador de la Fase 1 (mejora
% r Y RMSE en las 4 curvas a la vez) - y prueba 2 refinamientos:
%   E6  = E4 + costura SUAVIZADA (blend sigmoide +-5% del ciclo en la
%         frontera apoyo/balanceo, en vez de un salto duro) - mismo
%         numero de parametros que E4, solo cambia como se combinan.
%   E7  = 4 tramos (cuartiles del ciclo) en vez de 2 - mas grados de
%         libertad; SOLO vale si generaliza mejor en el LOSO real, no
%         solo en ajuste dentro de muestra (chequeo explicito de
%         sobreajuste, mismo criterio ya usado en el proyecto: "el
%         promedio simple no pierde contra versiones optimizadas cuando
%         N es chico").
%
% Tambien calcula RMSEnorm para E0 (crudo) y E4 (ganador Fase 1), para
% saber en que escala estamos parados antes de intentar mejorar mas.

carpeta = fileparts(mfilename('fullpath'));
load(fullfile(carpeta, 'Analisis_Correccion_resultados.mat'), 'Res','Real','S_all','pct');
N = numel(S_all); n = numel(pct);
campos_curva = {'RodX','RodY','TobX','TobY'};

pos0_all = arrayfun(@(k) correr_pendulo(S_all(k).theta1_koop, S_all(k).theta2_koop, S_all(k), pct), 1:N);

% ---------- SD entre sujetos por punto del ciclo (para RMSEnorm) ----------
SD = struct();
for c = 1:4
    camp = campos_curva{c};
    SD.(camp) = std(Real.(camp), 0, 1);   % [1 x n], entre los 44 sujetos, por punto
end

% ==========================================================================
% E6: posicion por fase CON COSTURA SUAVIZADA (blend sigmoide +-5% del ciclo)
% E7: posicion por CUARTILES (4 tramos)
% ==========================================================================
for c = 1:4, ResE6.(campos_curva{c}).pred = nan(N,n); end
for c = 1:4, ResE7.(campos_curva{c}).pred = nan(N,n); end

for i = 1:N
    otros = setdiff(1:N, i);
    s = S_all(i);
    frac = s.frac_apoyo*100;
    idx_ap = pct <= frac; idx_bal = ~idx_ap;

    % --- E6: mismo ajuste por fase que E4, pero mezclado suave en +-5% ---
    pos0 = pos0_all(i);
    for c = 1:4
        camp = campos_curva{c};
        [prap, prbl] = fit_pos_fase(pos0_all, S_all, otros, camp, idx_ap, idx_bal);
        vap = prap(2) + prap(1)*pos0.(camp);
        vbl = prbl(2) + prbl(1)*pos0.(camp);
        w = pesos_blend(pct, frac, 5);   % 1=usar vap, 0=usar vbl, transicion suave +-5%
        ResE6.(camp).pred(i,:) = w.*vap + (1-w).*vbl;
    end

    % --- E7: 4 tramos (cuartiles reales del ciclo: 0-25,25-50,50-75,75-100) ---
    bordes = [0 25 50 75 100];
    for c = 1:4
        camp = campos_curva{c};
        v = pos0.(camp);
        for q = 1:4
            idxq = pct >= bordes(q) & pct <= bordes(q+1);
            pr = fit_pos_tramo(pos0_all, S_all, otros, camp, idxq);
            v(idxq) = pr(2) + pr(1)*v(idxq);
        end
        ResE7.(camp).pred(i,:) = v;
    end
end

% ==========================================================================
% Reporte: r, RMSE, RMSEnorm para E0, E4 (Fase1), E6, E7
% ==========================================================================
nombres_curva = {'RODILLA X','RODILLA Y','TOBILLO X','TOBILLO Y'};
estrategias = struct('nombre', {'E0 crudo','E4 posicion por fase (Fase1)','E6 posicion por fase SUAVIZADA','E7 posicion por cuartiles'}, ...
    'datos', {Res, Res, ResE6, ResE7}, 'prefijo', {'E0_','E4_','',''});

fprintf('\n%-32s', 'Estrategia');
for c = 1:4, fprintf('%22s', nombres_curva{c}); end
fprintf('\n');
for e = 1:numel(estrategias)
    fprintf('%-32s', estrategias(e).nombre);
    for c = 1:4
        camp = campos_curva{c};
        if e <= 2
            pred = estrategias(e).datos.([estrategias(e).prefijo camp]).pred;
        else
            pred = estrategias(e).datos.(camp).pred;
        end
        real = Real.(camp);
        r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:N);
        rmse = sqrt(mean((pred-real).^2,2));
        % t=0 excluido: por construccion (desplazamiento normalizado al
        % inicio) real y predicho son EXACTAMENTE 0 ahi para todos los
        % sujetos -> SD entre sujetos = 0 -> division por cero, no un
        % fallo del modelo. Igual criterio en las demas curvas.
        pts = 2:size(pred,2);
        err_norm = (pred(:,pts) - real(:,pts)) ./ SD.(camp)(pts);
        rmsenorm = sqrt(mean(err_norm.^2, 2));
        clasif = clasificar_rmsenorm(mean(rmsenorm));
        fprintf('  r=%.3f e=%.1f n=%.2f(%s)', mean(r), mean(rmse), mean(rmsenorm), clasif);
    end
    fprintf('\n');
end

save(fullfile(carpeta, 'Analisis_Correccion_Fase2_resultados.mat'), 'ResE6','ResE7','SD');

% ---------- figura final: real vs E0 vs E4 vs E6 vs E7 ----------
f = figure('Position',[40 40 1500 850], 'Color','w');
colores = [0.5 0.5 0.5; 0.85 0.33 0.10; 0.00 0.45 0.74; 0.47 0.67 0.19];
for c = 1:4
    subplot(2,2,c); hold on; grid on; box on;
    camp = campos_curva{c};
    plot(pct, mean(Real.(camp),1), 'k', 'LineWidth', 2.8);
    plot(pct, mean(Res.(['E0_' camp]).pred,1), '--', 'Color', colores(1,:), 'LineWidth', 1.3);
    plot(pct, mean(Res.(['E4_' camp]).pred,1), 'Color', colores(2,:), 'LineWidth', 1.6);
    plot(pct, mean(ResE6.(camp).pred,1), 'Color', colores(3,:), 'LineWidth', 1.6);
    plot(pct, mean(ResE7.(camp).pred,1), 'Color', colores(4,:), 'LineWidth', 1.6);
    title(nombres_curva{c});
    xlabel('% ciclo'); ylabel('cm');
    if c==1, legend({'real','E0 crudo','E4 por fase','E6 suavizada','E7 cuartiles'}, 'Location','southoutside', 'FontSize',8, 'NumColumns',3); end
end
sgtitle('Fase 2: refinamientos sobre E4 (medias, N=44)', 'FontWeight','bold');
exportgraphics(f, fullfile(carpeta, 'Analisis_Correccion_Fase2_figura.png'), 'Resolution', 150);
fprintf('\nGuardado: %s\n', fullfile(carpeta, 'Analisis_Correccion_Fase2_figura.png'));

% ==========================================================================
function pos = correr_pendulo(theta1, theta2, s, pct, A_cm)
if nargin < 5, A_cm = 2.25; end
cad = Trayectoria_Cadera_Core(pct, s.zancada_cm, A_cm, 0);
p = Cinematica_DoblePendulo_Core(theta1, theta2, s.L1_cm, s.L2_cm, cad.Xh_cm, cad.Yh_cm);
pos = struct();
pos.RodX = p.Xk - p.Xk(1); pos.RodY = p.Yk - p.Yk(1);
pos.TobX = p.Xa - p.Xa(1); pos.TobY = p.Ya - p.Ya(1);
end

function [prap, prbl] = fit_pos_fase(pos0_all, S_all, otros, camp, idx_ap, idx_bal)
crudos_ap = cell2mat(arrayfun(@(k) pos0_all(k).(camp)(idx_ap), otros, 'uni', 0)');
reales_ap = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp])(idx_ap), otros, 'uni', 0)');
crudos_bl = cell2mat(arrayfun(@(k) pos0_all(k).(camp)(idx_bal), otros, 'uni', 0)');
reales_bl = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp])(idx_bal), otros, 'uni', 0)');
prap = polyfit(crudos_ap(:), reales_ap(:), 1);
prbl = polyfit(crudos_bl(:), reales_bl(:), 1);
end

function pr = fit_pos_tramo(pos0_all, S_all, otros, camp, idxq)
crudos = cell2mat(arrayfun(@(k) pos0_all(k).(camp)(idxq), otros, 'uni', 0)');
reales = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp])(idxq), otros, 'uni', 0)');
pr = polyfit(crudos(:), reales(:), 1);
end

function w = pesos_blend(pct, frac, ancho)
% w=1 lejos ANTES de la frontera (usa correccion de apoyo), w=0 lejos
% DESPUES (usa correccion de balanceo), transicion coseno suave en
% [frac-ancho, frac+ancho]
w = ones(size(pct));
w(pct >= frac+ancho) = 0;
zona = pct > frac-ancho & pct < frac+ancho;
w(zona) = 0.5*(1 + cos(pi*(pct(zona)-(frac-ancho))/(2*ancho)));
end

function s = clasificar_rmsenorm(v)
if v < 1, s = 'Excelente';
elseif v < 1.5, s = 'Bueno';
elseif v < 2, s = 'Aceptable';
else, s = 'Deficiente';
end
end
