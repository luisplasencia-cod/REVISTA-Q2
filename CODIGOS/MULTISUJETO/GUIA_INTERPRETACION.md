# Guía de interpretación — Procesamiento multi-sujeto (preparado para 15-20 sujetos)

> 🟢 **Herramienta clave tras el pivote (19-ago-2026) — ver `docs/codigos/INDICE_CODIGOS.md`.** El motor de cálculo por lote se reutiliza tal cual para comparar N sujetos/registros de una base de datos externa (ej. Camargo 2021, 22 sujetos) contra la trayectoria generada — misma estructura de datos, distinto origen de los "sujetos". `Cargar_Sujetos_CSV.m` sí necesitará adaptarse al formato de la base de datos que se elija (`analisis_escalamiento_Q1_generador_trayectorias.md` §4.4-4.5), en vez de al formato de captura con iSen que asumía antes.



**Para quién es este documento:** para leer la tabla y las figuras que produce `Procesar_Multisujeto_Core.m`, y para entender qué prueba exactamente `Test_Procesar_Multisujeto.m` antes de confiar en el pipeline con datos reales. Escrito antes de tener datos de más de un sujeto — a propósito: el objetivo de esta carpeta es que el día que lleguen 15-20 sujetos nuevos, el análisis esté listo y ya probado, no por construir.

---

## 1. Qué hace esto, en una frase

Recibe la captura natural (y, si ya existe, la salida del simulador reprogramado) de cada sujeto nuevo, calcula por sujeto las mismas métricas que ya usaba la conferencia (RMSEnorm, r, %±1SD, ICC), corre SPM1D para ver *en qué parte del ciclo* difieren, agrupa a todos los sujetos para comprobar si la trayectoria fija del simulador los representa razonablemente, y resume todo en una tabla y una figura — sin importar si son 3 sujetos o 20.

## 2. Qué comparación del proyecto resuelve cada parte

Ver la matriz completa en `docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`, sección 10. Esta carpeta cubre las tres filas que dependen únicamente de "hay sujetos nuevos", sin importar qué instrumento los capturó:

| Salida de `Procesar_Multisujeto_Core.m` | Comparación | Qué demuestra |
|---|---|---|
| `resultado.por_sujeto` (tabla) + `resultado.spm_por_sujeto` | **3** — simulador reprogramado por sujeto vs. captura propia | Que la fidelidad de seguimiento no es un golpe de suerte de un solo sujeto |
| `resultado.spm_comparacion4` | **4** — trayectoria fija vs. variabilidad natural de los sujetos nuevos | Representatividad de la trayectoria por defecto — el argumento central del artículo |
| `resultado.por_sujeto.ICC` + `resultado.variabilidad_grupo` | **6** — repetibilidad, por sujeto y entre sujetos | Consistencia del simulador y variabilidad natural del grupo |

**Lo que esto NO incluye:** validación cruzada de instrumentos (Kinovea vs. STT-IWS, IMU de Alessandro vs. STT-IWS — Comparaciones 1 y 2). Esas usan `BlandAltman_Core.m` de `ESTADISTICA/` y son independientes de esta carpeta — ver `docs/codigos/INDICE_CODIGOS.md`.

---

## 3. Cómo leer la tabla `resultado.por_sujeto`

| Columna | Qué es | Cómo interpretarla |
|---|---|---|
| `Sujeto` | Identificador | El mismo que se le dio al cargar los datos |
| `RMSEnorm`, `r`, `pct_1SD` | Igual que en `CODIGOS/VALIDACIONES/GUIA_INTERPRETACION.md` | Simulador (reprogramado con el CSV de ese sujeto) vs. la captura propia de ese sujeto |
| `ICC` | ICC(3,1) de los ensayos del simulador reproduciendo a ese sujeto | Repetibilidad de la reproducción, no de la captura original — mismo uso que en los scripts de la conferencia |
| `Clasificacion` | Excelente/Buena/Aceptable/Deficiente, o **"Sin reprogramar aun"** | Si dice "Sin reprogramar aun", ese sujeto todavía no tiene salida de simulador cargada — no es un error, es un estado válido mientras se van agregando sujetos de a uno |
| `SPM_pct_ciclo_signif` | % del ciclo donde el simulador difiere significativamente de la captura propia de ese sujeto (SPM1D, diseño pareado contra un objetivo fijo — ver nota abajo) | Cuanto más bajo, mejor. `NaN` si el sujeto no tiene salida de simulador todavía |

**Nota técnica sobre el SPM1D por sujeto (Comparación 3):** la captura propia del sujeto se usa como un único objetivo fijo (su curva media), no como un conjunto de ensayos pareados uno a uno con cada ensayo del simulador — no hay forma de emparejar "ensayo 3 del simulador" con "ciclo 3 de la marcha real" del sujeto, son sesiones distintas. Por eso se repite la curva media del sujeto como columna constante y se usa el modo pareado de `SPM1D_Core.m` con ese truco (el mismo patrón ya documentado como "SPM de una muestra" en `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md`, sección 2) — cada ensayo del simulador se compara contra ese mismo objetivo fijo.

## 4. Cómo leer `resultado.spm_comparacion4` (representatividad, diseño independiente)

Es un solo resultado de `SPM1D_Core.m` (no uno por sujeto): agrupa **todos** los ensayos de captura propia de **todos** los sujetos nuevos como un solo grupo, y lo compara contra los ensayos de la trayectoria fija del simulador (la que corre hoy, programada con el sujeto original), en diseño **independiente** — no hay pareo 1 a 1 porque son grupos de tamaños distintos y de sujetos distintos.

- **`pct_ciclo_significativo` bajo (idealmente cerca de 0%)** = buena noticia para el argumento central del artículo: la trayectoria fija representa razonablemente a gente que no participó en programarla.
- **`pct_ciclo_significativo` alto** = la trayectoria fija no generaliza bien — no es un resultado "malo" en sí, es información real que hay que reportar y discutir (puede motivar, por ejemplo, trabajo futuro sobre generación algorítmica de trayectorias, ya mencionado como línea futura en el plan).
- Revisar los `clusters` (dentro de `resultado.spm_comparacion4.clusters`) para saber **en qué fase del ciclo** aparece la diferencia, no solo cuánta hay — igual que con cualquier resultado de SPM1D.

## 5. Cómo leer `resultado.variabilidad_grupo`

Variabilidad natural entre los sujetos nuevos (no variabilidad de instrumento, no repetibilidad intra-sujeto): media, SD y CV (%) de pico y ROM entre sujetos, calculados con `Extraer_Features0D.m` sobre la captura propia de cada uno.

- Da contexto para interpretar la Comparación 4: si el CV entre sujetos ya es alto de por sí (gente camina distinto entre sí), es más exigente que la trayectoria fija represente a todos por igual — un `pct_ciclo_significativo` moderado en la Comparación 4 puede ser razonable si la variabilidad natural del grupo también es alta.
- **Cuidado con el CV cuando la media está cerca de cero:** si `pico_media` o `ROM_media` es un valor pequeño (o el ángulo cruza el cero dentro de su rango natural), el coeficiente de variación puede salir desproporcionadamente alto o inestable — es una propiedad conocida del CV, no un error del cálculo. En ese caso, reportar media±SD en vez de CV%.

## 6. Qué prueba `Test_Procesar_Multisujeto.m` (y qué NO prueba)

**No** vuelve a validar `SPM1D_Core.m` ni `Extraer_Features0D.m` desde cero — eso ya lo hace `CODIGOS/ESTADISTICA/Test_SPM1D_BlandAltman.m` (7/7 PASS). Esta prueba valida que `Procesar_Multisujeto_Core.m` **conecta correctamente** esas piezas ya validadas:

- **Parte A (corrección, 4 sujetos sintéticos):** 3 sujetos con un sesgo constante conocido de +2° entre su captura propia y la salida "simulada" sintética, más un 4° sujeto sin datos de simulador todavía (para probar que ese caso no rompe el pipeline). Verifica que el sesgo se detecta (SPM1D por sujeto), que el ICC sale alto cuando el ruido es bajo, que el sujeto sin reprogramar queda marcado con `NaN`/"Sin reprogramar aun" sin generar error, y que la Comparación 4 detecta un corrimiento de grupo conocido (2 de los 3 sujetos desplazados respecto a la trayectoria fija).
- **Parte B (escala, 20 sujetos × 10 ensayos):** mide el tiempo real de ejecución con datos sintéticos al tamaño esperado para el artículo, y lo compara contra un umbral (60 s, generoso) — para que "rápido" sea una cifra medida antes de tener datos reales, no una promesa. El tiempo también se reporta dentro de `resultado.tiempo_ejecucion_seg` en cualquier corrida real.

**Cómo correrlo:** abrir `Test_Procesar_Multisujeto.m` en MATLAB/Octave y ejecutar (no requiere ningún dato externo, todo es sintético). Reporta `[PASS]`/`[FAIL]` por cada una de las 7 pruebas y un resumen final tipo "N/7 pruebas PASS", igual que los `Test_*.m` de `CALIBRACION/` y `ESTADISTICA/`.

---

## 7. Checklist rápido: ¿el resultado es confiable?

- [ ] `Test_Procesar_Multisujeto.m` corrido y en 7/7 antes de confiar en el pipeline con datos reales
- [ ] Todos los sujetos comparten el mismo `eje_x` (mismo recorte de fase) — si no, `Procesar_Multisujeto_Core.m` lanza error explícito, no falla en silencio
- [ ] Revisar cuántos sujetos tienen `Clasificacion = "Sin reprogramar aun"` antes de interpretar promedios de grupo — esos sujetos SÍ cuentan para la Comparación 4 (representatividad) pero NO para la Comparación 3 (fidelidad de seguimiento), porque esa todavía no tiene datos para ellos
- [ ] `resultado.tiempo_ejecucion_seg` razonable para el número de sujetos cargados (comparar contra la Parte B de la prueba)
- [ ] Antes de correr con datos reales: confirmar en `Cargar_Sujetos_CSV.m` que `opciones.offset_calibracion_deg` es el correcto para el instrumento/montaje usado — el valor de 5.85° del sujeto original **no se reutiliza por defecto** (queda en 0), porque es específico de esa calibración de marcadores

---

## 8. Literatura que respalda cada parte del método

Todo lo estadístico ya está respaldado en las guías que esta carpeta reutiliza — no se repite aquí, solo se referencia:

| Método | Dónde está la literatura completa |
|---|---|
| RMSEnorm, r, %±1SD, ROM, CMC | `CODIGOS/VALIDACIONES/GUIA_INTERPRETACION.md`, sección 5 |
| ICC(3,1) | Koo & Li (2016) — mismo lugar |
| SPM1D no paramétrico (pareado e independiente) | `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md`, sección 8 (Nichols & Holmes 2002; Pataky et al. 2015) |
| Extraer_Features0D (pico/ROM) | Mismo lugar |
| Marco de exactitud (trueness/precision) | `docs/literatura/normas_ISO_relevantes.md` — ISO 5725 |

Lo único nuevo de esta carpeta es la **agregación multi-sujeto** en sí (Comparación 4 en diseño independiente, y la variabilidad de grupo) — no es una técnica estadística nueva, es la aplicación de las mismas herramientas ya validadas a un conjunto de sujetos en vez de a un solo dataset fijo.

---

## 9. Cómo se vería esto en el artículo (ejemplos)

**Métodos:**

> For each of the N new subjects, simulator output (reprogrammed with that subject's own trajectory) was compared against their natural gait capture using normalized RMSE, Pearson's r, percentage of points within ±1 SD, and ICC(3,1), following the same criteria previously applied to the reference subject. Additionally, the default (fixed) simulator trajectory was compared against the pooled natural gait variability of all N new subjects using SPM1D in an independent-group design, to assess how representative the default trajectory is of gait patterns not involved in its programming.

**Resultados — Comparación 3 (ejemplo, agregado):**

> Across N=15 new subjects, tracking fidelity showed RMSEnorm = X.XX ± X.XX (mean ± SD), with ICC(3,1) ranging from X.XX to X.XX; SPM1D identified significant differences in M/15 subjects, concentrated in [fase del ciclo].

**Resultados — Comparación 4 (ejemplo):**

> The default simulator trajectory differed significantly from the pooled natural gait of new subjects during X.X–Y.Y% of the gait cycle (SPM{t}, independent design, p=0.0XX), corresponding to [fase de la marcha].

---

## 10. Dónde está todo esto en el repositorio

- `Procesar_Multisujeto_Core.m` — motor de cálculo, sin diálogos.
- `Cargar_Sujetos_CSV.m` — interfaz interactiva; **archivo a ajustar** el día que se defina el formato final de carpetas para los sujetos reales.
- `Test_Procesar_Multisujeto.m` — prueba con datos sintéticos (corrección + escala).
- Funciones reutilizadas: `CODIGOS/VALIDACIONES/Calcular_Metricas_Curva.m`, `CODIGOS/ESTADISTICA/SPM1D_Core.m`, `CODIGOS/ESTADISTICA/Extraer_Features0D.m`.
- Mapa de toda la carpeta `CODIGOS/`: `docs/codigos/INDICE_CODIGOS.md`.
- Matriz completa de comparaciones y cronograma: `docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`.
