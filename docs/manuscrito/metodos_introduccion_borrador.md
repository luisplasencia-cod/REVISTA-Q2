# Borrador — Introducción (gancho) y Métodos 5.1-5.2

**Estado: borrador de trabajo, no final.** Prosa lista para pasar a Overleaf/plantilla de POI y ajustar formato de autores. Los tramos marcados `[PENDIENTE: ...]` dependen de datos o decisiones que todavía no existen — no completar con números inventados.

Fuente: `../CLAUDE.md`, `../planificacion/propuesta_articulo_Q2.md`, `../planificacion/plan_trabajo_5_semanas_articulo_Q2.md`, `../literatura/literatura_GRF_protesica.md`.

---

## Introducción — párrafo de cierre (transición a objetivos, no la introducción completa)

Prior work from this group demonstrated the mechanical feasibility of a 3-degree-of-freedom (horizontal, vertical, sagittal) gait simulator for transtibial prosthesis testing, validating that the platform can reproduce a single pre-recorded reference trajectory with acceptable fidelity [ref. paper de conferencia IBITeC 2026]. That validation, however, only established that the simulator can play back the gait pattern it was explicitly programmed with — it did not test whether the platform generalizes to gait patterns from subjects who did not contribute to its programming, nor did it decouple the sources of measurement error from the sources of mechanical/control error. The present study addresses both gaps: we assess whether the simulator reproduces gait kinematics captured from subjects independent of its calibration trajectory, using two independent measurement instruments whose cross-concordance is established rather than assumed, and we quantify — rather than narrate — the sources of vertical force overestimation inherent to a motor-driven platform.

## 5.1 System description (condensed)

The gait simulator, described in detail in [ref. paper de conferencia], reproduces a pre-recorded gait trajectory across three independent degrees of freedom — horizontal displacement, vertical displacement, and sagittal rotation — each driven by its own motor and transmission (chain-and-sprocket or direct drive, depending on the axis). Trajectories are stored as CSV files, uploaded via a Raspberry Pi, and executed open-loop by an ESP32 microcontroller; the present study does not modify this operating principle — no closed-loop control or algorithmic trajectory generation was introduced in this cycle (see Discussion, Future Work). [PENDIENTE: confirmar si se agrega una frase sobre calibración del actuador vertical, una vez resuelta la prueba de offset — no adelantar mientras siga bloqueada por la integración Raspberry Pi–ESP32.]

## 5.2 Instrumentation

Three motion-capture/measurement instruments were used across the validation protocol:

- **2D video-based tracking (Kinovea).** Used in the original reference-subject capture and retained as a fallback instrument throughout this cycle until cross-instrument concordance with the inertial system (below) is established (see 5.4). Segment angles are computed as `atan2` of marker coordinates, positive above horizontal, negative below — the same convention used throughout this project and preserved here for comparability with prior data.
- **Inertial motion capture (STT-IWS/iSen).** Used for (i) capturing new subjects, (ii) re-capturing the original reference subject for cross-instrument validation against Kinovea, and (iii) validating a low-cost IMU (below) by co-mounting it with the STT-IWS on the simulator platform. [PENDIENTE: reemplazar por resultado real del criterio de la prueba piloto — posición X,Y utilizable o solo ángulo — antes de fijar esta redacción.]
- **Low-cost IMU (developed in parallel by a member of the group).** Evaluated here strictly as a cross-validation instrument against the STT-IWS, not as a primary outcome measure of this study — its own load-cell/force-sensing component is out of scope for this article and reserved for a subsequent publication.
- **Force platform (AMTI).** Used to record the vertical ground reaction force (Fz) exerted by the simulator against a fixed load cell, sampled at 1000 Hz. [PENDIENTE: confirmar si el articulo reporta las 6 columnas completas del export (Fx,Fy,Fz,Mx,My,Mz) o solo Fz — por ahora solo Fz está validado en el pipeline existente.]

### Vertical force overestimation: a three-stage, decoupled explanation

Because the moving assembly is not a single rigid body — a stationary electronic control board is mounted on one side of the frame, while three independently actuated axes (horizontal, vertical, sagittal) each carry their own kinematic chain on the other — vertical force overestimation is decomposed into three independent, sequentially-corrected sources rather than a single inertial term:

1. A fixed **vertical datum offset**, calibrated once against an independent static load reference (not against any subject trajectory reported in Results) and held constant across all trials.
2. **Command-to-encoder tracking fidelity** per axis, isolating mechanical/control error (chain or sprocket backlash, insufficient motor holding torque under reaction load) from the remaining sources.
3. An **axis-wise inertial correction**, using the mass that actually accelerates with each motor according to the real mounting order of the kinematic chain — not the total assembly mass — benchmarked against published prosthetic gait GRF data (see `../literatura/literatura_GRF_protesica.md`). [PENDIENTE: fuente de `m_eje` sin resolver — el equipo decidió no pesar el ensamblaje; falta decidir entre estimación por CAD o renunciar a este término y declararlo limitación.]

This decomposition is the central methodological contribution distinguishing this manuscript from the conference paper: it explains the magnitude of the force discrepancy rather than only reporting it.

---

## Notas para quien retome este borrador

- No completar los `[PENDIENTE]` con valores estimados o supuestos — cada uno depende de un dato o una decisión de equipo todavía abierta (ver `../../CLAUDE.md`, sección "Qué falta decidir/hacer").
- El benchmark de literatura para Fz (110-170%BW según velocidad/lado) está en `../literatura/literatura_GRF_protesica.md` — no usar el número 100-120%BW suelto, ya se identificó como impreciso en esta misma sesión.
- Falta redactar: 5.3 (protocolo experimental — depende de si llegó la aprobación de ética), 5.4 (análisis estadístico — ya hay fórmulas listas en `../planificacion/plan_trabajo_5_semanas_articulo_Q2.md`, solo falta prosa), Introducción completa (este borrador solo tiene el párrafo de cierre/transición).
