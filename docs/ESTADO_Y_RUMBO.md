# ESTADO Y RUMBO — Artículo Q2

**Documento maestro. Empezar por aquí.** Consolida lo disperso en `planificacion/`, `manuscrito/` y `literatura/` para responder tres preguntas sin tener que leer cinco archivos: **qué es el artículo, qué se toca, y qué falta.**

**Actualizado:** 11-ago-2026 · **Revista:** IEEE JTEHM · **Envío:** setiembre 2026 como referencia, **confirmado extensible sin problema** (decisión del usuario, 11-ago) — el techo duro real es el límite de 8 páginas, no el calendario

---

## 1. El artículo, en diez líneas

**Afirmación central:** el simulador reproduce patrones de marcha de **múltiples sujetos que no participaron en su programación**, medido con un solo instrumento inercial de validez ya establecida en literatura, con las fuentes de error **cuantificadas y desacopladas**, no solo narradas.

**Instrumento único:** STT-IWS/iSen, usado para las tres cosas — capturar sujetos nuevos, recapturar al sujeto de referencia, y medir la salida de la propia plataforma. Más la plataforma de fuerza AMTI para Fz.

**Fuera de alcance, por decisión ya tomada — no reabrir:** Kinovea · el IMU de Alessandro · concordancia entre instrumentos (Bland-Altman) · caracterización de rigidez de la prótesis · lazo cerrado o generación algorítmica de trayectorias · **cualquier cita al paper de conferencia IBITeC 2026**.

---

## 2. Qué se toca — el contenido real

| Sección | Contenido | Se alimenta de | Estado |
|---|---|---|---|
| Introducción | Necesidad clínica + vacío: los simuladores se programan desde un sujeto único y eso rara vez se verifica | Literatura externa | **Redactada.** Falta condensar y confirmar la frase de novedad |
| 5.1 Sistema | 3 DOF, CSV → RPi → ESP32, lazo abierto | — | **Redactada** |
| 5.2 Instrumentación | iSen + AMTI, convención de ángulo, por qué no se re-valida el instrumento | Literatura + piloto | **Redactada**, pendiente del piloto |
| 5.3 Protocolo | Sujetos, capturas, condiciones | Ética | **Sin redactar** — bloqueada |
| 5.4 Estadística | RMSEnorm, r, ±1SD, ICC(3,1), SPM1D permutación, marco ISO 5725 | — | **Completa** ✔ |
| Resultados | Las 4 comparaciones de abajo | Datos | **Sin redactar** — bloqueada |
| Discusión | Fuentes de error desacopladas, limitaciones, trabajo futuro | — | **Sin redactar** |
| Abstract (5 campos) + **Impact Statement** | Impact Statement es **obligatorio**, ≤30 palabras, con categoría del espectro clínico NIH | — | **Vacíos.** Sin Impact Statement devuelven el envío sin revisar |

### Las 4 comparaciones vivas

| # | Qué compara | Qué demuestra | Bloqueada por |
|---|---|---|---|
| **3** | Simulador reprogramado por sujeto vs. captura de ese sujeto | Fidelidad de seguimiento robusta, no un golpe de suerte | Ética + RPi-ESP32 |
| **4** | Salida fija del simulador vs. variabilidad natural del grupo | Representatividad de la trayectoria por defecto | Ética + RPi-ESP32 |
| **5** | Fz cruda vs. corregida vs. literatura protésica | Explicación cuantificada del error en 3 fuentes | RPi-ESP32 (offset) · **el resto NO depende de ética** |
| **6** | Repetibilidad inter-repetición (ICC) | Consistencia del simulador | Ética para sujetos nuevos · ya existe para el dataset original |

*(Las comparaciones 1 y 2 quedaron fuera de alcance el 03-ago. `BlandAltman_Core.m` está construido y probado, sin uso este ciclo.)*

---

## 3. Los tres bloqueos

**Actualizado 11-ago-2026 — los tres pasaron de "sin información" a "con fecha o avance concreto":**

| Bloqueo | Estado (11-ago-2026) | Qué bloquea | Quién lo resuelve |
|---|---|---|---|
| **Integración Raspberry Pi–ESP32** | 🟡 Interfaz y pantalla ya instaladas en el simulador. Falta la integración con el ESP32, **~2 semanas estimadas** | **Todo lo que implique mover el simulador**: comparaciones 3, 4, mitad de 5. Sin esto no hay ni posicionamiento estático de un eje | Equipo (Electrónica/Mecatrónica) |
| **Aprobación de ética** | 🟡 Protocolo redactado, **en revisión del asesor**. **Comité: 18-ago-2026** | Cualquier captura de sujeto: comparaciones 3, 4, 6 y la recaptura del sujeto de referencia | Comité — envío ya no está pospuesto, está en curso con fecha |
| **Piloto de iSen** | 🟡 **Ángulo de inclinación tibial ya se obtiene limpio**, vía un pipeline en Python de un compañero del equipo que calcula y segmenta el ángulo por ciclo de marcha a partir de los datos crudos de iSen. Falta cerrar el **desplazamiento (X,Y)** | Confirma si el sensor exporta orientación cruda o solo el ángulo articular calibrado. Define si hace falta el plan B de dos IMU | Equipo, en curso — se sube el código al proyecto cuando cierre la parte de desplazamiento |

**El punto que más importa de esta sección:** la corrección de Fz (comparación 5) **no depende de ética**. Junto con la fidelidad de seguimiento comandado-vs-encoder, es el **único contenido empírico que puede existir sin sujetos humanos**. Eso responde al riesgo señalado en `planificacion/propuesta_articulo_Q2.md` §9 — tras el pivote parecía no haber contenido de respaldo si ética se atrasaba. Sí lo hay: un artículo de caracterización del sistema, más débil que el planeado pero no vacío. **Con la fecha del comité (18-ago), ese escenario de respaldo es cada vez menos probable que haga falta.**

**Sobre el plazo del artículo:** decisión del usuario el 11-ago-2026 — la quincena de setiembre **es referencial y se puede extender considerablemente**. No se activa ningún plan B de contenido reducido por presión de calendario; ver `DISCUSION_Q2.md` P-7. El único techo duro que sigue siendo duro es el de **8 páginas** de JTEHM.

---

## 4. Mapa de documentos — qué está vivo y qué no

### Vivos — se consultan y se editan

| Documento | Para qué |
|---|---|
| **`DISCUSION_Q2.md`** | **El único documento de interacción.** Tablero de avance, reglas de trabajo, preguntas abiertas y registro de decisiones. **Se discute ahí; aquí se guarda el resultado** |
| `ESTADO_Y_RUMBO.md` | **Este.** Almacenamiento maestro |
| `manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` | **El manuscrito final** (lo que va a Overleaf) |
| `manuscrito/JTEHM_LaTex_Template/references.bib` | Bibliografía final, con estado por entrada |
| `manuscrito/metodos_introduccion_borrador.md` | Borrador en prosa |
| `manuscrito/referencias_verificadas.md` | Control de citas y acciones pendientes |
| `manuscrito/guia_autor_JTEHM.md` | Reglas de la revista (8 páginas, Impact Statement, figuras) |
| `planificacion/plan_trabajo_5_semanas_articulo_Q2.md` | Fórmulas estadísticas y matriz de comparaciones. **Su cronograma semanal ya no aplica** — las fechas se corrieron |
| `planificacion/propuesta_articulo_Q2.md` | Justificación metodológica y objeciones de revisor |
| `codigos/INDICE_CODIGOS.md` | Mapa de `CODIGOS/` |

### Consulta puntual — no leer completos

`literatura/literatura_GRF_protesica.md` (benchmark de Fz) · `literatura/validacion_instrumentos_IMU.md` · `literatura/normas_ISO_relevantes.md` · `literatura/postprocesado_datos_crudos_IMU.md` · `etica/comite_etica.md` · `equipo/tarea_alessandro.md` · `planificacion/revistas_candidatas_Q2.md` (**solo la primera sección está vigente**; el resto es el historial de 6 vueltas)

### Futuro — no es este artículo

`planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` — la línea del generador de trayectorias desde antropometría, para el artículo 2 (2027, IEEE TNSRE). **No mezclar con el Q2.**

### Archivados en `_archivo/` — superados, se conservan

`preguntas_SIBUC_VRI.md` (resuelto por la lista de editoriales aprobadas) · `plantilla_overleaf_POI.tex` · `plantilla_overleaf_Bioengineering_MDPI.tex` · `plantilla_overleaf_Prosthesis_MDPI.tex` (revistas descartadas)

---

## 5. Qué se puede hacer hoy — nada de esto está bloqueado

| # | Tarea | Esfuerzo | Por qué importa |
|---|---|---|---|
| ~~1~~ | ~~Leer el simulador compacto (Med Eng Phys 2024)~~ | — | ✅ **11-ago:** metadatos verificados y resumen leído. La frase de novedad **se sostiene** a nivel de resumen. Queda leer el texto completo antes del envío (¿de cuántos sujetos salieron sus datos de marcha?) |
| ~~2~~ | ~~Leer la revisión Neelen 2026~~ | — | ✅ **11-ago: descartada.** Es de otro tema — simuladores que *viste* una persona sana, no bancos robóticos. Ver §6-D |
| ~~3~~ | ~~Impact Statement + posicionamiento TRL~~ | — | ✅ **13-ago:** aprobado con corrección (sin "knee", el simulador es transtibial) y aplicado en `manuscrito_JTEHM.tex`. Falta solo pegarlo en Overleaf. Ver `DISCUSION_Q2.md` T-1 |
| ~~4~~ | ~~Completar autoría de 3 referencias~~ | — | ✅ **11-ago:** las 5 referencias de simuladores e instrumentación están completas y verificadas. ✅ **13-ago:** las 4 de métodos estadísticos también, con una advertencia nueva (ISO 5725-1:1994 está retirada, ver `referencias_verificadas.md`) |
| ~~5~~ | ~~Correr `Test_Procesar_Multisujeto.m` en MATLAB~~ | — | ✅ **13-ago:** confirmado 7/7 PASS por el usuario. Si se modifica el código, re-correr |
| ~~6~~ | ~~Decidir `m_eje` (CAD vs. renunciar al término inercial)~~ | — | ✅ **13-ago:** ni CAD ni pesaje (distribución no uniforme de fuerza/peso) — se infiere indirectamente del barrido de alturas de offset (1). Ver `DISCUSION_Q2.md` P-5 y `plan_trabajo_5_semanas_articulo_Q2.md` |
| 7 | Decidir autoría, CRediT y declaraciones | Decisión de equipo | 🟡 **13-ago, parcial:** Luis Marcos Plasencia Janampa como autor de correspondencia, correo confirmado `luis.plasencia@pucp.edu.pe` y ya aplicado en el `.tex`. Resto de autores pendiente |
| ~~0~~ | ~~Confirmar que Piche 2022 evalúa iSen/STT-IWS~~ | — | ✅ **11-ago:** confirmado sobre el PDF. Es **LA** validación del sistema (*"no study have validated this specific ISEN system"*). Métodos 5.2 ya lo afirma directamente, con cifras. PDF en `literatura/pdfs/` |
| 8 | **Buscar reemplazo de la cita R2**, o eliminar esa frase | 1-2 h | R2 es un resumen de congreso de una página — cita débil para IEEE. Su reemplazo previsto era Neelen 2026, que ya no aplica |
| ~~9~~ | ~~Búsqueda deliberada de revisiones de **bancos robóticos** de marcha~~ | — | ✅ **16-ago:** segunda ronda de búsquedas independientes (se suma a la del 11-ago), mismo resultado — no existe revisión sistemática dedicada. Refuerza (no cambia) la Limitation #5 ya redactada en `manuscrito_JTEHM.tex`. Ver `DISCUSION_Q2.md` §4-bis |

---

## 6. Cómo hacerlo más fuerte — candidatos evaluados

Ocho opciones consideradas. Las columnas son honestas: *desbloqueado* significa que no depende de ética, hardware ni sujetos.

| Candidato | Desbloq. | Esfuerzo | Ganancia | Veredicto |
|---|---|---|---|---|
| **A. Análisis de potencia a priori por simulación** | ✅ | ~1 sem | **Alta** | ✅ **Aprobado 11-ago, código construido 13-ago** |
| **B. Pruebas de equivalencia (TOST) además de tests de diferencia** | ✅ | ~2 sem | **Alta** | ✅ **Aprobado 11-ago, código construido 13-ago** |
| **C. Justificar la arquitectura 3-DOF con literatura** | ✅ | ~0 | Media | ✅ **Hecho 11-ago** |
| ~~D. Condensar Introducción con la revisión de 2026~~ | — | — | — | ❌ **Cae 11-ago** — la revisión es de otro tema |
| E. Presupuesto formal de incertidumbre (ISO 5725/GUM) extendido a cinemática | ✅ | ~2 sem | Media-alta | ✅ **Aprobado 16-ago (P-19), código construido 16-ago** |
| F. Preregistro del plan de análisis (OSF) | ✅ | ~2 días | Media | ✅ **Aprobado 11-ago, borrador redactado 13-ago** |
| G. Material suplementario con curvas individuales | ❌ | Bajo | Baja-media | Si sobra tiempo |
| H. Adelantar algo del generador de trayectorias | ✅ | Alto | **Negativa** | **No hacer** |

**A, B y F aprobados por el usuario el 11-ago-2026** (`DISCUSION_Q2.md` P-3). **A y B: código construido el 13-ago-2026** — `CODIGOS/POTENCIA_EQUIVALENCIA/` (`PotenciaApriori_Core.m`, `TOST_Core.m`, `Test_PotenciaApriori_TOST.m`, `GUIA_INTERPRETACION.md`), sin correr todavía en MATLAB/Octave por el usuario. **F: borrador redactado el 13-ago-2026** — `docs/planificacion/preregistro_OSF_borrador.md`, con N y margen de TOST en `[PENDIENTE]` hasta correr A y B; no publicado en OSF todavía.

### A — Análisis de potencia a priori por simulación

**El problema que resuelve:** la objeción número uno que va a recibir este artículo es el tamaño de muestra (`propuesta_articulo_Q2.md` §4.2). Hoy la defensa es argumental: *"es validación técnica, no estudio clínico"*. Eso ayuda, pero no es un número.

**Qué es:** usando la variabilidad de las curvas que **ya existen** y el motor de permutación de `SPM1D_Core.m`, simular cuántos sujetos hacen falta para detectar una diferencia de X grados en el ciclo de marcha, con qué potencia. Resultado: *"con n=15 el diseño detecta diferencias ≥ X° con potencia ≥ 80% en el Y% del ciclo"*.

**Por qué es fuerte:** convierte la limitación en un parámetro de diseño declarado. Casi ningún artículo de biomecánica con SPM1D lo reporta — es un diferenciador real, no un trámite. Y no necesita ni un sujeto nuevo.

**Riesgo honesto:** puede revelar que n=15 no alcanza para lo que se quiere afirmar. Es mejor saberlo ahora que en la carta del revisor.

**Actualizado 11-ago-2026 — dato que cambia el marco:** la capacidad real de reclutamiento del equipo no es 15-20, es **hasta 50 sujetos sin problema** (`DISCUSION_Q2.md` P-3). La pregunta deja de ser *"¿15 alcanza?"* y pasa a ser *"¿cuántos hacen falta, dado que el techo real es mucho más alto?"* — una posición bastante más cómoda para defender el diseño.

**Construido 13-ago-2026:** `CODIGOS/POTENCIA_EQUIVALENCIA/PotenciaApriori_Core.m`, validado con datos sintéticos. Advertencia real, no cosmética: usa hoy la variabilidad ensayo-a-ensayo del sujeto original como proxy de variabilidad entre sujetos distintos — probablemente optimista, hay que recalcular en cuanto existan ~5 sujetos reales (detalle en `GUIA_INTERPRETACION.md` §2).

### B — Pruebas de equivalencia

**El problema que resuelve:** el artículo afirma que el simulador **reproduce** la marcha. Si Resultados dice *"SPM1D no encontró diferencias significativas"*, un revisor responde: *"eso no prueba equivalencia, prueba falta de potencia"*. Ausencia de evidencia no es evidencia de ausencia — y con n modesto es exactamente lo que va a pasar.

**Qué es:** además de los tests de diferencia, pruebas de equivalencia con un umbral declarado a priori. El umbral natural, y que ya está implementado en el proyecto, es **la variabilidad intra-sujeto**: si la discrepancia simulador-vs-sujeto no supera la que el sujeto tiene consigo mismo entre pasadas, la reproducción es indistinguible de su ruido natural.

**Implica:** extender `SPM1D_Core.m`, que hoy solo detecta diferencias. Trabajo acotado, pero no se improvisa en la semana de redacción.

**Beneficio doble:** el mismo módulo lo necesita el artículo 2 (ver `planificacion/analisis_escalamiento_Q1_...` §2.6). Se construye una vez, sirve dos veces.

**Construido 13-ago-2026:** `CODIGOS/POTENCIA_EQUIVALENCIA/TOST_Core.m`, validado con datos sintéticos. El margen de equivalencia todavía no está decidido (ver `GUIA_INTERPRETACION.md` §5) — no se aplica a datos reales sin esa decisión.

### C — Hecho el 11-ago-2026

El simulador compacto de Med Eng Phys 2024 concluye que **solo los movimientos del plano sagital — flexión-extensión, traslación vertical, traslación horizontal — bastan para ensayar rodillas protésicas.** Es exactamente la arquitectura de 3 DOF de este simulador, publicada de forma independiente por otro grupo. Convierte una elección de diseño en una decisión respaldada, con una cita.

Ya incorporado en 5.1 del `.tex`, con la cita ahora verificada y completa (`Sudeesh2024CompactGaitSimulator`).

### D — Cae: la revisión de 2026 es de otro tema

**Lo que se creía el 05-ago:** que Neelen et al. 2026 (*State of the art of lower limb prosthesis simulators*, 73 estudios, acceso abierto) permitía reemplazar cuatro papers sueltos por *"una revisión reciente de 73 estudios establece que…"*, condensar la Introducción y documentar el vacío con voz de terceros.

**Lo que dice al leerla:** en esa revisión, *prosthesis simulator* significa **un dispositivo que viste una persona sana** para imitar el uso de una prótesis — bota, ortesis o adaptador de *bypass*. Textual: *"designed to mimic prosthesis use with anatomically intact individuals"*. Sus 18 estudios "transtibiales" son botas que inmovilizan el tobillo a ~90° en sujetos sanos, no plataformas motorizadas. Es otra literatura que comparte el nombre.

**Tres consecuencias:**

1. **No se cita.** Presentarla como "la revisión más reciente del campo" es un error de categoría que un revisor de JTEHM detecta en un minuto — y de los que contaminan la credibilidad del resto.
2. **El vacío vuelve a sostenerse por cuenta propia.** No hay, por ahora, respaldo externo de tercero para la premisa central. Lo más cercano que existe es R1 (Etoundi 2022), un banco robótico **diseñado a partir de la marcha de un solo participante amputado** — evidencia concreta de que la práctica que este artículo cuestiona es la habitual. Conviene apoyarse en ella explícitamente.
3. **La cita más débil sigue sin reemplazo** (tarea 8 de §5).

Detalle completo, con las citas textuales: `manuscrito/referencias_verificadas.md`.

### E — Presupuesto formal de incertidumbre (GUM/ISO 5725)

**El problema que resuelve:** el argumento central promete fuentes de error *cuantificadas, no solo narradas*. Eso ya está resuelto para Fz (offset + fidelidad de seguimiento, P-5), pero del lado cinemático (ángulo de plataforma) la incertidumbre se sigue describiendo en prosa ("el instrumento tiene tal RMSD, la calibración tiene tal residuo") sin combinarlas en un número único con su propio nivel de confianza.

**Qué es:** un presupuesto de incertidumbre formal siguiendo la ley de propagación de incertidumbre de la GUM (JCGM 100:2008) — la misma familia metodológica que ISO 5725, ya citada en 5.4. Combina componentes (validación del instrumento, residuo de calibración de offset, repetibilidad ensayo-a-ensayo) en una incertidumbre estándar combinada y una incertidumbre expandida al 95%, con una tabla que muestra qué % de la incertidumbre total aporta cada fuente.

**Por qué es fuerte:** casi ningún artículo de bancos de prueba de marcha reporta un presupuesto de incertidumbre formal — es otro diferenciador real, en la misma línea que A y B. Y, como A y B, no necesita ni un sujeto nuevo para diseñarse (aunque sí para tener los números finales de los componentes Tipo A).

**Aprobado 16-ago-2026 (`DISCUSION_Q2.md` P-19) — "no depende de nada, avanzar todo lo posible mientras los datos reales demoran".** Construido el mismo día: `CODIGOS/INCERTIDUMBRE/PresupuestoIncertidumbre_Core.m`, genérico (no hardcodea ningún número del proyecto — recibe los componentes como entrada), validado con datos sintéticos incluyendo un caso de uso realista con las cifras de Piche 2022. **Decisión pendiente antes de usarlo con datos reales:** qué cifra de Piche 2022 (rodilla 3.3°/tobillo 5.6°/cadera 7.3°) es la analogía correcta para el ángulo de plataforma medido por el simulador — no es un ángulo articular en sentido clínico, ver `GUIA_INTERPRETACION.md` §6.

### F — Preregistro: la ventana está abierta justo ahora

Un preregistro solo vale si se hace **antes** de recolectar los datos. Como no hay ni un sujeto capturado todavía, la ventana está abierta — **y se cierra el día que empiece la campaña**. Publicar en OSF el plan de análisis (métricas, umbrales, criterios de exclusión, plan estadístico) cuesta un par de días y es una señal de rigor que un revisor de instrumentación valora. Combinado con A y B, los tres se refuerzan: potencia declarada + umbral de equivalencia declarado + plan congelado.

**Borrador redactado 13-ago-2026:** `docs/planificacion/preregistro_OSF_borrador.md` — hipótesis confirmatorias (H1 fidelidad, H2 representatividad, H3 repetibilidad) y exploratorias (corrección de Fz) separadas explícitamente, plan de muestreo, variables, plan de análisis. Faltan dos números antes de poder publicarlo: el N objetivo (correr `PotenciaApriori_Core.m` con los defaults de producción) y el margen de equivalencia de TOST (decisión pendiente, ver su guía §5).

### H — Por qué NO adelantar nada del generador de trayectorias

Tentador, pero perjudica en tres frentes: (1) **canibaliza la contribución central del artículo 2**, que es donde vale más; (2) con 8 páginas incluyendo referencias no cabe, y lo que entre saldrá superficial — peor que no ponerlo; (3) diluye la afirmación central, y los revisores Q2 penalizan los manuscritos que se sienten como "todo lo que hicimos". **Mencionarlo en trabajo futuro es suficiente, y ya está previsto.**

---

## 7. Recomendación

*(Actualizada el 11-ago-2026 tras cerrar la bibliografía.)*

1. ~~Hoy mismo, costo cero: C y D.~~ ✅ **C hecho; D cae.** Con eso, las tareas 1, 2 y 4 de §5 también quedan cerradas.
2. ~~Lo siguiente, y es lo más valioso desbloqueado que queda: tarea 3 de §5 — Impact Statement + posicionamiento TRL.~~ ✅ **13-ago: cerrada**, ver §5 tarea 3.
3. **Antes de que empiece cualquier captura:** decidir A, B y F. Las tres pierden todo su valor si se deciden después de tener los datos.
4. **No tocar:** H, y nada que reabra decisiones ya cerradas de §1.

**Lo que hay que entender del rumbo:** el artículo no está atascado por falta de ideas ni de herramientas — las herramientas están construidas y probadas. Está atascado en **dos bloqueos físicos** (integración y ética) que no se resuelven escribiendo. Todo lo listado en §5 y §6 existe precisamente para que, el día que esos bloqueos caigan, el trabajo restante sea recolectar y redactar, no diseñar.
