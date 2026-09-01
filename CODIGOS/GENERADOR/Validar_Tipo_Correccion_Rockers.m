function T = Validar_Tipo_Correccion_Rockers()
% VALIDAR_TIPO_CORRECCION_ROCKERS  30-ago-2026: responde dos preguntas del
%                   usuario sobre el residuo de rockers, con dato real y
%                   LOSO, en vez de con argumento:
%
%   (1) MAGNITUD: cuanto vale la correccion frente a lo que hay ANTES de
%       corregir, punto por punto del apoyo (no solo el rango global que
%       ya reporta la Sec. 8.4 del informe).
%
%   (2) VALIDEZ DEL TIPO: se compara el tipo de correccion vigente
%       (ADITIVA FIJA: misma curva de cm para todos) contra dos
%       alternativas plausibles, todas evaluadas con el MISMO protocolo
%       LOSO (el residuo de cada sujeto se predice con los OTROS, nunca
%       con el propio):
%         A) aditiva fija         : resid_i = mean(resid_otros)
%         B) aditiva escalada por talla : resid_i = mean(resid_otros/talla_otros)*talla_i
%         C) aditiva escalada por long. de pierna : idem con long_pierna
%       Si (B) o (C) ganaran claramente, el residuo deberia escalarse por
%       antropometria en vez de ser una curva fija - eso cambiaria el
%       modelo, y por eso se mide antes de afirmar que la version fija es
%       la correcta.
%
%   CRITERIO: RMSE del residuo PREDICHO vs. el residuo REAL del sujeto
%   dejado afuera, en el tramo de apoyo. Menor es mejor.
%
% SALIDA: tabla por sujeto + resumen impreso.
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
dir_kuopio = fullfile(carpeta, 'RODILLA', 'Kuopio');
addpath(carpeta); addpath(dir_kuopio);

ids = [1,4,13,19,22,25,28,31,37,40,43,46,49];
PCT_APOYO = 61;   % 0:60% del ciclo, misma convencion que el resto del proyecto

Xres = []; Yres = []; talla_m = []; Lpierna_m = []; ids_ok = [];
for sid = ids
    try
        S = Cargar_Kuopio2024_Core(sid);
        Xres(end+1,:) = S.x_horiz_tobillo_cm(1:PCT_APOYO); %#ok<AGROW>
        Yres(end+1,:) = S.y_vert_tobillo_cm(1:PCT_APOYO);  %#ok<AGROW>
        talla_m(end+1) = S.talla_cm/100;                    %#ok<AGROW>
        Lpierna_m(end+1) = (S.muslo_mm + S.tibia_mm)/1000;  %#ok<AGROW>
        ids_ok(end+1) = sid;                                %#ok<AGROW>
    catch
        continue
    end
end
n = numel(ids_ok);

rmse = @(a,b) sqrt(mean((a-b).^2));
rmse_x = nan(n,3); rmse_y = nan(n,3);

for i = 1:n
    otros = setdiff(1:n, i);

    % (A) aditiva fija: promedio crudo de los otros
    predA_x = mean(Xres(otros,:), 1);
    predA_y = mean(Yres(otros,:), 1);

    % (B) aditiva escalada por TALLA: se normaliza cada residuo por la
    % talla de su propio sujeto, se promedia, y se re-escala a la talla
    % del sujeto dejado afuera
    predB_x = mean(Xres(otros,:) ./ talla_m(otros)', 1) * talla_m(i);
    predB_y = mean(Yres(otros,:) ./ talla_m(otros)', 1) * talla_m(i);

    % (C) aditiva escalada por LONGITUD DE PIERNA (muslo+tibia medidos)
    predC_x = mean(Xres(otros,:) ./ Lpierna_m(otros)', 1) * Lpierna_m(i);
    predC_y = mean(Yres(otros,:) ./ Lpierna_m(otros)', 1) * Lpierna_m(i);

    rmse_x(i,:) = [rmse(Xres(i,:),predA_x), rmse(Xres(i,:),predB_x), rmse(Xres(i,:),predC_x)];
    rmse_y(i,:) = [rmse(Yres(i,:),predA_y), rmse(Yres(i,:),predB_y), rmse(Yres(i,:),predC_y)];
end

T = table(ids_ok', talla_m', Lpierna_m', rmse_x(:,1), rmse_x(:,2), rmse_x(:,3), ...
    rmse_y(:,1), rmse_y(:,2), rmse_y(:,3), 'VariableNames', ...
    {'sub_id','talla_m','Lpierna_m','rmseX_fija','rmseX_talla','rmseX_pierna', ...
     'rmseY_fija','rmseY_talla','rmseY_pierna'});

fprintf('\n=== VALIDEZ DEL TIPO DE CORRECCION (LOSO, N=%d, tramo de apoyo) ===\n', n);
fprintf('RMSE del residuo predicho vs. residuo REAL del sujeto dejado afuera (menor=mejor)\n\n');
fprintf('  Tipo de correccion            X [cm]     Y [cm]\n');
fprintf('  (A) aditiva fija              %6.3f     %6.3f\n', mean(rmse_x(:,1)), mean(rmse_y(:,1)));
fprintf('  (B) escalada por talla        %6.3f     %6.3f\n', mean(rmse_x(:,2)), mean(rmse_y(:,2)));
fprintf('  (C) escalada por long.pierna  %6.3f     %6.3f\n', mean(rmse_x(:,3)), mean(rmse_y(:,3)));

% --- Magnitud punto a punto: residuo vs. variabilidad real entre sujetos ---
sd_x = std(Xres, 0, 1); sd_y = std(Yres, 0, 1);
mu_x = mean(Xres,1);    mu_y = mean(Yres,1);
fprintf('\n=== MAGNITUD DEL RESIDUO vs. LA VARIABILIDAD REAL ENTRE SUJETOS ===\n');
fprintf('X: residuo medio |mu|=%.2fcm | SD entre sujetos=%.2fcm | razon |mu|/SD=%.2f\n', ...
    mean(abs(mu_x)), mean(sd_x), mean(abs(mu_x))/mean(sd_x));
fprintf('Y: residuo medio |mu|=%.2fcm | SD entre sujetos=%.2fcm | razon |mu|/SD=%.2f\n', ...
    mean(abs(mu_y)), mean(sd_y), mean(abs(mu_y))/mean(sd_y));
fprintf('(razon > 1 => el residuo comun es mayor que la dispersion individual:\n');
fprintf(' aplicar una curva fija a todos es defendible. razon < 1 => la\n');
fprintf(' diferencia entre sujetos domina y una curva unica pierde sentido.)\n');

writematrix([ (0:PCT_APOYO-1)' , mu_x', sd_x', mu_y', sd_y' ], ...
    fullfile(carpeta, 'Validar_Tipo_Correccion_Rockers_curvas.csv'));
writetable(T, fullfile(carpeta, 'Validar_Tipo_Correccion_Rockers_resultados.csv'));
fprintf('\nTablas: Validar_Tipo_Correccion_Rockers_{resultados,curvas}.csv\n');

end
