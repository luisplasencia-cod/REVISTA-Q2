% ANALISIS_CORRECCION_FASE3_NUMTRAMOS  Continuacion (31-ago-2026):
% E7 (cuartiles, 4 tramos) gano la Fase 2. Antes de fijarlo como
% respuesta final, se barre el NUMERO de tramos (2,3,4,6,8,10,12) via
% LOSO real (N=44) para encontrar el punto donde mas tramos deja de
% ayudar o empieza a sobreajustar (RMSEnorm en el sujeto dejado afuera
% deja de bajar o sube) - la justificacion matematica de cuantos tramos
% usar es esta curva, no un numero elegido a mano.

carpeta = fileparts(mfilename('fullpath'));
load(fullfile(carpeta, 'Analisis_Correccion_resultados.mat'), 'Real','S_all','pct');
load(fullfile(carpeta, 'Analisis_Correccion_Fase2_resultados.mat'), 'SD');
N = numel(S_all); n = numel(pct);
campos_curva = {'RodX','RodY','TobX','TobY'};
nombres_curva = {'RODILLA X','RODILLA Y','TOBILLO X','TOBILLO Y'};

pos0_all = arrayfun(@(k) correr_pendulo(S_all(k).theta1_koop, S_all(k).theta2_koop, S_all(k), pct), 1:N);

num_tramos_lista = [2 3 4 6 8 10 12 16 20];
RMSEnorm_tabla = nan(numel(num_tramos_lista), 4);
r_tabla = nan(numel(num_tramos_lista), 4);

pts_norm = 2:n;   % excluye t=0 (SD=0 por construccion, ver Fase2)

for t = 1:numel(num_tramos_lista)
    ntr = num_tramos_lista(t);
    bordes = linspace(0, 100, ntr+1);
    Pred = struct();
    for c = 1:4, Pred.(campos_curva{c}) = nan(N,n); end

    for i = 1:N
        otros = setdiff(1:N, i);
        pos0 = pos0_all(i);
        for c = 1:4
            camp = campos_curva{c};
            v = pos0.(camp);
            for q = 1:ntr
                idxq = pct >= bordes(q) & pct <= bordes(q+1);
                crudos = cell2mat(arrayfun(@(k) pos0_all(k).(camp)(idxq), otros, 'uni', 0)');
                reales = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp])(idxq), otros, 'uni', 0)');
                pr = polyfit(crudos(:), reales(:), 1);
                v(idxq) = pr(2) + pr(1)*v(idxq);
            end
            Pred.(camp)(i,:) = v;
        end
    end

    for c = 1:4
        camp = campos_curva{c};
        pred = Pred.(camp); real = Real.(camp);
        r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:N);
        err_norm = (pred(:,pts_norm) - real(:,pts_norm)) ./ SD.(camp)(pts_norm);
        rmsenorm = sqrt(mean(err_norm.^2, 2));
        RMSEnorm_tabla(t,c) = mean(rmsenorm);
        r_tabla(t,c) = mean(r);
    end
    fprintf('tramos=%2d  ', ntr);
    for c = 1:4, fprintf('%s: r=%.3f n=%.2f   ', nombres_curva{c}, r_tabla(t,c), RMSEnorm_tabla(t,c)); end
    fprintf('\n');
end

save(fullfile(carpeta, 'Analisis_Correccion_Fase3_resultados.mat'), 'num_tramos_lista','RMSEnorm_tabla','r_tabla');

f = figure('Position',[60 60 1200 500], 'Color','w');
subplot(1,2,1); hold on; grid on; box on;
for c = 1:4, plot(num_tramos_lista, RMSEnorm_tabla(:,c), '-o', 'LineWidth', 1.6); end
yline(1, '--k'); yline(1.5, ':k');
xlabel('numero de tramos'); ylabel('RMSEnorm (LOSO)');
legend(nombres_curva, 'Location','best'); title('RMSEnorm vs. granularidad');

subplot(1,2,2); hold on; grid on; box on;
for c = 1:4, plot(num_tramos_lista, r_tabla(:,c), '-o', 'LineWidth', 1.6); end
xlabel('numero de tramos'); ylabel('r (LOSO)');
legend(nombres_curva, 'Location','best'); title('r vs. granularidad');
sgtitle('Busqueda del numero de tramos optimo (LOSO real, N=44)', 'FontWeight','bold');
exportgraphics(f, fullfile(carpeta, 'Analisis_Correccion_Fase3_figura.png'), 'Resolution', 150);
fprintf('Guardado figura.\n');

function pos = correr_pendulo(theta1, theta2, s, pct)
cad = Trayectoria_Cadera_Core(pct, s.zancada_cm, 2.25, 0);
p = Cinematica_DoblePendulo_Core(theta1, theta2, s.L1_cm, s.L2_cm, cad.Xh_cm, cad.Yh_cm);
pos = struct();
pos.RodX = p.Xk - p.Xk(1); pos.RodY = p.Yk - p.Yk(1);
pos.TobX = p.Xa - p.Xa(1); pos.TobY = p.Ya - p.Ya(1);
end
