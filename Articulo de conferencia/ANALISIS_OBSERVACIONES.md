# Análisis de las observaciones de los revisores — IBITeC 2026

**Paper ID:** 1571326099
**Título:** Simulation-Driven Design and Functional Assessment of a Gait Simulator for Transtibial Prosthesis Evaluation
**Track:** Human Motion and Rehabilitation Engineering
**Fecha del análisis:** 06-ago-2026

> **Qué es este archivo:** documento de **referencia**, no de trabajo. Contiene el inventario de archivos, la extracción completa de las 15 observaciones, el cruce de cada una contra el manuscrito (con número de línea), y el análisis previo a redactar. **No hace falta que escribas nada aquí.**
>
> La discusión activa y las preguntas que te tengo que hacer van en **`DISCUSION_COMENTARIOS.md`** — ese es el archivo donde tú respondes.

---

## PASO 1 — Inventario de la carpeta

La carpeta `Articulo de conferencia/` contenía originalmente 2 archivos:

| Archivo | Tamaño | Identificación |
|---|---|---|
| `articulo original.md` | 33 KB | **Manuscrito.** Es el código LaTeX completo de Overleaf (`\documentclass[conference]{IEEEtran}` … `\end{document}`), guardado con extensión `.md`. Abstract, 5 secciones, 20 referencias. |
| `feedbacks y comentarios extra.md` | 8 KB | **Documento de observaciones.** Dos partes: (a) el correo original de los revisores, y (b) la plantilla vacía de *Author's response / Author's action*. |

Sin ambigüedad en la identificación.

**Nota:** no hay archivos de figuras en la carpeta. El `.md` referencia 5 imágenes que viven solo en Overleaf: `fig_cad_model_simulator.png`, `Figura 3.jpg`, `fig_software_block_diagram.png`, `fig_test_setup.png`, `Figura 5.jpg`.

### ⚠️ Aviso de numeración de figuras (crítico para la carta de respuesta)

Los `\label` internos **no coinciden** con el número que ve el revisor, porque falta un `fig:2` en la secuencia:

| `\label` en el código | Número compilado (el que ve el revisor) | Contenido |
|---|---|---|
| `fig:1` | **Figura 1** | Modelo CAD |
| `fig:3` | **Figura 2** | Sistema eléctrico / electrónico |
| `fig:4` | **Figura 3** | Diagrama de software |
| `fig:5` | **Figura 4** | Setup experimental (foto del simulador) |
| `fig:6` | **Figura 5** | Evaluación funcional (ángulo + Fz) |

Esto cuadra con lo que dicen los revisores ("easier to see the simulator at Figure 4", "Figure 5: the Fz seems ok"). Traducción práctica:

- R1 pide "incluir la prótesis en **Figure 1**" → es el CAD, `\label{fig:1}`.
- R2 pide "improve **Figure 5**" → es la evaluación funcional, `\label{fig:6}`, archivo `Figura 5.jpg`.

---

## PASO 1-bis — Verificación: ¿el correo y la plantilla son lo mismo?

**Confirmado por comparación automática línea a línea: SÍ, es exactamente el mismo texto.**

El diff no arroja ni una sola diferencia de contenido. Las únicas 32 "diferencias" detectadas son:

- el prefijo `Comment N:` añadido en la plantilla,
- la numeración `1.`, `2.`, `3.`… del correo de R2 que se eliminó al trocear,
- las cabeceras `======= Extended Submission 2 =======` y la línea `*** Detailed comments…` que no se copiaron.

Cero texto añadido, cero texto perdido, cero reformulación.

**Conclusión operativa:** se trabaja sobre la segunda parte del archivo (la de las cajas `Author's response` / `Author's action`). La primera parte queda solo como registro del correo original.

### Detalle importante sobre el troceo de R1

El troceo de R1 respetó las **secciones del manuscrito**, no las peticiones individuales. Por eso hay **5 cajas pero 7 pedidos reales**:

| Caja | Peticiones que contiene |
|---|---|
| **R1-C1** | (a) la asimetría no es necesariamente mala + pide cita · (b) limitaciones de simuladores previos + "¿por qué [20] es complejo?" |
| **R1-C2** | (a) prótesis en la Fig. 1 · (b) figura de marcadores + cálculo del ángulo |
| **R1-C3** | una |
| **R1-C4** | una |
| **R1-C5** | una |
| **R2-C1 … C10** | una cada una (C3 y C7 traen sub-ítems en viñetas) |

En las cajas R1-C1 y R1-C2 la respuesta **debe atender las dos peticiones**, o el revisor va a sentir que le contestamos la mitad.

---

## PASO 2 — Las 15 observaciones extraídas

### Revisor 1 — 5 comentarios (2 de ellos con sub-partes)

| # | Cita / resumen fiel | Sección | Tipo de cambio |
|---|---|---|---|
| **R1-1a** | "I dont agree that gait asymmetries is necessarily bad for the person. Any citation for these? Since gait asymmetries are also found in healthy subject." | Introducción, párr. 1 | Matiz textual + cita bibliográfica específica |
| **R1-1b** | "the author needs to discuss the limitation of previously designed gait simulator. Why the [20] is complex?" | Introducción, párr. 2 y 4 | Contenido nuevo (limitaciones concretas) + aclaración de atribución |
| **R1-2a** | "Figure 1 should include the prosthesis… I suggest to include the prosthesis in Figure 1 also." | Métodos / Fig. 1 (CAD) | **Figura nueva/modificada** (render CAD) |
| **R1-2b** | "Marker location should be shown in a Figure. Some calculation regarding the inclination angle modelling using the marker is necessary. Its hard to understand which inclination angle do you mean?" | Functional Assessment | **Figura nueva** + **ecuación nueva** + aclaración |
| **R1-3** | "Figure 5: the Fz seems ok. The inclination angle also nice." | Resultados | **Sin cambio** — solo agradecimiento |
| **R1-4** | "Explain how the design is simpler, yet produced appropriate result? direct comparison with complex approach that you said in [20] is demanded." | Discusión | Contenido nuevo: comparación con literatura |
| **R1-5** | "Conclusion — Is enough" | Conclusión | **Sin cambio** por parte de R1 |

### Revisor 2 — 10 comentarios

| # | Cita / resumen fiel | Sección | Tipo de cambio |
|---|---|---|---|
| **R2-1** | Corregir y completar la Referencia [2], "incompleta y puede no representar la fuente pretendida". | Bibliografía | Corrección bibliográfica |
| **R2-2** | Usar *accuracy, agreement, correlation, tracking error, repeatability* de forma consistente y según su significado estadístico. | Global | Pase editorial de terminología |
| **R2-3** | Describir el procesamiento de señal: filtrado, frecuencia de corte, detección de eventos, normalización temporal, remuestreo, marcadores perdidos. | Functional Assessment | **Dato faltante** — subsección nueva |
| **R2-4** | Completar velocidad de marcha, duración del ciclo, duración del apoyo, duración de ejecución del simulador. | Functional Assessment | **Dato faltante** |
| **R2-5** | Explicar la justificación del % de puntos dentro de ±1 SD. "No es una medida estándar de concordancia y se basa en solo diez ciclos de un participante." | Métodos + Resultados | Justificación metodológica + limitación |
| **R2-6** | Eliminar o sustentar la afirmación de *cost-effective*. Sería útil un BOM o costo aproximado. | Introducción | Eliminar **o** dato nuevo |
| **R2-7** | Mejorar la Figura 5: bandas de variabilidad del simulador, valores pico, anotaciones temporales, curva de error/residual. | Fig. 5 (`fig:6`) | **Figura regenerada** |
| **R2-8** | Reportar la GRF en Newtons **y** en %BW. | Métodos, Resultados, Fig. 5(c), Abstract | Conversión + edición |
| **R2-9** | Terminología consistente para repetibilidad, p. ej. "intra-device inter-trial repeatability". | Global | Pase editorial |
| **R2-10** | Revisar la conclusión para reflejar el carácter preliminar. **Entrega texto alternativo literal.** | Conclusión (+ Abstract) | Reescritura |

---

## PASO 3 — Cruce con el manuscrito

Referencias de línea sobre `articulo original.md`.

### R1-1a — Asimetrías de marcha · línea 81
> "In individuals with lower-limb amputation, these interactions are altered by the prosthetic device, **often leading to gait asymmetries, increased energy expenditure, and abnormal loading patterns that may compromise mobility and long-term musculoskeletal health**. …`\cite{ref1,ref2,ref3,ref4,ref5}`"

**Existe.** Hay un bloque de 5 citas al final del párrafo, pero genérico — el revisor no ve cita *específica* para esa afirmación. Y la redacción sí suena categórica.

### R1-1b — Limitaciones de simuladores previos · líneas 83 y 87

Línea 83 (única mención a limitaciones, totalmente genérica):
> "However, each approach presents limitations regarding their biomechanical realism, implementation complexity, computational requirements, or experimental reproducibility `\cite{ref8,…,ref14}`."

Línea 87:
> "the development of gait simulators has been shown to involve an inherent trade-off between the number of controlled degrees of freedom and system cost and complexity, with high-DOF platforms requiring substantial capital investment and reduced-DOF designs facing a corresponding compromise in simulation accuracy `\cite{ref20}`."

**Parcialmente existe, sin especificidad.**

> ⚠️ **El manuscrito NUNCA dice que [20] sea complejo.** Cita a [20] como fuente del *trade-off*. El revisor lo leyó al revés. Ver análisis en Paso 4.

### R1-2a — Prótesis en Figura 1 · líneas 101-107
`fig:1`, caption: *"CAD model of the final mechanical architecture and principal motion modules."* **No incluye prótesis.** El montaje se menciona en texto (línea 109, plataforma de 150×120 mm) pero no se ve.

### R1-2b — Marcadores y ángulo · líneas 193-195
Todo en prosa, **sin figura ni ecuación**:
> "Four reflective markers were placed on the reference subject: the first at the lateral malleolus and the second 42 cm proximal to it… A third marker was placed at the midpoint of the segment formed by these two markers, and a fourth marker was aligned with the third to form a segment perpendicular to the tibial segment… The tibial-segment inclination angle was computed from the marker coordinates using the `atan2` function, defined as positive above the horizontal reference and negative below it."

**No existe ni la figura de marcadores ni la ecuación.** El manuscrito **no tiene ninguna ecuación numerada** en todo el documento. Además la descripción es objetivamente difícil de seguir: no queda claro para qué sirven los marcadores 3 y 4 si el ángulo tibial parece obtenerse de los dos primeros.

### R1-3 — Figura 5 Fz "ok" · líneas 207-212, 223
Comentario positivo. Nada que cruzar.

### R1-4 — Discusión: ¿por qué es más simple? · línea 231
> "Overall, these findings indicate that the mechanical design and control architecture… Furthermore, the results show that the proposed reduced-degree-of-freedom architecture can reproduce the essential gait characteristics required for transtibial prosthesis evaluation."

**No existe comparación con literatura en toda la Discusión** — la sección completa (líneas 226-231) tiene **cero citas**. Ese es el hueco real.

### R2-1 — Referencia [2] · líneas 251-252
```latex
\bibitem{ref2}
\textit{Gait Analysis: Normal and Pathological Function}," J. Sports Sci. Med., vol. 9, no. 2, p. 353, Jun. 2010
```
**Confirmado defectuoso:** sin autor, con una comilla `"` huérfana, sin editorial, y citando *Journal of Sports Science and Medicine* vol. 9 p. 353 — que es una **reseña de una página** del libro, no el libro. El revisor tiene toda la razón.

### R2-2 — Terminología · líneas 71, 221, 227, 229, 237-239
- L71 (abstract): "reproduced… with **RMSE**… **correlation coefficients**… **ICC(3,1)**"; "can **accurately and repeatably** reproduce"
- L221: "**Agreement** between the simulator output and the reference subject trajectory was quantified using RMSE, the Pearson correlation coefficient (r), and the percentage of simulator data points within ±1 SD"
- L227: "confirmed that the simulator **accurately reproduces**"
- L229: "a strong **waveform correlation** was obtained"
- L237-239: "confirmed the platform's **fidelity**"; "an **accurate, repeatable**, and controlled experimental platform"

**El problema concreto está en L221:** llama *agreement* a un conjunto que incluye RMSE (que es error de seguimiento) y r (que es similitud de forma). El término *tracking error* nunca aparece pese a ser exactamente lo que mide el RMSE aquí.

### R2-3 — Procesamiento de señal · líneas 191-197
Describe cámara (120 fps), marcadores, iluminación, calibración píxel-métrica en Kinovea, AMTI a 1000 Hz, normalización a %BW.

**NO existe absolutamente nada sobre:** filtro, frecuencia de corte, detección de contacto inicial/despegue, normalización a 0-100% del ciclo, remuestreo, ni marcadores perdidos/oclusiones. Los 6 sub-ítems del revisor están al 0%.

### R2-4 — Parámetros temporales · líneas 187, 217, 219
Hay: sujeto (hombre, 86 kg, 1.74 m), 10 ciclos por fase, 10 repeticiones del simulador.
**No existe:** velocidad de marcha, duración del ciclo, duración del apoyo, duración de ejecución del simulador.

### R2-5 — % dentro de ±1 SD · líneas 221, 223
Método (L221): "…and the percentage of simulator data points within ±1 SD of the reference trajectory."
Resultados (L223): "100% of points within ±1 SD" (apoyo), "72.50% of points within ±1 SD" (balanceo).
**Existe la métrica, no existe ninguna justificación ni cita.**

### R2-6 — "cost-effective" · línea 87
> "…capable of reproducing the essential kinematic and kinetic demands of gait within a reduced and **cost-effective** mechanical architecture."

**Es la única aparición literal** de la afirmación. El abstract dice "practical experimental platform", que es más defendible. La línea 150 menciona "cost" como criterio de selección de la cadena ANSI 35 — eso es justificación de diseño, no una afirmación global, y no parece ser el blanco del revisor.

### R2-7 — Mejorar Figura 5 · líneas 207-212
Caption actual:
> "The black line and shaded area represent the reference subject mean ± 1 SD, while **the dashed red line represents the simulator mean**."

**Confirma la crítica:** la referencia tiene banda ±1 SD, el simulador **solo tiene la media, sin banda de variabilidad**. Tampoco hay picos anotados, ni marcas temporales, ni curva residual.

### R2-8 — GRF en N y %BW · líneas 71, 197, 223
L197: "normalized to the subject's body weight (86 kg) and expressed as \%BW"; L223: "RMSE = 21.87\%BW".
**Solo %BW en todo el documento, en ningún lado Newtons.**
Conversión disponible: 86 kg × 9.81 = **843.7 N** → 21.87 %BW ≈ **184.5 N**.

### R2-9 — Terminología de repetibilidad · líneas 219, 221, 71/223/227, 237
Cuatro formas distintas para lo mismo:
- L219: "to assess **output repeatability**"
- L221: "the **repeatability of the simulator across its ten programmed repetitions**"
- L71/223/227: "**inter-repetition** ICC(3,1)"
- L237: "the high **inter-repetition ICC** values demonstrated its repeatability"

**Existe la inconsistencia** que señala el revisor (aunque es leve).

### R2-10 — Conclusión preliminar · línea 239
> "These results indicate that the proposed simulator constitutes an **accurate, repeatable, and controlled experimental platform for the engineering evaluation of transtibial prostheses** prior to comprehensive biomechanical validation."

**Existe y es exactamente lo que el revisor objeta.** También arrastra al abstract (L71, "can accurately and repeatably reproduce gait kinematics") y a L231 ("with high fidelity and repeatability").

---

## PASO 4 — Análisis y clasificación por quién puede resolverlo

- 🟢 **lo resuelvo yo solo** con el texto actual
- 🟡 **lo redacto yo**, pero necesito que confirmes un dato o tomes una decisión
- 🔴 **depende de datos, figuras o análisis** que yo no puedo generar en esta carpeta

| Estado | Observaciones |
|---|---|
| 🟢 **Listas para hacer** (4) | R2-1 · R2-9 · R2-10 · R1-3/R1-5 (solo carta) |
| 🟡 **Con tu decisión** (5) | R2-2 · R2-5 · R2-6 · R2-8 · R1-1a |
| 🔴 **Bloqueadas** (6) | R2-3 · R2-4 · R2-7 · R1-2a · R1-2b · R1-1b/R1-4 |

### 🟢 R2-1 · Referencia [2]
**Claridad: total.** La entrada está rota. Lo que casi seguro se quiso citar es el libro:
> J. Perry and J. M. Burnfield, *Gait Analysis: Normal and Pathological Function*, 2nd ed. Thorofare, NJ, USA: SLACK Incorporated, 2010.

**Antes de fijarla hay que verificarla** contra la fuente (edición, editorial, año). No se da por buena de memoria.

### 🟢 R2-10 · Conclusión preliminar — *regalo del revisor*
**Claridad: total.** Nos dio el texto redactado. Adoptarlo prácticamente literal (los revisores lo agradecen mucho) y **suavizar en cascada** el abstract (L71) y L231 para que no se contradigan.

Conflicto aparente: R1 dijo "Conclusion is enough". No es un veto — R1 simplemente no pidió cambios. Se le explica en su carta que se revisó atendiendo a un pedido del Revisor 2.

### 🟢 R2-9 · Terminología de repetibilidad
**Claridad: total.** Definir el término una vez en Métodos ("**intra-device inter-trial repeatability**, quantified with ICC(3,1)") y usarlo idéntico en las 5-6 apariciones. Cambio cosmético, cero riesgo.

### 🟡 R2-2 · Terminología estadística — *más de fondo de lo que parece*
**Claridad: media.** El revisor no dice qué está mal, pero al leer L221 se ve: se llama **agreement** a un paquete que mezcla RMSE (error), r (forma) e ICC (repetibilidad).

Convención propuesta, a fijar en Métodos y respetar en todo el texto:

| Métrica | Término asignado | Qué NO se dice de ella |
|---|---|---|
| RMSE (sim. vs. referencia) | **tracking error** / *trueness* | no llamarlo "agreement" |
| Pearson *r* | **waveform correlation** (similitud de forma) | no llamarlo "accuracy" ni "agreement" |
| ICC(3,1) entre repeticiones | **intra-device inter-trial repeatability** (*precision*) | no llamarlo "accuracy" |
| % puntos dentro de ±1 SD | **descriptive band overlap** | no llamarlo "agreement" (ver R2-5) |

Es **el cambio de mayor superficie** de todo el paquete: toca abstract, métodos, resultados, discusión y conclusión. Se puede reforzar citando ISO 5725 (trueness/precision) si se quiere respaldo formal.

### 🟡 R2-5 · Justificación del % dentro de ±1 SD
**Claridad: alta, y el revisor tiene razón.** Es descriptiva, no de concordancia, y n=10 ciclos de 1 sujeto. Tres caminos:

- **(a) Defender + reencuadrar** *(recomendado)*. Mantenerla, redefinirla explícitamente como *descriptive measure of how much of the simulator curve falls inside the subject's natural inter-cycle variability band*, decir que **no** se presenta como medida de concordancia, y añadir la limitación de n=1 sujeto. Costo: ~4 líneas. Riesgo: bajo.
- **(b) Quitarla.** Hay que borrar "100%" y "72.50%" de Resultados y del abstract. Debilita los resultados sin ganar nada.
- **(c) Sustituirla por una métrica formal** (Bland-Altman sobre features 0-D, o SPM1D). 🔴 Análisis nuevo, requiere datos crudos fuera de esta carpeta, y probablemente no cabe en un paper de conferencia.

### 🟡 R2-6 · "cost-effective"
- **(a) Quitar la palabra** en L87 → "reduced-complexity mechanical architecture". Costo: 1 palabra. Riesgo: cero. El revisor explícitamente permite "remove".
- **(b) Sustentarla** con costo total aproximado o BOM resumido. Más fuerte para el paper y **refuerza R1-4** (el argumento de "más simple"), pero requiere el número del equipo.

### 🟡 R2-8 · GRF en Newtons y %BW
**Fácil, salvo dos detalles que hay que confirmar:**
1. ¿La normalización se hizo con **peso** (86 × 9.81 = 843.7 N) o con **masa** (86, tratando %BW como % de 86 "kgf")? Cambia el número.
2. Para reportar los **picos** en N (que es lo que más querrá ver el revisor, y engancha con R2-7) hacen falta los valores pico reales de referencia y simulador — no están en el manuscrito.

### 🟡 R1-1a · Asimetrías de marcha
**El revisor tiene razón de fondo.** Existe asimetría en marcha sana (dominancia de miembro) y no toda asimetría es patológica. No conviene pelearla: se matiza y se gana un revisor.

**Hallazgo útil:** `ref4` (Gailey et al. 2008, *secondary physical conditions associated with lower-limb amputation*) **es exactamente la cita que el revisor pide** y ya está en la bibliografía — solo hay que anclarla a la frase concreta en vez de dejarla en el bloque genérico. Solo haría falta **1 cita nueva** para la parte de "también en sanos".

### 🔴 R1-1b + R1-4 · Limitaciones previas y comparación con [20] — *el punto más delicado*

Dos hallazgos que condicionan la respuesta:

1. **El manuscrito nunca afirma que [20] sea complejo** (ver Paso 3). El revisor lo interpretó al revés.
2. **[20] es Sudeesh et al. (2024), titulado literalmente "A *compact and cost-effective* gait simulator…"**. El trabajo con el que R1 nos pide compararnos "como enfoque complejo" se presenta a sí mismo como compacto y económico — igual que el nuestro. Escribir "nuestro diseño es más simple que [20]" sin datos es exponerse a un contraataque en la segunda ronda.

**Estrategia en dos movimientos:**
- **En la carta:** aclarar que no se atribuyó complejidad a [20], **asumiendo la culpa de la redacción** ("we acknowledge that the original phrasing could be misread…"). Nunca "usted entendió mal"; siempre "nos expresamos mal".
- **En el texto:** convertir la frase genérica de L83 en limitaciones **nombradas y concretas** por familia de enfoque (bancos mecánicos / simuladores robóticos / modelos musculoesqueléticos / HIL / simuladores usados por sujetos sanos), y añadir en Discusión un párrafo o tabla de posicionamiento honesto.

**Bloqueo:** hacen falta los datos de [20] y de 2-3 simuladores más (nº de DOF, actuación, si reportan costo, métricas de validación). No se pueden inventar.

### 🔴 R2-3 · Procesamiento de señal
**Claridad: total, es una lista cerrada.** El manuscrito es mudo en los 6 puntos. Los datos necesarios están listados en `DISCUSION_COMENTARIOS.md`.

> ⚠️ Existen scripts de MATLAB del proyecto Q2 fuera de esta carpeta que podrían tener algunos de estos parámetros, **pero podrían corresponder a otro procesamiento**. No se asumen sin confirmación.

### 🔴 R2-4 · Parámetros temporales
Cuatro números que no están en el manuscrito. Nota estratégica: si el simulador corre a velocidad muy distinta de la marcha real, **hay que decirlo explícitamente** — es una limitación honesta que el revisor valorará más que el silencio, y además afecta la interpretación de la Fz (efectos inerciales dependientes de la velocidad).

### 🔴 R1-2a · Prótesis en la Figura 1 (CAD)
Requiere un render nuevo desde Autodesk Inventor con la prótesis montada en la plataforma de 150×120 mm. **Acción del equipo (Mecatrónica).** El caption actualizado y la respuesta al revisor se redactan apenas exista la imagen.

### 🔴 R1-2b · Figura de marcadores + ecuación — *el más importante de R1*
**El revisor tiene toda la razón: el texto actual es genuinamente confuso.** Se necesitan tres cosas: figura esquemática nueva, primera ecuación numerada del paper, y reescritura de L193-195. **Falta entender la geometría real de los 4 marcadores** — ver pregunta en `DISCUSION_COMENTARIOS.md`.

### 🔴 R2-7 · Mejorar la Figura 5
Los 4 ítems son legítimos. El más importante es el primero: **la figura muestra banda ±1 SD para la referencia pero solo la media del simulador**. Siendo la repetibilidad el argumento central del paper, es una omisión llamativa — y los datos existen (hay 10 repeticiones, ya se calculó ICC sobre ellas).

Requiere **regenerar las figuras en MATLAB desde los datos crudos**, que están fuera de esta carpeta. No se resuelve editando el `.md`.

**Sub-decisión de layout:** añadir curva residual a los 3 paneles convierte la figura en 6 paneles, lo que pesa en un paper con límite de páginas. Alternativas: (a) 3 paneles con residual en eje secundario, (b) fila de 3 + fila de 3 residuales, (c) residual solo para Fz (donde está el problema de magnitud).

---

## Dos avisos técnicos sobre el formato del entregable

### 1. `\hl{}` no va a funcionar tal como está el preámbulo

El comando `\hl` **no** viene de `xcolor` (que sí está cargado, línea 11) — viene del paquete **`soul`**, que **no está cargado**. Hay que añadir al preámbulo:

```latex
\usepackage{soul}
\sethlcolor{yellow}
```

Además, `\hl{}` **se rompe** si dentro hay `\cite{}`, `\ref{}` o matemáticas. Para esos casos hay que sacar la cita fuera del `\hl{}` o envolverla en `\mbox{}`. Si se van a resaltar párrafos enteros con citas dentro, conviene preparar las líneas ya partidas correctamente — es un error de compilación muy común y aparecería justo al final, con el tiempo encima.

### 2. Dónde va el documento de respuesta

La plantilla de *Author's response / Author's action* está dentro del mismo `feedbacks y comentarios extra.md`, mezclada con el correo original. **Recomendación:** generar un archivo nuevo (`respuesta_revisores.md`) y dejar el original intacto como registro.

---

## Preguntas transversales pendientes (afectan a varias observaciones)

1. **¿Hay límite de páginas y/o de referencias en la versión extendida de IBITeC?** Condiciona R2-3, R2-4, R2-7, R1-1b y R1-4 — que son justamente los que más texto y figuras añaden.

2. **¿Se puede añadir figuras nuevas?** R1-2a y R1-2b piden dos figuras adicionales.

3. **¿Autorización para buscar y verificar literatura nueva?** Necesario para R1-1a (asimetría en sanos) y R1-1b/R1-4 (limitaciones de simuladores previos).

