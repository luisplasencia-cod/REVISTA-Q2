# Validación de instrumentación inercial (iSen/STT-IWS) — literatura de respaldo

> **⚠️ CORRECCIÓN 11-ago-2026 — leer antes que el resto del documento.**
>
> Las dos citas de este archivo se verificaron contra la fuente, y **una de las dos no dice lo que aquí se afirmaba**:
>
> - **Sección 2 (la que se marcaba como "la más directamente aplicable"): el sistema validado NO es iSen/STT-IWS, es un Noraxon MyoMotion.** Texto completo leído en PMC9920655. La cita sigue sirviendo, pero **solo como respaldo de la clase de instrumento** — no del instrumento de este proyecto. Por eso Métodos 5.2 dice *"inertial motion capture of this class"* y no "el sistema empleado aquí".
> - **Sección 1: CONFIRMADA sobre el PDF completo, y es mejor de lo que se pensaba.** El usuario descargó el artículo; copia local en `pdfs/Piche2022_iSen_STT-IWS_validacion_OptiTrack_Measurement198_111442.pdf`. Evalúa **exactamente** el sistema del proyecto: *"a new inertial measurement system, iSen STT-IWS sensors"*, *"(iSen, STT Systems Inc., San Sebastian, Spain)"*. Y dice algo aún más útil: *"no study have validated this specific ISEN system"* — **es LA validación del sistema, no una de varias.** Sostiene por sí sola la decisión de no re-validar el instrumento en este ciclo. Datos completos: `../manuscrito/referencias_verificadas.md` §R7.
>
> **La advertencia de la sección 1 queda levantada** — su cifra de RMSD < 10° era correcta, pero el detalle por articulación es mejor: rodilla 3.3°, tobillo 5.6°, cadera 7.3°. Ya aplicado en Métodos 5.2.
>
> Estado por entrada y entradas BibTeX listas: `../manuscrito/referencias_verificadas.md` y `../manuscrito/JTEHM_LaTex_Template/references.bib`.

**Para quién es este documento:** desde la sesión del 03-ago-2026, el artículo Q2 usa un solo sistema de captura (STT-IWS/iSen) tanto para los sujetos nuevos como para medir la salida del propio simulador — no se hace una validación cruzada de instrumentos propia dentro de este ciclo (ver `CLAUDE.md`, decisión "Cambio de foco"). Para que eso sea metodológicamente defendible ante un revisor Q2, hace falta apoyarse en literatura que ya validó el instrumento — este documento reúne esa literatura, para citar directamente en Métodos.

**Motivo del cambio (para contexto, no repetir en el artículo):** se dejó de usar Kinovea porque el equipo lo describe como impreciso y manual de operar, y porque el paper de conferencia (que reportó los datos de Kinovea del sujeto original) no estará publicado para cuando se envíe este artículo — citar/reusar ese dataset antes de que sea público es un riesgo de superposición de publicación (self-overlap), no solo una preferencia de instrumento. Por eso este artículo no debe mencionar ni citar el paper de conferencia.

---

## 1. Validación de iSen/STT-IWS contra un sistema optoelectrónico

**Hallazgo:** existe un estudio publicado que evalúa la validez del sistema STT-IWS/iSen contra un sistema optoelectrónico (OptiTrack) — 22 participantes jóvenes, caminata en cinta a distintas velocidades, ángulos de cadera/rodilla/tobillo en el plano sagital.

- **Resultado:** precisión buena a tolerable (RMSD < 10°, Lin's Concordance Correlation > 0.75), la fiabilidad decrece con la velocidad de marcha. Repetibilidad test-retest excelente (ICC > 0.75).
- **Fuente:** ["Validity and repeatability of a new inertial measurement unit system for gait analysis on kinematic parameters: Comparison with an optoelectronic system"](https://www.sciencedirect.com/science/article/abs/pii/S0263224122006716) (ScienceDirect).
- **Advertencia honesta:** el resumen de búsqueda liga este estudio a iSen/STT-IWS con bastante confianza (coincide en instrumento, protocolo y cifras con lo que se conoce del sistema), pero el título indexado no menciona la marca explícitamente — **antes de citarlo en el manuscrito, confirmar leyendo el texto completo o el abstract directo de la revista** (queda detrás de paywall en la búsqueda), no solo el resumen. No usar esta cita en Overleaf sin esa verificación final.
- **Por qué importa la caída de fiabilidad con velocidad:** si el simulador corre a velocidades altas (recordar el hallazgo de la sesión del 02-ago sobre el dial 1-30 y el factor de velocidad ~30x en los trials de `SIMULADOR/FUERZA GRF - SIM/`), este resultado es relevante para la Discusión — no asumir que la precisión de iSen es constante en todo el rango de velocidad del simulador.

## 2. Validación de IMU específicamente en marcha con prótesis transtibial

**Hallazgo — el más directamente aplicable de los dos:** hay un estudio de validez y fiabilidad de cinemática articular 3D derivada de IMU **en personas que usan prótesis transtibial**, no solo en sujetos sanos — coincide con la población de interés real de este proyecto.

- **Resultado:** concordancia buena a excelente (ICC) entre el sistema IMU y captura óptica convencional para todos los parámetros cinemáticos sagitales evaluados.
- **Fuente:** Sensors (MDPI), 2023 — ["Validity and Reliability of Inertial Measurement Unit (IMU)-Derived 3D Joint Kinematics in Persons Wearing Transtibial Prosthesis"](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9920655/), DOI 10.3390/s23031738.
- **Por qué es la cita más fuerte del artículo para este punto:** no es un sistema IMU genérico validado en sujetos sanos — es exactamente la combinación instrumento+población (marcha protésica transtibial) que necesita este artículo. Es la primera línea de defensa en Métodos ante la pregunta "¿por qué confiar en el IMU sin validarlo ustedes mismos?".

## 3. Cómo se vería esto en el artículo (ejemplo de texto de Métodos)

> Kinematic data were collected using the STT-IWS/iSen inertial measurement system. Given the well-established validity of IMU-based systems for lower-limb kinematics in both healthy gait [cita del punto 1, una vez confirmada] and, specifically, in individuals with transtibial prosthesis [Sensors 2023, DOI 10.3390/s23031738], no in-house cross-instrument validation was performed in this cycle; instrument validity is supported by the cited literature rather than re-derived.

## 4. Qué NO resuelve esta literatura

- No reemplaza la calibración del offset vertical del simulador (`CODIGOS/CALIBRACION/`) ni la corrección inercial de Fz — son problemas distintos (offset/inercia del simulador, no precisión del sensor de captura).
- No justifica saltarse el criterio de la prueba piloto de iSen (`docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`, sección 0) para la posición X,Y — esa prueba sigue siendo necesaria porque evalúa una variable (posición) distinta de la que valida la literatura de arriba (ángulo articular).
- No es una validación del ángulo de **inclinación absoluta de un objeto rígido** (la plataforma del simulador) — la literatura de arriba valida ángulos **articulares** (entre dos segmentos calibrados con T-pose). Para la plataforma, lo que se necesita es la orientación cruda del sensor respecto a la gravedad (pitch/roll), no el protocolo de ángulo articular — ver la nota técnica en `CLAUDE.md` sobre esto. Es la misma distinción que ya identificó el propio protocolo de piloto del proyecto.

## 5. Fuentes consultadas

- [Validity and repeatability of a new inertial measurement unit system for gait analysis on kinematic parameters: Comparison with an optoelectronic system (ScienceDirect)](https://www.sciencedirect.com/science/article/abs/pii/S0263224122006716)
- [Validity and Reliability of Inertial Measurement Unit (IMU)-Derived 3D Joint Kinematics in Persons Wearing Transtibial Prosthesis (PMC9920655 / Sensors 2023)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9920655/)
- [Validation of a new inertial measurement unit system based on different dynamic movements for future in-field applications (ResearchGate)](https://www.researchgate.net/publication/337224220_Validation_of_a_new_inertial_measurement_unit_system_based_on_different_dynamic_movements_for_future_in-field_applications) — mismo grupo de sistemas IMU, revisar si aplica como cita secundaria.
