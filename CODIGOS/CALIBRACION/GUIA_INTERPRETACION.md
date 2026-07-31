# Guía de interpretación — Calibración del offset vertical

**Para quién es este documento:** para leer el reporte de consola y las dos figuras que produce `Calibracion_Offset_Core.m` sin tener que recordar estadística de memoria. Está escrito para poder ir directo del resultado a saber si es bueno, y para poder citar el respaldo metodológico en el manuscrito sin tener que rebuscar literatura después.

---

## 1. Qué hace esto, en una frase

Toma varios ensayos de carga estática a distintas alturas (offset, en mm) del eje vertical, mide la fuerza que registra el AMTI en cada uno, y ajusta una recta para encontrar **a qué altura exacta la fuerza medida coincide con el peso real de la carga de referencia** — esa altura es el "offset óptimo" que después se usa fijo en todas las pruebas del artículo.

## 2. Antes de nada: la prueba de práctica

Si corriste `Calibracion_Offset_Vertical.m` sobre la carpeta `EJEMPLO_PRUEBA_NO_ES_DATO_REAL/`, el número final (offset óptimo) **no significa nada real** — son tus archivos de marcha del simulador con nombres de mm inventados, no una prueba de carga estática. Esa carpeta es solo para ver cómo se comporta el programa (ventanas, gráficas, avisos). El día que exista la prueba real, el procedimiento es el mismo pero con datos reales — ahí sí el resultado importa.

---

## 3. Cómo leer el reporte de la consola, línea por línea

```
--- Regresion lineal: Fz(N) = b0 + b1*offset(mm) ---
```
Es la ecuación de la recta ajustada: cuánta fuerza (N) se espera medir para cada altura de offset (mm).

| Línea | Qué es | Cómo interpretarla |
|---|---|---|
| `b1 (pendiente)` | Cuántos N cambia Fz por cada mm de offset | Es la "rigidez" aparente del montaje en esa zona. Si sale casi 0, el offset no está afectando Fz — revisar el montaje o el rango barrido. |
| `IC95%` de b1 y b0 | Rango donde probablemente está el valor verdadero | Si el intervalo es angosto, la medición es precisa. Si es muy ancho, hacen falta más repeticiones o el ruido del AMTI es alto. |
| `p` (de b1) | Si la pendiente es realmente distinta de cero | `p < 0.05` = sí, el offset afecta Fz de verdad (esperable). Si `p` sale grande, algo anda mal (poco rango de offset, mucho ruido). |
| `R²` y `R² ajustado` | Qué tan bien la recta explica los datos | Cerca de 1.0 = excelente. Por debajo de ~0.90 en una prueba controlada como esta es sospechoso — revisar datos atípicos o falta de ajuste (ver abajo). |
| `F(1,df), p` | Prueba de que la regresión completa es significativa | Prácticamente siempre va a salir significativa si R² es alto; es más una formalidad que hay que reportar. |
| `s` (error estándar residual) | Cuánto se desvían en promedio los puntos de la recta, en N | Compararlo con la magnitud de Fz esperada da una idea de precisión relativa (ej. `s`=0.5N sobre un Fz esperado de 200N es <1% de error). |
| **`Falta de ajuste`** | Prueba de si el modelo LINEAL es el correcto, no solo asumirlo | **Esta es la más importante de todas.** `p > 0.05` = no hay evidencia de que la relación sea distinta de una línea recta (bien). `p < 0.05` = hay curvatura real que la recta no está capturando — no usar el offset óptimo de una recta mal ajustada, revisar si hace falta un modelo cuadrático o si hay un problema de medición. Solo se puede calcular si hay repeticiones en ≥3 alturas de offset distintas. |
| `Normalidad de residuos (Jarque-Bera)` | Si los errores del modelo se comportan como ruido aleatorio normal | Es un chequeo complementario, no una prueba de aceptación por sí sola — con pocos datos (n pequeño) tiene poca capacidad de detectar nada, así que un "no se rechaza normalidad" con n chico no es una garantía fuerte. |
| **`Offset optimo`** | La respuesta final | La altura donde Fz medida = peso conocido. Siempre viene con su **intervalo de confianza al 95%** — repórtalo como "X.X mm [límite inferior, límite superior]", no como un número suelto. |
| `Repetibilidad (CV)` | Qué tan parecidas salen las repeticiones al mismo offset | CV bajo (unos pocos %) = el AMTI y el montaje son consistentes. CV alto = hay algo variable entre repeticiones (holgura mecánica, vibración, etc.). |

**Advertencia de extrapolación:** si aparece, significa que el offset óptimo calculado cae **fuera** del rango de alturas que realmente se probaron — la recta se está extrapolando más allá de donde hay datos, lo cual es estadísticamente frágil. Hay que ampliar el rango de la prueba, no confiar en ese número.

---

## 4. Cómo leer la Figura 1 (curva de calibración)

- **Puntos azules** = la media de Fz medida en cada altura de offset, con su barra de error (± 1 SD entre repeticiones).
- **Línea azul** = la recta ajustada.
- **Banda celeste alrededor de la línea** = el intervalo de confianza al 95% de la recta — dónde probablemente está la verdadera relación. Si es angosta, la calibración es precisa; si es ancha, hacen falta más datos.
- **Línea naranja discontinua horizontal** = el peso real de la carga de referencia (lo que Fz *debería* medir).
- **Línea gris punteada vertical** = el offset óptimo — donde la recta cruza la línea naranja. Esa intersección es literalmente la respuesta de toda la prueba.

**Qué se ve bien:** puntos muy cerca de la línea, banda de confianza angosta, y la intersección claramente dentro del rango de offsets que se probaron (no en el borde ni afuera).

## 5. Cómo leer la Figura 2 (diagnóstico de residuos)

Un "residuo" es la diferencia entre lo que la recta predice y lo que realmente se midió en cada ensayo — es el sobrante que el modelo no explica.

- **Panel izquierdo (Residuos vs. offset):** si el modelo lineal es correcto, esto se debe ver como una nube de puntos dispersos al azar alrededor de la línea de cero, **sin ningún patrón**. Si en cambio se ve una curva, una "U", o una tendencia (los residuos crecen o se achican de forma sistemática con el offset), significa que la relación real no es una línea recta — la prueba de falta de ajuste de la consola debería confirmar esto con un `p` chico. *(Esto pasó literalmente durante el desarrollo de este script: una versión anterior mostraba una curva en forma de U en este panel, causada por un sesgo en cómo se calculaba la meseta estable — se corrigió antes de dar el script por bueno. Ver Nota de sesión en `docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`.)*
- **Panel derecho (QQ-plot):** compara los residuos contra lo que se esperaría si fueran perfectamente normales. Si los puntos caen aproximadamente sobre la línea diagonal, los residuos son razonablemente normales (bien). Si se curvan claramente en los extremos (colas), hay valores atípicos o una distribución distinta a la normal — revisar esos ensayos puntuales.

---

## 6. Checklist rápido: ¿el resultado es confiable?

- [ ] R² alto (>0.95 idealmente, en una prueba controlada de laboratorio)
- [ ] Falta de ajuste **no significativa** (p > 0.05) — o al menos evaluable (¿hubo repeticiones en ≥3 offsets?)
- [ ] Residuos sin patrón visible en el panel izquierdo de la Figura 2
- [ ] Offset óptimo **dentro** del rango de offsets probados (sin advertencia de extrapolación)
- [ ] Intervalo de confianza del offset óptimo razonablemente angosto (no ± varios mm)
- [ ] Repetibilidad (CV) baja entre ensayos del mismo offset

Si todo esto se cumple, el offset óptimo que dio el script es el número que se congela y se usa en el resto de las pruebas del artículo.

---

## 7. Literatura que respalda cada parte del método

No son citas decorativas — cada una respalda una decisión metodológica concreta de este script, y se pueden usar directamente en la sección de Métodos del manuscrito:

| Método usado aquí | Referencia | Qué respalda exactamente |
|---|---|---|
| Predicción inversa del offset óptimo con IC propagado | Massart, B.G.M. et al. (1997). *Handbook of Chemometrics and Qualimetrics, Part A*, cap. 8, ec. 8.26/8.28 | Es la fórmula clásica y estándar para "calibración inversa": dado un valor de Y conocido, encontrar X y su incertidumbre a partir de una recta de calibración. Implementación de referencia en el paquete `chemCal` de R, validada contra los mismos ejemplos del libro. |
| Prueba de falta de ajuste (lack-of-fit) | Draper, N.R. & Smith, H. (1998). *Applied Regression Analysis*, 3ra ed., Wiley | Método estándar para contrastar si un modelo lineal es adecuado usando la varianza entre repeticiones (error puro) vs. la desviación de las medias respecto a la recta (falta de ajuste), en vez de asumir linealidad sin probarla. |
| Calibración lineal de una plataforma de fuerza con pesos de referencia conocidos | Ghersi, I. et al., *"Force plate calibration and setup for assessments of human balance"* (repositorio UCA) | Precedente directo en biomecánica: calibran una plataforma de fuerza propia con pesos estáticos conocidos, reportan R²=1.0 para el ajuste lineal, y presentan el offset de la plataforma como resultado de la calibración — mismo tipo de procedimiento que este script, aplicado a otro instrumento del mismo campo. |
| Calibración funcional de sensores de fuerza/torque para GRF con carga dinámica | Cereatti et al./ScienceDirect, *"A force plate based method for the calibration of force/torque sensors"* | Precedente de calibración de sensores de fuerza específicamente para medición de GRF (ground reaction force), reportando RMSD como % del valor máximo — mismo dominio de aplicación que este proyecto (validación de sensores de fuerza para marcha). |
| Recalibración periódica / corrección de errores sistemáticos in-situ | *"In-situ force plate calibration: 12 years' experience..."* (PubMed 28763716) | Respalda la práctica de calibrar el instrumento en su propio montaje (in-situ) en vez de confiar solo en la calibración de fábrica, y recomienda repetir la calibración tras cualquier cambio físico del montaje — aplica directo a por qué se calibra el offset de *este* simulador en particular, no se asume un valor de fábrica. |
| Supuesto de regresión por mínimos cuadrados ordinarios (X sin error) | *"Force calibration using errors-in-variables regression..."*, Metrologia 53(3), 2016 (NIST) | Este script asume que el offset (mm) se conoce sin error porque es un valor **comandado/controlado**, no medido — por eso es válido usar regresión lineal simple (OLS) en vez de un método más complejo tipo "errors-in-variables". Si en algún momento el offset real también tuviera incertidumbre relevante (por ejemplo, si se mide con un instrumento en vez de comandarse), este paper es la referencia para el método más riguroso. |

---

## 8. Cómo se vería esto en el artículo (ejemplo)

**Texto de Métodos (ejemplo, ajustar con los números reales):**

> The vertical datum offset was calibrated using a known static reference load (X kg) applied at N discrete offset positions (range: A to B mm, M replicates each). Vertical force was recorded via the AMTI force platform and averaged over the stable plateau of each trial. A simple linear regression of measured Fz against commanded offset was fitted, and the optimal offset was estimated via inverse prediction as the offset at which predicted Fz equaled the known reference weight, following standard calibration-curve methodology [Massart et al., 1997]. Model adequacy was assessed via a lack-of-fit F-test using replicate measurements [Draper & Smith, 1998]. The resulting offset (X.X mm, 95% CI [L, U]) was fixed for all subsequent trials.

**Pie de figura (ejemplo):**

> **Figure X.** Vertical datum offset calibration curve. Points show mean ± SD measured Fz at each commanded offset (n = X trials, Y levels). Shaded band: 95% confidence interval of the fitted regression line. Dashed orange line: expected Fz from the known reference load. The optimal offset (intersection, dash-dot line) was X.X mm (95% CI [L, U]; R² = X.XX; lack-of-fit p = X.XX).

---

## 9. Dónde está todo esto en el repositorio

- `Calibracion_Offset_Core.m` — el análisis (sin diálogos).
- `Calibracion_Offset_Vertical.m` — la interfaz que va a usar el equipo.
- `Test_Calibracion_Offset.m` — prueba con datos sintéticos, ya validada.
- `EJEMPLO_PRUEBA_NO_ES_DATO_REAL/` — carpeta de práctica con archivos reales renombrados, **no usar el resultado numérico que da**.
- Protocolo completo de la prueba real (qué carga usar, cuántos offsets, convención de nombres): `docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`.
