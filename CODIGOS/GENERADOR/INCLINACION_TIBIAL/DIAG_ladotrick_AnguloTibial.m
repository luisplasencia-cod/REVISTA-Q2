function DIAG_ladotrick_AnguloTibial()
% DIAG_LADOTRICK_ANGULOTIBIAL  27-ago-2026: responde el pendiente abierto
% en CIERRE_TOBILLO.md #11 / PIPELINE_KOOPMAN_KUOPIO.md #8: ¿el "truco de
% lado" que ayuda a Zhao/Yun contra Maastricht (RODILLA/CIERRE_RODILLA.md
% #1-ter) tambien ayuda para el ANGULO TIBIAL nativo contra Kuopio 2024?
%
% Metodo: identico a Evaluar_vs_Kuopio_AnguloTibial_Zhao.m /
% _Yun.m (angulo real vs Kuopio, calibracion afin LOSO, r/RMSE/RMSEnorm),
% pero corriendo LOS DOS LADOS de cada candidato en la misma pasada -
% Yun2014_Wrapper ya calcula R_ y L_ en una sola llamada por sujeto (no
% hace falta correr la regresion GP dos veces), y Zhao2026_Core acepta
% 'lado' como parametro directo (llamada cerrada, rapida en los dos casos).
% No se modifica ningun archivo existente (Obtener_Angulos_Candidato.m,
% las 4 evaluaciones ya cerradas de Koopman/Zhao-nativo/Yun-nativo).

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
carpeta = fileparts(mfilename('fullpath'));
dir_kuopio = fullfile(carpeta, '..', 'RODILLA', 'Kuopio');
addpath(dir_kuopio);

Tmeta = readtable(fullfile(dir_kuopio, 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id;
n = numel(ids);
pct = 0:100;

nombres = {'Zhao_izquierda_nativo','Zhao_derecha_alt','Yun_R_nativo','Yun_L_alt'};
Ang_real_all = nan(n,101);
Ang_pred_all = nan(n,101,4);
ok = false(n,1);

for i = 1:n
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
        theta_real_deg = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));

        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1));
        antro = Estimar_Antropometria_Core(antro_in);

        Zi = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/S.T_ciclo_s, struct('lado','izquierda'));
        Zd = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/S.T_ciclo_s, struct('lado','derecha'));

        antro14 = antro; antro14.edad_anios = 25;
        p14 = [antro14.edad_anios, antro14.talla_m*100, antro14.masa_kg, double(upper(antro14.sexo(1))=='M'), ...
               antro14.long_muslo_m*100, antro14.long_tibia_m*100, ...
               32.8, 29.7, 25.5, 10, antro14.long_pie_m*100, 7.30, 7.10, 9.80];
        Y = Yun2014_Wrapper(p14);   % UNA sola llamada -> R_ y L_ ya vienen los dos

        curvas = { rad2deg(Zi.theta_tibia_rad), rad2deg(Zd.theta_tibia_rad), ...
                   rad2deg(Y.theta_tibia_via_tobillo_R_rad), rad2deg(Y.theta_tibia_via_tobillo_L_rad) };

        Ang_real_all(i,:) = theta_real_deg;
        for c = 1:4
            cu = curvas{c};
            pct_c = linspace(0,100,numel(cu));
            Ang_pred_all(i,:,c) = interp1(pct_c, cu, pct, 'pchip');
        end
        ok(i) = true;
        fprintf('Sujeto %d OK (%d/%d)\n', sid, i, n);
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
    end
end
idx_ok = find(ok);
sd_fase = std(Ang_real_all(idx_ok,:), 0, 1); sd_fase(sd_fase < 1e-6) = 1e-6;

fprintf('\n=== TRUCO DE LADO - ANGULO TIBIAL vs Kuopio 2024, N=%d ===\n', numel(idx_ok));
fprintf('%-24s %10s %10s %10s %10s %10s\n', 'Config', 'r_crudo', 'r_cal', 'RMSE_cal', 'RMSEnorm_cal', 'ganancia');

R = table();
for c = 1:4
    r_crudo = nan(n,1); r_cal = nan(n,1); rmse_cal = nan(n,1); rmsenorm_cal = nan(n,1); ganancia = nan(n,1);
    for k = 1:numel(idx_ok)
        i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
        real_i = Ang_real_all(i,:); pred_i = Ang_pred_all(i,:,c);
        r_crudo(i) = corr(real_i(:), pred_i(:));
        p = polyfit(reshape(Ang_pred_all(otros,:,c),1,[]), reshape(Ang_real_all(otros,:),1,[]), 1);
        ganancia(i) = p(1);
        pred_cal = polyval(p, pred_i);
        r_cal(i) = corr(real_i(:), pred_cal(:));
        err_cal = pred_cal - real_i;
        rmse_cal(i) = sqrt(mean(err_cal.^2));
        rmsenorm_cal(i) = sqrt(mean((err_cal./sd_fase).^2));
    end
    fprintf('%-24s %10.3f %10.3f %10.2f %10.3f %10.3f\n', nombres{c}, ...
        mean(r_crudo(idx_ok)), mean(r_cal(idx_ok)), mean(rmse_cal(idx_ok)), mean(rmsenorm_cal(idx_ok)), mean(ganancia(idx_ok)));
    Rc = table(ids(idx_ok), repmat(string(nombres{c}),numel(idx_ok),1), r_crudo(idx_ok), r_cal(idx_ok), rmse_cal(idx_ok), rmsenorm_cal(idx_ok), ganancia(idx_ok), ...
        'VariableNames', {'sub_id','config','r_crudo','r_cal','rmse_cal','rmsenorm_cal','ganancia'});
    R = [R; Rc]; %#ok<AGROW>
end

writetable(R, fullfile(carpeta, 'DIAG_ladotrick_AnguloTibial_resultados.csv'));
fprintf('\nTabla: %s\n', fullfile(carpeta, 'DIAG_ladotrick_AnguloTibial_resultados.csv'));

end
