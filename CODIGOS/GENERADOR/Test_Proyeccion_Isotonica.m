function Test_Proyeccion_Isotonica()
% TEST_PROYECCION_ISOTONICA  02-sep-2026: pruebas del PAVA
% (Proyeccion_Isotonica_Core.m) contra casos con solucion conocida a mano,
% mas verificacion sobre los 3 sujetos reales de Kuopio que hoy tienen
% retrocesos en tobillo X (33, 44, 45).

n_ok = 0; n_total = 0;

% --- Test 1: entrada ya monotona -> debe salir IDENTICA (idempotencia) ---
n_total = n_total+1;
y = [1 2 2 5 7 7 9];
yhat = Proyeccion_Isotonica_Core(y);
if isequal(yhat(:)', y)
    fprintf('Test 1 (idempotencia, ya monotona) PASS\n'); n_ok = n_ok+1;
else
    fprintf('Test 1 FALLO: yhat=%s\n', mat2str(yhat(:)'));
end

% --- Test 2: un solo "diente" hacia abajo, solucion PAVA a mano ---
% y = [1 3 2 4] -> el 3 y el 2 violan orden -> se funden en (3+2)/2=2.5
% resultado esperado: [1 2.5 2.5 4]
n_total = n_total+1;
y = [1 3 2 4];
yhat = Proyeccion_Isotonica_Core(y);
esperado = [1 2.5 2.5 4];
if max(abs(yhat(:)'-esperado)) < 1e-9
    fprintf('Test 2 (diente simple, solucion a mano) PASS\n'); n_ok = n_ok+1;
else
    fprintf('Test 2 FALLO: yhat=%s esperado=%s\n', mat2str(yhat(:)'), mat2str(esperado));
end

% --- Test 3: caida larga en cascada -> todo un bloque se funde (promedio) ---
% y = [5 4 3 2 1] -> estrictamente decreciente -> PAVA da la CONSTANTE = media = 3
n_total = n_total+1;
y = [5 4 3 2 1];
yhat = Proyeccion_Isotonica_Core(y);
if max(abs(yhat(:)' - 3)) < 1e-9
    fprintf('Test 3 (cascada decreciente -> constante = media) PASS\n'); n_ok = n_ok+1;
else
    fprintf('Test 3 FALLO: yhat=%s\n', mat2str(yhat(:)'));
end

% --- Test 4: salida SIEMPRE no-decreciente, para 200 entradas aleatorias ---
n_total = n_total+1;
ok4 = true;
rng(42);
for k = 1:200
    y = randn(1,101)*10 + linspace(0,50,101);  % tendencia + ruido, algunos retrocesos
    yhat = Proyeccion_Isotonica_Core(y);
    if any(diff(yhat) < -1e-9), ok4 = false; break; end
end
if ok4
    fprintf('Test 4 (200 entradas aleatorias, salida SIEMPRE no-decreciente) PASS\n'); n_ok = n_ok+1;
else
    fprintf('Test 4 FALLO: aparecio un retroceso en la iteracion %d\n', k);
end

% --- Test 5: conserva forma fila/columna ---
n_total = n_total+1;
yr = [3 1 2];           % fila
yc = yr(:);              % columna
yhat_r = Proyeccion_Isotonica_Core(yr);
yhat_c = Proyeccion_Isotonica_Core(yc);
if isrow(yhat_r) && iscolumn(yhat_c) && isequal(yhat_r(:), yhat_c(:))
    fprintf('Test 5 (conserva forma fila/columna) PASS\n'); n_ok = n_ok+1;
else
    fprintf('Test 5 FALLO\n');
end

% --- Test 6: distorsion minima cuando el input YA es casi monotono
% (caso real esperado: RMSE del ajuste practicamente no debe cambiar) ---
n_total = n_total+1;
y = linspace(0,100,101);
y(50) = y(50) - 0.001;   % una violacion microscopica
yhat = Proyeccion_Isotonica_Core(y);
d = max(abs(yhat(:)'-y));
if d < 0.01 && ~any(diff(yhat)<0)
    fprintf('Test 6 (violacion microscopica -> distorsion minima, max|delta|=%.5f) PASS\n', d); n_ok = n_ok+1;
else
    fprintf('Test 6 FALLO: max|delta|=%.5f\n', d);
end

% --- Test 7: sobre los 3 sujetos reales de Kuopio con retroceso conocido ---
n_total = n_total+1;
try
    addpath(fileparts(mfilename('fullpath')));
    L = load(fullfile(fileparts(mfilename('fullpath')), 'Ajustar_Warp_Temporal_resultados.mat'));
    ids = [L.S_all.id];
    problema = [33 44 45];
    ok7 = true;
    for pid = problema
        k = find(ids==pid, 1);
        curva = L.PredLOSO.TobX(k,:);
        antes = sum(diff(curva) < 0);
        curva_pava = Proyeccion_Isotonica_Core(curva);
        despues = sum(diff(curva_pava) < 0);
        rmse_cambio = sqrt(mean((curva_pava-curva).^2));
        fprintf('  sujeto %d: retrocesos antes=%d despues=%d (cambio RMSE=%.4fcm)\n', ...
            pid, antes, despues, rmse_cambio);
        if despues ~= 0, ok7 = false; end
    end
    if ok7
        fprintf('Test 7 (sujetos reales 33/44/45, retrocesos -> 0 tras PAVA) PASS\n'); n_ok = n_ok+1;
    else
        fprintf('Test 7 FALLO: algun sujeto sigue con retroceso tras PAVA\n');
    end
catch ME
    fprintf('Test 7 SALTADO (no se pudo cargar Ajustar_Warp_Temporal_resultados.mat): %s\n', ME.message);
    n_total = n_total - 1;
end

% --- Test 8: PAVA PONDERADO con peso grande en el ultimo punto -> lo
% deja PRACTICAMENTE fijo (protege el avance final, para la monotonia
% en talla), mientras sigue garantizando monotonia en el tiempo ---
n_total = n_total+1;
y = [1 5 2 8 3 10];      % con retroceso justo antes del final
w = ones(1,6); w(end) = 1e12;
yhat = Proyeccion_Isotonica_Core(y, w);
ok8 = abs(yhat(end)-y(end)) < 1e-6 && ~any(diff(yhat)<0);
if ok8
    fprintf('Test 8 (peso grande fija el ultimo punto, sigue monotona) PASS (yhat(end)=%.6f)\n', yhat(end)); n_ok = n_ok+1;
else
    fprintf('Test 8 FALLO: yhat=%s\n', mat2str(yhat));
end

% --- Test 9: sin pesos (default) da EXACTAMENTE lo mismo que antes
% (no cambia el comportamiento ya validado en los Tests 1-7) ---
n_total = n_total+1;
y = [1 3 2 4];
yhat_sin_w = Proyeccion_Isotonica_Core(y);
yhat_w1 = Proyeccion_Isotonica_Core(y, ones(size(y)));
if isequal(yhat_sin_w, yhat_w1)
    fprintf('Test 9 (default == pesos todos 1, sin regresion) PASS\n'); n_ok = n_ok+1;
else
    fprintf('Test 9 FALLO\n');
end

fprintf('\n=== %d/%d PASS ===\n', n_ok, n_total);

end
