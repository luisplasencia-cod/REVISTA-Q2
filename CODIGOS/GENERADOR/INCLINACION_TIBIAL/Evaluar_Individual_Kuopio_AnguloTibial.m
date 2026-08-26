function T6 = Evaluar_Individual_Kuopio_AnguloTibial()
% EVALUAR_INDIVIDUAL_KUOPIO_ANGULOTIBIAL  25-ago-2026: el MODELO FINAL del
%                   ANGULO DE INCLINACION TIBIAL (Koopman + calibracion
%                   afin LOSO, ver Evaluar_vs_Kuopio_AnguloTibial.m)
%                   sujeto por sujeto, no en promedio.
%
%   POR QUE ESTA PRUEBA ES LA QUE MANDA (objecion del usuario, 25-ago-2026):
%   el modelo se alimenta de sexo/talla/masa + velocidad medida de CADA
%   sujeto, asi que la comparacion con sentido es sujeto contra su propia
%   prediccion. Promediar curvas de sujetos con antropometria distinta
%   mezcla trayectorias que no son comparables entre si.
%
%   Cada fila muestra el MISMO sujeto dos veces: Koopman crudo (izquierda)
%   y calibrado LOSO (derecha), en la misma escala vertical - se ve
%   directamente que la forma ya era correcta (r igual en ambos) y que lo
%   que corrige la calibracion es escala/offset.
%
%   UNA SOLA IMPLEMENTACION DEL MODELO: llama a
%   Evaluar_vs_Kuopio_AnguloTibial(false) y grafica las mismas curvas que
%   producen las estadisticas reportadas.
%
%   MISMOS 6 sujetos que RODILLA/ y TOBILLO/ - deliberadamente los mismos,
%   para poder comparar los 3 modelos sujeto a sujeto.

addpath(fileparts(mfilename('fullpath')));
carpeta = fileparts(mfilename('fullpath'));

ids_mostrar = [40, 37, 43, 46, 19, 28];

[~, D] = Evaluar_vs_Kuopio_AnguloTibial(false);
pct = D.pct;

fig = figure('Name','ANGULO TIBIAL - comparacion individual, Kuopio', 'Position',[30 20 1400 1000], 'Color','w');
nfil = numel(ids_mostrar);
sub_id = zeros(nfil,1); sexo = strings(nfil,1); talla_cm = zeros(nfil,1); masa_kg = zeros(nfil,1);
r_ang = nan(nfil,1); rmse_crudo = nan(nfil,1); rmse_cal = nan(nfil,1);
rmsenorm_crudo = nan(nfil,1); rmsenorm_cal = nan(nfil,1);

% escala vertical comun a todos los paneles: la comparacion crudo/calibrado
% solo se lee bien si ambos estan en la misma escala
todo = [D.Ang_real(:); D.Ang_crudo(:); D.Ang_cal(:)];
ylim_com = [min(todo) max(todo)] + [-3 3];

for r = 1:nfil
    i = find(D.sub_id == ids_mostrar(r), 1);
    if isempty(i)
        warning('Sujeto %d no disponible en la corrida', ids_mostrar(r)); continue;
    end
    ar = D.Ang_real(i,:); ac = D.Ang_crudo(i,:); ak = D.Ang_cal(i,:);

    sub_id(r)=D.sub_id(i); sexo(r)=D.sexo(i); talla_cm(r)=D.talla_cm(i); masa_kg(r)=D.masa_kg(i);
    r_ang(r) = corr(ar(:), ak(:));
    rmse_crudo(r) = sqrt(mean((ac-ar).^2));
    rmse_cal(r)   = sqrt(mean((ak-ar).^2));
    rmsenorm_crudo(r) = sqrt(mean(((ac-ar)./D.sd_fase).^2));
    rmsenorm_cal(r)   = sqrt(mean(((ak-ar)./D.sd_fase).^2));

    subplot(nfil, 2, 2*r-1); hold on; grid on; box on;
    plot(pct, ar, 'k-', 'LineWidth', 2.5);
    plot(pct, ac, '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 2);
    ylim(ylim_com);
    title(sprintf('Suj %d (%s, %.1fcm, %.1fkg) - CRUDO: RMSE=%.2f%c, RMSEnorm=%.2f', ...
        D.sub_id(i), D.sexo(i), D.talla_cm(i), D.masa_kg(i), rmse_crudo(r), char(176), rmsenorm_crudo(r)));
    ylabel('\theta_{tibia} [\circ]');
    if r == nfil, xlabel('% ciclo'); end
    if r == 1, legend({'real','Koopman crudo'}, 'Location','northwest'); end

    subplot(nfil, 2, 2*r); hold on; grid on; box on;
    plot(pct, ar, 'k-', 'LineWidth', 2.5);
    plot(pct, ak, '-', 'Color', [0.20 0.45 0.70], 'LineWidth', 2);
    ylim(ylim_com);
    title(sprintf('Suj %d (%s, %.1fcm, %.1fkg) - CALIBRADO: r=%.3f, RMSE=%.2f%c, RMSEnorm=%.2f', ...
        D.sub_id(i), D.sexo(i), D.talla_cm(i), D.masa_kg(i), r_ang(r), rmse_cal(r), char(176), rmsenorm_cal(r)));
    ylabel('\theta_{tibia} [\circ]');
    if r == nfil, xlabel('% ciclo'); end
    if r == 1, legend({'real','MODELO FINAL'}, 'Location','northwest'); end
end

T6 = table(sub_id, sexo, talla_cm, masa_kg, r_ang, rmse_crudo, rmse_cal, rmsenorm_crudo, rmsenorm_cal);

fprintf('\n=== ANGULO TIBIAL, comparacion individual (6 sujetos de antropometria diversa) ===\n');
disp(T6);

sgtitle('ANGULO TIBIAL - Koopman crudo (izq) vs modelo final calibrado (der), sujeto por sujeto', 'FontWeight','bold');

writetable(T6, fullfile(carpeta, 'Evaluar_Individual_Kuopio_AnguloTibial_resultados.csv'));
out_png = fullfile(carpeta, 'Evaluar_Individual_Kuopio_AnguloTibial_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura guardada en: %s\n', out_png);
fprintf('Tabla guardada en: %s\n', fullfile(carpeta, 'Evaluar_Individual_Kuopio_AnguloTibial_resultados.csv'));

end
