function T6 = Evaluar_Individual_Kuopio()
% EVALUAR_INDIVIDUAL_KUOPIO  25-ago-2026: el MODELO FINAL de RODILLA
%                   sujeto por sujeto, no en promedio - pedido explicito
%                   del usuario: "hacer varias pruebas... con diferente
%                   sexo talla y masa... comparar al menos 5 muestras".
%
%   POR QUE ESTA PRUEBA ES LA QUE MANDA (objecion del usuario, 25-ago-2026):
%   el modelo se alimenta de sexo/talla/masa + velocidad medida de CADA
%   sujeto, asi que la comparacion con sentido es sujeto contra su propia
%   prediccion. Promediar trayectorias de sujetos con antropometria
%   distinta mezcla curvas que no son comparables entre si. La figura de
%   grupo (Evaluar_vs_Kuopio_Avance.m) ya no promedia: muestra pares por
%   sujeto y curvas de error. Esta figura es el detalle de esos pares.
%
%   UNA SOLA IMPLEMENTACION DEL MODELO: este script NO recalcula nada -
%   llama a Evaluar_vs_Kuopio_Avance(false) y grafica las mismas curvas
%   que producen las estadisticas reportadas. Asi el individual no puede
%   divergir del agregado (antes ambos duplicaban la logica).
%
%   6 sujetos elegidos para maximizar la diversidad antropometrica
%   disponible en la muestra piloto de 15 (no al azar): el mas pesado
%   (40, 136kg), el mas alto (37, 186.6cm), el mas liviano (43, 61kg),
%   la mas baja (46, 165cm F), una mujer de talla/masa media (19) y un
%   hombre de talla media (28). Son los MISMOS 6 sujetos en las 3
%   carpetas (RODILLA/TOBILLO/INCLINACION_TIBIAL) para poder comparar
%   los 3 modelos sujeto a sujeto.

addpath(fileparts(mfilename('fullpath')));
carpeta = fileparts(mfilename('fullpath'));

ids_mostrar = [40, 37, 43, 46, 19, 28];   % diversidad maxima de sexo/talla/masa

[~, D] = Evaluar_vs_Kuopio_Avance(false);
pct = D.pct;

fig = figure('Name','RODILLA - comparacion individual, Kuopio', 'Position',[30 20 1400 1000], 'Color','w');
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
    if r == 1, legend({'real','modelo'}, 'Location','northwest'); end

    subplot(nfil, 2, 2*r); hold on; grid on; box on;
    plot(pct, yr, 'k-', 'LineWidth', 2.5);
    plot(pct, yp, '-', 'Color', [0.20 0.45 0.70], 'LineWidth', 2);
    title(sprintf('Suj %d (%s, %.1fcm, %.1fkg) - Y: r=%.3f, RMSE=%.2fcm', ...
        D.sub_id(i), D.sexo(i), D.talla_cm(i), D.masa_kg(i), r_y(r), rmse_y(r)));
    ylabel('Y [cm]');
    if r == nfil, xlabel('% ciclo'); end
end

T6 = table(sub_id, sexo, talla_cm, masa_kg, r_x, rmse_x, r_y, rmse_y);

fprintf('\n=== RODILLA, comparacion individual (6 sujetos de antropometria diversa) ===\n');
disp(T6);

sgtitle('RODILLA - modelo final, sujeto por sujeto (cada uno con SU sexo/talla/masa y SU velocidad medida)', 'FontWeight','bold');

writetable(T6, fullfile(carpeta, 'Evaluar_Individual_Kuopio_resultados.csv'));
out_png = fullfile(carpeta, 'Evaluar_Individual_Kuopio_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura guardada en: %s\n', out_png);
fprintf('Tabla guardada en: %s\n', fullfile(carpeta, 'Evaluar_Individual_Kuopio_resultados.csv'));

end
