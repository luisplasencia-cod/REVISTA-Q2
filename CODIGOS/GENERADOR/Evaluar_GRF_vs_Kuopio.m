function [T, D] = Evaluar_GRF_vs_Kuopio(ids, candidato)
% EVALUAR_GRF_VS_KUOPIO  28-ago-2026: PRIMERA validacion real de la Fz
% predicha (GRF_Newton_ApoyoSimple_Core.m) contra fuerza REAL medida
% (Extraer_GRF_Kuopio_Core.m, plataformas del Kuopio Gait Dataset) -
% mismo patron que RODILLA/TOBILLO/INCLINACION_TIBIAL, pero para fuerza,
% nunca hecho antes en este proyecto.
%
%   [T, D] = Evaluar_GRF_vs_Kuopio()                 % todos los sujetos disponibles
%   [T, D] = Evaluar_GRF_vs_Kuopio(ids)
%
% METODO:
%   1) Antropometria y velocidad REAL del sujeto (Cargar_Kuopio2024_Core.m)
%      -> GRF_Newton_ApoyoSimple_Core.m (Koopman, calibrado) -> Fz PREDICHA,
%      UNA por sujeto (no depende de que paso especifico se mida).
%   2) Fz REAL de cada paso que cayo limpio en una placa (Extraer_GRF_
%      Kuopio_Core.m, ya con el signo corregido y el umbral de 20N).
%   3) Comparacion restringida a la ventana %ciclo donde el MODELO es
%      confiable (apoyo_simple_mask_estricta) - el lado real no necesita
%      su propia restriccion ahi porque una placa dedicada a un pie no
%      tiene el problema de "dos piernas mezcladas" que si tiene el
%      modelo (que calcula fuerza de CUERPO COMPLETO, no por pierna).
%   4) RMSE, RMSEnorm (SD = variabilidad entre TODOS los pasos reales
%      agrupados en cada punto de %ciclo, mismo principio de "poblacion
%      agrupada" que el resto del proyecto) y r, por paso.
%
% SALIDA
%   T: tabla, una fila por PASO real comparado (sub_id, placa, r, RMSE_pctBW, RMSEnorm)
%   D: struct con las curvas (para graficar aparte si se quiere)
% ==========================================================================

if nargin < 1 || isempty(ids)
    ids = [1,4,13,19,22,25,28,31,37,40,43,46,49];
end
if nargin < 2 || isempty(candidato), candidato = 'Koopman'; end

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta);
dir_kuopio = fullfile(carpeta, 'RODILLA', 'Kuopio');
addpath(dir_kuopio);

% --- Paso 1: acumular TODAS las curvas reales validas de TODOS los
% sujetos primero, para poder calcular la SD agrupada entre pasos (para
% RMSEnorm) antes de comparar paso a paso. ---
pct = 0:100;
Fz_real_todos = []; suj_todos = []; placa_todos_all = [];
info_suj = struct();
for sid = ids
    try
        R = Extraer_GRF_Kuopio_Core(sid);
    catch ME
        fprintf('sujeto %d: fallo extraccion de fuerza (%s)\n', sid, ME.message);
        continue
    end
    if R.n_pasos_validos == 0, continue; end
    Fz_real_todos = [Fz_real_todos; R.Fz_pctBW_todos]; %#ok<AGROW>
    suj_todos = [suj_todos; repmat(sid, R.n_pasos_validos,1)]; %#ok<AGROW>
    placa_todos_all = [placa_todos_all, R.placa_todos]; %#ok<AGROW>
    info_suj.(sprintf('s%d',sid)) = R;
end
n_pasos = size(Fz_real_todos,1);
fprintf('Total pasos reales validos (todos los sujetos): %d\n', n_pasos);

sd_pct = std(Fz_real_todos, 0, 1, 'omitnan');   % SD entre pasos, por punto de %ciclo
sd_pct(sd_pct < 1) = 1;   % piso minimo (evitar division por ~0 en tramos con pocos pasos)

% --- Paso 2: prediccion del modelo, UNA vez por sujeto ---
pred_por_sujeto = struct();
sujetos_unicos = unique(suj_todos)';
for sid = sujetos_unicos
    S = Cargar_Kuopio2024_Core(sid);
    antro = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1), ...
        'velocidad_ms', S.speed_ms, 'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000);
    gr = GRF_Newton_ApoyoSimple_Core(antro, candidato);
    pred_por_sujeto.(sprintf('s%d',sid)) = gr;
end

% --- Paso 3: comparar cada paso real contra la prediccion de SU sujeto,
% en la ventana donde el MODELO es confiable ---
filas = {};
D = struct('pct', pct, 'real', [], 'pred', [], 'sub_id', [], 'placa', []);
for i = 1:n_pasos
    sid = suj_todos(i);
    gr = pred_por_sujeto.(sprintf('s%d',sid));
    % ACTUALIZADO 28-ago-2026: usar la Fz de la pierna TRACKEADA (Zhao
    % et al. 2026 Ec.9, reparto de doble apoyo) en vez de la Fz de AMBOS
    % pies restringida a apoyo simple - extiende la ventana comparable de
    % ~20% del ciclo a ~55% (ver GRF_Newton_ApoyoSimple_Core.m).
    mask_modelo = gr.mask_confiable_trackeada;
    pred_pctbw = interp1(gr.pct_ciclo, gr.GRF_vertical_trackeada_pctBW, pct, 'pchip');
    mask_pct = interp1(gr.pct_ciclo, double(mask_modelo), pct, 'nearest') > 0;

    real_i = Fz_real_todos(i,:);
    ok = mask_pct & ~isnan(real_i);
    if sum(ok) < 5
        continue   % sin suficiente superposicion, descartar este paso
    end

    err = pred_pctbw(ok) - real_i(ok);
    RMSE = sqrt(mean(err.^2));
    RMSEnorm = sqrt(mean((err./sd_pct(ok)).^2));
    r = corr_manual_local(pred_pctbw(ok), real_i(ok));

    filas(end+1,:) = {sid, placa_todos_all(i), sum(ok), r, RMSE, RMSEnorm}; %#ok<AGROW>
    D.real(end+1,:) = real_i; D.pred(end+1,:) = pred_pctbw; %#ok<AGROW>
    D.sub_id(end+1) = sid; D.placa(end+1) = placa_todos_all(i); %#ok<AGROW>
end

T = cell2table(filas, 'VariableNames', {'sub_id','placa','n_pts','r','RMSE_pctBW','RMSEnorm'});
fprintf('\n%d pasos con suficiente superposicion con la ventana confiable del modelo\n', height(T));
disp(T);
fprintf('\nRESUMEN: r medio=%.3f (SD %.3f), RMSE medio=%.1f%%BW (SD %.1f), RMSEnorm medio=%.2f (SD %.2f)\n', ...
    mean(T.r), std(T.r), mean(T.RMSE_pctBW), std(T.RMSE_pctBW), mean(T.RMSEnorm), std(T.RMSEnorm));

end

function c = corr_manual_local(a,b)
a=a(:); b=b(:);
c = sum((a-mean(a)).*(b-mean(b))) / sqrt(sum((a-mean(a)).^2)*sum((b-mean(b)).^2));
end
