# Bases de datos sugeridas por la profesora — evaluación (23-ago-2026)

**Contexto:** 6 links enviados por la profesora asesora, sin revisar por el equipo. Se evalúan aquí contra el criterio de validación del generador: ángulos articulares sagitales reales (cadera/rodilla/tobillo) + antropometría de segmentos, población suficiente, sin participar en la construcción del algoritmo (regla de no-circularidad, `analisis_escalamiento_Q1_generador_trayectorias.md` §7.2). Preferencia declarada del proyecto por bases sudamericanas/peruanas (banner de pivote, `CLAUDE.md`).

| # | Dataset | N | Institución/país | Tipo de dato | ¿Sirve para Nivel A/B? |
|---|---|---|---|---|---|
| 1 | Health&Gait (Zenodo 14039922) | 398 | no especificado | **Video 2D** (AlphaPose), no mocap 3D, sí antropometría | ❌ No da ángulos sagitales reales de mocap — es pose 2D de video, insuficiente para Nivel A/B |
| 2 | **Kuopio Gait Dataset** (Zenodo 10559504) | **51** | U. Eastern Finland | **Mocap 3D real** (marcadores, GRF), IMU, antropometría completa (long. de segmentos, ancho rodilla/tobillo) | ✅ **Sí — el más fuerte de los 6.** Mismo tipo de dato que Camargo, población mayor (51 vs 22) |
| 3 | (Zenodo 10787523) | 4 | U. Twente, Holanda | Mocap+IMU+EMG, pero **post-ACV**, no sanos | ❌ Población equivocada (patológica) y n insuficiente |
| 4 | DUO-GAIT (Zenodo 8244887) | 16 | U. Potsdam/Freiburg | Solo IMU, parámetros espacio-temporales | ❌ No da ángulos articulares directos, solo derivados de IMU |
| 5 | Full-Body 3D Gait (Zenodo 12818935) | 26 | no especificado | IMU Xsens, ángulos articulares sí, pero **antropometría sin longitud de muslo/tibia** (solo talla, pie, hombro, muñeca) | ⚠️ Parcial — ángulos sí, longitud de segmento no directamente |
| 6 | GaHu-Video (Mendeley gprg4s73v4) | 44 | **Universidad Militar Nueva Granada, Colombia** | Video, silueta (ancho/alto/área de rectángulo) — **reconocimiento de personas, no biomecánica** | ❌ Es la única sudamericana, pero no mide ángulos ni antropometría de segmentos — dataset de identificación por marcha, no de cinemática |

## Conclusión honesta

**Ninguno de los 6 es sudamericano/peruano con el tipo de dato que la validación necesita.** El único dataset de la región (#6, Colombia) es de reconocimiento de personas por silueta de video — no sirve para comparar ángulos articulares.

**El hallazgo útil es el #2 (Kuopio, Finlandia).** Mismo tipo de dato que Camargo (mocap 3D + antropometría de segmentos), con más sujetos (51 vs 22). No reemplaza a Camargo — sigue siendo la decisión ya cerrada en P-24 — pero es un candidato serio como **segunda base de validación independiente**, útil para robustecer el Nivel A/B con una cohorte que no participó en ningún candidato del generador, en un país distinto (reduce el riesgo de que un patrón particular de la cohorte de Camargo, todos de EE.UU., contamine la conclusión).

**No se toma ninguna decisión de incorporarlo todavía** — es información para que el usuario decida si vale la pena, no una sustitución del plan vigente. Camargo sigue siendo el dataset primario del plan `plan_100_generador.md`.
