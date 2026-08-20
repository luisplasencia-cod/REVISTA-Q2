# Referencias verificadas para el manuscrito JTEHM

> 🟡 **Relevancia mixta tras el pivote — 19-ago-2026.** Estas 10 citas se verificaron para el argumento de fidelidad de seguimiento multi-sujeto, ya superado (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20). Algunas siguen siendo útiles de forma directa (Sudeesh 2024 sobre arquitectura 3-DOF, Etoundi 2022 sobre bancos robóticos — ambas hablan del banco en sí, no del enfoque de captura). Otras (Piche 2022/iSen, Rattanakoch/Noraxon) pierden relevancia porque dependían de la captura con iSen, ahora abandonada. El estándar de verificación (nunca fijar una cita sin comprobarla contra la fuente) sigue aplicando igual a cualquier cita nueva del enfoque actual — ver también `planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` §4.5, con el mismo estándar ya aplicado a los candidatos de algoritmo/base de datos nuevos.

**Creado:** 05-ago-2026 · **Actualizado:** 15-ago-2026
**Para qué sirve:** `metodos_introduccion_borrador.md` y `JTEHM_LaTex_Template/manuscrito_JTEHM.tex` arrastraban claves `\cite{PENDIENTE_*}` con citas identificadas por búsqueda pero **sin verificar** — marcadas dos veces en la documentación como "no usar en un envío real sin confirmar". Este archivo cierra esa deuda: lo verificado va con entrada BibTeX lista para pegar; lo que sigue incompleto está marcado con exactamente qué falta.

**Estado al 15-ago-2026: las 10 de 10 entradas están verificadas y completas.** Solo falta leer R4 texto completo para confirmar la frase de novedad (el resumen ya se leyó y se sostiene).

**Cambio de esta ronda (15-ago-2026):**

1. **ISO5725 — decisión cerrada (P-14):** se cita la edición **2023**, no la 1994. La 1994 figura como retirada en iso.org; la 2023 es una revisión técnica del mismo marco de trueness/precision (mismo tema, algunas definiciones retiradas, encuadre nuevo sobre condiciones/recursos para estudios de precisión), no un cambio de alcance. `references.bib` ya actualizado.

**Cambios de esta ronda (13-ago-2026) — las 4 de métodos estadísticos, ya no `[REVISAR]`:**

1. **KooLi2016 (ICC) verificada** — título, revista, volumen, páginas y DOI coinciden exactamente con lo ya anotado (búsqueda web, PubMed incluido).
2. **NicholsHolmes2002 (permutación SPM) verificada** — coincide exactamente (Wiley Online Library).
3. **Pataky2015 (SPM biomecánica) verificada** — coincide exactamente (PubMed, ScienceDirect).
4. **ISO5725 verificada, con una advertencia nueva:** la Parte 1 es correcta (principios generales, trueness/precision), pero **la edición 1994 figura como retirada en iso.org** — la vigente es ISO 5725-1:2023. No se cambió de oficio porque la 1994 es la que de hecho se usó para tomar el vocabulario y sigue siendo de uso común en biomecánica, pero era una decisión pendiente: **¿se cita 1994 (la usada) o 2023 (la vigente)?** ✅ Cerrada 15-ago, se cita 2023 — ver arriba.

**Cambios de esta ronda (11-ago-2026):**

1. **R4 completada** — autores, volumen, artículo y DOI, verificados contra dos fuentes independientes.
2. **R5 completada** — autores, congreso, páginas y DOI.
3. **R3 completada, y se resolvió su advertencia abierta** — el sistema validado es **Noraxon MyoMotion, no STT-IWS/iSen**. Obliga a redactar 5.2 de una forma concreta (ya corregida).
4. **R6 descartada por error de categoría** — no es del tema que se creía. Ver abajo; es el hallazgo más importante de esta ronda.
5. **Claves de cita renombradas** a Autor+Año, como el resto. Si hay una versión previa pegada en Overleaf, hay que resubir también el `.bib`.

| Clave vieja | Clave nueva |
|---|---|
| `CompactGaitSimulator2024` | `Sudeesh2024CompactGaitSimulator` |
| `ConceptualDesignSimulator2015` | `Marinelli2015ConceptualDesign` |
| `IMU2023TranstibialValidity` | `Rattanakoch2023TranstibialIMU` |

---

## ⚠️ El hallazgo de esta ronda: R6 no sirve para este artículo

### R6 — Neelen et al. 2026, *State of the art of lower limb prosthesis simulators* — **DESCARTADA**

El 05-ago se registró como "la nueva más valiosa encontrada": una revisión de 73 estudios, de 2026, acceso abierto, que iba a condensar el primer párrafo de la Introducción y sustituir a R2. **Al leer el texto completo (PMC12964165) resulta ser de otro tema.**

En esa revisión, *prosthesis simulator* **no significa banco robótico de pruebas**. Significa un dispositivo que **viste una persona sana** para imitar el uso de una prótesis. Textual, de la introducción:

> "Prosthesis simulators, also called able-bodied adapters, bypass adapters, or bypass orthoses, are designed to mimic prosthesis use with anatomically intact individuals."

Y del resumen:

> "Prosthesis simulators, designed for mimicking prosthesis use with able-bodied individuals, offer an alternative to conducting controlled experiments."

Los 18 estudios "transtibiales" que tanto encajaban sobre el papel son **botas y ortesis que inmovilizan el tobillo a ~90° en sujetos sanos**, no plataformas motorizadas. Todos sus estudios incluyen participantes humanos vistiendo el dispositivo — el criterio de inclusión es literalmente "evaluating prosthetic components with an able-bodied individual".

**Consecuencias, en orden de importancia:**

1. **No se cita.** Presentarla como "la revisión más reciente del campo" ante un revisor de JTEHM sería un error de categoría detectable en un minuto, y de los que cuestan credibilidad en todo lo demás.
2. **El "vacío documentado por terceros" no existe todavía.** Lo que se creía respaldo externo de la tesis central (falta de estandarización, ausencia de evaluaciones para transtibiales) es un vacío de *otra* literatura. La frase de novedad de la Introducción vuelve a sostenerse por cuenta propia.
3. **R2 se queda sin reemplazo.** El plan era sustituir el resumen de congreso de una página por esta revisión. Sigue pendiente y ahora sin candidato identificado.
4. **Cae la recomendación D de `ESTADO_Y_RUMBO.md` §6** ("condensar la Introducción con la revisión de 2026", marcada *hacer ya, costo cero*). Ya corregida allí.

La entrada BibTeX queda **comentada** dentro de `references.bib`, no borrada, para que una sesión futura no la vuelva a "descubrir" como hallazgo nuevo.

**Lo que sí queda de la búsqueda:** no se localizó una revisión sistemática equivalente para bancos robóticos de marcha. Si no existe, es un dato a favor del artículo — pero **afirmarlo en el manuscrito requiere una búsqueda deliberada, no la ausencia de resultados en dos consultas.**

---

## ✅ VERIFICADAS — listas para `references.bib`

### R1 — Banco de pruebas robótico para articulaciones protésicas

```bibtex
@article{Etoundi2022RoboticTestRig,
  author  = {Etoundi, Appolinaire C. and Dobner, Alexander and Agrawal, Subham
             and Semasinghe, Chathura L. and Georgilas, Ioannis and Jafari, Aghil},
  title   = {A Robotic Test Rig for Performance Assessment of Prosthetic Joints},
  journal = {Frontiers in Robotics and AI},
  volume  = {8},
  year    = {2022},
  doi     = {10.3389/frobt.2021.613579}
}
```

Verificado en PMC8936071 (05-ago-2026).

**Hallazgo aprovechable:** el banco usa un husillo motorizado para simular la acción cuádriceps-isquiotibiales, y **fue diseñado a partir del análisis de marcha de UN solo participante amputado**. Eso es exactamente la suposición que este artículo cuestiona — sirve como evidencia concreta de que la programación desde un sujeto único es la práctica habitual del campo, no un hombre de paja. Vale la pena citarlo explícitamente en esa frase, no solo en la lista general de simuladores.

**Nota 11-ago:** al caer R6, esta cita pasa a ser **el respaldo más fuerte que hay** para la premisa del artículo. Conviene apoyarse en ella de forma explícita.

### R2 — Simulador robótico para herramienta de alineamiento

```bibtex
@article{DeRaeve2014AlignmentTool,
  author  = {De Raeve, Eveline and Saey, Tom and Muraru, Luiza and Peeraer, Louis},
  title   = {The use of a robotic gait simulator for the development of an
             alignment tool for lower limb prostheses},
  journal = {Journal of Foot and Ankle Research},
  volume  = {7},
  number  = {Suppl 1},
  pages   = {A15},
  year    = {2014},
  doi     = {10.1186/1757-1146-7-S1-A15}
}
```

Verificado en PMC4101690 (05-ago-2026).

**⚠️ Advertencia de peso, todavía abierta:** `7(Suppl 1):A15` significa que es un **resumen de congreso publicado en un suplemento**, de una sola página — no un artículo completo revisado por pares. Citarlo en la Introducción de una revista IEEE es una cita débil, y un revisor atento lo nota.

**Actualizado 11-ago:** el reemplazo previsto (R6) no aplica. Opciones que quedan: buscar la publicación completa del mismo grupo (De Raeve / Muraru / Peeraer), o eliminar esa frase de la Introducción — que además ayuda con el límite de 8 páginas.

**Resuelto 13-ago-2026 (`DISCUSION_Q2.md` P-11):** búsqueda exhaustiva (múltiples consultas independientes, todas devolviendo el mismo resultado) confirma que el grupo De Raeve/Muraru/Peeraer **nunca publicó el artículo completo** de este sistema — solo existe el resumen de congreso de una página. Tampoco se encontró ningún otro grupo con un artículo completo sobre una plataforma robótica dedicada específicamente a *alineamiento* protésico (se revisaron candidatos como el sistema IMU de Han et al. 2024, *Sensors* — usa un robot solo como banco de validación del sensor, no como plataforma de alineamiento — y quedó descartado por no encajar con la afirmación).

**Decisión:** no se inventa ni se fuerza un reemplazo tangencial. Se mantiene R2 (describe correctamente lo que es) pero se cita **junto a Etoundi2022RoboticTestRig** (ya citado antes en el mismo párrafo, artículo completo revisado por pares) en la cláusula del `.tex` — Etoundi refuerza la mitad de "joint performance assessment" de la afirmación con una fuente fuerte; R2 sigue siendo la única fuente real para la mitad de "alignment". Aplicado en `manuscrito_JTEHM.tex` e indicado con comentario `[RESUELTO 13-ago-2026]` en ambos archivos.

### R3 — Validación de IMU en usuarios de prótesis transtibial

```bibtex
@article{Rattanakoch2023TranstibialIMU,
  author  = {Rattanakoch, Jutima and Samala, Manunchaya and
             Limroongreungrat, Weerawat and Guerra, Gary and
             Tharawadeepimuk, Kittichai and Nanbancha, Ampika and
             Niamsang, Wisavaporn and Kerdsomnuek, Pichitpol and
             Suwanmana, Sarit},
  title   = {Validity and Reliability of Inertial Measurement Unit
             (IMU)-Derived 3D Joint Kinematics in Persons Wearing
             Transtibial Prosthesis},
  journal = {Sensors},
  volume  = {23},
  number  = {3},
  pages   = {1738},
  year    = {2023},
  doi     = {10.3390/s23031738}
}
```

Texto completo verificado en PMC9920655 (PMID 36772783), autores vía Crossref.

**⚠️ ADVERTENCIA RESUELTA — y el resultado obliga a redactar con cuidado.** El 05-ago quedó abierta la duda de qué sistema IMU se validó. **No es STT-IWS/iSen.** Textual, de Métodos:

> "The IMU system was the Noraxon MyoMotion Research Pro system (Noraxon USA, Scottsdale, AZ) with a sampling rate of 200 Hz. Seven IMUs were attached using Velcro straps at the feet, legs, thighs, and pelvis."

Referencia óptica: 8 cámaras Raptor (Motion Analysis Corporation), también a 200 Hz. 30 usuarios de prótesis transtibial.

**Cómo se redacta, entonces:** "sistemas inerciales de esta clase" / *"inertial motion capture of this class"*. **Nunca** "el sistema empleado en este estudio fue validado" — sería falso y trivialmente verificable. Ya corregido en `manuscrito_JTEHM.tex` (Introducción y 5.2).

**Dato a vigilar, no estaba antes:** el acuerdo **no es uniformemente excelente**. ICC de flexo-extensión de rodilla 0.99 (lado amputado) / 0.98 (sano) y de cadera 0.90 / 0.84 — pero **dorsiflexión-plantarflexión de tobillo baja a 0.60 en el lado amputado**, solo moderado. Si la cita se usa como respaldo general de validez, un revisor puede señalar ese 0.60. La redacción actual acota la afirmación a rodilla y cadera y **no menciona tobillo**, porque este artículo no mide ángulo de tobillo — es defendible, pero hay que saber sostenerlo si preguntan.

### R4 — Simulador de marcha compacto y de bajo costo

```bibtex
@article{Sudeesh2024CompactGaitSimulator,
  author  = {Sudeesh, S. and Shunmugam, M. S. and Sujatha, S.},
  title   = {A compact and cost-effective gait simulator to advance prosthesis
             development with reduced reliance on human subject testing:
             Development, validation and application},
  journal = {Medical Engineering \& Physics},
  volume  = {134},
  pages   = {104254},
  year    = {2024},
  doi     = {10.1016/j.medengphy.2024.104254}
}
```

Verificado contra dos fuentes independientes (Europe PMC y PubMed, PMID 39672657). El PII que se tenía anotado, `S1350453324001553`, corresponde a `S1350-4533(24)00155-3` y **es consistente con este DOI** — no había discrepancia, solo faltaba el dato.

**Sigue siendo la referencia más crítica del manuscrito, por dos motivos distintos:**

1. **Respalda la arquitectura del simulador de este proyecto.** Textual del resumen: *"sagittal plane movements, namely flexion-extension, vertical translation, and horizontal translation, are sufficient to test prosthetic knees"*. Eso es, exactamente, la arquitectura de 3 DOF de este simulador, publicada de forma independiente por otro grupo. **Ya incorporada en 5.1** del `.tex` — es la recomendación C de `ESTADO_Y_RUMBO.md` §6, ahora cerrada con una cita verificada.
2. **Es el competidor más cercano.** El resumen verificado dice que validó con *hardware-in-loop simulations* y simulación numérica de la fase de balanceo a partir de datos de marcha 3D, sobre una rodilla protésica (IITM polycentric knee). **No reporta validación multi-sujeto de fidelidad de reproducción** — o sea, la frase de novedad de la Introducción se sostiene **a nivel de resumen**.

**Lo que todavía conviene hacer:** leer el texto completo antes del envío. El resumen no dice de cuántos sujetos salieron los "3D gait data", y esa es justamente la pregunta que decide si la frase de novedad es exacta o hay que matizarla. Accesible por la suscripción ScienceDirect de la universidad. Ya no es urgente para redactar — pero sí antes de enviar.

*(Es también la compuerta G1 del tablero de §13 del análisis de escalamiento a Q1 — una sola lectura resuelve un pendiente de ambos artículos.)*

### R5 — Diseño conceptual de un simulador de marcha

```bibtex
@inproceedings{Marinelli2015ConceptualDesign,
  author    = {Marinelli, Cristiano and Giberti, Hermes and Resta, Ferruccio},
  title     = {Conceptual design of a gait simulator for testing lower-limb
               active prostheses},
  booktitle = {2015 16th International Conference on Research and Education
               in Mechatronics (REM)},
  pages     = {314--320},
  year      = {2015},
  doi       = {10.1109/REM.2015.7380413}
}
```

Verificado vía Crossref (11-ago-2026). Confirmado como `proceedings-article`, no artículo de revista — la suposición previa era incorrecta, y el año 2015 sí era correcto.

**Dato de contexto:** el congreso es REM (Research and Education in Mechatronics), no un congreso de EMBS ni de biomecánica. Es una cita válida, pero de peso medio. Si en algún momento hay que recortar la Introducción para las 8 páginas, esta y R2 son las dos primeras candidatas.

---

## ✅ R7 — la cita de instrumentación más importante del artículo

### R7 — Validación de iSen/STT-IWS contra OptiTrack — **VERIFICADA SOBRE EL PDF COMPLETO**

```bibtex
@article{Piche2022iSenValidity,
  author  = {Piche, Elodie and Guilbot, Marine and Chorin, Fr\'ed\'eric and
             Gu\'erin, Olivier and Zory, Rapha\"el and Gerus, Pauline},
  title   = {Validity and repeatability of a new inertial measurement unit
             system for gait analysis on kinematic parameters: Comparison
             with an optoelectronic system},
  journal = {Measurement},
  volume  = {198},
  pages   = {111442},
  year    = {2022},
  doi     = {10.1016/j.measurement.2022.111442}
}
```

**Verificada leyendo el PDF completo** (11-ago-2026; el usuario lo descargó). Copia local: `../literatura/pdfs/Piche2022_iSen_STT-IWS_validacion_OptiTrack_Measurement198_111442.pdf`.

**Confirmado: evalúa exactamente el sistema de este proyecto.** Textual del resumen: *"a new inertial measurement system, iSen STT-IWS sensors, with reference to the optoelectronic motion capture system OptiTrack"*; de la introducción: *"(iSen, STT Systems Inc., San Sebastian, Spain)"*.

**Y dice algo aún mejor para Métodos 5.2:**

> "Previous studies have previously validated similar systems [4,7,8] while no study have validated this specific ISEN system and quantify the possible bias of IMUs and kinematics errors."

Es decir: **es LA validación del sistema, no una de varias.** Sostiene por sí sola la decisión de no re-validar el instrumento en este ciclo.

**Cifras utilizables** (22 sanos jóvenes, cinta, 0.8 / 1.2 / 1.6 m/s; 11 IMU a 100 Hz vs. 9 cámaras OptiTrack; ICC(2,1) test-retest a 2 semanas):

| Métrica | Rodilla | Cadera | Tobillo |
|---|---|---|---|
| RMSD forma de onda completa | **3.3°** | 7.3° | 5.6° |
| RMSD por velocidad (0.8/1.2/1.6) | 3.3 / 3.9 / 5.4° | — | — |
| LCC | 0.96 / 0.96 / 0.88 | >0.75 | **0.72 / 0.60 / 0.56** |
| ICC test-retest | **0.93** | 0.89 | 0.80 |

**Dato extra, muy útil y que no se esperaba — la deriva es pequeña:** comparando los primeros y los últimos 30 s de 3 minutos de captura, el error relativo máximo fue **1.1°** y el RMSD entre ciclos medios **< 2°**. Es evidencia directa contra la objeción clásica de deriva de IMU, y refuerza lo que ya decía `../literatura/postprocesado_datos_crudos_IMU.md`.

**⚠️ Tres caveats que hay que saber sostener.** No invalidan la cita, pero un revisor puede levantarlos:

1. **Su propia hipótesis no se cumplió.** Declararon esperar error < 3°; el RMSD quedó entre 3.3 y 8.4°. El resumen lo llama *"good to tolerable"*. Si se cita como "validado", conviene usar sus palabras, no una versión mejorada.
2. **Población: 22 sanos jóvenes (media 26 años), no usuarios de prótesis** — pese a que su propio resumen concluye utilidad *"on older adults"*, que es un salto de ellos, no un dato. **Aquí está la razón de que hagan falta las dos citas:** R7 cubre el **instrumento**, R3 (Rattanakoch) cubre la **población** transtibial pero con otro instrumento. Ninguna cubre las dos cosas. Presentarlas como complementarias, explícitamente, es lo honesto y además se anticipa a la objeción.
3. **La fiabilidad decrece al aumentar la velocidad** (LCC 0.88 → 0.85; sesgo de tobillo −4.15° → −8.35° → −11.73°). Rango validado: **0.8–1.6 m/s**.

**Sobre el caveat 3, un matiz que juega a favor y conviene tener claro:** el simulador opera **~30x más LENTO** que la marcha humana (28.5 s de apoyo frente a 0.9459 s reales, ver `../literatura/literatura_GRF_protesica.md`), no más rápido. O sea, queda **por debajo** del rango validado — el extremo **favorable** a la exactitud según la tendencia que reporta este estudio. Sigue siendo una extrapolación y hay que declararla, pero no es la amenaza que parecía.

> ⚠️ **Corregir al citar internamente:** varios documentos del proyecto dicen "~30x la marcha humana" sin signo, lo que se lee como "más rápido". Es **más lento**. Ya aclarado en `../../CLAUDE.md`.

---

## Resumen de acciones

| # | Acción | Dónde | Estado |
|---|---|---|---|
| 1 | Obtener autores/volumen/DOI de R4 | Europe PMC + PubMed | ✅ **Hecho 11-ago** |
| 2 | Obtener autores de R5 y confirmar tipo | Crossref | ✅ **Hecho 11-ago** |
| 3 | Obtener autores de R3 y confirmar **qué sistema IMU** validó | PMC9920655 | ✅ **Hecho 11-ago** — es Noraxon, no iSen; 5.2 ya corregido |
| 4 | Leer R6 y decidir si condensa la Introducción | PMC12964165 | ✅ **Hecho 11-ago** — descartada, otro tema |
| 5 | **Confirmar que R7 evalúa iSen/STT-IWS** (+ su volumen) | PDF completo | ✅ **Hecho 11-ago** — confirmado; es LA validación del sistema |
| 5-bis | **Leer R4 texto completo** y confirmar la frase de novedad | ScienceDirect vía universidad | ⏳ **Intentado 13-ago, sigue pendiente** — ScienceDirect devuelve 403 sin acceso institucional; requiere que el usuario lo abra con su acceso PUCP y comparta el texto (o confirme la pregunta puntual: ¿el paper reporta validación con múltiples sujetos, o solo con el IPK y un sujeto/trayectoria de referencia?) |
| 6 | Buscar reemplazo de R2, o eliminar la frase | — | ✅ **Hecho 13-ago** — sin reemplazo de artículo completo disponible en el campo; se citó junto a Etoundi2022 en vez de reemplazar |
| 7 | Verificar las 4 referencias de métodos estadísticos, todavía `[REVISAR]` | — | ✅ **Hecho 13-ago** — las 4 coinciden exactamente. Decisión de edición ISO 5725 cerrada 15-ago: se cita 2023, no 1994. |
| 8 | Búsqueda deliberada de revisiones de bancos robóticos de marcha | — | ⏳ Pendiente, decide si el vacío se puede afirmar |

**Nota de método, reforzada por esta ronda:** ninguna cita debe fijarse con los datos "por búsqueda". En dos rondas de verificación, **6 de 6 referencias identificadas por búsqueda tenían algún error**: un título equivocado, un resumen de suplemento confundido con artículo, un paper de congreso confundido con artículo de revista, un sistema IMU distinto del que se suponía, un DOI inventado por un buscador a partir del patrón de la URL, y una revisión entera que era de otro tema. La verificación no es un trámite.
