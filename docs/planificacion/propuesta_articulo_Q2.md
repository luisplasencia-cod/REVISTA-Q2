# Propuesta del artículo Q2 — Simulador de marcha 3-DOF

> 🚨 **SUPERADO por el pivote — 19-ago-2026.** La propuesta de fondo (argumento central, revista, objeciones anticipadas) describe el enfoque de fidelidad de seguimiento multi-sujeto, reemplazado por completo (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20). El nuevo argumento central (generación de trayectoria desde antropometría, validada contra bases de datos independientes) todavía no tiene su propia propuesta escrita — el material más cercano hoy es `analisis_escalamiento_Q1_generador_trayectorias.md`. Esta propuesta se conserva como referencia de estilo/estructura de lo que un documento de este tipo necesita cubrir, no como contenido vigente.

**Rol de este documento:** propuesta de fondo, escrita desde la perspectiva de un revisor/editor de revista Q2 en ingeniería biomédica, para alinear al equipo antes de escribir una sola línea del manuscrito. No es el manuscrito — es el "por qué así" detrás de cada decisión de metodología, resultados y narrativa. Se apoya en `plan_trabajo_5_semanas_articulo_Q2.md` (misma carpeta), `../etica/comite_etica.md` y `../equipo/tarea_alessandro.md`, y no repite lo que ya está decidido ahí (ver `../../CLAUDE.md`).

---

## 1. La pregunta que un revisor Q2 hace primero

**Revisado 03-ago-2026 — pivote a instrumentación única.** El equipo decidió capturar todo (sujetos nuevos y salida del propio simulador) con un solo sistema, STT-IWS/iSen, en vez de triangular Kinovea + STT-IWS + IMU de Alessandro. Motivo doble: (1) Kinovea resultó impreciso y manual de operar en la práctica, y (2) el paper de conferencia — que reportó los datos de Kinovea del sujeto original — no estará publicado para cuando se envíe este artículo, y reusar/citar ese dataset antes de que sea público es un riesgo de superposición de publicación, no solo una preferencia de instrumento. **Este artículo no menciona ni cita el paper de conferencia.** Ver `CLAUDE.md`, decisión "Cambio de foco (03-ago-2026)".

Antes de mirar métodos o resultados, un revisor de una revista de ingeniería biomédica Q2 se pregunta: **"¿por qué esto y no el paper de conferencia otra vez?"**. Si no puede contestar esa pregunta en el primer párrafo del abstract, el manuscrito arranca cuesta arriba.

La respuesta, reformulada tras el pivote:

> El simulador reproduce patrones de marcha de **múltiples** sujetos que **no** participaron en su programación, medido con un sistema inercial cuya validez ya está establecida en la literatura — incluida marcha con prótesis transtibial —, con una explicación cuantificada — no solo narrada — de las fuentes de error.

Tres elementos hacen esa tesis publicable en Q2, y los tres tienen que aparecer explícitamente en el abstract, no solo en la discusión:
1. **Generalización multi-sujeto** (varios sujetos nuevos, no solo el sujeto de calibración) — esto es lo que el paper de conferencia no puede reclamar, y ahora es el pilar que sostiene casi todo el peso argumental del artículo (ver punto 2).
2. **Instrumentación con validez externa ya establecida**, no re-derivada en este ciclo — apoyada en literatura publicada de STT-IWS/iSen (incluida validación específicamente en marcha con prótesis transtibial, ver `docs/literatura/validacion_instrumentos_IMU.md`), usada de forma consistente en todo el diseño (mismo instrumento para sujetos y para la salida del simulador, eliminando por diseño el problema de concordancia entre instrumentos en vez de tener que demostrarlo aparte).
3. **Descomposición cuantificada del error** (corrección inercial de Fz, separación error de control vs. error de medición) — esto es lo que distingue "funciona" de "sabemos por qué funciona hasta donde funciona".

Si en algún punto de la redacción alguna sección deja de servir a uno de estos tres pilares, es candidata a recortarse — los revisores Q2 penalizan manuscritos que se sienten como "todo lo que hicimos" en vez de "el argumento que estamos probando".

---

## 2. Título — opciones evaluadas

**Revisado 03-ago-2026:** las tres opciones originales (abajo, tachadas conceptualmente) tenían "Multi-Instrument"/"Cross-Instrument" en el centro del título — ya no corresponde tras el pivote a un solo instrumento.

| Opción | Por qué funciona / por qué no |
|---|---|
| **"Multi-Subject Functional Validation of a 3-DOF Gait Simulator for Transtibial Prosthesis Testing Using Inertial Motion Capture"** *(recomendada)* | Pone el pilar nuevo (multi-sujeto) y el método (captura inercial) en el título, sin reclamar "Development" (ya usado en IBITeC 2026) ni prometer una validación de instrumento que ya no se hace en este ciclo. |
| "Development and Multi-Subject Kinematic Validation of a 3-DOF Gait Simulator for Transtibial Prosthesis Evaluation: An Inertial-Sensor-Based Assessment" | Alternativa más larga, mantiene "Development" — revisar el límite de caracteres de título de IEEE JTEHM antes de usarla. |

Opciones descartadas (versión previa al pivote, dependían de la comparación Kinovea vs. STT-IWS que ya no está en el alcance): *"Development, Multi-Instrument Validation, and Multi-Subject Kinematic Assessment..."*; *"Multi-Instrument Validation of a 3-DOF Gait Simulator Against Untrained Subjects..."*; *"Beyond Calibration: Cross-Subject and Cross-Instrument Validation..."*.

Decisión sugerida: usar la primera opción como título de trabajo desde ya, y confirmar el título final en la revisión cruzada de la semana 4.

---

## 3. Selección de revista — DECISIÓN FINAL: IEEE JTEHM (03-ago-2026, sexta y última vuelta)

**Journal of Translational Engineering in Health and Medicine** (IEEE/EMBS) — Q2 (una fuente dice Q1), IF 3.9, dentro de la lista de editoriales aprobadas por la universidad (IEEE/IET Electronic Library). Vigente hasta que se diga lo contrario.

**Enlaces oficiales:**
- Página de la revista: https://www.embs.org/jtehm/
- Instrucciones para autores: https://www.embs.org/jtehm/instructions-for-authors/
- FAQs (APC, descuentos): https://www.embs.org/jtehm/about/faqs/
- Plantillas (redirige a selector genérico de IEEE): https://journals.ieeeauthorcenter.ieee.org/create-your-ieee-journal-article/authoring-tools-and-templates/ieee-article-templates/templates-for-ieee-journal-of-translational-engineering-in-health-and-medicine/
- Selector interactivo de plantillas IEEE: https://template-selector.ieee.org/
- Organización oficial de IEEE en Overleaf: https://www.overleaf.com/org/ieee
- Requisitos de figuras (política general IEEE): https://journals.ieeeauthorcenter.ieee.org/create-your-ieee-journal-article/create-graphics-for-your-article/file-formatting/

**Por qué, tras reanalizar:** la recomendación inicial de esta sección era *Gait & Posture*, apoyada en que la cinemática (su fuerte) corría menos riesgo que la cinética (bloqueada por la integración Raspberry Pi–ESP32). El usuario corrigió ese argumento: **la integración bloquea igual a la cinemática que a la cinética** — ninguna comparación que necesite mover el simulador puede avanzar sin ella. Sin esa asimetría de riesgo, el ajuste de contenido completo (mitad cinemática multi-sujeto + mitad de ingeniería de corrección de Fz) favorece a JTEHM, cuya misión editorial explícita es "soluciones de ingeniería probadas y demostradas en contextos clínicos reales" — encaja con las dos mitades del artículo, no solo una.

**Documentación de soporte creada:**
- `docs/manuscrito/guia_autor_JTEHM.md` — guía completa: límite de 8 páginas incluyendo referencias (el más estricto de todas las revistas evaluadas), abstract estructurado ≤250 palabras, Clinical and Translational Impact Statement obligatorio ≤30 palabras (sin esto se devuelve el envío sin revisar), requisitos de figuras, costo y descuentos de APC.
- `docs/manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` — esqueleto listo para Overleaf, clase `IEEEtran`, con el contenido ya redactado insertado y reestructurado a la estructura de "Papers" de JTEHM (Introduction, Methods and Procedures, Results, Conclusion — sin sección Discussion separada).

**Descartadas en el camino hasta esta decisión** (detalle completo con las 6 vueltas en `revistas_candidatas_Q2.md`): POI/SAGE (no está en la lista de editoriales aprobadas por la universidad), *Bioengineering*/*Prosthesis*/*Sensors* (MDPI, bloqueada por la universidad), *Gait & Posture* (buen ajuste cinemático pero fuerza la mitad de ingeniería), *Scientific Reports* (alcance genérico, sin ajuste temático específico), *Journal of Biomechanics* (cuartil con discrepancia entre fuentes, riesgo de no cumplir Q2), *JNER* (excede el tope de presupuesto), *Medical Engineering & Physics* (Q3, no cumple Q2), *IEEE TNSRE* (guardado para 2º artículo).

**Mientras se espera la respuesta de SIBUC/VRI:** no bloquea seguir redactando — Introducción, Métodos y el resto del contenido son en gran parte independientes de cuál de las tres se elija (misma estructura IMRaD); lo que cambia es solo el formato final de plantilla y algunas declaraciones, que se ajustan al cierre.

---

## 4. Metodología — qué necesita un revisor Q2, y por qué

No es una lista de qué se va a hacer (eso ya está en el plan). Es la justificación que hay que tener lista quirúrgicamente, porque son los puntos donde un revisor de biomecánica ataca primero:

### 4.1 Justificación de las métricas estadísticas

| Métrica | Qué prueba | Objeción típica de revisor si falta |
|---|---|---|
| RMSEnorm | Magnitud de la discrepancia, normalizada por variabilidad de referencia | "¿Por qué RMSE crudo sin normalizar? No es comparable entre segmentos." — ya resuelto al usar la versión normalizada |
| Pearson r | Co-variación de forma | "r alto en curvas monótonas no significa nada" — **hay que decir esto explícitamente en Métodos**, no esperar que el revisor lo señale. Una frase como *"Pearson's r is reported for completeness but interpreted jointly with RMSEnorm and SPM1D, given its known insensitivity to offset and scaling errors in monotonic phases of the gait cycle"* neutraliza la objeción antes de que aparezca. |
| % puntos dentro de ±1 SD | Envolvente de tolerancia clínica | Poco riesgo, es intuitivo incluso para revisores sin trasfondo estadístico profundo |
| ICC(3,1) | Repetibilidad — entre ensayos del simulador reproduciendo a un mismo sujeto, y entre ciclos de la captura natural de cada sujeto (ya no "concordancia entre instrumentos", ver nota de pivote arriba) | **Especificar el modelo exacto** (two-way mixed effects, single measurement, acuerdo absoluto) — "ICC" a secas sin el modelo es un rechazo típico en revisión estadística |
| SPM1D | Dónde en el ciclo hay diferencia significativa | Es el elemento que más "moderniza" el manuscrito frente al de conferencia — pero hay que reportar tamaño de efecto o al menos el % del ciclo con diferencia, no solo el mapa binario significativo/no-significativo |
| Bland-Altman | **No se usa en este ciclo** (revisado 03-ago-2026) — estaba reservado para concordancia entre dos instrumentos (Kinovea vs. STT-IWS, IMU de Alessandro vs. STT-IWS), ninguna de las dos aplica ya. La herramienta (`BlandAltman_Core.m`) queda construida y probada, sin uso en este artículo. | No aplica — no incluir en Resultados de este ciclo. |
| Corrección inercial de Fz | Explica la sobreestimación en vez de solo reportarla | El punto fuerte del artículo — pero exige mostrar el **antes/después** con las tres curvas superpuestas (cruda, corregida, literatura), no solo un párrafo de texto |

### 4.2 El punto más frágil del diseño: tamaño de muestra

El objetivo del equipo es 15-20 sujetos nuevos (ver `CODIGOS/MULTISUJETO/`, preparado para esa escala) — mejor que el n=2-3 original, pero **sigue siendo pequeño frente a estudios clínicos comparativos**, y cualquier revisor Q2 va a preguntar por poder estadístico si el n final queda más cerca de 5-10 (riesgo real dado el cronograma). La defensa correcta no es pretender que no es una limitación — es:
- Encuadrar el estudio explícitamente como **validación técnica de instrumento/sistema**, no como estudio clínico de eficacia — el estándar de n para validación de instrumentación (tipo ISO/ASTM de equipos biomecánicos) es mucho más permisivo que el de estudios clínicos comparativos.
- Usar SPM1D (que no depende de supuestos de gran muestra de la misma forma que un t-test, y usa permutación en vez de asumir normalidad) como el argumento metodológico de por qué n pequeño sigue siendo informativo aquí.
- Declarar el tamaño de muestra como limitación **en una frase corta y temprana** de Discusión, no enterrada al final — los revisores confían más en autores que se adelantan a la limitación.

### 4.3 Rigidez de la prótesis — ya resuelto en las decisiones del proyecto

Ya está decidido no resolverlo este ciclo (`../../CLAUDE.md`). Para que eso no lea como "no lo hicimos", la redacción debe encuadrarlo como decisión metodológica deliberada, y — actualizado en sesión del 31-jul-2026 — apoyada en una descomposición de tres fuentes de error, no un solo término genérico: *"stiffness characterization via universal testing machine was outside the scope of this validation cycle; instead, the vertical force overestimation is decoupled into (1) a fixed vertical datum offset calibrated once against an independent load reference, (2) command-to-encoder tracking fidelity per axis, and (3) an axis-wise inertial correction using the mass that actually accelerates with each motor (horizontal, vertical, sagittal) rather than the total assembly mass, benchmarked against published prosthetic gait GRF data"* — la diferencia entre "limitación admitida con solución alternativa" y "hueco" es la redacción, no el dato. Este desglose en tres fuentes es además el ejemplo más concreto del pilar 3 de la sección 1 (descomposición cuantificada del error) y encaja directo con la idea 3 de la sección 8 ("Sources of error, decoupled").

**Nota de rigor:** la calibración del offset (1) debe hacerse con datos independientes de los sujetos que se reportan en Resultados — nunca ajustando contra la curva del sujeto de referencia que luego se usa para validar, porque eso sería circular. Se fija una sola vez y se congela para todo el estudio.

---

## 5. Resultados — qué necesita mostrarse, y en qué orden

**Revisado 03-ago-2026:** con Comparaciones 1 y 2 (concordancia de instrumentos) fuera del alcance, Resultados ya no necesita "establecer primero que los instrumentos concuerdan" — arranca directo en la fidelidad de seguimiento por sujeto, que ahora es el resultado principal del artículo. Orden recomendado, siguiendo la matriz de `plan_trabajo_5_semanas_articulo_Q2.md` sección 10 (Comparaciones 3, 4, 6 y 5):

| Orden | Resultado | Figura/tabla mínima esperada |
|---|---|---|
| 1 | Fidelidad de seguimiento por sujeto (Comparación 3) | Curvas superpuestas ángulo-vs-%ciclo, banda ±1 SD, con mapa SPM1D debajo de cada curva (formato estándar en biomecánica: curva arriba, estadístico t/SPM abajo, mismo eje X) — una por sujeto o consolidado en pequeños múltiplos (ver `CODIGOS/MULTISUJETO/`) |
| 2 | Representatividad de la trayectoria por defecto (Comparación 4) | Misma familia de figura que #1, pero contra la salida fija, diseño independiente — deja ver de inmediato cuánto se pierde al no reprogramar por sujeto |
| 3 | Repetibilidad inter-repetición (ICC) por sujeto y variabilidad natural entre sujetos (Comparación 6) | Tabla resumen única — consolida todos los ICC del artículo en un solo lugar, algo que los revisores agradecen porque no tienen que buscar valores dispersos por el texto |
| 4 | Fz cruda / corregida / literatura (Comparación 5) | Una sola figura, tres curvas superpuestas, banda de literatura como referencia sombreada |

**Idea concreta para diferenciar el artículo:** cerrar Resultados con una **tabla-resumen única** que cruce sujetos × métricas (RMSEnorm, ICC, % ciclo significativo en SPM1D) — exactamente lo que exporta `Procesar_Multisujeto_Core.m`. Es el tipo de tabla que un revisor cita cuando recomienda aceptación, porque condensa todo el rigor metodológico en una sola mirada — y que no está en el paper de conferencia.

---

## 6. Cómo anticiparse a las objeciones típicas de un revisor Q2 en este tema

| Objeción esperable | Dónde neutralizarla |
|---|---|
| "¿Por qué no usaron un sistema de captura óptica 3D tipo Vicon como gold standard?" | Métodos: declarar que STT-IWS/iSen fue la instrumentación disponible en LIBRA, y que su validez frente a sistemas optoelectrónicos — incluida validación específica en marcha con prótesis transtibial — ya está publicada (ver `docs/literatura/validacion_instrumentos_IMU.md`), por lo que no se re-deriva en este ciclo. |
| "El simulador sigue ejecutando un CSV pregrabado — ¿qué tan generalizable es esto a control en tiempo real?" | Discusión, párrafo de trabajo futuro: mencionar explícitamente que el lazo cerrado y la generación algorítmica de trayectorias quedan para trabajo futuro (ya está en `../../CLAUDE.md`) — decirlo antes de que lo pregunten quita fuerza a la objeción. |
| "¿Por qué la corrección inercial y no una máquina de ensayos universales para caracterizar rigidez?" | Ver sección 4.3 de este documento. |
| "n muy pequeño para conclusiones de generalización" | Ver sección 4.2. |
| "Pearson r es alto pero eso no prueba nada en curvas monótonas" | Adelantarlo en Métodos (ver 4.1) — convierte una objeción en un punto de rigor metodológico propio. |
| "¿El IMU de bajo costo de Alessandro es parte de este estudio o no?" | **No** (revisado 03-ago-2026) — no se menciona en este artículo. Es contenido para el segundo artículo de Alessandro. No hace falta ni una frase aclaratoria, porque simplemente no aparece en Métodos. |
| **(Nueva, 03-ago-2026, específica de JTEHM) "Esto es validación de banco de pruebas en laboratorio sin contexto clínico — ¿por qué encaja en una revista de ingeniería traslacional?"** | JTEHM declara explícitamente que prioriza TRL 5-9 y que su "poor fit" es "lab validation without clinical context" (TRL 1-4) — objeción real, no hipotética. Neutralizarla con una frase de posicionamiento TRL explícita en Introducción/Discusión (el simulador ya validado/demostrado en entorno relevante con datos de sujetos reales, no sintéticos) y con el "Clinical impact" del abstract enmarcado en reducción de tiempo/costo/riesgo de pruebas humanas durante desarrollo de prótesis — no en precisión técnica sola. Ver `docs/manuscrito/guia_autor_JTEHM.md` sección 1-ter para el detalle completo y precedentes publicados en JTEHM con el mismo patrón. |

---

## 7. Checklist de calidad Q2 / ciencia abierta

Revistas Q2 en ingeniería biomédica, sobre todo MDPI (open-access como *Bioengineering*), cada vez piden más explícitamente estos puntos — conviene resolverlos con tiempo, no en la semana 5:

- [ ] **Declaración de disponibilidad de datos y código** — ya contemplado en semana 5 ("Actualizar repositorio GitHub"), pero la declaración formal en el manuscrito debe decidirse antes: ¿todo el repo público, o solo los scripts de análisis con datos de ejemplo?
- [ ] **Declaración de aprobación ética** con número de protocolo — depende de que el comité apruebe (semana 1-3).
- [ ] **Declaración de conflicto de interés y financiamiento** — texto estándar, pero hay que tenerlo listo antes del ensamblado del manuscrito (semana 4), no improvisado al final.
- [ ] **CRediT authorship statement** (contribución de cada autor) — cada vez más pedido por revistas Q2; conviene decidir quién hizo qué mientras está fresco, no reconstruirlo en semana 5.
- [ ] **Reporte de género/edad/antropometría de los sujetos** de forma explícita en una tabla, no solo narrado — estándar en biomecánica.
- [ ] **Figura gráfica de resumen (graphical abstract)** — MDPI lo pide/recomienda activamente como parte del envío para la mayoría de sus revistas, confirmar el requisito exacto en https://www.mdpi.com/journal/bioengineering/instructions; dado lo visual del tema (simulador + curvas de marcha), es una figura que vale la pena preparar con cuidado, no como trámite de último minuto.

---

## 8. Ideas concretas para que el manuscrito destaque

1. **Una figura "hero" en la introducción o al final de métodos**: diagrama del simulador con el sensor STT-IWS/iSen montado en la plataforma, junto a un panel de pequeños múltiplos con las curvas de varios sujetos superpuestas — comunica en una imagen el argumento central actual (generalización multi-sujeto), en vez de la triangulación instrumental de la versión previa.
2. **Tabla-resumen única de Resultados** (sección 5 de este documento) — el diferenciador más citable frente al paper de conferencia.
3. **Discusión con subsección explícita de "Sources of error, decoupled"** — un párrafo por fuente de error (control del ESP32, medición instrumental, sobreestimación inercial de Fz), en vez de mezclarlas. Los revisores de instrumentación valoran mucho esta separación explícita.
4. **Explicitar el criterio de la prueba piloto de iSen y su resultado** como parte de la validación metodológica del propio proceso de selección de instrumentos — convierte una decisión operativa interna (¿usamos posición X,Y de iSen o no?) en un dato metodológico defendible.
5. Si el tiempo alcanza: un **apéndice o material suplementario con las curvas individuales por sujeto** (no solo promedios) — cada vez más valorado en revistas de instrumentación porque permite al lector evaluar variabilidad real, no solo la agregada.

---

## 9. Riesgos para la aceptación, y mitigación

| Riesgo | Mitigación |
|---|---|
| **La aprobación de ética no llega a tiempo (semana 3) — riesgo más alto que antes del pivote.** Antes, la ruta alternativa era declarar n=1 apoyado en la concordancia Alessandro-vs-STT como contenido de respaldo. Esa concordancia ya no es parte de este artículo — sin ella, si ética no llega, el artículo queda solo con la recaptura del sujeto original (iSen) + corrección de Fz, sin ningún resultado multi-sujeto que sostenga el pilar 1 de la sección 1. | No hay una mitigación de respaldo equivalente todavía. Si el riesgo de ética se materializa, este documento y el título/argumento central necesitan revisarse otra vez — no asumir que el pivote actual sobrevive automáticamente a un escenario sin sujetos nuevos. Vigilar este riesgo de cerca (ver `CLAUDE.md`, "riesgo de cronograma" ya anotado desde el 02-ago). |
| Bioengineering rechaza por alcance | POI (mejor ajuste clínico, ya con manuscrito compatible en `docs/manuscrito/plantilla_overleaf_POI.tex`) o Sensors como plan B. |
| Revisor pide sujetos adicionales o gold standard óptico 3D | Responder con la literatura de validación de iSen/STT-IWS (`docs/literatura/validacion_instrumentos_IMU.md`, incluida validación específica en marcha protésica), no prometer datos nuevos que rompan el cronograma. |
| El manuscrito termina pareciendo una versión extendida del paper de conferencia | La tarea `[S5] Revisar porcentaje de contenido nuevo` (task #38) existe justo para esto — pero conviene aplicar ese criterio también en la revisión cruzada de semana 4, no solo al final. |

---

## 10. Vínculo con el tracker de tareas

Este documento no reemplaza el plan de 5 semanas — lo informa. Las decisiones que quedan pendientes de aquí y que deberían resolverse en las próximas tareas del tracker:

- **Task #3 ([S1] Elegir revista Q2 objetivo):** ya cerrada — **Bioengineering (MDPI)**, decisión final del 03-ago-2026, segunda vuelta tras reconsiderar POI (ver sección 3 de este documento).
- **Task #13/#14 ([S2] Introducción/Métodos):** usar las justificaciones de la sección 4 de este documento como base de los párrafos metodológicos, no reescribirlas desde cero.
- **Task #27 ([S4] Resultados):** seguir el orden de la sección 5 de este documento.
- **Task #28 ([S4] Discusión):** usar la tabla de la sección 6 como checklist de objeciones a cubrir antes de dar la Discusión por cerrada.

Revista y título de trabajo ya cerrados (secciones 2 y 3) — lo que queda pendiente de este documento es que el equipo confirme los datos del piloto del IMU en la plataforma (ver `CLAUDE.md`) para dar por completamente estable el argumento central de la sección 1.
