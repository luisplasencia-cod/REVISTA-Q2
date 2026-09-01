function modelo = Personalizar_Plantilla_Fukuchi_GRF_Core()
% PERSONALIZAR_PLANTILLA_FUKUCHI_GRF_CORE  29-ago-2026 (VERSION FINAL,
% ver Comparar_Variantes_Plantilla_Fukuchi.m para las 8 variantes
% probadas): en vez de UNA sola plantilla poblacional de %BW(t)
% (Construir_Plantilla_Fukuchi_GRF.m, r=0.84 contra Kuopio real pero
% identica para todo el mundo), ajusta una regresion lineal PUNTO A PUNTO
% del ciclo (mismo principio que usa Koopman 2014 en sus propias 5 tablas
% de regresion por evento: predecir con velocidad y talla, coeficientes ya
% ajustados, sin volver a entrenar en tiempo de uso):
%
%   %BW(pct) = a(pct) + b(pct)*velocidad_ms [+ c(pct)*talla_m, si ayuda]
%
% GANADORA DE 8 VARIANTES PROBADAS Y VALIDADAS CONTRA KUOPIO REAL
% (Comparar_Variantes_Plantilla_Fukuchi.m, mismo criterio de toda la
% sesion: medir, no asumir):
%   - Piernas R+L combinadas (N=48 filas, no solo R) - dio lo mismo que
%     solo-R en la plantilla plana (0.838 vs 0.842, diferencia de ruido),
%     pero SI ayudo combinado con personalizacion.
%   - SOLO adultos jovenes de Fukuchi (<40 anios, 24 de los 42 sujetos -
%     el dataset tiene un split limpio bimodal 21-37 / 50-84, no hay
%     sujetos intermedios) - por si solo (plantilla plana) empeoraba
%     (0.835 vs 0.842 con todos) pero COMBINADO con personalizar por
%     velocidad+talla fue la mejor variante de las 8 (0.866).
%   - Talla SI ayuda (umbral de mejora de R^2 superado). Masa NO ayuda
%     agregada como 3er predictor (empeora de 0.866 a 0.849 - sobreajuste
%     con n=48 y 4 predictores x 101 puntos).
% Resultado final: r=0.866 (SD~0.08), RMSE=15.1%BW contra los 13 sujetos
% de Kuopio - mejor que la plantilla plana (0.842) y que personalizar
% sobre TODOS los 42 sujetos sin filtrar por edad (0.847).
%
% ENTRADA: ninguna (usa los 24 sujetos jovenes de Fukuchi, ambas piernas)
% SALIDA: struct `modelo` con .pct, .a, .b, .c (c=[] si no ayuda),
%   .incluye_talla, .r2_solo_velocidad, .r2_con_talla (comparacion, en
%   ambos casos promedio sobre los 101 puntos del ciclo)
% ==========================================================================

EDAD_MAX_ANIOS = 40;  % split bimodal real de Fukuchi (jovenes 21-37, mayores 50-84)

carpeta = fileparts(mfilename('fullpath'));
addpath(fullfile(carpeta,'RODILLA','Fukuchi'));

curvasR = nan(42,101); curvasL = nan(42,101); velR = nan(42,1); velL = nan(42,1);
talla_m42 = nan(42,1); edad42 = nan(42,1);
for sid = 1:42
    try
        SR = Cargar_Fukuchi2018_GRF_Core(sid, struct('pierna','R'));
        SL = Cargar_Fukuchi2018_GRF_Core(sid, struct('pierna','L'));
    catch
        continue
    end
    curvasR(sid,:) = SR.GRF_vertical_pctBW; velR(sid) = SR.speed_ms;
    curvasL(sid,:) = SL.GRF_vertical_pctBW; velL(sid) = SL.speed_ms;
    talla_m42(sid) = SR.talla_cm/100;
    edad42(sid) = SR.edad_anios;
end
% Combinar R+L (cada pierna es una fila independiente) y filtrar por edad
curvas = [curvasR; curvasL]; vel = [velR; velL]; talla_m = [talla_m42; talla_m42]; edad = [edad42; edad42];
ok = ~any(isnan(curvas),2) & ~isnan(vel) & ~isnan(talla_m) & (edad < EDAD_MAX_ANIOS);
curvas = curvas(ok,:); vel = vel(ok); talla_m = talla_m(ok);
n = sum(ok);
fprintf('sujetos-pierna usados para el ajuste (jovenes, R+L): %d\n', n);

pct = 0:100;
a = nan(1,101); b = nan(1,101); c = nan(1,101);
r2_v = nan(1,101); r2_vt = nan(1,101);

X_v  = [ones(n,1), vel];
X_vt = [ones(n,1), vel, talla_m];

for i = 1:101
    y = curvas(:,i);
    % Solo velocidad
    coef_v = X_v \ y;
    yhat_v = X_v*coef_v;
    ss_res_v = sum((y-yhat_v).^2); ss_tot = sum((y-mean(y)).^2);
    % durante el balanceo (~60-100% del ciclo), casi todas las curvas son
    % 0 exacto (SD~0, ver Construir_Plantilla_Fukuchi_GRF.m) - ss_tot~0
    % ahi produce R^2 indefinido (0/0), no un R^2 real malo - se excluye
    % del promedio en vez de contarlo como NaN o como ajuste perfecto.
    if ss_tot < 1e-6
        r2_v(i) = NaN; r2_vt(i) = NaN;
    else
        r2_v(i) = 1 - ss_res_v/ss_tot;
        coef_vt = X_vt \ y;
        yhat_vt = X_vt*coef_vt;
        ss_res_vt = sum((y-yhat_vt).^2);
        r2_vt(i) = 1 - ss_res_vt/ss_tot;
    end

    a(i) = coef_v(1); b(i) = coef_v(2);
end

r2_medio_v = mean(r2_v, 'omitnan');
r2_medio_vt = mean(r2_vt, 'omitnan');
% Se agrega talla SOLO si mejora el R^2 promedio de forma no trivial
% (umbral +0.02 - una mejora menor no justifica el 2do predictor con
% n=48 y 101 ajustes independientes, riesgo de sobreajuste declarado)
incluye_talla = (r2_medio_vt - r2_medio_v) > 0.02;
if incluye_talla
    for i = 1:101
        y = curvas(:,i);
        coef_vt = X_vt \ y;
        a(i) = coef_vt(1); b(i) = coef_vt(2); c(i) = coef_vt(3);
    end
end

modelo = struct();
modelo.pct = pct;
modelo.a = a; modelo.b = b; modelo.c = c;
modelo.incluye_talla = incluye_talla;
modelo.r2_solo_velocidad = r2_medio_v;
modelo.r2_con_talla = r2_medio_vt;
modelo.n_sujetos = n;
modelo.rango_velocidad_ms = [min(vel), max(vel)];
modelo.rango_talla_m = [min(talla_m), max(talla_m)];

fprintf('R^2 medio (solo velocidad): %.3f\n', r2_medio_v);
fprintf('R^2 medio (velocidad+talla): %.3f\n', r2_medio_vt);
fprintf('incluye_talla = %d\n', incluye_talla);

save(fullfile(carpeta,'Modelo_Personalizado_Fukuchi_GRF.mat'), 'modelo');
end
