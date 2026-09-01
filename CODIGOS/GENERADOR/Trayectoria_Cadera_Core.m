function out = Trayectoria_Cadera_Core(pct_ciclo, zancada_cm, A_cm, Y0_cm)
% TRAYECTORIA_CADERA_CORE  Trayectoria de la cadera en el espacio de
%                   laboratorio (cm) durante un ciclo de marcha completo.
%                   Construida de CERO a pedido explicito del usuario
%                   (30-ago-2026) - NO reusa Cadena_Completa_Core.m ni
%                   Cadera_Continua_Zhao_Core.m.
%
%   Xh(t) = zancada_cm * (pct_ciclo/100)              [avance lineal]
%   Yh(t) = Y0_cm - A_cm*cos(4*pi*pct_ciclo/100)      [oscilacion doble giba]
%
% MODELO VERTICAL - verificado contra literatura (30-ago-2026, WebSearch):
% la oscilacion vertical de cadera/centro de masa durante la marcha tiene
% una amplitud PICO A PICO de ~4-5 cm, con MINIMOS cerca de 0%/50% del
% ciclo (contacto inicial de cada pie) y MAXIMOS cerca de 25%/75% (medio
% apoyo) - hallazgo clasico de Saunders, Inman & Eberhart 1953 ("The
% Major Determinants in Normal and Pathological Gait"), confirmado en
% multiples fuentes independientes de biomecanica de marcha (~4-5cm,
% modelo de compass gait / pendulo invertido). La formula
% Y0-A*cos(4*pi*t/100) da esos minimos/maximos EXACTAMENTE por
% construccion: cos(0)=cos(2*pi)=cos(4*pi)=1 -> minimo en t=0,50,100;
% cos(pi)=cos(3*pi)=-1 -> maximo en t=25,75. Ademas CIERRA EL CICLO
% (Yh(0)=Yh(100) exacto), a diferencia de un intento anterior del mismo
% dia (cadera anclada a la geometria de la pierna en el piso, alternando
% de pierna) que no cerraba el ciclo en el empalme.
%
% CAVEAT declarado: la cifra de 4-5cm es de EXCURSION DEL CENTRO DE MASA
% corporal completo, no de un marcador especifico de cadera/pelvis - se
% usa como proxy estandar en biomecanica de marcha (misma aproximacion
% que ya usa el proyecto en otras partes, p.ej. Cadena_Completa_Core.m,
% "el vaiven vertical real de cadera no se modela, se declara"). A_cm
% default sugerido = 2.25 (da 4.5cm pico a pico, centro del rango 4-5cm
% de la literatura) - PARAMETRO AJUSTABLE por el llamador, no fijo aqui.
%
% MODELO HORIZONTAL: avance LINEAL con %ciclo (velocidad promedio
% constante) - aproximacion declarada de primer orden, no modela el
% vaiven real de velocidad instantanea dentro del paso. zancada_cm =
% distancia recorrida en UN ciclo completo (contacto inicial a contacto
% inicial del MISMO pie); un default razonable es velocidad_ms *
% tiempo_ciclo_s * 100 de Temporizacion_Core.m (velocidad estimada por
% Froude si no se mide) - se calcula en el llamador, no aqui.
%
%   out = Trayectoria_Cadera_Core(pct_ciclo, zancada_cm, A_cm, Y0_cm)
%
% ENTRADA
%   pct_ciclo    [1 x n] o escalar, 0-100 (% del ciclo de marcha)
%   zancada_cm   avance horizontal total en un ciclo completo (cm), escalar
%   A_cm         amplitud de la oscilacion vertical (cm), escalar >= 0 -
%                default sugerido 2.25 (ver arriba), AJUSTABLE
%   Y0_cm        altura de referencia de la cadera (cm), escalar - el
%                llamador decide si usa 0 (solo interesa el
%                desplazamiento relativo) o una altura real
%
% SALIDA: struct `out` con .Xh_cm, .Yh_cm - mismo tamano que pct_ciclo
%
% Funciona con CUALQUIER longitud de arreglo (no asume 101 puntos).
% ==========================================================================

if nargin < 4
    error('Se requieren pct_ciclo, zancada_cm, A_cm, Y0_cm.');
end
if ~(isnumeric(zancada_cm) && isscalar(zancada_cm))
    error('zancada_cm debe ser escalar. Se recibio: %s', mat2str(zancada_cm));
end
if ~(isnumeric(A_cm) && isscalar(A_cm) && A_cm >= 0)
    error('A_cm debe ser un escalar >= 0. Se recibio: %s', mat2str(A_cm));
end
if ~(isnumeric(Y0_cm) && isscalar(Y0_cm))
    error('Y0_cm debe ser escalar. Se recibio: %s', mat2str(Y0_cm));
end

pct_ciclo = pct_ciclo(:).';

out = struct();
out.Xh_cm = zancada_cm * (pct_ciclo/100);
out.Yh_cm = Y0_cm - A_cm*cos(4*pi*pct_ciclo/100);

end
