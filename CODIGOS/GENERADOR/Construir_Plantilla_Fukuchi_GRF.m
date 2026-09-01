function plantilla = Construir_Plantilla_Fukuchi_GRF()
% CONSTRUIR_PLANTILLA_FUKUCHI_GRF  29-ago-2026: construye la plantilla
% empirica de %BW(t) "que debe seguir una persona sana" (pedido del
% usuario) promediando la Fz vertical REAL de los 42 sujetos de Fukuchi et
% al. 2018 (pierna derecha, marcha comoda overground) - sin pasar por
% ningun modelo de angulos articulares ni de dinamica teorica. Fukuchi
% nunca se usa para entrenar Koopman/Zhao/Yun (§11-bis de JUSTIFICACION_
% MODELOS_Y_ESTADO_Q1.md) - construir y validar esta plantilla contra
% Kuopio (otro pais, otro equipo, 0 sujetos en comun) es una validacion
% limpia, no un LOSO.
carpeta = fileparts(mfilename('fullpath'));
addpath(fullfile(carpeta,'RODILLA','Fukuchi'));

curvas = nan(42,101);
vel = nan(42,1);
for sid = 1:42
    try
        S = Cargar_Fukuchi2018_GRF_Core(sid);
    catch ME
        fprintf('sujeto %d: fallo (%s)\n', sid, ME.message);
        continue
    end
    curvas(sid,:) = S.GRF_vertical_pctBW;
    vel(sid) = S.speed_ms;
end
ok = ~any(isnan(curvas),2);
fprintf('sujetos validos: %d/42\n', sum(ok));

plantilla.pct = 0:100;
plantilla.media_pctBW = mean(curvas(ok,:),1);
plantilla.sd_pctBW = std(curvas(ok,:),0,1);
plantilla.n = sum(ok);
plantilla.velocidad_media_ms = mean(vel(ok));
plantilla.velocidad_sd_ms = std(vel(ok));
plantilla.curvas_individuales_pctBW = curvas(ok,:);

fig = figure('Color','w','Position',[80 80 700 450]);
hold on; box on;
for i = find(ok)'
    plot(plantilla.pct, curvas(i,:), '-', 'Color',[0.75 0.75 0.75],'LineWidth',0.5);
end
plot(plantilla.pct, plantilla.media_pctBW, 'b-', 'LineWidth',2.5);
plot(plantilla.pct, plantilla.media_pctBW+plantilla.sd_pctBW, 'b--','LineWidth',1);
plot(plantilla.pct, plantilla.media_pctBW-plantilla.sd_pctBW, 'b--','LineWidth',1);
xlabel('% ciclo'); ylabel('Fz %BW');
title(sprintf('Plantilla Fukuchi (N=%d, v=%.2f±%.2fm/s) - media±SD', plantilla.n, plantilla.velocidad_media_ms, plantilla.velocidad_sd_ms));
grid on;
saveas(fig, fullfile(carpeta,'Plantilla_Fukuchi_GRF_figura.png'));
fprintf('Guardada figura. Media pico1=%.1f valle=%.1f pico2=%.1f\n', ...
    max(plantilla.media_pctBW(1:50)), min(plantilla.media_pctBW(20:40)), max(plantilla.media_pctBW(35:60)));

save(fullfile(carpeta,'Plantilla_Fukuchi_GRF.mat'), 'plantilla');
end
