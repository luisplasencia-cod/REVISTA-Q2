% ===================================================
% PRUEBA AUTOMATIZADA - CALIBRACION_OFFSET_CORE CON DATOS SINTETICOS
% ===================================================
% Genera archivos .txt sinteticos con el mismo formato que exporta el
% AMTI (6 columnas separadas por coma, Fz en columna 3, ~1000 Hz),
% simulando una relacion offset(mm) -> Fz(N) CONOCIDA de antemano, y
% verifica que Calibracion_Offset_Core.m la recupere correctamente.
%
% No usa dialogos - pensado para correr sin intervencion y confirmar
% que el pipeline completo (lectura, filtrado, deteccion de meseta
% estable, regresion, prediccion inversa) funciona antes de tener
% datos reales del simulador.
% ===================================================

clc; clear; close all;

%% ---- CARPETA DE SALIDA (scratchpad, no es parte del repo del proyecto) ----
out_dir = 'C:\Users\chees\AppData\Local\Temp\claude\C--GAITSIM\92d083a2-3200-45db-906e-527d38dcbec4\scratchpad\datos_sinteticos_offset';
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

%% ---- "VERDAD CONOCIDA" QUE EL SCRIPT DEBE RECUPERAR ----
peso_ref_kg   = 20;                  % carga de referencia
Fz_esperado_N = peso_ref_kg * 9.81;  % = 196.2 N

pendiente_real_N_mm = 15;            % rigidez estructural simulada (N/mm)
offset_optimo_real_mm = 6.3;         % offset "verdadero" que el ajuste deberia recuperar
intercepto_real_N = Fz_esperado_N - pendiente_real_N_mm*offset_optimo_real_mm;

fprintf('Verdad conocida simulada:\n');
fprintf('  Fz(N) = %.4f + %.4f * offset(mm)\n', intercepto_real_N, pendiente_real_N_mm);
fprintf('  Offset optimo real = %.2f mm\n\n', offset_optimo_real_mm);

%% ---- PARAMETROS DE GENERACION ----
fs = 1000;
duracion_s = 6;                      % 1s de transitorio + 5s de meseta
t = (0:1/fs:duracion_s-1/fs)';
N = length(t);

offsets_prueba = [-10 -5 0 5 10 15];  % mm, inventados para la prueba
repeticiones   = 3;
ruido_sd_N     = 2.0;                 % ruido gaussiano en la meseta (N)
tau_asentamiento_s = 0.3;             % constante de tiempo del transitorio de asentamiento

rng(42);  % reproducibilidad de la prueba

archivos_generados = {};
for oi = 1:length(offsets_prueba)
    off = offsets_prueba(oi);
    Fz_teorico = intercepto_real_N + pendiente_real_N_mm*off;

    for rep = 1:repeticiones
        % Transitorio de asentamiento (exponencial) + meseta con ruido
        transitorio = Fz_teorico * (1 - exp(-t/tau_asentamiento_s));
        ruido = ruido_sd_N * randn(N,1);
        Fz_sim = transitorio + ruido;
        Fz_sim(t < 3*tau_asentamiento_s) = transitorio(t < 3*tau_asentamiento_s) + ruido(t < 3*tau_asentamiento_s)*0.3; % menos ruido durante el asentamiento, mas realista

        % Los archivos reales del proyecto (SIMULADOR/FUERZA GRF - SIM)
        % quedan por debajo de 500 en crudo, o sea estan en lbf antes de
        % la conversion de Calibracion_Offset_Core.m. Para que la prueba
        % sea realista (y para exponer bugs de unidades, como paso aqui
        % en el primer intento), se simula lo mismo: se escribe en lbf.
        Fz_export = Fz_sim / 4.44822;

        otras_cols = zeros(N,5);  % Fx,Fy,Mx,My,Mz simulados en cero + ruido pequeno
        otras_cols = otras_cols + 0.1*randn(N,5);

        M = [otras_cols(:,1), otras_cols(:,2), Fz_export, otras_cols(:,3:5)];

        fname = sprintf('Offset_%+d_%d.txt', off, rep);
        fpath = fullfile(out_dir, fname);
        fid = fopen(fpath, 'w');
        for k = 1:N
            fprintf(fid, '%.4f, %.4f, %.4f, %.4f, %.4f, %.4f,\n', M(k,1), M(k,2), M(k,3), M(k,4), M(k,5), M(k,6));
        end
        fclose(fid);
        archivos_generados{end+1} = fname; %#ok<AGROW>
    end
end

fprintf('%d archivos sinteticos generados en: %s\n\n', numel(archivos_generados), out_dir);

%% ---- CORRER EL ANALISIS REAL SOBRE LOS DATOS SINTETICOS ----
opciones = struct('umbral_variabilidad_N', 3.0*2.5, 'guardar_en', out_dir, 'graficar', true);
% (umbral relajado a 2.5x el ruido simulado, ya que aqui SI conocemos el
% ruido real del generador; con datos reales del AMTI hay que recalibrar
% este umbral con el ruido real del instrumento)

resultado = Calibracion_Offset_Core(out_dir, peso_ref_kg, opciones);

%% ---- VERIFICACION: ¿SE RECUPERO LA VERDAD CONOCIDA? ----
fprintf('\n==================================================================\n');
fprintf('VERIFICACION CONTRA LA VERDAD CONOCIDA\n');
fprintf('==================================================================\n');
fprintf('Pendiente:      real = %.4f N/mm | estimada = %.4f N/mm | dentro de IC95%%: %s\n', ...
    pendiente_real_N_mm, resultado.b1, ...
    string(pendiente_real_N_mm >= resultado.CI_b1(1) && pendiente_real_N_mm <= resultado.CI_b1(2)));
fprintf('Intercepto:     real = %.4f N    | estimado = %.4f N    | dentro de IC95%%: %s\n', ...
    intercepto_real_N, resultado.b0, ...
    string(intercepto_real_N >= resultado.CI_b0(1) && intercepto_real_N <= resultado.CI_b0(2)));
fprintf('Offset optimo:  real = %.2f mm   | estimado = %.2f mm   | dentro de IC95%%: %s\n', ...
    offset_optimo_real_mm, resultado.offset_optimo_mm, ...
    string(offset_optimo_real_mm >= resultado.CI95_offset_optimo(1) && offset_optimo_real_mm <= resultado.CI95_offset_optimo(2)));
fprintf('R^2 = %.4f (deberia ser alto, la relacion simulada es lineal por construccion)\n', resultado.R2);
if resultado.lof.disponible
    fprintf('Falta de ajuste: p = %.3f (deberia ser NO significativo, ya que el generador es lineal)\n', resultado.lof.p);
end
fprintf('==================================================================\n');
fprintf('\nListo. Revisa las figuras generadas (curva de calibracion + diagnostico de residuos)\n');
fprintf('y el CSV/PNG exportados en: %s\n', out_dir);
