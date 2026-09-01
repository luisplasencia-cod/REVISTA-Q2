function Comparar_Variantes_Plantilla_Fukuchi()
% COMPARAR_VARIANTES_PLANTILLA_FUKUCHI  29-ago-2026: prueba variantes de
% la plantilla/regresion de GRF de Fukuchi (edad, piernas L+R, masa) y
% valida CADA UNA contra Kuopio real - mismo criterio de toda la sesion:
% no asumir que "más sofisticado" es mejor, medirlo.
carpeta = fileparts(mfilename('fullpath'));
addpath(fullfile(carpeta,'RODILLA','Fukuchi'));
addpath(fullfile(carpeta,'RODILLA','Kuopio'));

% --- Cargar los 42 sujetos, ambas piernas, con todos los covariables ---
edad = nan(42,1); talla_m = nan(42,1); masa_kg = nan(42,1);
curvaR = nan(42,101); curvaL = nan(42,101); velR = nan(42,1); velL = nan(42,1);
for sid = 1:42
    try
        SR = Cargar_Fukuchi2018_GRF_Core(sid, struct('pierna','R'));
        SL = Cargar_Fukuchi2018_GRF_Core(sid, struct('pierna','L'));
    catch
        continue
    end
    edad(sid)=SR.edad_anios; talla_m(sid)=SR.talla_cm/100; masa_kg(sid)=SR.masa_kg;
    curvaR(sid,:)=SR.GRF_vertical_pctBW; velR(sid)=SR.speed_ms;
    curvaL(sid,:)=SL.GRF_vertical_pctBW; velL(sid)=SL.speed_ms;
end
ok = ~any(isnan(curvaR),2);

% --- Sujetos reales de Kuopio para validar (mismo set de siempre) ---
ids_kuopio = [1,4,13,19,22,25,28,31,37,40,43,46,49];

variantes = {};

% Variante A: baseline ya conocido (solo R, N=42, plantilla plana)
variantes{end+1} = construir_variante('A: R, N=42, plana', ok, edad, talla_m, masa_kg, curvaR, velR, [], 'plana');
% Variante B: R+L combinados (N=84), plantilla plana
ok2 = [ok; ok]; edad2=[edad;edad]; talla2=[talla_m;talla_m]; masa2=[masa_kg;masa_kg];
curva2 = [curvaR; curvaL]; vel2 = [velR; velL];
variantes{end+1} = construir_variante('B: R+L, N=84, plana', ok2, edad2, talla2, masa2, curva2, vel2, [], 'plana');
% Variante C: solo jovenes (<40), R, plantilla plana
okY = ok & edad<40;
variantes{end+1} = construir_variante('C: R, solo jovenes N=24, plana', okY, edad, talla_m, masa_kg, curvaR, velR, [], 'plana');
% Variante D: solo jovenes, R+L (N=48), plantilla plana
okY2 = ok2 & edad2<40;
variantes{end+1} = construir_variante('D: R+L, solo jovenes N=48, plana', okY2, edad2, talla2, masa2, curva2, vel2, [], 'plana');
% Variante E: R+L, N=84, personalizada por velocidad+talla
variantes{end+1} = construir_variante('E: R+L N=84, personalizada v+talla', ok2, edad2, talla2, masa2, curva2, vel2, [], 'regresion');
% Variante F: R+L, solo jovenes N=48, personalizada v+talla
variantes{end+1} = construir_variante('F: R+L jovenes N=48, personalizada v+talla', okY2, edad2, talla2, masa2, curva2, vel2, [], 'regresion');
% Variante G: R+L N=84, personalizada v+talla+masa
variantes{end+1} = construir_variante('G: R+L N=84, personalizada v+talla+masa', ok2, edad2, talla2, masa2, curva2, vel2, 'masa', 'regresion');
% Variante H: R+L jovenes N=48, personalizada v+talla+masa
variantes{end+1} = construir_variante('H: R+L jovenes N=48, personalizada v+talla+masa', okY2, edad2, talla2, masa2, curva2, vel2, 'masa', 'regresion');

for i = 1:numel(variantes)
    v = variantes{i};
    [r_medio, rmse_medio] = validar_contra_kuopio(v, ids_kuopio);
    fprintf('%-45s n=%3d  r=%.3f  RMSE=%.1f%%BW\n', v.nombre, v.n, r_medio, rmse_medio);
end

end

% ======================================================================
function v = construir_variante(nombre, mask, edad, talla_m, masa_kg, curva, vel, extra_pred, tipo)
v = struct('nombre', nombre, 'tipo', tipo, 'n', sum(mask));
c = curva(mask,:); ve = vel(mask); ta = talla_m(mask); ma = masa_kg(mask);
v.pct = 0:100;
if strcmp(tipo, 'plana')
    v.media = mean(c,1);
else
    n = size(c,1);
    if strcmp(extra_pred, 'masa')
        X = [ones(n,1), ve, ta, ma];
    else
        X = [ones(n,1), ve, ta];
    end
    coef = nan(size(X,2), 101);
    for i = 1:101
        coef(:,i) = X \ c(:,i);
    end
    v.coef = coef;
    v.extra_pred = extra_pred;
    v.rango_v = [min(ve), max(ve)];
    v.rango_talla = [min(ta), max(ta)];
    v.rango_masa = [min(ma), max(ma)];
end
end

% ======================================================================
function [r_medio, rmse_medio] = validar_contra_kuopio(v, ids_kuopio)
rs = []; rmses = [];
for sid = ids_kuopio
    try
        S = Cargar_Kuopio2024_Core(sid);
        R = Extraer_GRF_Kuopio_Core(sid);
    catch
        continue
    end
    if R.n_pasos_validos == 0, continue; end
    if strcmp(v.tipo, 'plana')
        pred_pctBW = v.media;
    else
        if strcmp(v.extra_pred, 'masa')
            pred_pctBW = v.coef(1,:) + v.coef(2,:)*S.speed_ms + v.coef(3,:)*(S.talla_cm/100) + v.coef(4,:)*S.masa_kg;
        else
            pred_pctBW = v.coef(1,:) + v.coef(2,:)*S.speed_ms + v.coef(3,:)*(S.talla_cm/100);
        end
        pred_pctBW = max(pred_pctBW, 0);
    end
    pred = interp1(v.pct, pred_pctBW, R.pct_ciclo, 'pchip');
    for ip = 1:R.n_pasos_validos
        real_i = R.Fz_pctBW_todos(ip,:);
        ok = ~isnan(real_i) & R.pct_ciclo <= 55;
        if sum(ok) < 10, continue; end
        rs(end+1) = corr(pred(ok)', real_i(ok)'); %#ok<AGROW>
        rmses(end+1) = sqrt(mean((pred(ok)-real_i(ok)).^2)); %#ok<AGROW>
    end
end
r_medio = mean(rs, 'omitnan');
rmse_medio = mean(rmses, 'omitnan');
end
