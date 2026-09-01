function T = Explorar_ThetaPie_para_Residuo_Y()
% EXPLORAR_THETAPIE_PARA_RESIDUO_Y  30-ago-2026: prueba si el angulo de
%                   tobillo que SI publica Koopman (tobillo_flexext, nunca
%                   usado hasta ahora para reconstruir posicion - solo se
%                   uso en la via-tobillo descartada de la reduccion
%                   tibial) explica parte del residuo Y que hoy es 100%
%                   empirico (Kuopio) - pedido del usuario: bajar el peso
%                   de la correccion empirica incorporando mas de lo que
%                   Koopman ya publica, en vez de mas dato de Kuopio.
%
% IDEA: theta_pie(t) = theta_tibia_via_rodilla(t) + phi_tobillo_Koopman(t)
%       (angulo ABSOLUTO del pie, derivado sin dato nuevo - combina la via
%       rodilla ya validada con el canal de tobillo de Koopman que hasta
%       hoy no se usaba para nada geometrico). Si el pie rota mas
%       (heel-rise) hacia el final del apoyo, el tobillo real debe subir
%       - se prueba esa relacion con una calibracion AFIN LOSO, MISMO
%       metodo ya usado y validado para muslo/tibia (Seccion "La
%       correccion" del informe) - no una formula geometrica inventada.
%
% CRITERIO DE EXITO: si la calibracion afin LOSO explica una fraccion
% real del residuo Y (RMSE del residuo restante < RMSE del residuo
% completo actual), se puede reducir la porcion 100% empirica sin perder
% precision - el "sobrante" (mas chico) seguiria viniendo de Kuopio.
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
dir_generador = fullfile(carpeta, '..');
dir_kuopio = fullfile(carpeta, '..', 'RODILLA', 'Kuopio');
addpath(dir_generador); addpath(dir_kuopio);

ids = [1,4,13,19,22,25,28,31,37,40,43,46,49];
n = numel(ids);
npts = 101;

ThetaPie_ap = cell(n,1); ResiduoY_real = cell(n,1); pc_arr = nan(n,1);
ok = false(n,1);

for i = 1:n
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, ...
            'sexo', S.sexo(1), 'velocidad_ms', S.speed_ms, ...
            'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000);
        antro = Estimar_Antropometria_Core(antro_in);
        tempo = Temporizacion_Core(antro, 'Koopman');
        tempo.tiempo_ciclo_s = S.T_ciclo_s;
        [th_m, th_t] = Obtener_Angulos_Candidato('Koopman', antro, tempo, npts);
        out = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, struct('nMuestras', npts));

        pct_corte = tempo.frac_apoyo*100;
        pc = round(pct_corte) + 1;
        theta_tibia_ap_deg = rad2deg(th_t.apoyo(1:pc));
        phi_tobillo_ap = interp1(linspace(0,100,npts), out.tobillo_flexext.angulo_deg, ...
            linspace(0,pct_corte,pc), 'pchip');
        % signo_tobillo=-1, misma convencion que Obtener_Theta_Tibia_Candidato.m
        theta_pie_ap = theta_tibia_ap_deg + (-1)*phi_tobillo_ap;

        ThetaPie_ap{i} = theta_pie_ap(:);
        ResiduoY_real{i} = S.y_vert_tobillo_cm(1:pc)';
        pc_arr(i) = pc;
        ok(i) = true;
    catch ME
        fprintf('fallo %d: %s\n', sid, ME.message);
    end
end
idx_ok = find(ok);
nk = numel(idx_ok);

rmse_original = nan(nk,1); rmse_con_thetapie = nan(nk,1);
gan = nan(nk,1); off = nan(nk,1);

for k = 1:nk
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);

    % LOSO: ajustar Y_residuo = a + b*theta_pie con los OTROS 12 (todos
    % los puntos de todos los sujetos, apilados)
    allX = []; allY = [];
    for j = otros(:)'
        allX = [allX; ThetaPie_ap{j}]; %#ok<AGROW>
        allY = [allY; ResiduoY_real{j}]; %#ok<AGROW>
    end
    p = polyfit(allX, allY, 1);
    gan(k) = p(1); off(k) = p(2);

    pred_thetapie = polyval(p, ThetaPie_ap{i});
    real_y = ResiduoY_real{i};

    % modelo ORIGINAL (100% empirico): promedio de los residuos Y de los
    % otros 12 (igual que el modelo vigente del proyecto)
    pred_original = zeros(size(real_y));
    for j = otros(:)'
        L = min(numel(pred_original), numel(ResiduoY_real{j}));
        pred_original(1:L) = pred_original(1:L) + ResiduoY_real{j}(1:L)/numel(otros);
    end

    rmse_original(k) = sqrt(mean((real_y - pred_original).^2));
    rmse_con_thetapie(k) = sqrt(mean((real_y - pred_thetapie).^2));
end

T = table(ids(idx_ok)', gan, off, rmse_original, rmse_con_thetapie, ...
    'VariableNames', {'sub_id','ganancia_thetapie','offset_thetapie','rmse_residuo_100pct_empirico','rmse_con_thetapie_koopman'});

fprintf('\n=== theta_pie (Koopman, sin dato nuevo) como predictor del residuo Y, LOSO N=%d ===\n', nk);
fprintf('RMSE modelo vigente (100%% empirico, promedio de Kuopio): %.3f cm\n', mean(T.rmse_residuo_100pct_empirico));
fprintf('RMSE con theta_pie calibrado (afin LOSO, usa Koopman):     %.3f cm\n', mean(T.rmse_con_thetapie_koopman));
mejora = 100*(1 - mean(T.rmse_con_thetapie_koopman)/mean(T.rmse_residuo_100pct_empirico));
fprintf('Cambio: %.1f%% %s\n', abs(mejora), ternary(mejora>0,'de MEJORA (theta_pie explica parte real del residuo)','de EMPEORAMIENTO (no ayuda, se descarta)'));

writetable(T, fullfile(carpeta, 'Explorar_ThetaPie_para_Residuo_Y_resultados.csv'));
end

function s = ternary(cond, a, b)
if cond, s = a; else, s = b; end
end
