function out = Romero_Sorozabal2024_Core(v_kph, l_m, opciones)
% ROMERO_SOROZABAL2024_CORE  Genera trayectorias 3D (posicion, no angulo)
%                   de cadera, rodilla y tobillo, relativas a la pelvis,
%                   con el metodo de Romero-Sorozabal, Delgado-Oleas,
%                   Laudanski, Gutierrez & Rocon 2024 (Biomimetics 9(6):352,
%                   DOI 10.3390/biomimetics9060352, MDPI, acceso abierto):
%                   regresion robusta (peso bicuadrado) sobre 66 "key-points"
%                   (posicion t%ciclo + posicion y en cada eje), YA
%                   PUBLICADOS (Tablas A1-A3 del apendice) - sin ajustar
%                   ningun coeficiente (regla P-23, docs/DISCUSION_Q2.md).
%                   Reconstruccion final por spline cubico entre key-points
%                   (mismo metodo declarado en el paper, Sec.2.3.3 - a
%                   diferencia de Koopman2014_Core.m, el paper NO publica
%                   derivadas en los key-points, solo (t,y), asi que la
%                   interpolacion aqui es spline cubico simple, no Hermite
%                   quintico).
%
%   out = Romero_Sorozabal2024_Core(v_kph, l_m)
%   out = Romero_Sorozabal2024_Core(v_kph, l_m, opciones)
%
% ENTRADA
%   v_kph   velocidad de marcha (km/h). Rango del dataset (Fukuchi et al.
%           2018, ambas cohortes): 1.29-8.02 kph (Discussion, Sec.4).
%   l_m     talla corporal (m). Rango del dataset: 1.47-1.92 m.
%   opciones (struct opcional):
%     .nMuestras   puntos por ciclo, 0-100% (default 101)
%
% SALIDA: struct `out` con 3 campos (uno por articulacion: .cadera,
%   .rodilla, .tobillo), cada uno con .pct_ciclo (1 x nMuestras) y
%   POSICION 3D relativa a la pelvis (P), EN LA CONVENCION NATIVA DEL
%   PAPER (Fig.1: X=plano sagital/avance, Y=mediolateral, Z=vertical,
%   NEGATIVO por debajo de la pelvis):
%     .x_m, .y_m, .z_m   (1 x nMuestras), metros
%   Ademas, por conveniencia de lectura (no cambia el signo fuente):
%     .z_abajo_pelvis_m = -z_m   (positivo = distancia por debajo de la
%     pelvis, mas intuitivo para verificar contra Fig.2b/3a del paper,
%     donde cadera esta cerca de 0, tobillo cerca de 1m por debajo).
%
%   ADVERTENCIA DE CONVENCION (igual que Koopman2014_Core.m/Yun2014_Wrapper.m
%   con sus signos de tobillo): el eje X de este paper (plano sagital) NO
%   esta verificado contra la convencion "x=avance, positivo hacia adelante"
%   que usa el resto del proyecto (Cargar_Camargo_Core.m,
%   Segmento_Posicion_Core.m) - el paper no declara el signo de avance
%   explicitamente en el texto, solo en la Fig.1 (diagrama). NO combinar
%   con los otros 3 candidatos sin revisar el signo de X primero (mismo
%   patron de advertencia que GUIA_INTERPRETACION.md #3 ya usa para
%   Koopman/Yun/Zhao).
%
%   ANOMALIA CONOCIDA, SIN RESOLVER - Z DE RODILLA Y TOBILLO NO SE USAN EN
%   EL ENSAMBLE (decision del usuario, 24-ago-2026, ver
%   plan_ensamble_multimodelo.md Sec.2.1-bis): beta3(altura) de las Tablas
%   A2-Z y A3-Z produce una profundidad vertical (pelvis->rodilla,
%   pelvis->tobillo) sistematicamente ~2x mayor a lo esperado por las
%   fracciones antropometricas de Winter/Drillis&Contini (las MISMAS que
%   ya usa Estimar_Antropometria_Core.m de este proyecto) - verificado con
%   DOS chequeos independientes: (1) distancia absoluta pelvis-articulacion,
%   (2) longitud de segmento (diferencia entre articulaciones adyacentes,
%   que cancela cualquier supuesto sobre donde esta exactamente el marcador
%   de pelvis). Los dos dan el mismo factor ~2x. Se re-extrajo la tabla
%   desde la pagina HTML de MDPI (fuente independiente del PDF ya usado) y
%   coincide exacto - NO es un error de transcripcion. No existe fe de
%   erratas ni repositorio de datos/codigo publico de los autores. Cadera
%   (hip) Z SI es consistente con lo esperado, no tiene este problema.
%   DECISION: out.rodilla.z_m/y_abajo_pelvis_m y out.tobillo.z_m/etc. se
%   calculan y quedan disponibles (fieles a la tabla publicada, no se
%   inventan valores "corregidos"), pero Combinar_Candidatos_Core.m NO los
%   usa - el ensamble solo toma el eje X (sagital) de este candidato.
%
% Fuente: docs/literatura/pdfs/RomeroSorozabal2024_Biomimetics.pdf,
% Tablas A1 (cadera), A2 (rodilla), A3 (tobillo) - verificadas a texto
% completo 24-ago-2026 (ver docs/planificacion/plan_ensamble_multimodelo.md
% Sec.2.1). Los "-" de la fuente (coeficiente no reportado/no aplicable)
% se tratan como 0, mismo criterio que Koopman2014_Core.m.
%
% ADVERTENCIA DE UNIDADES (encontrada empiricamente, NO declarada de forma
% explicita en el texto del paper): la variable "v" de la Ec.1 (Sec.2.3.2)
% debe evaluarse en m/s, NO en km/h (a diferencia de Koopman2014_Core.m,
% que si usa km/h directo). Se detecto porque, con v en km/h, el parametro
% de TIEMPO (t, %ciclo) de varios key-points salia no-monotono y hasta por
% encima de 100% incluso para la talla/velocidad medianas del propio
% dataset (171cm/4.6kph) - incompatible con el RMSE de t reportado
% (0.6-13.17%, Sec.3.1). Con v convertida a m/s (v_kph/3.6), los t_key
% quedan monotonos y cercanos a beta0 (ver diagnostico de la sesion
% 24-ago-2026, plan_ensamble_multimodelo.md). La Fig.3b del paper rotula
% su eje "Gait Speed [km/h]" solo para lectura visual - no implica que la
% regresion interna se haya ajustado en esas unidades. Aplica tanto a la
% regresion de t como a la de y (misma Ec.1 para ambas, Sec.2.3.2).
% ==========================================================================

if nargin < 3, opciones = struct(); end
if ~isfield(opciones,'nMuestras'), opciones.nMuestras = 101; end

if ~(isnumeric(v_kph) && isscalar(v_kph) && v_kph > 0)
    error('v_kph debe ser un escalar positivo (velocidad en km/h). Se recibio: %s', mat2str(v_kph));
end
if ~(isnumeric(l_m) && isscalar(l_m) && l_m > 0)
    error('l_m debe ser un escalar positivo (talla corporal en metros). Se recibio: %s', mat2str(l_m));
end
if v_kph < 1.29 || v_kph > 8.02
    warning('RomeroSorozabal2024:rangoVelocidad', ...
        'v_kph=%.2f fuera del rango validado por el dataset (1.29-8.02 kph, Fukuchi et al. 2018). Extrapolacion.', v_kph);
end
if l_m < 1.47 || l_m > 1.92
    warning('RomeroSorozabal2024:rangoTalla', ...
        'l_m=%.3f fuera del rango validado por el dataset (1.47-1.92 m). Extrapolacion.', l_m);
end

tablas = tablas_romero_sorozabal();
pct_ciclo = linspace(0, 100, opciones.nMuestras);

out = struct();
nombres_art = {'cadera','rodilla','tobillo'};
for a = 1:numel(tablas)
    T = tablas(a);
    art = struct('pct_ciclo', pct_ciclo);
    ejes = {'X','Y','Z'};
    campo_salida = {'x_m','y_m','z_m'};
    for e = 1:3
        Ax = T.(ejes{e});
        y_curva = reconstruir_curva(Ax, v_kph, l_m, pct_ciclo);
        art.(campo_salida{e}) = y_curva;
    end
    art.z_abajo_pelvis_m = -art.z_m;
    out.(nombres_art{a}) = art;
end

end

% ==========================================================================
function y_curva = reconstruir_curva(Ax, v, l, pct_ciclo)
% Ax.coef_t (N x 4), Ax.coef_y (N x 4). Primer key-point: t fijo=1 (Heel
% contact). Ultimo key-point: t fijo=100 (End of the gait cycle). Los
% intermedios: t = regresion(coef_t). TODOS los key-points (incluidos el
% 1ro y el ultimo): y = regresion(coef_y). Reconstruccion: spline cubico
% simple (Sec.2.3.3 del paper - no hay derivadas publicadas, a diferencia
% de Koopman).

v_ms = v / 3.6; % ver advertencia de unidades en el encabezado del archivo

N = size(Ax.coef_t, 1);
t_key = zeros(1, N);
y_key = zeros(1, N);
for i = 1:N
    if i == 1
        t_key(i) = 1;
    elseif i == N
        t_key(i) = 100;
    else
        t_key(i) = evaluar_regresion(Ax.coef_t(i,:), v_ms, l);
    end
    y_key(i) = evaluar_regresion(Ax.coef_y(i,:), v_ms, l);
end

[t_key, orden] = sort(t_key);
y_key = y_key(orden);

y_curva = ppval(spline(t_key, y_key), pct_ciclo);

end

% ==========================================================================
function val = evaluar_regresion(coef, v, l)
% coef = [b0 b1(v) b2(v^2) b3(l)] - "-" de la fuente ya transcrito como 0.
val = coef(1) + coef(2)*v + coef(3)*v^2 + coef(4)*l;
end

% ==========================================================================
function tablas = tablas_romero_sorozabal()
% Coeficientes YA PUBLICADOS (Romero-Sorozabal et al. 2024, Tablas A1-A3,
% verificados a texto completo el 24-ago-2026). Cada tabla (cadera/
% rodilla/tobillo) tiene 3 sub-tablas (X,Y,Z), cada una con coef_t
% (N_ejeX4) y coef_y (N_ejeX4). N varia por eje (numero de key-points
% distinto segun complejidad de la trayectoria, Sec.2.3.1 del paper).

% ---------------- Tabla A1: CADERA ----------------
Hip = struct();

% Cadera X (6 key-points)
Hip.X.coef_t = [ 1.00     0       0      0;
                 7.61     5.46   -1.86  -4.90;
                21.02    -7.41    2.36  -0.46;
                64.37   -20.42    6.66   6.08;
                71.10     0.64   -1.84   7.09;
               100        0       0      0];
Hip.X.coef_y = [ 0.03     0.03    0     -0.04;
                 0.02     0.03   -0.01  -0.02;
                 0.02     0.01    0     -0.02;
                 0        0.02   -0.02  -0.02;
                -0.02     0.04   -0.02   0;
                 0.03     0.03    0     -0.04];

% Cadera Y (8 key-points)
Hip.Y.coef_t = [ 1.00     0       0      0;
                 8.84     6.50   -1.47  -2.41;
                24.53    -5.35    3.50   1.20;
                37.50   -15.19    7.75   5.52;
                58.89    -5.47    3.19  -5.74;
                78.90     3.73   -1.10 -15.52;
                95.94    -7.92    3.56  -2.14;
               100        0       0      0];
Hip.Y.coef_y = [-0.17     0.01    0     -0.03;
                -0.17     0       0     -0.02;
                -0.16     0       0     -0.02;
                -0.16    -0.01    0     -0.02;
                -0.17    -0.01    0.01   0;
                -0.18     0.01    0     -0.02;
                -0.18     0.01    0     -0.02;
                -0.17     0.01    0     -0.03];

% Cadera Z (9 key-points)
Hip.Z.coef_t = [ 1.00     0       0      0;
                11.72    -3.63    1.10   3.10;
                34.72    -0.22   -0.41  -1.06;
                41.51    -5.41    2.32   1.48;
                54.43     0.72   -1.20  -2.40;
                72.00   -12.51    4.99   4.05;
                80.73    -5.01    2.29   0.62;
                91.27    -1.41    1.18  -3.13;
               100        0       0      0];
Hip.Z.coef_y = [-0.06    -0.01    0     -0.10;
                -0.05     0.01    0     -0.12;
                -0.07     0.01    0     -0.11;
                -0.05     0       0     -0.13;
                -0.05     0.01    0     -0.13;
                -0.05    -0.02    0     -0.12;
                -0.05    -0.01    0     -0.12;
                -0.05    -0.01    0     -0.12;
                -0.06    -0.01    0     -0.10];

% ---------------- Tabla A2: RODILLA ----------------
Knee = struct();

% Rodilla X (7 key-points)
Knee.X.coef_t = [ 1.00     0       0      0;
                  3.00     0       0      0;
                  5.20    -9.52    6.33 -14.31;
                 29.98    -2.57    0.71   0.93;
                 59.08    -7.07    1.81  -0.46;
                 75.94    -6.09    1.26  -4.99;
                100        0       0      0];
Knee.X.coef_y = [-0.02     0.09   -0.01   0.11;
                 -0.03     0.10   -0.02   0.12;
                  0        0.08   -0.01   0.12;
                 -0.08     0.04   -0.02   0.08;
                 -0.09    -0.03   -0.01   0.03;
                  0        0.03   -0.03   0.01;
                 -0.01     0.09   -0.01   0.11];

% Rodilla Y (5 key-points)
Knee.Y.coef_t = [ 1.00     0       0      0;
                 30.02    -1.11    0.28   8.23;
                 41.73    14.48   -7.91  37.34;
                 58.46    -6.93   -0.22  10.27;
                100        0       0      0];
Knee.Y.coef_y = [-0.11     0.03   -0.01  -0.07;
                 -0.08    -0.02    0.01  -0.03;
                 -0.15     0.03   -0.01  -0.06;
                 -0.12     0.01    0     -0.04;
                 -0.11     0.03   -0.01  -0.07];

% Rodilla Z (10 key-points)
Knee.Z.coef_t = [ 1.00     0       0      0;
                  2.86     3.15   -0.77  -1.96;
                  6.28     5.74   -1.27  -4.89;
                 18.29    -0.80    0.32   1.72;
                 27.54    -5.80    1.44   9.67;
                 57.28    -1.98   -0.15  -1.37;
                 68.39    -3.10    0.60  -6.33;
                 72.50    -5.80    1.93  -3.10;
                 88.92    -1.24    1.42  -3.51;
                100        0       0      0];
Knee.Z.coef_y = [-0.02     0.01    0     -0.57;
                 -0.02     0.01    0     -0.57;
                 -0.04     0.02    0     -0.57;
                 -0.03     0.02    0     -0.57;
                 -0.03     0.02    0     -0.56;
                 -0.02     0.01    0     -0.59;
                  0       -0.01    0     -0.61;
                 -0.02     0       0     -0.59;
                  0.01     0.02    0     -0.63;
                  0       -0.01    0.01  -0.60];

% ---------------- Tabla A3: TOBILLO ----------------
Ankle = struct();

% Tobillo X (6 key-points)
Ankle.X.coef_t = [ 1.00     0       0      0;
                   33.37   -5.87    1.48   1.32;
                   65.98  -11.19    2.77   2.53;
                   77.19    9.27   -3.17   3.26;
                   93.19    2.67   -0.82   1.92;
                  100        0       0      0];
Ankle.X.coef_y = [-0.03     0.20   -0.04   0.14;
                  -0.01     0.04   -0.03  -0.07;
                   0       -0.12    0     -0.25;
                  -0.17     0.28   -0.09   0.08;
                   0        0.19   -0.04   0.14;
                  -0.03     0.20   -0.05   0.14];

% Tobillo Y (7 key-points)
Ankle.Y.coef_t = [ 1.00     0       0      0;
                   12.28    0.64    0.15   6.50;
                   24.33    1.09    0.41  12.84;
                   66.48   -5.59   -0.23   7.31;
                   82.66   -1.33   -0.46  -0.26;
                   93.81    4.64   -1.34  -3.77;
                  100        0       0      0];
Ankle.Y.coef_y = [-0.13     0.05   -0.01  -0.03;
                  -0.07    -0.01    0     -0.01;
                  -0.05    -0.04    0.01   0;
                  -0.16     0.04   -0.01   0;
                  -0.14     0.06   -0.01  -0.04;
                  -0.14     0.05   -0.01  -0.04;
                  -0.13     0.05   -0.01  -0.04];

% Tobillo Z (8 key-points)
Ankle.Z.coef_t = [ 1.00     0       0      0;
                   15.05   -0.49    0.14  -0.29;
                   29.12   -1.10    0.34   0.09;
                   68.28   -4.31   -1.21   0.38;
                   70.65   -5.04    0.15   4.48;
                   72.31    4.54   -2.87   7.29;
                   90.68   -2.00    0.17   1.18;
                  100        0       0      0];
Ankle.Z.coef_y = [ 0        0.03   -0.01  -1.07;
                  -0.01     0.02    0     -1.07;
                  -0.02     0       0     -1.05;
                  -0.03     0.12   -0.03  -0.99;
                  -0.06     0.11   -0.02  -0.92;
                  -0.01     0.03    0     -1.00;
                   0        0.01    0     -1.05;
                   0        0.03   -0.01  -1.07];

tablas = [Hip, Knee, Ankle];

end
