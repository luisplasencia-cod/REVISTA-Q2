function T = Validar_Externo_Ferber_Core()
% VALIDAR_EXTERNO_FERBER_CORE  02-sep-2026 (corregido mismo dia): examen
% externo de la RODILLA (posicion X,Y) contra Ferber et al. 2024 -- NUNCA
% usado para ajustar calibracion ni correccion (solo para elegir el
% modelo, Tabla comparacion_rodilla del informe) -- evita la
% circularidad de seguir probando contra Kuopio, que es el mismo dataset
% que ajusto los coeficientes. Camargo sigue reservado aparte (examen
% final, no tocar).
%
% POR QUE FERBER Y NO OTRO: de las bases ya en el proyecto, es la unica
% (ademas de Kuopio) con posicion 3D REAL (no solo angulos) y
% antropometria individual medida -- Maastricht solo tiene angulos.
% Cubre ademas 8 sujetos fuera del rango de talla validado con Kuopio
% (161-186.6cm): 5 por debajo (150-159.1cm), 3 por encima (187.5-195cm) --
% examen directo de si el modelo generaliza fuera del rango donde se
% ajusto, con dato real, no solo con un barrido sintetico.
%
% HALLAZGO REAL, DIAGNOSTICADO CON DATOS (02-sep-2026, investigacion
% dedicada, ver Diag_Ferber_Fase.m / Diag_Ferber_Descomponer.m /
% Diag_Ferber_Variantes_XY.m en esta misma carpeta): el primer intento de
% este script (usaba Trayectoria_Cadera_Core + Correccion_Hibrida_
% PenduloDoble_Core, igual que la comparacion contra Kuopio) daba r_X~0.36
% -- muy por debajo del r_X=0.999 contra Kuopio. Causa raiz CONFIRMADA
% (no es un defecto del modelo, es un error de comparacion): Ferber 2024
% es un dataset de TREADMILL (Ferber/README_Ferber2024_original.txt,
% lineas 18/48-49: "walking on a treadmill"), a diferencia de Kuopio
% (overground, confirmado en su propio docstring). En treadmill el sujeto
% NO avanza en el marco de laboratorio -- el rango real de X en Ferber es
% de solo ~28-35cm (Diag_Ferber_Fase.m), dominado enteramente por el
% balanceo rodilla-relativo-a-cadera, mientras que Trayectoria_Cadera_Core
% asume una zancada OVERGROUND de ~135-160cm (Froude, 4-5x mas grande) --
% esa rampa, sumada ANTES de Correccion_Hibrida_PenduloDoble_Core (que
% mezcla no linealmente rampa+balanceo via warp temporal + afin,
% calibrada contra el Xk COMPLETO de Kuopio), contamina la comparacion en
% las dos convenciones (global Y relhip) sin poder separarse despues
% (v2 de Diag_Ferber_Descomponer.m: restar la rampa DESPUES de corregir
% sigue dando r=0.36 -- la mezcla no es reversible).
%
% FIX APLICADO (Diag_Ferber_Variantes_XY.m, N=40, decisivo):
%   Xh=Yh=0 (SIN rampa/oscilacion de cadera, Trayectoria_Cadera_Core
%            NO se usa aqui) + angulo Koopman calibrado LOSO (Calibracion_
%            Koopman_Kuopio_Core) + Cinematica_DoblePendulo_Core, SIN
%            aplicar Correccion_Hibrida_PenduloDoble_Core (esa correccion
%            fue calibrada para la curva COMPLETA rampa+balanceo de
%            Kuopio -- aplicada a un balanceo puro sin rampa la destruye:
%            r_X 0.945->0.594, r_Y 0.777->-0.259, verificado con datos).
%   Resultado: r_X=0.945 (SD 0.045), r_Y=0.777 (SD 0.140) -- de "debil" a
%   "fuerte", con el MISMO modelo de produccion (solo se le quito la
%   rampa de avance overground, que no aplica a treadmill, y la
%   correccion que depende de ella).
%
% CONVENCION: solo RELHIP (rodilla relativa a cadera) -- la GLOBAL/lab de
% Ferber no es fisicamente comparable contra ningun modelo de avance
% overground (en treadmill el cuerpo no se traslada en el laboratorio),
% asi que se dejo de reportar. Cargar_Ferber2024_Core.m ya advertia esto
% para el modelo viejo de tobillo fijo; con el fix queda confirmado que
% aplica IGUAL al modelo vigente, por la naturaleza del dataset (treadmill),
% no por como se modela el tobillo.
%
% NOTA (alcance de este examen, no es una validacion cerrada): compara
% solo la FORMA del balanceo rodilla-cadera, sin la rampa de avance ni la
% correccion final de produccion -- es una pieza del pipeline completo,
% util para confirmar que la cinematica angular generaliza bien fuera de
% Kuopio, no una repeticion identica de la validacion contra Kuopio (que
% si incluye rampa+correccion, porque ahi si aplica).
%
% SALIDA: tabla T por sujeto, con r/RMSE en convencion relhip (X,Y) y una
% columna 'dentro_rango' (talla 161-186.6cm) para separar el examen dentro
% del rango validado del examen fuera de rango.

carpeta = fileparts(mfilename('fullpath'));
carpeta_ferber = fullfile(carpeta, 'Ferber');
addpath(carpeta_ferber);
addpath(fileparts(carpeta));  % CODIGOS/GENERADOR

Tmeta = readtable(fullfile(carpeta_ferber, 'muestra_40.csv'));
n = 101; pct = linspace(0,100,n);
warning('off','all');

filas = {};
for i = 1:height(Tmeta)
    sid = Tmeta.sub_id(i);
    talla_cm = Tmeta.Height(i);
    json_path = fullfile(carpeta_ferber, 'muestra40_raw', sprintf('%d_%s', sid, Tmeta.filename{i}));
    if ~isfile(json_path), continue; end
    try
        S = Cargar_Ferber2024_Core(json_path);
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
        continue;
    end
    if numel(S.x_horiz_cm) ~= n, continue; end

    % --- prediccion del pipeline vigente, SOLO TALLA (igual que la app),
    % SIN rampa de cadera (Xh=Yh=0, Ferber es treadmill) y SIN Correccion_
    % Hibrida (calibrada para la curva rampa+balanceo de Kuopio, no aplica
    % a un balanceo puro) -- ver hallazgo en la cabecera de este archivo.
    antro = Estimar_Antropometria_Core(struct('talla_m', talla_cm/100));
    tempo = Temporizacion_Core(antro, 'Koopman');
    cal = Calibracion_Koopman_Kuopio_Core();
    Kd = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, struct('nMuestras', n));
    theta1 = deg2rad(Kd.cadera_flexext.angulo_deg(:).');
    theta2 = Kd.theta_tibia_via_rodilla_rad(:).';
    theta1c = deg2rad(cal.off_muslo_deg) + cal.gan_muslo*theta1;
    theta2c = deg2rad(cal.off_tibia_deg) + cal.gan_tibia*theta2;
    L1_cm = antro.long_muslo_m*100; L2_cm = antro.long_tibia_m*100;
    posc = Cinematica_DoblePendulo_Core(theta1c, theta2c, L1_cm, L2_cm, 0, 0);
    Xpred = posc.Xk - posc.Xk(1); Ypred = posc.Yk - posc.Yk(1);

    % --- comparacion SOLO contra relhip (unica convencion valida en treadmill) ---
    Xreal_r = S.x_horiz_relhip_cm(:).'; Yreal_r = S.y_vert_relhip_cm(:).';

    rXr = corr(Xpred(:), Xreal_r(:)); rYr = corr(Ypred(:), Yreal_r(:));
    rmseXr = sqrt(mean((Xpred-Xreal_r).^2)); rmseYr = sqrt(mean((Ypred-Yreal_r).^2));

    dentro_rango = talla_cm >= 161 && talla_cm <= 186.6;

    filas(end+1,:) = {sid, talla_cm, dentro_rango, rXr, rYr, rmseXr, rmseYr}; %#ok<AGROW>
end
warning('on','all');

T = cell2table(filas, 'VariableNames', {'sub_id','talla_cm','dentro_rango', ...
    'r_X_relhip','r_Y_relhip','RMSE_X_relhip','RMSE_Y_relhip'});

fprintf('\n=== Examen externo RODILLA vs Ferber et al. 2024 (N=%d, nunca usado para calibrar/corregir) ===\n', height(T));
fprintf('Convencion RELATIVA-cadera (unica valida, Ferber=treadmill): r_X=%.3f (SD %.3f)  r_Y=%.3f (SD %.3f)\n', ...
    mean(T.r_X_relhip), std(T.r_X_relhip), mean(T.r_Y_relhip), std(T.r_Y_relhip));

idx_dentro = T.dentro_rango; idx_fuera = ~T.dentro_rango;
fprintf('\n--- Dentro del rango validado (161-186.6cm), N=%d ---\n', sum(idx_dentro));
reporte_subset(T, idx_dentro);
fprintf('--- FUERA del rango validado, N=%d (talla: %s) ---\n', sum(idx_fuera), mat2str(T.talla_cm(idx_fuera)'));
reporte_subset(T, idx_fuera);

writetable(T, fullfile(carpeta, 'Validar_Externo_Ferber_resultados.csv'));
fprintf('\nGuardado: Validar_Externo_Ferber_resultados.csv\n');

end

function reporte_subset(T, idx)
if sum(idx)==0, fprintf('  (ninguno)\n'); return; end
fprintf('  RELATIVA:  r_X=%.3f (RMSE=%.2fcm)  r_Y=%.3f (RMSE=%.2fcm)\n', ...
    mean(T.r_X_relhip(idx)), mean(T.RMSE_X_relhip(idx)), mean(T.r_Y_relhip(idx)), mean(T.RMSE_Y_relhip(idx)));
end
