function [cad_x_cm, cad_y_cm] = Cadera_Continua_Zhao_Core(t_u, T, tiempo_apoyo_s, ...
    th_m_trackeada_rad, th_t_trackeada_rad, th_m_contra_rad, th_t_contra_rad, Lm_cm, Lt_cm, X_step_cm)
% CADERA_CONTINUA_ZHAO_CORE  29-ago-2026: posicion de cadera (x,y, cm) para
% el ciclo COMPLETO, construida con una sola regla geometrica en vez de dos
% distintas cosidas a mano - la que de verdad usa Zhao et al. 2026 (Ecs.3-4,
% Fig.1-3): en cualquier instante, la cadera es el extremo superior de la
% pierna que en ESE instante esta en el piso, rotando sobre su tobillo FIJO
% (modelo de pendulo invertido) - nunca una traslacion a velocidad
% constante impuesta.
%
% POR QUE EXISTE ESTA FUNCION (diagnostico de la misma sesion, Diag_Pico_
% DobleApoyo.m): Cadena_Completa_Core.m (la fuente de verdad YA VALIDADA
% para RODILLA/TOBILLO contra Kuopio, r>0.98 - NO SE TOCA) reconstruye la
% cadera con DOS reglas distintas: rotacion sobre tobillo fijo en apoyo,
% traslacion a velocidad constante en balanceo. El angulo articular mismo
% (theta_tibia/theta_muslo, Koopman/Zhao/Yun) YA es una funcion suave y
% periodica de todo el ciclo (Obtener_Theta_Tibia_Candidato.m devuelve el
% MISMO arreglo completo para "apoyo" y "balanceo", solo remuestreado por
% tramos) - la discontinuidad de VELOCIDAD de cadera en los dos empalmes
% (60% y 0%/100% del ciclo) es enteramente un artefacto de esa costura
% geometrica, no del angulo. Se verifico numericamente: al derivar dos
% veces para GRF, ese quiebre produce un pico de ~-265%BW / +363%BW justo
% en las dos costuras (ver docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_
% Q1.md, seccion nueva de esta sesion). Esta funcion se usa SOLO dentro de
% GRF_Newton_ApoyoSimple_Core.m, no reemplaza a Cadena_Completa_Core.m en
% ningun otro lugar del proyecto.
%
% MODELO (fiel a Zhao 2026, con doble apoyo repartido linealmente igual que
% su Ec.9, aplicado aqui a POSICION en vez de a fuerza, por consistencia):
%   - Apoyo simple de la pierna TRACKEADA (fase_trackeada en
%     (T_DT, tiempo_apoyo_s-T_DT)): cadera = rotacion sobre el tobillo
%     trackeada, fijo en (0,0).
%   - Apoyo simple de la pierna CONTRALATERAL (fase_trackeada >=
%     tiempo_apoyo_s, o < 0 en el ciclo previo): cadera = rotacion sobre el
%     tobillo contralateral, fijo en (X_step_cm, 0) - X_step_cm = media
%     zancada, la separacion horizontal estandar entre apoyos alternados de
%     marcha simetrica (Zhao 2026 Sec.2.7 asume "complete symmetry between
%     the two lower limbs" - misma hipotesis, aplicada aqui a la posicion
%     del apoyo en vez de solo al angulo).
%   - Doble apoyo (las dos ventanas de duracion T_DT en los extremos del
%     apoyo de la trackeada): mezcla LINEAL de las dos formulas de rotacion
%     de arriba - construida para dar continuidad de VALOR exacta con la
%     region de apoyo simple adyacente en los 4 bordes internos y en el
%     cierre del ciclo (0%=100%). T_DT se deriva de tiempo_apoyo_s - T/2,
%     mismo criterio ya usado en el reparto de fuerza de doble apoyo de
%     GRF_Newton_ApoyoSimple_Core.m (no se importa el 12%/38% de Zhao, ver
%     esa funcion para la justificacion completa).
%
% INTENTO DE VERSION 2, PROBADO Y DESCARTADO EN ESTA MISMA SESION
% (29-ago-2026): la V1 de arriba (mezcla lineal) da un sobreimpulso real y
% visible (~140-165%BW en los bordes contra Kuopio, vs ~70-110%BW real) -
% el usuario lo detecto directamente en la figura. Se probo reemplazarla
% por el SISTEMA CERRADO real que describe Zhao ("the angles of all body
% segments are not entirely independent because the model forms a
% closed-loop structure", Sec.2.5): dos tobillos fijos a distancia
% conocida (X_step_cm), cada pierna con una longitud efectiva
% tobillo-a-cadera de ESE instante (ley de cosenos sobre el angulo real de
% rodilla) - cadera = interseccion de las 2 circunferencias. RESULTADO:
% peor, no mejor. La interseccion pura no conecta con las formulas de una
% pierna en los bordes de la ventana de doble apoyo (saltos de ~50cm);
% anclando el VALOR en los bordes con una correccion lineal arregla el
% salto pero deja un quiebre de PENDIENTE que el suavizado esparce en una
% franja mas ancha, produciendo un pico aislado de +200%BW cerca del 20%
% del ciclo y BAJANDO la correlacion real contra Kuopio (r: 0.40->0.29,
% `Evaluar_GRF_vs_Kuopio.m`). Se revirtio a V1 - ver el bloque de codigo de
% "temprano"/"tardio" mas abajo para el detalle completo de las 2
% variantes probadas y por que se descartaron.
%
% LIMITACION DECLARADA QUE QUEDA ABIERTA (no oculta, no resuelta esta
% sesion): ninguna de las 3 versiones probadas (velocidad constante
% original; mezcla lineal V1, la vigente; interseccion de circulos V2)
% resuelve el sistema realmente acoplado de las 2 piernas durante el doble
% apoyo (eso exigiria dinamica inversa de las 2 piernas simultaneas, o
% recalibrar los angulos de doble apoyo contra datos reales en vez de
% extrapolar el modelo de una sola pierna hasta ahi) - la V1 vigente sigue
% sobreestimando la Fz en los bordes del doble apoyo (~140-165%BW vs
% ~70-110%BW real, ver figura). La ventana de apoyo simple (sin doble
% apoyo, `apoyo_simple_mask_estricta`) SI es fiable y ya se valida bien
% contra Kuopio real - ver docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_
% Q1.md (entrada de esta sesion) para la recomendacion de como usar esto
% mientras no se resuelva del todo.
%
% ENTRADA: todo ya calculado por el llamador (GRF_Newton_ApoyoSimple_
% Core.m) - t_u,T en segundos; tiempo_apoyo_s en segundos; angulos en
% radianes, arreglos [1xN] sobre el grid uniforme de tiempo; Lm_cm,Lt_cm,
% X_step_cm en centimetros (escalares).
% SALIDA: cad_x_cm, cad_y_cm [1xN], mismo grid que t_u.
% ==========================================================================

T_DT = tiempo_apoyo_s - T/2;
if T_DT <= 0
    error('Cadera_Continua_Zhao_Core:fracApoyoInvalida', ...
        'tiempo_apoyo_s debe ser mayor que T/2 (frac_apoyo>0.5) para que haya ventana de doble apoyo real. Se recibio tiempo_apoyo_s=%.4f, T/2=%.4f.', tiempo_apoyo_s, T/2);
end

hip_x_trackeada = Lt_cm*sin(th_t_trackeada_rad) + Lm_cm*sin(th_m_trackeada_rad);
hip_y_trackeada = Lt_cm*cos(th_t_trackeada_rad) + Lm_cm*cos(th_m_trackeada_rad);

hip_y_contra = Lt_cm*cos(th_t_contra_rad) + Lm_cm*cos(th_m_contra_rad); % usado abajo, apoyo simple de la contralateral
% Anclas espaciales del contralateral (ver cabecera): paso anterior,
% detras (-X_step, usado como referencia de borde en "temprano") y paso
% siguiente, adelante (+X_step, usado en "tardio" y en "resto").
hip_x_contra_trailing = -X_step_cm + Lt_cm*sin(th_t_contra_rad) + Lm_cm*sin(th_m_contra_rad);
hip_x_contra_leading  =  X_step_cm + Lt_cm*sin(th_t_contra_rad) + Lm_cm*sin(th_m_contra_rad);

fase = mod(t_u, T);
cad_x_cm = nan(size(t_u));
cad_y_cm = nan(size(t_u));

% --- temprano: [0, T_DT) - doble apoyo real. SE PROBARON 2 VERSIONES en
% esta misma sesion (29-ago-2026) para esta ventana y la de "tardio":
%   V2a: interseccion pura de circulos (2 tobillos fijos, radio=longitud
%        efectiva de cada pierna) - descartada: no conecta con las formulas
%        de una pierna en los bordes (saltos de ~50cm, picos de GRF de
%        cientos de %BW, PEOR que V1).
%   V2b: V2a + correccion lineal que ancla el VALOR exactamente en los
%        bordes - descartada tambien: elimina el salto de valor pero deja
%        un quiebre de PENDIENTE que el suavizado esparce en una franja mas
%        ancha del ciclo, produciendo un pico aislado de +200%BW cerca del
%        20% del ciclo (visible en Ver_GRF_vs_Kuopio_Real_figura.png) y
%        BAJANDO la correlacion contra Kuopio real (r 0.40->0.29,
%        Evaluar_GRF_vs_Kuopio.m) - peor en la metrica que de verdad
%        importa, no solo distinto.
% Se vuelve a V1 (mezcla LINEAL de las 2 formulas de una sola pierna,
% ninguna interseccion de circulos) - es la que de las 3 probadas da la
% mejor correlacion real (r=0.40) y no produce picos aislados >200%BW,
% aunque sigue teniendo un sobreimpulso real y visible en los bordes
% (~140-165%BW vs ~70-110%BW real) que no se resolvio esta sesion - ver
% limitacion declarada en la cabecera y docs/algoritmo/JUSTIFICACION_
% MODELOS_Y_ESTADO_Q1.md (entrada de esta sesion) para la discusion
% completa de por que un cierre completo del sistema (2 piernas mutuamente
% consistentes) no se logro con los 3 intentos de esta sesion. ---
m1 = fase < T_DT;
w1 = fase(m1) / T_DT;
cad_x_cm(m1) = (1-w1).*hip_x_contra_trailing(m1) + w1.*hip_x_trackeada(m1);
cad_y_cm(m1) = (1-w1).*hip_y_contra(m1)          + w1.*hip_y_trackeada(m1);

% --- apoyo simple de la trackeada: [T_DT, tiempo_apoyo_s-T_DT) - un solo
% tobillo en el piso, la cadera queda determinada por el angulo (no solo
% la distancia) de la propia pierna trackeada. ---
m2 = fase >= T_DT & fase < (tiempo_apoyo_s - T_DT);
cad_x_cm(m2) = hip_x_trackeada(m2);
cad_y_cm(m2) = hip_y_trackeada(m2);

% --- tardio: [tiempo_apoyo_s-T_DT, tiempo_apoyo_s) - mismo criterio V1 que "temprano". ---
m3 = fase >= (tiempo_apoyo_s - T_DT) & fase < tiempo_apoyo_s;
w3 = (fase(m3) - (tiempo_apoyo_s - T_DT)) / T_DT;
cad_x_cm(m3) = (1-w3).*hip_x_trackeada(m3) + w3.*hip_x_contra_leading(m3);
cad_y_cm(m3) = (1-w3).*hip_y_trackeada(m3) + w3.*hip_y_contra(m3);

% --- resto del ciclo: apoyo simple de la contralateral, paso siguiente
% (trackeada en su propio balanceo) - [tiempo_apoyo_s, T) - un solo
% tobillo en el piso (contralateral, en +X_step_cm), la cadera queda
% determinada por el angulo de la pierna contralateral. ---
m4 = fase >= tiempo_apoyo_s;
cad_x_cm(m4) = X_step_cm + Lt_cm*sin(th_t_contra_rad(m4)) + Lm_cm*sin(th_m_contra_rad(m4));
cad_y_cm(m4) = hip_y_contra(m4);

if any(isnan(cad_x_cm)) || any(isnan(cad_y_cm))
    error('Cadera_Continua_Zhao_Core:mascaraIncompleta', ...
        'Las 4 mascaras de fase no cubrieron el ciclo completo - revisar limites (posible error de punto flotante en fase==limite exacto).');
end

end
