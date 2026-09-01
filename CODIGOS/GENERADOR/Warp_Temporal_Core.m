function tau = Warp_Temporal_Core(pct, gcoef, K)
% WARP_TEMPORAL_CORE  31-ago-2026 (aporte propio del proyecto): resuelve
%   la deformacion temporal (time-warp) que usa Correccion_Hibrida_
%   PenduloDoble_Core.m para corregir las curvas de AVANCE (X, rodilla y
%   tobillo) sin poder introducir retrocesos - a diferencia de la
%   correccion de amplitud (Correccion_Posicion_Suave_PenduloDoble_
%   Core.m, Fourier K=14), que SI puede (Diag_Retrocesos_X.m: hasta
%   22/100 pasos negativos en tobillo X).
%
% LA ECUACION DIFERENCIAL (por que esto SI es una ecuacion diferencial,
% no solo una funcion suave mas): se busca una reparametrizacion del
% tiempo tau(t) que nunca retroceda -- eso significa que su DERIVADA
% tiene que ser siempre positiva. La forma mas directa de garantizar
% "siempre positiva" sin imponerlo como restriccion de optimizacion (que
% podria fallar o quedar en el borde) es parametrizar la derivada como
% una EXPONENCIAL de una funcion libre:
%
%   dtau/dt = w(t) = exp(g(t)) > 0  SIEMPRE (para cualquier g real)
%   tau(0)  = 0
%
% g(t) es una serie de Fourier (K armonicos, misma base ya usada en el
% proyecto para Correccion_Posicion_Suave_PenduloDoble_Core.m). Como
% exp(x)>0 para cualquier x real, tau(t) es ESTRICTAMENTE CRECIENTE por
% CONSTRUCCION matematica, no por resultado empirico de un ajuste -- es
% la propiedad que hace que este metodo garantice cero retrocesos
% "nuevos" en cualquier curva que ya era monotona antes de aplicarlo
% (composicion de funciones monotonas es monotona: si crudo(s) no
% retrocede en s, entonces crudo(tau(t)) tampoco retrocede en t, porque
% d/dt[crudo(tau(t))] = crudo'(tau(t))*tau'(t), y tau'(t)>0 siempre).
%
% La ecuacion diferencial se resuelve NUMERICAMENTE por cuadratura
% (integral acumulada, cumtrapz) en vez de un solver tipo ode45 -- es
% valido y mas rapido aqui porque dtau/dt=w(t) NO depende de tau (es una
% ODE de primer orden ya separada, tau(t)=tau(0)+integral de w desde 0
% a t), no hace falta un solver iterativo de paso variable.
%
% CIERRE DE CICLO: se reescala tau para que tau(100)=100 exacto (dividir
% por tau_bruto(100)/100) -- garantiza que el warp respeta el mismo
% ciclo de 0 a 100% que todo lo demas del proyecto, sin necesitar una
% restriccion aparte.
%
% ORIGEN: idea propia del proyecto (pedido explicito del usuario,
% 31-ago-2026, "algo matematico... algoritmo de ecuaciones diferenciales
% en caso aplique"), no tomada de una fuente publicada especifica -- el
% principio general (deformar el TIEMPO de una curva en vez de su
% AMPLITUD para alinearla con una referencia) es un area establecida de
% estadistica funcional conocida como "registro de curvas"/"curve
% registration" o "dynamic time warping" (ver p.ej. Ramsay & Silverman,
% "Functional Data Analysis"), pero la formulacion exacta de aqui
% (dtau/dt=exp(g(t)) con g Fourier, mas afin global dependiente de
% velocidad en Correccion_Hibrida_PenduloDoble_Core.m) es una
% implementacion propia para este problema, no una copia de un metodo
% publicado con ese nombre exacto.
%
%   tau = Warp_Temporal_Core(pct, gcoef, K)
%
% ENTRADA
%   pct     [1 x n] % del ciclo, 0-100 (mismo grid que el resto del proyecto)
%   gcoef   [2K x 1] coeficientes de la serie de Fourier de g(t):
%           g(t) = sum_{k=1}^{K} gcoef(2k-1)*cos(k*w) + gcoef(2k)*sin(k*w),
%           w = 2*pi*pct/100. SIN termino constante (gcoef no lo trae) --
%           un termino constante en g solo reescala w(t) por un factor
%           multiplicativo, que la normalizacion de cierre (tau(100)=100)
%           cancela exactamente - agregarlo seria un parametro libre sin
%           efecto, well-known en optimizacion como no-identificable.
%   K       numero de armonicos (escalar entero positivo)
%
% SALIDA
%   tau     [1 x n] tiempo deformado, tau(1)=0, tau(end)=100, ESTRICTAMENTE
%           creciente.
%
% Funciona con cualquier longitud de pct siempre que gcoef/K sean
% consistentes (2*K elementos).
% ==========================================================================

if nargin < 3
    error('Se requieren pct, gcoef, K.');
end
if numel(gcoef) ~= 2*K
    error('gcoef debe tener 2*K=%d elementos. Se recibio %d.', 2*K, numel(gcoef));
end

pct = pct(:).';
n = numel(pct);
Phi = zeros(n, 2*K);
w_ang = 2*pi*pct/100;
for k = 1:K
    Phi(:, 2*k-1) = cos(k*w_ang);
    Phi(:, 2*k)   = sin(k*w_ang);
end

g = Phi * gcoef(:);
w = exp(g(:).');           % SIEMPRE positivo -> dtau/dt > 0 siempre
tau_bruto = cumtrapz(pct, w);   % integral acumulada = solucion de la ODE, tau(0)=0
tau = tau_bruto * 100 / tau_bruto(end);   % cierra el ciclo: tau(100)=100 exacto

end
