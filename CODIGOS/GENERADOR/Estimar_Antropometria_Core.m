function out = Estimar_Antropometria_Core(entrada)
% ESTIMAR_ANTROPOMETRIA_CORE  Completa el vector de antropometria del
%                              generador cuando faltan medidas directas,
%                              usando las fracciones de talla de
%                              Drillis & Contini 1966, reproducidas en
%                              Winter, "Biomechanics and Motor Control of
%                              Human Movement", Fig. 4.1 (verificado
%                              directamente contra la imagen de la fuente
%                              primaria, 23-ago-2026 - ver
%                              GUIA_INTERPRETACION.md #E3 para el
%                              detalle de la verificacion, incluida la
%                              captura de la figura real).
%
%                              Regla del proyecto: un dato MEDIDO
%                              siempre tiene prioridad sobre uno
%                              estimado - esta funcion nunca sobrescribe
%                              un campo que ya vino en la entrada.
%
%   out = Estimar_Antropometria_Core(entrada)
%
% ENTRADA: struct `entrada`, con al menos:
%   .talla_m         talla corporal (m)
%   Opcionales (si ya se midieron, se preservan tal cual):
%   .long_muslo_m, .long_tibia_m, .long_pie_m
%
% SALIDA: struct `out` = entrada + los campos que faltaban, más:
%   .fuente_muslo, .fuente_tibia, .fuente_pie   'medido' o 'estimado_deLeva'
%
% Coeficientes (fraccion de talla H, verificados contra Winter Fig. 4.1,
% valores originales de Drillis & Contini 1966):
%   altura de cadera (trocanter mayor) = 0.530 H
%   altura de rodilla (condilos femorales) = 0.285 H
%   altura de tobillo (maleolo) = 0.039 H
%   longitud de pie = 0.152 H
%   => long_muslo = 0.530H - 0.285H = 0.245 H  (cadera a rodilla)
%   => long_tibia = 0.285H - 0.039H = 0.246 H  (rodilla a tobillo)
%
% Caveat declarado (mismo que docs/planificacion/
% analisis_escalamiento_Q1_generador_trayectorias.md #5-bis): esta tabla
% esta calibrada para adultos jovenes - no se aplico ningun ajuste por
% edad/sexo especifico (de Leva 1996 SI distingue por sexo para
% masa/COM, pero la Fig.4.1 de Winter/Drillis-Contini para LONGITUD de
% segmento no trae version separada por sexo - se declara como
% limitacion, no se inventa un factor de correccion sin fuente).
% ==========================================================================

if nargin < 1 || ~isstruct(entrada)
    error('Se requiere un struct de entrada con al menos el campo talla_m.');
end
if ~isfield(entrada, 'talla_m') || ~(isnumeric(entrada.talla_m) && isscalar(entrada.talla_m) && entrada.talla_m > 0)
    error('entrada.talla_m debe ser un escalar positivo (m). Se recibio: %s', ...
        mat2str(getfield_safe(entrada, 'talla_m')));
end
H = entrada.talla_m;
if H < 1.30 || H > 2.10
    warning('Estimar_Antropometria_Core:tallaFueraDeRango', ...
        'talla_m=%.3f fuera del rango tipico adulto (1.30-2.10 m) - revisar unidad (m, no cm).', H);
end

FRAC_MUSLO = 0.245;
FRAC_TIBIA = 0.246;
FRAC_PIE   = 0.152;

out = entrada;

if isfield(entrada, 'long_muslo_m') && ~isempty(entrada.long_muslo_m)
    out.fuente_muslo = 'medido';
else
    out.long_muslo_m = FRAC_MUSLO * H;
    out.fuente_muslo = 'estimado_deLeva';
end

if isfield(entrada, 'long_tibia_m') && ~isempty(entrada.long_tibia_m)
    out.fuente_tibia = 'medido';
else
    out.long_tibia_m = FRAC_TIBIA * H;
    out.fuente_tibia = 'estimado_deLeva';
end

if isfield(entrada, 'long_pie_m') && ~isempty(entrada.long_pie_m)
    out.fuente_pie = 'medido';
else
    out.long_pie_m = FRAC_PIE * H;
    out.fuente_pie = 'estimado_deLeva';
end

end

% --------------------------------------------------------------------
function v = getfield_safe(s, campo)
if isfield(s, campo), v = s.(campo); else, v = []; end
end
