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

## 1 · Tablero de avance

**Global del artículo: 50 %** · `██████████░░░░░░░░░░` *(actualizado 13-ago-2026, tras trabajo adelantado en lo no bloqueado: potencia/TOST, preregistro, Discussion, Results, CRediT)*

| # | Objetivo | Avance | |
|---|---|---|---|
| **O1** | **Manuscrito redactado** | `██████████░░░░░░░░░░` | **50 %** ▲ |
| **O2** | **Bibliografía verificada** | `██████████████████░░` | **90 %** |
| **O3** | **Herramientas de análisis** | `████████████████░░░░` | **80 %** ▲ |
| **O4** | **Datos empíricos** | `██░░░░░░░░░░░░░░░░░░` | **10 %** |
| **O5** | **Bloqueos externos levantados** | `██████░░░░░░░░░░░░░░` | **30 %** |
| **O6** | **Requisitos de JTEHM** | `████████░░░░░░░░░░░░` | **40 %** ▲ |

**Lo que hay que leer en este tablero:** O1, O2 y O3 subieron todos en la misma ronda (13-ago) porque son justo las tareas **desbloqueadas** — bibliografía verificada, código de potencia/TOST construido, Discussion/Results/CRediT con esqueleto. **El artículo no avanza más allá de ~60-65 % global hasta que los tres bloqueos de O5 caigan de verdad**, por mucho que se afine el resto — pero ya no son una incógnita, son una cuenta regresiva (RPi-ESP32 ~2 semanas, comité de ética 18-ago, desplazamiento X,Y de iSen en curso).

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

9 de 10 entradas verificadas `[OK]`. **13-ago:** las 4 de métodos estadísticos (Koo & Li, Nichols & Holmes, Pataky, ISO 5725) también verificadas — coinciden exactamente con lo ya anotado. Único hallazgo nuevo: **ISO 5725-1:1994 figura como retirada** en iso.org, la vigente es la edición 2023 — decisión pendiente en P-14.

Única deuda que queda: **falta leer R4 completo**. (De Raeve, resumen de congreso débil, se cerró el 13-ago — sin reemplazo de artículo completo disponible en el campo, se refuerza citándola junto a Etoundi2022 en la misma cláusula.)

**O3 · Herramientas — 80 %**

| Carpeta | Estado |
|---|---|
| `VALIDACIONES/` | 🟢 Referencia intacta + `Calcular_Metricas_Curva.m` extraído |
| `CALIBRACION/` | 🟢 Validado con datos sintéticos, recupera la verdad conocida en IC95 % |
| `ESTADISTICA/` | 🟢 Validado, 7/7 PASS en MATLAB R2025b |
| `MULTISUJETO/` | 🟢 Construido y probado — **7/7 PASS confirmado 13-ago** |
| Pruebas de equivalencia (TOST) | 🟡 **13-ago:** `TOST_Core.m` construido y con test sintético — candidato **B** |
| Potencia a priori por simulación | 🟡 **13-ago:** `PotenciaApriori_Core.m` construido y con test sintético — candidato **A**. Advertencia importante en su guía: usa la variabilidad de un solo sujeto como proxy de variabilidad entre sujetos, recalcular con datos reales |

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

### P-14 · ISO 5725-1:1994 está retirada — ¿citamos la 1994 o la 2023? ⬜

Verificando las 4 citas de métodos estadísticos (13-ago), salió un hallazgo que no estaba en el radar: la edición de la norma ISO 5725 que se venía citando, **1994**, figura en iso.org como **retirada** — la vigente es **ISO 5725-1:2023**. El contenido que se usa (vocabulario de trueness/precision, Parte 1) sigue siendo válido en ambas ediciones; el riesgo no es de fondo, es de forma: un revisor puede notar que se cita una norma retirada.

**Dos caminos:**
- **(a) Mantener 1994.** Es de acceso más común, sigue siendo la edición que la mayoría de artículos de biomecánica cita para este vocabulario, y el contenido no cambió de forma relevante para el uso que se le da aquí.
- **(b) Cambiar a 2023.** Es la vigente, cero riesgo de que un revisor lo note — pero no se ha verificado que el acceso/DOI de la 2023 esté disponible del mismo modo, ni que el texto de Parte 1 sea idéntico en fondo.

**Mi recomendación:** (b), cambiar a 2023 — es la versión correcta hoy y evita una objeción gratuita, con esfuerzo mínimo (una norma, no un artículo). Pero es tu decisión, no la aplico sin luz verde.

```
✍️ TU RESPUESTA

```

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
| 13-ago | **Código de candidatos A y B construido** — `PotenciaApriori_Core.m`, `TOST_Core.m`, test sintético (9 pruebas), guía de interpretación | `CODIGOS/POTENCIA_EQUIVALENCIA/` (nueva carpeta) · `docs/codigos/INDICE_CODIGOS.md` · `ESTADO_Y_RUMBO.md` §6 — **sin correr todavía en MATLAB/Octave** |
| 13-ago | **Borrador de preregistro OSF (candidato F)** — hipótesis confirmatorias/exploratorias, plan de muestreo y análisis, con N y margen TOST en `[PENDIENTE]` hasta correr el código de A/B | `docs/planificacion/preregistro_OSF_borrador.md` (nuevo) — **borrador, no publicado en OSF** |
| 13-ago | **Discussion: subsecciones Limitations y Future Work redactadas** — 5 limitaciones que no dependen de datos (offset+seguimiento combinados, extrapolación de velocidad de iSen, sin validación cruzada este ciclo, potencia con proxy de variabilidad, vacío de literatura acotado) + trabajo futuro (lazo cerrado, IMU de Alessandro) | `manuscrito_JTEHM.tex` §Discussion — **borrador, falta la interpretación de resultados (depende de datos)** |
| 13-ago | **Results: 4 tablas esqueleto** (fidelidad por sujeto, representatividad, repetibilidad, Fz cruda/corregida/literatura) con columnas ya definidas contra la salida real de `MULTISUJETO/`/`POTENCIA_EQUIVALENCIA/`, y la fila de Fz ya disponible hoy (157.3%BW) | `manuscrito_JTEHM.tex` §Results — **estructura lista, valores bloqueados por datos** |
| 13-ago | **Borrador de roles CRediT** (14 roles de la taxonomía estándar, sin nombres salvo el corresponding author) — no se agregó sección nueva al `.tex` porque no está confirmado que JTEHM la pida ahí | `docs/manuscrito/creditos_autoria_borrador.md` (nuevo) |
| 13-ago | **R4 (Sudeesh 2024) texto completo — intentado, sigue bloqueado** por 403 de ScienceDirect sin acceso institucional | `referencias_verificadas.md` — **requiere acceso PUCP del usuario** |
| 13-ago | **Alessandro descartado del artículo (P-12)** — terminó su tarea, ya no se usa en este ciclo | `equipo/tarea_alessandro.md` (marcada cerrada) · `../CLAUDE.md` |
| 13-ago | **`Test_Procesar_Multisujeto.m` confirmado 7/7 PASS (P-13)** | `ESTADO_Y_RUMBO.md` §5 · `../CLAUDE.md` |

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
