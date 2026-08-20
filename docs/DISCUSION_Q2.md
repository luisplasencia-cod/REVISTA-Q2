# Discusión de trabajo — Artículo Q2 (IEEE JTEHM)

**Este es el único `.md` de interacción del proyecto Q2.** Todos los demás son de almacenamiento.

> **Cómo trabajamos**
> - Un tema a la vez. Yo escribo el análisis y las preguntas; tú respondes en los bloques ` ✍️ TU RESPUESTA `.
> - Si algo se discute y se resuelve **en el chat**, lo marco aquí con ✅ para que ninguna pregunta quede aparentemente abierta.
> - **Nada se aplica a los `.md` de almacenamiento ni al `.tex` sin tu visto bueno.**
> - Cuando una decisión se cierra aquí, **yo la vuelco** al archivo de almacenamiento que corresponda y lo anoto en §6. Este archivo no guarda el contenido final, guarda **cómo se llegó a él**.

---

## 0 · Mapa de archivos — quién manda sobre qué

**La regla de una línea:** se discute aquí, se guarda allá, y si los dos dicen cosas distintas, **manda el de almacenamiento** (porque es donde se aplicó la decisión).

| Archivo | Rol | ¿Se edita? |
|---|---|---|
| **`DISCUSION_Q2.md`** (este) | **Interacción.** Preguntas, opciones, decisiones en curso, tablero de avance | Constantemente |
| `ESTADO_Y_RUMBO.md` | **Almacenamiento maestro.** Qué es el artículo, comparaciones, bloqueos, candidatos de refuerzo | Al cerrar una decisión |
| `../CLAUDE.md` | **Almacenamiento de contexto.** Se carga solo al abrir sesión. Decisiones cerradas e historial | Al cerrar una decisión |
| `manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` | **El manuscrito final.** Lo que va a Overleaf | Al aprobar redacción |
| `manuscrito/JTEHM_LaTex_Template/references.bib` | Bibliografía final, con estado por entrada | Al verificar una cita |
| `manuscrito/metodos_introduccion_borrador.md` | Borrador en prosa. **Si difiere del `.tex`, manda el `.tex`** | Al redactar |
| `manuscrito/referencias_verificadas.md` | Control de citas: qué se verificó, contra qué, y qué advertencia arrastra | Al verificar una cita |
| `manuscrito/guia_autor_JTEHM.md` | Reglas de la revista | Casi nunca |
| `planificacion/*.md` · `literatura/*.md` · `codigos/INDICE_CODIGOS.md` | Almacenamiento temático | Al aparecer un hallazgo |
| `CODIGOS/*/GUIA_INTERPRETACION.md` | Cómo leer cada número de cada script | Al tocar un script |

**Los `.md` de almacenamiento no son solo archivo muerto — se consultan para decidir.** Tres que hay que abrir *antes* de discutir ciertos temas:

- ¿Vamos a hablar de **Fz o del benchmark**? → `literatura/literatura_GRF_protesica.md` primero. Tiene la corrección de que 100-120 %BW **no** es el techo típico.
- ¿Vamos a hablar de **qué compara qué, o de fórmulas**? → `planificacion/plan_trabajo_5_semanas_articulo_Q2.md`. (Su **cronograma semanal ya no aplica**; las fórmulas y la matriz sí.)
- ¿Vamos a **fijar o mover una cita**? → `manuscrito/referencias_verificadas.md`. Ahí está qué se verificó y qué advertencia arrastra cada una.

**Flujo obligatorio:** discutir aquí → aprobar → aplicar en el archivo que corresponda → anotar en §6 dónde se aplicó.

---

> 🚨 **CAMBIO DE RUMBO CERRADO (19-ago-2026) — ver P-20 en §4-quater.** El artículo reemplaza por completo el enfoque anterior: ya no es fidelidad de seguimiento multi-sujeto, es generación propia de trayectoria desde antropometría, validada contra bases de datos independientes (preferencia: peruanas/sudamericanas). **El tablero de abajo describe el artículo ANTERIOR — queda como historial, no como estado vigente**, hasta que se rehaga con el nuevo alcance.
>
> ⬜ **P-22 pendiente (§4-sexies, 20-ago-2026):** cerrando la última ambigüedad de alcance — confirmar si el banco físico puede ejecutar/medirse a sí mismo sin sujeto humano (sin ética) o si el artículo es 100% computacional. También ahí: 6 candidatos de algoritmo en secciones individuales, listos para revisar uno por uno.
>
> 📍 **Dónde contestar ahora mismo (20-ago-2026):** todo lo pendiente vive en **§4-sexies**, un poco más abajo en este mismo archivo — busca "4-sexies" (Ctrl+F). Ahí están: (1) las 2 preguntas de P-22, (2) las 6 secciones de candidato de algoritmo, cada una con su propio bloque `✍️`. No hace falta responder todo de una vez — cada bloque es independiente. **Dónde está el avance hacia Q1/Q2:** `docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md`, sección **§13 "Tablero cuantificado"** — tiene el puntaje (29/100 al 05-ago) y qué falta para subir. Ese puntaje se recalcula apenas cierre P-22 (ver nota en §4-sexies).

## 1 · Tablero de avance

**Global del artículo: 51 %** · `██████████░░░░░░░░░░` *(actualizado 17-ago-2026: candidato E construido, inconsistencia de 5.2 corregida, bloqueos sin cambio)*

| # | Objetivo | Avance | |
|---|---|---|---|
| **O1** | **Manuscrito redactado** | `██████████░░░░░░░░░░` | **50 %** |
| **O2** | **Bibliografía verificada** | `██████████████████░░` | **90 %** |
| **O3** | **Herramientas de análisis** | `█████████████████░░░` | **85 %** ▲ |
| **O4** | **Datos empíricos** | `██░░░░░░░░░░░░░░░░░░` | **10 %** |
| **O5** | **Bloqueos externos levantados** | `██████░░░░░░░░░░░░░░` | **30 %** |
| **O6** | **Requisitos de JTEHM** | `████████░░░░░░░░░░░░` | **40 %** |

**Lo que hay que leer en este tablero:** O3 sube (16/17-ago) por el candidato E construido (`CODIGOS/INCERTIDUMBRE/`), tercer candidato de refuerzo con código completo junto a A y B. O1 no sube pese a la corrección de 5.2 — era un arreglo de consistencia interna, no contenido nuevo (ver §4-bis). **El artículo no avanza más allá de ~60-65 % global hasta que los tres bloqueos de O5 caigan de verdad**, y siguen sin caer: RPi-ESP32 sigue sin integrarse (misma estimación ~25-ago), **el comité de ética es mañana (18-ago) y todavía no hay respuesta al momento de este chequeo (17-ago)**, desplazamiento X,Y de iSen sigue en pruebas. Ver P-15.

### Detalle por objetivo

**O1 · Manuscrito — 50 %**

| Sección | Estado | Falta |
|---|---|---|
| Introducción | 🟢 80 % | Condensar a 8 págs · frase de novedad (depende de leer R4 completo) · 1-2 frases de posicionamiento TRL |
| 5.1 Sistema | 🟢 100 % | — *(cerrada el 11-ago con la cita de arquitectura 3-DOF)* |
| 5.2 Instrumentación | 🟢 85 % | Resultado del piloto de iSen · fuente de `m_eje` |
| 5.3 Protocolo | 🔴 0 % | **Bloqueada por ética** |
| 5.4 Estadística | 🟢 100 % | — |
| Results | 🟡 15 % | **13-ago:** 4 tablas y figuras esqueleto listas (columnas ya definidas, sin valores). El contenido real sigue **bloqueado por datos** |
| Discussion | 🟡 25 % | **13-ago:** Limitations y Future Work redactados (no dependen de datos). Falta la interpretación de resultados (depende de datos) y el párrafo TRL ampliado |
| Conclusion | 🔴 0 % | Depende de Results |
| Abstract (5 campos) | 🔴 0 % | Objective/Methods/Results/Conclusion/**Clinical impact** — el 5º campo, Impact Statement, ya está |
| **Impact Statement** | 🟢 100 % | — *(cerrado 13-ago-2026, ver T-1: texto en `manuscrito_JTEHM.tex`, falta solo pegarlo en Overleaf)* |

**O2 · Bibliografía — 90 %**

9 de 10 entradas verificadas `[OK]`. **13-ago:** las 4 de métodos estadísticos (Koo & Li, Nichols & Holmes, Pataky, ISO 5725) también verificadas — coinciden exactamente con lo ya anotado. **15-ago:** decisión de edición de ISO 5725 cerrada (P-14) — se cita 2023, no la 1994 retirada.

Única deuda que queda: **falta leer R4 completo**. (De Raeve, resumen de congreso débil, se cerró el 13-ago — sin reemplazo de artículo completo disponible en el campo, se refuerza citándola junto a Etoundi2022 en la misma cláusula.)

**O3 · Herramientas — 85 %**

| Carpeta | Estado |
|---|---|
| `VALIDACIONES/` | 🟢 Referencia intacta + `Calcular_Metricas_Curva.m` extraído |
| `CALIBRACION/` | 🟢 Validado con datos sintéticos, recupera la verdad conocida en IC95 % |
| `ESTADISTICA/` | 🟢 Validado, 7/7 PASS en MATLAB R2025b |
| `MULTISUJETO/` | 🟢 Construido y probado — **7/7 PASS confirmado 13-ago** |
| Pruebas de equivalencia (TOST) | 🟡 **13-ago:** `TOST_Core.m` construido y con test sintético — candidato **B** |
| Potencia a priori por simulación | 🟡 **13-ago:** `PotenciaApriori_Core.m` construido y con test sintético — candidato **A**. Advertencia importante en su guía: usa la variabilidad de un solo sujeto como proxy de variabilidad entre sujetos, recalcular con datos reales |
| Presupuesto de incertidumbre GUM/ISO 5725 | 🟡 **16-ago:** `PresupuestoIncertidumbre_Core.m` construido y con test sintético — candidato **E**. Genérico, listo para usar en cuanto se decida qué cifra de Piche 2022 (rodilla/tobillo/cadera) anclar como componente de instrumento (ver P-18) |

**O4 · Datos — 10 %**

Lo único empírico que existe hoy: los 6 trials válidos de Fz del simulador (pico medio **157.3 %BW**, SD 5.8) contra la referencia real del proyecto (98.83 / 104.88 %BW) → **RMSEnorm = 21.1**. Es la cifra que motiva toda la corrección de Fz, y es defendible con caveats. Todo lo demás — recaptura de la referencia, 15-20 sujetos nuevos, logs de encoder, calibración de offset — está en cero.

**O5 · Bloqueos — 30 %** *(actualizado 11-ago)*

| Bloqueo | Estado | Bloquea |
|---|---|---|
| Integración Raspberry Pi–ESP32 | 🟡 **Interfaz y pantalla instaladas. Falta integrar con ESP32, ~2 semanas** | **Todo lo que mueva el simulador**: comparaciones 3, 4 y media de 5 |
| Aprobación de ética | 🟡 **Protocolo redactado, en revisión del asesor. Comité: 18-ago-2026** | Cualquier captura: comparaciones 3, 4, 6 y la recaptura |
| Piloto de iSen | 🟡 **Ángulo tibial ya limpio (pipeline Python de un compañero). Falta desplazamiento X,Y** | Cierra la nota técnica de `CLAUDE.md` — define si hace falta el plan B de dos IMU |

**O6 · JTEHM — 40 %**

🟢 Plantilla correcta (clase `IEEEJERM`, verificada contra el archivo oficial) · 🟢 Guía de autor documentada · 🔴 Abstract (4 de 5 campos) · 🟢 Impact Statement *(cerrado 13-ago)* · 🔴 Límite de 8 págs sin medir (no se ha compilado nunca) · 🟡 Autoría, CRediT y declaraciones *(corresponding author cerrado, roles CRediT en borrador aparte — 13-ago — falta el resto de autores)*.

---

## 2 · Reglas de trabajo — esto es lo que nos limita

Salen de decisiones ya tomadas. **No se reabren sin una razón fuerte y nueva.**

1. **Ninguna cita se fija sin verificarla contra la fuente.** No es un trámite: en dos rondas de verificación, **6 de 6** citas identificadas por búsqueda tenían algún error — un título equivocado, un resumen de suplemento confundido con artículo, un congreso confundido con revista, un sistema IMU distinto del supuesto, **un DOI inventado por el buscador a partir del patrón de la URL**, y una revisión entera que era de otro tema.
2. **8 páginas es techo duro, incluyendo referencias.** Es el límite más estricto de todas las revistas que se evaluaron. Cada párrafo que se añada hay que pagarlo. **Todavía no se ha compilado nunca** — no sabemos cuánto sobra.
3. **No completar los `[PENDIENTE]` con supuestos.** Cada uno depende de un dato o una decisión de equipo abierta. Un `[PENDIENTE]` visible es infinitamente mejor que un número inventado que después nadie recuerda que era inventado.
4. **Nada que dependa de ética se ejecuta antes de la aprobación.** Ni con "un solo sujeto de prueba", ni "informalmente". La prueba piloto de software con una persona ajena al estudio no cuenta como dato de investigación — y ese es el único hueco.
5. **No se adelanta contenido del generador de trayectorias** (artículo 2, 2027, IEEE TNSRE). Canibaliza su contribución central, no cabe en 8 páginas, y diluye la afirmación de este. Mencionarlo en trabajo futuro es suficiente y ya está previsto.
6. **Este artículo no menciona ni cita el paper de conferencia IBITeC 2026.** No estará publicado al momento del envío; reusar ese dataset antes de que sea público es riesgo de superposición de publicación.
7. **Fuera de alcance, cerrado:** Kinovea · el IMU de Alessandro · concordancia entre instrumentos (Bland-Altman) · caracterización de rigidez de la prótesis · lazo cerrado o generación algorítmica de trayectorias.
8. **Convención de ángulo, sin excepciones:** `atan2`, positivo por encima de la horizontal, negativo por debajo. Cualquier ángulo nuevo se calcula así o no es comparable con lo que ya existe.
9. **Los ` ``` ` son solo casillas de respuesta tuyas.** Nunca para encajonar texto explicativo.
10. **Al reorganizar documentos no se borran explicaciones.** Se conservan para consultar después.
11. **Toda literatura o hallazgo relevante se documenta en un `.md`** de la carpeta de `docs/` que le toque por tema — no se deja solo en el chat.

### ⚠️ Tensión real que conviene tener presente

La regla 2 (8 páginas) choca de frente con lo que todavía falta escribir: **Results, Discussion, Conclusion, Abstract y el Impact Statement no existen**, y la Introducción ya está redactada al 80 %. Cuando lleguen los datos, el espacio va a faltar, y la Introducción es la primera candidata a recortar — está marcada así en el `.tex`.

**Consecuencia práctica:** no invertir esfuerzo en pulir prosa de la Introducción hasta haber compilado una vez y saber cuánto espacio hay de verdad. Medir > estimar.

---

## 3 · Qué tenemos y qué falta — lectura honesta

### Lo que está sólido

- **Las herramientas están construidas y probadas antes de tener los datos.** Eso es lo contrario de lo habitual y es una ventaja real: cuando lleguen los sujetos, el análisis es correr un script, no diseñarlo.
- **La instrumentación ya no es un flanco débil.** Con Piche 2022 confirmado, existe **la** validación publicada del sistema exacto que usa el proyecto — y el propio artículo dice que no había ninguna otra. La decisión de no re-validar el instrumento está sostenida por literatura, no por conveniencia.
- **Hay una cifra defendible del problema que motiva el artículo**: 157.3 %BW frente a 98.83/104.88 %BW de referencia, RMSEnorm = 21.1.
- **La arquitectura de 3 DOF está justificada** por un grupo independiente, no por decisión propia.

### Lo que está frágil

- **El artículo depende casi por completo de dos cosas que no controlamos:** la integración RPi–ESP32 y el comité de ética. Sin ambas, las comparaciones 3, 4 y 6 no existen — y son el argumento central.
- **El envío de ética se pospuso por decisión del equipo** hasta después de las pruebas con los IMU. Eso retrasa la ruta crítica. Es la decisión de cronograma con más consecuencias del proyecto y conviene revisarla, no darla por hecha.
- **El vacío de literatura que sostiene la tesis se afirma por cuenta propia.** Se creía tener respaldo de tercero (la revisión de 2026) y resultó ser de otro tema. Lo más cercano que hay es Etoundi 2022, un banco diseñado desde la marcha de **un solo** amputado — que sirve como ejemplo de la práctica, pero no como "está documentado que el campo tiene este vacío".
- **Nunca se ha compilado el `.tex`.** No sabemos si cabe en 8 páginas ni si compila.
- **Riesgo de encaje editorial:** JTEHM declara preferencia por TRL 5-9 y dice textualmente que su *poor fit* es *"lab validation without clinical context"*. Este artículo, tal como está planteado, es validación de banco en laboratorio. Se identificó cómo corregir el encuadre sin tocar el diseño experimental, pero **todavía no está escrito**.

### Lo que se puede hacer sin que caiga ningún bloqueo

En orden de valor:

1. **Impact Statement + posicionamiento TRL** — obligatorio, y neutraliza el riesgo de encaje editorial. *(P-2)*
2. **Decidir candidatos A, B y F** (potencia a priori, pruebas de equivalencia, preregistro). Las tres **pierden todo su valor si se deciden después de tener los datos** — y ahora mismo no hay ni un dato. La ventana está abierta y se cierra sola. *(P-3)*
3. **Compilar el `.tex` una vez** y medir el espacio real.
4. **Correr `Test_Procesar_Multisujeto.m`** y confirmar 7/7 PASS.
5. Esqueleto de la sección de limitaciones de Discussion — no depende de datos.
6. Buscar reemplazo de la cita débil, o eliminar esa frase.

---

## 4 · Preguntas abiertas

*(P-1 a P-7 de la ronda del 11-ago quedaron todas cerradas o interpretadas — ver §5. Las dejo aquí mismo, sin mover el texto, para no perder el hilo de la conversación; el estado ✅/🟡 en el encabezado de cada una ya lo dice todo. Nuevas preguntas se agregan al final de esta sección.)*

### P-1 · Estado real de los tres bloqueos ✅ CERRADA

El tablero los da por no resueltos porque la última información es del 05-ago y han pasado seis días. Antes de planificar nada necesito el estado real — **de esto depende si el artículo va por el camino planeado o por el plan B**.

1. **Integración Raspberry Pi–ESP32:** ¿avanzó algo? ¿Hay fecha estimada?
2. **Ética:** ¿se envió el protocolo, o sigue pospuesto?
3. **Piloto de iSen:** ¿ya se corrió? Y la pregunta concreta: **¿el software expone la orientación cruda (quaternion/Euler sin calibrar a T-pose), o solo el ángulo articular del protocolo de marcha por defecto?**

Sobre el punto 3 hay un dato nuevo de hoy que ayuda: en Piche 2022 usaron **11 IMU con el modelo "Lower body (with heels) plus spine" del software de iSen**, o sea la vía de ángulo articular calibrado, no orientación cruda. No responde la pregunta, pero confirma que esa vía funciona y está validada.

```
✍️ TU RESPUESTA
La integración de la raspberry se pudo avanzar , el interfaz está finalizado e instalado la pantlla en el simulador. Falta integrarlo con el esp32, eso creo que dos semanas más.
el protocolo de ética está redactado, actualmente se encuentra en revision por mi profesor ya que el 18 de agosto recien es el comité. 
El isen ya se usó para probar, se pudo obtener los angulos de manera limpia y actualmente se esta analizando los mismos datos crudos para obtener los desplazamiento pero el angulo de inllicancin tibial  ya se pudo obtener, obvio el isen solo nos da datos crudos YA CON UN python que hizo un companero CALCULA Y SEGMENTa EN angulo de inclinacion por ciclo de marcha , una vez que mi companero logre obtener lo de las posiciones ya subo su avance a este proyecto par que lo puedas mejorar.

```

✅ **CERRADA 11-ago-2026.** Los tres bloqueos tienen estado real y ninguno está tan parado como parecía:

- **RPi–ESP32:** interfaz y pantalla ya instaladas en el simulador. Falta solo la integración con el ESP32, estimado **~2 semanas**. Es un avance real, no arranca de cero.
- **Ética:** protocolo redactado y **en revisión del asesor**, comité el **18-ago-2026**. Deja de ser "pospuesto sin fecha" — ahora es una fecha concreta, a una semana.
- **iSen:** el ángulo de inclinación tibial **ya se obtiene limpio**, con un pipeline en Python de un compañero que calcula y segmenta el ángulo por ciclo de marcha a partir de los datos crudos. Falta cerrar el desplazamiento (posición X,Y) — que es justo el criterio que definía el piloto en `CLAUDE.md` (error de distancia <10-15%, sin deriva visible). **En cuanto el compañero cierre esa parte, se sube el código al proyecto.**

**Consecuencia directa:** el camino principal sigue vivo y con fecha. No hace falta activar ningún plan B todavía — ver P-7.

### P-2 · Impact Statement y encuadre TRL — ¿arrancamos? ✅ CERRADA (redacción cerrada en T-1, 13-ago)

Es la tarea desbloqueada de más valor: obligatoria (sin ella devuelven el envío sin revisar), no depende de ningún dato, y de paso ataca el riesgo de encaje editorial. Necesito dos cosas tuyas antes de redactar:

1. **Categoría del espectro clínico NIH.** Las opciones son *Early/Pre-Clinical Research*, *Clinical Research*, *Clinical Implementation* y *Public Health*. Mi lectura es que corresponde **Early/Pre-Clinical Research** — es lo que de verdad es, y declarar algo más alto es fácil de desmentir. El encuadre de "herramienta de pre-evaluación clínica" se sostiene en el *texto*, no forzando la categoría.
2. **Con qué se compara el beneficio.** El Impact Statement funciona si dice *reduce X*. Lo natural es tiempo/costo/riesgo de las pruebas con humanos durante el desarrollo de prótesis. **¿Tenemos algún número propio** — cuántas sesiones con sujetos se ahorran, cuánto dura una sesión — o hay que dejarlo cualitativo?

```
✍️ TU RESPUESTA

1. Si la caterogia que dices es totalmente aceptada en la revista entonces esa es la que mas nos conviene.
2. hay que investigas mas respecto a eso, para poder nutrir mas ese beneficio , buscalo en base a lo que tenemos. QUE beneficiaria , o como nosotros influimos, etc ,e tc 
```

🟡 **PARCIALMENTE CERRADA 11-ago-2026.**

1. **Confirmado: *Early/Pre-Clinical Research* es una de las 4 categorías oficiales de la plantilla real de JTEHM** (no una interpretación mía) — ver `manuscrito/guia_autor_JTEHM.md` §3. Queda fijada.
2. **Investigado.** No existe una cifra publicada de "esto reduce X% el costo/tiempo de pruebas con sujetos en desarrollo de prótesis" — búsqueda honesta, no la hay. Lo que sí hay, y sostiene el argumento sin inventar un número:
   - Sesiones de evaluación de marcha con usuarios de prótesis: **2-3 horas**, típicamente **10-15 ensayos por condición y velocidad**.
   - Protocolos de adaptación a un componente protésico nuevo se extienden **varios días**, porque la marcha cambia con la familiarización.
   - La fatiga del participante amputado es una **restricción de diseño explícita** en la literatura de marcha protésica — varios protocolos limitan deliberadamente la duración por eso.
   - **Nuestras propias citas ya verificadas lo dicen de forma directa:** el título de Sudeesh et al. 2024 es literalmente *"...to advance prosthesis development **with reduced reliance on human subject testing**"*, y Etoundi et al. 2022 construye su banco explícitamente para evitar cargar la iteración de diseño sobre un participante humano. No es una afirmación nueva que este artículo inventa — es la premisa ya establecida de la que parte, con dos citas propias.

   **Recomendación con esto:** el Impact Statement se redacta **cualitativo, no con una cifra inventada** — apoyado en que la iteración de diseño con sujeto humano implica sesiones largas, repetidas y con fatiga como limitante real (documentado), y que un banco de pruebas validado permite iterar sin esa carga. Ver el borrador en la Tarea T-1 de §7.

### P-3 · Candidatos A, B y F — hay que decidirlos AHORA o se pierden ✅ APROBADOS

Los tres solo valen si se deciden **antes** de recolectar datos. Hoy no hay ni un sujeto capturado, así que la ventana está abierta; se cierra el día que empiece la campaña.

| | Qué es | Esfuerzo | Si no se hace |
|---|---|---|---|
| **A** · Potencia a priori por simulación | Usar la variabilidad de las curvas existentes + el motor de permutación para decir *"con n=15 se detectan diferencias ≥ X° con potencia ≥ 80 %"* | ~1 sem | La defensa del tamaño de muestra sigue siendo argumental, no numérica |
| **B** · Pruebas de equivalencia (TOST) | Además de tests de diferencia, un umbral de equivalencia declarado a priori — el natural es la variabilidad intra-sujeto | ~2 sem | *"No encontramos diferencias significativas"* invita a la respuesta *"eso prueba falta de potencia, no equivalencia"* |
| **F** · Preregistro en OSF | Publicar el plan de análisis antes de recolectar | ~2 días | Se pierde una señal de rigor barata |

**Mi recomendación:** las tres, en ese orden. **B es la que más protege el argumento del artículo** — el manuscrito afirma que el simulador *reproduce* la marcha, y con n modesto los tests de diferencia van a salir no significativos; sin una prueba de equivalencia eso es indistinguible de falta de potencia, y un revisor de Q2 lo va a decir.

**El riesgo honesto de A:** puede revelar que n=15 no alcanza para lo que se quiere afirmar. Es mejor saberlo ahora que en la carta del revisor — pero es un resultado que hay que estar dispuesto a recibir.

```
✍️ TU RESPUESTA
Ok, puedo ampliar a 50 sujetos sin ningun problema

```

✅ **CERRADA 11-ago-2026 — A, B y F aprobados.** Leo la respuesta como luz verde a los tres (respondiste con capacidad de reclutamiento, que es exactamente el dato que hacía falta para que A sea útil). **Dato muy bueno para el análisis de potencia:** la capacidad real de reclutamiento no es 15-20, es **hasta 50 sujetos sin problema**. Cambia el marco de A — en vez de preguntar *"¿15 alcanza?"*, la pregunta correcta es *"¿cuántos hacen falta, dado que hasta 50 son viables?"*, que es una posición mucho más cómoda para defender el diseño ante un revisor.

✅ **Construido 13-ago-2026:** `CODIGOS/POTENCIA_EQUIVALENCIA/PotenciaApriori_Core.m` (candidato A) y `TOST_Core.m` (candidato B), con `Test_PotenciaApriori_TOST.m` (9 pruebas sintéticas) y `GUIA_INTERPRETACION.md`. Mismo patrón Core/Test/Guía que el resto de `CODIGOS/`. **Sin correr todavía en MATLAB/Octave por el usuario.** Ver `docs/codigos/INDICE_CODIGOS.md` §6 y la guía para la advertencia importante sobre la variabilidad usada hoy (de un solo sujeto, probablemente optimista).

### P-4 · El envío de ética — ¿se puede adelantar? ✅ CERRADA (sin objeto — ya adelantado)

El equipo decidió posponerlo hasta después de las pruebas con los IMU. **Es la decisión de cronograma con más consecuencias del proyecto:** ética bloquea las comparaciones 3, 4 y 6, o sea el argumento central. Con envío en setiembre y un comité que tarda lo que tarda, cada semana de retraso se paga entera.

La pregunta concreta: **¿el protocolo de ética necesita de verdad el resultado de las pruebas con IMU, o se puede enviar en paralelo?** `etica/comite_etica.md` ya tiene redactada la sección de instrumentación y datos. Si lo que falta es un detalle que se puede escribir de forma general, se gana un mes.

```
✍️ TU RESPUESTA
ya esta redactado, ya esta en revision el protoclo de etica, ya se confirmo que se puede obtener con los isen el angulo , solo faltaria cofirmar que se pueda obtener los desplazamientos. 

```

✅ **CERRADA 11-ago-2026 — misma respuesta que P-1.** El protocolo no esperaba el resultado completo del piloto para redactarse; ya está escrito y en revisión, con comité el 18-ago. La pregunta original ("¿se puede adelantar?") queda sin objeto: **ya está adelantado**, no pospuesto.

### P-5 · `m_eje` — de dónde sale la masa ✅ CERRADA

El equipo decidió no pesar el ensamblaje móvil por poco preciso. Eso deja sin alimentar el término de masa de la corrección inercial por eje. **Bloquea el cierre de 5.2.** Dos opciones:

- **(a) Estimarla desde el modelo CAD**, si el de Mecatrónica tiene propiedades de masa asignadas. Mejor resultado, pero depende de que el CAD las tenga de verdad — no de que exista el CAD.
- **(b) Renunciar al término inercial** y sostener la explicación de Fz solo con calibración de offset + fidelidad de seguimiento, declarándolo como limitación adicional.

**Lo que hay que entender de la opción (b):** no es "perder" el término. La explicación de Fz queda con dos fuentes cuantificadas en vez de tres, más el benchmark de literatura — sigue siendo cuantificada, que es lo que el argumento central promete. Es una limitación declarable, no un agujero.

**Pregunta previa que decide todo:** ¿el CAD de Mecatrónica tiene materiales/densidades asignados, o es solo geometría?

```
✍️ TU RESPUESTA
Medainte cad o pesarlo no lo veo optimo ya que la fuerza en el simulado ry el peso no se distribuye uniformemente,  lo que si habiamos quedado antes es poder proabr ciertas alturas y como esta se ve reflejada en la salida de Fz con la paltaforma de marcha y como esto se puede relacioanar, ya que el simulador EJECUTA LA TRAYECTORIA PERO puede comenzar desde cualqueir altura , entonces habiamso quedado que ibamos a jugar y e encotnrar la relacion de eso para encontrar lo optimo o el comportamiento , que sea lo mejor para la revista

```

🟡 **INTERPRETADA, no cerrada del todo — confirma esto antes de que lo vuelque a los archivos de almacenamiento.**

Así lo entiendo: **ni CAD ni pesaje, porque el peso del ensamblaje no se distribuye uniforme** (razón nueva y más sólida que "poco preciso", que era lo que decía `CLAUDE.md` hasta hoy — un CAD sin densidades reales por pieza tampoco arreglaría esa no-uniformidad). En su lugar, **se retoma el plan ya acordado antes**: barrer distintas alturas de arranque de la trayectoria y medir cómo cambia la Fz de salida contra la plataforma real, para encontrar la altura/comportamiento óptimo.

**Lo que esto significa para la estructura de 3 fuentes de error de `CLAUDE.md`:**

Esto **es exactamente el ítem (1)**, calibración del offset vertical inicial — la herramienta ya existe y está validada (`CODIGOS/CALIBRACION/`, `Calibracion_Offset_Core.m`), solo espera datos reales, bloqueada por la misma integración RPi-ESP32 de siempre.

Lo que **no queda claro todavía** es el destino del ítem (3), la corrección inercial por eje con masa desagregada por motor. Dos lecturas posibles de tu respuesta:

- **(i)** El ítem (3) se cae del todo, y el barrido de alturas del ítem (1) pasa a ser el argumento completo — la explicación de Fz queda en dos fuentes cuantificadas (offset + fidelidad de seguimiento) en vez de tres, declarando la ausencia del término inercial como limitación.
- **(ii)** El ítem (3) se mantiene como concepto, pero su "dato de masa" ya no se busca por CAD/pesaje sino que **se infiere indirectamente** del propio barrido de alturas (la curva altura→Fz contiene, de forma implícita, el efecto inercial además del de compresión de offset) — más difícil de aislar como término separado, pero no exige pesar nada.

**Mi lectura, salvo que corrijas:** es la (i). Es la más limpia, es defendible ante un revisor ("no distribución uniforme" es una razón técnica real, no una excusa), y no exige separar dos efectos mezclados en una sola curva. **Aplicado así en `ESTADO_Y_RUMBO.md` y `CLAUDE.md` — avísame si querías la (ii) y lo corrijo.**

**Re-preguntando esto directo, porque quedó a medias (13-ago):** ¿(i) o (ii)? Si no contestas nada, sigo tratando esto como (i) por defecto — pero prefiero que lo digas explícito antes de que 5.2 lo dé por cerrado en el `.tex`.

```
✍️ TU RESPUESTA
Osea de igual manera podemos combinarlo , osea encontramos la relacion de alturas o el offset con el el resultado. 
Pero tmb el ii me gusta de una manera ed inferirlo, o sea podemos obtener los resultados con los dideferntes offset y luego inferimos a que peso coportal representa eso o algo estoy estoy pensando
```

✅ **CERRADA 13-ago-2026 — combinación de (1) y (3), no una lectura pura.** El ítem (3) no se cae del todo (no es (i) puro) ni se calcula a priori con masa medida — se **infiere indirectamente del mismo barrido de alturas de offset del ítem (1)**. En la práctica: se corre la calibración de offset en varios puntos de altura de arranque, se mide la Fz resultante contra la plataforma real, y de esa curva altura→Fz se infiere qué parte del residuo (más allá de lo que explica la compresión de offset) es atribuible al efecto inercial. Los ítems (1) y (3) pasan a ser un solo ensayo empírico. Aplicado en `plan_trabajo_5_semanas_articulo_Q2.md` y `../CLAUDE.md`. Sigue esperando la misma integración RPi-ESP32.

### P-6 · Compilar el `.tex` — necesito que lo hagas tú ⬜ POSPUESTA A PROPÓSITO

No tengo acceso a tu Overleaf. La regla 2 dice que 8 páginas es techo duro y **nunca se ha compilado**, así que ahora mismo no sabemos ni si compila ni cuánto ocupa lo ya escrito.

Para subir a Overleaf hacen falta tres archivos de `manuscrito/JTEHM_LaTex_Template/`: **`manuscrito_JTEHM.tex`** (reemplaza el contenido de `JERM Demo.tex`), **`IEEEJERM.cls`** y **`references.bib`**. Sin los dos últimos no compila.

⚠️ **Si ya habías pegado una versión anterior, hay que resubir también el `.bib`** — hoy cambiaron tres claves de cita y las viejas quedarían en `[?]`.

Lo que necesito de vuelta: **cuántas páginas ocupa** con lo que hay ahora (Intro + Métodos 5.1-5.4, sin Results ni Discussion).

```
✍️ TU RESPUESTA
Esto aun hay que dejarlo para el final de analizar todo

```

### P-7 · Plan B si ética no llega a tiempo ✅ CERRADA

No es derrotismo, es que la respuesta cambia qué se escribe **ahora**. Si ética no llega, el artículo posible es de **caracterización del sistema**: corrección de Fz cuantificada en sus fuentes + fidelidad de seguimiento comandado-vs-encoder, sin sujetos nuevos. Es más débil que el planeado, pero no está vacío — y es el único contenido empírico que puede existir sin humanos.

La pregunta: **¿preparamos ese plan B en paralelo, o se apuesta todo al camino principal?** Prepararlo cuesta poco ahora (la mitad del contenido se solapa) y mucho en la última semana.

**Ojo:** ese plan B **también** necesita la integración RPi–ESP32. Sin ella no hay ni offset ni logs de encoder. Si el bloqueo real es el hardware y no el comité, el plan B no salva nada — por eso P-1 va primero.

```
✍️ TU RESPUESTA
No hayq eu preparr el plan en paralelo ya que se necesita siosi lo de etica , podemos pospoenr la entrega  la revista sin nigun problema , la entrega del quincena de setiembre era referencial pero puede extenderse de alguna manera considerable

```

✅ **CERRADA 11-ago-2026 — no se prepara plan B, y cambia una restricción de fondo del proyecto.** No hace falta un plan de respaldo porque el camino principal está avanzando con fecha real (comité 18-ago). Y algo más importante: **la quincena de setiembre era una fecha referencial, no dura — se puede extender de forma considerable.**

**Esto afloja la regla 2 de §2** (8 páginas siguen siendo techo duro de la revista, eso no cambia) pero relaja la presión de calendario que hasta hoy empujaba a recortar/adelantar contenido para llegar a tiempo con lo que hubiera. **Aplicado en `CLAUDE.md`** (sección "Objetivo inmediato y fecha límite") y en `ESTADO_Y_RUMBO.md` (encabezado).

### T-1 · Borrador de Impact Statement + posicionamiento TRL — para tu aprobación ✅ CERRADA

Sale de la investigación pedida en P-2.2. **Esto NO está aplicado al `.tex` todavía** — es un borrador para que lo apruebes, corrijas o rechaces antes de tocar el manuscrito.

**Impact Statement** (máx. 30 palabras, con categoría NIH):

> *Early/Pre-Clinical Research. A validated bench simulator lets prosthetic knee/ankle components be iterated and evaluated without the repeated, fatiguing human-subject sessions that gait-lab testing otherwise requires.*

*(29 palabras. Cuenta hecha a mano, verificar antes de fijar.)*

**Por qué está redactado así, y no con una cifra:** la investigación de P-2.2 no encontró ninguna cifra publicada de "% de tiempo/costo ahorrado" que se pueda citar honestamente — inventar una sería exactamente el tipo de error que ya nos costó caro con Neelen 2026. Lo que sí se sostiene, con literatura propia de por medio, es la premisa: sesiones de evaluación de marcha con usuarios de prótesis toman 2-3 horas con 10-15 ensayos por condición, la fatiga del participante es una restricción de diseño documentada, y **el título de Sudeesh 2024** (ya citado en el manuscrito) es literalmente sobre reducir esa dependencia.

**Frase de posicionamiento TRL** (para Introducción o Discusión, reemplaza el `[PENDIENTE]` ya marcado en el `.tex`):

> *"By replicating gait kinematics captured from human subjects who did not participate in its programming, the simulator functions as a pre-clinical evaluation bench at TRL 5--6, positioned to accelerate prosthetic component iteration ahead of, and in support of, in-clinic assessment."*

**Qué necesito de ti:** ✅ / ❌ / edición sobre estas dos piezas. Si apruebas, las aplico al `.tex` y muevo esta pregunta a §5.

```
✍️ TU RESPUESTA
Respecto al impacto statement, quita lo de la rodilla ya que nuestro simulador es trasntibial , nunca sobrepasa la rodilla. Y el adjetivo bench para el simulador pq lo pones? es correcto?
Respecto a la frase de posicionamiento TRL  creo que el obejtivo es orientar lo que tenemos hacia lo que se pide en la resvista entonces se podria decr de que si esta bien encaminado entonces esta bien 
```

✅ **CERRADA 13-ago-2026.**

- **Sobre "knee":** corregido. El Impact Statement ya no menciona rodilla — "prosthetic knee/ankle components" pasó a **"transtibial prosthetic components"**, que es lo correcto para un simulador que nunca cruza la rodilla.
- **Sobre "bench":** es correcto, se mantiene. Es el término estándar de ingeniería/TRL para un banco de pruebas de laboratorio ("bench-top validation", "bench simulator") — no tiene relación con mobiliario, es el mismo registro que usa la propia frase TRL ("pre-clinical evaluation bench"). Si en algún momento se prefiere, "testbed" es intercambiable sin cambiar el sentido.
- **Frase TRL:** aprobada tal cual, sin cambios — ya no mencionaba rodilla.

**Texto final aplicado en `manuscrito_JTEHM.tex`:**

> Impact Statement (25 palabras, categoría NIH Early/Pre-Clinical Research): *"A validated bench simulator lets transtibial prosthetic components be iterated and evaluated without the repeated, fatiguing human-subject sessions that gait-lab testing otherwise requires."*
>
> Frase TRL (cierre del primer párrafo de Introduction): *"By replicating gait kinematics captured from human subjects who did not participate in its programming, the simulator functions as a pre-clinical evaluation bench at TRL 5–6, positioned to accelerate prosthetic component iteration ahead of, and in support of, in-clinic assessment."*

Aplicado en `manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` (abstract + cierre de Introduction). Sigue pendiente subirlo a Overleaf junto con el resto (ligado a P-6, pospuesta a propósito).

### P-8 · Autoría, orden, afiliaciones y correo de correspondencia 🟡 PARCIAL (correo cerrado)

No depende de ningún bloqueo — se puede resolver hoy. El `.tex` tiene tres huecos reales:

- Cabecera de autores (línea ~90): `[PENDIENTE: nombres, afiliaciones y orden de autoria -- decidir con CRediT statement]`.
- Pie de página 1 (línea ~154): correo del autor de correspondencia.
- Pies de página 2 y 3 (líneas ~155-156): afiliación de cada coautor.

JTEHM pide además el CRediT statement (quién hizo qué: conceptualización, software, análisis formal, redacción, etc.) — no hace falta cerrarlo hoy, pero la lista de autores y su orden sí conviene tenerla antes de seguir escribiendo Discussion/Conclusion.

**Pregunta:** ¿lista completa de autores en el orden que van a figurar, afiliación de cada uno, y quién es el autor de correspondencia (con su correo)?

```
✍️ TU RESPUESTA
Hasta ahora tengo el mio , Luis Marcos Plasencia Janampa , luis.plasencia@upch.edu.pe  , los otros lados ya te lo dare cuando ya sea indispensable
```

🟡 **PARCIAL 13-ago-2026.** Luis Marcos Plasencia Janampa queda anotado como autor de correspondencia. **Un detalle a confirmar antes de fijarlo:** el correo que diste aquí es `luis.plasencia@upch.edu.pe` (dominio de Cayetano Heredia), pero el que tengo registrado de sesiones anteriores es `luis.plasencia@pucp.edu.pe` (dominio PUCP, la universidad del proyecto). No lo corrijo de oficio por si el de `@upch.edu.pe` es intencional (correo personal/alterno) — **¿cuál va en el manuscrito?** Resto de autores: pendiente, según dijiste.

```
✍️ TU RESPUESTA
si es luis.plasencia@pucp.edu.pe , me confundi
```

✅ **Correo cerrado 13-ago-2026:** `luis.plasencia@pucp.edu.pe` (el `@upch.edu.pe` fue una confusión). Aplicado en el pie de página 1 de `manuscrito_JTEHM.tex`. **Sigue abierto:** resto de autores (orden, afiliaciones, CRediT) — el usuario los dará cuando sea indispensable.

### P-9 · Membresía IEEE EMBS — ¿aplica el descuento del 20% en el APC? 🟡 SIN CONFIRMAR

`guia_autor_JTEHM.md` señala que si algún autor o el asesor tiene membresía IEEE EMBS, el APC baja de USD 2160 a cerca de USD 1728 (ahorro ~USD 432). Esfuerzo de confirmar: prácticamente cero.

**Pregunta:** ¿alguien del equipo o el asesor tiene membresía EMBS vigente?

```
✍️ TU RESPUESTA
Creo que si , creo que 2 autores si tienene , eso ya lo veremos dps , pero no tan confrimado ,
```

🟡 **SIN CONFIRMAR 13-ago-2026.** Queda anotado que posiblemente 2 autores tengan membresía EMBS, sin confirmar. No se aplica el descuento del APC hasta que se confirme — se revisa más adelante, como dijiste.

### P-10 · Qué son realmente los archivos de `SIMULADOR/FUERZA GRF - SIM/` ✅ CERRADA

Es la única cifra empírica que sostiene hoy el argumento central del artículo: pico medio de Fz del simulador **157.3 %BW** (SD 5.8, n=6 trials) contra la referencia real del proyecto (98.83/104.88 %BW), RMSEnorm = 21.1. Es la cifra que motiva toda la corrección de Fz. Pero quedaron dos caveats sin cerrar desde la sesión del 03-ago (`CLAUDE.md`, sección de esa fecha):

1. **¿El peso corporal usado (86 kg) es el real de esa tanda de trials**, o es un supuesto?
2. **¿Esos 7 archivos (6 válidos) son efectivamente marcha simulada** — la trayectoria de marcha reproducida por el simulador — **o una prueba de carga/rampa con otro propósito** que se está interpretando como marcha por error?

Antes de citar esta cifra en Resultados como el dato que motiva la corrección de Fz, necesito que la confirmes — es la base numérica de la sección más citable del artículo hasta ahora.

```
✍️ TU RESPUESTA
Los datos dentro de esa capreta son los .txt obtenidos por el simulador EN LAS pruebas , el preso de 86 fue para procesarlo y normalizalro a ese %BW pero lo de los .txt no estan nronalziados es el crudo que salio. 
Los archivso validos son las graficas de fuerza cruda obtenida mediante la platafroma AMTI , ESO SE ira ampliando dps de que el comite de etica apruebe 
```

✅ **CERRADA 13-ago-2026.** Confirmado: son `.txt` crudos (sin normalizar) de fuerza, obtenidos por el simulador durante sus propias pruebas, medidos con la plataforma AMTI real — no una prueba de carga/rampa de otro propósito. El 86 kg se usó solo en el procesamiento (normalización a %BW), no está en el archivo crudo. **Detalle menor sin cerrar del todo:** la respuesta confirma que se usó 86 kg para normalizar, pero no confirma explícitamente si 86 kg es el peso corporal real medido de esa tanda o un supuesto — se mantiene como caveat menor de la cifra 157.3%BW hasta que se confirme. El dataset se amplía después de que el comité de ética apruebe.

### P-11 · Cita débil De Raeve 2014 (R2) — ¿reemplazo o se elimina la frase? ✅ CERRADA

`referencias_verificadas.md` y `ESTADO_Y_RUMBO.md` la marcan como resumen de congreso de una página — cita débil para una revista IEEE. Está en el primer párrafo de Introduction (`manuscrito_JTEHM.tex`), cubriendo "robotic platforms used for prosthetic alignment and joint performance assessment". El reemplazo que se tenía en mente (Neelen 2026) cayó por error de categoría el 11-ago y no hay otro candidato identificado.

**Pregunta:** ¿prefieres que busque una cita de reemplazo (nueva búsqueda, con verificación completa antes de fijarla — regla 1 de §2), o que reescriba esa cláusula del párrafo para no depender de esta fuente?

```
✍️ TU RESPUESTA
si busca una cita mas fuerte o mas precisa o mejor.
```

✅ **CERRADA 13-ago-2026 — sin reemplazo disponible, se refuerza en vez de sustituir.** Búsqueda exhaustiva (varias consultas independientes, mismo resultado siempre): el grupo De Raeve/Muraru/Peeraer nunca publicó el artículo completo de este sistema, solo el resumen de congreso de una página. Tampoco apareció ningún otro grupo con un artículo completo sobre una plataforma robótica dedicada a *alineamiento* protésico (se descartó un candidato — sistema IMU de Han et al. 2024, *Sensors* — porque usa el robot solo para validar el sensor, no como plataforma de alineamiento). **Decisión: no se inventa ni se fuerza una cita tangencial.** Se mantiene De Raeve (describe correctamente lo que es) pero se cita junto a `Etoundi2022RoboticTestRig` — ya citado antes en el mismo párrafo, artículo completo revisado por pares — que refuerza la mitad de "joint performance assessment" de la afirmación; De Raeve sigue siendo la única fuente real para la mitad de "alignment". Aplicado en `manuscrito_JTEHM.tex`, `references.bib` y `referencias_verificadas.md`.

### P-12 · Alessandro — su fecha límite (12-ago) ya pasó, ¿qué se decidió? ✅ CERRADA

Quedó pendiente desde el 03-ago hablar con él sobre si la sesión de validación de su IMU contra el STT-IWS, y los temas 2/3 de su revisión bibliográfica (justificados originalmente por la comparación Kinovea/STT-IWS/su sensor, que ya no aplica a este artículo tras el pivote a instrumento único), siguen teniendo valor para su propio segundo artículo o se caen del todo por ahora. Su fecha límite era el 12-ago-2026 — ayer.

**Pregunta:** ¿hablaste con él? ¿Qué se decidió sobre esos dos temas y sobre esa sesión?

```
✍️ TU RESPUESTA
Alessandro ya termino su trabajo pero como no nos sirven mas , ya hay que olvidarlo
```

✅ **CERRADA 13-ago-2026.** Alessandro terminó su tarea, pero se descarta para este artículo — confirmado explícitamente. `docs/equipo/tarea_alessandro.md` marcada cerrada para este ciclo (contenido conservado por si sirve para su segundo artículo).

### P-13 · `Test_Procesar_Multisujeto.m` — ¿ya corrió en MATLAB? ✅ CERRADA

Pendiente desde el 03-ago-2026: correr el test sintético de `CODIGOS/MULTISUJETO/` y confirmar que las 7 pruebas (recuperación de un sesgo conocido de +2°, detección de un corrimiento de grupo, tiempo de ejecución con 20 sujetos × 10 ensayos) dan PASS, antes de usar esa carpeta con datos reales cuando lleguen los sujetos nuevos.

**Pregunta:** ¿ya lo corriste? Si sí, ¿dio 7/7 PASS o hubo algo raro que debería revisar?

```
✍️ TU RESPUESTA
la ultima vez que lo corri si decia 7/7 , si haras modifaciones me avisas para vovlerlo a probar
```

✅ **CERRADA 13-ago-2026.** 7/7 PASS confirmado. Si el código de `CODIGOS/MULTISUJETO/` se modifica, se avisa y se vuelve a correr antes de usarlo con datos reales.

### P-14 · ISO 5725-1:1994 está retirada — ¿citamos la 1994 o la 2023? ✅ CERRADA

Verificando las 4 citas de métodos estadísticos (13-ago), salió un hallazgo que no estaba en el radar: la edición de la norma ISO 5725 que se venía citando, **1994**, figura en iso.org como **retirada** — la vigente es **ISO 5725-1:2023**. El contenido que se usa (vocabulario de trueness/precision, Parte 1) sigue siendo válido en ambas ediciones; el riesgo no es de fondo, es de forma: un revisor puede notar que se cita una norma retirada.

**Dos caminos:**
- **(a) Mantener 1994.** Es de acceso más común, sigue siendo la edición que la mayoría de artículos de biomecánica cita para este vocabulario, y el contenido no cambió de forma relevante para el uso que se le da aquí.
- **(b) Cambiar a 2023.** Es la vigente, cero riesgo de que un revisor lo note — pero no se ha verificado que el acceso/DOI de la 2023 esté disponible del mismo modo, ni que el texto de Parte 1 sea idéntico en fondo.

**Mi recomendación:** (b), cambiar a 2023 — es la versión correcta hoy y evita una objeción gratuita, con esfuerzo mínimo (una norma, no un artículo). Pero es tu decisión, no la aplico sin luz verde.

```
✍️ TU RESPUESTA
Si confirmo cierra el 2023
```

✅ **CERRADA 15-ago-2026.** Se cita **ISO 5725-1:2023**. Antes de decidir se confirmó que las dos ediciones hablan del mismo tema (mismo marco de trueness/precision; la 2023 es una revisión técnica de la 1994 — algunas definiciones retiradas, encuadre nuevo sobre condiciones/recursos para estudios de precisión, no un cambio de alcance), y que la 1994 está formalmente retirada en iso.org. Aplicado en `references.bib` (título, año y comentario de verificación actualizados; la clave de cita `ISO5725` no cambia, así que no hace falta tocar `manuscrito_JTEHM.tex`), `referencias_verificadas.md` y `literatura/normas_ISO_relevantes.md`.

---

## 4-bis · Auditoría 16-ago-2026 — qué encontré al verificar todo contra el disco

Pediste verificar si de verdad estamos en el porcentaje que muestra el tablero, y seguir avanzando en lo no bloqueado. Hice una pasada completa: releí este archivo entero y `ESTADO_Y_RUMBO.md`, y confirmé contra el disco que lo que dicen existe de verdad (no solo en la narrativa).

**Lo que se confirmó, existe tal como se describe:**
- `CODIGOS/POTENCIA_EQUIVALENCIA/` con sus 4 archivos (`PotenciaApriori_Core.m`, `TOST_Core.m`, `Test_PotenciaApriori_TOST.m`, `GUIA_INTERPRETACION.md`).
- `docs/planificacion/preregistro_OSF_borrador.md`, `docs/manuscrito/creditos_autoria_borrador.md`, `docs/equipo/tarea_alessandro.md`.
- El `.tex` tiene de verdad el Impact Statement, la frase TRL, el correo de correspondencia (`luis.plasencia@pucp.edu.pe`), las 4 tablas esqueleto de Results, y Limitations/Future Work redactados.

**Un hallazgo real, ya corregido — no era solo cosmético:** la subsección "Vertical Force Overestimation" de 5.2 en `manuscrito_JTEHM.tex` seguía describiendo el modelo **viejo de tres fuentes** ("axis-wise inertial correction, using the mass that actually accelerates...") con un comentario `% [PENDIENTE: fuente de m_eje sin resolver -- CAD vs. renunciar al termino]` — exactamente las dos opciones que P-5 **descartó** el 13-ago. La sección de **Limitations** (redactada el mismo 13-ago) sí tenía el modelo correcto de dos fuentes con inferencia indirecta — o sea que el `.tex` se contradecía a sí mismo entre 5.2 y Discussion. **Corregido ahora:** 5.2 reescrita al modelo de dos fuentes con inferencia indirecta (mismo lenguaje que ya usa Limitations), título de la subsección "Three-Stage" → "Two-Stage", comentario `PENDIENTE` reemplazado por uno `RESUELTO` que apunta a P-5. También estaba desactualizada la fila "Pesar el ensamblaje móvil del simulador" en `plan_trabajo_5_semanas_articulo_Q2.md` (Semana 1) — sigue diciendo "usar CAD si hay propiedades de masa asignadas", que ya no aplica; la marqué tachada como superada, sin borrarla (regla 10).

**Tarea 9 de `ESTADO_Y_RUMBO.md` §5 (búsqueda deliberada de revisiones de bancos robóticos de marcha) — ejecutada.** Dos búsquedas independientes más (16-ago, se suman a las del 11-ago) no encontraron ninguna revisión sistemática dedicada a bancos robóticos de marcha para prótesis — sí aparecieron simuladores individuales ya conocidos (Sudeesh 2024, Etoundi 2022, De Raeve 2014) y una revisión de 2024 en *IEEE Trans. Medical Robotics and Bionics* sobre prótesis robóticas de miembro inferior en general (no sobre bancos de prueba). **Segunda confirmación independiente del vacío** que sostiene la Limitation #5 ya redactada ("rests on a limited body... rather than a systematic review confirming the gap") — no cambia el texto, lo refuerza. Tarea 9 puede marcarse hecha.

**Conclusión honesta sobre el porcentaje:** el tablero (50% global) es razonablemente fiel a lo que hay en disco — no encontré contenido "fantasma" (nada que se reclame como construido y no exista). El único problema real era una inconsistencia interna entre dos secciones del `.tex` sobre una decisión ya cerrada, ya corregida. **O1 (Manuscrito, 5.2) sigue en 85%** — el fix es de consistencia, no agrega contenido nuevo.

---

## 4-ter · Preguntas nuevas (16-ago-2026)

*(Numeración continúa desde P-14. Todas son "las necesarias" — cosas que quedaron al aire o que hacen falta para seguir avanzando, no relleno.)*

### P-16 · Los 86 kg de la cifra 157.3%BW — ¿peso real medido, o supuesto? 🟡 ACLARADO, caveat menor se mantiene

```
✍️ TU RESPUESTA
o sea el .txt es el real medido, el %bw se convierte normalizandolo en matlab , pero el .txt crudo podemos obtener la fuerza real.
```

🟡 **ACLARADO 17-ago-2026, no cerrado del todo — y no hace falta que lo esté.** La respuesta confirma lo que ya se sabía (fuerza cruda real medida por el AMTI, %BW se calcula después en MATLAB), pero no confirma explícitamente si los **86 kg específicos** son el peso corporal real medido de esa tanda de sujetos o un valor de trabajo. **Por qué esto deja de ser bloqueante:** como el `.txt` guarda la fuerza cruda (no normalizada), el 157.3%BW se puede **recalcular** en cuanto se confirme el peso real — no hay que volver a medir nada, solo volver a dividir. Se mantiene como caveat menor explícito en la cifra (ya está anotado así en `CLAUDE.md` y `ESTADO_Y_RUMBO.md` §O4), sin bloquear su uso hoy como cifra motivadora del problema.

### P-17 · R4 (Sudeesh 2024) texto completo — link para acceso institucional ⬜

```
✍️ TU RESPUESTA
comparteme el link para ingresar y darte el pdf 
```

**Aquí está el link (17-ago-2026):**

> **DOI:** `10.1016/j.medengphy.2024.104254`
> **ScienceDirect:** https://www.sciencedirect.com/science/article/pii/S1350453324001553

**Cómo conseguir el PDF con tu acceso PUCP** (mismo patrón que ya funcionó con Piche 2022):
1. Entra a ese link **ya logueado en la red/VPN de PUCP**, o pasa primero por el proxy de la biblioteca PUCP (normalmente algo tipo `ezproxybib.pucp.edu.pe` antepuesto a la URL, o el buscador de la biblioteca virtual) — sin eso, ScienceDirect sigue devolviendo el 403 que ya se topó el 13-ago.
2. Una vez adentro, descarga el PDF y guárdalo en `docs/literatura/pdfs/` (ya existe esa carpeta, ahí está el de Piche 2022).
3. Dime cuando esté ahí, o pega el texto relevante directo aquí — lo que sea más rápido para ti.

**Lo que necesito confirmar puntualmente:** ¿el paper reporta validación con múltiples sujetos, o solo con el IPK y una trayectoria/sujeto de referencia? Sigue abierta hasta que llegue el PDF.

### P-18 · TOST: margen de equivalencia + tamaños de efecto para la potencia a priori ⬜

Candidatos A y B ya tienen código (`CODIGOS/POTENCIA_EQUIVALENCIA/`), pero no se pueden correr con sentido sobre datos reales sin dos decisiones que siguen abiertas (marcadas `[PENDIENTE]` también en `preregistro_OSF_borrador.md`):

1. **Margen de equivalencia de TOST** — el candidato natural, ya mencionado en P-3, es la **variabilidad intra-sujeto** (si la discrepancia simulador-vs-sujeto no supera lo que el sujeto varía consigo mismo entre pasadas, es indistinguible de su propio ruido). ¿confirmas ese criterio, o prefieres otro (p. ej. un umbral clínico/técnico fijo en grados o %BW)?
2. **Tamaños de efecto a simular en la potencia a priori** — ¿hay alguna diferencia mínima que el equipo considere clínicamente/técnicamente relevante detectar (en grados de ángulo, o en %BW de Fz), o prefieres que use un rango exploratorio basado en la variabilidad de las curvas que ya existen?

No es urgente hoy mismo, pero si se decide **antes** de la primera captura real (como A/B/F en general), el preregistro se puede publicar completo y el análisis de potencia da un N defendible en vez de un rango genérico.

```
✍️ TU RESPUESTA
1. O sea quiero que esa respuesta se encuentre dentro de una referencia o literatura 
2. Lo mismo con esto , no y estoy empapado de esta informacion asi que necesito nutrirme con mas informacion y poder dar una mejor respuesta.
```

🟡 **RESPALDO DE LITERATURA ENCONTRADO 17-ago-2026 — presentado para tu confirmación, no aplicado todavía (regla 1 de §2: ninguna cita se fija sin verificar, y ninguna decisión se aplica sin tu visto bueno).**

Hice dos búsquedas: una general de literatura de marcha (MDC/ICC de ángulos articulares, cualquier instrumento) y otra específica de TOST/márgenes de equivalencia en biomecánica. La general trajo valores dispersos (SEM<2.5°, MDC>5° en cadera, discrepancias de ±5-9° según la articulación y el instante del ciclo) de estudios con captura óptica convencional — no del instrumento de este proyecto, y sin verificar todavía a texto completo. **Encontré algo mejor, que ya tenemos verificado a texto completo dentro del propio proyecto:**

**Piche et al. 2022** (`Piche2022iSenValidity`, ya citada en 5.2 y confirmada sobre el PDF completo, `docs/literatura/pdfs/`) — es la validación del **instrumento exacto** de este artículo (iSen/STT-IWS) contra un sistema optoelectrónico, en la población de interés (marcha con prótesis transtibial). Reporta, por articulación:

| Articulación | RMSD | ICC |
|---|---|---|
| Rodilla | 3.3° | 0.93 |
| Tobillo | 5.6° | — |
| Cadera | 7.3° | 0.89 |

**Por qué esto es mejor anclaje que buscar un umbral MDC genérico de otro instrumento:** un margen de equivalencia dice, en el fondo, *"diferencias más chicas que esto son indistinguibles del ruido de mi propio proceso de medición"*. El RMSD de la validación del **propio instrumento** es exactamente esa cantidad — no hace falta ir a buscar un MDC de un sistema óptico distinto cuando ya existe, verificado, el número del sistema que de verdad se usa aquí. Es más defendible ante un revisor que cualquier cifra externa: *"el margen de equivalencia se fija en el RMSD de validación reportado del instrumento contra referencia óptica (Piche et al. 2022), la misma fuente ya citada para justificar el uso del instrumento en 5.2"*.

**Lo que falta para que esto sea aplicable, y es tu decisión, no la tomo por ti:** el simulador no mide un ángulo articular clínico (rodilla/tobillo/cadera entre dos segmentos) — mide la inclinación de una plataforma sobre la horizontal (convención atan2 del proyecto), geométricamente más parecido a un ángulo de segmento (shank/tibia) que a uno articular. Ninguna de las tres cifras de la tabla es una validación directa de "inclinación de plataforma". Se necesita elegir una analogía defendible y decirlo así en Métodos (p. ej. "se usa la cifra de tobillo, la articulación distal más próxima al segmento medido, con la limitación explícita de que no es una validación directa de ese ángulo específico").

**Con esto, mi recomendación concreta para las dos partes de P-18:**
1. **Margen de TOST:** usar el RMSD de Piche 2022 de la articulación que decidas (candidata natural: tobillo, 5.6°, por ser la más distal/próxima al segmento tibial) como margen simétrico `[-5.6°, +5.6°]`, en vez de (o además de) la variabilidad intra-sujeto ya calculable.
2. **Tamaños de efecto para la potencia a priori:** usar el mismo rango 3.3°-7.3° (las tres cifras de la tabla) como los "efectos" a simular en `PotenciaApriori_Core.m` — en vez de un rango arbitrario, quedan anclados a números de literatura ya verificados.

**Esta misma decisión (qué articulación de Piche 2022 usar) es la que también bloquea el uso real del candidato E recién construido** (ver P-19 en §5, y `CODIGOS/INCERTIDUMBRE/GUIA_INTERPRETACION.md` §6) — son la misma pregunta metodológica en dos lugares distintos. Conviene resolverla una sola vez.

**Tu decisión pendiente:** ¿tobillo (5.6°, mi recomendación por cercanía anatómica), rodilla (3.3°, la cifra con mejor ICC), o prefieres usar las tres y reportar un rango en vez de comprometerte a una? No se aplica a ningún archivo de almacenamiento (`references.bib`, el `.tex`, `GUIA_INTERPRETACION.md` de `POTENCIA_EQUIVALENCIA/` o `INCERTIDUMBRE/`) hasta que confirmes.

```
✍️ TU RESPUESTA

```

### P-19 · Candidato E (presupuesto de incertidumbre ISO 5725/GUM extendido a cinemática) — ¿evaluamos ahora? ✅ APROBADO Y CONSTRUIDO

```
✍️ TU RESPUESTA
si , no depende de nada , me gustaria ir avanzando en todo lo posible, ya que los datos reales van a demorar entonces , si avanzamos hasta que se obtenga los datos nuevos, una vez que los datos de interes y con el comite de eticaaprobado  encontramso una falla podemos solucionarlo rapidamente 
```

✅ **CERRADA 17-ago-2026 — construido el mismo día que se aprobó.** Ver §5 para el resumen; detalle completo en `CODIGOS/INCERTIDUMBRE/GUIA_INTERPRETACION.md`.

---

## 4-quater · CAMBIO RADICAL DE ENFOQUE — decisión de reunión de equipo (19-ago-2026)

**Lo que dijiste:** el equipo se reunió y decide un cambio de enfoque para el artículo: buscar bases de datos públicas, algoritmos/software y patrones ya publicados para generar la trayectoria de marcha que se quiera, integrarlo al simulador para que **él mismo genere su trayectoria** a partir de datos antropométricos (y otros), y validar el resultado contra **otras bases de datos públicas verificadas y más generales — no las que sirvieron para construir el algoritmo.**

**Esto no es una idea nueva — ya existe un análisis completo de exactamente esto**, guardado el 05-ago-2026 y deliberadamente mantenido **fuera** de este ciclo: `planificacion/analisis_escalamiento_Q1_generador_trayectorias.md`. Ese documento:

- Ya identificó 5 modelos publicados de generación de trayectorias desde antropometría (regresión, GPR, splines, LSTM — §4.1), y ya resolvió que adoptar uno sin reentrenar es lo correcto (evita el problema de "necesitamos 40-60 sujetos para entrenar").
- Ya resolvió **el mismo problema de circularidad que estás planteando ahora**: validar contra sujetos/datos que no se usaron para generar (§7.2, "sin circularidad") — es la misma exigencia que acabas de pedir con otras palabras.
- Ya identificó el hueco real de literatura tras revisar 3 precedentes cercanos (§4.2): *"no existe generación de trayectorias personalizada por antropometría, ejecutada físicamente en un banco de prótesis, y validada contra los sujetos individuales para los que fue personalizada."*
- Ya tiene compuertas go/no-go (G1-G6, §13.3) que se pueden resolver **sin un solo sujeto nuevo ni el simulador funcionando** — la más barata cuesta ~1 semana.
- Ya recomendaba **IEEE TNSRE** (Q1, mismo costo de APC que JTEHM, sin el límite de 8 páginas tan estricto) en vez de JTEHM para este contenido, precisamente porque no cabe en 8 páginas.
- Estimaba **9-12 meses de trabajo efectivo**, pensado como un **segundo artículo** que arranca después de cerrar este.

### Mi opinión, directa

La dirección técnica es sólida — no es un capricho, tiene un hueco de literatura real y un diseño experimental ya pensado con cuidado (incluida la parte de "sin circularidad" que pediste, que ya estaba resuelta). Y no se pierde el trabajo ya hecho: `MULTISUJETO/`, `ESTADISTICA/` (SPM1D), `POTENCIA_EQUIVALENCIA/` (TOST) sirven tal cual para esta línea también (§7.1 y §2.6 de ese documento lo dicen explícitamente).

**Pero "cambio radical" tiene que resolver tres tensiones concretas antes de que yo toque cualquier archivo de almacenamiento:**

1. **¿Esto reemplaza el artículo actual o lo absorbe como una parte?** Si se fusiona, el argumento central deja de ser "el simulador reproduce fielmente lo que se le graba" y pasa a ser "el simulador genera su propia trayectoria y esta iguala a sujetos reales que no participaron en generarla" — son afirmaciones distintas, no la misma con más datos. La fidelidad de seguimiento (comparaciones 3/4/6 actuales) pasaría a ser un **nivel de validación dentro del diseño nuevo** (nivel C del §7.1 de ese documento), no el resultado principal.
2. **¿Sigue siendo JTEHM (8 páginas, Q2) o cambia la revista?** Con este alcance (modelo + reducción cinemática §5 + validación en 3 niveles), 8 páginas se quedan cortas — es literalmente lo que ya se había concluido en agosto.
3. **¿Qué pasa con la fecha?** Ya no estamos hablando de "referencial, extensible" — estamos hablando de una escala de tiempo distinta. Prefiero que lo digas explícito ahora a que se vaya descubriendo en el camino.

### Preguntas necesarias — P-20

```
✍️ TU RESPUESTA
1. ¿Reemplaza al artículo actual, o el artículo actual se termina y envía tal cual, y esto es en verdad el "artículo 2" que ya estaba planeado (solo que ahora sí con fecha de arranque, no en 2027)?
si reempalzamos , ya que ya murio el protocolo , ya murio la toma de datos , ya murio la validacion con los isen , ahora es seguir lo que estba planeado de implementar el algoritmo al simulador y se comeienza eso desde ahora y se deja todo a aparte la cual esto afecta a todo lo que hemos estado trabajando sobre el articulo redacto hasta ahora , las referencias , todo en general hay que orientarlo.
2. Si reemplaza/absorbe: ¿seguimos en JTEHM con 8 páginas, o nos movemos a IEEE TNSRE (u otra) como ya recomendaba el análisis de agosto?
hay que primero ordnear mejors todas nuestras ideas para analizar si nos movemos a IEEE TNSRe uy otra si nuestra investigacion esta apta para una Q1 o Q2 o hacer todo lo necesariopara llegar Q1 con el nuevo enfoque que hemos encontrado 
3. ¿La fecha de envío sigue siendo "referencial, cuando sea" o el equipo ya tiene una nueva expectativa de cronograma con este alcance?
si , sigue siendo referenicual pero para maximo el 14 de seitiembr se tien que tener u buen avance en implemetnacion no finalizado todo 
4. Sobre "buscar bases de datos públicas, algoritmos/patrones": ¿ya tienen en mente algo puntual (un dataset, un paper, un método), o es tarea de investigación desde cero? El documento de agosto ya identificó 5 candidatos con parámetros publicados (§4.1) — ¿arrancamos de esa lista o el equipo quiere una búsqueda nueva?
no tengo nada en mente es lo que quiero dedicerl tiempo ene busqueda o sea analiza si podemos avanzalo en otro .md o actualziar lo que ya tenemos filtra todo lo de este proyecto , hayq ue buscar muchos y los necesarios .
5. Sobre "validar contra otras bases de datos públicas más generales, no las que sirvieron para el algoritmo": ¿el equipo ya tiene un dataset candidato para esto (ej. una base de marcha pública reconocida), o también es tarea de búsqueda?
no tenemos nada de base hasta ahroa pero idealmente pueda se base de datos de persoans peruanas o sudamericas para comparar mas que nada ya que el algoritmo al poner talla , peso , sexo ,  y entre otros datos es indpendientmente la region , ya una vez implementado eso se puede comprar con base de datos peruanas o sudadmenticas ya verifcas

```

**No aplico nada a `CLAUDE.md` ni a `ESTADO_Y_RUMBO.md` hasta tener esto** — son decisiones de fondo que cambian el argumento central, la revista y el cronograma del proyecto entero, exactamente el tipo de cosa que la regla de este documento pide discutir antes de aplicar.

✅ **CERRADA 19-ago-2026 — reemplazo total, no fusión.**

1. **Reemplaza por completo al artículo actual, no lo absorbe.** Palabras textuales: "ya murió el protocolo, ya murió la toma de datos, ya murió la validación con los iSen". El camino de fidelidad de seguimiento (comparaciones 3/4/6, protocolo de ética en revisión, piloto de iSen) queda abandonado como plan vigente — no se continúa. El contenido ya redactado (Introducción, 5.1-5.4, referencias, Impact Statement, etc.) **no se descarta**, pero **hay que reorientarlo** a la nueva línea, no darlo por válido tal cual.
2. **Revista: sin decidir.** Antes hay que "ordenar mejor las ideas" del nuevo enfoque y evaluar si el trabajo califica para Q1 (TNSRE u otra) o si conviene apuntar más conservador. No se fija ninguna revista todavía — **no se aplica ninguna plantilla nueva sin esta decisión**.
3. **Fecha: sigue referencial, pero con un checkpoint interno nuevo — 14-set-2026, "buen avance en implementación", no el artículo terminado.** Es una fecha de progreso, no de envío.
4. **Búsqueda del algoritmo/modelo: sin candidato fijo.** El equipo quiere dedicarle tiempo a la búsqueda — no arrancar directo de los 5 candidatos ya identificados en agosto sin más revisión. Pidió explícitamente que se evalúe si conviene actualizar `analisis_escalamiento_Q1_generador_trayectorias.md` (que ya trae esos 5) en vez de partir de cero en un documento nuevo, y que la búsqueda sea amplia ("muchos y los necesarios").
5. **Base de datos de validación: sin candidato.** Preferencia explícita: **bases de datos de marcha peruanas o sudamericanas verificadas**, ya que el argumento del equipo es que el algoritmo (entrada: talla, peso, sexo, etc.) es independiente de la región — comparar contra una población sudamericana refuerza esa independencia mejor que una base norteamericana/europea genérica. Tarea de búsqueda, nada identificado todavía.

**Consecuencia práctica para todo `docs/`:** `analisis_escalamiento_Q1_generador_trayectorias.md` deja de ser "análisis de consulta para el futuro, no mezclar" y pasa a ser **el plan vigente** de este ciclo. `CLAUDE.md` y `ESTADO_Y_RUMBO.md` necesitan una actualización de fondo, no un parche — ver el registro en §6 de qué se tocó y qué se conservó como historial superado (regla 10: no se borra, se marca superado).

---

## 4-quinquies · Resultado de la búsqueda del pivote (19-ago-2026)

Primera búsqueda tras P-20. Detalle completo en `planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` §4.1 (candidato nuevo) y §4.4 (bases de datos) — resumen aquí:

**Algoritmo — candidato nuevo, el más fuerte hasta ahora:** [Zhao et al. 2026, PLOS ONE](https://doi.org/10.1371/journal.pone.0338041). Entrada mínima (solo longitud de pierna, masa, cadencia — ni pide edad/sexo), salida completa (ángulos + momentos articulares + GRF, cubre cinemática y fuerza juntas), coeficientes y **código en GitHub**, y ya usa SPM1D para validar — el mismo motor que `CODIGOS/ESTADISTICA/` ya tiene construido. Dato colateral: [Karakish et al. 2022](https://doi.org/10.3390/s22218441) confirma que un modelo de este tamaño corre en un ESP32 (el mismo microcontrolador del banco) a 2.4 ms.

**Base de datos de validación — resultado honesto, no lo que se esperaba:** **no existe ninguna base de datos pública de marcha peruana o sudamericana** con antropometría, verificada. Búsqueda amplia en español e inglés, sin resultado. Alternativas reales: GaitRec (solo GRF, no sirve para trayectoria), Camargo/Georgia Tech (22 sanos, cinemática completa), y **Hood/Ishmael et al. 2020** (18 amputados transfemorales reales, cinemática/cinética completa) — este último es el más valioso porque es población protésica real, no sana, aunque no sea transtibial exacto ni regional.

### P-21 · Qué hacer con el vacío de base de datos regional ⬜

Tres caminos, y no los elijo por cuenta propia porque cambian qué tan fuerte queda el argumento de independencia regional del artículo:

- **(a) Capturar la base propia** con el iSen (ya disponible y probado) en un grupo de sujetos peruanos/sudamericanos — sostiene el criterio regional al 100%, pero es trabajo de campo nuevo (reclutamiento, captura), no una base ya existente.
- **(b) Usar Hood et al. 2020** (amputados transfemorales reales, EE.UU.) — no es regional, pero es población protésica real, que ataca el otro vacío señalado en agosto (§8: "todos los modelos están ajustados a sanos").
- **(c) Usar Camargo/Georgia Tech** (sanos, EE.UU.) — la opción más simple técnicamente, pero no aporta nada nuevo frente al vacío de "ajustado solo a sanos" y tampoco es regional.

```
✍️ TU RESPUESTA
 no hay que buscar estudios aunque sea que ppdamso comparar ya que usar los isen necesitamos protoclo de etica y no lo vamos a conseguir por arora
```

🟡 **INTERPRETADA, no cerrada del todo — confirma antes de fijarla.** Así la leo: **se descarta (a)** — capturar base propia con iSen — porque necesita protocolo de ética y no se va a conseguir por ahora (coherente con P-20: la ética queda abandonada como plan vigente). En su lugar, **hay que buscar entre estudios ya publicados algo con lo que sí podamos comparar** — o sea, se mantiene la línea de (b)/(c) y se sigue ampliando la búsqueda de datasets públicos en vez de cerrarse a uno solo todavía. Avísame si la lectura es al revés (que preferías no seguir buscando).

---

## 4-sexies · Aclaración de alcance + candidatos de algoritmo en secciones (20-ago-2026)

### P-22 · Cerrando la ambigüedad de una vez — CERO mediciones de personas, en cualquier nivel ⬜

Dijiste que estaba entendiendo mal dos cosas. Las fijo aquí, explícitas, para que no quede espacio a interpretación en ningún archivo:

1. **Cero mediciones o captura de personas reales, en ningún momento de este ciclo.** La validación es 100% contra bases de datos públicas ya existentes (Camargo 2021, GaitRec, Hood 2020, u otra que se decida) — no contra nadie capturado por el equipo. Esto es **más estricto** que lo que decía el análisis original de agosto, que incluía un "Nivel C" de validación física (ejecutar el algoritmo en el banco real y medir con iSen — sin sujeto humano, pero sí una medición del propio banco). **Pregunta puntual que sí necesito:** ¿ese Nivel C físico (banco + iSen, sin ninguna persona de por medio, no necesita ética) también queda fuera, o lo único que se descarta es medir personas? Cambia bastante si el artículo es 100% computacional (generar + comparar contra datos ya existentes, sin tocar el simulador físico) o si conserva una demostración física del banco ejecutando la trayectoria generada.
2. **El artículo original (fidelidad de seguimiento, JTEHM tal como estaba planteado el 17-ago) NO sigue en paralelo.** Ya estaba así de P-20 (reemplazo total, no fusión), lo reafirmo explícito porque puede que algún banner que escribí diera la impresión contraria. Hay **un solo artículo activo**: el de generación de trayectoria + validación contra bases de datos.

```
✍️ TU RESPUESTA

```

### Aclaración técnica (20-ago-2026) — no es una pregunta nueva, ya estaba resuelta en el diseño

Preguntaste: si no se encuentra una base de datos que ya tenga "la trayectoria del segmento tibial" lista, ¿se puede usar en cambio cualquier fuente/algoritmo que dé **posiciones de rodilla y tobillo**, y de ahí estimar la trayectoria tibial? **Sí, y de hecho es exactamente como ya está diseñado** — no hace falta un plan B, es el plan A:

- **Los 6 candidatos de algoritmo (abajo) YA predicen ángulos de cadera, rodilla y tobillo** — ninguno da "trayectoria tibial" directamente, todos dan ángulos articulares clásicos. Lo mismo pasa con **los 3 candidatos de base de datos de validación** (Camargo, GaitRec, Hood — cinemática articular estándar, no un ángulo de segmento).
- **La trayectoria del segmento tibial (lo que el simulador de verdad necesita, con la convención `atan2` del proyecto) se DERIVA de esos ángulos articulares**, no se busca ya hecha en ninguna parte. Esa derivación es exactamente la **"reducción a 3 DOF"** descrita en `analisis_escalamiento_Q1_generador_trayectorias.md` §5 — cinemática directa: ángulos articulares + longitudes de segmento del sujeto → posición/orientación del segmento tibial. Es, de hecho, **la contribución técnica propia más importante del artículo** (fila 2 del tablero §13, la que más define si esto es Q1 o Q2), no un cálculo secundario.
- **Consecuencia práctica:** esto amplía qué cuenta como candidato válido — cualquier algoritmo o base de datos que reporte ángulos articulares estándar de cadera/rodilla/tobillo sirve, sin necesidad de que ya venga en el formato exacto del simulador. No se descarta ningún candidato de los ya listados por este motivo — todos califican.

### Revista — pendiente de la respuesta de arriba

`analisis_escalamiento_Q1_generador_trayectorias.md` §11 recomendaba IEEE TNSRE asumiendo un diseño con validación física de 3 niveles (A/B/C). Si el alcance se reduce a **solo A y B** (numérico y de reducción cinemática, sin ejecutar nada en el banco), es un estudio más liviano — más rápido de completar, pero con un argumento de "aplicabilidad real" más débil ante un revisor de Q1 (todo queda en simulación, nada se demostró físicamente). Esa es exactamente la clase de objeción que un revisor Q1 hace primero. **Re-evalúo revista y qué tan cerca está de Q1/Q2 apenas cierres P-22.1** — no lo hago a ciegas porque la respuesta cambia el argumento completo, no solo el cronograma.

### Candidatos de algoritmo — una sección por candidato, para revisar uno por uno

Mismos 6 candidatos ya identificados y verificados (`analisis_escalamiento_Q1_generador_trayectorias.md` §4.1 y §4.5), reorganizados en secciones individuales como pediste. Cada uno tiene mi lectura y un espacio para tu respuesta — no hace falta responder los seis de una sentada, uno a la vez está bien.

#### Candidato 1 — Koopman, van Asseldonk & van der Kooij 2014 (*J Biomech* 47(6):1447-1458)

**Qué es:** splines quínticos ajustados entre eventos clave del ciclo de marcha, con regresión sobre velocidad + talla. Diseñado explícitamente para generar trayectorias de referencia en **soporte robótico de marcha** — no es un modelo genérico adaptado después, nació para este tipo de uso.

**Por qué es mi recomendación de partida:** de los seis, es el que tiene evidencia de adopción más sólida (87 citas, 8 influyentes, y el enfoque de "eventos clave por regresión" se reutiliza en robots de rehabilitación posteriores — línea LOPES/LOPES II). Entrada mínima (velocidad + talla), fácil de conseguir sin instrumentos especiales.

**Riesgo:** entrada muy simple (solo 2 parámetros) — puede que la personalización que produce sea débil frente a un revisor que pregunte "¿esto realmente distingue entre sujetos, o converge casi a la misma curva para todos?". El escalado geométrico por longitudes de segmento (§5 del análisis) ayuda a compensar esto en la salida final, no en el modelo en sí.

```
✍️ TU RESPUESTA

```

#### Candidato 2 — Yun, Kim, Shin, Lee, Deshpande & Kim 2014 (*J Biomech*, Gaussian Process Regression)

**Qué es:** GPR sobre 14 parámetros corporales, 113 sujetos, 14 movimientos articulares — el dataset de entrenamiento más grande de los seis. Entrega incertidumbre asociada a cada predicción (banda de confianza por punto del ciclo), no solo un valor puntual.

**Por qué podría convenir:** la incertidumbre explícita es una ventaja real para la validación — se puede comparar directo contra la banda ±1SD del sujeto real de la base de datos, una figura más fuerte que solo una curva media. También tiene adopción sólida (108 citas, 7 influyentes).

**Riesgo:** requiere 14 parámetros corporales — más trabajoso de reunir que Koopman (2) o Zhao (6), aunque siguen siendo medidas antropométricas estándar, no captura de marcha.

```
✍️ TU RESPUESTA

```

#### Candidato 3 — Moissenet, Leboeuf & Armand 2019 (*Scientific Reports*, regresión múltiple)

**Qué es:** regresión múltiple clásica desde velocidad, sexo, edad e IMC. El más simple de los seis de implementar y explicar — sin caja negra, coeficientes interpretables.

**Por qué podría convenir:** simplicidad. Si el argumento del artículo es "adoptamos un método publicado, no inventamos uno", un modelo interpretable es más fácil de defender ante la pregunta "¿por qué funciona?" que una red neuronal.

**Riesgo:** de los tres con buena adopción (junto a 1 y 2), es el que tiene menos evidencia concreta de reúso por terceros en la verificación de ayer — 73 citas pero sin ejemplos puntuales confirmados de quién lo reutilizó.

```
✍️ TU RESPUESTA

```

#### Candidato 4 — Semwal, Jain, Maheshwari & Khatwani 2023 (*MTAP*, LSTM+CNN)

**Qué es:** red neuronal (LSTM+CNN) entrenada con antropometría+velocidad, r=0.98 contra las curvas originales, validado en un rango de velocidad de 0.49–1.76 m/s — el rango más amplio reportado de los seis.

**Por qué podría convenir:** mejor ajuste numérico reportado (r=0.98) y el rango de velocidad más amplio, que le da más margen para cubrir la velocidad real de los sujetos de la base de datos de validación que se elija.

**Riesgo:** es una red neuronal — más difícil de justificar cada modificación ante un revisor ("¿por qué se ajustó así?") que un modelo de regresión o splines. Y es de un venue de cómputo (Multimedia Tools and Applications), no de biomecánica — puede pesar menos como respaldo metodológico en un artículo de ingeniería biomédica.

```
✍️ TU RESPUESTA

```

#### Candidato 5 — Xin, Li, Qin, Liu, Wang, Luo, Zhuang & Zhou 2025 (*Electronics*, GPR + series de Fourier)

**Qué es:** GPR combinado con series de Fourier, entrada: longitud de muslo, longitud de pierna, peso — pensado para personalizar trayectorias de exoesqueleto.

**Por qué podría convenir:** entrada de solo 3 parámetros, todos antropométricos directos (nada de velocidad ni edad/sexo), y el contexto de exoesqueleto es cercano al de un banco de prótesis (ambos accionan un miembro externo).

**Riesgo:** cero citas — es el más nuevo de los seis (2025) y sin ninguna evidencia de adopción todavía. Venue (MDPI *Electronics*) de menor peso relativo en biomecánica.

```
✍️ TU RESPUESTA

```

#### Candidato 6 — Zhao, Wei, Xie, Liu, Qu, Cao, Ding & Liao 2026 (*PLOS ONE*)

**Qué es:** el más nuevo, entrada mínima (solo longitud de pierna, masa, cadencia), salida más completa (ángulos + momentos articulares + GRF, cubre cinemática y fuerza a la vez). Código y coeficientes públicos en GitHub. Ya usa SPM1D para validar — el mismo motor que `CODIGOS/ESTADISTICA/` ya tiene construido y probado.

**Por qué podría convenir:** es el único que predice también GRF (retoma la línea de corrección de Fz del artículo anterior, si se quiere conservar algo de ese trabajo) y el más fácil de integrar con el código que ya existe en el proyecto.

**Riesgo:** cero citas por ser de 2026 — nadie más lo ha usado todavía, es la apuesta más nueva. Entrenado con solo 10 sujetos (validado con 4), la muestra más chica de entrenamiento de los seis.

```
✍️ TU RESPUESTA

```

**Mi orden de preferencia, si tuviera que recomendar uno hoy:** 1 (Koopman) por adopción y simplicidad, luego 6 (Zhao) por integración directa con el código ya construido y por cubrir Fz también, luego 2 (Yun/GPR) por la incertidumbre explícita. Pero es tu decisión y la del equipo — por eso están separados, para que cada uno se pueda aceptar, descartar o dejar en duda de forma independiente.

---

## 5 · Preguntas cerradas

*(Se conservan con su respuesta para no volver a abrirlas. Cuando una de §4 se cierra, baja aquí.)*

### P-1, P-4, P-7 — Estado de los tres bloqueos, ética y plazo (11-ago-2026)

RPi-ESP32 a ~2 semanas (interfaz y pantalla ya instaladas) · ética en revisión del asesor, comité 18-ago-2026 · iSen con ángulo tibial limpio, falta desplazamiento · **plazo de setiembre es referencial, se puede extender considerablemente** · no se prepara plan B, se apuesta al camino principal. Detalle completo en el cuerpo de cada pregunta arriba (no se resumen dos veces para no perder matices).

### P-2.1 — Categoría NIH del Impact Statement (11-ago-2026)

*Early/Pre-Clinical Research*, confirmada como una de las 4 categorías oficiales de la plantilla real de JTEHM. P-2.2 (redacción del contenido) sigue como T-1, pendiente de tu aprobación.

### P-3 — Candidatos A, B, F aprobados (11-ago-2026)

Los tres aprobados. Capacidad de reclutamiento hasta 50 sujetos, dato nuevo que cambia el marco del análisis de potencia (A). Construcción de código pendiente, no es trabajo de esta sesión.

### P-6 — Compilación del `.tex` pospuesta (11-ago-2026)

A propósito, hasta tener más avanzado el resto del contenido. No se insiste.

### T-1 — Impact Statement + frase TRL aprobados (13-ago-2026)

Impact Statement corregido (sin "knee", el simulador es transtibial) y aplicado al `.tex`; "bench" confirmado como término correcto (banco de pruebas, no mobiliario). Frase TRL aprobada sin cambios. Detalle completo arriba en §4.

### P-5 — `m_eje` combinado: se infiere del barrido de alturas de offset (13-ago-2026)

Ni CAD ni pesaje. El ítem (3) no se cae del todo ni se calcula a priori: se infiere indirectamente de la misma curva altura→Fz del ítem (1). Los dos ensayos se fusionan en uno. Aplicado en `plan_trabajo_5_semanas_articulo_Q2.md` y `../CLAUDE.md`.

### P-10 — Naturaleza de los archivos `SIMULADOR/FUERZA GRF - SIM/` confirmada (13-ago-2026)

Son `.txt` crudos de fuerza del simulador durante sus pruebas, medidos con AMTI real — no una prueba de carga/rampa distinta. 86 kg se usó para normalizar a %BW, no está en el archivo crudo. Queda un caveat menor: si 86 kg es el peso real medido o un supuesto, sin confirmar del todo.

### P-12 — Alessandro descartado del artículo (13-ago-2026)

Terminó su tarea, pero ya no se usa en este ciclo. `tarea_alessandro.md` marcada cerrada, contenido conservado por si sirve para su segundo artículo.

### P-13 — `Test_Procesar_Multisujeto.m` confirmado 7/7 PASS (13-ago-2026)

Confirmado por el usuario. Re-correr si el código cambia.

### P-8 (correo) — corresponding author cerrado (13-ago-2026)

`luis.plasencia@pucp.edu.pe` confirmado (el `@upch.edu.pe` fue una confusión). Aplicado en el pie de página 1 de `manuscrito_JTEHM.tex`. Resto de autores sigue pendiente.

### P-11 — Cita débil De Raeve 2014, sin reemplazo disponible (13-ago-2026)

Búsqueda exhaustiva no encontró artículo completo de reemplazo — el campo es genuinamente angosto aquí. Se mantiene De Raeve, citada junto a Etoundi2022 para reforzar la mitad de la afirmación que sí tiene respaldo fuerte. Aplicado en `manuscrito_JTEHM.tex`, `references.bib`, `referencias_verificadas.md`.

### P-14 — ISO 5725: se cita la edición 2023 (15-ago-2026)

Confirmado que 1994 y 2023 hablan del mismo tema (revisión técnica, no cambio de alcance); la 1994 está retirada en iso.org. `references.bib` actualizado a la edición 2023.

### P-15 — Chequeo de los 3 bloqueos, sin novedades (17-ago-2026)

RPi-ESP32 sigue sin integrarse (~25-ago estimado) · ética sin respuesta, comité era el 18-ago · iSen probando desplazamiento con datos crudos, sin cerrar. No cambia el rumbo (P-7 sigue vigente), pero el comité de ética pasa a vigilarse de cerca por haberse cumplido la fecha estimada sin confirmación.

### P-19 — Candidato E aprobado y construido (17-ago-2026)

`CODIGOS/INCERTIDUMBRE/PresupuestoIncertidumbre_Core.m` — presupuesto de incertidumbre GUM/ISO 5725 (ley de propagación de incertidumbre, Welch-Satterthwaite, factor de cobertura exacto), genérico, con `Test_PresupuestoIncertidumbre.m` (7 pruebas) y `GUIA_INTERPRETACION.md`. Sin correr todavía en MATLAB/Octave. Queda pendiente qué cifra de Piche 2022 usar como componente de instrumento — misma decisión que P-18, sin cerrar.

El historial de las decisiones anteriores a esta sesión está en `../CLAUDE.md` y en `ESTADO_Y_RUMBO.md`.

---

## 6 · Registro de decisiones aplicadas

Cada decisión cerrada aquí, con **dónde** se volcó. Esta tabla es el puente entre la discusión y el almacenamiento.

| Fecha | Decisión | Aplicada en |
|---|---|---|
| 11-ago | **Neelen 2026 descartada** — error de categoría (simuladores que viste una persona sana, no bancos robóticos) | `references.bib` (comentada, no borrada) · `referencias_verificadas.md` · `ESTADO_Y_RUMBO.md` §5-§6 · `metodos_introduccion_borrador.md` · `../CLAUDE.md` |
| 11-ago | **Arquitectura 3-DOF justificada con cita verificada** (Sudeesh 2024) — cierra el candidato C | `manuscrito_JTEHM.tex` §5.1 · `references.bib` |
| 11-ago | **Piche 2022 confirmada como LA validación de iSen/STT-IWS** — 5.2 pasa a afirmarlo directamente, con cifras | `manuscrito_JTEHM.tex` Intro + §5.2 · `references.bib` · `referencias_verificadas.md` §R7 · `validacion_instrumentos_IMU.md` |
| 11-ago | **Rattanakoch 2023 valida Noraxon, no iSen** — las dos citas se presentan como complementarias (una cubre instrumento, otra población) | `manuscrito_JTEHM.tex` §5.2 · `references.bib` · `referencias_verificadas.md` §R3 |
| 11-ago | **Claves de cita renombradas a Autor+Año** | `references.bib` · `manuscrito_JTEHM.tex` |
| 11-ago | **Aclarado: el simulador corre ~30x MÁS LENTO**, no más rápido (28.5 s de apoyo vs. 0.9459 s) | `referencias_verificadas.md` · `../CLAUDE.md` |
| 11-ago | **Estado real de los 3 bloqueos actualizado** — RPi-ESP32 ~2 sem, ética con comité 18-ago, iSen con ángulo confirmado | `ESTADO_Y_RUMBO.md` §3 · `../CLAUDE.md` |
| 11-ago | **Plazo de setiembre pasa de fecha dura a referencial, extensible** — no se activa plan B | `../CLAUDE.md` (Objetivo inmediato) · `ESTADO_Y_RUMBO.md` (encabezado) |
| 11-ago | **Categoría NIH del Impact Statement fijada:** Early/Pre-Clinical Research | `manuscrito_JTEHM.tex` (placeholder actualizado, contenido en T-1 pendiente de aprobación) |
| 11-ago | **Candidatos A (potencia a priori), B (TOST) y F (preregistro OSF) aprobados**; capacidad de reclutamiento hasta 50 sujetos | `ESTADO_Y_RUMBO.md` §6 |
| 11-ago | **`m_eje`: se descarta CAD/pesaje por distribución no uniforme; se retoma el barrido de alturas de offset** — interpretación pendiente de confirmar si el término inercial (3) se cae del todo | `ESTADO_Y_RUMBO.md` §1 (fórmulas de Fz) · `../CLAUDE.md` (decisión de corrección de Fz) — **pendiente de tu confirmación en P-5 antes de darlo por cerrado** |
| 13-ago | **Impact Statement + frase TRL aprobados** (T-1) — Impact Statement corregido sin "knee" (transtibial, nunca cruza la rodilla), "bench" confirmado correcto | `manuscrito_JTEHM.tex` (abstract + cierre de Introduction) · `ESTADO_Y_RUMBO.md` §5 · `../CLAUDE.md` |
| 13-ago | **`m_eje` (P-5) cerrado: combinación de (1) y (3)** — se infiere indirectamente del barrido de alturas de offset, en vez de caer del todo o medirse a priori | `plan_trabajo_5_semanas_articulo_Q2.md` (fórmula punto 3) · `../CLAUDE.md` · `ESTADO_Y_RUMBO.md` §5 |
| 13-ago | **Autoría (P-8), correo cerrado:** Luis Marcos Plasencia Janampa como corresponding author, `luis.plasencia@pucp.edu.pe` confirmado | `manuscrito_JTEHM.tex` (pie de página 1) · `ESTADO_Y_RUMBO.md` §5 · `../CLAUDE.md` — resto de autores sigue pendiente |
| 13-ago | **EMBS (P-9), sin confirmar:** posiblemente 2 autores, descuento de APC en espera | `../CLAUDE.md` |
| 13-ago | **Naturaleza de `SIMULADOR/FUERZA GRF - SIM/` confirmada (P-10):** `.txt` crudos del simulador, AMTI real, no prueba de carga distinta | `../CLAUDE.md` |
| 13-ago | **Cita débil De Raeve 2014 (P-11): sin reemplazo, se refuerza con Etoundi2022 en la misma cláusula** | `manuscrito_JTEHM.tex` · `references.bib` · `referencias_verificadas.md` · `../CLAUDE.md` |
| 13-ago | **4 citas de métodos estadísticos verificadas** (Koo & Li, Nichols & Holmes, Pataky, ISO 5725) — todas coinciden exactamente | `references.bib` · `referencias_verificadas.md` |
| 13-ago | **Hallazgo nuevo: ISO 5725-1:1994 está retirada** (vigente: 2023) — decisión de qué edición citar sin cerrar | `references.bib` (advertencia anotada) — **pendiente en P-14** |
| 15-ago | **P-14 cerrada: se cita ISO 5725-1:2023, no 1994** — mismo tema en ambas ediciones (revisión técnica, no cambio de alcance) | `references.bib` · `referencias_verificadas.md` · `literatura/normas_ISO_relevantes.md` |
| 13-ago | **Código de candidatos A y B construido** — `PotenciaApriori_Core.m`, `TOST_Core.m`, test sintético (9 pruebas), guía de interpretación | `CODIGOS/POTENCIA_EQUIVALENCIA/` (nueva carpeta) · `docs/codigos/INDICE_CODIGOS.md` · `ESTADO_Y_RUMBO.md` §6 — **sin correr todavía en MATLAB/Octave** |
| 13-ago | **Borrador de preregistro OSF (candidato F)** — hipótesis confirmatorias/exploratorias, plan de muestreo y análisis, con N y margen TOST en `[PENDIENTE]` hasta correr el código de A/B | `docs/planificacion/preregistro_OSF_borrador.md` (nuevo) — **borrador, no publicado en OSF** |
| 13-ago | **Discussion: subsecciones Limitations y Future Work redactadas** — 5 limitaciones que no dependen de datos (offset+seguimiento combinados, extrapolación de velocidad de iSen, sin validación cruzada este ciclo, potencia con proxy de variabilidad, vacío de literatura acotado) + trabajo futuro (lazo cerrado, IMU de Alessandro) | `manuscrito_JTEHM.tex` §Discussion — **borrador, falta la interpretación de resultados (depende de datos)** |
| 13-ago | **Results: 4 tablas esqueleto** (fidelidad por sujeto, representatividad, repetibilidad, Fz cruda/corregida/literatura) con columnas ya definidas contra la salida real de `MULTISUJETO/`/`POTENCIA_EQUIVALENCIA/`, y la fila de Fz ya disponible hoy (157.3%BW) | `manuscrito_JTEHM.tex` §Results — **estructura lista, valores bloqueados por datos** |
| 13-ago | **Borrador de roles CRediT** (14 roles de la taxonomía estándar, sin nombres salvo el corresponding author) — no se agregó sección nueva al `.tex` porque no está confirmado que JTEHM la pida ahí | `docs/manuscrito/creditos_autoria_borrador.md` (nuevo) |
| 13-ago | **R4 (Sudeesh 2024) texto completo — intentado, sigue bloqueado** por 403 de ScienceDirect sin acceso institucional | `referencias_verificadas.md` — **requiere acceso PUCP del usuario** |
| 13-ago | **Alessandro descartado del artículo (P-12)** — terminó su tarea, ya no se usa en este ciclo | `equipo/tarea_alessandro.md` (marcada cerrada) · `../CLAUDE.md` |
| 13-ago | **`Test_Procesar_Multisujeto.m` confirmado 7/7 PASS (P-13)** | `ESTADO_Y_RUMBO.md` §5 · `../CLAUDE.md` |
| 16-ago | **Auditoría del proyecto contra disco (§4-bis):** inconsistencia real encontrada y corregida — 5.2 del `.tex` seguía en el modelo viejo de 3 fuentes con `PENDIENTE` de m_eje ya descartado, mientras Discussion/Limitations ya tenía el modelo correcto de 2 fuentes. `.tex` alineado; fila obsoleta de "pesar el ensamblaje" tachada en `plan_trabajo_5_semanas_articulo_Q2.md` | `manuscrito_JTEHM.tex` §5.2 (Two-Stage, ya no Three-Stage) · `plan_trabajo_5_semanas_articulo_Q2.md` (Semana 1) |
| 16-ago | **Tarea 9 de `ESTADO_Y_RUMBO.md` §5 hecha:** segunda búsqueda independiente confirma que no existe revisión sistemática de bancos robóticos de marcha para prótesis — refuerza (sin cambiar) la Limitation #5 ya redactada | `ESTADO_Y_RUMBO.md` §5 (tarea 9 marcada hecha) |
| 16-ago | **5 preguntas nuevas abiertas (P-15 a P-19)** — chequeo de bloqueos (5 días después de P-1, comité de ética en 2 días), caveat de los 86 kg (P-10), R4 texto completo, margen TOST + tamaños de efecto de potencia, candidato E | `DISCUSION_Q2.md` §4-ter |
| 16-ago | **CRediT: verificado que la página oficial de "Instructions for Authors" de JTEHM no menciona ningún requisito de CRediT/Author Contributions** — no confirma el portal de envío, pero no hace falta reservar espacio en el `.tex` por ahora. Resuelto sin necesitar al usuario | `creditos_autoria_borrador.md` punto 1 |
| 17-ago | **P-15 cerrada: chequeo de los 3 bloqueos, sin cambios** — RPi-ESP32 sin integrar (~25-ago), ética sin respuesta (comité 18-ago), iSen probando desplazamiento. Comité de ética pasa a vigilar de cerca | `DISCUSION_Q2.md` §1 (tablero O5) |
| 17-ago | **P-16 aclarada, no cerrada del todo:** fuerza cruda confirmada real (AMTI), 86 kg no confirmado explícitamente como peso real — deja de ser bloqueante porque el `.txt` crudo permite recalcular %BW después | `../CLAUDE.md` (caveat ya anotado) · `ESTADO_Y_RUMBO.md` §O4 |
| 17-ago | **P-17: link de acceso a Sudeesh 2024 (R4) entregado** — DOI y URL de ScienceDirect, instrucciones de acceso PUCP. Sigue esperando el PDF | `DISCUSION_Q2.md` §4-ter |
| 17-ago | **P-18: respaldo de literatura encontrado para margen TOST y tamaños de efecto** — RMSD de Piche 2022 por articulación (rodilla 3.3°/tobillo 5.6°/cadera 7.3°), más fuerte que buscar un MDC externo porque es el instrumento exacto del proyecto. Decisión de qué articulación usar queda pendiente de tu confirmación — comparte pregunta con P-19/candidato E | `DISCUSION_Q2.md` §4-ter — **no aplicado a `references.bib` ni a las guías todavía** |
| 17-ago | **P-19 aprobada y candidato E construido el mismo día:** `PresupuestoIncertidumbre_Core.m` (GUM/ISO 5725, ley de propagación de incertidumbre, Welch-Satterthwaite, factor de cobertura exacto), `Test_PresupuestoIncertidumbre.m` (7 pruebas), `GUIA_INTERPRETACION.md` | `CODIGOS/INCERTIDUMBRE/` (nueva carpeta) · `docs/codigos/INDICE_CODIGOS.md` §7 · `ESTADO_Y_RUMBO.md` §6 — **sin correr todavía en MATLAB/Octave** |
| 19-ago | **P-20 — CAMBIO RADICAL: el artículo pasa de "fidelidad de seguimiento multi-sujeto" a "generación propia de trayectoria desde antropometría, validada contra bases de datos independientes".** Reemplazo total, no fusión — protocolo de ética, captura de sujetos e iSen quedan abandonados como plan vigente. Revista sin decidir (evaluar Q1/TNSRE vs. mantener Q2). Fecha sigue referencial, con checkpoint interno 14-set-2026 de "buen avance en implementación". Búsqueda de algoritmo y de base de datos de validación (preferencia: peruana/sudamericana) sin candidato fijo — tarea de investigación abierta | `analisis_escalamiento_Q1_generador_trayectorias.md` (pasa de "futuro, no mezclar" a plan vigente) · `../CLAUDE.md` y `ESTADO_Y_RUMBO.md` — **pendiente de actualización de fondo, ver tareas siguientes** |
| 19-ago | **Búsqueda del pivote — candidato de algoritmo nuevo (Zhao et al. 2026, entrada mínima + código público) y confirmación de que no existe base de datos de marcha peruana/sudamericana pública** — quedan 3 alternativas generales (GaitRec, Camargo, Hood et al. 2020 amputados), decisión de cuál usar pendiente en P-21 | `analisis_escalamiento_Q1_generador_trayectorias.md` §4.1 y §4.4 (nuevo) · `DISCUSION_Q2.md` §4-quinquies |
| 19-ago | **P-21 interpretada (no cerrada): se descarta capturar base propia (necesita ética), se sigue buscando entre estudios publicados.** Verificación de confiabilidad/adopción de los 9 candidatos (algoritmo + base de datos) contra Semantic Scholar y Crossref — **un error real encontrado y corregido: el DOI de GaitRec apuntaba a otro dataset**; los DOIs de J Biomech 2013/2014 resultaron correctos pese a que una primera pasada los marcó como erróneos (verificado dos veces antes de tocar el archivo). Candidatos con adopción más sólida: Koopman 2014 (algoritmo) y Camargo 2021 (base de datos, 329 citas) | `analisis_escalamiento_Q1_generador_trayectorias.md` §4.4 (DOI corregido) y §4.5 (nuevo, tabla de confiabilidad) |

---

## 7 · Acciones físicas pendientes — equipo, no Claude

- [ ] **Integración Raspberry Pi–ESP32** (Electrónica/Mecatrónica) — interfaz y pantalla listas, falta la integración final. **~2 semanas estimadas (11-ago).**
- [x] ~~Envío del protocolo de ética~~ — redactado, en revisión del asesor. **Comité: 18-ago-2026.**
- [ ] **Piloto de iSen**: ángulo tibial ya limpio. Falta cerrar el desplazamiento X,Y — el compañero sube el código en cuanto lo tenga.
- [ ] **Compilar el `.tex` en Overleaf** y reportar el número de páginas — pospuesto a propósito (P-6), no urgente.
- [x] ~~Correr `Test_Procesar_Multisujeto.m` en MATLAB~~ — **13-ago: 7/7 PASS confirmado.** Re-correr si el código cambia.
- [x] ~~Hablar con Alessandro~~ — **13-ago: terminó su tarea, se descarta para este artículo.** Ver `equipo/tarea_alessandro.md`.
- [x] ~~Confirmar qué representan los archivos de `SIMULADOR/FUERZA GRF - SIM/`~~ — **13-ago: `.txt` crudos del simulador, AMTI real, confirmado.**
- [ ] Decidir autoría, orden, CRediT y declaraciones — **13-ago, parcial:** Luis Marcos Plasencia Janampa como corresponding author, correo `luis.plasencia@pucp.edu.pe` confirmado y aplicado en el `.tex`. Resto de autores pendiente.
- [ ] Revisar si algún autor o el asesor tiene membresía EMBS — **13-ago:** posiblemente 2 autores, sin confirmar. 20 % de descuento sobre los USD 2160 del APC.
- [ ] **Nuevo (11-ago):** cuando el compañero suba el código de desplazamiento de iSen, revisarlo para integrarlo con lo ya construido en `CODIGOS/`.
- [x] ~~Aprobar o corregir el borrador de T-1 (Impact Statement + frase TRL)~~ — aprobado con corrección (13-ago), aplicado a `manuscrito_JTEHM.tex`. Falta solo pegarlo en Overleaf (junto con P-6).
- [x] ~~Confirmar la lectura (i) vs (ii) de P-5~~ — **13-ago: ninguna de las dos pura, combinadas.** Ver `plan_trabajo_5_semanas_articulo_Q2.md`.
- [x] ~~Buscar cita de reemplazo para De Raeve 2014 (R2)~~ — **13-ago: sin reemplazo disponible en el campo**, se refuerza citándola junto a Etoundi2022 en vez de sustituirla.
