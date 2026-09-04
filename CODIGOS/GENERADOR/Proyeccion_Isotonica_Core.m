function yhat = Proyeccion_Isotonica_Core(y, w)
% PROYECCION_ISOTONICA_CORE  02-sep-2026 (aporte propio, PAVA estandar):
%   proyecta cualquier curva 1D sobre el conjunto de curvas NO DECRECIENTES
%   -- la mas cercana en minimos cuadrados PONDERADOS. Metodo: Pool
%   Adjacent Violators Algorithm (PAVA) PONDERADO, resultado estandar y
%   consolidado de estadistica de orden restringido (Barlow, Bartholomew,
%   Bremner & Brunk 1972, "Statistical Inference under Order Restrictions"
%   -- el caso ponderado, no solo el caso simple, esta cubierto ahi mismo;
%   tambien Ayer et al. 1955, el primer paper del metodo). NO es una idea
%   nueva de este proyecto -- la implementacion (bucle con pila de
%   "pools") si es propia, escrita para este caso (n=101, sin
%   dependencias de toolbox).
%
% AGREGADO 02-sep-2026, segundo hallazgo (el usuario lo pidio verificar
% explicitamente): el PAVA sin ponderar, aplicado por separado a cada
% sujeto/talla, NO preserva la monotonia EN TALLA del avance final (a
% mayor talla, igual o mayor avance) que si estaba garantizada para
% warp+afin solo (Correccion_Hibrida_PenduloDoble_Core.m, b0>0). Se
% encontraron 4-5 violaciones reales en un barrido 100-230cm, TODAS en
% tallas <=114cm (muy por debajo del minimo de la app, 130cm) -- causadas
% porque a esa talla el CRUDO ya trae 55-65 retrocesos de 100 (muy
% distorsionado), y el PAVA sin ponderar puede mover el ULTIMO punto
% (el avance total del ciclo) al fusionarlo en un pool grande.
% SOLUCION: version PONDERADA del PAVA, con el ultimo punto (t=100%, el
% avance final) con un peso MUY grande -- efectivamente lo "fija" en su
% valor de warp+afin (que YA tenia la garantia de monotonia en talla, por
% construccion geometrica, r=1.000 entre talla y crudo(100%)) mientras el
% PAVA sigue reordenando libremente los puntos INTERMEDIOS para
% garantizar monotonia en el tiempo. No es una alteracion del metodo --
% "PAVA ponderado con un peso muy grande en un punto" sigue siendo la
% MISMA solucion exacta de minimos cuadrados ponderados sujeta a
% monotonia, con un peso mas en la formula, no una regla nueva agregada
% por fuera.
%
% POR QUE EXISTE (limite real del warp temporal, Warp_Temporal_Core.m):
% el warp SOLO puede preservar la monotonia que el crudo YA TENIA -- la
% propiedad que usa (d/dt[crudo(tau(t))] = crudo'(tau(t))*tau'(t), con
% tau'>0 siempre) hace que el SIGNO del resultado dependa enteramente de
% crudo'. Si el crudo geometrico (Cinematica_DoblePendulo_Core.m +
% Koopman, extrapolado fuera de su rango de velocidad validado) YA trae
% un retroceso local -- verificado con datos reales: 3 de 47 sujetos de
% Kuopio en el borde de talla 161-165cm, y mas retrocesos en tallas
% sinteticas fuera de 161-186.6cm (ver GUIA_INTERPRETACION.md) -- el warp
% no puede eliminarlo, solo reordenar CUANDO aparece. Por eso "0
% retrocesos" con warp solo es una garantia CONDICIONAL (si el crudo ya
% era monotono), no universal.
%
% ESTA FUNCION cierra esa brecha: aplicada DESPUES del warp, sobre
% CUALQUIER curva de entrada (monotona o no), garantiza una salida NO
% DECRECIENTE siempre -- por construccion matematica del propio PAVA (es
% la solucion exacta, no aproximada, de min ||yhat-y||^2 sujeto a
% yhat(1)<=yhat(2)<=...<=yhat(n)), no una heuristica. Es IDEMPOTENTE sobre
% entradas ya monotonas (si y ya es no decreciente, PAVA regresa y
% intacto, sin distorsion) -- por eso aplicarla SIEMPRE, sin condicion, no
% cambia nada en los casos ya limpios (la inmensa mayoria) y solo
% interviene exactamente donde hace falta.
%
%   yhat = Proyeccion_Isotonica_Core(y)
%   yhat = Proyeccion_Isotonica_Core(y, w)
%
% ENTRADA
%   y      [1 x n] o [n x 1] curva cualquiera (ej.: salida de
%          Correccion_Hibrida_PenduloDoble_Core.m, Xk o Xa)
%   w      (opcional) [1 x n] o [n x 1] pesos, default todos = 1 (PAVA
%          simple, sin cambio de comportamiento respecto a la version
%          anterior). Un peso grande en un punto lo "fija" -- lo protege
%          de moverse por una fusion, sin dejar de participar en las
%          fusiones que arrastran a los DEMAS puntos hacia el orden
%          correcto.
%
% SALIDA
%   yhat   misma forma que y, garantizado NO DECRECIENTE (yhat(i+1)>=yhat(i)
%          para todo i), la mas cercana a y en el sentido de minimos
%          cuadrados entre todas las curvas no decrecientes posibles.
%
% ALGORITMO (PAVA, version "pila" -- O(n), sin toolbox):
%   Se recorre y de izquierda a derecha manteniendo una pila de "pools"
%   (nivel promedio, peso=numero de puntos fusionados). Si el nuevo punto
%   viola el orden respecto al ultimo pool (nivel nuevo < nivel del pool
%   anterior), se fusionan (promedio ponderado) hasta que el orden se
%   restablece -- exactamente la definicion del algoritmo, no una
%   aproximacion.
% ==========================================================================

forma_original = size(y);
y = y(:);
n = numel(y);
if nargin < 2 || isempty(w)
    w = ones(n,1);
else
    w = w(:);
    if numel(w) ~= n, error('w debe tener el mismo numero de elementos que y.'); end
end
if n <= 1
    yhat = reshape(y, forma_original);
    return;
end

nivel = zeros(n,1); peso = zeros(n,1); inicio = zeros(n,1);
m = 0;   % numero de pools activos en la pila

for i = 1:n
    cur_nivel = y(i); cur_peso = w(i); cur_inicio = i;
    while m > 0 && nivel(m) > cur_nivel
        % viola el orden -> fusionar con el pool anterior (promedio ponderado)
        cur_nivel = (nivel(m)*peso(m) + cur_nivel*cur_peso) / (peso(m) + cur_peso);
        cur_peso  = peso(m) + cur_peso;
        cur_inicio = inicio(m);
        m = m - 1;
    end
    m = m + 1;
    nivel(m) = cur_nivel; peso(m) = cur_peso; inicio(m) = cur_inicio;
end

% expandir los m pools de vuelta a los n puntos originales
yhat = zeros(n,1);
finales = [inicio(2:m)-1; n];
for j = 1:m
    yhat(inicio(j):finales(j)) = nivel(j);
end

yhat = reshape(yhat, forma_original);   % conserva fila/columna de la entrada original

end
