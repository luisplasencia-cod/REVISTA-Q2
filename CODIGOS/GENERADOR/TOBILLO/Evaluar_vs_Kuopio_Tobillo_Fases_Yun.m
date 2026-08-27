function [T, D] = Evaluar_vs_Kuopio_Tobillo_Fases_Yun(hacer_figura)
% EVALUAR_VS_KUOPIO_TOBILLO_FASES_YUN  27-ago-2026: replica EXACTA del
%                   pipeline de TOBILLO de Koopman (Evaluar_vs_Kuopio_
%                   Tobillo_Fases.m, la ESPECIFICACION - ver
%                   CODIGOS/GENERADOR/PLAN_ZHAO_YUN.md) con el candidato
%                   Yun 2014 en vez de Koopman 2014. Unico cambio de
%                   fondo: la fuente de theta_muslo/theta_tibia pasa de
%                   Koopman2014_Core (via Obtener_Angulos_Candidato
%                   'Koopman') a Yun2014_Wrapper (via Obtener_Angulos_
%                   Candidato 'Yun', canal R_ nativo por defecto - D2 de
%                   DECISIONES.md, NO se mezclan canales L_/R_, y theta_
%                   tibia usa via_tobillo_R, la regla ya corregida el
%                   26-ago-2026 en Obtener_Angulos_Candidato.m - NO via
%                   rodilla). Cadena_Completa_Core, el residuo de rockers
%                   LOSO, el cierre de ciclo/zancada y el formato de
%                   figura/tabla son CANDIDATO-AGNOSTICOS y se dejan sin
%                   cambios de diseno, tal como exige el plan.
%
%   IMPORTANTE: la RODILLA no se toca aqui (igual que en Koopman/Zhao) -
%   ver CIERRE_TOBILLO.md #6. Este archivo NO recalcula rodilla.
%
%   ADVERTENCIA DE RENDIMIENTO: Yun2014_Wrapper corre una regresion
%   Gaussian Process completa del toolbox de terceros y escribe ~30
%   archivos por cada llamada (una por sujeto, 15 llamadas en total aqui)
%   - es LENTO, ver PLAN_ZHAO_YUN.md. Cada sujeto llama a
%   Obtener_Angulos_Candidato('Yun',...) una sola vez (paso 1a); el resto
%   del pipeline (calibracion, cadena, residuos) no vuelve a invocar a Yun.
%
%   MAPEO - de donde viene cada pieza (pedido explicito del usuario,
%   25-ago-2026, para trazabilidad en el articulo):
%
%   1) DE YUN 2014 (toolbox real de terceros, sin modificar, canal R_
%      nativo): R_hip_extension(t) (via theta_muslo), theta_tibia_via_
%      tobillo_R(t) (Yun2014_Wrapper.m, via Obtener_Angulos_Candidato
%      ('Yun',...) - ver PLAN_ZHAO_YUN.md)
%
%   2) NUESTRO APORTE #1 - Cadena_Completa_Core.m (24-ago-2026, nunca
%      validado contra datos reales hasta hoy): reconstruccion de
%      POSICION consciente de FASE (apoyo: tobillo pivote fijo, cadena
%      hacia arriba; balanceo: cadera avanza, cadena hacia abajo).
%      Corrige el sesgo sistematico de la formula continua
%      dy=L*(1-cos(theta)) (funcion PAR - ver CIERRE_TOBILLO.md #5-bis):
%      minimo real siempre superficial (-0.67 a -3.08cm) pero la formula
%      continua predecia siempre profundo (-4.48 a -7.71cm) en los 15
%      sujetos - sesgo sistematico, no ruido.
%
%   3) NUESTRO APORTE #2 - residuo de rockers (nuevo en este archivo): el
%      pivote "fijo" en apoyo es a su vez una idealizacion (el usuario lo
%      senalo: se ve forzado, el dato real SI se mueve -1 a -3cm). Los "3
%      rockers de la marcha" (heel/ankle/forefoot rocker - Perry &
%      Burnfield, PM&R KnowledgeNow) son el mecanismo real conocido -
%      pero no se encontro una curva cuantitativa publicada reusable
%      (busqueda 25-ago-2026, solo descripcion cualitativa). En vez de
%      importar un numero de otra fuente con poblacion/instrumentacion
%      distinta, se construye el residuo EMPIRICO con LOSO sobre los
%      mismos 15 sujetos de Kuopio (misma tecnica ya validada para el
%      vaiven de cadera de rodilla) - el residuo real de apoyo de CADA
%      sujeto se predice con el promedio de los OTROS 14, nunca con su
%      propia curva.
%
%   4) KUOPIO 2024 (Lavikainen et al., Data Brief 56:110841) - dato REAL
%      overground, N=15, antropometria y velocidad MEDIDAS. Rol: valida
%      todo lo anterior y construye el residuo de rockers (LOSO) - nunca
%      se usa para ajustar los coeficientes de Yun ni la logica de
%      Cadena_Completa_Core.m, que ya estaban fijados antes de esto.
%
% RESULTADO (Yun, 27-ago-2026): ver Evaluar_vs_Kuopio_Tobillo_Fases_Yun_
% resultados.csv y BITACORA_NOCHE.md para los numeros reales de esta
% corrida - no se copian a mano los de Koopman/Zhao aqui.
%
% METODO (identico al de Koopman, ver Evaluar_vs_Kuopio_Tobillo_Fases.m
% para el detalle/motivacion completos): la correccion se aplica sobre el
% ANGULO (calibracion afin LOSO de theta_muslo y theta_tibia), no sobre la
% posicion ya construida - mismo patron, mismos coeficientes propios de
% cada corrida (columnas gan_muslo/off_muslo/gan_tibia/off_tibia de la
% tabla de salida).
%
% NOTA (regla de oro de PLAN_ZHAO_YUN.md): si el resultado de Yun sale con
% r bajo por el defasaje de flexion de rodilla ya documentado en el
% proyecto, ESO ES UN HALLAZGO VALIDO A REPORTAR, no un error a esconder
% ni a "arreglar" con el truco de lado (L_/R_) ni con via_rodilla.
%
%   SALIDAS
%     T : tabla por sujeto (metricas + antropometria)
%     D : struct con las curvas por sujeto (pct, sub_id, sexo, talla_cm,
%         masa_kg, X_real, X_pred, Y_real, Y_pred) - lo consume
%         Evaluar_Individual_Kuopio_Tobillo_Yun.m para que exista UNA SOLA
%         implementacion del modelo.
%   hacer_figura (opcional, default true): false para reusar el calculo
%   sin generar/sobrescribir la figura de grupo.
%
%   NOTA SOBRE LA FIGURA (25-ago-2026, objecion correcta del usuario): los
%   paneles ya NO grafican media(real) vs media(predicho). Promediar
%   trayectorias de sujetos con talla/masa distintas mezcla curvas que no
%   son comparables entre si, y el modelo se alimenta justamente de la
%   antropometria de cada uno. Se muestran pares por sujeto y curvas de
%   error, ambos validos con antropometria heterogenea.

if nargin < 1 || isempty(hacer_figura), hacer_figura = true; end

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

% --- Paso 1a: cargar sujetos, angulos del candidato (Yun) y angulos REALES ---
Sarr = cell(n,1); Antro = cell(n,1); Tempo = cell(n,1);
Thm_s = cell(n,1); Tht_s = cell(n,1); pct_nat_arr = cell(n,1);
Thm_cand = nan(n,101); Tht_cand = nan(n,101);   % en malla 0:100, grados
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
        tempo = Temporizacion_Core(antro, 'Yun');
        [th_m, th_t, tempo] = Obtener_Angulos_Candidato('Yun', antro, tempo, npts);
        tempo.tiempo_ciclo_s = S.T_ciclo_s;
        tempo.tiempo_apoyo_s = tempo.frac_apoyo * tempo.tiempo_ciclo_s;
        tempo.tiempo_balanceo_s = (1-tempo.frac_apoyo) * tempo.tiempo_ciclo_s;

        pct_corte = tempo.frac_apoyo*100;
        pct_ap  = linspace(0, pct_corte, npts);
        pct_bal = linspace(pct_corte, 100, npts);
        pct_nat = [pct_ap, pct_bal(2:end)];

        Thm_cand(i,:) = interp1(pct_nat, rad2deg([th_m.apoyo th_m.balanceo(2:end)]), pct, 'pchip');
        Tht_cand(i,:) = interp1(pct_nat, rad2deg([th_t.apoyo th_t.balanceo(2:end)]), pct, 'pchip');
        % angulos REALES (misma convencion atan2, 0=vertical) - el tibial es
        % identico al que valida INCLINACION_TIBIAL/
        Thm_real(i,:) = rad2deg(atan2(-S.dx_muslo_cm, S.dy_muslo_cm));
        Tht_real(i,:) = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm));

        Sarr{i}=S; Antro{i}=antro; Tempo{i}=tempo;
        Thm_s{i}=th_m; Tht_s{i}=th_t; pct_nat_arr{i}=pct_nat;
        pct_corte_arr(i) = pct_corte;
        ok(i) = true;
        fprintf('Sujeto %d OK (%d/%d)\n', sid, i, n);
    catch ME
        fprintf('FALLO sujeto %d: %s\n', sid, ME.message);
    end
end
idx_ok = find(ok);

% --- Paso 1b: calibracion AFIN LOSO de LOS DOS angulos, y luego la cadena ---
% Mismo metodo que Koopman/Zhao (ver cabecera): la correccion se aplica
% DONDE esta el error - el angulo publicado por el candidato - y no sobre
% la posicion ya construida.
% Como el tobillo cuelga de DOS angulos encadenados, se calibran ambos.
tob_x_sinresiduo = nan(n,101); tob_y_sinresiduo = nan(n,101);
gan_muslo = nan(n,1); off_muslo = nan(n,1);
gan_tibia = nan(n,1); off_tibia = nan(n,1);

for k = 1:numel(idx_ok)
    i = idx_ok(k); otros = idx_ok(idx_ok ~= i);

    pm = polyfit(reshape(Thm_cand(otros,:),1,[]), reshape(Thm_real(otros,:),1,[]), 1);
    pt = polyfit(reshape(Tht_cand(otros,:),1,[]), reshape(Tht_real(otros,:),1,[]), 1);
    gan_muslo(i)=pm(1); off_muslo(i)=pm(2);
    gan_tibia(i)=pt(1); off_tibia(i)=pt(2);

    th_m = Thm_s{i}; th_t = Tht_s{i};    % en radianes, por fase
    th_m.apoyo    = deg2rad(pm(2)) + pm(1)*th_m.apoyo;
    th_m.balanceo = deg2rad(pm(2)) + pm(1)*th_m.balanceo;
    th_t.apoyo    = deg2rad(pt(2)) + pt(1)*th_t.apoyo;
    th_t.balanceo = deg2rad(pt(2)) + pt(1)*th_t.balanceo;

    cc = Cadena_Completa_Core(th_m, th_t, Antro{i}.long_muslo_m, Antro{i}.long_tibia_m, Tempo{i}, npts);
    tob_x_nat = [cc.apoyo.tobillo_x_cm,  cc.balanceo.tobillo_x_cm(2:end)];
    tob_y_nat = [cc.apoyo.tobillo_y_cm,  cc.balanceo.tobillo_y_cm(2:end)];
    tob_x_sinresiduo(i,:) = interp1(pct_nat_arr{i}, tob_x_nat, pct, 'pchip');
    tob_y_sinresiduo(i,:) = interp1(pct_nat_arr{i}, tob_y_nat, pct, 'pchip');
end

% --- Paso 2: residuo de rockers en X e Y, LOSO -> curvas GEOMETRICAS (sin calibrar) ---
% CORREGIDO 25-ago-2026 (el usuario detecto el problema: el modelo fija
% el tobillo en EXACTAMENTE (0,0) durante TODO el apoyo, por construccion
% de Cadena_Completa_Core.m - una constante matematica perfecta, no solo
% "cercana a cero" - eso es fisicamente imposible. El dato real SI avanza
% un poco en X durante el apoyo (3-13cm segun el sujeto, por el mecanismo
% de "rockers" del pie - talon->tobillo->antepie, mismo mecanismo ya usado
% para el residuo de Y). Antes solo se aplicaba el residuo a Y, asumiendo
% que los rockers eran "solo verticales" - el propio dato real contradice
% eso, tambien hay avance horizontal real. Se aplica el MISMO residuo
% empirico LOSO a X tambien.
X_real_tob = nan(n,101); Y_real_tob = nan(n,101); X_geo_tob = nan(n,101); Y_geo_tob = nan(n,101);

for k = 1:numel(idx_ok)
    i = idx_ok(k); S = Sarr{i};
    pc = round(pct_corte_arr(i)) + 1;

    otros = idx_ok(idx_ok ~= i);
    residuo_x_ap = zeros(1, pc); residuo_y_ap = zeros(1, pc);
    for j = otros(:)'
        residuo_x_ap = residuo_x_ap + Sarr{j}.x_horiz_tobillo_cm(1:pc);
        residuo_y_ap = residuo_y_ap + Sarr{j}.y_vert_tobillo_cm(1:pc);
    end
    residuo_x_ap = residuo_x_ap / numel(otros);
    residuo_y_ap = residuo_y_ap / numel(otros);

    tob_x = tob_x_sinresiduo(i,:);
    tob_x(1:pc) = tob_x(1:pc) + residuo_x_ap;
    tob_x(pc+1:end) = tob_x(pc+1:end) + residuo_x_ap(end);

    tob_y = tob_y_sinresiduo(i,:);
    tob_y(1:pc) = tob_y(1:pc) + residuo_y_ap;
    tob_y(pc+1:end) = tob_y(pc+1:end) + residuo_y_ap(end);

    % CIERRE DE CICLO (nuevo, 25-ago-2026, pedido del usuario): en marcha
    % periodica sobre piso plano, el tobillo DEBE terminar el ciclo
    % (pct=100) a la misma altura de donde partio (pct=0=0, por
    % construccion) - verificado en el dato real: los 15 sujetos cierran
    % dentro de -0.6 a +1.8cm (~0, dentro del ruido). El modelo, en
    % cambio, terminaba sistematicamente ~8-11cm MAS ALTO en los 15
    % sujetos - un sesgo real, no ruido, acumulado durante el balanceo
    % (la extension terminal de rodilla del modelo no baja al tobillo lo
    % suficiente antes del "siguiente" contacto). Se fuerza el cierre con
    % una rampa suave SOLO en el balanceo (el apoyo ya esta bien, no se
    % toca) - de 0 en el inicio del balanceo a "-exceso" en pct=100, para
    % no introducir un salto brusco. Es una restriccion fisica exacta
    % (periodicidad del ciclo), no un ajuste arbitrario - a diferencia de
    % X (avance horizontal), que NO cierra (cada ciclo avanza una zancada
    % real, no vuelve a 0) y por eso NO se le aplica esta correccion.
    exceso = tob_y(end);   % deberia ser ~0, es el sesgo a remover
    n_bal = numel(tob_y) - pc;
    rampa = linspace(0, -exceso, n_bal);
    tob_y(pc+1:end) = tob_y(pc+1:end) + rampa;

    % CIERRE DE ZANCADA EN X (nuevo, 25-ago-2026, mismo principio que el
    % cierre de ciclo en Y pero para el eje que SI avanza): en marcha
    % periodica el pie recorre exactamente UNA zancada por ciclo, y la
    % zancada es velocidad*T_ciclo - una cantidad que el generador conoce
    % sin ningun dato medido de Kuopio. La cadena por fases, en cambio,
    % genera su propia zancada a partir de la geometria y se desvia hasta
    % ~15cm en algunos sujetos. Se corrige repartiendo la diferencia de
    % forma proporcional al avance ya recorrido (no toca el apoyo, que ya
    % esta bien por el residuo de rockers, y no introduce saltos).
    zancada_cm = S.speed_ms * S.T_ciclo_s * 100;
    w = (tob_x - tob_x(1)) / max(tob_x(end) - tob_x(1), eps);
    tob_x = tob_x + (zancada_cm - tob_x(end)) * w;

    X_real_tob(i,:)=S.x_horiz_tobillo_cm; Y_real_tob(i,:)=S.y_vert_tobillo_cm;
    X_geo_tob(i,:)=tob_x; Y_geo_tob(i,:)=tob_y;
end

% --- Paso 3: metricas (YA NO hay calibracion de posicion) ---
% La calibracion de ganancia por eje que habia aqui se ELIMINO el
% 25-ago-2026: al mover la correccion al nivel del angulo (Paso 1b) deja
% de hacer falta (mismo diseno que Koopman/Zhao, ver sus cabeceras).
sub_id = zeros(n,1); sexo = strings(n,1); talla_cm = zeros(n,1); masa_kg = zeros(n,1);
r_x_tob = nan(n,1); rmse_x_tob = nan(n,1);
r_y_tob = nan(n,1); rmse_y_tob = nan(n,1);
X_pred_tob = X_geo_tob; Y_pred_tob = Y_geo_tob;

for k = 1:numel(idx_ok)
    i = idx_ok(k); S = Sarr{i};
    r_x_tob(i) = corr(S.x_horiz_tobillo_cm(:), X_pred_tob(i,:)');
    rmse_x_tob(i) = sqrt(mean((X_real_tob(i,:)-X_pred_tob(i,:)).^2));
    r_y_tob(i) = corr(S.y_vert_tobillo_cm(:), Y_pred_tob(i,:)');
    rmse_y_tob(i) = sqrt(mean((Y_real_tob(i,:)-Y_pred_tob(i,:)).^2));
    sub_id(i)=ids(i); sexo(i)=S.sexo; talla_cm(i)=S.talla_cm; masa_kg(i)=S.masa_kg;
end
ok2 = false(n,1); ok2(idx_ok) = true;

T = table(sub_id, sexo, talla_cm, masa_kg, gan_muslo, off_muslo, gan_tibia, off_tibia, ...
    r_x_tob, rmse_x_tob, r_y_tob, rmse_y_tob);
T = T(ok2,:);

D = struct('pct', pct, 'sub_id', sub_id(ok2), 'sexo', sexo(ok2), ...
    'talla_cm', talla_cm(ok2), 'masa_kg', masa_kg(ok2), ...
    'X_real', X_real_tob(ok2,:), 'X_pred', X_pred_tob(ok2,:), ...
    'Y_real', Y_real_tob(ok2,:), 'Y_pred', Y_pred_tob(ok2,:));

ampR_y = mean(max(Y_real_tob(ok2,:),[],2)-min(Y_real_tob(ok2,:),[],2));
ampP_y = mean(max(Y_pred_tob(ok2,:),[],2)-min(Y_pred_tob(ok2,:),[],2));

fprintf('\n=== TOBILLO, MODELO FINAL Yun (angulos calibrados LOSO + fases + rockers) vs Kuopio, N=%d ===\n', sum(ok2));
fprintf('Calibracion de angulos: muslo ganancia=%.3f offset=%.2f | tibia ganancia=%.3f offset=%.2f (grados)\n', ...
    mean(T.gan_muslo), mean(T.off_muslo), mean(T.gan_tibia), mean(T.off_tibia));
fprintf('X: r=%.3f (SD=%.3f), RMSE=%.2fcm\n', mean(T.r_x_tob), std(T.r_x_tob), mean(T.rmse_x_tob));
fprintf('Y: r=%.3f (SD=%.3f), RMSE=%.2fcm | amplitud modelo/real=%.2f\n', ...
    mean(T.r_y_tob), std(T.r_y_tob), mean(T.rmse_y_tob), ampP_y/ampR_y);

writetable(T, fullfile(carpeta, 'Evaluar_vs_Kuopio_Tobillo_Fases_Yun_resultados.csv'));
fprintf('Tabla: %s\n', fullfile(carpeta, 'Evaluar_vs_Kuopio_Tobillo_Fases_Yun_resultados.csv'));

if ~hacer_figura, return; end

% ---------------- Figura de grupo (PAREADA, sin promediar sujetos) ------
col_x = [0.85 0.33 0.10]; col_y = [0.20 0.45 0.70];
fig = figure('Name','TOBILLO Yun modelo final (fases+rockers) vs Kuopio','Position',[40 20 1250 1050],'Color','w');

subplot(3,2,1); hold on; grid on; box on;
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, X_real_tob(i,:), '-', 'Color',[0.55 0.55 0.55 0.85],'LineWidth',1.1); end
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, X_pred_tob(i,:), '-', 'Color',[col_x 0.85],'LineWidth',1.1); end
xlabel('% ciclo'); ylabel('X horizontal ABSOLUTO [cm]');
title(sprintf('X: cada sujeto con SU prediccion (r=%.3f, RMSE=%.2fcm)', mean(T.r_x_tob), mean(T.rmse_x_tob)));
legend({'real (por sujeto)','modelo Yun (por sujeto)'},'Location','northwest');

subplot(3,2,2); hold on; grid on; box on;
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Y_real_tob(i,:), '-', 'Color',[0.55 0.55 0.55 0.85],'LineWidth',1.1); end
for k=1:numel(idx_ok), i=idx_ok(k); plot(pct, Y_pred_tob(i,:), '-', 'Color',[col_y 0.85],'LineWidth',1.1); end
xlabel('% ciclo'); ylabel('Y vertical ABSOLUTO [cm]');
title(sprintf('Y: cada sujeto con SU prediccion (r=%.3f, RMSE=%.2fcm)', mean(T.r_y_tob), mean(T.rmse_y_tob)));
legend({'real (por sujeto)','modelo Yun (por sujeto)'},'Location','northwest');

Ex = X_pred_tob(idx_ok,:) - X_real_tob(idx_ok,:);
Ey = Y_pred_tob(idx_ok,:) - Y_real_tob(idx_ok,:);
dibujar_error_tob(subplot(3,2,3), pct, Ex, col_x, 'Error X (modelo - real) [cm]');
dibujar_error_tob(subplot(3,2,4), pct, Ey, col_y, 'Error Y (modelo - real) [cm]');

subplot(3,2,5); hold on; grid on; box on;
histogram(T.r_x_tob,10,'FaceColor',col_x);
xlabel('r horizontal, por sujeto'); ylabel('N sujetos'); xlim(rango_r(T.r_x_tob));
title(sprintf('Distribucion r horizontal, N=%d', sum(ok2)));

subplot(3,2,6); hold on; grid on; box on;
histogram(T.r_y_tob,10,'FaceColor',col_y);
xlabel('r vertical, por sujeto'); ylabel('N sujetos'); xlim(rango_r(T.r_y_tob));
title(sprintf('Distribucion r vertical, N=%d', sum(ok2)));

sgtitle(sprintf('TOBILLO Yun vs Kuopio 2024 (overground, N=%d) - angulos calibrados (LOSO) + cadena por fases + rockers', sum(ok2)), 'FontWeight','bold');
out_png = fullfile(carpeta, 'Evaluar_vs_Kuopio_Tobillo_Fases_Yun_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura: %s\n', out_png);

end

% ------------------------------------------------------------------------
function lim = rango_r(r)
% Ver nota en RODILLA/Kuopio/Evaluar_vs_Kuopio_Avance.m: con xlim([-1 1])
% fijo, 15 sujetos todos entre 0.99 y 1.00 salen como una sola barra
% ilegible pegada al borde.
lo = min(r); hi = max(r);
margen = max(0.02, 0.15*(hi-lo));
lim = [max(0, lo-margen), min(1, hi+margen)];
if diff(lim) < 0.02, lim = [max(0, lim(1)-0.01), min(1, lim(2)+0.01)]; end
end

% ------------------------------------------------------------------------
function dibujar_error_tob(ax, pct, E, col, etiqueta)
axes(ax); hold on; grid on; box on; %#ok<LAXES>
m = mean(E,1); s = std(E,0,1);
fill([pct fliplr(pct)], [m+s fliplr(m-s)], col, 'FaceAlpha',0.18, 'EdgeColor','none');
plot(pct, E', '-', 'Color',[0.55 0.55 0.55 0.7], 'LineWidth',0.8);
plot(pct, m, '-', 'Color',col, 'LineWidth',2.5);
yline(0,'k--');
xlabel('% ciclo'); ylabel(etiqueta);
title(sprintf('%s  |  media+-SD entre sujetos', etiqueta));
end
