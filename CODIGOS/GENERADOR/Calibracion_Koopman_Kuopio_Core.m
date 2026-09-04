function c = Calibracion_Koopman_Kuopio_Core()
% CALIBRACION_KOOPMAN_KUOPIO_CORE  28-ago-2026, RECALCULADO 01-sep-2026,
%                   RECALCULADO OTRA VEZ 02-sep-2026: constantes de la
%                   calibracion afin de los angulos de muslo y tibia de
%                   Koopman 2014, para USO EN PRODUCCION (generador +
%                   prediccion de GRF para cualquier antropometria nueva).
%
% RECALCULADO 02-sep-2026 (mismo dia que congelar_vl_angulo se activo por
% defecto en produccion, Koopman2014_Core.m/Obtener_Angulos_Candidato.m -
% ver GUIA_INTERPRETACION.md #10): estas constantes se aplican SOBRE la
% salida de Obtener_Angulos_Candidato.m, que ahora usa v/l CONGELADOS
% (v_ref=5 kph, l_ref=1.735 m) en vez de la v/talla real de cada sujeto -
% los coeficientes de abajo (calculados el 01-sep-2026 contra el Koopman
% SIN congelar) quedaron desactualizados para la curva que realmente
% reciben en produccion. Recalculados con Recalibrar_Koopman_Kuopio_Core.m
% (mismo script, sin cambios - hereda el nuevo default de
% Obtener_Angulos_Candidato.m automaticamente).
%
% POR QUE EXISTE: al validar Koopman2014_Core.m contra el Kuopio Gait
% Dataset (Lavikainen et al. 2024) se encontro que reproduce la FORMA del
% ciclo casi exacta (r=0.97-0.99) pero SOBREESTIMA la excursion angular
% ~19-24% - un solo defecto del modelo publicado, medido independientemente
% en 2 segmentos (ver docs/algoritmo/pipeline_koopman_kuopio/
% PIPELINE_KOOPMAN_KUOPIO.md Sec.5.2). La correccion se valido con LOSO
% (leave-one-subject-out): cada sujeto se corrige con coeficientes
% ajustados SOLO con los otros N-1, nunca consigo mismo - sin
% circularidad, tecnica estandar para evitar overfitting con N chico. La
% consistencia entre folds (SD muy chica, ver abajo) es justamente lo que
% confirma que la correccion generaliza y no esta sobreajustada a un
% sujeto particular.
%
% RECALCULADO 01-sep-2026 (el usuario senalo la inconsistencia: los
% coeficientes de abajo se habian calculado el 28-ago-2026 contra el pool
% VIEJO de N=15/13 que se incorporo el 23-ago-2026 - la extraccion
% completa de los 51 sujetos de Kuopio corrio ESE MISMO 28-ago
% (RODILLA/Kuopio/raw/_extraccion_28ago_51sujetos_log.txt) pero nadie
% volvio a recalcular contra el pool ya expandido). Recalculado con
% Recalibrar_Koopman_Kuopio_Core.m (nuevo, SI se deja en el repo - el
% script original que dio los valores de N=13 no se habia guardado).
%
% ESTAS CONSTANTES SON DISTINTAS DE LAS DE LOS FOLDS LOSO EN TEORIA (con
% N=47 practicamente coinciden, ver abajo): los folds LOSO sirven para
% VALIDAR (cada uno simula "aplicar a un sujeto nuevo, nunca visto"). Para
% DESPLEGAR (generar la trayectoria de un sujeto realmente nuevo, que no
% es ninguno de los 47), no hay "sujeto a dejar afuera" - se usa el ajuste
% con TODOS los sujetos disponibles, mismo principio ya usado en el
% proyecto para FRAC_AVANCE_APOYO=0.079 de Generar_Trayectoria.m y para
% Fr=0.25 de Estimar_Velocidad_Froude_Core.m (constantes poblacionales, no
% ajustadas por sujeto).
%
% COMO SE CALCULARON (reproducible - Recalibrar_Koopman_Kuopio_Core.m):
% para cada uno de los sujetos con CSV extraido (Kuopio/raw/), se corrio
% Koopman2014 con SU antropometria/velocidad reales y se comparo
% theta_muslo/theta_tibia del modelo (grados) contra el angulo REAL medido
% (atan2 de la posicion de marcador, misma convencion que el resto del
% proyecto) en una malla comun de 0:100% del ciclo. UN SOLO ajuste polyfit
% de grado 1 (theta_real = a + b*theta_koopman) sobre los sujetos
% CONCATENADOS (no por sujeto, no LOSO) - el metodo agrupado, distinto del
% LOSO que usa la Tabla de calibracion del informe tecnico para validar.
%
% RESULTADO (N=47 de 51 - sujetos 7, 9, 10, 24 excluidos: NINGUN trial
% utilizable, falta el marcador RTibia_RFoot_score en su .c3d fuente, ver
% RODILLA/Kuopio/raw/_extraccion_28ago_51sujetos_log.txt; no es un limite
% de codigo, es del dataset publicado). CON congelar_vl_angulo=true (vigente
% desde 02-sep-2026):
%   MUSLO: ganancia=0.6827  offset=-1.48 deg  (LOSO: SD entre folds 0.0035 / 0.07 deg)
%   TIBIA: ganancia=0.7630  offset=-11.70 deg (LOSO: SD entre folds 0.0034 / 0.06 deg)
% (valores SIN congelar, 01-sep-2026, quedan solo como historial: MUSLO
% 0.7926/-2.60, TIBIA 0.8516/-11.84 - la ganancia de tibia bajo ~10%
% relativo; el offset de tibia casi no se movio).
% Con N=47 el ajuste agrupado y el promedio LOSO coinciden a 4 decimales
% - la muestra grande hace que ambos metodos converjan (ya lo hacian antes
% de congelar, y lo siguen haciendo despues).
%
% USO: theta_calibrado_rad = deg2rad(c.off_X_deg) + c.gan_X * theta_koopman_rad
% SOLO valido para candidato='Koopman', y SOLO si theta_koopman viene de
% Obtener_Angulos_Candidato.m/Obtener_Theta_Tibia_Candidato.m con su
% default vigente (congelar_vl_angulo=true) - si se llama a
% Koopman2014_Core.m directo con congelar_vl_angulo=false (los scripts de
% comparacion de candidatos), estos coeficientes NO aplican, usar los
% historicos de arriba o recalcular. Zhao/Yun no tienen esta calibracion
% derivada de la misma forma (ver PIPELINE_KOOPMAN_KUOPIO.md Sec.5.7, ahi
% Zhao/Yun perdieron con claridad en TOBILLO/INCLINACION_TIBIAL, no se
% investigo una calibracion afin propia para ellos).
% ==========================================================================

c = struct();
c.gan_muslo    = 0.6827;
c.off_muslo_deg = -1.48;
c.gan_tibia    = 0.7630;
c.off_tibia_deg = -11.70;
c.n_sujetos = 47;
c.fuente = 'Kuopio Gait Dataset (Lavikainen et al. 2024, DOI 10.5281/zenodo.10559504), ajuste agrupado 02-sep-2026, N=47, CON congelar_vl_angulo=true (Recalibrar_Koopman_Kuopio_Core.m)';

end
