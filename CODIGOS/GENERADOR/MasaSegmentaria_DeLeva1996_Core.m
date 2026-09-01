function out = MasaSegmentaria_DeLeva1996_Core(entrada)
% MASASEGMENTARIA_DELEVA1996_CORE  Fracciones de masa y de posicion del
%                          centro de masa (CoM) por segmento corporal,
%                          de Leva 1996 (Table 4), por sexo.
%
%   out = MasaSegmentaria_DeLeva1996_Core(entrada)
%
% ENTRADA: struct `entrada` con:
%   .masa_kg   masa corporal total (kg)
%   .sexo      'M' o 'F' (insensible a mayusculas, solo se usa el 1er caracter)
%
% SALIDA: struct `out` con, para cada segmento, masa en kg y en fraccion,
% mas la posicion del CoM como fraccion de la longitud del segmento medida
% DESDE EL EXTREMO PROXIMAL (mismo sentido que la tabla 4 original: origen
% proximal -> destino distal):
%   .cabeza_masa_kg, .cabeza_masa_frac
%   .tronco_masa_kg, .tronco_masa_frac
%   .brazo_masa_kg, .brazo_masa_frac           (1 solo brazo)
%   .antebrazo_masa_kg, .antebrazo_masa_frac   (1 solo antebrazo)
%   .mano_masa_kg, .mano_masa_frac             (1 sola mano)
%   .muslo_masa_kg, .muslo_masa_frac           (1 sola pierna)
%   .muslo_com_frac        posicion del CoM del muslo, fraccion de
%                           long_muslo_m desde la CADERA (0=cadera, 1=rodilla)
%   .pierna_masa_kg, .pierna_masa_frac         (1 sola pierna, "shank")
%   .pierna_com_frac        posicion del CoM de la tibia/pierna, fraccion
%                           de long_tibia_m desde la RODILLA (0=rodilla, 1=tobillo)
%   .pie_masa_kg, .pie_masa_frac               (1 solo pie)
%   .hat_masa_kg, .hat_masa_frac    cabeza + tronco + 2*(brazo+antebrazo+mano)
%                           ("Head-Arms-Trunk", lo que Zhao 2026 Sec.2.4
%                           llama "m": masa del tronco+cabeza+miembros
%                           superiores. Se aproxima su aceleracion con la
%                           de la cadera - ver GRF_Newton_ApoyoSimple_Core.m)
%   .verificacion_suma_pct   suma de: cabeza+tronco+2*(brazo+antebrazo+
%                           mano+muslo+pierna+pie), debe dar ~100 (chequeo
%                           de que no se omitio ningun segmento de la tabla)
%
% FUENTE (Table 4 de-Leva1996, "Adjusted parameters for females (F; body
% mass=61.9kg, stature=1.735m) and males (M; body mass=73.0kg,
% stature=1.741m)" - de Leva P. (1996) "Adjustments to Zatsiorsky-
% Seluyanov's segment inertia parameters", J. Biomechanics 29(9):1223-1230.
% Coeficientes leidos directamente de la imagen de la Tabla 4 (PDF escaneado,
% docs/literatura/pdfs/DeLeva1996_JBiomech_SegmentInertiaParameters.pdf,
% pagina 6/8), 27-ago-2026. Verificacion de transcripcion: la suma de
% cabeza+tronco+2*(brazo+antebrazo+mano+muslo+pierna+pie) da 99.99% (F) y
% 100.00% (M) - confirma que no hay filas mal leidas ni segmentos faltantes.
%
% Mass (%) por segmento, columnas F / M de la Tabla 4:
%   Head        6.68 / 6.94
%   Trunk      42.57 / 43.46
%   Upper arm   2.55 / 2.71
%   Forearm     1.38 / 1.62
%   Hand        0.56 / 0.61
%   Thigh      14.78 / 14.16
%   Shank       4.81 / 4.33
%   Foot        1.29 / 1.37
%
% Longitudinal CM position (%, desde el extremo PROXIMAL de cada fila,
% ver Fig.1/columna "Endpoints/Origin" de la Tabla 4 - Thigh: origen=
% Iliospinale~cadera; Shank: origen=Tibiale~rodilla):
%   Thigh      36.12 / 40.95   (fraccion desde cadera hacia rodilla)
%   Shank      44.16 / 44.59   (fraccion desde rodilla hacia tobillo)
%
% NO se usa GB/T17245-2004 (la fuente que usa el propio paper de Zhao
% 2026 para estas mismas masas) - se sustituye por de Leva 1996 de forma
% declarada: es la fuente ya usada/verificada en este proyecto (Winter
% Fig.4.1, ver Estimar_Antropometria_Core.m), peer-reviewed, ampliamente
% citada en biomecanica occidental, y el documento GB/T no esta disponible
% para verificar directamente (regla del proyecto: no fijar un numero sin
% verificar la fuente). Decision confirmada por el usuario, 27-ago-2026.
% ==========================================================================

if nargin < 1 || ~isstruct(entrada)
    error('Se requiere un struct de entrada con los campos masa_kg y sexo.');
end
if ~isfield(entrada,'masa_kg') || ~(isnumeric(entrada.masa_kg) && isscalar(entrada.masa_kg) && entrada.masa_kg > 0)
    error('entrada.masa_kg debe ser un escalar positivo (kg). Se recibio: %s', mat2str(getfield_safe(entrada,'masa_kg')));
end
if ~isfield(entrada,'sexo') || isempty(entrada.sexo) || ~any(upper(entrada.sexo(1)) == 'MF')
    error('entrada.sexo debe ser ''M'' o ''F''. Se recibio: %s', mat2str(getfield_safe(entrada,'sexo')));
end

M = entrada.masa_kg;
esM = upper(entrada.sexo(1)) == 'M';

% --- Tabla 4, mass fraction (%), [F, M] ---
tabla_masa = struct( ...
    'cabeza',    [6.68,  6.94], ...
    'tronco',    [42.57, 43.46], ...
    'brazo',     [2.55,  2.71], ...
    'antebrazo', [1.38,  1.62], ...
    'mano',      [0.56,  0.61], ...
    'muslo',     [14.78, 14.16], ...
    'pierna',    [4.81,  4.33], ...
    'pie',       [1.29,  1.37]);

% --- Tabla 4, Longitudinal CM position (%), [F, M] (solo muslo/pierna,
% que son los unicos segmentos con cinematica propia en este generador) ---
tabla_com = struct( ...
    'muslo',  [36.12, 40.95], ...
    'pierna', [44.16, 44.59]);

campos = fieldnames(tabla_masa);
out = struct();
suma_pct = 0;
for i = 1:numel(campos)
    c = campos{i};
    pct = tabla_masa.(c)(1 + esM);
    out.([c '_masa_frac']) = pct / 100;
    out.([c '_masa_kg'])   = (pct / 100) * M;
    if any(strcmp(c, {'cabeza','tronco'}))
        suma_pct = suma_pct + pct;
    else
        suma_pct = suma_pct + 2*pct;  % segmentos pares (brazo/antebrazo/mano/muslo/pierna/pie)
    end
end

out.muslo_com_frac  = tabla_com.muslo(1 + esM) / 100;
out.pierna_com_frac = tabla_com.pierna(1 + esM) / 100;

out.hat_masa_frac = out.cabeza_masa_frac + out.tronco_masa_frac + ...
    2*(out.brazo_masa_frac + out.antebrazo_masa_frac + out.mano_masa_frac);
out.hat_masa_kg = out.hat_masa_frac * M;

out.verificacion_suma_pct = suma_pct;
out.masa_total_kg = M;
out.sexo = upper(entrada.sexo(1));
out.fuente = 'deLeva1996_Tabla4';

end

% --------------------------------------------------------------------
function v = getfield_safe(s, campo)
if isfield(s, campo), v = s.(campo); else, v = []; end
end
