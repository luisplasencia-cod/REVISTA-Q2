# Guía de interpretación — SPM1D y Bland-Altman

> 🟢 **Herramienta clave tras el pivote (19-ago-2026) — ver `docs/codigos/INDICE_CODIGOS.md`.** `SPM1D_Core.m` es justo el motor que ya usa el candidato de algoritmo más fuerte encontrado (Zhao et al. 2026, `docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` §4.1) — se reutiliza directo para comparar la trayectoria generada contra sujetos/bases de datos externas.



**Para quién es este documento:** para leer el reporte de consola y las figuras que producen `SPM1D_Core.m` y `BlandAltman_Core.m` sin tener que recordar estadística de memoria, y para saber exactamente en qué comparación del proyecto aplica cada herramienta y en cuál todavía no. Escrito para ir directo del resultado a saber si es bueno, y para citar el respaldo metodológico en el manuscrito sin rebuscar literatura después.

---

## 1. Qué hace cada herramienta, en una frase

- **`SPM1D_Core.m`** — compara dos conjuntos de curvas **punto a punto a lo largo de todo el ciclo de marcha** y dice **en qué % del ciclo** hay una diferencia estadísticamente real, no solo un número resumen (RMSE, r) que promedia todo el ciclo en un solo valor.
- **`BlandAltman_Core.m`** — compara pares de valores **escalares** (un pico, un ROM, un tiempo) medidos por **dos métodos distintos sobre la misma unidad de análisis**, y dice si concuerdan, cuánto sesgo sistemático hay, y qué tan anchos son los límites de acuerdo esperables entre ambos métodos.

Son complementarias, no intercambiables: SPM1D mira la forma completa de la curva; Bland-Altman mira la concordancia de un número puntual entre dos instrumentos.

---

## 2. Dónde aplica cada una en este proyecto — mapa completo

| Comparación (ver matriz completa en `docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`) | SPM1D | Bland-Altman | Estado de los datos |
|---|---|---|---|
| Ángulo plataforma (apoyo/balanceo): simulador vs. referencia Kinovea | ✅ Sí — SPM{t} de **una muestra** (ensayos del simulador vs. curva de referencia fija) | ❌ No — la referencia solo tiene media±SD, no ensayos individuales, no hay pares que comparar | **Disponible hoy.** Script listo: `Aplicar_SPM_BlandAltman_CurvasExistentes.m` |
| Fz apoyo: simulador vs. referencia AMTI | ✅ Sí — mismo caso, una muestra | ❌ No — mismo motivo | **Disponible hoy.** Mismo script |
| Kinovea vs. STT-IWS (recaptura sujeto original) | ✅ Sí — pareado, dos instrumentos midiendo lo mismo | ✅ Sí — pares reales de dos métodos | Bloqueado por ética (Semana 3) |
| IMU de Alessandro vs. STT-IWS (montados juntos en la plataforma) | ✅ Sí — pareado | ✅ Sí | No bloqueado — se puede hacer en Semana 2 |
| Sujeto reprogramado vs. su propia captura (Comparación 3) | ✅ Sí — pareado | ✅ Sí | Bloqueado por ética (Semana 3) |
| Trayectoria fija del simulador vs. variabilidad de sujetos nuevos (Comparación 4) | ✅ Sí — **independiente** (grupos no emparejados) | ⚠️ Con matices (ver nota abajo) | Bloqueado por ética (Semana 3) |
| Fz cruda vs. corregida vs. literatura protésica (Comparación 5) | ✅ Sí | ⚠️ Solo si la literatura reporta datos punto-a-punto por sujeto, raro | Bloqueado por calibración de offset (integración RPi-ESP32) |

**Nota sobre Comparación 4:** cuando se compara la salida fija del simulador contra la variabilidad natural de varios sujetos nuevos, cada sujeto aporta un solo valor por ensayo (no hay "pares" 1 a 1 con la trayectoria fija, que es un solo objeto). Ahí Bland-Altman aplica mejor comparando cada sujeto contra el promedio del grupo (o usando el enfoque de repetibilidad de la sección 4), no como concordancia clásica de dos instrumentos.

## 3. Por qué HOY no se corre Bland-Altman sobre nada (hallazgo importante)

Se investigó si se podía adelantar Bland-Altman con los datos que ya existen (`BaseDatos_Plataforma_Apoyo.mat`, `BaseDatos_Plataforma_Balanceo.mat`, `BaseDatos_FuerzaVertical.mat`) y la respuesta es **no, honestamente no** — esos archivos solo guardan la curva **media ± SD** del sujeto original, no los ensayos individuales de Kinovea. Bland-Altman necesita **pares**: el mismo ensayo medido por el método A y por el método B. Con un solo número de referencia (la media), cualquier "Bland-Altman" que se forzara ahí estaría comparando cada ensayo del simulador contra una constante repetida — no es concordancia entre instrumentos, es solo la desviación del simulador respecto a un objetivo fijo, que es exactamente lo que **ya hace SPM1D de una muestra** (y lo que ya hacían RMSE/ROM en `Validacion_Plataforma.m`/`Validacion_Fuerza.m`).

Por eso `Aplicar_SPM_BlandAltman_CurvasExistentes.m` corre SPM1D sobre las tres curvas disponibles hoy (ángulo apoyo, ángulo balanceo, Fz apoyo) y **no** corre Bland-Altman. El primer Bland-Altman real del proyecto va a ser la concordancia **IMU de Alessandro vs. STT-IWS** (Semana 2, no depende de ética) — ver sección 5 para el fragmento de código listo para ese día.

---

## 4. Cómo leer el reporte de consola de SPM1D_Core.m

```
Permutaciones: 1024 (exactas) | alpha = 0.050 | umbral critico |t| = 2.250
1 cluster(es) supraumbral | 25.7% del ciclo con diferencia significativa:
  [1] 20.0% - 45.0% del ciclo | t_pico = 12.430 | p = 0.0029
```

| Línea | Qué es | Cómo interpretarla |
|---|---|---|
| `Permutaciones... (exactas / Monte Carlo)` | Cuántas combinaciones se probaron para construir la distribución nula | "Exactas" = se probaron **todas** las combinaciones posibles (mejor, más confiable). "Monte Carlo" = se muestrearon al azar porque había demasiadas combinaciones para enumerar todas — con `n_perm=10000` sigue siendo confiable. |
| `umbral critico \|t\|` | El valor que el estadístico tiene que superar para considerarse significativo, **ya corregido** por hacer 101 comparaciones a la vez (una por cada punto del ciclo) | No es un umbral fijo tipo 1.96 — se calcula específicamente para estos datos, por eso cambia de una corrida a otra. |
| `cluster(es) supraumbral` | Tramos contiguos del ciclo donde la diferencia supera el umbral | Cada cluster es un hallazgo separado: dice **dónde** en el ciclo hay diferencia, no solo si la hay. |
| `% del ciclo con diferencia significativa` | El resumen de una sola cifra, si hace falta reportar solo un número | Pero **siempre** acompañarlo del rango (20.0%-45.0%) — decir "difieren" sin decir en qué fase del ciclo pierde la mitad de la información que da SPM1D sobre RMSE. |
| `p` de cada cluster | Probabilidad de ver un pico tan alto como este solo por azar | `p < 0.05` = el cluster es real, no ruido. Es un p-valor de permutación, no depende de asumir normalidad. |
| Sin clusters | "Sin clusters supraumbral: ninguna diferencia significativa en todo el ciclo" | El resultado más fuerte posible a favor de que las curvas concuerdan — mejor que un RMSE bajo, porque cubre el ciclo completo, no un promedio. |

**Diseño pareado vs. independiente:** el reporte dice `diseno pareado` o `diseno independiente`. Pareado = las columnas de A y B están emparejadas (mismo ensayo, o simulador-vs-referencia-fija). Independiente = dos grupos que no se corresponden 1 a 1 (p.ej. sujetos nuevos vs. trayectoria fija). Si el diseño que aparece no es el que se esperaba, revisar el número de columnas de `curvasA`/`curvasB` antes de confiar en el resultado — es la fuente de error más probable al llamar la función con datos nuevos.

## 5. Cómo leer el reporte de consola de BlandAltman_Core.m

```
Bias (media de diferencias) = 4.9158 %BW   IC95% = [3.9125, 5.9190]
SD de diferencias = 2.6867 %BW
Limites de acuerdo (95%): [-0.3501, 10.1817] %BW
Sesgo proporcional: pendiente = 0.0558, p = 0.6237 -> no se detecta sesgo proporcional
```

| Línea | Qué es | Cómo interpretarla |
|---|---|---|
| `Bias` | Cuánto más alto (o bajo) mide en promedio el método A respecto al B | Si el IC95% **cubre 0**, no hay evidencia de sesgo sistemático entre los dos métodos (bien). Si no lo cubre, un método mide sistemáticamente distinto del otro. |
| `SD de diferencias` | Qué tan dispersas son las diferencias individuales alrededor del bias | Chico = los dos métodos concuerdan de forma consistente en todos los ensayos, no solo en promedio. |
| `Limites de acuerdo (LoA)` | El rango donde se espera que caiga la diferencia entre A y B en el 95% de los casos individuales | Es la cifra que hay que juzgar contra el criterio clínico/técnico: ¿un desacuerdo de esa magnitud importa para el uso que se le va a dar al simulador? Un bias bajo con LoA muy anchos igual puede ser un problema práctico. |
| `IC95%` de cada LoA | Incertidumbre del límite mismo (con `n` chico los LoA son poco precisos) | Con n=5-10 (tamaños típicos de este proyecto) el IC de los LoA puede ser bastante ancho — reportarlo siempre, no solo el LoA puntual. |
| **`Sesgo proporcional`** | Si el desacuerdo entre métodos **crece o se achica** según la magnitud medida (no es constante en todo el rango) | `p < 0.05` = **sí hay** sesgo proporcional: los LoA fijos (bias ± 1.96SD) no son representativos en todo el rango — hay que decirlo explícitamente en Resultados/Discusión, o considerar LoA dependientes de la magnitud. `p > 0.05` = el desacuerdo es razonablemente constante, los LoA fijos son válidos. |
| `Normalidad de las diferencias (Jarque-Bera)` | Chequeo complementario del supuesto detrás de `bias ± 1.96·SD` | Igual que en la calibración de offset: con n chico esta prueba tiene poca potencia, un "no se rechaza" no es garantía fuerte por sí sola. |

## 6. Cómo leer las figuras

**Figura SPM1D:** línea azul = estadístico SPM{t} en cada punto del ciclo. Líneas naranjas discontinuas horizontales = umbral crítico (positivo y negativo). Bandas celestes sombreadas = los clusters supraumbral (donde SPM{t} sale del corredor entre las líneas naranjas) — esas son las zonas del ciclo con diferencia real.

**Figura Bland-Altman:** eje X = promedio de las dos mediciones del par (mejor estimador disponible del valor "verdadero", porque ninguno de los dos métodos es un patrón de oro absoluto). Eje Y = diferencia (A−B). Línea azul horizontal = bias. Líneas naranjas discontinuas = límites de acuerdo. Si los puntos muestran una tendencia (suben o bajan según el eje X en vez de dispersarse al azar alrededor del bias), eso es la señal visual de sesgo proporcional, confirmarlo con el `p` de la consola.

---

## 7. Checklist rápido: ¿el resultado es confiable?

**SPM1D:**
- [ ] Si el diseño es pareado con pocos ensayos (n<8), recordar que la prueba exacta por signo tiene pocas combinaciones posibles (2^n) — el script avisa con un `warning` si n<5
- [ ] Revisar que `nA`/`nB` en el reporte sean los esperados (error más común: cargar los archivos en el orden equivocado)
- [ ] Si aparece un cluster, reportar siempre el rango de %ciclo, no solo el % total significativo

**Bland-Altman:**
- [ ] n ≥ 3 (mínimo técnico del script) pero idealmente n ≥ 15-20 para que los LoA sean razonablemente precisos — con n=5-10 (típico de este proyecto en esta fase) reportar los IC de los LoA siempre, y ser cauto con la interpretación
- [ ] Revisar sesgo proporcional antes de reportar los LoA como si fueran válidos en todo el rango
- [ ] Confirmar que los pares realmente correspondan a la misma unidad de análisis (mismo ensayo, mismo sujeto) — pares mal alineados invalidan todo el análisis silenciosamente, no van a dar ningún error de MATLAB

---

## 8. Literatura que respalda cada parte del método

| Método usado aquí | Referencia | Qué respalda exactamente |
|---|---|---|
| SPM no paramétrico por permutación (en vez de random field theory paramétrico) | Nichols, T.E. & Holmes, A.P. (2002). *Human Brain Mapping*, "Nonparametric permutation tests for functional neuroimaging: a primer with examples" | Método base de permutación con estadístico máximo para control de error familiar (FWER) sin asumir normalidad ni estimar suavizado — es la base estadística de `SPM1D_Core.m`. |
| Elección de permutación no paramétrica sobre SPM paramétrico clásico para n chico | Pataky, T.C., Vanrenterghem, J. & Robinson, M.A. (2015). *J Biomech*, "Zero- vs. one-dimensional, parametric vs. non-parametric, and confidence interval vs. hypothesis testing procedures in veterinary biomechanics" | Los propios autores del paquete `spm1d` (el más citado en biomecánica) recomiendan la versión no paramétrica cuando el tamaño de muestra es chico, exactamente la situación de este proyecto (5-10 ensayos, 2-3 sujetos nuevos). |
| Aplicación de SPM a curvas de marcha en general | Pataky, T.C. (2010). *J Biomech*, "Generalized n-dimensional biomechanical field analysis using statistical parametric mapping" | Referencia estándar de por qué SPM es preferible a comparar solo un resumen escalar (RMSE, ROM) cuando el interés está en *dónde* del ciclo ocurre la diferencia. |
| Bland-Altman: método base | Bland, J.M. & Altman, D.G. (1986). *Lancet*, "Statistical methods for assessing agreement between two methods of clinical measurement" | El método en sí: bias, límites de acuerdo, gráfico de diferencia-media. |
| IC de bias y de los límites de acuerdo | Bland, J.M. & Altman, D.G. (1999). *Stat Methods Med Res*, "Measuring agreement in method comparison studies" | Fórmulas exactas de error estándar usadas en `BlandAltman_Core.m` para el IC del bias y de cada LoA (`SE_LoA = SD·√(3/n)`), y la recomendación de chequear sesgo proporcional antes de reportar LoA fijos. |

---

## 9. Cómo se vería esto en el artículo (ejemplos)

**Métodos — SPM1D:**

> Continuous gait-cycle waveforms (hip/knee angle, vertical GRF) were compared using non-parametric one-dimensional Statistical Parametric Mapping (SPM1D), implemented via sign-permutation (paired designs) or label-permutation (independent-group designs) with a maximum-statistic threshold controlling the family-wise error rate at α=0.05 [Nichols & Holmes, 2002]. The non-parametric variant was preferred over classical random field theory SPM given the limited trial counts per condition (5–10 trials), following recommendations for small-sample biomechanical datasets [Pataky et al., 2015].

**Métodos — Bland-Altman:**

> Agreement between [instrumento A] and [instrumento B] for [variable] was assessed via Bland-Altman analysis, reporting bias (mean difference) and 95% limits of agreement (bias ± 1.96 SD), with 95% confidence intervals for both computed following Bland & Altman (1999). Proportional bias was tested via linear regression of the difference against the pairwise mean.

**Resultados — SPM1D (ejemplo):**

> The simulator platform angle differed significantly from the reference trajectory during X.X–Y.Y% of the stance phase (SPM{t}, p=0.0XX), corresponding to [fase de la marcha]; no other significant differences were observed across the remainder of the cycle.

**Resultados — Bland-Altman (ejemplo):**

> Peak tibial angle showed a mean bias of X.X° (95% CI [L, U]) between [método A] and [método B], with 95% limits of agreement of [L, U]°. No significant proportional bias was detected (p=0.XX).

---

## 10. Dónde está todo esto en el repositorio

- `SPM1D_Core.m` — SPM1D no paramétrico (sin diálogos).
- `BlandAltman_Core.m` — Bland-Altman (sin diálogos).
- `Extraer_Features0D.m` — helper para reducir curvas a pico/ROM/tiempo-al-pico, insumo de Bland-Altman.
- `Test_SPM1D_BlandAltman.m` — prueba con datos sintéticos, ya validada (7/7 PASS, ver corrida del 02-ago-2026).
- `Aplicar_SPM_BlandAltman_CurvasExistentes.m` — script interactivo listo para correr HOY: SPM1D sobre ángulo (apoyo/balanceo) y Fz, simulador vs. referencia Kinovea/AMTI. No corre Bland-Altman (ver sección 3 de esta guía).
- Scripts que ya se usaron para reportar resultados de la conferencia y que **no se modifican**, quedan solo como referencia de cómo se cargan/procesan los datos crudos: `CODIGOS/VALIDACIONES/Validacion_Plataforma.m`, `CODIGOS/VALIDACIONES/Validacion_Fuerza.m`.
- Matriz completa de comparaciones y cronograma: `docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`.
