function T = Evaluar_vs_Ferber()
% EVALUAR_VS_FERBER  25-ago-2026: comparacion DECISIVA para la posicion de
%                   la RODILLA (horizontal + vertical) con antropometria
%                   REAL sujeto-a-sujeto - a diferencia de Maastricht
%                   (solo angulo, promedio de grupo de edad) y de Winter
%                   (posicion real, pero SIN antropometria documentada -
%                   no se puede "setear" en el modelo, pedido explicito
%                   del usuario 24-ago-2026).
%
%                   Fuente: Ferber, Brett, Fukuchi, Hettinga & Osis 2024
%                   (Scientific Data, DOI 10.1038/s41597-024-04011-7),
%                   Figshare+ 10.25452/figshare.plus.24255795.v1. Muestra
%                   estratificada de 40 sujetos SANOS (20M/20F, sin
%                   lesion, talla 150-195cm, peso 48-105kg), cada uno con
%                   su sexo/talla/peso real documentado en muestra_40.csv.
%
%                   Para cada sujeto: se predice la rodilla con Koopman
%                   2014 (ganador ya establecido, ver mejor_modelo_rodilla.md)
%                   usando SU antropometria real, y se compara contra su
%                   posicion de rodilla REAL reconstruida desde los
%                   marcadores crudos con el pipeline oficial de los
%                   autores (gait_kinematics.m + gait_steps.m, MIT
%                   license) - ver Ferber/Cargar_Ferber2024_Core.m.
%
%                   IMPORTANTE (hallazgo real, 25-ago-2026): el primer
%                   intento comparo la rodilla relativa a un TOBILLO FIJO
%                   (Cadena_Cinematica_Core.m, formula ya usada contra
%                   Control_Luis, que SI es valida ahi porque el CSV del
%                   simulador es relativo al tobillo por construccion) y
%                   dio r=-0.41 en los 40 sujetos A LA VEZ - senal de un
%                   problema de marco de referencia, no de signo ni del
%                   modelo: en el marco de LABORATORIO real (como Ferber,
%                   Winter, Camargo) el tobillo NO esta fijo durante el
%                   balanceo, se desplaza con toda la pierna. La
%                   comparacion correcta - MISMO principio ya usado y
%                   validado en Evaluar_vs_Winter.m - es la rodilla
%                   RELATIVA A LA CADERA, que cancela esa traslacion:
%                   sube r_x de -0.41 a ~0.97 en el sujeto de prueba.
%                   Formula (theta_muslo = angulo de cadera de Koopman,
%                   0=muslo vertical, MISMO signo +sin ya verificado en
%                   Evaluar_vs_Winter.m para X; signo de Y VERIFICADO
%                   empiricamente aqui, no asumido - ver diagnostico en
%                   docs/algoritmo/busqueda_modelos_antropometria_rodilla.md):
%                     dx = +L_muslo*sin(theta_muslo)
%                     dy = +L_muslo*(1-cos(theta_muslo))

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
addpath(fullfile(fileparts(mfilename('fullpath')), 'Ferber'));

carpeta = fileparts(mfilename('fullpath'));
Tmeta = readtable(fullfile(carpeta, 'Ferber', 'muestra_40.csv'));
n = height(Tmeta);

sub_id = zeros(n,1); sexo = strings(n,1); talla_cm = zeros(n,1); peso_kg = zeros(n,1);
n_ciclos = zeros(n,1); r_x = nan(n,1); rmse_x = nan(n,1); r_y = nan(n,1); rmse_y = nan(n,1);
ok = false(n,1);

pct = 0:100;
X_real_all = nan(n,101); Y_real_all = nan(n,101);
X_pred_all = nan(n,101); Y_pred_all = nan(n,101);

for i = 1:n
    row = Tmeta(i,:);
    sid = row.sub_id; fn = row.filename{1};
    json_path = fullfile(carpeta, 'Ferber', 'muestra40_raw', sprintf('%d_%s', sid, fn));

    sub_id(i) = sid;
    sexo(i) = row.Gender{1};
    talla_cm(i) = row.Height;
    peso_kg(i) = row.Weight;

    try
        S = Cargar_Ferber2024_Core(json_path, struct('lado','R'));

        antro_in = struct('talla_m', row.Height/100, 'masa_kg', row.Weight, ...
            'sexo', ternary(startsWith(row.Gender{1},'M'), 'M', 'F'));
        antro = Estimar_Antropometria_Core(antro_in);
        tempo0 = Temporizacion_Core(antro, 'Koopman');
        K = Koopman2014_Core(tempo0.velocidad_ms*3.6, antro.talla_m);
        m_K = deg2rad(K.cadera_flexext.angulo_deg);
        pct_K = linspace(0,100,numel(m_K));
        L_m_cm = antro.long_muslo_m * 100;

        % rodilla relativa a cadera - ver cabecera de este archivo (formula
        % verificada, NO Cadena_Cinematica_Core que asume tobillo fijo)
        dx = L_m_cm * sin(m_K);            dx = dx - dx(1);
        dy = L_m_cm * (1 - cos(m_K));      dy = dy - dy(1);

        xi = interp1(pct_K, dx, pct, 'pchip');
        yi = interp1(pct_K, dy, pct, 'pchip');

        r_x(i) = corr(S.x_horiz_relhip_cm(:), xi(:));
        rmse_x(i) = sqrt(mean((S.x_horiz_relhip_cm(:)-xi(:)).^2));
        r_y(i) = corr(S.y_vert_relhip_cm(:), yi(:));
        rmse_y(i) = sqrt(mean((S.y_vert_relhip_cm(:)-yi(:)).^2));
        n_ciclos(i) = S.n_ciclos;

        X_real_all(i,:) = S.x_horiz_relhip_cm; Y_real_all(i,:) = S.y_vert_relhip_cm;
        X_pred_all(i,:) = xi; Y_pred_all(i,:) = yi;
        ok(i) = true;
    catch ME
        fprintf('FALLO sujeto %d (%s): %s\n', sid, fn, ME.message);
    end
end

T = table(sub_id, sexo, talla_cm, peso_kg, n_ciclos, r_x, rmse_x, r_y, rmse_y);
T = T(ok,:);

fprintf('\n=== Resumen Evaluar_vs_Ferber: %d/%d sujetos procesados OK ===\n', sum(ok), n);
fprintf('Horizontal (X): r medio=%.3f (SD=%.3f, rango [%.3f %.3f]), RMSE medio=%.2f cm\n', ...
    mean(T.r_x), std(T.r_x), min(T.r_x), max(T.r_x), mean(T.rmse_x));
fprintf('Vertical   (Y): r medio=%.3f (SD=%.3f, rango [%.3f %.3f]), RMSE medio=%.2f cm\n', ...
    mean(T.r_y), std(T.r_y), min(T.r_y), max(T.r_y), mean(T.rmse_y));

writetable(T, fullfile(carpeta, 'Evaluar_vs_Ferber_resultados.csv'));

% --- Figura (25-ago-2026: CORREGIDA para no promediar sujetos - mismo
% principio ya aplicado en RODILLA/Kuopio/, TOBILLO/, INCLINACION_TIBIAL/,
% ver CIERRE_RODILLA.md #9. Esta figura se construyo el 24-ago-2026, antes
% de esa correccion, y quedo con el estilo viejo (media real vs media
% predicha) hasta hoy - las estadisticas por sujeto (T.r_x, T.r_y, CSV)
% siempre fueron correctas, solo la figura promediaba 40 antropometrias
% distintas en una sola curva. Se reemplaza por pares por sujeto + curvas
% de error, igual que Evaluar_vs_Kuopio_Avance.m.
idx_ok = find(ok);
n_ok = numel(idx_ok);
col_x = [0.85 0.33 0.10]; col_y = [0.30 0.55 0.75];

fig = figure('Name','Rodilla (posicion) vs Ferber 2024, N=40 sujetos reales','Position',[60 30 1300 1100],'Color','w');

subplot(3,2,1); hold on; grid on; box on;
for k=1:n_ok, i=idx_ok(k); plot(pct, X_real_all(i,:), '-', 'Color',[0.55 0.55 0.55 0.6], 'LineWidth',0.9); end
for k=1:n_ok, i=idx_ok(k); plot(pct, X_pred_all(i,:), '-', 'Color',[col_x 0.55], 'LineWidth',0.9); end
xlabel('% ciclo'); ylabel('X horizontal, rel. cadera [cm]');
title(sprintf('X: cada sujeto con SU prediccion (r=%.3f, RMSE=%.2fcm)', mean(T.r_x), mean(T.rmse_x)));
legend({'real (por sujeto)','modelo (por sujeto)'},'Location','best');

subplot(3,2,2); hold on; grid on; box on;
for k=1:n_ok, i=idx_ok(k); plot(pct, Y_real_all(i,:), '-', 'Color',[0.55 0.55 0.55 0.6], 'LineWidth',0.9); end
for k=1:n_ok, i=idx_ok(k); plot(pct, Y_pred_all(i,:), '-', 'Color',[col_y 0.55], 'LineWidth',0.9); end
xlabel('% ciclo'); ylabel('Y vertical, rel. cadera [cm]');
title(sprintf('Y: cada sujeto con SU prediccion (r=%.3f, RMSE=%.2fcm)', mean(T.r_y), mean(T.rmse_y)));
legend({'real (por sujeto)','modelo (por sujeto)'},'Location','best');

Ex = X_pred_all(idx_ok,:) - X_real_all(idx_ok,:);
Ey = Y_pred_all(idx_ok,:) - Y_real_all(idx_ok,:);
dibujar_error_ferber(subplot(3,2,3), pct, Ex, col_x, 'Error X (modelo - real) [cm]');
dibujar_error_ferber(subplot(3,2,4), pct, Ey, col_y, 'Error Y (modelo - real) [cm]');

subplot(3,2,5); hold on; grid on; box on;
histogram(T.r_x, 15, 'FaceColor',col_x);
xlabel('r (horizontal, por sujeto)'); ylabel('N sujetos'); xlim([-1 1]); xline(0,'k:');
title('Distribucion de r horizontal, N=40');

subplot(3,2,6); hold on; grid on; box on;
histogram(T.r_y, 15, 'FaceColor',col_y);
xlabel('r (vertical, por sujeto)'); ylabel('N sujetos'); xlim([-1 1]); xline(0,'k:');
title('Distribucion de r vertical, N=40');

sgtitle('Rodilla: Koopman 2014 (antropometria real por sujeto) vs Ferber 2024 (N=40, posicion real reconstruida)', 'FontWeight','bold');

out_png = fullfile(carpeta, 'Evaluar_vs_Ferber_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('\nFigura guardada en: %s\n', out_png);
fprintf('Tabla guardada en: %s\n', fullfile(carpeta, 'Evaluar_vs_Ferber_resultados.csv'));

end

% ------------------------------------------------------------------------
function dibujar_error_ferber(ax, pct, E, col, etiqueta)
% Curvas de error por sujeto + banda media+-SD (mismo patron que
% RODILLA/Kuopio/Evaluar_vs_Kuopio_Avance.m).
axes(ax); hold on; grid on; box on; %#ok<LAXES>
m = mean(E,1); s = std(E,0,1);
fill([pct fliplr(pct)], [m+s fliplr(m-s)], col, 'FaceAlpha',0.18, 'EdgeColor','none');
plot(pct, E', '-', 'Color',[0.55 0.55 0.55 0.5], 'LineWidth',0.6);
plot(pct, m, '-', 'Color',col, 'LineWidth',2.5);
yline(0,'k--');
xlabel('% ciclo'); ylabel(etiqueta);
title(sprintf('%s  |  media+-SD entre sujetos', etiqueta));
end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end
