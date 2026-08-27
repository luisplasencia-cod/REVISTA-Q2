function T6 = Evaluar_Individual_Kuopio_Tobillo_Yun()
% EVALUAR_INDIVIDUAL_KUOPIO_TOBILLO_YUN  27-ago-2026 (tarea nocturna
%                   /loop, Agente B, PLAN_ZHAO_YUN.md Tarea 2): replica
%                   EXACTA de Evaluar_Individual_Kuopio_Tobillo.m para el
%                   candidato YUN 2014 - misma metodologia y mismos 6
%                   sujetos, solo cambia la fuente del calculo (llama a
%                   Evaluar_vs_Kuopio_Tobillo_Fases_Yun en vez de la
%                   version de Koopman).
%
%   UNA SOLA IMPLEMENTACION DEL MODELO: este script NO recalcula nada -
%   llama a Evaluar_vs_Kuopio_Tobillo_Fases_Yun(false) y grafica las
%   mismas curvas que producen las estadisticas reportadas. Como el
%   individual reusa el calculo del grupo (hacer_figura=false), Yun2014_
%   Wrapper NO se vuelve a correr aqui - una sola pasada por los 15
%   sujetos basta para ambos scripts (ver advertencia de rendimiento en
%   Evaluar_vs_Kuopio_Tobillo_Fases_Yun.m).
%
%   MISMOS 6 sujetos que Koopman/Zhao/RODILLA/INCLINACION_TIBIAL (el mas
%   pesado 40, el mas alto 37, el mas liviano 43, la mas baja 46 F, una
%   mujer media 19, un hombre de talla media 28) - deliberadamente los
%   mismos, para poder comparar los 3 modelos sujeto a sujeto.

addpath(fileparts(mfilename('fullpath')));
carpeta = fileparts(mfilename('fullpath'));

ids_mostrar = [40, 37, 43, 46, 19, 28];

[~, D] = Evaluar_vs_Kuopio_Tobillo_Fases_Yun(false);
pct = D.pct;

fig = figure('Name','TOBILLO Yun - comparacion individual, Kuopio', 'Position',[30 20 1400 1000], 'Color','w');
nfil = numel(ids_mostrar);
sub_id = zeros(nfil,1); sexo = strings(nfil,1); talla_cm = zeros(nfil,1); masa_kg = zeros(nfil,1);
r_x = nan(nfil,1); rmse_x = nan(nfil,1); r_y = nan(nfil,1); rmse_y = nan(nfil,1);

for r = 1:nfil
    i = find(D.sub_id == ids_mostrar(r), 1);
    if isempty(i)
        warning('Sujeto %d no disponible en la corrida', ids_mostrar(r)); continue;
    end
    xr = D.X_real(i,:); xp = D.X_pred(i,:);
    yr = D.Y_real(i,:); yp = D.Y_pred(i,:);

    sub_id(r)=D.sub_id(i); sexo(r)=D.sexo(i); talla_cm(r)=D.talla_cm(i); masa_kg(r)=D.masa_kg(i);
    r_x(r) = corr(xr(:), xp(:));  rmse_x(r) = sqrt(mean((xr-xp).^2));
    r_y(r) = corr(yr(:), yp(:));  rmse_y(r) = sqrt(mean((yr-yp).^2));

    subplot(nfil, 2, 2*r-1); hold on; grid on; box on;
    plot(pct, xr, 'k-', 'LineWidth', 2.5);
    plot(pct, xp, '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 2);
    title(sprintf('Suj %d (%s, %.1fcm, %.1fkg) - X: r=%.3f, RMSE=%.2fcm', ...
        D.sub_id(i), D.sexo(i), D.talla_cm(i), D.masa_kg(i), r_x(r), rmse_x(r)));
    ylabel('X [cm]');
    if r == nfil, xlabel('% ciclo'); end
    if r == 1, legend({'real','modelo Yun'}, 'Location','northwest'); end

    subplot(nfil, 2, 2*r); hold on; grid on; box on;
    plot(pct, yr, 'k-', 'LineWidth', 2.5);
    plot(pct, yp, '-', 'Color', [0.20 0.45 0.70], 'LineWidth', 2);
    title(sprintf('Suj %d (%s, %.1fcm, %.1fkg) - Y: r=%.3f, RMSE=%.2fcm', ...
        D.sub_id(i), D.sexo(i), D.talla_cm(i), D.masa_kg(i), r_y(r), rmse_y(r)));
    ylabel('Y [cm]');
    if r == nfil, xlabel('% ciclo'); end
end

T6 = table(sub_id, sexo, talla_cm, masa_kg, r_x, rmse_x, r_y, rmse_y);

fprintf('\n=== TOBILLO Yun, comparacion individual (6 sujetos de antropometria diversa) ===\n');
disp(T6);

sgtitle('TOBILLO Yun - sujeto por sujeto (cada uno con SU sexo/talla/masa y SU velocidad medida)', 'FontWeight','bold');

writetable(T6, fullfile(carpeta, 'Evaluar_Individual_Kuopio_Tobillo_Yun_resultados.csv'));
out_png = fullfile(carpeta, 'Evaluar_Individual_Kuopio_Tobillo_Yun_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura guardada en: %s\n', out_png);
fprintf('Tabla guardada en: %s\n', fullfile(carpeta, 'Evaluar_Individual_Kuopio_Tobillo_Yun_resultados.csv'));

end
