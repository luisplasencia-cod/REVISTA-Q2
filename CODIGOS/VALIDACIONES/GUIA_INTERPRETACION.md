# Guía de interpretación — Validación clásica (RMSEnorm, r, %±1SD, ROM, CMC, ICC)

**Para quién es este documento:** para leer la tabla semáforo que producen `Validacion_Plataforma.m` y `Validacion_Fuerza.m` (los scripts que ya reportaron los resultados de la conferencia) sin tener que recordar estadística de memoria, y para entender qué es `Calcular_Metricas_Curva.m` — el archivo nuevo que extrae esas mismas fórmulas para que las reutilice `CODIGOS/MULTISUJETO/`.

**Por qué esta guía se escribe recién ahora:** `VALIDACIONES/` es la carpeta más antigua del proyecto — las fórmulas que contiene son la base de todo lo demás (`CALIBRACION/` y `ESTADISTICA/` las dan por conocidas), pero nunca tuvo su propia guía. Con `CODIGOS/MULTISUJETO/` reutilizándolas directamente, ya no puede quedar sin explicación.

---

## 1. Qué hace esto, en una frase

Compara la curva media del simulador (una fase de marcha: apoyo, balanceo, o Fz) contra la curva de referencia de un sujeto, resume la diferencia en un puñado de números estándar de la literatura de marcha, y clasifica cada uno en una tabla semáforo (Excelente/Buena/Aceptable/Deficiente) para que el resultado se lea de un vistazo.

**`Validacion_Plataforma.m` y `Validacion_Fuerza.m` no se modifican** — son los scripts que ya reportaron los resultados de la conferencia, quedan como referencia de cómo se cargan y procesan los datos crudos (mismo criterio ya aplicado a otras carpetas del proyecto). **`Calcular_Metricas_Curva.m`** es un archivo nuevo que extrae las mismas fórmulas (`calcular_estadistica()`/`calcular_icc31()`, embebidas como funciones locales al final de esos dos scripts) a una función reutilizable, con una interfaz más simple: en vez de recibir vectores completos del ciclo más un índice lógico `idx` (que los dos scripts originales usaban con dos convenciones ligeramente distintas entre sí — una fuente real de confusión), recibe directamente los vectores ya recortados a la fase de interés. La matemática es idéntica, solo cambia cómo se le llama.

---

## 2. Cómo leer cada columna de la tabla

| Columna | Qué es | Fórmula / origen | Cómo interpretarla |
|---|---|---|---|
| `RMSEnorm` | Error cuadrático medio, normalizado por la SD de la referencia en cada punto del ciclo | `sqrt(mean(((sim-exp)./sd_ref).^2))` | Compara el error contra la variabilidad natural de la referencia, no contra su magnitud absoluta — por eso es comparable entre ángulo (°) y fuerza (%BW). Umbral: <1 Excelente, 1–1.5 Buena, 1.5–2 Aceptable, >2 Deficiente. |
| `r` (Pearson) | Correlación lineal entre la curva del simulador y la de referencia | Coeficiente de Pearson clásico | Mide si ambas curvas suben y bajan juntas, **no** si tienen la misma magnitud — una curva desplazada en offset puede tener `r` alto y aun así estar sesgada. Interpretar siempre junto a RMSEnorm, nunca solo. Umbral: >0.9 Excelente, 0.8–0.9 Buena, 0.7–0.8 Aceptable, <0.7 Deficiente. |
| `% ±1SD` | Porcentaje de puntos del ciclo donde el simulador cae dentro de ±1 SD de la referencia | `mean(abs(sim-exp) <= sd_ref) * 100` | Versión punto-a-punto, más intuitiva que RMSEnorm para explicarle a alguien que no es estadístico. Umbral: >85% Excelente, 75–85% Buena, 65–75% Aceptable, <65% Deficiente. |
| `ROM` (sim/exp) y `ΔROM` | Rango de movimiento (máximo − mínimo) de cada curva, y su diferencia | `max(x)-min(x)` | Métrica clínica directa (grados o %BW), fácil de reportar sola en Resultados. `ΔROM` cerca de 0 = el simulador reproduce la amplitud del movimiento, no solo la forma. |
| `CMC` (Coefficient of Multiple Correlation) | Qué tan bien la curva del simulador reproduce la **forma** de la de referencia | `sqrt(1 - Σ(sim-exp)² / Σ(exp-mean(exp))²)` | Muy usado en literatura de marcha para comparar formas de onda completas (Kadaba et al. 1989). Complementa a `r`: penaliza más el desfase de magnitud que la correlación simple. Umbral: >0.95 Excelente, 0.85–0.95 Buena, 0.75–0.85 Aceptable, <0.75 Deficiente. |
| `ICC(3,1)` | Repetibilidad entre los ensayos individuales que forman la curva media (no la concordancia sim-vs-ref) | Modelo mixto dos vías, acuerdo absoluto (Koo & Li 2016) | Responde una pregunta distinta a las de arriba: "¿qué tan parecidos son los ensayos entre sí?", no "¿se parece el simulador a la referencia?". Sale `NaN` si no se le pasan ensayos individuales (`trials_fase` vacío). Umbral: >0.90 Excelente, 0.75–0.90 Buena, 0.50–0.75 Aceptable, <0.50 Deficiente. |
| Clasificación global | El peor nivel entre RMSEnorm, r y %±1SD | `max(nivel_rmse, nivel_r, nivel_sd)` | Resume la fila en una palabra, pero **siempre reportar los números individuales también** — un "Aceptable" global puede esconder un RMSEnorm excelente arrastrado hacia abajo por un `r` bajo en una curva casi plana (r es inestable cuando la curva tiene poca variación, ver nota abajo). |

**Nota sobre `r` en curvas monótonas o casi planas:** el propio plan del proyecto (`docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`) ya advierte interpretar `r` con cautela en curvas monótonas — el coeficiente de Pearson puede ser engañosamente bajo (o inestable) cuando la curva de referencia tiene poca variación, aunque el simulador la siga bien en magnitud. Por eso nunca se reporta `r` solo.

---

## 3. `Calcular_Metricas_Curva.m` — qué cambia respecto a los scripts originales

- **Entrada:** `calcular_metricas_curva(sim_fase, exp_fase, sd_fase, trials_fase, nombre_fase)` — los tres primeros vectores ya deben estar recortados a la fase de interés (apoyo, balanceo, o el tramo de Fz que corresponda). `trials_fase` es la matriz de ensayos individuales (puntos × ensayos) para el cálculo de ICC, o `[]` si no aplica.
- **Salida:** un `struct` con un campo por métrica (`RMSEnorm`, `r`, `pct_1sd`, `ROM_sim`, `ROM_exp`, `delta_ROM`, `CMC`, `ICC`, más los niveles de clasificación 1–4 y el texto `clasificacion_global`) — más fácil de indexar y de acumular en tabla que el `cell` de fila que devolvían los scripts originales.
- **No incluye** la parte de dibujar la tabla `uitable` con colores (eso es específico de la interfaz interactiva de `Validacion_Plataforma.m`/`Validacion_Fuerza.m`). `CODIGOS/MULTISUJETO/` construye su propia tabla/figura de salida a partir de estos structs.
- **Quién lo usa:** `CODIGOS/MULTISUJETO/Procesar_Multisujeto_Core.m` llama a esta función una vez por sujeto — así la fórmula vive en un solo lugar y no hay que mantenerla sincronizada en dos archivos.

---

## 4. Checklist rápido: ¿el resultado es confiable?

- [ ] `sd_fase` no tiene ceros ni valores casi cero (si la referencia no tiene variabilidad en algún punto, `RMSEnorm` y `%±1SD` se vuelven inestables ahí — mismo tipo de problema que se corrigió en `SPM1D_Core.m`, ver `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md`)
- [ ] `trials_fase` tiene al menos 2 ensayos si se espera un `ICC` numérico (con 1 ensayo no hay repetibilidad que medir, sale `NaN` por diseño, no por error)
- [ ] Reportar siempre `RMSEnorm` + `r` + `%±1SD` juntos, nunca uno solo — cada uno puede ocultar lo que los otros dos muestran
- [ ] Revisar la nota sobre `r` en curvas monótonas antes de usar solo ese número para decidir "bueno/malo"

---

## 5. Literatura que respalda cada parte del método

| Métrica | Referencia | Qué respalda |
|---|---|---|
| RMSEnorm, %±1SD, ROM | Ya usado en el paper de conferencia del proyecto — convención estándar en validación de sistemas de marcha instrumentados | Métricas de error punto-a-punto normalizadas por variabilidad de referencia, estándar en el campo |
| CMC (Coefficient of Multiple Correlation) | Kadaba, M.P., Ramakrishnan, H.K. & Wootten, M.E. (1989). *J Orthop Res*, "Measurement of lower extremity kinematics during level walking" | Métrica clásica de biomecánica de marcha para comparar formas de onda completas entre sesiones/sistemas, más robusta que `r` simple ante desfases de magnitud |
| ICC(3,1) | Koo, T.K. & Li, M.Y. (2016). *J Chiropr Med*, "A Guideline of Selecting and Reporting Intraclass Correlation Coefficients for Reliability Research" | Guía de referencia para elegir el modelo correcto de ICC (dos vías, mixto, acuerdo absoluto) según el diseño del estudio — exactamente el modelo ya implementado aquí |
| Exactitud como veracidad + precisión (marco general) | ISO 5725 (ver `docs/literatura/normas_ISO_relevantes.md`) | Da vocabulario formal: RMSEnorm/CMC ≈ "trueness" (qué tan cerca del valor de referencia), ICC ≈ "precision" (qué tan repetible) — útil para la sección de Métodos ante un revisor Q2 |

---

## 6. Cómo se vería esto en el artículo (ejemplo)

**Métodos:**

> Simulator output curves were compared against the reference curve using normalized RMSE (RMSEnorm, error normalized by the pointwise reference SD), Pearson's r, the percentage of points within ±1 SD of the reference, range of motion (ROM) difference, the Coefficient of Multiple Correlation (CMC) [Kadaba et al., 1989], and intraclass correlation ICC(3,1) [Koo & Li, 2016] for trial-to-trial repeatability.

**Resultados (ejemplo):**

> Stance-phase tibial angle showed RMSEnorm = X.XX, r = 0.XX, XX.X% of points within ±1 SD, CMC = 0.XX, and ICC(3,1) = 0.XX, consistent with [Excellent/Good/Acceptable] agreement per the classification thresholds in Table X.

---

## 7. Dónde está todo esto en el repositorio

- `Validacion_Plataforma.m`, `Validacion_Fuerza.m` — scripts originales de la conferencia, **no se modifican**, quedan como referencia de carga/procesamiento de datos crudos.
- `Calcular_Metricas_Curva.m` — extracción reutilizable de las mismas fórmulas, con interfaz simplificada. Nuevo, sin diálogos.
- Mapa de toda la carpeta `CODIGOS/`: `docs/codigos/INDICE_CODIGOS.md`.
- Quién reutiliza esto: `CODIGOS/MULTISUJETO/Procesar_Multisujeto_Core.m` (ver `CODIGOS/MULTISUJETO/GUIA_INTERPRETACION.md`).
