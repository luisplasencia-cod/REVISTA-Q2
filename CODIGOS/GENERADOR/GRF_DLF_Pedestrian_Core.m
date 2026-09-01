function out = GRF_DLF_Pedestrian_Core(antropometria, opciones)
% GRF_DLF_PEDESTRIAN_CORE  29-ago-2026: fuerza de reaccion VERTICAL a
% partir del modelo de "Dynamic Load Factor" (DLF) de la literatura de
% ingenieria estructural (vibracion de pasarelas/pisos por caminata
% peatonal) - Nguyen, Lythgo, Gad, Wilson & Haritos (2022), Int. J. of
% Applied Mechanics and Engineering 27(3):103-114, DOI 10.2478/ijame-2022-
% 0038, Tabla 3 (coeficientes MEDIOS, no los percentiles 90/95 que son
% deliberadamente conservadores para diseno estructural, no representan un
% caminante "tipico").
%
% POR QUE ESTA LINEA (pedido explicito del usuario, 29-ago-2026, tras ver
% que ninguna de las 6 combinaciones cinematica+geometria de esta misma
% sesion superaba r=0.40 contra Kuopio real): esta familia de modelos NO
% pasa por angulos articulares de ninguna pierna - es una serie de Fourier
% ajustada DIRECTAMENTE sobre la fuerza medida (158 pisadas reales, 23
% adultos jovenes, 170cm/72kg promedio, Vicon+plataforma de fuerza),
% parametrizada SOLO por peso corporal y frecuencia de paso. Al no
% necesitar reconciliar la geometria de 2 piernas generadas por separado,
% evita por completo la fuente de error que domino la primera mitad de
% esta sesion.
%
% RESULTADO Y ESTADO VIGENTE (29-ago-2026, mismo dia): r=0.53 contra
% Kuopio real - mejor que los 6 intentos basados en angulos articulares,
% pero SUPERADO despues, en la misma sesion, por un modelo aun mas directo:
% usar la fuerza REAL medida de un dataset independiente (Fukuchi et al.
% 2018) como plantilla, sin ningun modelo teorico de por medio - r=0.866,
% ver Predecir_GRF_Personalizado_Core.m y GUIA_INTERPRETACION.md
% #8-quinquies. Esta funcion se conserva como evidencia documentada de un
% paso intermedio real del razonamiento (que sirvio para confirmar que
% saltarse los angulos articulares era la direccion correcta), no como el
% modelo recomendado.
%
% MODELO (Ec.1.1 del paper, SOLO fuerza VERTICAL, igual alcance que el
% resto de esta linea):
%   F(t) = P*[1 + sum_i alpha_i*sin(2*pi*i*fp*t + phi_i)]
% donde P=peso corporal, fp=frecuencia de PASO (steps/s = 2/T_ciclo, un
% paso por cada pie por ciclo completo de zancada), alpha_i = Tabla 3 del
% paper (columna "Mean", NO percentil 90/95), phi_i = SCI P354 (citado
% dentro del propio Nguyen 2022): 0, pi/2, pi, -pi/2 para i=1..4 - Nguyen
% no publica sus propias fases medidas ("phase angles have been found to
% scatter significantly"), asi que se usa la convencion ya establecida en
% la literatura citada por el propio paper, declarado, no inventado.
%
% IMPORTANTE, DECLARADO: esta F(t) es la fuerza COMBINADA bajo LOS DOS
% PIES a la vez (se deriva superponiendo pisadas consecutivas de ambos
% pies, Fig.2 del paper) - NO la fuerza de un solo pie que mide Kuopio en
% una sola plataforma. Se reparte entre las 2 piernas con el MISMO
% principio de transferencia lineal de masa que la Ec.9 de Zhao 2026 (ya
% usado en GRF_Newton_ApoyoSimple_Core.m) - pero aplicado aqui sobre una
% señal YA limpia y periodica por construccion, no sobre 2 estimaciones
% cinematicas independientes que se desacuerdan.
%
% ENTRADA
%   antropometria.masa_kg, .talla_m (para el motor de tiempo compartido)
%   opciones.n_armonicos   default 4 (los unicos con fase bien establecida)
%   opciones.N_uniforme    default 201
%
% SALIDA: out.t_s, .pct_ciclo, .GRF_vertical_pctBW (combinada, 2 pies),
%   .GRF_vertical_trackeada_pctBW (repartida, 1 pierna),
%   .apoyo_simple_mask, .verificacion_media_vGRF_pctBW
% ==========================================================================

if nargin < 1 || ~isstruct(antropometria) || ~isfield(antropometria,'talla_m')
    error('antropometria debe ser un struct con al menos el campo talla_m.');
end
if ~isfield(antropometria,'masa_kg') || ~(isnumeric(antropometria.masa_kg) && isscalar(antropometria.masa_kg) && antropometria.masa_kg>0)
    error('antropometria.masa_kg es obligatorio (escalar positivo).');
end
if nargin < 2, opciones = struct(); end
if ~isfield(opciones,'n_armonicos') || isempty(opciones.n_armonicos), opciones.n_armonicos = 4; end
if ~isfield(opciones,'N_uniforme') || isempty(opciones.N_uniforme), opciones.N_uniforme = 201; end
N = opciones.N_uniforme;

antro = Estimar_Antropometria_Core(antropometria);
M_total = antro.masa_kg;

tempo = Temporizacion_Core(antro, 'Koopman');  % motor de tiempo compartido, mismo criterio que el resto del proyecto
T = tempo.tiempo_ciclo_s;
fp = 2/T;  % frecuencia de PASO (2 pasos por zancada completa)

% --- Tabla 3 de Nguyen et al. 2022, columna "Mean" (NO percentil 90/95) ---
alpha_todos = [0.324, 0.090, 0.059, 0.054, 0.048, 0.037, 0.029, 0.023, 0.019, 0.017];
% Fases SCI P354 (citadas dentro de Nguyen 2022, Sec.1) - solo bien
% establecidas para los primeros 4 armonicos.
phi_sci = [0, pi/2, pi, -pi/2];
n = min(opciones.n_armonicos, 4);
if opciones.n_armonicos > 4
    warning('GRF_DLF_Pedestrian_Core:fasesNoPublicadas', ...
        'Fases bien establecidas solo para 4 armonicos (SCI P354) - se limita opciones.n_armonicos a 4.');
end
alpha = alpha_todos(1:n);
phi = phi_sci(1:n);

t_u = linspace(0, T, N);
F_combinada_pctBW = 100*ones(1,N);
for i = 1:n
    F_combinada_pctBW = F_combinada_pctBW + 100*alpha(i)*sin(2*pi*i*fp*t_u + phi(i));
end

% --- Reparto de doble apoyo (mismo criterio de transferencia lineal que
% Zhao Ec.9, ya usado en GRF_Newton_ApoyoSimple_Core.m, aplicado aqui
% sobre F_combinada YA limpia - no sobre 2 estimaciones independientes) ---
frac_apoyo = tempo.frac_apoyo;
tiempo_apoyo_s = frac_apoyo*T;
T_DT = tiempo_apoyo_s - T/2;
if T_DT <= 0
    error('GRF_DLF_Pedestrian_Core:fracApoyoInvalida', 'frac_apoyo debe ser > 0.5.');
end
fase = mod(t_u, T);
en_apoyo_trackeada = fase <= tiempo_apoyo_s;
fase_contra = mod(t_u+T/2, T);
contra_en_apoyo = fase_contra <= tiempo_apoyo_s;
apoyo_simple_mask = en_apoyo_trackeada & ~contra_en_apoyo;
temprano = en_apoyo_trackeada & contra_en_apoyo & (fase < T/4);
tardio   = en_apoyo_trackeada & contra_en_apoyo & (fase >= T/4);

F_trackeada_pctBW = nan(1,N);
F_trackeada_pctBW(apoyo_simple_mask) = F_combinada_pctBW(apoyo_simple_mask);
w_temprano = fase(temprano)/T_DT;                      % 0 (recien aterrizado) -> 1 (ya asumio todo el peso disponible)
F_trackeada_pctBW(temprano) = w_temprano .* F_combinada_pctBW(temprano);
w_tardio = 1 - (fase(tardio)-T/2)/T_DT;                 % 1 -> 0 (a punto de despegar)
F_trackeada_pctBW(tardio) = w_tardio .* F_combinada_pctBW(tardio);
F_trackeada_pctBW(~en_apoyo_trackeada) = 0;             % trackeada en su propio balanceo, no toca el piso

out = struct();
out.t_s = t_u;
out.pct_ciclo = 100*t_u/T;
out.GRF_vertical_pctBW = F_combinada_pctBW;
out.GRF_vertical_trackeada_pctBW = F_trackeada_pctBW;
out.apoyo_simple_mask = apoyo_simple_mask;
out.verificacion_media_vGRF_pctBW = mean(F_combinada_pctBW);
out.fp_hz = fp;
out.antro = antro;
out.tempo = tempo;

end
