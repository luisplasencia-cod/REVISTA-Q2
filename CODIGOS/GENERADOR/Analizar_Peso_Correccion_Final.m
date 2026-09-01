% ANALIZAR_PESO_CORRECCION_FINAL  31-ago-2026: recalculo de "cuanto pesa
% la correccion" con el pipeline FINAL confirmado (angulo LOSO +
% posicion suave) - reemplaza a Analizar_Peso_Correccion_Posicion.m
% (que media solo la correccion de posicion de 16 tramos, sin angulo).

carpeta = fileparts(mfilename('fullpath'));
load(fullfile(carpeta, 'Evaluar_CorreccionFinal_resultados.mat'), ...
    'RealRodX','RealRodY','PredRodX','PredRodY','PredRodX_c','PredRodY_c', ...
    'RealTobX','RealTobY','PredTobX','PredTobY','PredTobX_c','PredTobY_c','pct');

campos = {'RodX','RodY','TobX','TobY'};
nombres = {'RODILLA X','RODILLA Y','TOBILLO X','TOBILLO Y'};
Crudo = struct('RodX',PredRodX,'RodY',PredRodY,'TobX',PredTobX,'TobY',PredTobY);
Final = struct('RodX',PredRodX_c,'RodY',PredRodY_c,'TobX',PredTobX_c,'TobY',PredTobY_c);
Real  = struct('RodX',RealRodX,'RodY',RealRodY,'TobX',RealTobX,'TobY',RealTobY);

fprintf('\n%-12s %12s %12s %12s %10s\n', 'Curva', 'ROM crudo', 'ROM delta', 'ROM final', '%peso');
for c = 1:4
    camp = campos{c};
    crudo_m = mean(Crudo.(camp), 1);
    final_m = mean(Final.(camp), 1);
    delta_m = final_m - crudo_m;
    rom_crudo = max(crudo_m)-min(crudo_m);
    rom_delta = max(delta_m)-min(delta_m);
    rom_final = max(final_m)-min(final_m);
    fprintf('%-12s %10.1fcm %10.1fcm %10.1fcm %9.1f%%\n', nombres{c}, rom_crudo, rom_delta, rom_final, 100*rom_delta/rom_crudo);
end

f = figure('Position',[40 40 1500 850], 'Color','w');
for c = 1:4
    camp = campos{c};
    crudo_m = mean(Crudo.(camp), 1);
    final_m = mean(Final.(camp), 1);
    real_m  = mean(Real.(camp), 1);
    delta_m = final_m - crudo_m;
    subplot(2,2,c); hold on; grid on; box on;
    plot(pct, crudo_m, '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.6);
    plot(pct, delta_m, ':', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.8);
    plot(pct, final_m, 'Color', [0.00 0.45 0.74], 'LineWidth', 2.2);
    plot(pct, real_m, 'k', 'LineWidth', 2.2);
    yline(0, 'Color', [0.85 0.85 0.85]);
    title(sprintf('%s -- ROM crudo=%.1fcm, ROM correccion=%.1fcm (%.0f%%)', nombres{c}, ...
        max(crudo_m)-min(crudo_m), max(delta_m)-min(delta_m), 100*(max(delta_m)-min(delta_m))/(max(crudo_m)-min(crudo_m))), 'FontSize', 9);
    xlabel('% ciclo'); ylabel('cm');
    if c==1, legend({'crudo (sin nada)','correccion sola (delta)','final (angulo LOSO + suave)','real'}, ...
            'Location','southoutside', 'FontSize', 8, 'NumColumns', 2); end
end
sgtitle('Peso de la correccion FINAL frente al crudo (medias, N=44)', 'FontWeight','bold');
exportgraphics(f, fullfile(carpeta, 'Peso_Correccion_figura.png'), 'Resolution', 150);
fprintf('\nGuardado: %s\n', fullfile(carpeta, 'Peso_Correccion_figura.png'));
