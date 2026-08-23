# Índice maestro de `CODIGOS/` — qué es cada script y cuándo usarlo

> 🟢 **Herramientas reutilizables tras el pivote — 19-ago-2026.** Todo el código de análisis (`VALIDACIONES/`, `CALIBRACION/`, `ESTADISTICA/`, `MULTISUJETO/`, `POTENCIA_EQUIVALENCIA/`, `INCERTIDUMBRE/`) sigue siendo válido tal cual — la matemática de comparar dos curvas no cambia. Lo que cambia es **qué se compara contra qué**: antes era "simulador vs. CSV pregrabado del mismo sujeto", ahora es "trayectoria generada desde antropometría vs. sujetos/bases de datos externas que no participaron en generarla" (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20, `docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` §7.1). `GENERAR CURVS DE REFERENCIA/` y `VALIDACIONES/` (construidos para el flujo de captura con Kinovea/iSen) son los que más pierden relevancia directa; el resto se reutiliza casi sin cambios.

**Para quién es este documento:** es el primer archivo a leer antes de tocar cualquier `.m` del proyecto. Da el mapa de una página: qué hace cada carpeta, qué hace cada script dentro de ella, y a qué guía ir si hace falta el detalle completo (fórmulas, literatura, cómo leer cada número). Ninguna carpeta de análisis queda sin su propio `GUIA_INTERPRETACION.md` — si falta uno, es un hueco a llenar, no una carpeta "menor".

**Regla que se repite en las cinco carpetas:** los archivos `*_Core.m` no tienen diálogos (reciben datos ya cargados, se pueden probar con datos sintéticos). Los archivos sin sufijo `_Core` que sí abren ventanas (`uigetfile`, `inputdlg`) son la interfaz que usa el equipo día a día. Los `Test_*.m` validan el `_Core` correspondiente con datos sintéticos de verdad conocida antes de confiar en él con datos reales.

---

## 1. `GENERAR CURVS DE REFERENCIA/` — construcción de las bases de datos originales

Ya ejecutados, generaron los `.mat` que vive en `REFERENCIAS/` (curvas media±SD del sujeto original). No tienen guía propia porque no se van a volver a correr salvo que el equipo decida regenerar la base del sujeto original desde cero.

| Script | Para qué sirve |
|---|---|
| `Angulo_Control_Plataforma.m` | Calcula el ángulo de control de la plataforma (atan2, misma convención que el resto del proyecto) a partir de los datos crudos del sujeto original. |
| `Desplazamientos.m` | Calcula desplazamientos horizontales/verticales de la plataforma. |
| `Base_Datos_GRF.m` | Construye la base de datos de fuerza vertical (GRF) de referencia. |

## 2. `VALIDACIONES/` — validación clásica, scripts de la conferencia

**Guía:** `CODIGOS/VALIDACIONES/GUIA_INTERPRETACION.md`

| Script | Para qué sirve | Cuándo correrlo |
|---|---|---|
| `Validacion_Plataforma.m` | Compara ángulo del simulador (apoyo/balanceo) vs. referencia Kinovea: RMSEnorm, r, %±1SD, ROM, CMC, ICC(3,1), tabla semáforo. | Ya ejecutado para el sujeto original, queda como referencia de cómo se cargan/procesan los CSV crudos. No se modifica. |
| `Validacion_Fuerza.m` | Igual que el anterior pero para Fz (fuerza vertical), con detección automática de IC/TO y filtrado de ensayos inválidos. | Igual — referencia, no se modifica. |
| `Calcular_Metricas_Curva.m` *(nuevo)* | Extrae las mismas fórmulas de los dos scripts de arriba a una función reutilizable, con interfaz más simple. | Lo llaman otros scripts (hoy: `MULTISUJETO/`), no se corre solo. |

## 3. `CALIBRACION/` — calibración del offset vertical inicial

**Guía:** `CODIGOS/CALIBRACION/GUIA_INTERPRETACION.md`

**Estado: en pausa por dependencia técnica, no por decisión del equipo** — bloqueada hasta que termine la integración Raspberry Pi–ESP32 (sin ella no hay movimiento posible del eje vertical, ni estático).

| Script | Para qué sirve | Cuándo correrlo |
|---|---|---|
| `Calibracion_Offset_Core.m` | Regresión offset(mm)→Fz(N), IC95%, prueba de falta de ajuste, predicción inversa del offset óptimo. | Lo llama la interfaz de abajo; no se corre solo salvo para pruebas. |
| `Calibracion_Offset_Vertical.m` | Interfaz interactiva (diálogos) que llama al Core. | El día que haya datos reales de la prueba de offset. |
| `Test_Calibracion_Offset.m` | Prueba con datos sintéticos de verdad conocida. Ya ejecutado, recupera pendiente/intercepto/offset dentro del IC95%. | Ya validado — solo re-correr si se modifica el Core. |
| `EJEMPLO_PRUEBA_NO_ES_DATO_REAL/` | Carpeta de práctica, archivos reales renombrados. **Su resultado numérico no significa nada real.** | Solo para ver la mecánica del programa. |

## 4. `ESTADISTICA/` — SPM1D y Bland-Altman de propósito general

**Guía:** `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md`

| Script | Para qué sirve | Cuándo correrlo |
|---|---|---|
| `SPM1D_Core.m` | Compara curvas completas punto a punto (SPM no paramétrico por permutación), diseño pareado o independiente. | Lo llaman otros scripts (`Aplicar_SPM_BlandAltman_CurvasExistentes.m`, y ahora `MULTISUJETO/`). |
| `BlandAltman_Core.m` | Concordancia entre dos instrumentos midiendo el mismo valor escalar (bias, límites de acuerdo, sesgo proporcional). | Cuando haya pares reales de dos instrumentos — hoy no aplica a ninguna curva existente (ver su guía, sección 3). |
| `Extraer_Features0D.m` | Reduce una curva a pico/ROM/tiempo-al-pico, insumo de Bland-Altman y de la variabilidad entre sujetos en `MULTISUJETO/`. | Lo llaman otros scripts. |
| `Aplicar_SPM_BlandAltman_CurvasExistentes.m` | Script interactivo listo para correr hoy: SPM1D sobre ángulo/Fz, simulador vs. referencia Kinovea/AMTI. | Cuando se quiera repetir/actualizar ese resultado con datos reales. |
| `Test_SPM1D_BlandAltman.m` | Prueba con datos sintéticos (7/7 PASS, corrida real en MATLAB R2025b). | Ya validado — solo re-correr si se modifican los Core. |

## 5. `MULTISUJETO/` — procesamiento por lote para sujetos nuevos (preparado para 15-20)

**Guía:** `CODIGOS/MULTISUJETO/GUIA_INTERPRETACION.md`

**Estado: preparado, sin datos reales todavía** — hoy solo hay datos de 1 sujeto (el original). El motor estadístico ya está construido y probado con datos sintéticos; falta que lleguen los sujetos nuevos.

| Script | Para qué sirve | Cuándo correrlo |
|---|---|---|
| `Procesar_Multisujeto_Core.m` | Motor de cálculo: por cada sujeto corre `Calcular_Metricas_Curva.m` (RMSEnorm/r/%±1SD/ICC) y SPM1D pareado contra su propia captura (Comparación 3); agrupa todos los sujetos contra la trayectoria fija con SPM1D independiente (Comparación 4); resume variabilidad entre sujetos con `Extraer_Features0D.m` (Comparación 6). Exporta tabla CSV y figura de pequeños múltiplos. | Lo llama la interfaz de carga, o se le pasa un struct ya armado. |
| `Cargar_Sujetos_CSV.m` | Interfaz interactiva: lee una carpeta por sujeto con sus CSV, arma el struct que necesita el Core, reutilizando el mismo parseo (atan2, filtro) que ya usa `Validacion_Plataforma.m`. **Es el archivo a ajustar el día que el equipo defina el formato final de carpetas/nombres.** | Cuando lleguen datos reales de sujetos nuevos. |
| `Test_Procesar_Multisujeto.m` | Prueba con datos sintéticos: (a) recupera valores esperados con 3 sujetos de verdad conocida, (b) mide el tiempo de ejecución con 20 sujetos × 10 ensayos para confirmar que es rápido antes de tener datos reales. | Ya listo para correr — ver la guía para qué salida esperar. |

## 6. `POTENCIA_EQUIVALENCIA/` — potencia a priori y pruebas de equivalencia *(nuevo, 13-ago-2026)*

**Guía:** `CODIGOS/POTENCIA_EQUIVALENCIA/GUIA_INTERPRETACION.md`

**Estado: construido y con test sintético, pendiente de correr en MATLAB/Octave por el usuario** — igual que el resto de carpetas de análisis, listo antes de tener datos reales. Sale de los candidatos **A** y **B** aprobados en `docs/DISCUSION_Q2.md` P-3.

| Script | Para qué sirve | Cuándo correrlo |
|---|---|---|
| `PotenciaApriori_Core.m` | Potencia estadística por simulación Monte Carlo para la Comparación 4 (sujetos nuevos vs. trayectoria fija, `SPM1D_Core.m` diseño independiente): dado un tamaño de efecto y un N, ¿qué probabilidad hay de detectarlo? Da el N mínimo estimado para 80% de potencia. **Advertencia importante en su guía, sección 2:** usa hoy la variabilidad ensayo-a-ensayo del sujeto original como proxy de variabilidad entre sujetos — probablemente optimista, recalcular con ~5 sujetos reales. | Antes de reclutar (ya, la ventana se cierra cuando empiece la captura) y de nuevo cuando existan ~5 sujetos reales. |
| `TOST_Core.m` | Prueba de equivalencia (Schuirmann, two one-sided tests) sobre una métrica 0D (`Extraer_Features0D.m`): declara un margen de equivalencia antes de los datos y dice si la diferencia observada cae dentro. Protege el argumento central del artículo contra la objeción "no hubo diferencia significativa = falta de potencia, no equivalencia". | Con los datos reales de la Comparación 3/4, una vez definido el margen (ver guía, sección 5). |
| `Test_PotenciaApriori_TOST.m` | Prueba con datos sintéticos (9 pruebas): tasa de falso positivo con efecto=0, potencia alta con efecto grande, monotonía en N, equivalencia/no-equivalencia detectada correctamente, caso límite SE=0. | Antes de usar cualquiera de los dos Core con datos reales. |

## 7. `INCERTIDUMBRE/` — presupuesto formal de incertidumbre GUM/ISO 5725 *(nuevo, 16-ago-2026)*

**Guía:** `CODIGOS/INCERTIDUMBRE/GUIA_INTERPRETACION.md`

**Estado: construido y con test sintético, pendiente de correr en MATLAB/Octave por el usuario** — igual que el resto de carpetas de análisis. Sale del **candidato E** de `docs/ESTADO_Y_RUMBO.md` §6, aprobado en `docs/DISCUSION_Q2.md` P-19.

| Script | Para qué sirve | Cuándo correrlo |
|---|---|---|
| `PresupuestoIncertidumbre_Core.m` | Combina componentes de incertidumbre (validación del instrumento, residuo de calibración de offset, repetibilidad ensayo-a-ensayo) siguiendo la ley de propagación de incertidumbre de la GUM (JCGM 100:2008): incertidumbre combinada por RSS, grados de libertad efectivos por Welch-Satterthwaite, factor de cobertura `k` calculado exactamente (no asumido en 2), incertidumbre expandida. Reporta qué % de la incertidumbre total aporta cada fuente — el diagnóstico más útil. Genérico, no hardcodea ningún número del proyecto. | Cuando exista una tabla de componentes real (instrumento + calibración de offset + repetibilidad) para el ángulo de plataforma. Decisión pendiente antes de usarlo así (ver guía, sección 6): qué cifra de Piche 2022 (rodilla/tobillo/cadera) usar como analogía del ángulo medido. |
| `Test_PresupuestoIncertidumbre.m` | Prueba con datos sintéticos (7 pruebas): combinación RSS exacta, un solo componente, grados de libertad efectivos dominados por el componente con menos gl, contribución porcentual, ensanchamiento de `k` con muestras chicas, error controlado por campo faltante, y un caso de uso realista con las cifras de Piche 2022. | Antes de usar el Core con datos reales. |

## 8. `GENERADOR/` — generador de trayectoria desde antropometría *(nuevo, 23-ago-2026)*

**Guía:** `CODIGOS/GENERADOR/GUIA_INTERPRETACION.md`

**Estado: los tres candidatos construidos, probados y corridos en MATLAB real (23-ago-2026, 16/16 PASS).** Es el código central del pivote de fondo (`CLAUDE.md`, banner inicial) — genera ángulos articulares desde antropometría y los reduce al ángulo absoluto del segmento tibial. **Sin datos propios del proyecto** (`PERSONA SANA/`/`REFERENCIAS/`) — algoritmo 100% de literatura, decisión explícita del usuario (23-ago-2026), validado después contra Camargo 2021 (2 sujetos piloto ya descargados, ver la guía §5).

| Script | Para qué sirve | Cuándo correrlo |
|---|---|---|
| `Zhao2026_Core.m` | Genera φ_cadera(t), φ_rodilla(t) y θ_tibia = φ_cadera − φ_rodilla con los coeficientes ya publicados (Tabla 1, Zhao et al. 2026) — sin reentrenar. | Ya listo, dar longitud de pierna y cadencia. |
| `Yun2014_Wrapper.m` | Llama al toolbox real de Yun 2014 (`Gait_Pred.m`, sin reentrenar) y aplica la reducción vía tobillo. | Cuando el toolbox esté en disco (`docs/literatura/pdfs/yun2014_toolbox/`, base KIST gitignored por licencia). |
| `Koopman2014_Core.m` | Genera las 4 trayectorias articulares (cadera ab/ad, cadera flex/ext, rodilla, tobillo) con splines quínticos entre 6 eventos clave, coeficientes ya publicados (Tablas 1-5) — sin reentrenar. | Ya listo, dar velocidad (kph) y talla (m). |
| `Reduccion_Winter_Core.m` | Relación general ángulo relativo↔absoluto: calcula θ_tibia vía rodilla y/o vía tobillo, y cruza ambos caminos como chequeo interno. | Lo llama `Yun2014_Wrapper.m`; también se puede usar con Koopman o con datos de Camargo. |
| `Cargar_Camargo_Core.m` | Carga un ensayo real de Camargo 2021 (marcadores + ángulos IK + longitud de tibia real) para validación Nivel A/B. | Cuando el sujeto piloto esté en disco (`docs/literatura/pdfs/camargo2021_piloto/`). |
| `Test_Generador.m` | 16 pruebas: sintéticas (Zhao + reducción) + reales (Yun con su toolbox, Camargo con AB06, Koopman contra el ROM publicado en su Tabla 6). | Ya corrido, 16/16 PASS. Re-correr si se modifica algún Core. |

---

## Qué es "tentativo" y sigue existiendo, pero no es el rumbo actual

Nada de esto se borró. Sigue disponible para cuando el equipo decida retomarlo (ver `CLAUDE.md`, sección de decisiones, entrada 03-ago-2026):

- **Validación cruzada de instrumentos** (Kinovea vs. STT-IWS, IMU de Alessandro vs. STT-IWS — Comparaciones 1 y 2 de `docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`): usa `BlandAltman_Core.m` de `ESTADISTICA/`, ya construido y probado, esperando pares reales de dos instrumentos.
- **Corrección de Fz** (offset + fidelidad de seguimiento + inercia por eje — Comparación 5): `CALIBRACION/`, en pausa por la integración Raspberry Pi–ESP32, no por prioridad.

Estas dos rutas no bloquean ni dependen de `MULTISUJETO/` — pueden avanzar en paralelo cuando corresponda.
