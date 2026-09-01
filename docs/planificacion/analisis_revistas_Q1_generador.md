# Revista para el generador de trayectorias — análisis desde cero (27-ago-2026)

Análisis nuevo, no una actualización de `revistas_candidatas_Q2.md` (ese archivo evaluaba el artículo **anterior al pivote**: validación de hardware, sujeto único, Kinovea/iSen). El pivote del 19-ago cambió el perfil del artículo por completo — hay que re-evaluar encaje desde cero, con las mismas restricciones duras de siempre.

## Restricciones duras (no negociables, ya confirmadas en sesiones previas)

- **Lista cerrada de editoriales aprobadas por la universidad:** ACM, Annual Reviews, ASCE, ASME, ASTM, Bloomberg, Ebsco, **IEEE/IET Electronic Library**, JoVE, Nature, Passport, **ScienceDirect (Elsevier)**, Science, **SpringerLink**, WoS. **Fuera de la lista: MDPI, Frontiers, SAGE** (confirmado, no solo bloqueadas — SAGE descartó POI de forma definitiva).
- **Tope de APC: USD 2500** (salvo descuento de membresía EMBS, sin confirmar todavía — P-9).
- **Cuartil Q1 o Q2 exigido** por el programa de financiamiento (Journal of Biomechanics Open se descartó antes por no tener cuartil propio pese a ser gratis).
- Preferencia por **Gold OA**, no obligatoria.

## Perfil real del artículo, hoy (lo que cambia todo el análisis)

- **100% computacional.** Sin banco físico corriendo, sin sujetos humanos, sin ética.
- El contenido son **3 modelos de literatura (Koopman/Zhao/Yun) diagnosticados y validados contra 5 bases de datos públicas independientes** (Winter, Maastricht, Ferber, Kuopio, Camargo reservada) en 3 segmentos del miembro inferior (rodilla, tobillo, ángulo tibial) — **cinemática pura**, nada de fuerza/GRF activo en esta línea.
- El aporte propio es metodológico: geometría de cadena + calibración LOSO + el hallazgo del desfase de fase de 50% en `lado` de Zhao/Yun (ver `docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md`).
- **No hay ningún componente clínico ni traslacional todavía** — ni paciente, ni contexto de rehabilitación, ni demo del banco.

## Consecuencia directa: las candidatas "traslacionales" que se habían evaluado antes ya NO encajan bien

| Revista | Por qué encajaba antes | Por qué encaja peor ahora |
|---|---|---|
| **IEEE JTEHM** (Q2, elegida antes del pivote) | El simulador físico como herramienta de pre-evaluación clínica | JTEHM exige explícitamente TRL 5-9, "clinical or healthcare environment" — su propio "poor fit" declarado es "lab validation without clinical context". Antes el artículo AL MENOS tenía un banco físico corriendo; hoy no tiene ni eso — el riesgo de "poor fit" que ya existía **se agravó**, no se resolvió |
| **IEEE TNSRE** (Q1, IF 5.2) | Ingeniería de rehabilitación | Exige relevancia neuro-rehab/traslacional fuerte — mismo problema que JTEHM, sin componente clínico ni de paciente hoy |
| **IEEE/ASME T-Mech** (Q1, IF 7.3) | Se consideró por el banco robótico | El artículo hoy no tiene ningún contenido de mecatrónica/control — es 100% modelo+validación cinemática. Sin la fila 7 del tablero (banco físico) resuelta, no hay nada que ofrecerle a esta revista |
| **JNER** (Q1, IF 6.0) | Rehabilitación/neuroingeniería | Encaje parcial — JNER sí publica papers puramente metodológicos de predicción de marcha, pero su lector típico espera un ángulo de rehabilitación/paciente que este artículo no tiene |

## Candidatas re-evaluadas para el perfil actual (cinemática predictiva + validación multi-base)

| Revista | Editorial (¿aprobada?) | Cuartil / IF | Costo | Encaje real |
|---|---|---|---|---|
| **Gait & Posture** | Elsevier — ✅ | Q2 (una fuente Scopus dice Q1), IF 2.7 | Híbrida, **USD 0 sin pagar OA** | **El mejor encaje hoy.** Es LA revista de cinemática de marcha — comparar modelos predictivos contra múltiples datasets es exactamente su contenido habitual. La razón por la que se descartó antes (necesitaba también cinética/GRF) **ya no aplica** — el artículo actual es 100% cinemática |
| **Journal of Biomechanics** | Elsevier — ✅ | **Discrepancia sin resolver:** una fuente dice Q3/IF 2.4, otra (sesión previa) decía Q1-Q2 — **verificar cuartil exacto antes de comprometerse** | Híbrida, APC no confirmado (Elsevier general: USD 500-5000) | Muy alto en prestigio y encaje temático — es el journal donde se publicó Koopman 2014, el modelo base de este artículo. Riesgo real: si el cuartil verificado es Q3, no cumple el requisito del programa |
| **Medical Engineering & Physics** | Elsevier — ✅ | Q2 (histórico) | por confirmar | **Encaje confirmado (27-ago, texto completo leído):** es donde se publicó Sudeesh 2024, el precedente más cercano — misma arquitectura de 3-DOF sagitales, mismo argumento de "reducir dependencia de sujetos humanos", **y esa revista aceptó una validación con n=1 declarada abiertamente como limitación** — señal de que el nivel de rigor de este proyecto (N=15/40/246, muy por encima del precedente) tiene margen de sobra ahí. Framing más de ingeniería traslacional que Gait & Posture |
| **Computers in Biology and Medicine** | Elsevier — ✅ | Q1 (histórico, IF ~7) | por confirmar | Encaje medio-alto si se enfatiza el lado computacional/metodológico (comparación de modelos, calibración) más que el biomecánico puro — no verificado a fondo todavía |
| IEEE JTEHM | IEEE/IET — ✅ | Q2, IF 3.9 | USD 2160 (dentro del tope) | Ver tabla de arriba — encaje debilitado por el pivote |
| **Progress in Engineering Science** | Elsevier — ✅ | Q2, SJR 0.539 | USD 2580 (**~80 sobre el tope**) | Débil — revista joven, H-index bajo (8), sin encaje temático específico |
| POI | SAGE — ❌ **no aprobada** | — | — | Descartada, no reabrir |
| Sensors/Bioengineering/Prosthesis | MDPI — ❌ **no aprobada** | — | — | Descartadas, no reabrir |

## Veredicto: ¿ya se puede apuntar a Q1?

**Todavía no con garantías — depende de cuál Q1.** Distinción importante que no existía en el análisis anterior:

- **Q1 "traslacional/clínico" (TNSRE, JNER, T-Mech):** no, y no es solo cuestión de pulir texto — falta el componente clínico/físico que esas revistas piden por diseño editorial. Solo se vuelve viable si se cierra la fila 7 del tablero (banco físico real, hoy 0%).
- **Q1 "metodológico/biomecánico puro" (Journal of Biomechanics, si el cuartil se confirma en Q1-Q2, o Computers in Biology and Medicine):** **sí es defendible con lo que hay hoy**, siempre que se cierren antes: correr Camargo (examen final sin circularidad) y aplicar SPM1D/TOST a los datos reales — sin eso, el rigor estadístico (fila 4 del tablero, hoy 55%) queda débil para el nivel de exigencia de estas revistas.
- **Q2 seguro, sin más trabajo que redactar:** **Gait & Posture** — es el candidato de menor riesgo y mejor encaje temático hoy mismo, con el trabajo ya hecho (RODILLA/TOBILLO/INCLINACION_TIBIAL, las 5 bases de datos, el hallazgo del desfase de fase). Costo USD 0 si no se paga OA.

## Recomendación concreta

1. **Candidato por defecto, bajo riesgo:** Gait & Posture (Q2, encaje perfecto, costo 0).
2. **Apuesta a Q1, si se completa el trabajo pendiente:** Journal of Biomechanics — **primero verificar el cuartil real** (la discrepancia Q1/Q2/Q3 entre fuentes es un bloqueador de decisión, no un detalle) y correr Camargo + SPM1D/TOST antes de comprometerse.
3. **JTEHM descartada por completo (confirmado 27-ago-2026, decisión del usuario, no solo "retirada de la lista activa")** — no se manda nada ahí. TNSRE/T-Mech quedan igual de fuera por la misma razón (sin componente clínico/físico). El manuscrito nuevo se escribe desde cero para la revista que se elija — no se reciclan el Impact Statement ni el encuadre TRL que se habían armado específicamente para JTEHM, aunque sí puede compartir estructura de Métodos con el borrador anterior.
4. JNER queda como opción intermedia — ni tan mal encaje como TNSRE/T-Mech, ni tan bueno como Gait & Posture. Segunda opción de respaldo, no primera.

## Qué falta para cerrar esto con más certeza

- Verificar el cuartil real de Journal of Biomechanics (fuentes contradictorias).
- Confirmar APC de Medical Engineering & Physics y Computers in Biology and Medicine (no verificados todavía).
- Correr Camargo (Nivel A/B) y SPM1D/TOST — sube el rigor estadístico y hace defendible cualquiera de las opciones Q1.
- Decidir si vale la pena, más adelante, retomar el camino físico (fila 7) para reabrir JTEHM/TNSRE/T-Mech — eso es una decisión de alcance del equipo, no de literatura.
