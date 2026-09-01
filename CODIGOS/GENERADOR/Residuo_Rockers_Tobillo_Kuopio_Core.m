function res = Residuo_Rockers_Tobillo_Kuopio_Core()
% RESIDUO_ROCKERS_TOBILLO_KUOPIO_CORE  28-ago-2026: posicion X,Y REAL
%                   promedio del tobillo durante el ciclo, N=13 sujetos de
%                   Kuopio - el "residuo de rockers" que TOBILLO/Evaluar_
%                   vs_Kuopio_Tobillo_Fases.m ya usaba (LOSO, por fold, para
%                   VALIDAR), aqui como PROMEDIO AGRUPADO (todos los
%                   sujetos, sin dejar ninguno afuera) para USAR EN
%                   PRODUCCION - mismo principio que Calibracion_Koopman_
%                   Kuopio_Core.m y FRAC_AVANCE_APOYO de Generar_Trayectoria.m.
%
% POR QUE EXISTE: Cadena_Completa_Core.m fija el tobillo EXACTAMENTE en
% (0,0) durante todo el apoyo (idealizacion de pivote fijo) - correcto
% como primera aproximacion, pero el tobillo real SI se mueve, por el
% mecanismo de "rockers" del pie (heel/ankle/forefoot rocker, Perry &
% Burnfield) - MUY IMPORTANTE PARA LA FUERZA: el mismo mecanismo es el
% que la literatura (Adamczyk & Kuo 2009, "Redirection of center-of-mass
% velocity during the step-to-step transition", J Exp Biol 212:2668)
% identifica como el que REDIRIGE la velocidad del CoM hacia arriba en el
% empuje (push-off) - sin el, la altura del CoM sale con un solo pico
% simple (verificado 28-ago-2026, ver docs/algoritmo/, comparacion cruda
% vs suavizada de la altura de cadera) y GRF_Newton_ApoyoSimple_Core.m no
% puede reproducir el segundo pico de Fz (empuje) que SI aparece en datos
% reales (Kuopio y la referencia propia del proyecto, PERSONA SANA/FUERZA
% GRF, 86kg).
%
% HALLAZGO (grafica en RODILLA/Kuopio/diag_residuo_pooled.png): el
% residuo Y es NEGATIVO en carga inicial (~-1.5cm a 5-10%, el talon
% "cede" un poco), casi plano en medio-apoyo, y SUBE fuerte desde ~45%
% (+2 a +9cm hacia 65%) - la firma exacta del rocker de antepie/empuje.
% El residuo X tambien es real (avanza 0->~5cm en carga, meseta, y sube
% de nuevo hacia el despegue) - MISMO mecanismo, reemplaza la
% aproximacion lineal (FRAC_AVANCE_APOYO=0.079*t) que se usaba antes solo
% para X.
%
% SALIDA: struct res
%   res.pct_ciclo   0:100
%   res.x_cm, res.y_cm   posicion real promedio del tobillo (cm),
%                        relativa a su propio inicio de ciclo (0 en pct=0)
%   res.n_sujetos
%
% NOTA: se recalcula desde Cargar_Kuopio2024_Core.m (13 sujetos, rapido)
% en vez de hardcodear 101 numeros - mismo criterio que Combinar_
% Candidatos_Core.m, mas trazable que una tabla fija.
% ==========================================================================

carpeta = fileparts(mfilename('fullpath'));
addpath(fullfile(carpeta, 'RODILLA', 'Kuopio'));

ids = [1,4,13,19,22,25,28,31,37,40,43,46,49];
Xres = []; Yres = [];
for sid = ids
    try
        S = Cargar_Kuopio2024_Core(sid);
        Xres(end+1,:) = S.x_horiz_tobillo_cm; %#ok<AGROW>
        Yres(end+1,:) = S.y_vert_tobillo_cm; %#ok<AGROW>
    catch
        continue
    end
end

res = struct();
res.pct_ciclo = 0:100;
res.x_cm = mean(Xres,1);
res.y_cm = mean(Yres,1);
res.n_sujetos = size(Xres,1);

end
