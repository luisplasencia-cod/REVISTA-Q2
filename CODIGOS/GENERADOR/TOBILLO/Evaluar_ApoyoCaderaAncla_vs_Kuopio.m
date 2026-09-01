function [T, T_base] = Evaluar_ApoyoCaderaAncla_vs_Kuopio()
% EVALUAR_APOYOCADERAANCLA_VS_KUOPIO  30-ago-2026: prueba la propuesta del
%                   usuario (revision del informe) - anclar el APOYO en la
%                   CADERA (avanza a velocidad conocida, geometria hacia
%                   abajo) en vez de anclar en el TOBILLO (fijo + residuo
%                   empirico de rockers, Evaluar_vs_Kuopio_Tobillo_Fases.m).
%
% MOTIVACION (medida, no solo argumentada): sobre los mismos 13 sujetos de
% Kuopio, la cadera real se desvia en promedio 3.82cm (max 6.61cm) de una
% recta a velocidad constante durante el apoyo: el tobillo real se desvia
% en promedio 8.33cm (max 13.04cm) de estar fijo en (0,0). La idealizacion
% de "cadera a v constante" es ~2x mas fiel que "tobillo fijo".
%
% LO QUE NO CAMBIA: la calibracion LOSO de angulos (muslo/tibia, Paso 1b
% de Evaluar_vs_Kuopio_Tobillo_Fases.m) - se reutiliza identica, porque
% corrige un defecto de Koopman (subestima la excursion angular ~20-23%)
% que no tiene relacion con donde se ancla la cadena.
%
% LO QUE CAMBIA: en vez de Cadena_Completa_Core.m (tobillo pivote fijo en
% apoyo), se reconstruye manualmente cadera->rodilla->tobillo con la
% cadera avanzando a la velocidad REAL medida (S.speed_ms), igual que ya
% hace el balanceo - misma formula, aplicada tambien al apoyo.
%
% SALIDA
%   T       metricas SIN residuo (geometria pura desde la cadera)
%   T_base  metricas del modelo YA vigente (tobillo fijo + residuo), para
%           comparar lado a lado sin tener que correr el otro archivo
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
dir_generador = fullfile(carpeta, '..');
dir_kuopio = fullfile(carpeta, '..', 'RODILLA', 'Kuopio');
addpath(dir_generador);
addpath(dir_kuopio);

Tmeta = readtable(fullfile(dir_kuopio, 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id;
n = numel(ids);
npts = 101;
pct = 0:100;

Sarr = cell(n,1); Antro = cell(n,1); Tempo = cell(n,1);
Thm_s = cell(n,1); Tht_s = cell(n,1); pct_nat_arr = cell(n,1);
Thm_koop = nan(n,101); Tht_koop = nan(n,101);
Thm_real = nan(n,101); Tht_real = nan(n,101);
pct_corte_arr = nan(n,1);
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
        [th_m, th_t, tempo] = Obtener_Angulos_Candidato('Koopman', antro, tempo, npts);
        tempo.tiempo_ciclo_s = S.T_ciclo_s;
        tempo.tiempo_apoyo_s = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
        tempo.tiempo_balanceo_s = (1-tempo.frac_apoyo) * tempo.tiempo_ciclo_s;

        pct_corte = tempo.frac_apoyo*100;
        pct_ap  = linspace(0, pct_corte, npts);
        pct_bal = linspace(pct_corte, 100, npts);
        pct_nat = [pct_ap, pct_bal(2:end)];

        Thm_koop(i,:) = interp1(pct_nat, rad2deg([th_m.apoyo th_m.balanceo(2:end)]), pct, 'pchip');
        Tht_koop(i,:) = interp1(pct_nat, rad2deg([th_t.apoyo th_t.balanceo(2:end)]), pct, 'pchip');
        Thm_real(i,:) = rad2deg(atan2(-S.dx_muslo_cm, S.dy_muslo_cm));
        Tht_real(i,:) = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));

        Sarr{i}=S; Antro{i}=antro; Tempo{i}=tempo;
        Thm_s{i}=th_m; Tht_s{i}=th_t; pct_nat_arr{i}=pct_nat;
        pct_corte_arr(i) = pct_corte;
        ok(i) = true;
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
    end
end
idx_ok = find(ok);

% --- Calibracion AFIN LOSO de los 2 angulos (identica a Evaluar_vs_Kuopio_Tobillo_Fases.m) ---
gan_muslo = nan(n,1); off_muslo = nan(n,1);
gan_tibia = nan(n,1); off_tibia = nan(n,1);
Th_m_cal = cell(n,1); Th_t_cal = cell(n,1);

for k = 1:numel(idx_ok)
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
    pm = polyfit(reshape(Thm_koop(otros,:),1,[]), reshape(Thm_real(otros,:),1,[]), 1);
    pt = polyfit(reshape(Tht_koop(otros,:),1,[]), reshape(Tht_real(otros,:),1,[]), 1);
    gan_muslo(i)=pm(1); off_muslo(i)=pm(2);
    gan_tibia(i)=pt(1); off_tibia(i)=pt(2);

    th_m = Thm_s{i}; th_t = Tht_s{i};
    th_m.apoyo    = deg2rad(pm(2)) + pm(1)*th_m.apoyo;
    th_t.apoyo    = deg2rad(pt(2)) + pt(1)*th_t.apoyo;
    Th_m_cal{i} = th_m; Th_t_cal{i} = th_t;
end

% --- Geometria: CADERA ancla, avanza a velocidad REAL medida ---
X_real_tob = nan(n,101); Y_real_tob = nan(n,101);
X_pred_tob = nan(n,101); Y_pred_tob = nan(n,101);
X_real_rod = nan(n,101); Y_real_rod = nan(n,101);
X_pred_rod = nan(n,101); Y_pred_rod = nan(n,101);

for k = 1:numel(idx_ok)
    i = idx_ok(k); S = Sarr{i}; antro = Antro{i};
    % th_m.apoyo/th_t.apoyo ya son arreglos de npts=101 puntos que cubren
    % SOLO el tramo de apoyo (0 a pct_corte%, en su propio "% natural") -
    % NO son un subconjunto de una malla combinada 0-100 (bug corregido
    % 30-ago-2026: antes se recortaba con pc~=61, dejando solo el primer
    % 60% del propio tramo de apoyo, es decir ~36% del ciclo real, y se
    % emparejaba con un t_ap que sí cubria el apoyo completo - desajuste
    % que disparaba RMSE de decenas de cm).
    th_m_ap = Th_m_cal{i}.apoyo; th_t_ap = Th_t_cal{i}.apoyo;
    pct_corte = pct_corte_arr(i);
    pc = round(pct_corte) + 1;   % tamano del tramo de apoyo en la malla ABSOLUTA 0-100

    L_m = antro.long_muslo_m * 100; L_t = antro.long_tibia_m * 100;
    t_ap = linspace(0, Tempo{i}.tiempo_apoyo_s, npts);   % 101 puntos, cubre TODO el apoyo
    cad_x_ap = S.speed_ms * 100 * t_ap;   % CADERA avanza a v REAL medida (cm)
    cad_y_ap = zeros(1, npts);            % altura de cadera constante (misma simplificacion que balanceo)

    rod_x_ap = cad_x_ap + L_m*sin(th_m_ap);
    rod_y_ap = cad_y_ap - L_m*cos(th_m_ap);
    tob_x_ap = rod_x_ap + L_t*sin(th_t_ap);
    tob_y_ap = rod_y_ap - L_t*cos(th_t_ap);

    % NORMALIZAR a (0,0) en el primer punto (bug corregido 30-ago-2026):
    % igual que TODO el resto del pipeline (normalizeDisp, S.x_horiz_cm/
    % S.y_vert_cm de Kuopio son DESPLAZAMIENTO desde el inicio del ciclo,
    % no posicion absoluta) - sin esto, rod_y_ap salia en el orden de
    % -33 a -38cm (la distancia geometrica cadera-rodilla, no un
    % desplazamiento) en vez de partir de 0 como el dato real.
    rod_x_ap = rod_x_ap - rod_x_ap(1);  rod_y_ap = rod_y_ap - rod_y_ap(1);
    tob_x_ap = tob_x_ap - tob_x_ap(1);  tob_y_ap = tob_y_ap - tob_y_ap(1);

    % reescalar del "% natural del apoyo" (0-100 de SU propio tramo) a la
    % malla ABSOLUTA 0-100 del ciclo completo, solo en el tramo 1:pc -
    % misma logica que pct_nat_arr en Evaluar_vs_Kuopio_Tobillo_Fases.m
    pct_natural_apoyo = linspace(0, pct_corte, npts);
    pct_absoluto_apoyo = pct(1:pc);
    tob_x_full = nan(1,101); tob_y_full = nan(1,101);
    rod_x_full = nan(1,101); rod_y_full = nan(1,101);
    tob_x_full(1:pc) = interp1(pct_natural_apoyo, tob_x_ap, pct_absoluto_apoyo, 'pchip');
    tob_y_full(1:pc) = interp1(pct_natural_apoyo, tob_y_ap, pct_absoluto_apoyo, 'pchip');
    rod_x_full(1:pc) = interp1(pct_natural_apoyo, rod_x_ap, pct_absoluto_apoyo, 'pchip');
    rod_y_full(1:pc) = interp1(pct_natural_apoyo, rod_y_ap, pct_absoluto_apoyo, 'pchip');

    X_real_tob(i,:) = S.x_horiz_tobillo_cm; Y_real_tob(i,:) = S.y_vert_tobillo_cm;
    X_pred_tob(i,:) = tob_x_full; Y_pred_tob(i,:) = tob_y_full;
    X_real_rod(i,:) = S.x_horiz_cm; Y_real_rod(i,:) = S.y_vert_cm;
    X_pred_rod(i,:) = rod_x_full; Y_pred_rod(i,:) = rod_y_full;
end

% --- Metricas, SOLO tramo de apoyo (0:pct_corte), igual criterio que el resto del proyecto ---
sub_id = zeros(n,1);
r_x_tob=nan(n,1); rmse_x_tob=nan(n,1); r_y_tob=nan(n,1); rmse_y_tob=nan(n,1);
r_x_rod=nan(n,1); rmse_x_rod=nan(n,1); r_y_rod=nan(n,1); rmse_y_rod=nan(n,1);

for k = 1:numel(idx_ok)
    i = idx_ok(k); pc = round(pct_corte_arr(i)) + 1;
    idxA = 1:pc;
    r_x_tob(i)=corr(X_real_tob(i,idxA)', X_pred_tob(i,idxA)');
    rmse_x_tob(i)=sqrt(mean((X_real_tob(i,idxA)-X_pred_tob(i,idxA)).^2));
    r_y_tob(i)=corr(Y_real_tob(i,idxA)', Y_pred_tob(i,idxA)');
    rmse_y_tob(i)=sqrt(mean((Y_real_tob(i,idxA)-Y_pred_tob(i,idxA)).^2));
    r_x_rod(i)=corr(X_real_rod(i,idxA)', X_pred_rod(i,idxA)');
    rmse_x_rod(i)=sqrt(mean((X_real_rod(i,idxA)-X_pred_rod(i,idxA)).^2));
    r_y_rod(i)=corr(Y_real_rod(i,idxA)', Y_pred_rod(i,idxA)');
    rmse_y_rod(i)=sqrt(mean((Y_real_rod(i,idxA)-Y_pred_rod(i,idxA)).^2));
    sub_id(i)=ids(i);
end
ok2 = false(n,1); ok2(idx_ok)=true;

T = table(sub_id(ok2), r_x_tob(ok2), rmse_x_tob(ok2), r_y_tob(ok2), rmse_y_tob(ok2), ...
    r_x_rod(ok2), rmse_x_rod(ok2), r_y_rod(ok2), rmse_y_rod(ok2), ...
    'VariableNames', {'sub_id','r_x_tob','rmse_x_tob','r_y_tob','rmse_y_tob', ...
    'r_x_rod','rmse_x_rod','r_y_rod','rmse_y_rod'});

fprintf('\n=== APOYO con CADERA como ancla (geometria pura, SIN residuo de rockers), N=%d, solo tramo de apoyo ===\n', sum(ok2));
fprintf('TOBILLO -- X: r=%.3f, RMSE=%.2fcm | Y: r=%.3f, RMSE=%.2fcm\n', mean(T.r_x_tob), mean(T.rmse_x_tob), mean(T.r_y_tob), mean(T.rmse_y_tob));
fprintf('RODILLA -- X: r=%.3f, RMSE=%.2fcm | Y: r=%.3f, RMSE=%.2fcm\n', mean(T.r_x_rod), mean(T.rmse_x_rod), mean(T.r_y_rod), mean(T.rmse_y_rod));
fprintf('\n(referencia, MODELO VIGENTE tobillo-fijo+residuo, todo el tramo 0-100: X r=0.998 RMSE=2.90cm, Y r=0.985 RMSE=1.54cm -- Evaluar_vs_Kuopio_Tobillo_Fases.m)\n');

T_base = struct('nota', 'ver header de Evaluar_vs_Kuopio_Tobillo_Fases.m para las metricas del modelo vigente');

writetable(T, fullfile(carpeta, 'Evaluar_ApoyoCaderaAncla_vs_Kuopio_resultados.csv'));
fprintf('Tabla: %s\n', fullfile(carpeta, 'Evaluar_ApoyoCaderaAncla_vs_Kuopio_resultados.csv'));

end
