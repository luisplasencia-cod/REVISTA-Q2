% ⚠️ SUPERADO 31-ago-2026 (tarde-noche) — NO RE-EJECUTAR sin querer.
% Este script ajusta los coeficientes con ANTROPOMETRIA/VELOCIDAD REALES
% de Kuopio (linea "load(...,'S_all','pct')" de abajo trae ese ajuste
% viejo) - si se corre, SOBREESCRIBE Coeficientes_CorreccionFinal.mat con
% la version vieja y rompe la consistencia app<->informe que se arreglo
% esta sesion (verificada con diferencia <1e-9cm). El script vigente,
% que SI usa solo talla (igual que la app), es Refit_CorreccionFinal_
% TallaSola.m - ese es el que hay que correr si hace falta regenerar
% Coeficientes_CorreccionFinal.mat. Se conserva este archivo por
% trazabilidad de la busqueda de familia de correccion (Fases 4-6), no
% para volver a correr.
%
% CALCULAR_COEFICIENTES_CORRECCIONFINAL  31-ago-2026: coeficientes de
% PRODUCCION (ajuste con los 44 sujetos juntos, sin dejar ninguno afuera
% - no es LOSO, es el ajuste final para desplegar en un sujeto nuevo) de
% la correccion FINAL confirmada por el usuario: angulo LOSO (ciclo
% completo, refit propio con N=44 - NO reusa los coeficientes viejos de
% Calibracion_Koopman_Kuopio_Core.m, que eran de N=13) + correccion de
% posicion SUAVE (Fourier periodico, K=14) ajustada sobre esa base ya
% corregida en angulo.
%
% Reusa el patron ya establecido en el proyecto (Calibracion_Koopman_
% Kuopio_Core.m): LOSO para VALIDAR (ya hecho, Fases 4-6), ajuste
% agrupado completo para DESPLEGAR.

carpeta = fileparts(mfilename('fullpath'));
load(fullfile(carpeta, 'Analisis_Correccion_resultados.mat'), 'S_all','pct');
N = numel(S_all); n = numel(pct);
campos_curva = {'RodX','RodY','TobX','TobY'};
K = 14;

% --- angulo: REUSA Calibracion_Koopman_Kuopio_Core.m (ya establecido y
% documentado en el informe, Seccion "Calibracion", N=13 produccion) -
% NO se recalcula de cero, para no duplicar esa pieza ni generar
% inconsistencia con lo ya citado. Los coeficientes de un refit propio
% con N=44 (probado en Fase4/Fase6 solo para VALIDAR la combinacion)
% salieron muy cercanos a estos (muslo -2.59 vs -2.00 grados, 0.79 vs
% 0.76 de ganancia; tibia -11.83 vs -11.35 grados, 0.85 vs 0.81 de
% ganancia) - la diferencia practica en la posicion final es minima.
calAngulo = Calibracion_Koopman_Kuopio_Core();
a1 = deg2rad(calAngulo.off_muslo_deg); b1 = calAngulo.gan_muslo;
a2 = deg2rad(calAngulo.off_tibia_deg); b2 = calAngulo.gan_tibia;
fprintf('Angulo (reusado de Calibracion_Koopman_Kuopio_Core.m): muslo a=%.4f b=%.4f | tibia a=%.4f b=%.4f\n', ...
    rad2deg(a1), b1, rad2deg(a2), b2);

% --- posicion, sobre la base ya angulo-corregida, para todos los 44 ---
pos_all = struct('RodX',nan(N,n),'RodY',nan(N,n),'TobX',nan(N,n),'TobY',nan(N,n));
for k = 1:N
    s = S_all(k);
    th1 = a1 + b1*s.theta1_koop; th2 = a2 + b2*s.theta2_koop;
    p = correr_pendulo(th1, th2, s, pct);
    for c = 1:4, pos_all.(campos_curva{c})(k,:) = p.(campos_curva{c}); end
end

coefPos = struct();
for c = 1:4
    camp = campos_curva{c};
    reales = cell2mat(arrayfun(@(k) S_all(k).(['Real' camp]), 1:N, 'uni', 0)');
    coefPos.(camp) = fit_fourier_afin(pct, pos_all.(camp), reales, K);
end

coefAngulo = struct('a1_deg', rad2deg(a1), 'b1', b1, 'a2_deg', rad2deg(a2), 'b2', b2);
save(fullfile(carpeta, 'Coeficientes_CorreccionFinal.mat'), 'coefAngulo', 'coefPos', 'K');

fprintf('Coeficientes de posicion (Fourier K=%d) calculados para: %s\n', K, strjoin(campos_curva, ', '));
for c = 1:4
    camp = campos_curva{c};
    fprintf('%s: %d coeficientes (A: %d, B: %d)\n', camp, numel(coefPos.(camp)), 2*K+1, 2*K+1);
end

function pos = correr_pendulo(theta1, theta2, s, pct)
cad = Trayectoria_Cadera_Core(pct, s.zancada_cm, 2.25, 0);
p = Cinematica_DoblePendulo_Core(theta1, theta2, s.L1_cm, s.L2_cm, cad.Xh_cm, cad.Yh_cm);
pos = struct();
pos.RodX = p.Xk - p.Xk(1); pos.RodY = p.Yk - p.Yk(1);
pos.TobX = p.Xa - p.Xa(1); pos.TobY = p.Ya - p.Ya(1);
end

function [a,b] = fit_afin(xk, xr)
p = polyfit(xk(:), xr(:), 1);
b = p(1); a = p(2);
end

function coef = fit_fourier_afin(pct, crudos, reales, K)
Nsuj = size(crudos,1);
Phi = fourier_base(pct, K);
Xdes = []; Ydes = [];
for k = 1:Nsuj
    Xdes = [Xdes; [Phi, Phi .* crudos(k,:)']]; %#ok<AGROW>
    Ydes = [Ydes; reales(k,:)']; %#ok<AGROW>
end
coef = Xdes \ Ydes;
end

function Phi = fourier_base(pct, K)
n = numel(pct);
Phi = ones(n, 2*K+1);
w = 2*pi*pct(:)/100;
for k = 1:K
    Phi(:, 2*k)   = cos(k*w);
    Phi(:, 2*k+1) = sin(k*w);
end
end
