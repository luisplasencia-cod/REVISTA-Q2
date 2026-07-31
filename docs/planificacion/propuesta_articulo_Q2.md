# Propuesta del artículo Q2 — Simulador de marcha 3-DOF

**Rol de este documento:** propuesta de fondo, escrita desde la perspectiva de un revisor/editor de revista Q2 en ingeniería biomédica, para alinear al equipo antes de escribir una sola línea del manuscrito. No es el manuscrito — es el "por qué así" detrás de cada decisión de metodología, resultados y narrativa. Se apoya en `plan_trabajo_5_semanas_articulo_Q2.md` (misma carpeta), `../etica/comite_etica.md` y `../equipo/tarea_alessandro.md`, y no repite lo que ya está decidido ahí (ver `../../CLAUDE.md`).

---

## 1. La pregunta que un revisor Q2 hace primero

Antes de mirar métodos o resultados, un revisor de una revista de ingeniería biomédica Q2 se pregunta: **"¿por qué esto y no el paper de conferencia otra vez?"**. Si no puede contestar esa pregunta en el primer párrafo del abstract, el manuscrito arranca cuesta arriba.

La respuesta ya está definida en `../../CLAUDE.md` y es la correcta:

> El simulador reproduce patrones de marcha de sujetos que **no** participaron en su programación, medido con dos instrumentos independientes que concuerdan entre sí, con una explicación cuantificada — no solo narrada — de las fuentes de error.

Tres elementos hacen esa tesis publicable en Q2, y los tres tienen que aparecer explícitamente en el abstract, no solo en la discusión:
1. **Generalización** (sujetos nuevos, no el sujeto de calibración) — esto es lo que el paper de conferencia no puede reclamar.
2. **Triangulación instrumental** (Kinovea + STT-IWS, y el IMU de bajo costo como validación adicional) — un solo instrumento nunca convence a un revisor de biomecánica.
3. **Descomposición cuantificada del error** (corrección inercial de Fz, separación error de control vs. error de medición) — esto es lo que distingue "funciona" de "sabemos por qué funciona hasta donde funciona".

Si en algún punto de la redacción alguna sección deja de servir a uno de estos tres pilares, es candidata a recortarse — los revisores Q2 penalizan manuscritos que se sienten como "todo lo que hicimos" en vez de "el argumento que estamos probando".

---

## 2. Título — opciones evaluadas

| Opción | Por qué funciona / por qué no |
|---|---|
| *"Development, Multi-Instrument Validation, and Multi-Subject Kinematic Assessment of a 3-DOF Gait Simulator for Transtibial Prosthesis Testing"* (ya propuesto en el plan) | Correcto pero denso — un revisor lee "Development" y puede confundirlo con el paper de conferencia. |
| **"Multi-Instrument Validation of a 3-DOF Gait Simulator Against Untrained Subjects: Kinematic Concordance and Quantified Sources of Error"** *(recomendado)* | Pone la generalización ("untrained subjects") y la cuantificación del error en el título mismo — exactamente los dos puntos que diferencian este artículo del de conferencia. Evita "Development", que ya se reclamó en IBITeC 2026. |
| "Beyond Calibration: Cross-Subject and Cross-Instrument Validation of a Transtibial Gait Simulator" | Más editorial/llamativo — bueno para *Sensors*, posiblemente demasiado informal para *POI* o *IEEE TNSRE*. |

Decisión sugerida: usar la opción recomendada como título de trabajo desde ya, y guardar la tercera como alternativa si el título final se decide en la revisión cruzada de la semana 4.

---

## 3. Selección de revista — con datos actualizados (2026)

`../../CLAUDE.md` listaba cuatro candidatas asumiendo que todas eran Q2. Verifiqué las métricas actuales — dos ya no encajan en ese supuesto, y eso cambia la decisión:

| Revista | Cuartil real (2025/2026) | Impact Factor | Ajuste temático | Riesgo/nota |
|---|---|---|---|---|
| **Sensors (MDPI)** | **Q2** (Instruments & Instrumentation), IF 4.0 | Alto — la revista publica activamente validación de IMU en marcha, tiene special issues específicos de "Sensors for Gait, Posture, and Health Monitoring" | Open access con APC (~2000-2600 CHF); revisión rápida (semanas, no meses) — **compatible con el plazo de setiembre** | **Recomendación principal** |
| **Prosthetics and Orthotics International (POI)** | Q2 (Rehabilitation / Health Professions), IF 1.4 | Máximo ajuste clínico — revista oficial de ISPO, exactamente el público que le da relevancia clínica al argumento | IF bajo compensado por ser *la* revista del campo — un revisor de POI entiende de inmediato por qué importa una prótesis transtibial bien validada | **Recomendación secundaria fuerte**, sobre todo si Discusión enfatiza aplicabilidad clínica |
| Medical Engineering & Physics | **Q3** actualmente (IF 2.3), no Q2 como se asumía | Buen ajuste técnico, pero ya no cumple el criterio "Q2" del objetivo del ciclo | Mantener como plan C si Sensors/POI rechazan | Bajar de prioridad |
| IEEE TNSRE | **Q1** actualmente (IF 5.2), no Q2 | Ajuste temático excelente pero barra de rigor y competencia mucho más alta (CiteScore 8.1) | Con n pequeño (1 sujeto original + 2-3 nuevos) y timeline de 5 semanas, el riesgo de rechazo por "sample size" es alto aquí | No recomendada para este ciclo — candidata para un segundo artículo con más sujetos |

**Recomendación:** apuntar a **Sensors** como primera opción — el ángulo de "validación multi-instrumento de sensórica inercial en marcha" es exactamente su línea editorial, el timeline de revisión es compatible con la fecha límite, y el manuscrito ya viene con la instrumentación (STT-IWS, IMU de bajo costo) como protagonista. **POI** como segunda opción si el equipo prefiere maximizar relevancia clínica sobre impact factor, o como destino de resubmission si Sensors rechaza.

Esta decisión hay que cerrarla en la tarea **[S1] Elegir revista Q2 objetivo** (task #3) — recomiendo cerrarla con Sensors, porque el formato de figuras/abstract estructurado de MDPI condiciona cómo se redactan Métodos y Resultados desde el borrador, no al final.

---

## 4. Metodología — qué necesita un revisor Q2, y por qué

No es una lista de qué se va a hacer (eso ya está en el plan). Es la justificación que hay que tener lista quirúrgicamente, porque son los puntos donde un revisor de biomecánica ataca primero:

### 4.1 Justificación de las métricas estadísticas

| Métrica | Qué prueba | Objeción típica de revisor si falta |
|---|---|---|
| RMSEnorm | Magnitud de la discrepancia, normalizada por variabilidad de referencia | "¿Por qué RMSE crudo sin normalizar? No es comparable entre segmentos." — ya resuelto al usar la versión normalizada |
| Pearson r | Co-variación de forma | "r alto en curvas monótonas no significa nada" — **hay que decir esto explícitamente en Métodos**, no esperar que el revisor lo señale. Una frase como *"Pearson's r is reported for completeness but interpreted jointly with RMSEnorm and SPM1D, given its known insensitivity to offset and scaling errors in monotonic phases of the gait cycle"* neutraliza la objeción antes de que aparezca. |
| % puntos dentro de ±1 SD | Envolvente de tolerancia clínica | Poco riesgo, es intuitivo para revisores clínicos (POI) |
| ICC(3,1) | Repetibilidad / concordancia entre instrumentos | **Especificar el modelo exacto** (two-way mixed effects, single measurement, consistencia vs. acuerdo absoluto) — "ICC" a secas sin el modelo es un rechazo típico en revisión estadística |
| SPM1D | Dónde en el ciclo hay diferencia significativa | Es el elemento que más "moderniza" el manuscrito frente al de conferencia — pero hay que reportar tamaño de efecto o al menos el % del ciclo con diferencia, no solo el mapa binario significativo/no-significativo |
| Bland-Altman | Sesgo + límites de acuerdo entre instrumentos | Reportar sesgo medio, límites de acuerdo (±1.96 SD), y si el sesgo es proporcional (heterocedasticidad) — si no se menciona la posible dependencia del sesgo con la magnitud, un revisor lo va a preguntar |
| Corrección inercial de Fz | Explica la sobreestimación en vez de solo reportarla | El punto fuerte del artículo — pero exige mostrar el **antes/después** con las tres curvas superpuestas (cruda, corregida, literatura), no solo un párrafo de texto |

### 4.2 El punto más frágil del diseño: tamaño de muestra

Con 1 sujeto original + 2-3 sujetos nuevos, **cualquier revisor Q2 va a preguntar por poder estadístico**. La defensa correcta no es pretender que no es una limitación — es:
- Encuadrar el estudio explícitamente como **validación técnica de instrumento/sistema**, no como estudio clínico de eficacia — el estándar de n para validación de instrumentación (tipo ISO/ASTM de equipos biomecánicos) es mucho más permisivo que el de estudios clínicos comparativos.
- Usar SPM1D y Bland-Altman (que no dependen de supuestos de gran muestra de la misma forma que un t-test) como el argumento metodológico de por qué n pequeño sigue siendo informativo aquí.
- Declarar el tamaño de muestra como limitación **en una frase corta y temprana** de Discusión, no enterrada al final — los revisores confían más en autores que se adelantan a la limitación.

### 4.3 Rigidez de la prótesis — ya resuelto en las decisiones del proyecto

Ya está decidido no resolverlo este ciclo (`../../CLAUDE.md`). Para que eso no lea como "no lo hicimos", la redacción debe encuadrarlo como decisión metodológica deliberada, y — actualizado en sesión del 31-jul-2026 — apoyada en una descomposición de tres fuentes de error, no un solo término genérico: *"stiffness characterization via universal testing machine was outside the scope of this validation cycle; instead, the vertical force overestimation is decoupled into (1) a fixed vertical datum offset calibrated once against an independent load reference, (2) command-to-encoder tracking fidelity per axis, and (3) an axis-wise inertial correction using the mass that actually accelerates with each motor (horizontal, vertical, sagittal) rather than the total assembly mass, benchmarked against published prosthetic gait GRF data"* — la diferencia entre "limitación admitida con solución alternativa" y "hueco" es la redacción, no el dato. Este desglose en tres fuentes es además el ejemplo más concreto del pilar 3 de la sección 1 (descomposición cuantificada del error) y encaja directo con la idea 3 de la sección 8 ("Sources of error, decoupled").

**Nota de rigor:** la calibración del offset (1) debe hacerse con datos independientes de los sujetos que se reportan en Resultados — nunca ajustando contra la curva del sujeto de referencia que luego se usa para validar, porque eso sería circular. Se fija una sola vez y se congela para todo el estudio.

---

## 5. Resultados — qué necesita mostrarse, y en qué orden

Recomiendo estructurar Resultados en el mismo orden que la matriz de comparaciones del plan (`plan_trabajo_5_semanas_articulo_Q2.md`, sección 10), porque esa matriz **ya está ordenada por dependencia lógica**: primero se establece que los instrumentos concuerdan entre sí (sin eso, nada más importa), luego que el simulador sigue fielmente lo que se le programa, y al final la explicación del error de fuerza.

| Orden | Resultado | Figura/tabla mínima esperada |
|---|---|---|
| 1 | Concordancia Kinovea vs. STT-IWS (sujeto original) | Bland-Altman plot + tabla ICC |
| 2 | Concordancia IMU de Alessandro vs. STT-IWS | Bland-Altman plot (mismo formato que #1, para comparabilidad visual directa) |
| 3 | Fidelidad de seguimiento por sujeto (comparación B) | Curvas superpuestas ángulo-vs-%ciclo, banda ±1 SD, con mapa SPM1D debajo de cada curva (formato estándar en biomecánica: curva arriba, estadístico t/SPM abajo, mismo eje X) |
| 4 | Representatividad de la trayectoria por defecto (comparación A) | Misma familia de figura que #3, pero contra la salida fija — deja ver de inmediato cuánto se pierde al no reprogramar |
| 5 | Fz cruda / corregida / literatura | Una sola figura, tres curvas superpuestas, banda de literatura como referencia sombreada |
| 6 | Repetibilidad inter-repetición (ICC) por condición | Tabla resumen única al final — consolida todos los ICC del artículo en un solo lugar, algo que los revisores agradecen porque no tienen que buscar valores dispersos por el texto |

**Idea concreta para diferenciar el artículo:** cerrar Resultados con una **tabla-resumen única** que cruce las 6 comparaciones contra sus métricas (RMSEnorm, ICC, sesgo Bland-Altman, % ciclo significativo en SPM1D). Es el tipo de tabla que un revisor cita cuando recomienda aceptación, porque condensa todo el rigor metodológico en una sola mirada — y que no está en el paper de conferencia.

---

## 6. Cómo anticiparse a las objeciones típicas de un revisor Q2 en este tema

| Objeción esperable | Dónde neutralizarla |
|---|---|
| "¿Por qué no usaron un sistema de captura óptica 3D tipo Vicon como gold standard?" | Métodos: declarar que Kinovea 2D + STT-IWS inercial fue la instrumentación disponible en LIBRA, y que la concordancia cruzada entre ambos (más el benchmark de literatura) cumple el rol de validación sin depender de un sistema no disponible en el laboratorio. |
| "El simulador sigue ejecutando un CSV pregrabado — ¿qué tan generalizable es esto a control en tiempo real?" | Discusión, párrafo de trabajo futuro: mencionar explícitamente que el lazo cerrado y la generación algorítmica de trayectorias quedan para trabajo futuro (ya está en `../../CLAUDE.md`) — decirlo antes de que lo pregunten quita fuerza a la objeción. |
| "¿Por qué la corrección inercial y no una máquina de ensayos universales para caracterizar rigidez?" | Ver sección 4.3 de este documento. |
| "n muy pequeño para conclusiones de generalización" | Ver sección 4.2. |
| "Pearson r es alto pero eso no prueba nada en curvas monótonas" | Adelantarlo en Métodos (ver 4.1) — convierte una objeción en un punto de rigor metodológico propio. |
| "¿El IMU de bajo costo de Alessandro es parte de este estudio o no?" | Encuadrarlo explícitamente como **validación cruzada de instrumento, no como resultado principal** — es contenido de apoyo para este artículo, protagonista del segundo. Una frase aclaratoria en Métodos evita que un revisor pida expandir esa parte y descarrile el alcance. |

---

## 7. Checklist de calidad Q2 / ciencia abierta

Revistas Q2 en ingeniería biomédica (sobre todo *Sensors*, que es MDPI open-access) cada vez piden más explícitamente estos puntos — conviene resolverlos con tiempo, no en la semana 5:

- [ ] **Declaración de disponibilidad de datos y código** — ya contemplado en semana 5 ("Actualizar repositorio GitHub"), pero la declaración formal en el manuscrito debe decidirse antes: ¿todo el repo público, o solo los scripts de análisis con datos de ejemplo?
- [ ] **Declaración de aprobación ética** con número de protocolo — depende de que el comité apruebe (semana 1-3).
- [ ] **Declaración de conflicto de interés y financiamiento** — texto estándar, pero hay que tenerlo listo antes del ensamblado del manuscrito (semana 4), no improvisado al final.
- [ ] **CRediT authorship statement** (contribución de cada autor) — cada vez más pedido por revistas Q2; conviene decidir quién hizo qué mientras está fresco, no reconstruirlo en semana 5.
- [ ] **Reporte de género/edad/antropometría de los sujetos** de forma explícita en una tabla, no solo narrado — estándar en biomecánica.
- [ ] **Figura gráfica de resumen (graphical abstract)** — MDPI/*Sensors* lo pide como parte del envío; dado lo visual del tema (simulador + curvas de marcha), es una figura que vale la pena preparar con cuidado, no como trámite de último minuto.

---

## 8. Ideas concretas para que el manuscrito destaque

1. **Una figura "hero" en la introducción o al final de métodos**: diagrama del simulador + los tres instrumentos superpuestos (Kinovea, STT-IWS, IMU de Alessandro) sobre la misma pierna instrumentada — comunica en una imagen la triangulación instrumental que es el argumento central del artículo.
2. **Tabla-resumen única de Resultados** (sección 5 de este documento) — el diferenciador más citable frente al paper de conferencia.
3. **Discusión con subsección explícita de "Sources of error, decoupled"** — un párrafo por fuente de error (control del ESP32, medición instrumental, sobreestimación inercial de Fz), en vez de mezclarlas. Los revisores de instrumentación valoran mucho esta separación explícita.
4. **Explicitar el criterio de la prueba piloto de iSen y su resultado** como parte de la validación metodológica del propio proceso de selección de instrumentos — convierte una decisión operativa interna (¿usamos posición X,Y de iSen o no?) en un dato metodológico defendible.
5. Si el tiempo alcanza: un **apéndice o material suplementario con las curvas individuales por sujeto** (no solo promedios) — cada vez más valorado en revistas de instrumentación porque permite al lector evaluar variabilidad real, no solo la agregada.

---

## 9. Riesgos para la aceptación, y mitigación

| Riesgo | Mitigación |
|---|---|
| La aprobación de ética no llega a tiempo (semana 3) | El plan ya tiene la ruta alternativa (`tarea #26` en el tracker) — n=1 declarado honestamente, apoyado en concordancia Alessandro-vs-STT. Esto **reduce** el artículo a *Sensors* o *POI* con un alcance más modesto, pero sigue siendo publicable si la narrativa de instrumentación es sólida. |
| Sensors rechaza por alcance ("fuera de foco") | POI como plan B inmediato — mismo manuscrito, ajustar encuadre hacia relevancia clínica en la introducción/discusión. |
| Revisor pide sujetos adicionales o gold standard óptico 3D | Responder con el argumento de validación cruzada instrumental + literatura (sección 6), no prometer datos nuevos que rompan el cronograma. |
| El manuscrito termina pareciendo una versión extendida del paper de conferencia | La tarea `[S5] Revisar porcentaje de contenido nuevo` (task #38) existe justo para esto — pero conviene aplicar ese criterio también en la revisión cruzada de semana 4, no solo al final. |

---

## 10. Vínculo con el tracker de tareas

Este documento no reemplaza el plan de 5 semanas — lo informa. Las decisiones que quedan pendientes de aquí y que deberían resolverse en las próximas tareas del tracker:

- **Task #3 ([S1] Elegir revista Q2 objetivo):** recomendación de este documento es **Sensors** (primaria) / **POI** (secundaria) — cerrar esta tarea con esa decisión.
- **Task #13/#14 ([S2] Introducción/Métodos):** usar las justificaciones de la sección 4 de este documento como base de los párrafos metodológicos, no reescribirlas desde cero.
- **Task #27 ([S4] Resultados):** seguir el orden de la sección 5 de este documento.
- **Task #28 ([S4] Discusión):** usar la tabla de la sección 6 como checklist de objeciones a cubrir antes de dar la Discusión por cerrada.

Cuando el equipo decida la revista, aviso y actualizo la tarea correspondiente en el tracker.
