function out = Zhao2026_Core(l, f, opciones)
% ZHAO2026_CORE  Genera phi_cadera(t), phi_rodilla(t) y la reduccion
%                theta_tibia(t) = phi_cadera(t) - phi_rodilla(t), usando
%                los coeficientes YA PUBLICADOS de Zhao, Wei, Xie, Liu,
%                Qu, Cao, Ding & Liao 2026 (PLOS ONE), Ecs. 1-2 y Tabla 1.
%
%                Sin ajustar ningun coeficiente con datos propios (regla
%                P-23, docs/DISCUSION_Q2.md #4-sexies) - solo evalua la
%                formula publicada para la entrada antropometrica dada.
%
%   out = Zhao2026_Core(l, f)
%   out = Zhao2026_Core(l, f, opciones)
%
% ENTRADA
%   l   longitud de pierna (m), ASIS -> maleolo medial. Si no se mide
%       directo, usar de Leva 1996 (ver docs/planificacion/
%       analisis_escalamiento_Q1_generador_trayectorias.md #5-bis).
%   f   cadencia (zancadas/segundo); periodo del ciclo T = 1/f.
%   opciones (struct opcional):
%     .lado        'izquierda' (default, Ec.1) o 'derecha' (Ec.2, agrega
%                  fase +j*pi por armonico)
%     .nMuestras   puntos por ciclo, 0-100% (default 101)
%
% SALIDA: struct `out`
%   .t                tiempo (s), [1 x nMuestras], un ciclo completo (0 a 1/f)
%   .pct_ciclo        0-100, mismo tamano que .t
%   .phi_cadera_rad   angulo articular relativo de cadera (Ec.1/2, rad)
%   .phi_rodilla_rad  angulo articular relativo de rodilla (Ec.1/2, rad)
%   .theta_tibia_rad  = phi_cadera_rad - phi_rodilla_rad (seccion 2.6 del
%                     paper). Angulo ABSOLUTO del segmento tibial
%                     respecto al eje vertical del mundo, EN LA
%                     CONVENCION PROPIA DE ZHAO (referencia vertical) -
%                     todavia no es la convencion atan2/horizontal de
%                     este proyecto. Ver GUIA_INTERPRETACION.md antes de
%                     usar esto como entrada del CSV del simulador.
%   .coeficientes     struct con B0..B3, phi1..phi3 de cadera y rodilla,
%                     para trazabilidad (que numero de la Tabla 1 se uso)
%
% Fuente verificada a texto completo: docs/literatura/pdfs/ (Zhao 2026) y
% docs/algoritmo/diseno_matematico_generador.md #4.
% ==========================================================================

if nargin < 3, opciones = struct(); end
def = struct('lado', 'izquierda', 'nMuestras', 101);
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

if ~(isnumeric(l) && isscalar(l) && l > 0)
    error('l (longitud de pierna, m) debe ser un escalar positivo. Se recibio: %s', mat2str(l));
end
if ~(isnumeric(f) && isscalar(f) && f > 0)
    error('f (cadencia, zancadas/s) debe ser un escalar positivo. Se recibio: %s', mat2str(f));
end
if ~any(strcmpi(opciones.lado, {'izquierda','derecha'}))
    error('opciones.lado debe ser ''izquierda'' o ''derecha''. Se recibio: %s', opciones.lado);
end

% --- Tabla 1 del paper (coeficientes ya publicados, no reajustar) ---
coef_cadera  = struct('B0', 0.086, 'B1', -0.316, 'B2', -0.067, 'B3', 0.026, ...
                       'phi1', -1.105, 'phi2', 1.433, 'phi3', 0.187);
coef_rodilla = struct('B0', 0.468, 'B1',  0.465, 'B2',  0.311, 'B3', -0.093, ...
                       'phi1',  0.244, 'phi2', -0.990, 'phi3', 0.266);

T = 1/f;
n = opciones.nMuestras;
t = linspace(0, T, n);
pct_ciclo = linspace(0, 100, n);

signo_fase = 0;
if strcmpi(opciones.lado, 'derecha')
    signo_fase = 1; % Ec.2: + j*pi por armonico j
end

phi_cadera_rad  = evaluar_serie(coef_cadera,  l, f, t, signo_fase);
phi_rodilla_rad = evaluar_serie(coef_rodilla, l, f, t, signo_fase);

theta_tibia_rad = phi_cadera_rad - phi_rodilla_rad;

out = struct();
out.t = t;
out.pct_ciclo = pct_ciclo;
out.phi_cadera_rad = phi_cadera_rad;
out.phi_rodilla_rad = phi_rodilla_rad;
out.theta_tibia_rad = theta_tibia_rad;
out.coeficientes = struct('cadera', coef_cadera, 'rodilla', coef_rodilla, 'lado', opciones.lado);

end

% ----------------------------------------------------------------------
function phi = evaluar_serie(coef, l, f, t, signo_fase)
% phi(t) = B0*l + sum_{j=1}^{3} Bj*l*sin(2*pi*j*f*t + phi_j + signo_fase*j*pi)
Bj  = [coef.B1, coef.B2, coef.B3];
phj = [coef.phi1, coef.phi2, coef.phi3];

phi = coef.B0 * l * ones(size(t));
for j = 1:3
    fase = 2*pi*j*f.*t + phj(j) + signo_fase*j*pi;
    phi = phi + Bj(j) * l * sin(fase);
end
end
