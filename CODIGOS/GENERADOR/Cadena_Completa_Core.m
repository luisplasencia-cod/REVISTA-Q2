function out = Cadena_Completa_Core(theta_muslo_rad, theta_tibia_rad, L_muslo_m, L_tibia_m, tempo, n)
% CADENA_COMPLETA_CORE  Cadena cinematica COMPLETA cadera->muslo->rodilla->
%                   tibia->tobillo (24-ago-2026). Reemplaza, para efectos
%                   de posicion, al modelo de "tobillo pivote fijo todo el
%                   ciclo" de Cadena_Cinematica_Core.m, que producia tres
%                   artefactos que el usuario detecto mirando las graficas:
%                     (1) el TOBILLO quedaba a altura constante todo el
%                         ciclo (en la marcha real el pie se levanta en
%                         balanceo);
%                     (2) la RODILLA "regresaba" al final del balanceo
%                         (bucle en la vista sagital), porque la rotacion
%                         del segmento restaba mas de lo que sumaba el
%                         avance a velocidad constante;
%                     (3) corr(angulo,Y) contra Control_apoyo_Luis_V4.csv
%                         real caia a ~0 (Test 15), porque Y=L*cos(theta)
%                         es una funcion PAR y el angulo cruza el cero.
%                   Las tres tienen la MISMA causa: tratar el tobillo como
%                   pivote rigido durante TODO el ciclo.
%
% MODELO (estandar de marcha, no inventado aqui - es la cadena cinematica
% clasica; lo unico que se elige es el punto de anclaje por fase):
%   - APOYO: el pie esta plantado. El tobillo es el pivote, FIJO en el
%     piso (y=0). Se construye hacia ARRIBA:
%         rodilla = tobillo + (-L_t*sin(th_t), +L_t*cos(th_t))
%         cadera  = rodilla + (-L_m*sin(th_m), +L_m*cos(th_m))
%     (misma convencion de signo ya verificada en G7,
%     Cadena_Cinematica_Core.m: theta=0 -> vertical, X invertido)
%   - BALANCEO: el pie esta en el aire, la pierna CUELGA de la cadera. La
%     cadera avanza a la velocidad de marcha (aproximacion razonable: la
%     cadera es el segmento que menos oscila en avance). Se construye
%     hacia ABAJO desde la cadera:
%         rodilla = cadera  + (+L_m*sin(th_m), -L_m*cos(th_m))
%         tobillo = rodilla + (+L_t*sin(th_t), -L_t*cos(th_t))
%     Asi el tobillo SE LEVANTA solo (por la flexion de rodilla), sin
%     necesidad de imponer ninguna curva de elevacion inventada.
%   - EMPALME: el balanceo arranca con la cadera exactamente donde la
%     dejo el apoyo -> la cadera queda continua en todo el ciclo, y con
%     ella toda la cadena.
%
% ENTRADA
%   theta_muslo_rad, theta_tibia_rad   [1 x n] por fase, ya recortados
%       (structs con campos .apoyo y .balanceo, cada uno [1 x n])
%   L_muslo_m, L_tibia_m   longitudes de segmento (m)
%   tempo                  struct de Temporizacion_Core (usa
%                          .velocidad_ms, .tiempo_apoyo_s, .tiempo_balanceo_s)
%   n                      puntos por fase
%
% SALIDA: struct `out` con .apoyo y .balanceo, cada uno con
%   .cadera_x_cm, .cadera_y_cm, .rodilla_x_cm, .rodilla_y_cm,
%   .tobillo_x_cm, .tobillo_y_cm
%   (X = avance horizontal, Y = altura; y=0 = nivel del piso en apoyo)
% ==========================================================================

L_m = L_muslo_m * 100;  % cm
L_t = L_tibia_m * 100;

th_m_ap  = theta_muslo_rad.apoyo(:).';
th_t_ap  = theta_tibia_rad.apoyo(:).';
th_m_bal = theta_muslo_rad.balanceo(:).';
th_t_bal = theta_tibia_rad.balanceo(:).';

% ---------- APOYO: anclado en el tobillo (pivote en el piso) ----------
tob_x_ap = zeros(1,n);
tob_y_ap = zeros(1,n);
rod_x_ap = tob_x_ap - L_t*sin(th_t_ap);
rod_y_ap = tob_y_ap + L_t*cos(th_t_ap);
cad_x_ap = rod_x_ap - L_m*sin(th_m_ap);
cad_y_ap = rod_y_ap + L_m*cos(th_m_ap);

% ---------- BALANCEO: anclado en la cadera, que avanza ----------
% La cadera continua desde donde quedo al final del apoyo, avanzando a la
% velocidad de marcha. Su ALTURA se mantiene en el nivel que traia (la
% oscilacion vertical real de la cadera es de pocos cm y no se modela
% aqui - se declara, no se inventa).
t_bal = linspace(0, tempo.tiempo_balanceo_s, n);
cad_x_bal = cad_x_ap(end) + tempo.velocidad_ms * 100 * t_bal;
cad_y_bal = cad_y_ap(end) * ones(1,n);

rod_x_bal = cad_x_bal + L_m*sin(th_m_bal);
rod_y_bal = cad_y_bal - L_m*cos(th_m_bal);
tob_x_bal = rod_x_bal + L_t*sin(th_t_bal);
tob_y_bal = rod_y_bal - L_t*cos(th_t_bal);

out = struct();
out.apoyo = struct('cadera_x_cm',cad_x_ap, 'cadera_y_cm',cad_y_ap, ...
                   'rodilla_x_cm',rod_x_ap,'rodilla_y_cm',rod_y_ap, ...
                   'tobillo_x_cm',tob_x_ap,'tobillo_y_cm',tob_y_ap);
out.balanceo = struct('cadera_x_cm',cad_x_bal, 'cadera_y_cm',cad_y_bal, ...
                      'rodilla_x_cm',rod_x_bal,'rodilla_y_cm',rod_y_bal, ...
                      'tobillo_x_cm',tob_x_bal,'tobillo_y_cm',tob_y_bal);

end
