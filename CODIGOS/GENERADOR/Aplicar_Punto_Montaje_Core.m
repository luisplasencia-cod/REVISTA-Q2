function out = Aplicar_Punto_Montaje_Core(Xa_cm, Ya_cm, Xk_cm, Yk_cm, d_montaje_cm)
% APLICAR_PUNTO_MONTAJE_CORE  Posicion del punto de montaje de una protesis
%                   transtibial sobre el segmento tibial, a una distancia
%                   d_montaje_cm medida DESDE EL TOBILLO hacia la rodilla
%                   (convencion elegida por el usuario, 02-sep-2026, sesion
%                   de integracion con GAITSIM/Raspberry) - NO desde la
%                   rodilla.
%
% DEFINICION (REESCRITA 03-sep-2026, decision del usuario - ver abajo por
% que cambio): el punto se define SOBRE EL SEGMENTO QUE FORMAN LOS DOS
% PUNTOS YA GENERADOS (tobillo y rodilla), caminando d_montaje_cm desde el
% tobillo en direccion a la rodilla:
%
%     u  = (Pk - Pa) / |Pk - Pa|        (vector unitario tobillo->rodilla)
%     Pm = Pa + d_montaje_cm * u
%
% Propiedades, exactas por construccion (verificadas en Test_Punto_Montaje.m):
%   - |Pm - Pa| = d_montaje_cm SIEMPRE (la protesis es un tubo rigido: su
%     longitud no cambia durante el ciclo).
%   - Pm cae EXACTAMENTE sobre el segmento Pa-Pk siempre.
%   - d=0 -> Pm = Pa (el tobillo, no-op). d=|Pk-Pa| -> Pm = Pk (la rodilla).
%
% POR QUE CAMBIO (03-sep-2026): la version anterior caminaba d en la
% direccion de theta_tibia (el angulo del MODELO) en vez de la direccion
% de la rodilla ya generada. Mientras la geometria es rigida las dos cosas
% coinciden exactamente - pero DESPUES de Correccion_Hibrida_PenduloDoble_
% Core.m no coinciden, porque esa correccion mueve rodilla y tobillo por
% separado y el segmento corregido ya no mide L_tibia ni apunta en
% direccion theta_tibia (se desvia hasta 5.2% en longitud y 7.6 grados en
% direccion, medido en el rango de la app). Consecuencia: el punto quedaba
% fuera del segmento, hasta 2.5 cm de donde debia estar para d=20 cm.
% Con la definicion de arriba el problema desaparece: las dos propiedades
% (distancia exacta Y sobre el segmento) se cumplen a la vez, porque la
% direccion se toma de los puntos reales y no de un angulo que ya no les
% corresponde. Ver GUIA_INTERPRETACION.md #11.
%
% RESTRICCION (la que senalo el usuario, y que hace innecesario todo lo
% demas): d_montaje_cm tiene que ser MENOR que la longitud del segmento en
% todo el ciclo. Se valida contra el segmento REAL (min sobre el ciclo),
% no contra L_tibia nominal - despues de la correccion el segmento real es
% lo unico que existe. En la aplicacion real el eje de prueba mide 15-24 cm
% y el segmento tibial generado es de ~28 cm para arriba en todo el rango
% de talla de la app (1.30-2.10 m), asi que hay margen de sobra.
%
% CONVENCION DE EJES - IMPORTANTE, NO MEZCLAR CON OTRA FUNCION:
%   Trabaja directamente con las coordenadas de Cinematica_DoblePendulo_
%   Core.m (Y positivo = HACIA ARRIBA), la convencion "de libro de texto"
%   verificada en la app interactiva (App_Animacion_Cadera_Rodilla_
%   Tobillo.m) y confirmada por el usuario como coincidente con la maquina
%   fisica de GAITSIM. Al tomar la direccion de los propios puntos, esta
%   funcion ya no depende de ninguna convencion de signo de angulo.
%
%   Esto sigue siendo DISTINTO de opciones.punto_seguimiento_m de
%   Cadena_Cinematica_Core.m/Generar_Trayectoria.m, que implementa el mismo
%   concepto para el pipeline de exportacion a CSV, con una inversion de
%   signo en X propia del cableado del banco fisico (ver "NOTA DE SIGNO" en
%   la cabecera de esa funcion). No usar el resultado de esta funcion como
%   si fuera compatible con el CSV del simulador sin verificar el signo de X.
%
%   out = Aplicar_Punto_Montaje_Core(Xa_cm, Ya_cm, Xk_cm, Yk_cm, d_montaje_cm)
%
% ENTRADA
%   Xa_cm, Ya_cm    posicion del TOBILLO (cm), [1 x n] o escalar - salida
%                    .Xa/.Ya de Cinematica_DoblePendulo_Core.m, YA con la
%                    correccion de posicion aplicada si se va a usar.
%   Xk_cm, Yk_cm    posicion de la RODILLA (cm), misma forma que el tobillo
%                    y en el MISMO sistema de coordenadas (ojo: si las
%                    curvas vienen normalizadas cada una a su propio cero,
%                    hay que reponer los offsets antes de llamar aqui - ver
%                    INCLINACION_TIBIAL/CIERRE_INCLINACION_TIBIAL.md Sec.3).
%   d_montaje_cm    escalar >= 0, distancia (cm) desde el tobillo hasta el
%                    punto de montaje, a lo largo del segmento.
%
% SALIDA: struct `out` con
%   .Xm_cm, .Ym_cm       posicion del punto de montaje, misma forma que la entrada
%   .L_segmento_cm       longitud del segmento tobillo-rodilla en cada instante
%   .fraccion            d_montaje_cm ./ L_segmento_cm (0=tobillo, 1=rodilla)
% ==========================================================================

if nargin < 5
    error(['Se requieren 5 argumentos: (Xa_cm, Ya_cm, Xk_cm, Yk_cm, d_montaje_cm). ' ...
           'FIRMA NUEVA desde 03-sep-2026: antes era (Xa, Ya, theta_tibia_rad, d, L_tibia) - ' ...
           'ahora el punto se define sobre el segmento tobillo-rodilla real, no sobre el angulo del modelo. ' ...
           'Ver la cabecera de Aplicar_Punto_Montaje_Core.m.']);
end

% Deteccion de llamada con la firma VIEJA (Xa, Ya, theta, d, L): ahi el 4to
% argumento era un ESCALAR (d) mientras que aqui es un vector del mismo
% tamano que el tobillo. Error explicito en vez de resultados silenciosamente
% equivocados (hay otra sesion trabajando sobre la app, 03-sep-2026).
if numel(Xa_cm) > 1 && isscalar(Yk_cm)
    error(['Parece una llamada con la FIRMA VIEJA (Xa, Ya, theta_tibia_rad, d_montaje_cm, L_tibia_cm). ' ...
           'Desde 03-sep-2026 la firma es (Xa_cm, Ya_cm, Xk_cm, Yk_cm, d_montaje_cm): el punto se define ' ...
           'sobre el segmento que forman el tobillo y la rodilla YA generados, no con el angulo del modelo ' ...
           '(que despues de la correccion de posicion ya no apunta hacia la rodilla). Ver la cabecera.']);
end

if ~(isnumeric(d_montaje_cm) && isscalar(d_montaje_cm) && d_montaje_cm >= 0)
    error('d_montaje_cm debe ser un escalar >= 0 (cm). Se recibio: %s', mat2str(d_montaje_cm));
end

Xa_cm = Xa_cm(:).';  Ya_cm = Ya_cm(:).';
Xk_cm = Xk_cm(:).';  Yk_cm = Yk_cm(:).';
if ~isequal(size(Xa_cm), size(Ya_cm), size(Xk_cm), size(Yk_cm))
    error('Xa_cm, Ya_cm, Xk_cm, Yk_cm deben tener el mismo tamano.');
end

vx = Xk_cm - Xa_cm;
vy = Yk_cm - Ya_cm;
L_seg = sqrt(vx.^2 + vy.^2);

if any(L_seg < 1e-9)
    error('El segmento tobillo-rodilla tiene longitud ~0 en algun instante - revisar que ambos puntos esten en el MISMO sistema de coordenadas (offsets repuestos).');
end
if d_montaje_cm > min(L_seg) + 1e-9
    error(['d_montaje_cm (%.2f cm) excede la longitud del segmento tobillo-rodilla en algun instante ' ...
           '(minimo del ciclo: %.2f cm) - el punto de montaje quedaria mas alla de la rodilla. ' ...
           'Reducir d_montaje_cm (el eje de prueba real mide 15-24 cm).'], d_montaje_cm, min(L_seg));
end

out = struct();
out.Xm_cm = Xa_cm + d_montaje_cm * (vx ./ L_seg);
out.Ym_cm = Ya_cm + d_montaje_cm * (vy ./ L_seg);
out.L_segmento_cm = L_seg;
out.fraccion = d_montaje_cm ./ L_seg;

end
