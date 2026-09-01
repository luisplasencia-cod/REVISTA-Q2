function out = Cinematica_DoblePendulo_Core(theta1_rad, theta2_rad, L1, L2, Xh, Yh)
% CINEMATICA_DOBLEPENDULO_CORE  Cinematica DIRECTA de la cadena abierta
%                   cadera-rodilla-tobillo (2 eslabones, pendulo doble).
%                   Construida de CERO a pedido explicito del usuario
%                   (30-ago-2026, prompt completo del usuario) - NO reusa
%                   Cadena_Completa_Core.m ni Cadera_Continua_Zhao_Core.m,
%                   es una pieza independiente para poder comparar al
%                   final contra esas soluciones ya existentes.
%
%   Xk = Xh + L1*sin(theta1)      Yk = Yh - L1*cos(theta1)
%   Xa = Xk + L2*sin(theta2)      Ya = Yk - L2*cos(theta2)
%
% CONVENCION (verificada contra el codigo ya existente del proyecto,
% 30-ago-2026 - ver App_Animacion_Cadera_Rodilla_Tobillo.m para el detalle
% completo de la verificacion): theta1 (muslo) y theta2 (tibia) son
% angulos ABSOLUTOS de segmento respecto a la VERTICAL, 0 = segmento
% vertical apuntando hacia ABAJO desde la articulacion proximal, positivo
% = flexion hacia adelante - misma convencion que theta_muslo/theta_
% tibia_via_rodilla de Koopman2014_Core.m/Reduccion_Winter_Core.m, ya
% verificada empiricamente en el proyecto contra hitos de marcha normal
% (Perry & Burnfield/Winter). Y positivo = HACIA ARRIBA (de ahi el signo
% MENOS: el eslabon distal cuelga por debajo del proximal cuando theta=0).
%
% NOTA IMPORTANTE: esta funcion usa las ecuaciones tal cual las
% especifico el usuario, convencion "de libro de texto" de pendulo doble.
% NO hereda la inversion de signo de X que tiene Cadena_Cinematica_
% Core.m - esa inversion es un artefacto verificado del cableado/
% hardware del banco fisico (especifico del CSV que lee el simulador),
% no de la anatomia, y no aplica a esta herramienta de visualizacion
% independiente del CSV.
%
%   out = Cinematica_DoblePendulo_Core(theta1_rad, theta2_rad, L1, L2, Xh, Yh)
%
% ENTRADA (todo en las MISMAS unidades - la funcion es agnostica, ver
% nota de unidades abajo; [1 x n] o escalar, se expande por broadcasting):
%   theta1_rad, theta2_rad   angulos absolutos (rad) del muslo y la tibia
%   L1, L2                   longitudes de muslo y tibia (escalares
%                             positivos, mismas unidades que Xh/Yh)
%   Xh, Yh                   posicion instantanea de la cadera (mismas
%                             unidades que L1/L2) - escalar (cadera fija)
%                             o [1 x n]
%
% UNIDADES: agnostica - lo que le des es lo que devuelve (si L1/Xh estan
% en cm, la salida sale en cm; si estan en m, sale en m). El llamador
% (App_Animacion_Cadera_Rodilla_Tobillo.m) trabaja en CENTIMETROS de
% punta a punta y lo declara ahi, no aca.
%
% SALIDA: struct `out` con .Xk, .Yk, .Xa, .Ya - mismo tamano que la
% entrada de mayor largo (broadcast de escalares).
%
% Funciona con CUALQUIER longitud de arreglo (no asume 101 puntos).
% ==========================================================================

if nargin < 6
    error('Se requieren theta1_rad, theta2_rad, L1, L2, Xh, Yh.');
end

theta1_rad = theta1_rad(:).';
theta2_rad = theta2_rad(:).';
Xh = Xh(:).';
Yh = Yh(:).';

n = max([numel(theta1_rad), numel(theta2_rad), numel(Xh), numel(Yh)]);

campos = {'theta1_rad','theta2_rad','Xh','Yh'};
valores = {theta1_rad, theta2_rad, Xh, Yh};
for k = 1:numel(campos)
    v = valores{k};
    if ~isscalar(v) && numel(v) ~= n
        error('%s debe ser escalar o tener %d elementos (largo comun de la entrada). Se recibio %d.', ...
            campos{k}, n, numel(v));
    end
end

if ~(isnumeric(L1) && isscalar(L1) && L1 > 0)
    error('L1 debe ser un escalar positivo. Se recibio: %s', mat2str(L1));
end
if ~(isnumeric(L2) && isscalar(L2) && L2 > 0)
    error('L2 debe ser un escalar positivo. Se recibio: %s', mat2str(L2));
end

Xk = Xh + L1*sin(theta1_rad);
Yk = Yh - L1*cos(theta1_rad);
Xa = Xk + L2*sin(theta2_rad);
Ya = Yk - L2*cos(theta2_rad);

out = struct('Xk', Xk, 'Yk', Yk, 'Xa', Xa, 'Ya', Ya);

end
