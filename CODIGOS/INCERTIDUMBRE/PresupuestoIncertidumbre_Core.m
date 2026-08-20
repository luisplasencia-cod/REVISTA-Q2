function resultado = PresupuestoIncertidumbre_Core(componentes, opciones)
% PRESUPUESTOINCERTIDUMBRE_CORE  Presupuesto formal de incertidumbre de
%                                 medicion (GUM / ISO 5725) para una
%                                 cadena de medicion cinematica o cinetica.
%
%   resultado = PresupuestoIncertidumbre_Core(componentes)
%   resultado = PresupuestoIncertidumbre_Core(componentes, opciones)
%
% Por que existe este archivo: candidato E de docs/ESTADO_Y_RUMBO.md §6,
% aprobado en docs/DISCUSION_Q2.md P-19 (16-ago-2026). RMSEnorm/ICC/SPM1D
% (5.4 del manuscrito) dicen si el simulador reproduce una curva de
% referencia; esta herramienta responde una pregunta distinta: de dónde
% viene la incertidumbre total de una medición individual, y cuánto
% aporta cada fuente. Es el marco de "trueness/precision" de ISO 5725
% (ya citado en 5.4, ISO5725) llevado a un presupuesto numerico explicito
% siguiendo el metodo de propagacion de incertidumbre de la GUM
% (JCGM 100:2008, "Evaluation of measurement data - Guide to the
% expression of uncertainty in measurement").
%
% ENTRADA
%   componentes   struct array, un elemento por fuente de incertidumbre.
%                 Cada elemento debe tener:
%       .nombre    string, para el reporte (p.ej. 'Validacion iSen (RMSD)')
%       .tipo      'A' (evaluada por analisis estadistico de una serie de
%                  observaciones propias, p.ej. SD de residuos de
%                  Calibracion_Offset_Core.m) o 'B' (evaluada por otros
%                  medios: literatura, especificacion de fabricante,
%                  juicio cientifico) - clasificacion GUM seccion 4,
%                  ambas se combinan de la misma forma matematica.
%       .valor     incertidumbre ESTANDAR de este componente (no
%                  expandida), en las mismas unidades que la magnitud
%                  final. Si la fuente reporta un RMSD/SD directamente,
%                  usar ese valor tal cual (ver GUIA_INTERPRETACION.md
%                  seccion 3 para la advertencia sobre RMSD vs.
%                  incertidumbre estandar en sentido estricto).
%       .gl        grados de libertad de esa estimacion. Usar Inf (o
%                  cualquier numero >=1000) si se asume conocida con
%                  certeza (tipico de una especificacion), o el gl real
%                  (n-1 para una SD tipo A, o el gl de la fuente de
%                  literatura si se reporta) para que la incertidumbre
%                  expandida no sea artificialmente angosta.
%       .fuente    string libre, para trazabilidad en el reporte (p.ej.
%                  'Piche et al. 2022, Measurement, iSen vs. optoelectronico').
%
%   opciones      struct opcional:
%       .nivel_confianza  (default 0.95) nivel para la incertidumbre
%                         expandida U = k*u_c.
%       .nombre_magnitud  (default '') para el reporte.
%       .unidad           (default '') para el reporte.
%
% METODOLOGIA (JCGM 100:2008, ley de propagacion de incertidumbre,
% modelo aditivo con coeficientes de sensibilidad = 1 - valido cuando la
% magnitud de interes es una suma/diferencia de las fuentes, p.ej. un
% error medido es la suma de error de instrumento + error de calibracion
% + error de repetibilidad; si el modelo real de la magnitud no es
% aditivo, los coeficientes de sensibilidad hay que calcularlos aparte
% antes de usar esta funcion - no se asume de oficio):
%   1. Incertidumbre estandar combinada (componentes no correlacionados):
%        u_c = sqrt( sum(valor_i^2) )
%   2. Grados de libertad efectivos (formula de Welch-Satterthwaite,
%      JCGM 100:2008 ec. G.2b):
%        gl_eff = u_c^4 / sum( valor_i^4 / gl_i )
%      Si todos los gl_i son Inf, gl_eff = Inf.
%   3. Factor de cobertura k: t de Student al nivel de confianza pedido
%      con gl_eff grados de libertad (se reduce a k=1.96 cuando
%      gl_eff->Inf y nivel=0.95; la aproximacion comun k=2 solo es
%      valida cuando gl_eff es grande, por eso aqui se calcula de forma
%      exacta en vez de asumirla).
%   4. Incertidumbre expandida: U = k * u_c.
%
% SALIDA: struct `resultado` con la tabla de componentes (incluyendo el
% % de contribucion de cada uno a u_c^2 - el diagnostico mas util del
% presupuesto, muestra qué fuente domina), u_c, gl_eff, k, U, y el nivel
% de confianza usado. Listo para convertirse en la tabla de Metodos/
% Resultados que pide un presupuesto de incertidumbre formal.
%
% Requiere: Statistics and Machine Learning Toolbox (tinv) - mismo
% requisito que TOST_Core.m y Calibracion_Offset_Core.m.
% ==========================================================================

if nargin < 2, opciones = struct(); end

def = struct('nivel_confianza', 0.95, 'nombre_magnitud', '', 'unidad', '');
campos = fieldnames(def);
for i = 1:numel(campos)
    if ~isfield(opciones, campos{i})
        opciones.(campos{i}) = def.(campos{i});
    end
end

if isempty(componentes)
    error('componentes no puede estar vacio - se necesita al menos una fuente de incertidumbre.');
end

n = numel(componentes);
nombres = cell(n,1); tipos = cell(n,1); fuentes = cell(n,1);
valores = zeros(n,1); gls = zeros(n,1);

for i = 1:n
    c = componentes(i);
    if ~isfield(c,'nombre') || ~isfield(c,'tipo') || ~isfield(c,'valor') || ~isfield(c,'gl')
        error('componentes(%d) debe tener los campos nombre, tipo, valor, gl (fuente es opcional).', i);
    end
    if ~(strcmpi(c.tipo,'A') || strcmpi(c.tipo,'B'))
        error('componentes(%d).tipo debe ser ''A'' o ''B'' (clasificacion GUM), recibido "%s".', i, c.tipo);
    end
    if c.valor < 0
        error('componentes(%d).valor debe ser >= 0 (es una incertidumbre estandar, no puede ser negativa).', i);
    end
    if c.gl <= 0
        error('componentes(%d).gl debe ser > 0.', i);
    end
    nombres{i} = c.nombre;
    tipos{i} = upper(c.tipo);
    valores(i) = c.valor;
    gls(i) = c.gl;
    if isfield(c,'fuente'), fuentes{i} = c.fuente; else, fuentes{i} = ''; end
end

u_c = sqrt(sum(valores.^2));

if u_c == 0
    gl_eff = Inf;
else
    denom = sum((valores.^4) ./ gls);   % gl=Inf da termino 0, coherente con Welch-Satterthwaite
    if denom == 0
        gl_eff = Inf;
    else
        gl_eff = u_c^4 / denom;
    end
end

alpha = 1 - opciones.nivel_confianza;
if isinf(gl_eff)
    k = norminv(1 - alpha/2);   % limite normal cuando gl_eff -> Inf
else
    k = tinv(1 - alpha/2, gl_eff);
end

U = k * u_c;

if u_c > 0
    contribucion_pct = 100 * (valores.^2) / (u_c^2);
else
    contribucion_pct = zeros(n,1);
end

resultado = struct();
resultado.nombres = {nombres{:}}';
resultado.tipos = {tipos{:}}';
resultado.fuentes = {fuentes{:}}';
resultado.valores = valores;
resultado.gls = gls;
resultado.contribucion_pct = contribucion_pct;
resultado.u_c = u_c;
resultado.gl_eff = gl_eff;
resultado.nivel_confianza = opciones.nivel_confianza;
resultado.k = k;
resultado.U = U;

etiqueta = opciones.nombre_magnitud;
if isempty(etiqueta), etiqueta = 'magnitud'; end
unidad = opciones.unidad;

fprintf('\n------------------------------------------------------------------\n');
fprintf('Presupuesto de incertidumbre (GUM/ISO 5725) - %s\n', etiqueta);
fprintf('------------------------------------------------------------------\n');
[~, orden] = sort(contribucion_pct, 'descend');
for idx = 1:n
    i = orden(idx);
    fprintf('  [%s] %-38s u = %8.4g%s  (%5.1f%% de u_c^2, gl=%s)\n', ...
        tipos{i}, nombres{i}, valores(i), unidad, contribucion_pct(i), glstr(gls(i)));
end
fprintf('------------------------------------------------------------------\n');
fprintf('u_c (combinada)      = %.4g%s\n', u_c, unidad);
fprintf('gl efectivos (W-S)   = %s\n', glstr(gl_eff));
fprintf('k (nivel %.0f%%)       = %.3f\n', 100*opciones.nivel_confianza, k);
fprintf('U (expandida, %.0f%%)  = %.4g%s\n', 100*opciones.nivel_confianza, U, unidad);
fprintf('------------------------------------------------------------------\n');

end

function s = glstr(gl)
if isinf(gl)
    s = 'Inf';
else
    s = sprintf('%.1f', gl);
end
end
