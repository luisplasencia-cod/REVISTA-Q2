% EVALUAR_CORRECCIONFINAL_VS_KUOPIO  31-ago-2026: figuras FINALES
% (grupo N=44 + individual 6 sujetos) con la correccion FINAL confirmada
% (angulo LOSO + Correccion_Hibrida_PenduloDoble_Core.m: warp temporal en
% X + Fourier K=14 sin cambio en Y) - real vs. crudo (sin nada) vs.
% corregido (combo final). Usa los coeficientes de PRODUCCION (los 44
% juntos) solo para visualizar, mismo criterio ya usado en el proyecto
% para las figuras de calibracion.
%
% ACTUALIZADO 31-ago-2026 (tarde-noche): la correccion de X paso de
% Fourier (podia introducir retrocesos, hasta 22/100 en tobillo) a warp
% temporal + afin(v) (Correccion_Hibrida_PenduloDoble_Core.m, Warp_
% Temporal_Core.m) - garantiza 0 retrocesos por construccion matematica.
% Y no cambia, sigue en Fourier.
%
% REAJUSTADO 31-ago-2026 (segunda pasada, tarde): SOLO TALLA como entrada
% -- igual pipeline que App_Animacion_Cadera_Rodilla_Tobillo.m y que
% Refit_CorreccionFinal_TallaSola.m (que ya reajusto Coeficientes_
% CorreccionFinal.mat con esta misma regla). Antes se pasaba muslo/tibia/
% velocidad REALES de cada sujeto de Kuopio a Estimar_Antropometria_Core,
% lo que hacia que esta figura NO fuera comparable con lo que la app
% realmente entrega a un usuario que solo mide la talla.

% CORREGIDO 01-sep-2026 (mismo motivo que Ajustar_Warp_Temporal_TallaSola.m
% y Refit_CorreccionFinal_TallaSola.m): dir('*_l_comf_01.csv') excluia 3
% sujetos (02,30,39) con datos utilizables bajo otro numero de trial. Sube
% N de 44 a 47 - el limite real (4 sujetos, marcador RTibia_RFoot_score
% faltante) no lo mueve ningun cambio de codigo.
carpeta = fullfile(fileparts(mfilename('fullpath')), 'RODILLA', 'Kuopio');
addpath(carpeta);
Tmeta_ids = readtable(fullfile(carpeta, 'raw', 'subjects_meta.csv'));
ids = Tmeta_ids.sub_id(:).';
n = 101; pct = linspace(0,100,n);
cal = Calibracion_Koopman_Kuopio_Core();

RealRodX=[]; RealRodY=[]; PredRodX=[]; PredRodY=[]; PredRodX_c=[]; PredRodY_c=[];
RealTobX=[]; RealTobY=[]; PredTobX=[]; PredTobY=[]; PredTobX_c=[]; PredTobY_c=[];
PredRodX_a=[]; PredRodY_a=[]; PredTobX_a=[]; PredTobY_a=[];  % SOLO angulo LOSO, SIN corregir posicion (31-ago-2026, pedido del usuario)
sexoAll = strings(0); tallaAll=[]; masaAll=[]; idAll=[];

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
    % congelar_vl_angulo=true (02-sep-2026): MISMA correccion que produccion
    % (Obtener_Theta_Tibia_Candidato.m/Obtener_Angulos_Candidato.m/la app) -
    % este script genera las cifras/figuras OFICIALES del informe tecnico,
    % debe quedar sincronizado con lo que la app realmente calcula. Ver
    % GUIA_INTERPRETACION.md #10.
    K1 = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, ...
        struct('nMuestras', n, 'congelar_vl_angulo', true, 'v_ref_kph', 5.0, 'l_ref_m', 1.735));
    theta1 = deg2rad(K1.cadera_flexext.angulo_deg(:).');
    theta2 = K1.theta_tibia_via_rodilla_rad(:).';
    L1_cm = antro.long_muslo_m*100; L2_cm = antro.long_tibia_m*100;
    zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;
    cad = Trayectoria_Cadera_Core(pct, zancada_cm, 2.25, 0);

    % --- CRUDO: sin nada ---
    pos0 = Cinematica_DoblePendulo_Core(theta1, theta2, L1_cm, L2_cm, cad.Xh_cm, cad.Yh_cm);
    Xk=pos0.Xk-pos0.Xk(1); Yk=pos0.Yk-pos0.Yk(1); Xa=pos0.Xa-pos0.Xa(1); Ya=pos0.Ya-pos0.Ya(1);

    % --- FINAL: angulo LOSO + correccion HIBRIDA (warp temporal en X,
    % Fourier sin cambio en Y) - reemplaza a la version solo-Fourier ---
    theta1c = deg2rad(cal.off_muslo_deg) + cal.gan_muslo*theta1;
    theta2c = deg2rad(cal.off_tibia_deg) + cal.gan_tibia*theta2;
    posc = Cinematica_DoblePendulo_Core(theta1c, theta2c, L1_cm, L2_cm, cad.Xh_cm, cad.Yh_cm);
    Xkc=posc.Xk-posc.Xk(1); Ykc=posc.Yk-posc.Yk(1); Xac=posc.Xa-posc.Xa(1); Yac=posc.Ya-posc.Ya(1);
    c = Correccion_Hibrida_PenduloDoble_Core(pct, Xkc, Ykc, Xac, Yac, tempo.velocidad_ms);

    RealRodX(end+1,:) = S.x_horiz_cm(:).';         RealRodY(end+1,:) = S.y_vert_cm(:).';
    PredRodX(end+1,:) = Xk;   PredRodY(end+1,:) = Yk;
    PredRodX_a(end+1,:) = Xkc; PredRodY_a(end+1,:) = Ykc;   % angulo LOSO, sin posicion
    PredRodX_c(end+1,:) = c.Xk; PredRodY_c(end+1,:) = c.Yk;
    RealTobX(end+1,:) = S.x_horiz_tobillo_cm(:).'; RealTobY(end+1,:) = S.y_vert_tobillo_cm(:).';
    PredTobX(end+1,:) = Xa;   PredTobY(end+1,:) = Ya;
    PredTobX_a(end+1,:) = Xac; PredTobY_a(end+1,:) = Yac;   % angulo LOSO, sin posicion
    PredTobX_c(end+1,:) = c.Xa; PredTobY_c(end+1,:) = c.Ya;

    sexoAll(end+1) = S.sexo; tallaAll(end+1) = S.talla_cm; masaAll(end+1) = S.masa_kg; idAll(end+1) = sid; %#ok<AGROW>
end
Nsuj = numel(idAll);
fprintf('N sujetos: %d\n', Nsuj);

% ---- RESUMEN FINAL (agregado 01-sep-2026): r/RMSE/RMSEnorm de la
% CORRECCION FINAL (angulo LOSO + posicion hibrida), misma formula ya
% usada en Ajustar_Warp_Temporal_TallaSola.m - es lo que llena la Tabla
% de resultados finales del informe tecnico. Antes no se imprimia aqui;
% los numeros se armaban aparte, fragil para reproducir - se deja fijo. ----
pts_norm = 2:n;
fprintf('\n=== RESUMEN FINAL (angulo LOSO + posicion HIBRIDA), SOLO TALLA, N=%d ===\n', Nsuj);
resumen_final('Rodilla X', RealRodX, PredRodX_c, pts_norm);
resumen_final('Rodilla Y', RealRodY, PredRodY_c, pts_norm);
resumen_final('Tobillo X', RealTobX, PredTobX_c, pts_norm);
resumen_final('Tobillo Y', RealTobY, PredTobY_c, pts_norm);

carpeta_out = fileparts(mfilename('fullpath'));
figura_grupo(pct, RealRodX, PredRodX, PredRodX_c, RealRodY, PredRodY, PredRodY_c, Nsuj, ...
    'Rodilla vs Kuopio -- crudo vs. CORRECCION FINAL (angulo LOSO + posicion HIBRIDA), SOLO TALLA', ...
    fullfile(carpeta_out, 'RODILLA', '06_rodilla_vs_kuopio_grupo.png'));
figura_grupo(pct, RealTobX, PredTobX, PredTobX_c, RealTobY, PredTobY, PredTobY_c, Nsuj, ...
    'Tobillo vs Kuopio -- crudo vs. CORRECCION FINAL (angulo LOSO + posicion HIBRIDA), SOLO TALLA', ...
    fullfile(carpeta_out, 'TOBILLO', '08_tobillo_vs_kuopio_grupo.png'));

% ---- NUEVO 31-ago-2026 (pedido del usuario): desglose de 4 curvas
% (real, crudo TOTAL, SOLO angulo LOSO -sin posicion-, FINAL) - para ver
% que aporta cada correccion por separado, no solo el resultado combinado ----
figura_grupo4(pct, RealRodX, PredRodX, PredRodX_a, PredRodX_c, RealRodY, PredRodY, PredRodY_a, PredRodY_c, Nsuj, ...
    'RODILLA vs Kuopio -- desglose: crudo / SOLO angulo LOSO / FINAL (angulo+posicion), SOLO TALLA', ...
    fullfile(carpeta_out, 'RODILLA', '12_rodilla_desglose_vs_kuopio_grupo.png'));
figura_grupo4(pct, RealTobX, PredTobX, PredTobX_a, PredTobX_c, RealTobY, PredTobY, PredTobY_a, PredTobY_c, Nsuj, ...
    'TOBILLO vs Kuopio -- desglose: crudo / SOLO angulo LOSO / FINAL (angulo+posicion), SOLO TALLA', ...
    fullfile(carpeta_out, 'TOBILLO', '13_tobillo_desglose_vs_kuopio_grupo.png'));

ids_mostrar = [40, 37, 43, 46, 19, 28];
sel = arrayfun(@(x) find(idAll==x,1), ids_mostrar);
figura_individual(pct, RealRodX(sel,:), PredRodX(sel,:), RealRodY(sel,:), PredRodY(sel,:), ...
    ids_mostrar, sexoAll(sel), tallaAll(sel), masaAll(sel), ...
    'RODILLA - CRUDO (sin correccion), sujeto por sujeto (Kuopio), SOLO TALLA', 'crudo', ...
    fullfile(carpeta_out, 'RODILLA', 'Evaluar_Individual_PenduloDoble_figura.png'));
figura_individual(pct, RealTobX(sel,:), PredTobX(sel,:), RealTobY(sel,:), PredTobY(sel,:), ...
    ids_mostrar, sexoAll(sel), tallaAll(sel), masaAll(sel), ...
    'TOBILLO - CRUDO (sin correccion), sujeto por sujeto (Kuopio), SOLO TALLA', 'crudo', ...
    fullfile(carpeta_out, 'TOBILLO', 'Evaluar_Individual_PenduloDoble_figura.png'));
figura_individual(pct, RealRodX(sel,:), PredRodX_c(sel,:), RealRodY(sel,:), PredRodY_c(sel,:), ...
    ids_mostrar, sexoAll(sel), tallaAll(sel), masaAll(sel), ...
    'RODILLA - CORRECCION FINAL, sujeto por sujeto (Kuopio), SOLO TALLA', 'corregido (final)', ...
    fullfile(carpeta_out, 'RODILLA', 'Evaluar_Individual_PenduloDoble_Calibrado_figura.png'));
figura_individual(pct, RealTobX(sel,:), PredTobX_c(sel,:), RealTobY(sel,:), PredTobY_c(sel,:), ...
    ids_mostrar, sexoAll(sel), tallaAll(sel), masaAll(sel), ...
    'TOBILLO - CORRECCION FINAL, sujeto por sujeto (Kuopio), SOLO TALLA', 'corregido (final)', ...
    fullfile(carpeta_out, 'TOBILLO', 'Evaluar_Individual_PenduloDoble_Calibrado_figura.png'));

save(fullfile(carpeta_out, 'Evaluar_CorreccionFinal_resultados.mat'), ...
    'RealRodX','RealRodY','PredRodX','PredRodY','PredRodX_a','PredRodY_a','PredRodX_c','PredRodY_c', ...
    'RealTobX','RealTobY','PredTobX','PredTobY','PredTobX_a','PredTobY_a','PredTobX_c','PredTobY_c','idAll','pct');

function figura_grupo(pct, RealX, PredX, PredX_c, RealY, PredY, PredY_c, Nsuj, titulo, out_png)
f = figure('Position',[80 80 1150 500], 'Color','w');
sgtitle(sprintf('%s (N=%d)', titulo, Nsuj), 'FontWeight','bold', 'FontSize', 11);
subplot(1,2,1); hold on; grid on; box on;
plot(pct, mean(RealX,1), 'k', 'LineWidth', 2.4);
plot(pct, mean(PredX,1), '--', 'Color', [0.55 0.55 0.55], 'LineWidth', 2.0);
plot(pct, mean(PredX_c,1), 'Color', [0.00 0.30 0.70], 'LineWidth', 2.4);
xlabel('% ciclo'); ylabel('Desplazamiento X (cm)');
legend({'real (media)','crudo (media)','final: angulo LOSO + posicion HIBRIDA (media)'}, 'Location','best','FontSize',8);
title('X');
subplot(1,2,2); hold on; grid on; box on;
plot(pct, mean(RealY,1), 'k', 'LineWidth', 2.4);
plot(pct, mean(PredY,1), '--', 'Color', [0.55 0.55 0.55], 'LineWidth', 2.0);
plot(pct, mean(PredY_c,1), 'Color', [0.75 0.30 0.10], 'LineWidth', 2.4);
xlabel('% ciclo'); ylabel('Desplazamiento Y (cm)');
legend({'real (media)','crudo (media)','final: angulo LOSO + posicion HIBRIDA (media)'}, 'Location','best','FontSize',8);
title('Y');
exportgraphics(f, out_png, 'Resolution', 150);
fprintf('Guardado: %s\n', out_png);
end

function figura_individual(pct, Xr, Xp, Yr, Yp, ids, sexo, talla_cm, masa_kg, titulo, etiqueta_pred, out_png)
nfil = numel(ids);
fig = figure('Position',[30 20 1300 1050], 'Color','w');
for r = 1:nfil
    rx = corr(Xr(r,:)', Xp(r,:)'); rmsex = sqrt(mean((Xr(r,:)-Xp(r,:)).^2));
    ry = corr(Yr(r,:)', Yp(r,:)'); rmsey = sqrt(mean((Yr(r,:)-Yp(r,:)).^2));
    subplot(nfil,2,2*r-1); hold on; grid on; box on;
    plot(pct, Xr(r,:), 'k-', 'LineWidth', 2.3);
    plot(pct, Xp(r,:), '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.8);
    marcar_max(pct, Xp(r,:), [0.85 0.33 0.10]);
    title(sprintf('Suj %d (%s, %.1fcm, %.1fkg) - X: r=%.3f, RMSE=%.1fcm', ...
        ids(r), sexo(r), talla_cm(r), masa_kg(r), rx, rmsex), 'FontSize', 9);
    ylabel('X [cm]'); if r==nfil, xlabel('% ciclo'); end
    if r==1, legend({'real', etiqueta_pred}, 'Location','northwest','FontSize',7); end
    subplot(nfil,2,2*r); hold on; grid on; box on;
    plot(pct, Yr(r,:), 'k-', 'LineWidth', 2.3);
    plot(pct, Yp(r,:), '-', 'Color', [0.20 0.45 0.70], 'LineWidth', 1.8);
    marcar_max(pct, Yp(r,:), [0.20 0.45 0.70]);
    title(sprintf('Suj %d - Y: r=%.3f, RMSE=%.1fcm', ids(r), ry, rmsey), 'FontSize', 9);
    ylabel('Y [cm]'); if r==nfil, xlabel('% ciclo'); end
end
sgtitle(titulo, 'FontWeight','bold');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Guardado: %s\n', out_png);
end

function figura_grupo4(pct, RealX, PredX0, PredXa, PredXc, RealY, PredY0, PredYa, PredYc, Nsuj, titulo, out_png)
% FIGURA_GRUPO4  31-ago-2026 (pedido del usuario): desglosa las 2
% correcciones por separado (antes solo se veia crudo total y final
% combinado) - real, crudo TOTAL (sin nada), SOLO angulo LOSO (sin
% corregir posicion), y FINAL (angulo+posicion) - para ver que aporta
% cada paso.
f = figure('Position',[80 80 1150 500], 'Color','w');
sgtitle(sprintf('%s (N=%d)', titulo, Nsuj), 'FontWeight','bold', 'FontSize', 11);
subplot(1,2,1); hold on; grid on; box on;
plot(pct, mean(RealX,1), 'k', 'LineWidth', 2.6);
plot(pct, mean(PredX0,1), ':', 'Color', [0.60 0.60 0.60], 'LineWidth', 1.8);
plot(pct, mean(PredXa,1), '--', 'Color', [0.45 0.65 0.20], 'LineWidth', 2.0);
plot(pct, mean(PredXc,1), 'Color', [0.00 0.30 0.70], 'LineWidth', 2.4);
xlabel('% ciclo'); ylabel('Desplazamiento X (cm)');
legend({'real (media)','crudo TOTAL, sin nada','SOLO angulo LOSO (sin posicion)','FINAL (angulo+posicion)'}, ...
    'Location','best','FontSize',7.5);
title('X');
subplot(1,2,2); hold on; grid on; box on;
plot(pct, mean(RealY,1), 'k', 'LineWidth', 2.6);
plot(pct, mean(PredY0,1), ':', 'Color', [0.60 0.60 0.60], 'LineWidth', 1.8);
plot(pct, mean(PredYa,1), '--', 'Color', [0.45 0.65 0.20], 'LineWidth', 2.0);
plot(pct, mean(PredYc,1), 'Color', [0.75 0.30 0.10], 'LineWidth', 2.4);
xlabel('% ciclo'); ylabel('Desplazamiento Y (cm)');
legend({'real (media)','crudo TOTAL, sin nada','SOLO angulo LOSO (sin posicion)','FINAL (angulo+posicion)'}, ...
    'Location','best','FontSize',7.5);
title('Y');
exportgraphics(f, out_png, 'Resolution', 150);
fprintf('Guardado: %s\n', out_png);
end

function marcar_max(pct, curva, col)
% MARCAR_MAX  31-ago-2026 (pedido del usuario): marca el punto MAXIMO de
% la curva PREDICHA con su valor numerico visible - para poder comparar
% a ojo, cifra contra cifra, con la lectura en vivo de App_Animacion_
% Cadera_Rodilla_Tobillo.m al ingresar la MISMA talla.
[vmax, imax] = max(curva);
plot(pct(imax), vmax, 'o', 'MarkerSize', 6, 'MarkerFaceColor', col, 'MarkerEdgeColor', 'k');
text(pct(imax), vmax, sprintf('  %.2f cm', vmax), 'FontSize', 7.5, ...
    'FontWeight', 'bold', 'Color', col, 'VerticalAlignment', 'bottom');
end

function resumen_final(nombre, real, pred, pts_norm)
Nsuj = size(real,1);
r = arrayfun(@(k) corr(pred(k,:)', real(k,:)'), 1:Nsuj);
rmse = sqrt(mean((pred-real).^2,2));
sd_use = std(real,0,1); sd_use(sd_use<1e-6) = 1e-6;
err_norm = (pred(:,pts_norm) - real(:,pts_norm)) ./ sd_use(pts_norm);
rmsenorm = mean(sqrt(mean(err_norm.^2, 2)));
if rmsenorm < 1, clase = 'Excelente';
elseif rmsenorm < 1.5, clase = 'Bueno';
elseif rmsenorm < 2, clase = 'Aceptable';
else, clase = 'Deficiente';
end
fprintf('%-10s r=%.3f  RMSE=%.2f  RMSEnorm=%.2f  (%s)\n', nombre, mean(r), mean(rmse), rmsenorm, clase);
end
