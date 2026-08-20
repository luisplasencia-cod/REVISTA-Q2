# Normas ISO relevantes para la validación del artículo Q2

> 🟢 **Sigue vigente tras el pivote — 19-ago-2026.** El vocabulario de ISO 5725 y el marco estadístico (ICC, Bland-Altman, SPM) no dependen de qué se compare — siguen aplicando para validar la trayectoria generada contra sujetos/bases de datos externas (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20). ISO 10328 (referencia de magnitud de carga) queda con la misma relevancia incierta que el resto de la literatura de Fz, ver `literatura_GRF_protesica.md`.

**Para quién es este documento:** evalúa, con búsqueda verificada (no de memoria), qué normas ISO pueden reforzar legítimamente la sección de Métodos del artículo — y deja explícito qué NO aplica, para no sobrevender una cita ante un revisor que sí conozca la norma.

**Conclusión corta:** no existe una norma ISO dedicada a "validar un sistema de captura de movimiento" o "validar un simulador de marcha" — ese hueco lo llenan ICC, Bland-Altman y SPM (Nichols & Holmes 2002; Koo & Li 2016; Bland & Altman 1999), que el proyecto ya implementa (ver `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md` y `CODIGOS/VALIDACIONES/GUIA_INTERPRETACION.md`). Lo que sí aporta la ISO es **vocabulario formal** (ISO 5725) y **una referencia de magnitud de carga** (ISO 10328) — ninguna reemplaza el diseño estadístico ya elegido.

---

## 1. ISO 5725 — Accuracy (trueness and precision) of measurement methods and results

**Edición citada en este proyecto: ISO 5725-1:2023** (decisión cerrada 15-ago-2026, `DISCUSION_Q2.md` P-14). La 1994 figura como retirada en iso.org; la 2023 cubre el mismo marco de trueness/precision (revisión técnica, no cambio de alcance).

**Qué es:** serie de normas vigente (parte 1: 2023, parte 2: 2019, entre otras) que define el marco general de exactitud de un método de medición como la combinación de dos componentes distintos:
- **Trueness** (veracidad): cercanía entre el promedio de muchas mediciones y el valor de referencia aceptado — se expresa como sesgo (bias).
- **Precision** (precisión): cercanía entre mediciones independientes repetidas entre sí — se expresa como desviación estándar (repetibilidad/reproducibilidad).

**Precedente en biomecánica:** un estudio de captura óptica de movimiento (evaluación de laboratorio, análisis de nivel inferior del cuerpo en marcha) reportó explícitamente trueness y uncertainty en mm siguiendo este marco (ScienceDirect, "Analysis of accuracy in optical motion capture — A protocol for laboratory setup evaluation"), confirmando que ISO 5725 se usa de forma legítima en el campo, no es un préstamo forzado de metrología industrial.

**Uso concreto en este proyecto:** ISO 5725 no reemplaza ninguna métrica ya elegida, **las reencuadra con vocabulario formal**:

| Concepto del proyecto | Rol en ISO 5725 |
|---|---|
| RMSEnorm, CMC (`Calcular_Metricas_Curva.m`) | Trueness — qué tan cerca está el simulador del valor de referencia |
| ICC(3,1), CV entre sujetos (`MULTISUJETO/`) | Precision — qué tan repetible es la medición en sí misma |
| Bland-Altman bias / límites de acuerdo | Trueness (bias) + Precision (ancho de los límites) combinados en un solo análisis |

Citar ISO 5725 en Métodos, al lado de las métricas ya usadas, es lo que le da a un revisor Q2 la señal de que el diseño de validación sigue un marco de exactitud reconocido, no una colección ad hoc de números.

## 2. ISO 10328 — Prosthetics: Structural testing of lower-limb prostheses — Requirements and test methods

**Qué es:** norma vigente (edición 2016) que especifica ensayos estáticos y cíclicos de **resistencia estructural** sobre el componente físico de la prótesis (transtibial, transfemoral, etc.), aplicando cargas compuestas que replican los picos de carga de la fase de apoyo de la marcha. Determina resistencia a fatiga, de prueba y última del dispositivo.

**Qué NO es — advertencia explícita:** ISO 10328 evalúa si la **estructura de la prótesis** aguanta cargas repetidas sin fallar mecánicamente. No es una norma de validación de sistemas de captura de movimiento, no valida simuladores de marcha, y su propio texto advierte que no debe usarse como guía para prescribir una prótesis a un paciente individual. **No corresponde citarla como si validara la fidelidad cinemática/cinética del simulador** — sería una cita fuera de contexto que un revisor familiarizado con la norma señalaría de inmediato.

**Uso legítimo y acotado:** los niveles de carga estandarizados de ISO 10328 (definidos como fracciones del peso corporal, derivados de picos reales de fase de apoyo) son una referencia de magnitud útil para **contextualizar** el benchmark de Fz — complementa, no reemplaza, `docs/literatura/literatura_GRF_protesica.md` (que ya corrige el supuesto de 100-120%BW como techo típico). Si se cita, debe ser explícitamente como "nivel de carga de referencia de la industria de ensayo estructural", no como estándar de validación del simulador.

## 3. Convenciones ISB (Wu et al., 2002) — no es ISO, pero es el estándar de facto del campo

**Qué es:** recomendaciones de la International Society of Biomechanics para definir sistemas de coordenadas articulares y convenciones de signo en cinemática de marcha ("ISB recommendation on definitions of joint coordinate systems").

**Por qué se incluye aquí aunque no sea ISO:** el proyecto ya sigue una convención de signo específica (atan2, positivo por encima de la horizontal — ver `CLAUDE.md`, sección "Cómo ayudar en esta carpeta") en **todos** los cálculos de ángulo, nuevos y existentes, precisamente para que sean comparables entre sí. Hoy esa convención no tiene ninguna cita formal en ningún `.md` del proyecto — Wu et al. (2002) es la referencia estándar del campo para justificar por qué se define el signo de esa manera, y cerrar ese hueco de citación es tan importante como las citas ISO.

---

## 4. Cómo se vería esto en el artículo (ejemplo)

**Métodos — marco de exactitud:**

> Agreement between simulator output and reference gait data was assessed within the trueness/precision framework of ISO 5725, using normalized RMSE and the Coefficient of Multiple Correlation as trueness indicators, and ICC(3,1) [Koo & Li, 2016] as the precision (repeatability) indicator.

**Métodos — convención de ángulos:**

> Joint/segment angles were computed following ISB sign conventions [Wu et al., 2002], with positive values above the horizontal plane, consistent across all instruments and sessions.

**Discusión — benchmark de carga (si se usa ISO 10328):**

> The observed vertical GRF overestimation was contextualized against both prosthetic gait literature (see `literatura_GRF_protesica.md`) and the standardized loading levels defined for structural testing of lower-limb prostheses [ISO 10328:2016], acknowledging that the latter reflects structural test loads rather than a kinematic/kinetic validation benchmark.

---

## 5. Resumen — qué citar y qué no

| Norma/convención | ¿Aplica a este artículo? | Cómo |
|---|---|---|
| ISO 5725 (trueness & precision) | Sí | Vocabulario formal para Métodos, junto a RMSEnorm/CMC/ICC ya implementados |
| ISO 10328 (structural testing) | Solo como referencia de magnitud de carga, con salvedad explícita | Discusión, benchmark de Fz — **no** como validación del simulador |
| ISB / Wu et al. 2002 | Sí (no es ISO) | Justifica formalmente la convención atan2 ya usada en todo el proyecto |
| Norma ISO de "validación de mocap/simuladores de marcha" | No existe | El campo usa ICC + Bland-Altman + SPM — ya implementados, no hace falta ISO adicional |

## 6. Fuentes consultadas

- [ISO 5725-1:2023 — General principles and definitions](https://www.iso.org/standard/69418.html)
- [ISO 5725-2:2019 — Basic method for repeatability and reproducibility](https://www.iso.org/standard/69419.html)
- [Analysis of accuracy in optical motion capture — A protocol for laboratory setup evaluation (ScienceDirect)](https://www.sciencedirect.com/science/article/abs/pii/S0021929016305681)
- [ISO 10328:2016 — Prosthetics, Structural testing of lower-limb prostheses](https://www.iso.org/standard/70205.html)
- [ISO 10328:2016(en), texto completo de scope y limitaciones](https://www.iso.org/obp/ui/#iso:std:iso:10328:ed-2:v1:en)
