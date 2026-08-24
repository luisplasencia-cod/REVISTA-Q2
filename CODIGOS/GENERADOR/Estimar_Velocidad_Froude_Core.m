function v_ms = Estimar_Velocidad_Froude_Core(talla_m, opciones)
% ESTIMAR_VELOCIDAD_FROUDE_CORE  Estima la velocidad de marcha
%                                 autoseleccionada desde la talla
%                                 corporal, via similitud dinamica
%                                 (numero de Froude), sin necesitar
%                                 medir velocidad (D2 de
%                                 plan_100_generador.md: "solo cinta
%                                 metrica y balanza").
%
%   v_ms = Estimar_Velocidad_Froude_Core(talla_m)
%   v_ms = Estimar_Velocidad_Froude_Core(talla_m, opciones)
%
% ENTRADA
%   talla_m      talla corporal (m)
%   opciones.Fr  numero de Froude objetivo (default 0.25 - velocidad
%                metabolicamente optima/autoseleccionada, verificado a
%                texto completo: Raichlen, Pontzer et al., "Optimal
%                walking speed following changes in limb geometry",
%                J Exp Biol 214:2276-2282, 2011 - "optimal walking
%                speeds that correspond to the same Fr number, 0.25"
%                across adultos, ninos, personas con enanismo y pigmeos
%                - remonta al principio de similitud dinamica de
%                Alexander 1989. Fr = v^2/(g*L).
%   opciones.frac_talla_pierna   fraccion de talla usada como "longitud
%                de pierna" L en Fr=v^2/(g*L) (default 0.530 - altura de
%                cadera/trocanter mayor, Drillis & Contini 1966 via
%                Winter Fig.4.1, MISMA fuente ya verificada en
%                Estimar_Antropometria_Core.m - definicion estandar de
%                "leg length" en la literatura de Froude/marcha).
%
% SALIDA
%   v_ms    velocidad de marcha estimada (m/s)
%
% Formula: v = sqrt(Fr * g * L),  L = frac_talla_pierna * talla_m
%
% Caveat declarado: Fr=0.25 es un promedio poblacional de estudios de
% similitud dinamica, no una medida individual - introduce dispersion
% que ninguna cinta metrica puede eliminar. Se declara como limitacion
% del generador (mismo patron que otras estimaciones de esta carpeta),
% no se oculta. Rango tipico esperado para adultos (talla 1.50-1.90 m):
% ver GUIA_INTERPRETACION.md para los valores de sanidad.
% ==========================================================================

if nargin < 1 || ~(isnumeric(talla_m) && isscalar(talla_m) && talla_m > 0)
    error('talla_m debe ser un escalar positivo (m). Se recibio: %s', mat2str(talla_m));
end
if nargin < 2, opciones = struct(); end
if ~isfield(opciones, 'Fr'), opciones.Fr = 0.25; end
if ~isfield(opciones, 'frac_talla_pierna'), opciones.frac_talla_pierna = 0.530; end

g = 9.81;
L = opciones.frac_talla_pierna * talla_m;
v_ms = sqrt(opciones.Fr * g * L);

end
