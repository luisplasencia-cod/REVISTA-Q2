function [T, D] = Evaluar_vs_Maastricht_Individual_AnguloTibial()
% EVALUAR_VS_MAASTRICHT_INDIVIDUAL_ANGULOTIBIAL  02-sep-2026: valida el
%                   angulo tibial (theta_tibia = theta_muslo - phi_rodilla,
%                   misma reduccion "via rodilla" que usa Koopman) contra
%                   datos POR SUJETO (no agrupados) de Maastricht Normative
%                   3D Gait Dataset (Senden et al. 2024, OSF t72cw,
%                   N=244 hombres+mujeres, talla 153-197cm) - segunda base
%                   INDEPENDIENTE de Kuopio, usada especificamente para
%                   confirmar (o descartar) que la dependencia con talla
%                   que predice el generador es un defecto real y no un
%                   artefacto de una sola muestra.
%
% FUENTE DEL ARCHIVO: RODILLA/Maastricht/02_Overview_comf.xlsx (19.3 MB,
% descargado de https://osf.io/download/gxpu4/ el 02-sep-2026 - el archivo
% 05_AgeGenderGroup_comf.xlsx que ya estaba en el repo es solo el resumen
% AGRUPADO por edad/sexo, no sirve para correlacionar con talla
% individual). Talla individual: RODILLA/Maastricht/01_Demo_PhysEx.xlsx
% (ya estaba en el repo).
%
% METODO: hojas 'Rotation_RHipFlex_comf' y 'Rotation_RKneeFlex_comf' de
% 02_Overview_comf.xlsx traen, por sujeto (fila, id tipo 'HAC021'), el
% angulo (deg) en 100 puntos de %ciclo (columnas 3-102). theta_tibia_i(t)
% = HipFlex_i(t) - KneeFlex_i(t) - mismo signo/convencion que
% Koopman2014_Core.m (theta_muslo - phi_rodilla, ver Reduccion_Winter_Core.m).
%
% RESULTADO (hallazgo que motivo la correccion de Koopman2014_Core.m,
% opcion congelar_vl_angulo - ver GUIA_INTERPRETACION.md #10): SD entre
% sujetos real ~5-7 grados en todo el ciclo (no solo un tramo), vs. SD que
% predice el generador con la v/talla real de cada sujeto ~0.4-0.5 grados
% (10-15x menor) - y |corr(talla,real)| <= 0.08 en TODO el ciclo, contra
% |corr(talla,crudo)| hasta 0.99 en el modelo sin congelar. Mismo patron
% que Kuopio (N=47), en una muestra sin solape de talla en los extremos -
% descarta que fuera un artefacto de una sola base.
%
% SALIDA
%   T : tabla por sujeto (id, talla_m, y metricas si se piden)
%   D : struct con las curvas (real, crudo sin congelar, congelado) - pct
%       1:100, para reusar en analisis posteriores sin recalcular.
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
dir_maastricht = fullfile(carpeta, '..', 'RODILLA', 'Maastricht');
dir_generador = fullfile(carpeta, '..');
addpath(dir_generador);

f = fullfile(dir_maastricht, '02_Overview_comf.xlsx');
if ~isfile(f)
    error(['No se encontro %s - descargar de https://osf.io/download/gxpu4/ ' ...
        '(OSF t72cw, archivo "02_Overview_comf.xlsx", ~19 MB) y guardarlo ahi.'], f);
end

[hip_id, hip_curv]   = leer_curvas(f, 'Rotation_RHipFlex_comf');
[knee_id, knee_curv] = leer_curvas(f, 'Rotation_RKneeFlex_comf');

Cd = readcell(fullfile(dir_maastricht, '01_Demo_PhysEx.xlsx'), 'Sheet','Blad1');
demo_id = string(Cd(4:end,1));
demo_talla = cell2mat(Cd(4:end,5));

[ids_common, ih, ik] = intersect(hip_id, knee_id, 'stable');
[~, ih2, idm] = intersect(ids_common, demo_id, 'stable');
n = numel(ih2);

theta_hip  = hip_curv(ih(ih2), :);
theta_knee = knee_curv(ik(ih2), :);
talla_m = demo_talla(idm);
theta_tibia_real = theta_hip - theta_knee;   % [n x 100], pct 1:100
pct = 1:100;

fprintf('Sujetos con hip+knee+talla emparejados: %d (talla %.1f-%.1f cm)\n', ...
    n, min(talla_m)*100, max(talla_m)*100);

% --- Prediccion del generador con la talla real de cada sujeto ---
cal = Calibracion_Koopman_Kuopio_Core();
pct_gen = linspace(0,100,101);
theta_crudo_sincongelar = nan(n,101);
theta_crudo_congelado   = nan(n,101);
warning('off','all');
for i = 1:n
    v_ms = Estimar_Velocidad_Froude_Core(talla_m(i));
    v_kph = v_ms*3.6;
    Ksc = Koopman2014_Core(v_kph, talla_m(i), struct('nMuestras',101,'congelar_vl_angulo',false));
    Kc  = Koopman2014_Core(v_kph, talla_m(i), struct('nMuestras',101,'congelar_vl_angulo',true,'v_ref_kph',5.0,'l_ref_m',1.735));
    theta_crudo_sincongelar(i,:) = Ksc.theta_tibia_via_rodilla_deg;
    theta_crudo_congelado(i,:)   = Kc.theta_tibia_via_rodilla_deg;
end
warning('on','all');
theta_crudo_sc_i = interp1(pct_gen, theta_crudo_sincongelar', pct, 'pchip')';
theta_crudo_c_i  = interp1(pct_gen, theta_crudo_congelado',   pct, 'pchip')';

fprintf('\n%%ciclo | SD_real | SD_sinCongelar | SD_congelado | |corr(talla,real)| | |corr(talla,sinCongelar)|\n');
for p = [1 10 20 30 40 50 60 70 80 90 100]
    [~, idx] = min(abs(pct - p));
    fprintf('%3d%%   | %6.2f  | %6.2f         | %6.2f       | %8.3f           | %8.3f\n', p, ...
        std(theta_tibia_real(:,idx)), std(theta_crudo_sc_i(:,idx)), std(theta_crudo_c_i(:,idx)), ...
        abs(corr(talla_m, theta_tibia_real(:,idx))), abs(corr(talla_m, theta_crudo_sc_i(:,idx))));
end

r_forma_sc = corr(mean(theta_tibia_real,1)', mean(theta_crudo_sc_i,1)');
r_forma_c  = corr(mean(theta_tibia_real,1)', mean(theta_crudo_c_i,1)');
rmse_sc = sqrt(mean((mean(theta_tibia_real,1)-mean(theta_crudo_sc_i,1)).^2));
rmse_c  = sqrt(mean((mean(theta_tibia_real,1)-mean(theta_crudo_c_i,1)).^2));
fprintf('\nForma media: sin congelar r=%.3f RMSE=%.2f | congelado r=%.3f RMSE=%.2f\n', r_forma_sc, rmse_sc, r_forma_c, rmse_c);

T = table(ids_final_col(ids_common,ih2), talla_m, 'VariableNames', {'id','talla_m'});
D = struct('pct', pct, 'talla_m', talla_m, 'theta_tibia_real', theta_tibia_real, ...
    'theta_crudo_sin_congelar', theta_crudo_sc_i, 'theta_crudo_congelado', theta_crudo_c_i);
end

% ==========================================================================
function [ids, curvas] = leer_curvas(archivo, hoja)
raw = readcell(archivo, 'Sheet', hoja);
filas_id = cellfun(@(x) (ischar(x)||isstring(x)) && startsWith(string(x),'HAC'), raw(:,2));
ids = string(raw(filas_id, 2));
curvas = cell2mat(raw(filas_id, 3:102));
end

function c = ids_final_col(ids_common, ih2)
c = ids_common(ih2);
end
