function Diag_Oraculo_GRF()
% DIAG_ORACULO_GRF  28-ago-2026: diagnostico para decidir si el enfoque
% actual (Newton sobre CoM aproximado, geometria de Cadena_Completa_Core)
% es viable con mejor ajuste, o si hace falta algo mas riguroso
% (Simscape Multibody / OpenSim) - pedido del usuario tras ver que la
% correlacion poblacional (residuo promedio) sigue siendo modesta (r~0.14).
%
% METODO "ORACULO": en vez del residuo de rockers PROMEDIO (poblacional),
% se usa el desplazamiento REAL medido de CADA sujeto (su propio tobillo,
% Cargar_Kuopio2024_Core.m) - la mejor informacion posible sobre su
% cinematica de tobillo. Si con esto la correlacion sigue siendo mala,
% el problema NO es el promedio poblacional (ya no hay margen para
% mejorarlo con mas datos de posicion) - apunta a algo estructural
% (masa segmentaria, aproximacion de HAT=cadera, modelo de Newton mismo).
% Si mejora mucho, confirma que el enfoque es valido y solo falta mejor
% ajuste por sujeto (ej. LOSO en vez de pooled, o mas sujetos).
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta); addpath(fullfile(carpeta,'RODILLA','Kuopio'));

ids = [1,4,13,19,22,25,28,31,37,40,43,46,49];
resultados = {};
for sid = ids
    try
        S = Cargar_Kuopio2024_Core(sid);
        R = Extraer_GRF_Kuopio_Core(sid);
    catch
        continue
    end
    if R.n_pasos_validos == 0, continue; end

    antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1), ...
        'velocidad_ms', S.speed_ms, 'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000);
    antro = Estimar_Antropometria_Core(antro_in);
    masaSeg = MasaSegmentaria_DeLeva1996_Core(struct('masa_kg',antro.masa_kg,'sexo',antro.sexo));
    tempo = Temporizacion_Core(antro, 'Koopman');
    opts_cal = struct('calibrar_koopman', true);
    n=101; N=201; G=9.80665;
    [theta_apoyo, theta_balanceo, tempo, muslo_full, ~] = Obtener_Theta_Tibia_Candidato('Koopman', antro, tempo, n, opts_cal);
    % usar el T_ciclo y frac_apoyo REALES del sujeto en vez del de Koopman (oraculo: mejor info posible)
    tempo.tiempo_ciclo_s = S.T_ciclo_s;
    pct_ciclo_completo = linspace(0,100,numel(theta_apoyo));
    pct_corte = tempo.frac_apoyo*100;
    pct_ap = linspace(0,pct_corte,n); pct_bal = linspace(pct_corte,100,n);
    theta_ap_rad = interp1(pct_ciclo_completo,theta_apoyo,pct_ap,'pchip');
    theta_bal_rad = interp1(pct_ciclo_completo,theta_balanceo,pct_bal,'pchip');
    theta_muslo_ap_rad = interp1(pct_ciclo_completo,muslo_full,pct_ap,'pchip');
    theta_muslo_bal_rad = interp1(pct_ciclo_completo,muslo_full,pct_bal,'pchip');
    tempo.tiempo_apoyo_s = tempo.frac_apoyo*tempo.tiempo_ciclo_s;
    tempo.tiempo_balanceo_s = (1-tempo.frac_apoyo)*tempo.tiempo_ciclo_s;
    theta_muslo_struct = struct('apoyo',theta_muslo_ap_rad,'balanceo',theta_muslo_bal_rad);
    theta_tibia_struct = struct('apoyo',theta_ap_rad,'balanceo',theta_bal_rad);
    cadena = Cadena_Completa_Core(theta_muslo_struct, theta_tibia_struct, antro.long_muslo_m, antro.long_tibia_m, tempo, n);

    % --- ORACULO: residuo = desplazamiento REAL del tobillo DE ESTE SUJETO ---
    resid_x_ap = interp1(0:100, S.x_horiz_tobillo_cm, pct_ap, 'pchip');
    resid_y_ap = interp1(0:100, S.y_vert_tobillo_cm, pct_ap, 'pchip');
    cadena.apoyo.cadera_x_cm  = cadena.apoyo.cadera_x_cm  + resid_x_ap;
    cadena.apoyo.rodilla_x_cm = cadena.apoyo.rodilla_x_cm + resid_x_ap;
    cadena.apoyo.tobillo_x_cm = cadena.apoyo.tobillo_x_cm + resid_x_ap;
    cadena.apoyo.cadera_y_cm  = cadena.apoyo.cadera_y_cm  + resid_y_ap;
    cadena.apoyo.rodilla_y_cm = cadena.apoyo.rodilla_y_cm + resid_y_ap;
    cadena.apoyo.tobillo_y_cm = cadena.apoyo.tobillo_y_cm + resid_y_ap;
    cadena.balanceo.cadera_x_cm  = cadena.balanceo.cadera_x_cm  + resid_x_ap(end);
    cadena.balanceo.rodilla_x_cm = cadena.balanceo.rodilla_x_cm + resid_x_ap(end);
    cadena.balanceo.tobillo_x_cm = cadena.balanceo.tobillo_x_cm + resid_x_ap(end);
    cadena.balanceo.cadera_y_cm  = cadena.balanceo.cadera_y_cm  + resid_y_ap(end);
    cadena.balanceo.rodilla_y_cm = cadena.balanceo.rodilla_y_cm + resid_y_ap(end);
    cadena.balanceo.tobillo_y_cm = cadena.balanceo.tobillo_y_cm + resid_y_ap(end);

    t_ap=linspace(0,tempo.tiempo_apoyo_s,n); t_bal=linspace(0,tempo.tiempo_balanceo_s,n)+tempo.tiempo_apoyo_s;
    t_nu=[t_ap,t_bal(2:end)];
    cad_x_nu=[cadena.apoyo.cadera_x_cm,cadena.balanceo.cadera_x_cm(2:end)];
    cad_y_nu=[cadena.apoyo.cadera_y_cm,cadena.balanceo.cadera_y_cm(2:end)];
    th_m_nu=[theta_muslo_ap_rad,theta_muslo_bal_rad(2:end)];
    th_t_nu=[theta_ap_rad,theta_bal_rad(2:end)];
    T=tempo.tiempo_ciclo_s; t_u=linspace(0,T,N);
    cad_x_u=interp1(t_nu,cad_x_nu,t_u,'pchip'); cad_y_u=interp1(t_nu,cad_y_nu,t_u,'pchip');
    th_m_u=interp1(t_nu,th_m_nu,t_u,'pchip'); th_t_u=interp1(t_nu,th_t_nu,t_u,'pchip');
    t_ext=[t_u(1:end-1)-T,t_u,t_u(2:end)+T];
    thm_ext=[th_m_u(1:end-1),th_m_u,th_m_u(2:end)]; tht_ext=[th_t_u(1:end-1),th_t_u,th_t_u(2:end)];
    th_m_c=interp1(t_ext,thm_ext,t_u+T/2,'pchip'); th_t_c=interp1(t_ext,tht_ext,t_u+T/2,'pchip');
    Lm=antro.long_muslo_m*100; Lt=antro.long_tibia_m*100;
    rod_x_s=cad_x_u+Lm*sin(th_m_u); rod_y_s=cad_y_u-Lm*cos(th_m_u);
    tob_x_s=rod_x_s+Lt*sin(th_t_u); tob_y_s=rod_y_s-Lt*cos(th_t_u);
    rod_x_c=cad_x_u+Lm*sin(th_m_c); rod_y_c=cad_y_u-Lm*cos(th_m_c);
    tob_x_c=rod_x_c+Lt*sin(th_t_c); tob_y_c=rod_y_c-Lt*cos(th_t_c);
    fc_m=masaSeg.muslo_com_frac; fc_p=masaSeg.pierna_com_frac;
    cm_mu_s_x=cad_x_u+fc_m*(rod_x_s-cad_x_u); cm_mu_s_y=cad_y_u+fc_m*(rod_y_s-cad_y_u);
    cm_pi_s_x=rod_x_s+fc_p*(tob_x_s-rod_x_s); cm_pi_s_y=rod_y_s+fc_p*(tob_y_s-rod_y_s);
    cm_mu_c_x=cad_x_u+fc_m*(rod_x_c-cad_x_u); cm_mu_c_y=cad_y_u+fc_m*(rod_y_c-cad_y_u);
    cm_pi_c_x=rod_x_c+fc_p*(tob_x_c-rod_x_c); cm_pi_c_y=rod_y_c+fc_p*(tob_y_c-rod_y_c);
    mH=masaSeg.hat_masa_frac; mMu=masaSeg.muslo_masa_frac; mPi=masaSeg.pierna_masa_frac; mPie=masaSeg.pie_masa_frac;
    suma=mH+2*mMu+2*mPi+2*mPie;
    com_x=(mH*cad_x_u+mMu*(cm_mu_s_x+cm_mu_c_x)+mPi*(cm_pi_s_x+cm_pi_c_x)+mPie*(tob_x_s+tob_x_c))/suma;
    com_y=(mH*cad_y_u+mMu*(cm_mu_s_y+cm_mu_c_y)+mPi*(cm_pi_s_y+cm_pi_c_y)+mPie*(tob_y_s+tob_y_c))/suma;
    com_x_m=com_x/100; com_y_m=com_y/100;
    dt=t_u(2)-t_u(1); deriva=com_x_m(end)-com_x_m(1);
    x_ext=[com_x_m(1:end-1)-deriva,com_x_m,com_x_m(2:end)+deriva];
    y_ext=[com_y_m(1:end-1),com_y_m,com_y_m(2:end)];
    framelen=2*floor(N/10)+1;
    x_sm=sgolayfilt(x_ext,3,framelen); y_sm=sgolayfilt(y_ext,3,framelen);
    ax_ext=gradient(gradient(x_sm,dt),dt); ay_ext=gradient(gradient(y_sm,dt),dt);
    ax_u=ax_ext(N:2*N-1); ay_u=ay_ext(N:2*N-1);
    M_total=antro.masa_kg; BW_N=M_total*G;
    GRF_v = M_total*(G+ay_u);
    pct_pred = 100*t_u/T;
    pred_pctbw = 100*GRF_v/BW_N;

    % --- comparar contra el paso real, en la ventana donde HAY dato real
    % (mask_activa) - aqui no hace falta mask_fisica del modelo, se usa
    % directo la ventana real medida ---
    real_todos = R.Fz_pctBW_todos;
    for ip = 1:R.n_pasos_validos
        real_i = real_todos(ip,:);
        pred_en_real = interp1(pct_pred, pred_pctbw, R.pct_ciclo, 'pchip');
        ok = ~isnan(real_i) & R.pct_ciclo <= 55;   % evitar el extremo del despegue, ruidoso en ambos lados
        if sum(ok) < 10, continue; end
        r = corr(pred_en_real(ok)', real_i(ok)');
        RMSE = sqrt(mean((pred_en_real(ok)-real_i(ok)).^2));
        resultados(end+1,:) = {sid, ip, r, RMSE}; %#ok<AGROW>
    end
end

T2 = cell2table(resultados, 'VariableNames', {'sub_id','paso','r','RMSE_pctBW'});
disp(T2);
fprintf('\nORACULO (residuo real de CADA sujeto, no promedio): r medio=%.3f (SD %.3f), RMSE medio=%.1f%%BW (SD %.1f)\n', ...
    mean(T2.r,'omitnan'), std(T2.r,'omitnan'), mean(T2.RMSE_pctBW,'omitnan'), std(T2.RMSE_pctBW,'omitnan'));

end
