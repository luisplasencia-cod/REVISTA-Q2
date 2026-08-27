function DIAG_ferber_lados()
% DIAG_ferber_lados  26-ago-2026: reevalua Zhao y Yun (AMBOS LADOS) contra
% Ferber 2024 (N=40, posicion real, antropometria real por sujeto), tras
% descubrir que el parametro de lado estaba mal puesto en la comparacion
% contra Maastricht. Pregunta que responde: con el lado correcto, ¿Koopman
% sigue siendo el mejor en la prueba decisiva, o Zhao/Yun lo superan
% tambien aqui?
%
% EFICIENCIA: Yun2014_Wrapper corre una regresion GP completa y escribe 30
% archivos por llamada. El ANGULO de cadera de Yun depende de la
% antropometria, pero para responder la pregunta de LADO alcanza con
% correrlo UNA vez con antropometria media y comparar la FORMA (r de
% Pearson es invariante a escala, y la escala L_muslo se aplica igual a
% ambos lados) - por eso se llama una sola vez fuera del bucle, no 40.
% Koopman y Zhao SI se corren por sujeto (son formulas cerradas, rapidas).

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
addpath(fullfile(fileparts(mfilename('fullpath')), 'Ferber'));
carpeta = fileparts(mfilename('fullpath'));
Tmeta = readtable(fullfile(carpeta, 'Ferber', 'muestra_40.csv'));
n = height(Tmeta);
pct = 0:100;

% --- Yun: UNA sola corrida, antropometria media de la muestra ---
antro_med = Estimar_Antropometria_Core(struct('talla_m', mean(Tmeta.Height)/100, ...
    'masa_kg', mean(Tmeta.Weight), 'sexo', 'M'));
p14 = [25, antro_med.talla_m*100, antro_med.masa_kg, 1, ...
       antro_med.long_muslo_m*100, antro_med.long_tibia_m*100, ...
       32.8,29.7,25.5,10, antro_med.long_pie_m*100, 7.30,7.10,9.80];
fprintf('Corriendo Yun UNA sola vez (antropometria media de los 40)...\n');
Yq = Yun2014_Wrapper(p14);
mYR = deg2rad(Yq.R_hip_extension.mean); mYL = deg2rad(Yq.L_hip_extension.mean);
pct_Y = linspace(0,100,numel(mYR));

nombres = {'Koopman','Zhao_izq','Zhao_der','Yun_R','Yun_L'};
r_x = nan(n,5); r_y = nan(n,5); rmse_x = nan(n,5); rmse_y = nan(n,5);
ok = false(n,1);

for i = 1:n
    row = Tmeta(i,:);
    sid = row.sub_id; fn = row.filename{1};
    json_path = fullfile(carpeta, 'Ferber', 'muestra40_raw', sprintf('%d_%s', sid, fn));
    try
        S = Cargar_Ferber2024_Core(json_path, struct('lado','R'));
        antro = Estimar_Antropometria_Core(struct('talla_m', row.Height/100, ...
            'masa_kg', row.Weight, 'sexo', ternary(startsWith(row.Gender{1},'M'),'M','F')));
        tempo0 = Temporizacion_Core(antro, 'Koopman');
        L_m_cm = antro.long_muslo_m * 100;

        K = Koopman2014_Core(tempo0.velocidad_ms*3.6, antro.talla_m);
        Zi = Zhao2026_Core(antro.long_muslo_m+antro.long_tibia_m, 1/tempo0.tiempo_ciclo_s, struct('lado','izquierda'));
        Zd = Zhao2026_Core(antro.long_muslo_m+antro.long_tibia_m, 1/tempo0.tiempo_ciclo_s, struct('lado','derecha'));

        angs = { deg2rad(K.cadera_flexext.angulo_deg), Zi.phi_cadera_rad, Zd.phi_cadera_rad, mYR, mYL };
        pcts = { linspace(0,100,numel(K.cadera_flexext.angulo_deg)), ...
                 linspace(0,100,numel(Zi.phi_cadera_rad)), ...
                 linspace(0,100,numel(Zd.phi_cadera_rad)), pct_Y, pct_Y };

        xr = S.x_horiz_relhip_cm(:); yr = S.y_vert_relhip_cm(:);
        for c = 1:5
            m = angs{c};
            dx = L_m_cm*sin(m);        dx = dx - dx(1);
            dy = L_m_cm*(1-cos(m));    dy = dy - dy(1);
            xi = interp1(pcts{c}, dx, pct, 'pchip').';
            yi = interp1(pcts{c}, dy, pct, 'pchip').';
            r_x(i,c) = corr(xr, xi);  rmse_x(i,c) = sqrt(mean((xr-xi).^2));
            r_y(i,c) = corr(yr, yi);  rmse_y(i,c) = sqrt(mean((yr-yi).^2));
        end
        ok(i) = true;
    catch ME
        fprintf('fallo %d: %s\n', sid, ME.message);
    end
end

fprintf('\n=== RODILLA rel. cadera vs FERBER 2024 (N=%d de %d) - TODOS los candidatos, AMBOS lados ===\n', sum(ok), n);
fprintf('%-10s %10s %10s %10s %10s\n', 'Modelo', 'r_x', 'RMSE_x', 'r_y', 'RMSE_y');
for c = 1:5
    fprintf('%-10s %10.3f %10.2f %10.3f %10.2f\n', nombres{c}, ...
        mean(r_x(ok,c)), mean(rmse_x(ok,c)), mean(r_y(ok,c)), mean(rmse_y(ok,c)));
end

T = table(Tmeta.sub_id(ok), r_x(ok,1), r_x(ok,2), r_x(ok,3), r_x(ok,4), r_x(ok,5), ...
    r_y(ok,1), r_y(ok,2), r_y(ok,3), r_y(ok,4), r_y(ok,5), ...
    'VariableNames', {'sub_id','rx_Koopman','rx_Zhao_izq','rx_Zhao_der','rx_Yun_R','rx_Yun_L', ...
                      'ry_Koopman','ry_Zhao_izq','ry_Zhao_der','ry_Yun_R','ry_Yun_L'});
writetable(T, fullfile(carpeta, 'DIAG_ferber_lados_resultados.csv'));
fprintf('\nTabla por sujeto: %s\n', fullfile(carpeta, 'DIAG_ferber_lados_resultados.csv'));

end

function out = ternary(cond,a,b)
if cond, out=a; else, out=b; end
end
