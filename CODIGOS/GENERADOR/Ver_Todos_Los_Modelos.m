function Ver_Todos_Los_Modelos(antro_in)
% VER_TODOS_LOS_MODELOS  Ventana unica pedida por el usuario 24-ago-2026:
%                   los 4 candidatos (Koopman/Zhao/Yun/Romero-Sorozabal),
%                   rodilla y tobillo, X e Y, y angulo tibial - usando la
%                   CADENA COMPLETA (Cadena_Completa_Core.m) para K/Z/Y en
%                   vez del pivote-de-tobillo-fijo, que corrige los 3
%                   artefactos que el usuario detecto (tobillo sin
%                   levantarse, rodilla "regresando"/bucle, Y sin
%                   correlacionar con el dato real).

if nargin < 1 || isempty(antro_in)
    antro_in = struct('talla_m', 1.71, 'masa_kg', 68, 'sexo', 'M');
end
antro = Estimar_Antropometria_Core(antro_in);
tempo0 = Temporizacion_Core(antro, 'Koopman');
n = 101;

cands = {'Koopman','Zhao','Yun'};
col = struct('Koopman',[0.85 0.33 0.10], 'Zhao',[0.47 0.67 0.19], ...
             'Yun',[0.30 0.55 0.75], 'RomeroSorozabal',[0.60 0.20 0.60]);

R = struct();
for i = 1:numel(cands)
    c = cands{i};
    [th_m, th_t, tempo_c] = Obtener_Angulos_Candidato(c, antro, tempo0, n);
    cad = Cadena_Completa_Core(th_m, th_t, antro.long_muslo_m, antro.long_tibia_m, tempo_c, n);
    pct_ap  = linspace(0, tempo_c.frac_apoyo*100, n);
    pct_bal = linspace(tempo_c.frac_apoyo*100, 100, n);
    R.(c).pct    = [pct_ap, pct_bal(2:end)];
    R.(c).rod_x  = [cad.apoyo.rodilla_x_cm,  cad.balanceo.rodilla_x_cm(2:end)];
    R.(c).rod_y  = [cad.apoyo.rodilla_y_cm,  cad.balanceo.rodilla_y_cm(2:end)];
    R.(c).tob_x  = [cad.apoyo.tobillo_x_cm,  cad.balanceo.tobillo_x_cm(2:end)];
    R.(c).tob_y  = [cad.apoyo.tobillo_y_cm,  cad.balanceo.tobillo_y_cm(2:end)];
    R.(c).ang    = rad2deg([th_t.apoyo, th_t.balanceo(2:end)]);
    R.(c).frac_apoyo = tempo_c.frac_apoyo;
end

% Romero-Sorozabal: nativo (rodilla y tobillo reales relativos a pelvis) -
% Z tiene la anomalia conocida, se muestra igual con caveat.
v_kph = tempo0.velocidad_ms*3.6;
RS = Romero_Sorozabal2024_Core(v_kph, antro.talla_m, struct('nMuestras', 2*n-1));
R.RomeroSorozabal.pct   = RS.rodilla.pct_ciclo;
R.RomeroSorozabal.rod_x = RS.rodilla.x_m*100;
R.RomeroSorozabal.rod_y = RS.rodilla.z_abajo_pelvis_m*100;
R.RomeroSorozabal.tob_x = RS.tobillo.x_m*100;
R.RomeroSorozabal.tob_y = RS.tobillo.z_abajo_pelvis_m*100;
dx = RS.tobillo.x_m - RS.rodilla.x_m; dz = RS.tobillo.z_abajo_pelvis_m - RS.rodilla.z_abajo_pelvis_m;
R.RomeroSorozabal.ang = rad2deg(atan2(dx,dz));

todos = {'Koopman','Zhao','Yun','RomeroSorozabal'};
nombres = {'Koopman','Zhao','Yun','Romero-Sorozabal'};

fig = figure('Name','Todos los modelos - ventana unica', 'Position',[50 30 1500 900], 'Color','w');

% --- Panel 1: vista sagital RODILLA ---
subplot(2,3,1); hold on; grid on; box on; axis equal;
for i=1:4, c=todos{i}; plot(R.(c).rod_x, R.(c).rod_y, '-', 'Color',col.(c), 'LineWidth',2); end
xlabel('X [cm]'); ylabel('Y [cm]'); title('Vista sagital - RODILLA');
legend(nombres, 'Location','best');

% --- Panel 2: vista sagital TOBILLO ---
subplot(2,3,2); hold on; grid on; box on; axis equal;
for i=1:4, c=todos{i}; plot(R.(c).tob_x, R.(c).tob_y, '-', 'Color',col.(c), 'LineWidth',2); end
xlabel('X [cm]'); ylabel('Y [cm]'); title('Vista sagital - TOBILLO (ya se levanta en balanceo)');
legend(nombres, 'Location','best');

% --- Panel 3: angulo tibial ---
subplot(2,3,3); hold on; grid on; box on;
for i=1:4
    c=todos{i};
    if strcmp(c,'RomeroSorozabal')
        plot(R.(c).pct, R.(c).ang, ':', 'Color',col.(c), 'LineWidth',2);
    else
        plot(R.(c).pct, R.(c).ang, '-', 'Color',col.(c), 'LineWidth',2);
        xline(R.(c).frac_apoyo*100, ':', 'Color',[0.7 0.7 0.7], 'HandleVisibility','off');
    end
end
yline(0,':k','HandleVisibility','off');
xlabel('% ciclo'); ylabel('\theta_{tibia} [deg] (0=vertical)');
title('Angulo tibial (Romero-Sorozabal punteado: usa su Z con anomalia)');
legend(nombres, 'Location','best');

% --- Panel 4: X rodilla vs %ciclo ---
subplot(2,3,4); hold on; grid on; box on;
for i=1:4, c=todos{i}; plot(R.(c).pct, R.(c).rod_x, '-', 'Color',col.(c), 'LineWidth',2); end
xlabel('% ciclo'); ylabel('X rodilla [cm]'); title('X - RODILLA');
legend(nombres, 'Location','best');

% --- Panel 5: Y tobillo vs %ciclo ---
subplot(2,3,5); hold on; grid on; box on;
for i=1:4, c=todos{i}; plot(R.(c).pct, R.(c).tob_y, '-', 'Color',col.(c), 'LineWidth',2); end
xlabel('% ciclo'); ylabel('Y tobillo [cm]'); title('Y (altura) - TOBILLO');
legend(nombres, 'Location','best');

% --- Panel 6: Y rodilla vs %ciclo ---
subplot(2,3,6); hold on; grid on; box on;
for i=1:4, c=todos{i}; plot(R.(c).pct, R.(c).rod_y, '-', 'Color',col.(c), 'LineWidth',2); end
xlabel('% ciclo'); ylabel('Y rodilla [cm]'); title('Y (altura) - RODILLA');
legend(nombres, 'Location','best');

sgtitle(sprintf('Cadena completa (cadera-muslo-rodilla-tibia-tobillo) -- talla=%.2fm, v=%.2fm/s', antro.talla_m, tempo0.velocidad_ms), 'FontWeight','bold');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Ver_Todos_Los_Modelos_figura.png');
try
    exportgraphics(fig, out_png, 'Resolution', 150);
    fprintf('Figura guardada en: %s\n', out_png);
catch ME
    fprintf('  [aviso] no se pudo exportar PNG: %s\n', ME.message);
end

end
