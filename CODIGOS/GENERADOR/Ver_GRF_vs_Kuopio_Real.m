function Ver_GRF_vs_Kuopio_Real(ids)
% VER_GRF_VS_KUOPIO_REAL  28-ago-2026: figura combinada de Fz PREDICHA vs
% Fz REAL (plataforma de fuerza, Kuopio) para varios sujetos reales, para
% inspeccion visual directa (pedido del usuario: "quiero afinar el GRF
% pero no puedo ver los resultados visualmente").
if nargin < 1 || isempty(ids)
    ids = [1, 28, 37, 43, 46, 13];  % mezcla de casos buenos y malos ya vistos
end
carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta); addpath(fullfile(carpeta,'RODILLA','Kuopio'));

nc = numel(ids);
fig = figure('Color','w','Position',[40 20 500 230*nc]);
for i = 1:nc
    sid = ids(i);
    S = Cargar_Kuopio2024_Core(sid);
    R = Extraer_GRF_Kuopio_Core(sid);
    antro = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1), ...
        'velocidad_ms', S.speed_ms, 'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000);
    gr = GRF_Newton_ApoyoSimple_Core(antro, 'Koopman');
    mask = gr.apoyo_simple_mask_estricta;
    pred_en_real = interp1(gr.pct_ciclo, gr.GRF_vertical_pctBW, R.pct_ciclo, 'pchip');
    mask_en_real = interp1(gr.pct_ciclo, double(mask), R.pct_ciclo, 'nearest') > 0;

    subplot(nc,1,i); hold on; box on;
    for ip = 1:R.n_pasos_validos
        if R.placa_todos(ip) ~= 2, continue; end
        plot(R.pct_ciclo, R.Fz_pctBW_todos(ip,:), '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1);
    end
    plot(R.pct_ciclo(mask_en_real), pred_en_real(mask_en_real), 'b-', 'LineWidth', 2.5);
    plot(R.pct_ciclo(~mask_en_real), pred_en_real(~mask_en_real), 'b:', 'LineWidth', 1);
    xlim([0 65]); grid on;
    r_ok = ~isnan(pred_en_real) & mask_en_real;
    ylabel(sprintf('Sujeto %d\n(%.0fkg,%.2fm)\nFz %%BW', sid, S.masa_kg, S.talla_cm/100), 'FontSize', 8);
    if i==1
        title('Fz real (gris, cada paso en placa 2) vs predicha (azul: solido=ventana confiable, punteado=no confiable)', 'FontSize', 9);
        legend({'real','','','predicho (confiable)'}, 'Location','best','FontSize',7);
    end
    if i==nc, xlabel('% ciclo'); end
    set(gca,'FontSize',8);
end
out_png = fullfile(carpeta, 'Ver_GRF_vs_Kuopio_Real_figura.png');
exportgraphics(fig, out_png, 'Resolution', 140);
fprintf('Guardado: %s\n', out_png);
end
