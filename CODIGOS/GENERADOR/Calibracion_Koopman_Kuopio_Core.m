function c = Calibracion_Koopman_Kuopio_Core()
% CALIBRACION_KOOPMAN_KUOPIO_CORE  28-ago-2026: constantes de la
%                   calibracion afin de los angulos de muslo y tibia de
%                   Koopman 2014, para USO EN PRODUCCION (generador +
%                   prediccion de GRF para cualquier antropometria nueva).
%
% POR QUE EXISTE: al validar Koopman2014_Core.m contra el Kuopio Gait
% Dataset (Lavikainen et al. 2024, N=15 sujetos piloto, 13 con marcador
% completo) se encontro que reproduce la FORMA del ciclo casi exacta
% (r=0.97-0.99) pero SOBREESTIMA la excursion angular ~19-24% - un solo
% defecto del modelo publicado, medido independientemente en 2 segmentos
% (ver docs/algoritmo/pipeline_koopman_kuopio/PIPELINE_KOOPMAN_KUOPIO.md
% Sec.5.2). La correccion se valido con LOSO (leave-one-subject-out): cada
% sujeto se corrige con coeficientes ajustados SOLO con los otros 12/14,
% nunca consigo mismo - sin circularidad, tecnica estandar para evitar
% overfitting con N chico. Los 13 folds LOSO dieron ganancias consistentes
% (muslo ~0.769, tibia ~0.811, ver TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases.m
% cabecera) - la consistencia entre folds es justamente lo que confirma que
% la correccion generaliza y no esta sobreajustada a un sujeto particular.
%
% ESTAS CONSTANTES SON DISTINTAS DE LAS DE LOS FOLDS LOSO: los folds LOSO
% sirven para VALIDAR (cada uno simula "aplicar a un sujeto nuevo, nunca
% visto"). Para DESPLEGAR (generar la trayectoria de un sujeto realmente
% nuevo, que no es ninguno de los 13), no hay "sujeto a dejar afuera" -
% se usa el ajuste con TODOS los sujetos disponibles, mismo principio ya
% usado en el proyecto para FRAC_AVANCE_APOYO=0.079 de Generar_Trayectoria.m
% ("se usa el promedio de los 15 [aqui 13] como constante general, igual
% que Fr=0.25 en Estimar_Velocidad_Froude_Core.m es una constante
% poblacional, no ajustada por sujeto").
%
% COMO SE CALCULARON (reproducible, no hardcodeado a ciegas): para cada uno
% de los 13 sujetos con CSV extraido (Kuopio/raw/), se corrio Koopman2014
% con SU antropometria/velocidad reales y se comparo theta_muslo/theta_tibia
% del modelo (grados) contra el angulo REAL medido (atan2 de la posicion de
% marcador, misma convencion que el resto del proyecto) en una malla comun
% de 0:100% del ciclo. Se hizo UN SOLO ajuste polyfit de grado 1
% (theta_real = a + b*theta_koopman) sobre los 13 sujetos CONCATENADOS (no
% por sujeto, no LOSO) - script de calculo no se deja en el repo (era
% temporal), pero es exactamente el mismo bucle de carga que
% TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases.m lineas 103-136, solo sin la
% exclusion "otros = idx_ok(idx_ok~=i)" del paso LOSO.
%
% RESULTADO (N=13, sujetos 7 y 10 excluidos por falta del marcador
% RTibia_RFoot_score en su .c3d, ver extraer_kuopio.py):
%   MUSLO: ganancia=0.7609  offset=-2.00 deg
%   TIBIA: ganancia=0.8123  offset=-11.35 deg
% Consistente con el promedio de los folds LOSO ya documentado (0.769,
% 0.811) - confirma que el ajuste agrupado no es un valor atipico.
%
% USO: theta_calibrado_rad = deg2rad(c.off_X_deg) + c.gan_X * theta_koopman_rad
% SOLO valido para candidato='Koopman' - Zhao/Yun no tienen esta calibracion
% derivada de la misma forma (ver PIPELINE_KOOPMAN_KUOPIO.md Sec.5.7, ahi
% Zhao/Yun perdieron con claridad en TOBILLO/INCLINACION_TIBIAL, no se
% investigo una calibracion afin propia para ellos).
%
% LIMITACION DECLARADA: N=13, no 15 (2 sujetos sin marcador utilizable) -
% ligeramente menor que lo documentado en PIPELINE_KOOPMAN_KUOPIO.md, que
% asumia los 15. No cambia la conclusion (ganancias consistentes con los
% folds LOSO ya reportados con esos mismos 13 sujetos en la practica, ya
% que sujeto 7/10 tampoco tenian CSV en las validaciones anteriores).
% ==========================================================================

c = struct();
c.gan_muslo    = 0.7609;
c.off_muslo_deg = -2.00;
c.gan_tibia    = 0.8123;
c.off_tibia_deg = -11.35;
c.n_sujetos = 13;
c.fuente = 'Kuopio Gait Dataset (Lavikainen et al. 2024, DOI 10.5281/zenodo.10559504), ajuste agrupado 28-ago-2026';

end
