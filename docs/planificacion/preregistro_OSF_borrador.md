# Preregistro OSF — borrador (candidato F)

> 🚨 **SUPERADO por el pivote — 19-ago-2026.** Las hipótesis (H1 fidelidad, H2 representatividad, H3 repetibilidad) son del enfoque anterior, reemplazado por completo (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20/P-21) — y de todas formas dependían de captura de sujetos con ética, ahora abandonada. Si se retoma un preregistro bajo el nuevo enfoque, hay que reescribirlo desde cero con las hipótesis del modelo generador (`analisis_escalamiento_Q1_generador_trayectorias.md` §7.2-7.3), no adaptar este.

**Estado: BORRADOR, no publicado en OSF todavía.** Sale del candidato **F** aprobado en `docs/DISCUSION_Q2.md` P-3 (11-ago-2026). Sigue la plantilla estándar de OSF ("OSF Preregistration" / basada en Van 't Veer & Giner-Sorolla 2016), adaptada a un estudio de validación de instrumento/simulador, no un ensayo clínico. **No se publica sin aprobación explícita** — mismo flujo que el resto del proyecto (discutir → aprobar → aplicar).

**Por qué importa el orden:** un preregistro solo protege el argumento si se publica **antes** de recolectar el primer dato de un sujeto nuevo. Hoy (13-ago-2026) no hay ningún sujeto nuevo capturado — la ventana sigue abierta, pero se cierra el día que arranque la campaña de captura (que a su vez depende de la aprobación de ética, comité 18-ago-2026).

**Lo que falta para que esto sea publicable, no solo borrador:** correr `CODIGOS/POTENCIA_EQUIVALENCIA/PotenciaApriori_Core.m` con los defaults de producción para tener el N objetivo con un número real (hoy sigue en `[PENDIENTE]`), y decidir el margen de equivalencia de TOST (`GUIA_INTERPRETACION.md` de esa carpeta, sección 5). Sin esos dos, el preregistro tendría números provisionales que después habría que corregir — mejor esperar a tenerlos.

---

## 1. Study Information

**Title:** Multi-Subject Functional Validation of a 3-DOF Gait Simulator for Transtibial Prosthesis Testing Using Inertial Motion Capture *(mismo título que `manuscrito_JTEHM.tex` — actualizar aquí si cambia allá)*

**Description:** Validación funcional de un simulador de marcha de 3 grados de libertad (horizontal, vertical, sagital) para evaluación de prótesis transtibiales, evaluando si la trayectoria fija programada desde un sujeto de referencia reproduce patrones de marcha de múltiples sujetos nuevos que no participaron en su programación, medido con un sistema de captura inercial (STT-IWS/iSen).

**Hypotheses** *(confirmatorias, ligadas a la matriz de comparaciones de `plan_trabajo_5_semanas_articulo_Q2.md`)*:

- **H1 (Comparación 3 — fidelidad de seguimiento):** para cada sujeto nuevo reprogramado, la trayectoria ejecutada por el simulador no difiere significativamente (SPM1D, diseño pareado) de la captura natural de ese mismo sujeto en una fracción sustancial del ciclo de marcha, **y** es estadísticamente equivalente (TOST, margen declarado en `POTENCIA_EQUIVALENCIA/GUIA_INTERPRETACION.md` §5) dentro de la variabilidad intra-sujeto.
- **H2 (Comparación 4 — representatividad):** la trayectoria fija original del simulador no difiere significativamente (SPM1D, diseño independiente) de la variabilidad natural agrupada de los sujetos nuevos en una fracción sustancial del ciclo de marcha.
- **H3 (Comparación 6 — repetibilidad):** el simulador mantiene ICC(3,1) ≥ 0.75 (umbral "good" de Koo & Li 2016, ya citado en `references.bib`) entre repeticiones, para cada condición evaluada.

**Qué NO es confirmatorio, y se declara exploratorio desde ya:** la corrección de Fz (Comparación 5, offset + fidelidad de seguimiento, con el término inercial inferido indirectamente del barrido de alturas — ver `DISCUSION_Q2.md` P-5) es caracterización de ingeniería del banco, no una hipótesis que se prueba con sujetos — se reporta de forma descriptiva/cuantificada, sin prueba de hipótesis formal.

---

## 2. Design Plan

**Study type:** Observational — comparación de curvas de marcha, sin intervención sobre los sujetos más allá de la captura de su marcha natural (fuera del simulador) y, para el subconjunto de sujetos que además se usan en la Comparación 3, la reprogramación del simulador con su propio CSV.

**Blinding:** No aplica — no hay evaluación subjetiva ni asignación de tratamiento; las métricas (RMSEnorm, SPM1D, ICC, TOST) son deterministas dado el par de curvas de entrada.

**Study design:** Ver matriz completa en `plan_trabajo_5_semanas_articulo_Q2.md` sección "Matriz de comparaciones". Resumen:
- Comparación 3: diseño **pareado** (cada sujeto contra sí mismo, dos condiciones: captura propia vs. salida del simulador reprogramado con su CSV).
- Comparación 4: diseño **independiente** (grupo de sujetos nuevos, capturados naturalmente, vs. la trayectoria fija original del simulador — no reprogramada).
- Comparación 6: repeticiones dentro de cada sujeto/condición, ICC(3,1).

**Randomization:** No aplica — no hay asignación aleatoria a condiciones; el orden de captura de sujetos no afecta el análisis (cada sujeto es su propia unidad de comparación en H1/H3, y se agrupan sin orden en H2).

---

## 3. Sampling Plan

**Existing data:** Los datos de los sujetos nuevos **no existen todavía** — este documento se redacta y (cuando corresponda) se publica antes de la primera captura. El dataset del sujeto original (`REFERENCIAS/*.mat`, vía Kinovea) no se usa como fuente de la trayectoria fija de este artículo tras el pivote a iSen — ver `../../CLAUDE.md`, decisión "Cambio de foco" (03-ago-2026); si se usa como antecedente exploratorio de la magnitud de sobreestimación de Fz (157.3 %BW, sección 5), eso ya se reporta como tal, no como parte de esta pre-registración.

**Sample size:** `[PENDIENTE — correr PotenciaApriori_Core.m con los defaults de producción (n_iter=200, n_perm=1000) y un grid de efectos a decidir; reportar aquí el N mínimo estimado para 80% de potencia, junto con el efecto que ese N puede detectar]`. Capacidad real de reclutamiento confirmada por el equipo: **hasta 50 sujetos** (`DISCUSION_Q2.md` P-3, 11-ago-2026) — el N objetivo no puede superar ese techo práctico.

**Sample size rationale:** Simulación Monte Carlo sobre el motor de permutación ya usado en el análisis confirmatorio (`SPM1D_Core.m`), con la variabilidad ensayo-a-ensayo del sujeto original como proxy de variabilidad entre sujetos — **advertencia explícita, no oculta:** ese proxy probablemente subestima la variabilidad real entre 15-50 personas distintas, así que el N reportado aquí es una primera estimación, a recalcular con datos reales de ~5 sujetos apenas existan (ver `POTENCIA_EQUIVALENCIA/GUIA_INTERPRETACION.md` §2). Esta limitación se declara en el preregistro mismo, no se descubre después.

**Stopping rule:** Se captura hasta alcanzar el N objetivo (una vez fijado, ver arriba) o hasta el límite de tiempo del cronograma del proyecto (plazo referencial, extensible — ver `../../CLAUDE.md`, "Objetivo inmediato y fecha límite"), lo que ocurra primero. Si se detiene por tiempo antes de alcanzar el N objetivo, se declara explícitamente en Resultados/Limitaciones, no se presenta como si el N planeado se hubiera alcanzado.

---

## 4. Variables

**Manipulated variables:** Ninguna en sentido experimental clásico — la "condición" es cuál trayectoria ejecuta el simulador (fija original vs. reprogramada por sujeto), no algo que se manipule sobre el sujeto.

**Measured variables:**
- Ángulo de inclinación de la plataforma (convención `atan2`, positivo por encima de la horizontal — sin excepciones, regla 8 de `DISCUSION_Q2.md` §2), apoyo y balanceo por separado.
- Fuerza vertical (Fz), cruda y corregida (offset + fidelidad de seguimiento).
- Métricas 0D derivadas por ensayo/sujeto (`Extraer_Features0D.m`): pico, tiempo-al-pico, ROM.
- Peso corporal y altura de cada sujeto nuevo (checklist de captura, `plan_trabajo_5_semanas_articulo_Q2.md`).

---

## 5. Analysis Plan

**Statistical models:**
- **SPM1D no paramétrico por permutación** (`SPM1D_Core.m`; Nichols & Holmes 2002, ya verificada) — diseño pareado (H1) e independiente (H2), reportando % del ciclo con diferencia significativa y clusters con su ubicación/p-valor.
- **TOST** (`TOST_Core.m`; Schuirmann 1987 — **cita todavía sin verificar, ver `POTENCIA_EQUIVALENCIA/GUIA_INTERPRETACION.md` §7**) sobre las métricas 0D, margen de equivalencia `[PENDIENTE — decidir antes de la primera captura, ver GUIA_INTERPRETACION.md §5]`.
- **ICC(3,1)** (`Calcular_Metricas_Curva.m`, ya extraído de `Validacion_Plataforma.m`/`Validacion_Fuerza.m`; Koo & Li 2016, ya verificada) para H3.
- RMSEnorm, r de Pearson, %±1SD como métricas descriptivas complementarias (no confirmatorias por sí solas — ver `plan_trabajo_5_semanas_articulo_Q2.md`, sección de fórmulas, sobre por qué SPM1D es la prueba primaria y estas son de apoyo).

**Transformations:** Ninguna transformación no lineal prevista sobre las curvas — se trabaja en las unidades originales (grados, %BW). Filtrado (Savitzky-Golay, mismo que `Validacion_Plataforma.m`/`Validacion_Fuerza.m`) se aplica como preprocesamiento estándar ya establecido, no como parte del análisis confirmatorio.

**Inference criteria:** α = 0.05 para SPM1D y TOST (cada prueba de una cola de TOST a α, sin corrección adicional — es una propiedad conocida del procedimiento de Schuirmann, no un error). Sin corrección de Bonferroni entre H1/H2/H3 — son hipótesis sobre comparaciones distintas (fidelidad, representatividad, repetibilidad), no pruebas múltiples sobre la misma pregunta.

**Data exclusion:** `[PENDIENTE — definir criterios de exclusión de sujetos/ensayos antes de la primera captura: p.ej. calibración estática fallida, pérdida de señal del sensor, ciclos de marcha incompletos. No dejar esto para decidirlo caso por caso durante el análisis]`.

**Missing data:** Un sujeto sin reprogramar todavía (p.ej. por falta de tiempo del equipo) se excluye de H1 pero puede incluirse en H2/H3 si tiene captura propia — mismo criterio que ya implementa `Procesar_Multisujeto_Core.m` (sujeto marcado `NaN`/"Sin reprogramar aún", sin romper el resto del pipeline).

**Exploratory analyses:** Corrección de Fz (Comparación 5, offset + fidelidad de seguimiento + término inercial inferido del barrido de alturas), benchmark contra literatura de vGRF protésica (`literatura_GRF_protesica.md`), y cualquier hallazgo no previsto en esta lista se reporta explícitamente como exploratorio, no confirmatorio.

---

## 6. Otras notas del proyecto, no del formato estándar de OSF

- Este documento no reemplaza el flujo de `DISCUSION_Q2.md` — cualquier cambio a las hipótesis, el N, o el margen de TOST después de publicado en OSF se documenta ahí como una decisión de desviación del preregistro (amendments), no se edita este archivo en silencio.
- Vínculo con el protocolo de ética: las hipótesis y variables de este documento deben ser consistentes con lo que `etica/comite_etica.md` describe — revisar ambos documentos juntos antes de publicar en OSF, no por separado.
- Cuando se publique en OSF, actualizar aquí el enlace/DOI del preregistro y anotar la fecha real de publicación (que tiene que ser antes de la primera captura de un sujeto nuevo).
