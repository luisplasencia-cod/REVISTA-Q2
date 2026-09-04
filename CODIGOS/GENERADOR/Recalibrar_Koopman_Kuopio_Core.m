function out = Recalibrar_Koopman_Kuopio_Core(hacer_print)
% RECALIBRAR_KOOPMAN_KUOPIO_CORE  01-sep-2026: recalcula los coeficientes
%                   de calibracion afin de Koopman 2014 (muslo y tibia)
%                   con TODO el pool de Kuopio disponible hoy en
%                   RODILLA/Kuopio/raw/ (N=47 de 51 - los 4 restantes,
%                   sujetos 7/9/10/24, no tienen NINGUN trial utilizable
%                   por falta del punto RTibia_RFoot_score en su .c3d
%                   fuente, ver RODILLA/Kuopio/raw/_extraccion_28ago_51sujetos_log.txt
%                   - no es un limite de este script, es del dataset).
%
% POR QUE EXISTE: los coeficientes vigentes hasta hoy
% (Calibracion_Koopman_Kuopio_Core.m) se calcularon el 28-ago-2026 pero
% CONTRA EL POOL VIEJO de N=15 (13 utilizables) que se habia incorporado
% el 23-ago-2026 - la extraccion completa de los 51 sujetos corrio ese
% mismo 28-ago pero nadie volvio a recalcular contra ella despues. El
% usuario senalo esto (01-sep-2026): "por que no usamos LOSO con los
% sujetos disponibles de los 51". Este script es esa recalculacion, y
% ademas SE GUARDA EN EL REPO (el script original que produjo 0.7609/
% 0.8123 no se habia guardado - "era temporal", ver cabecera de
% Calibracion_Koopman_Kuopio_Core.m - no reproducible sin reconstruirlo).
%
% METODO (identico al ya documentado en Calibracion_Koopman_Kuopio_Core.m,
% y al mismo bucle de carga de TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases.m
% lineas 95-136, reusado aqui en vez de duplicado con una version distinta):
%   1) Cargar cada sujeto de Kuopio (antropometria y velocidad REALES).
%   2) Correr Koopman2014 con esa antropometria/velocidad -> theta_muslo,
%      theta_tibia (grados, via rodilla).
%   3) Angulo REAL = atan2 de la posicion de marcador (misma convencion
%      atan2 del proyecto).
%   4) DOS ajustes, con roles distintos (no se confunden ni se mezclan):
%      a) LOSO (N pliegues, uno por sujeto, ajustado SOLO con los otros
%         N-1) -> para VALIDAR (que es lo que reporta la Tabla de
%         calibracion afin del informe tecnico, tab:coeficientes_calibracion).
%      b) UN SOLO ajuste agrupado (todos los sujetos concatenados a la
%         vez) -> para PRODUCCION (Calibracion_Koopman_Kuopio_Core.m),
%         mismo principio ya usado en el proyecto para otras constantes
%         poblacionales (Fr=0.25, FRAC_AVANCE_APOYO).
%
% SALIDA (struct):
%   out.n_ok            sujetos utilizables (ids con CSV completo)
%   out.ids_excluidos    ids sin ningun trial utilizable (marcador faltante)
%   out.loso.gan_muslo/off_muslo/gan_tibia/off_tibia   promedio de los folds
%   out.loso.gan_muslo_sd (...)                        SD entre folds
%   out.produccion.gan_muslo/off_muslo/gan_tibia/off_tibia   ajuste agrupado
%
% USO: out = Recalibrar_Koopman_Kuopio_Core(); luego decidir si se
% aplican estos valores a Calibracion_Koopman_Kuopio_Core.m (paso manual,
% este script NO sobreescribe ese archivo por si solo).

if nargin < 1 || isempty(hacer_print), hacer_print = true; end

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta);
addpath(fullfile(carpeta, 'RODILLA', 'Kuopio'));

Tmeta = readtable(fullfile(carpeta, 'RODILLA', 'Kuopio', 'raw', 'subjects_meta.csv'));
ids = Tmeta.sub_id;
n = numel(ids);
npts = 101;
pct = 0:100;

Thm_koop = nan(n,101); Tht_koop = nan(n,101);
Thm_real = nan(n,101); Tht_real = nan(n,101);
ok = false(n,1);
warning('off', 'all');   % silencia advertencias ya conocidas de extrapolacion de v

for i = 1:n
    sid = ids(i);
    try
        S = Cargar_Kuopio2024_Core(sid);
        antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, ...
            'sexo', S.sexo(1), 'velocidad_ms', S.speed_ms, ...
            'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000);
        antro = Estimar_Antropometria_Core(antro_in);
        tempo = Temporizacion_Core(antro, 'Koopman');
        [th_m, th_t] = Obtener_Angulos_Candidato('Koopman', antro, tempo, npts);

        pct_corte = tempo.frac_apoyo*100;
        pct_ap  = linspace(0, pct_corte, npts);
        pct_bal = linspace(pct_corte, 100, npts);
        pct_nat = [pct_ap, pct_bal(2:end)];

        Thm_koop(i,:) = interp1(pct_nat, rad2deg([th_m.apoyo th_m.balanceo(2:end)]), pct, 'pchip');
        Tht_koop(i,:) = interp1(pct_nat, rad2deg([th_t.apoyo th_t.balanceo(2:end)]), pct, 'pchip');
        Thm_real(i,:) = rad2deg(atan2(-S.dx_muslo_cm, S.dy_muslo_cm));
        Tht_real(i,:) = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));
        ok(i) = true;
    catch
        % sujeto sin CSV utilizable (marcador RTibia_RFoot_score faltante
        % en la fuente, o trial invalido) - se omite, no se fuerza un dato.
    end
end
warning('on', 'all');

idx_ok = find(ok);
n_ok = numel(idx_ok);
ids_excluidos = ids(~ok);

% --- (a) LOSO: un fold por sujeto, ajustado solo con los otros n_ok-1 ---
gm = nan(n_ok,1); om = nan(n_ok,1); gt = nan(n_ok,1); ot = nan(n_ok,1);
for k = 1:n_ok
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);
    pm = polyfit(reshape(Thm_koop(otros,:),1,[]), reshape(Thm_real(otros,:),1,[]), 1);
    pt = polyfit(reshape(Tht_koop(otros,:),1,[]), reshape(Tht_real(otros,:),1,[]), 1);
    gm(k)=pm(1); om(k)=pm(2); gt(k)=pt(1); ot(k)=pt(2);
end

% --- (b) produccion: un solo ajuste sobre TODOS los n_ok concatenados ---
pm_all = polyfit(reshape(Thm_koop(idx_ok,:),1,[]), reshape(Thm_real(idx_ok,:),1,[]), 1);
pt_all = polyfit(reshape(Tht_koop(idx_ok,:),1,[]), reshape(Tht_real(idx_ok,:),1,[]), 1);

out = struct();
out.n_ok = n_ok;
out.ids_excluidos = ids_excluidos;
out.loso.gan_muslo = mean(gm);  out.loso.gan_muslo_sd = std(gm);
out.loso.off_muslo = mean(om);  out.loso.off_muslo_sd = std(om);
out.loso.gan_tibia = mean(gt);  out.loso.gan_tibia_sd = std(gt);
out.loso.off_tibia = mean(ot);  out.loso.off_tibia_sd = std(ot);
out.produccion.gan_muslo = pm_all(1); out.produccion.off_muslo = pm_all(2);
out.produccion.gan_tibia = pt_all(1); out.produccion.off_tibia = pt_all(2);

if hacer_print
    fprintf('=== Recalibracion Koopman vs Kuopio, N=%d (excluidos: %s) ===\n', ...
        n_ok, mat2str(ids_excluidos'));
    fprintf('LOSO (promedio %d folds):  muslo gan=%.4f (SD %.4f) off=%.2f (SD %.2f) deg\n', ...
        n_ok, out.loso.gan_muslo, out.loso.gan_muslo_sd, out.loso.off_muslo, out.loso.off_muslo_sd);
    fprintf('                            tibia gan=%.4f (SD %.4f) off=%.2f (SD %.2f) deg\n', ...
        out.loso.gan_tibia, out.loso.gan_tibia_sd, out.loso.off_tibia, out.loso.off_tibia_sd);
    fprintf('PRODUCCION (ajuste agrupado, N=%d): muslo gan=%.4f off=%.2f deg | tibia gan=%.4f off=%.2f deg\n', ...
        n_ok, out.produccion.gan_muslo, out.produccion.off_muslo, out.produccion.gan_tibia, out.produccion.off_tibia);
end

end
