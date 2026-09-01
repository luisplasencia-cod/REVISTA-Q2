function T = Evaluar_ApoyoCaderaAncla_ConResiduo_vs_Kuopio()
% EVALUAR_APOYOCADERAANCLA_CONRESIDUO_VS_KUOPIO  30-ago-2026: comparacion
%                   JUSTA entre anclar en tobillo vs anclar en cadera -
%                   objecion correcta del usuario: Evaluar_ApoyoCaderaAncla_
%                   vs_Kuopio.m compara SIN residuo (geometria pura desde
%                   cadera) contra el modelo vigente que SI tiene residuo
%                   (Evaluar_vs_Kuopio_Tobillo_Fases.m) - no es apples-to-
%                   apples. Aqui se construye el MISMO tipo de residuo LOSO
%                   para el ancla de cadera (promedio del error real de los
%                   OTROS sujetos, nunca el propio) y se comparan las 4
%                   combinaciones: {tobillo,cadera} x {sin,con residuo}.
%
%   RESIDUO PARA CADA ANCLA (misma definicion, aplicada consistentemente):
%     residuo_i(t) = real_i(t) - geometria_i(t)     [error de CADA sujeto]
%     correccion para sujeto i = mean_{j~=i}( residuo_j(t) )   [LOSO]
%     prediccion final = geometria_i(t) + correccion
%
%   Para el tobillo-fijo, geometria_i(t)=(0,0) exacto, asi que el residuo
%   de cada sujeto ES su propia posicion real -> el promedio LOSO es
%   simplemente el promedio de las posiciones reales de los otros (lo que
%   ya hace Residuo_Rockers_Tobillo_Kuopio_Core.m). Para la cadera, la
%   geometria SI varia por sujeto (depende de su velocidad real), asi que
%   el residuo de cada sujeto no es su posicion real sino su ERROR -
%   la correccion no es la misma formula "de puro promedio" en los dos
%   casos, es la MISMA LOGICA aplicada correctamente a cada uno.
%
% SALIDA: tabla T con las 4 combinaciones, r y RMSE, tobillo y rodilla,
%   solo tramo de apoyo (0:pct_corte por sujeto), N=sujetos con CSV.
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
dir_generador = fullfile(carpeta, '..');
dir_kuopio = fullfile(carpeta, '..', 'RODILLA', 'Kuopio');
addpath(dir_generador); addpath(dir_kuopio);

Tmeta = readtable(fullfile(dir_kuopio, 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id; n = numel(ids); npts = 101; pct = 0:100;

Sarr = cell(n,1); Antro = cell(n,1); Tempo = cell(n,1);
Thm_s = cell(n,1); Tht_s = cell(n,1);
Thm_koop = nan(n,101); Tht_koop = nan(n,101);
Thm_real = nan(n,101); Tht_real = nan(n,101);
pct_corte_arr = nan(n,1); ok = false(n,1);

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

        pct_corte = tempo.frac_apoyo*100;
        pct_ap  = linspace(0, pct_corte, npts);
        pct_bal = linspace(pct_corte, 100, npts);
        pct_nat = [pct_ap, pct_bal(2:end)];
        Thm_koop(i,:) = interp1(pct_nat, rad2deg([th_m.apoyo th_m.balanceo(2:end)]), pct, 'pchip');
        Tht_koop(i,:) = interp1(pct_nat, rad2deg([th_t.apoyo th_t.balanceo(2:end)]), pct, 'pchip');
        Thm_real(i,:) = rad2deg(atan2(-S.dx_muslo_cm, S.dy_muslo_cm));
        Tht_real(i,:) = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));

        Sarr{i}=S; Antro{i}=antro; Tempo{i}=tempo;
        Thm_s{i}=th_m; Tht_s{i}=th_t; pct_corte_arr(i) = pct_corte;
        ok(i) = true;
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
    end
end
idx_ok = find(ok); n_ok = numel(idx_ok);

% --- calibracion LOSO de angulos, identica a los otros scripts ---
Th_m_cal = cell(n,1); Th_t_cal = cell(n,1);
for k = 1:n_ok
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
    pm = polyfit(reshape(Thm_koop(otros,:),1,[]), reshape(Thm_real(otros,:),1,[]), 1);
    pt = polyfit(reshape(Tht_koop(otros,:),1,[]), reshape(Tht_real(otros,:),1,[]), 1);
    th_m = Thm_s{i}; th_t = Tht_s{i};
    th_m.apoyo = deg2rad(pm(2)) + pm(1)*th_m.apoyo;
    th_t.apoyo = deg2rad(pt(2)) + pt(1)*th_t.apoyo;
    Th_m_cal{i} = th_m; Th_t_cal{i} = th_t;
end

% --- geometria CRUDA (sin residuo) para las DOS anclas, por sujeto ---
% tobillo-fijo: (0,0) exacto en TODO el apoyo (trivial, ni hace falta bucle)
% cadera-ancla: igual formula que Evaluar_ApoyoCaderaAncla_vs_Kuopio.m
Xt_real=nan(n,101); Yt_real=nan(n,101);   % real, tobillo
Xt_cadera_raw=nan(n,101); Yt_cadera_raw=nan(n,101);   % geometria cadera, sin residuo

for k = 1:n_ok
    i = idx_ok(k); S = Sarr{i}; antro = Antro{i};
    th_m_ap = Th_m_cal{i}.apoyo; th_t_ap = Th_t_cal{i}.apoyo;
    pct_corte = pct_corte_arr(i); pc = round(pct_corte)+1;

    L_m = antro.long_muslo_m*100; L_t = antro.long_tibia_m*100;
    t_ap = linspace(0, Tempo{i}.tiempo_apoyo_s, npts);
    cad_x_ap = S.speed_ms*100*t_ap; cad_y_ap = zeros(1,npts);
    rod_x_ap = cad_x_ap + L_m*sin(th_m_ap); rod_y_ap = cad_y_ap - L_m*cos(th_m_ap);
    tob_x_ap = rod_x_ap + L_t*sin(th_t_ap); tob_y_ap = rod_y_ap - L_t*cos(th_t_ap);
    tob_x_ap = tob_x_ap - tob_x_ap(1); tob_y_ap = tob_y_ap - tob_y_ap(1);

    pct_nat_ap = linspace(0, pct_corte, npts);
    Xt_cadera_raw(i,1:pc) = interp1(pct_nat_ap, tob_x_ap, pct(1:pc), 'pchip');
    Yt_cadera_raw(i,1:pc) = interp1(pct_nat_ap, tob_y_ap, pct(1:pc), 'pchip');

    Xt_real(i,:) = S.x_horiz_tobillo_cm; Yt_real(i,:) = S.y_vert_tobillo_cm;
end

% --- residuo LOSO para CADA ancla (definicion consistente: real - geometria) ---
Xt_tobillo_con=nan(n,101); Yt_tobillo_con=nan(n,101);   % tobillo-fijo + residuo (=modelo vigente)
Xt_cadera_con=nan(n,101);  Yt_cadera_con=nan(n,101);    % cadera-ancla + SU PROPIO residuo

for k = 1:n_ok
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
    pc = round(pct_corte_arr(i))+1;

    % tobillo-fijo: geometria=0 exacto -> residuo_j = real_j (para cada otro j)
    res_x_tob = mean(Xt_real(otros,1:pc),1); res_y_tob = mean(Yt_real(otros,1:pc),1);
    Xt_tobillo_con(i,1:pc) = 0 + res_x_tob;   Yt_tobillo_con(i,1:pc) = 0 + res_y_tob;

    % cadera-ancla: residuo_j = real_j - geometria_j (cada OTRO sujeto, con SU propia geometria)
    res_x_cad = mean(Xt_real(otros,1:pc) - Xt_cadera_raw(otros,1:pc), 1);
    res_y_cad = mean(Yt_real(otros,1:pc) - Yt_cadera_raw(otros,1:pc), 1);
    Xt_cadera_con(i,1:pc) = Xt_cadera_raw(i,1:pc) + res_x_cad;
    Yt_cadera_con(i,1:pc) = Yt_cadera_raw(i,1:pc) + res_y_cad;
end

% --- metricas, las 4 combinaciones ---
variantes = struct( ...
    'nombre', {'Tobillo fijo, SIN residuo', 'Tobillo fijo, CON residuo LOSO (=vigente)', ...
               'Cadera ancla, SIN residuo', 'Cadera ancla, CON residuo LOSO'}, ...
    'X', {zeros(n,101), Xt_tobillo_con, Xt_cadera_raw, Xt_cadera_con}, ...
    'Y', {zeros(n,101), Yt_tobillo_con, Yt_cadera_raw, Yt_cadera_con});

fprintf('\n=== Comparacion JUSTA: tobillo-fijo vs cadera-ancla, sin y con residuo LOSO propio (N=%d, tramo apoyo) ===\n', n_ok);
nombres = cell(4,1); r_x=nan(4,1); rmse_x=nan(4,1); r_y=nan(4,1); rmse_y=nan(4,1);
for v = 1:4
    rx=nan(n_ok,1); ex=nan(n_ok,1); ry=nan(n_ok,1); ey=nan(n_ok,1);
    for k = 1:n_ok
        i = idx_ok(k); pc = round(pct_corte_arr(i))+1; idxA = 1:pc;
        Xp = variantes(v).X(i,idxA); Yp = variantes(v).Y(i,idxA);
        Xr = Xt_real(i,idxA); Yr = Yt_real(i,idxA);
        if std(Xp) > 1e-9, rx(k) = corr(Xr', Xp'); end
        if std(Yp) > 1e-9, ry(k) = corr(Yr', Yp'); end
        ex(k) = sqrt(mean((Xr-Xp).^2)); ey(k) = sqrt(mean((Yr-Yp).^2));
    end
    nombres{v} = variantes(v).nombre;
    r_x(v) = mean(rx,'omitnan'); rmse_x(v) = mean(ex); r_y(v) = mean(ry,'omitnan'); rmse_y(v) = mean(ey);
    r_x_str = ternary_str(any(~isnan(rx)), sprintf('%.3f',r_x(v)), 'indefinido (pred. constante)');
    r_y_str = ternary_str(any(~isnan(ry)), sprintf('%.3f',r_y(v)), 'indefinido (pred. constante)');
    fprintf('%-42s X: r=%s RMSE=%5.2fcm | Y: r=%s RMSE=%5.2fcm\n', nombres{v}, r_x_str, rmse_x(v), r_y_str, rmse_y(v));
end

T = table(nombres, r_x, rmse_x, r_y, rmse_y, 'VariableNames', {'variante','r_x','rmse_x','r_y','rmse_y'});
writetable(T, fullfile(carpeta, 'Evaluar_ApoyoCaderaAncla_ConResiduo_vs_Kuopio_resultados.csv'));
fprintf('\nTabla: %s\n', fullfile(carpeta, 'Evaluar_ApoyoCaderaAncla_ConResiduo_vs_Kuopio_resultados.csv'));

% --- POR QUE la correccion de tobillo generaliza mejor que la de cadera:
% comparar cuanto varia ENTRE SUJETOS la cantidad que cada residuo LOSO
% promedia. Tobillo: promedia la posicion real misma. Cadera: promedia el
% ERROR (real-geometria). Si el tobillo tiene menos dispersion entre
% sujetos (relativa a su propio rango), un promedio poblacional lo
% predice mejor - eso explicaria por que su r sale tan alto pese a partir
% de una constante.
sd_tobillo_x = nan(1,101); sd_tobillo_y = nan(1,101);
sd_cadera_x  = nan(1,101); sd_cadera_y  = nan(1,101);
pc_min = min(round(pct_corte_arr(idx_ok))) + 1;   % tramo comun a todos
for t = 1:pc_min
    sd_tobillo_x(t) = std(Xt_real(idx_ok,t));
    sd_tobillo_y(t) = std(Yt_real(idx_ok,t));
    err_x = Xt_real(idx_ok,t) - Xt_cadera_raw(idx_ok,t);
    err_y = Yt_real(idx_ok,t) - Yt_cadera_raw(idx_ok,t);
    sd_cadera_x(t) = std(err_x);
    sd_cadera_y(t) = std(err_y);
end
fprintf('\n=== Por que el residuo del tobillo generaliza mejor (SD entre sujetos, tramo comun 0-%.0f%%) ===\n', pc_min-1);
fprintf('X - SD entre sujetos: tobillo (posicion real)=%.2fcm | cadera (error real-geometria)=%.2fcm\n', ...
    mean(sd_tobillo_x(1:pc_min)), mean(sd_cadera_x(1:pc_min)));
fprintf('Y - SD entre sujetos: tobillo (posicion real)=%.2fcm | cadera (error real-geometria)=%.2fcm\n', ...
    mean(sd_tobillo_y(1:pc_min)), mean(sd_cadera_y(1:pc_min)));
fprintf('(SD mas chica = el promedio LOSO de ese sujeto se parece mas a lo que cualquier OTRO sujeto necesita -> generaliza mejor)\n');

end

function s = ternary_str(cond, a, b)
if cond, s = a; else, s = b; end
end
