function DIAG_ladotrick_Tobillo()
% DIAG_LADOTRICK_TOBILLO  27-ago-2026: responde el pendiente abierto en
% CIERRE_TOBILLO.md #11: ¿el "truco de lado" que ayuda a Zhao/Yun contra
% Maastricht (RODILLA/CIERRE_RODILLA.md #1-ter) tambien ayuda para la
% POSICION del TOBILLO (cadena muslo+tibia) contra Kuopio 2024?
%
% SIMPLIFICACION DECLARADA (para responder rapido, sin correr Yun 4 veces
% mas): se calibra la posicion GEOMETRICA de Cadena_Completa_Core.m tras
% la calibracion afin LOSO de los 2 angulos (identico a los scripts
% _Zhao.m/_Yun.m ya cerrados) pero SIN el residuo empirico de rockers ni
% el cierre de ciclo/zancada (esas 2 correcciones son un post-proceso
% igual de chico para cualquier candidato, no cambian la pregunta de
% fondo: ¿el lado alternativo arregla o empeora la FORMA de la cadena?).
% Si esta version simplificada muestra una mejora clara, se justifica
% construir despues la version completa con rockers/cierre.
%
% Yun2014_Wrapper ya calcula R_ y L_ en una sola llamada por sujeto (no
% hace falta correr la regresion GP dos veces). No se modifica ningun
% archivo existente.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
carpeta = fileparts(mfilename('fullpath'));
dir_kuopio = fullfile(carpeta, '..', 'RODILLA', 'Kuopio');
addpath(dir_kuopio);

Tmeta = readtable(fullfile(dir_kuopio, 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id;
n = numel(ids);
npts = 101; pct = 0:100;

nombres = {'Zhao_izquierda_nativo','Zhao_derecha_alt','Yun_R_nativo','Yun_L_alt'};

Sarr = cell(n,1); Antro = cell(n,1); Tempo = cell(n,1);
% Por config: angulos en malla 0:100 (grados) y estructuras por-fase
ThM = cell(n,4); ThT = cell(n,4);       % structs .apoyo/.balanceo (rad)
Thm_cand = nan(n,101,4); Tht_cand = nan(n,101,4);
Thm_real = nan(n,101); Tht_real = nan(n,101);
pct_nat_arr = cell(n,1); pct_corte_arr = nan(n,1);
ok = false(n,1);

for i = 1:n
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, ...
            'sexo', S.sexo(1), 'velocidad_ms', S.speed_ms, ...
            'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000);
        antro = Estimar_Antropometria_Core(antro_in);
        tempo = Temporizacion_Core(antro, 'Zhao');  % misma regresion de tiempo que el pipeline nativo
        tempo.tiempo_ciclo_s = S.T_ciclo_s;
        tempo.tiempo_apoyo_s = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
        tempo.tiempo_balanceo_s = (1-tempo.frac_apoyo) * tempo.tiempo_ciclo_s;
        pct_corte = tempo.frac_apoyo*100;
        pct_ap  = linspace(0, pct_corte, npts);
        pct_bal = linspace(pct_corte, 100, npts);
        pct_nat = [pct_ap, pct_bal(2:end)];

        Zi = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/tempo.tiempo_ciclo_s, struct('lado','izquierda'));
        Zd = Zhao2026_Core(antro.long_muslo_m + antro.long_tibia_m, 1/tempo.tiempo_ciclo_s, struct('lado','derecha'));

        antro14 = antro; antro14.edad_anios = 25;
        p14 = [antro14.edad_anios, antro14.talla_m*100, antro14.masa_kg, double(upper(antro14.sexo(1))=='M'), ...
               antro14.long_muslo_m*100, antro14.long_tibia_m*100, ...
               32.8, 29.7, 25.5, 10, antro14.long_pie_m*100, 7.30, 7.10, 9.80];
        Y = Yun2014_Wrapper(p14);

        m_fulls = { Zi.phi_cadera_rad, Zd.phi_cadera_rad, ...
                    deg2rad(Y.R_hip_extension.mean), deg2rad(Y.L_hip_extension.mean) };
        t_fulls = { Zi.theta_tibia_rad, Zd.theta_tibia_rad, ...
                    Y.theta_tibia_via_tobillo_R_rad, Y.theta_tibia_via_tobillo_L_rad };

        for c = 1:4
            m_full = m_fulls{c}; t_full = t_fulls{c};
            pnat_c = linspace(0,100,numel(m_full));
            ThM{i,c} = struct('apoyo', interp1(pnat_c, m_full, pct_ap, 'pchip'), ...
                               'balanceo', interp1(pnat_c, m_full, pct_bal, 'pchip'));
            ThT{i,c} = struct('apoyo', interp1(pnat_c, t_full, pct_ap, 'pchip'), ...
                               'balanceo', interp1(pnat_c, t_full, pct_bal, 'pchip'));
            Thm_cand(i,:,c) = interp1(pct_nat, rad2deg([ThM{i,c}.apoyo ThM{i,c}.balanceo(2:end)]), pct, 'pchip');
            Tht_cand(i,:,c) = interp1(pct_nat, rad2deg([ThT{i,c}.apoyo ThT{i,c}.balanceo(2:end)]), pct, 'pchip');
        end

        Thm_real(i,:) = rad2deg(atan2(-S.dx_muslo_cm, S.dy_muslo_cm));
        Tht_real(i,:) = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));

        Sarr{i}=S; Antro{i}=antro; Tempo{i}=tempo;
        pct_nat_arr{i}=pct_nat; pct_corte_arr(i)=pct_corte;
        ok(i) = true;
        fprintf('Sujeto %d OK (%d/%d)\n', sid, i, n);
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
    end
end
idx_ok = find(ok);

fprintf('\n=== TRUCO DE LADO - TOBILLO (geometria calibrada, SIN rockers/cierre) vs Kuopio, N=%d ===\n', numel(idx_ok));
fprintf('%-24s %10s %10s %10s %10s\n', 'Config', 'r_x', 'RMSE_x', 'r_y', 'RMSE_y');

R = table();
for c = 1:4
    r_x = nan(n,1); rmse_x = nan(n,1); r_y = nan(n,1); rmse_y = nan(n,1);
    for k = 1:numel(idx_ok)
        i = idx_ok(k); otros = idx_ok(idx_ok ~= i); S = Sarr{i};

        pm = polyfit(reshape(Thm_cand(otros,:,c),1,[]), reshape(Thm_real(otros,:),1,[]), 1);
        pt = polyfit(reshape(Tht_cand(otros,:,c),1,[]), reshape(Tht_real(otros,:),1,[]), 1);

        th_m = ThM{i,c}; th_t = ThT{i,c};
        th_m.apoyo    = deg2rad(pm(2)) + pm(1)*th_m.apoyo;
        th_m.balanceo = deg2rad(pm(2)) + pm(1)*th_m.balanceo;
        th_t.apoyo    = deg2rad(pt(2)) + pt(1)*th_t.apoyo;
        th_t.balanceo = deg2rad(pt(2)) + pt(1)*th_t.balanceo;

        cc = Cadena_Completa_Core(th_m, th_t, Antro{i}.long_muslo_m, Antro{i}.long_tibia_m, Tempo{i}, npts);
        tob_x_nat = [cc.apoyo.tobillo_x_cm,  cc.balanceo.tobillo_x_cm(2:end)];
        tob_y_nat = [cc.apoyo.tobillo_y_cm,  cc.balanceo.tobillo_y_cm(2:end)];
        tob_x = interp1(pct_nat_arr{i}, tob_x_nat, pct, 'pchip');
        tob_y = interp1(pct_nat_arr{i}, tob_y_nat, pct, 'pchip');

        r_x(i) = corr(S.x_horiz_tobillo_cm(:), tob_x(:));
        rmse_x(i) = sqrt(mean((S.x_horiz_tobillo_cm(:)-tob_x(:)).^2));
        r_y(i) = corr(S.y_vert_tobillo_cm(:), tob_y(:));
        rmse_y(i) = sqrt(mean((S.y_vert_tobillo_cm(:)-tob_y(:)).^2));
    end
    fprintf('%-24s %10.3f %10.2f %10.3f %10.2f\n', nombres{c}, ...
        mean(r_x(idx_ok)), mean(rmse_x(idx_ok)), mean(r_y(idx_ok)), mean(rmse_y(idx_ok)));
    Rc = table(ids(idx_ok), repmat(string(nombres{c}),numel(idx_ok),1), r_x(idx_ok), rmse_x(idx_ok), r_y(idx_ok), rmse_y(idx_ok), ...
        'VariableNames', {'sub_id','config','r_x','rmse_x','r_y','rmse_y'});
    R = [R; Rc]; %#ok<AGROW>
end

writetable(R, fullfile(carpeta, 'DIAG_ladotrick_Tobillo_resultados.csv'));
fprintf('\nTabla: %s\n', fullfile(carpeta, 'DIAG_ladotrick_Tobillo_resultados.csv'));

end
