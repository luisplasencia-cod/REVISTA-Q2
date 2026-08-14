# Levantamiento de observaciones — Paper de conferencia IBITeC 2026

> **Este trabajo NO es el artículo Q2.** El `CLAUDE.md` de la raíz describe el artículo Q2 para JTEHM, que es un proyecto distinto. Cuando se trabaje en esta carpeta, **el contexto es este archivo**, no el de la raíz.

## 🔒 Regla de alcance — leer antes de cualquier cosa

Mientras la sesión sea sobre el paper de conferencia, **el trabajo se limita a `Articulo de conferencia/`**:

- **Se lee y se escribe solo dentro de esta carpeta.** Ningún archivo de fuera se modifica.
- **Nada del proyecto Q2 aplica aquí** — ni su revista, ni sus plazos, ni sus decisiones, ni su plan de 5 semanas, ni su bibliografía. Son dos artículos distintos. Si algo del Q2 parece relevante, **no se importa sin preguntar**.
- **No se mezclan los dos trabajos en una misma respuesta.** Si el usuario cambia de tema al Q2, se dice explícitamente que se está cambiando de proyecto.
- **Única excepción, solo de lectura:** los scripts de MATLAB y las bases de datos del repositorio (`CODIGOS/`, `REFERENCIAS/`, `SIMULADOR/`, `PERSONA SANA/`) se pueden **consultar** cuando una observación exige un dato real que solo está ahí — de ahí salió el hallazgo de las unidades del RMSE. Consultar sí; modificar no.

## Qué es

El paper de conferencia **"Simulation-Driven Design and Functional Assessment of a Gait Simulator for Transtibial Prosthesis Evaluation"** (Paper ID 1571326099, track *Human Motion and Rehabilitation Engineering*) fue **aceptado con observaciones**. Hay que levantar **15 observaciones** de 2 revisores y devolver: manuscrito corregido con lo añadido **resaltado en amarillo** (`\hl{}`) + carta de respuesta con `Author's response` y `Author's action` por comentario.

**Plazo:** 1 semana desde el 06-ago-2026; la asesora lo quiere antes.

## Estado al cerrar la sesión del 08-ago-2026

- ✔️ **REVISOR 1 CERRADO POR COMPLETO** (C1, C2a, C2b, C3, C4, C5). Aplicado en `articulo corregido.md` y documentado en `RESPUESTA_REVISORES.md`. Verificación cruzada: 14 cambios en el manuscrito, 14 documentados en la carta, 0 huecos.
- ✔️ **REVISOR 2, FASE 1 CERRADA:** R2-1, R2-9, **R2-2** y **R2-5** (este último adelantado desde la Fase 4 por decisión del usuario, para tocar la frase de la línea 221 una sola vez). Aplicado y documentado.
- ✔️ **REVISOR 2, FASE 2 CERRADA:** **R2-6** y **R2-10**. Aplicado y documentado.
- ✔️ **R2-7 — figura regenerada** (`codigos figura 5/fig5_revisada.png` + `.pdf`) con los cuatro sub-ítems. Carta escrita.
- ✔️ **R2-8 — resuelto DENTRO de la figura:** el panel (c) lleva un segundo eje vertical en **newtons** (en el panel y en su tira residual), así que la GRF se lee en las dos unidades **sin duplicar un solo número en el texto**. Carta escrita (la tabla de conversión que la acompañaba pasó a bloque interno el 10-ago, ver cuarta pasada más abajo).
- ✔️ **P3.2 — cerrado por decisión del usuario (09-ago):** se marcan **los dos máximos** de la curva del simulador (126.8 %BW @25 % y 157.4 %BW @45 %) y **la frase de la Discusión no se toca**. Razón del usuario: el revisor no objetó el doble pico, solo pidió mejorar la figura, y no hay que sembrarle dudas nuevas. Las etiquetas dan el **valor medido**, sin escribir "primer pico" ni afirmar el patrón. *(Quedó anotado en `DISCUSION_COMENTARIOS.md` que la prominencia de ese máximo es 0.34 %BW frente a 6.16–11.23 %BW de la referencia, por si el revisor pregunta en la segunda ronda — la respuesta está preparada. Decisión tomada, no reabrir.)*
- ✔️ **R2-3 y R2-4 aplicados.** Con eso **LAS 15 OBSERVACIONES ESTÁN REDACTADAS** — Revisor 1 (C1–C5) y Revisor 2 (1–10), manuscrito y carta.
- ✔️ **CABE EN 6 PÁGINAS.** `PDF_REVISAR (3).pdf` (10-ago-2026) compila en **6 páginas**, con la pág. 6 llena hasta y=718.4. Es el PDF vigente.
- ✔️ **Pasada de estilo sobre los 15 `Author's response` (10-ago-2026).** Reescritos más breves, naturales y fluidos, sin perder ni un dato ni una declaración (las tres desviaciones de R2-10, la nota de numeración de [22] en R2-3, la tabla de conversión de R2-8, etc. siguen todas). **Regla nueva del usuario, aplicada a toda la carta: nada de guiones largos (—) ni de dos puntos (:) dentro del texto de respuesta** — se reemplazan por conector ("ya que", "porque", "namely") o por frase nueva. Los guiones de palabra compuesta (*frontal-plane*, *Savitzky–Golay*) sí valen. Las tablas de `Author's action` y los bloques de texto original/revisado **no se tocaron**. ⚠️ Durante la sesión el archivo cambió en disco a mitad de las ediciones (R2-7 y R2-8 tenían una versión más larga que la leída al inicio) — **releer el archivo antes de editar si el usuario está trabajando en él en paralelo**.

- ✔️ **Lo eliminado ahora se muestra en la carta, no solo lo añadido (10-ago-2026, pedido del usuario).** Hasta ahora los bloques `*Original*` solo servían de contraste y el resaltado marcaba únicamente lo agregado, así que el revisor no podía comprobar qué se borró sin diffear a mano contra el PDF enviado. Tres cambios en `RESPUESTA_REVISORES.md`: (1) **convención nueva** declarada en el encabezado de la carta — en `*Original*` lo eliminado va **tachado** (`~~texto~~`), en `*Revised*` lo añadido va resaltado (`==texto==`); (2) **tachados aplicados en los 15 bloques** de texto original (R1-C1 ¶1/¶2/¶3/¶4, R1-C2 marcadores, R1-C4 ×2, R2-1 ref. [2], R2-2 frase de métodos + tabla de unidades, R2-6, R2-7 pie de figura, R2-9 *inter-repetition*, R2-10 ×3), incluidos los originales de los ¶3 y ¶4 de la Introducción que antes solo se resumían en una nota entre paréntesis; (3) **sección nueva `Summary of removed and condensed text` al final de la carta, que SÍ se envía** — dos tablas: las supresiones que responden a un comentario (con puntero al comentario) y **las 11 condensaciones por límite de página**, cada una con la columna de dónde sigue estando esa información. Es el Anexo A reducido a lo que el revisor necesita; el Anexo A completo (motivos internos, balances de palabras) sigue siendo interno. ⚠️ **Al pasar a Word/PDF hay que convertir el `~~tachado~~` en tachado real** (`\sout{}` de `ulem`, o formato Tachado en Word), igual que el `==` en resaltado amarillo. - ✔️ **Los cuadros de `Author's action` se eliminaron y pasaron a ítems (10-ago-2026, segunda pasada, pedido del usuario).** El disparador fueron los ítems 4 y 5 del R1-C1: existían solo como fila de tabla y como una nota entre paréntesis, sin mostrar ni el original ni el resultado, así que no se entendía qué se había hecho con los párrafos 3 y 4 de la Introducción. Ahora **los dos son ítems completos**, cada uno con su acción, su original tachado y su texto revisado — el ¶3 desaparece como párrafo y su única frase no redundante pasa a cerrar el ¶2; el ¶4 pierde la frase que repetía el cierre del párrafo anterior. **El mismo formato se aplicó a los 15 comentarios**: los 10 cuadros de acciones desaparecieron y sus celdas se convirtieron en la línea de acción de cada ítem, sin perder ni un dato (los cinco valores de pico de la Fig. 5, los residuales, la definición de la terminología de R2-9, etc. siguen todos). Ver el formato exacto en la regla 6.

- ✔️ **Pasada de "ser más puntual" sobre los 15 `Author's response` (10-ago-2026, tercera pasada, pedido del usuario).** Criterio aplicado: **la respuesta contesta lo que el revisor preguntó y para ahí**; todo lo que sea defenderse de lo que no objetó, o señalarle sitios del artículo que no había mirado, sale de la carta y baja a un bloque 🔒 INTERNO bajo su comentario, con el motivo escrito. Recortados de verdad **cuatro**: **R2-6** (dos párrafos, ver detalle en su sección más abajo), **R2-4** (de 4 párrafos a 3, fuera la explicación de por qué difieren 0.48 y 0.97 m/s — elaborar sobre desplazamiento horizontal roza la limitación no declarada del riel de 45 cm), **R2-7** (fuera que la figura no ocupa más alto de página, que es problema nuestro de maquetación, y la nota de paleta accesible, que nadie pidió) y **R2-3** (se quitó *"which leaves the results impossible to reproduce"*, una autoinculpación citable a cambio de nada). **Revisados y dejados como estaban, porque ya contestan justo lo preguntado:** R1-C1, R1-C2, R1-C3, R1-C4, R1-C5, R2-1, R2-2, R2-5, R2-9, R2-10. En R2-10 las tres desviaciones del texto del revisor **no se tocan** — son declaraciones al revisor, no relleno.

⚠️ **R2-8 recortado después (10-ago-2026, cuarta pasada, pedido del usuario) — esto revierte lo que decía la tercera pasada.** La tabla de conversión %BW↔N de los cinco valores, la frase que la introducía y la concesión de apertura (*"We agree that reporting the force in a single unit…"*) salieron de la carta y bajaron a un bloque 🔒 INTERNO bajo el comentario. Razón del usuario: el revisor pidió la fuerza en las dos unidades y eso ya lo contestan el peso corporal en newtons más el segundo eje del panel (c); repetirle los cinco valores no le da nada que no pueda leer en la figura. **La respuesta quedó en dos párrafos.** En la misma pasada, **el `Author's action` de este comentario dejó de ir en ítems numerados y pasó a un solo párrafo corrido** (pedido del usuario), sin perder ninguno de los tres contenidos que tenía (peso corporal en kg y N en Sección III, segundo eje en newtons en la Fig. 5(c) aplicado a curvas y a tira residual, y la declaración de que los valores reportados siguen en %BW con la lectura en newtons dada por ese eje). **Es una excepción consciente a la regla 6, que sigue vigente para los otros 14 comentarios** — no "corregirlo" de vuelta a ítems en una sesión futura. En la misma pasada salieron también **las dos menciones al límite de seis páginas**, una en la respuesta y otra en la acción: el revisor no preguntó por qué no duplicamos los números, y alegar la maquetación propia es una excusa que invita a que la segunda ronda proponga dónde recortar (regla 11). La declaración de fondo se mantiene, enunciada como hecho y sin justificarse. ⚠️ **Contrapartida asumida:** la carta ya no contiene ninguna cifra en newtons, así que la prueba de cumplimiento depende de que el revisor mire la Fig. 5(c). Si en la segunda ronda pide los números explícitos, la tabla está íntegra en el bloque interno.

⚠️ **Tensión con la regla 11** (*la carta contesta solo lo que el revisor preguntó*): listar los recortes de *Electrical Power System*, *Motion Control Software* y *Electronic Control Hardware* nombra secciones que nadie objetó. Se aceptó a propósito porque **son supresiones, no temas nuevos** — declararlas cierra el reproche de "borraron cosas sin decirlo", que es peor que la atención que atraen; y cada fila dice dónde sigue el dato.

### ⚠️ Revisión del PDF de la carta armado por el usuario (10-ago-2026, 22:03) — hay que arreglar antes de enviar

El usuario montó `Response to reviewer's comments .pdf` a mano desde `RESPUESTA_REVISORES.md`, con modificaciones propias. Revisado entero. **El detalle completo, con el texto exacto de cada arreglo, está en el `ANEXO C` al final de `RESPUESTA_REVISORES.md`** (interno, no se envía). Resumen:

- 🔴 **Lo grave: en el Comment 9, ítems 2 y 4, los bloques `Revised` muestran el texto ORIGINAL, con "inter-repetition" todavía dentro** — el ítem dice "Dropped without replacement" / "Nothing added" y la palabra sigue ahí, cinco veces en total. **Causa: el `~~tachado~~` del `.md` no sobrevivió al pasar a Word y el bloque `*Original*` acabó etiquetado como `Revised`.** Es exactamente el riesgo que ya estaba anotado en esta sección sobre convertir `~~` a tachado real. **Corolario:** si el tachado no sobrevive en ningún bloque del documento, hay que quitar del encabezado de la carta la convención que le anuncia al revisor que lo eliminado va tachado, o restituir los tachados.
- 🔴 En el Comment 9 los cuatro ítems **perdieron su encabezado de ubicación** (`Abstract, first mention`, etc.), así que quedan numerados sin decir dónde ocurre cada cambio.
- 🔴 Restos de edición visibles: `as +support`, `sentences.The`, `removed.The`, `ICC(3,1)..`, comilla doble duplicada, `…RMSE values added`, `Section Functional Assessment,` sin el `III`.
- 🟡 **La acción del Comment 7 quedó en una línea sin contenido** (*"Figure 5 was revised based on the feedback received"*), la única así en toda la carta, y con ella el cambio del pie de figura queda sin declarar.
- 🟡 `operating cycle` en el Comment 7 frente a `gait cycle` en la figura y en el pie; `Panel b`/`Panel C`/`Panel c`; `our review article` en el saludo; dos frases donde la referencia [20]/[21] hace de sujeto gramatical.
- 🟡 **Falta la sección `Summary of removed and condensed text`**, que se había decidido enviar, mientras la carta sigue diciendo tres veces que se recortó texto por el límite de páginas.
- ✔️ Falsa alarma descartada: θ, °, ±, comillas y la tabla de RMSE$_{norm}$ renderizan bien.

### Auditoría completa del 10-ago-2026 — qué se verificó y qué se corrigió

**Verificado sobre `PDF_REVISAR (3).pdf` (todo OK):** 6 páginas · orden de citación IEEE **ascendente estricto** por primera aparición (1,3,4,5,6,7,8,9,10,11,12,15,16,20,21,22 — los saltos son rangos colapsados, no desorden) · **`agreement` = 0 apariciones** · `cost-effective` aparece **1 vez y es el título de la ref. [21]**, legítimo · numeración real de figuras en el PDF: **Fig. 4 = montaje experimental, Fig. 5 = resultados**, que coincide con la numeración que usan los revisores · los cuatro sub-ítems de R2-7 están en la figura (bandas ±1 SD del simulador, picos 97.4/91.3/102.5/126.8/157.4 %BW, anotaciones temporales, tira residual con eje en newtons) · panel (b) etiqueta −50.8° y −44.7° · abstract completo · todos los datos de R2-4 presentes y el ciclo de 1.49 s ausente.

**Comparado también contra `articulo original.md`** (diff palabra a palabra): **todas** las supresiones corresponden a cambios documentados — R1–R7 del Anexo A.11, abreviatura de revistas, y las reescrituras de R1-C1/C2/C4 y R2-2/6/10. **No hay nada borrado sin registrar.**

**7 desajustes encontrados y corregidos:**
1. *Manuscrito:* el panel (a) de la Fig. 4 **no estaba citado** en el texto (decía solo `Fig.~\ref{fig:5}`, mientras el pie define (a) y (b) y el cuerpo sí citaba (b)). Añadido `\hl{(a)}`.
2. *Carta, R1-C4 ítem 2:* la cita del texto "revisado" estaba desactualizada — todavía incluía *"which were evaluated independently"* e *"inter-repetition"*, que después se quitaron por R7 y por R2-9.
3-5. *Carta:* tres referencias a secciones inexistentes — *"Section IV-B, Methods"* (×2) y *"Section V, Results"*. El paper tiene I Introduction · II System Architecture · **III Functional Assessment** · IV Discussion · V Conclusion, y tanto las métricas como los resultados están en la III.
6. *Carta, R2-8 acción 3:* afirmaba *"Peak values given in both units"* en Results, **lo cual es falso** — la conversión vive solo en el segundo eje de la Fig. 5(c) (decisión tomada para no duplicar números). Reescrito para decir lo que de verdad se hizo.
7. *Carta:* el encabezado de estado y el del Anexo A decían "falta compilar" / "nada se ha aplicado todavía". Actualizados.

⚠️ **Pendiente menor, cosmético:** `articulo corregido.md` conserva dos comentarios internos en castellano (`% <-- VERIFICAR que el nombre coincida...` en la Fig. 1 y `% version de 2 paneles...` en la Fig. 4). LaTeX los ignora, pero conviene borrarlos antes de enviar el `.tex` si se entrega el fuente.

### Cierre de la sesión del 09-ago (tras P-6P.2) y arreglos del 10-ago

**Aplicado el 09-ago, ya en `articulo corregido.md` y en el Anexo A.11:** se quitó de R2-3 *"sustained for 20 ms"*, *"refined by linear interpolation"* y el *"5 %"* de las oclusiones · **17 títulos de revista abreviados** al estilo IEEE (−293 car. ≈ 4 líneas; [1][2][3][7] son libros/tesis y no llevan) · **recortes de redundancia R1–R7** (−63 palabras, **sin `\hl{}`** a propósito) · **los DOI no se tocan** (decisión del usuario).

**Aplicado el 10-ago:**
- **R2-4 reescrito por completo a formato por fase** (ver arriba). La versión anterior corregía solo el simulador y del sujeto seguía dando el ciclo de 1.49 s — error real detectado por el usuario.
- **Palancas 1 y 2 sincronizadas desde el Overleaf del usuario**, que las tenía y el archivo de trabajo no: bloque de `\setlength` de floats **a 10 pt** (no los 6 pt que se habían propuesto) + `\abovecaptionskip` a 3 pt, sin `\belowcaptionskip`; y `trim`+`clip` en tres figuras — `Figura 3.jpg` `{0 0 0 3.5}`, `fig_software_block_diagram.png` `{0 24 0 24}`, `fig_test_setup.png` `{0 8 0 20}`.
- **Posiciones de float sincronizadas** (decisión del usuario, 10-ago): Fig. 5 (test setup) `[h!]`→`[!b]`, Fig. 6 `[t!]`→`[!t]`. La Fig. 4 ya coincidía en `[t!]`, y las Figs. 1 y 3 no cambian. **`articulo corregido.md` y el Overleaf están ahora alineados en formato.**
- ⚠️ **El abstract de `articulo corregido.md` apareció truncado** (cortado en *"…the stance and swing phases, res"*, sin `\end{abstract}` ni el bloque `IEEEkeywords`) al pegar contenido en el archivo. **Restaurado** el 10-ago desde el `.tex` del usuario; el abstract no había cambiado en las ediciones del 09-ago, así que es idéntico. **Comprobar que el archivo termine bien cada vez que se pegue texto largo.**
- ⚠️ **Riesgo anotado, no declarado:** dar la velocidad por fase hace más visible el desplazamiento horizontal (velocidad × duración), que es justo el dato del que sale la compresión del balanceo al 83.9 % por el riel de 45 cm — la limitación que el usuario decidió no declarar (opción A). Si el revisor la cruza, la respuesta está preparada en `DISCUSION_COMENTARIOS.md`.

### R2-3 / R2-4 — decisiones y datos

- **Filtro cinemático:** se reporta por **orden (3) y ventana (9)**, sin frecuencia de corte. **El `fcorte_cinematica = 6` del código es una variable muerta, nunca se usa** — reportarla habría sido un dato falso. El corte equivalente del Savitzky-Golay (≈20 Hz por la aproximación de Schafer) **se decidió NO ponerlo**: invita a "eso es muy alto". Si el revisor lo pide en la segunda ronda, la respuesta preparada es que el simulador ejecuta ~30× más lento, así que el contenido está en torno a 0.7 Hz.
- **Referencia [22] añadida y VERIFICADA a texto completo:** Zahradka et al., *Sensors* 20(18):5272, 2020, DOI 10.3390/s20185272. Usa literalmente *"a threshold of 20N"* sobre la fuerza vertical para IC/TC. **No rompe la numeración**: todas las citas previas están en la Introducción, así que la nueva, citada en Functional Assessment, es la [22] al final. Orden IEEE verificado: 1→22 estricto.
- **Criterios de rechazo de ensayo: NO se mencionan** (decisión del usuario). Se mantiene la lógica de 10 ensayos en todo el paper.
- **Datos temporales — TODO POR FASE, decisión del usuario (09-ago, reafirmada 10-ago). No se reporta ciclo completo ni velocidad global**, porque apoyo y balanceo se capturaron por separado y el simulador los ejecuta por separado; unirlos implicaría una continuidad que ni la captura ni el equipo tienen. Lo que va al paper: **apoyo 0.95 s / balanceo 0.55 s** (sujeto), **28.8 s / 15.9 s** (simulador), y **walking speed por fase, 0.48 m/s en apoyo y 0.97 m/s en balanceo** — se usa el término del revisor (*walking speed*) definido en la misma frase como el desplazamiento horizontal del segmento tibial dividido por la duración de la fase, para no dejar sin contestar la palabra que él pidió. Los 0.66 m/s de zancada completa y el ciclo de 1.49 s **quedan descartados, no se citan**. Fuente cruda (`PERSONA SANA/*/Desplazamiento - X - *`, 10 ensayos): apoyo 0.9469±0.0230 s / 45.38±1.35 cm, balanceo 0.5481±0.0251 s / 53.17±1.75 cm.
- ⚠️ **Limitación detectada y NO declarada (decisión del usuario, opción A):** el eje horizontal tiene **45 cm** de recorrido, así que el balanceo real del sujeto (53.17 cm) **se escala al 83.9 %**. El apoyo entra completo. **No invalida nada de lo publicado** — el paper valida ángulo y Fz, y ninguno depende del desplazamiento horizontal. Si el revisor pregunta, la respuesta está preparada en `DISCUSION_COMENTARIOS.md`.
- ⚠️ **La duración de ejecución del simulador entra al paper por primera vez** — verificado que el manuscrito no mencionaba nada de velocidad de operación.

### Figura 5 revisada — datos de maqueta

Colocada a 463 pt de ancho mide **141.0 pt**, frente a los **147.9 pt** de la original: **−6.9 pt**, que liberan ~13.8 pt de flujo de columna. Se le añadieron cuatro elementos y **encogió**.

⚠️ **Trampas de MATLAB ya resueltas en `Fig5_Generar.m`, no reintroducirlas:** `yyaxis` dentro de `tiledlayout` **recorta** el panel (c) al 95 % del apoyo, y `OuterPosition` no se fija en un `tiledlayout` (la leyenda se monta sobre los paneles). Por eso la maqueta es **manual, con posiciones explícitas**, y el eje en newtons son unos ejes superpuestos sin datos. `FIG_ALTO_IN` es el único parámetro que hay que tocar para cuadrar las 6 páginas.

### 🔑 `codigos y base original/` + `codigos figura 5/` — lo más importante de esta fase

El usuario entregó la carpeta original del artículo (`Articulo de conferencia/codigos y base original/`) porque **el repo `C:\articuloq2` ya fue modificado por el trabajo del Q2 y no sirve como fuente**. Sobre ella se construyó `codigos figura 5/`:

| Archivo | Qué hace |
|---|---|
| `Fig5_Datos_Plataforma.m` | Copia de `Validacion_Plataforma.m`, **lógica idéntica**, sin diálogos ni figuras; guarda curvas + datos temporales |
| `Fig5_Datos_Fuerza.m` | Copia de `Validacion_Fuerza.m`, ídem, con BW = 86 kg fijo |
| `Fig5_Generar.m` | **Todo el aspecto visual.** Un solo parámetro (`FIG_ALTO_IN`) controla la altura para ajustar las 6 páginas |
| `Verificar_Replica.m` | Compara contra los números publicados |

**La réplica está validada: los NUEVE estadísticos del paper salen exactos** (apoyo 0.38/1.00/100 · balanceo 1.58/0.997/72.50 · fuerza 21.87/0.9501/0.9984). Cualquier cifra que haga falta se puede recalcular con confianza.

⚠️ **Lección de esta fase: dos `.mat` de `REFERENCIAS/` estaban desactualizados** y daban números que no cuadraban con el paper. El usuario los reemplazó (09-ago 17:55 y 18:08) y entonces todo cuadró. **Antes de dudar del código, comprobar la fecha de los `.mat`.**

### Datos duros ya extraídos (sirven para R2-3, R2-4 y R2-8)

- **Procesamiento de fuerza:** Butterworth orden 4 a 15 Hz con `filtfilt` (fase cero), fs 1000 Hz; IC/TO por umbral de 20 N con permanencia de 20 muestras e interpolación lineal del cruce; normalización a 0–60 %; remuestreo `pchip`. **Cinemática:** Savitzky-Golay orden 3 ventana 9, fs 120 fps, ángulo por `atan2`, offset de −5.85° solo en apoyo.
- **Criterios de rechazo de ensayo** (no están en el paper): duración < 300 ms, < 50 puntos, pico < 80 %BW, < 2 máximos locales, o caída bajo umbral en zona media. **`Trial00964` se descarta por no detectarse IC/TO → los estadísticos de fuerza salen de 9 ensayos, no 10.** El usuario decidió mantener "ten programmed repetitions" (describe lo ejecutado, que sí fueron 10).
- **Tiempos (R2-4):** referencia apoyo 0.9459 s, balanceo 0.5397 s, ciclo **1.4857 s**. Simulador apoyo 28.81 s, balanceo 15.95 s, ciclo **44.75 s** → **30.1× más lento**. Falta solo la velocidad de marcha del sujeto.
- **Fuerzas (R2-8), BW = 86 kg = 843.7 N:** referencia pico1 97.43 %BW = 822.0 N @19 %, valle 91.27 %BW = 770.0 N @27 %, pico2 102.51 %BW = 864.8 N @45 %. Simulador pico único **157.37 %BW = 1327.7 N @45 %**.
- **P3.2 medido:** la curva del simulador tiene un máximo local en el **25.00 %** (126.75 %BW) — el usuario lo había visto —, pero su **prominencia es 0.34 %BW**, frente a caídas de 6.16 y 11.23 %BW en la referencia. Es un **hombro, no un valle**. No se anota en la figura para no dar un blanco medible.
- 🟨 **En manos del usuario:** compilar el `.tex` en Overleaf y pasar el PDF, para medir el desbordamiento real (acordado en P-F2.1). Sin `\usepackage{soul}` + `\sethlcolor{yellow}` en el preámbulo no compila.

### R2-6 — por qué se quitó "cost-effective" y no se sostuvo

**No hay coste total del simulador documentado** (confirmado por el usuario), así que se tomó la primera de las dos opciones que el propio revisor ofrece (*"**Remove** or support"*). No es una concesión: se verificó que **tampoco hay una cifra en la literatura citada con la que comparar**. La referencia [21] (Sudeesh et al.), cuyo título es literalmente *"A compact and cost-effective gait simulator…"*, **sostiene esa misma afirmación contando grados de libertad, no dando un precio** — verificado en su resumen público; el texto completo está tras muro de pago.

⚠️ **La carta NO dice nada de esto (recorte del 10-ago-2026, pedido del usuario: "ser más puntual, las referencias no creo que vayan").** El `Author's response` quedó en un solo párrafo: tomamos la primera de las dos opciones, no hay lista de materiales verificada, la afirmación aparecía una vez y se reemplaza por *reduced-degree-of-freedom*. **Se sacaron dos párrafos** — el de por qué la Introducción no pierde motivación (con [10], [11], [21]) y el de las otras cuatro apariciones de *cost* —, que quedan como bloque 🔒 INTERNO bajo el ítem 1 de ese comentario en `RESPUESTA_REVISORES.md`. Motivo: el revisor ofreció dos opciones y tomamos una; lo demás es defenderse de lo que no objetó, y enumerarle dónde quedan las otras menciones de *cost* es invitarle a mirarlas en la segunda ronda (regla 11). **Si insiste con el coste, la respuesta ya está preparada en ese bloque interno.**

La afirmación aparecía **una sola vez** (Introducción). Se sustituyó por `reduced-degree-of-freedom`, término que el Abstract ya usaba. El argumento de coste de la Introducción **sobrevive intacto** porque descansa en dos afirmaciones citadas ([9,10] y [21]), no en una afirmación propia sin factura. Las otras menciones de *cost* no se tocaron (dos son de literatura citada, una es *coste metabólico*, una es un criterio de selección de la cadena, una es el título de [21]).

### R2-10 — trampa que trae el texto propuesto por el revisor

El revisor **redactó él mismo la conclusión que quiere**, y se adoptó casi literal. Pero **su texto reintroduce la palabra *agreement*** (*"improved kinetic agreement"*), que se acababa de eliminar del paper por su propio comentario 2. Se cambió a *"improved kinetic tracking"*. Las otras dos desviaciones de su texto son *"assessed with a single participant"* (cierra el n = 1 que R2-5 prometía) y *"3-DOF"* por *"three-DOF"*. **Las tres están declaradas en la carta.**

### Hallazgo transversal ya resuelto — unidades del RMSE

El RMSE del paper (0.38 / 1.58 / 21.87) **nunca estuvo en grados ni en %BW**: es `RMSEnorm`, el error dividido por la SD puntual de la referencia, adimensional por construcción (verificado en `CODIGOS/VALIDACIONES/Validacion_Plataforma.m` y `Validacion_Fuerza.m`; el usuario confirmó que las cifras salieron de esos scripts y que las unidades se añadieron al redactar). Se corrigió **dentro de R2-2** (opción B): la métrica se nombra y define en Métodos, y los cinco valores del Abstract y de Resultados pierden el símbolo y ganan el subíndice. **Las cifras no cambian.**

⚠️ **Los 1.41° y 2.53° de la línea 217 SÍ son grados** — son los RMSE intra-sujeto, calculados sin normalizar en `Angulo_Control_Plataforma.m` línea 205. No mezclarlos con los anteriores.

## Archivos y su rol — respetar esto

| Archivo | Rol |
|---|---|
| `articulo original.md` | Código LaTeX original de Overleaf. **INTACTO, nunca se toca** |
| `articulo corregido.md` | Copia de trabajo. Aquí se aplican los cambios con `\hl{}` |
| `RESPUESTA_REVISORES.md` | Carta a los revisores (las 15 respuestas + la sección final **`Summary of removed and condensed text`**, que también se envía) + **Anexo A** (registro interno completo de todo lo recortado) + **Anexo B** (nota de LaTeX). La línea 🔒 marca dónde deja de enviarse |
| `DISCUSION_COMENTARIOS.md` | Documento de trabajo. Yo escribo análisis y preguntas; el usuario responde en los bloques ` ``` ✍️ TU RESPUESTA ``` ` |
| `ANALISIS_OBSERVACIONES.md` | Análisis inicial de las 15 observaciones, referencia estática |
| `feedbacks y comentarios extra.md` | Correo original de los revisores. **INTACTO** |
| `figuras_extraidas/` | Figuras sacadas del PDF compilado |
| `_2026__Articulo_conferencia_*.pdf` | PDF compilado de la versión **enviada** (6 págs., el original) |
| `PDF_Overleaf.pdf` | **PDF compilado de la versión en curso.** El usuario lo entrega tras compilar en Overleaf. **Convención acordada 09-ago-2026:** las siguientes llegan como `PDF_Overleaf_V1.pdf`, `_V2.pdf`, … — **el de número más alto es el vigente**; el actual, sin sufijo, es el más reciente hasta que llegue un V1 |

**Flujo obligatorio:** discutir en `DISCUSION_COMENTARIOS.md` → aprobar → aplicar en `articulo corregido.md` → verificar → volcar a `RESPUESTA_REVISORES.md`.

## Reglas de trabajo acordadas con el usuario — no reabrir

1. **Conservador.** El contenido ya pasó revisión; **no se reescribe lo que nadie objetó**. Cada cambio debe justificarse señalando la observación que lo pide.
2. **6 páginas es techo duro.** El PDF está **lleno al 100 %**: medido, la pág. 6 termina en y=718.4 y las llenas en y=718.9 → **0.5 pt libres**. Cada palabra añadida hay que pagarla.
3. **No borrar información.** En secciones **sin** observación no se toca nada; si hiciera falta, solo **quitando redundancia**. Corolario útil: Introduction, Functional Assessment, Discussion y Conclusion **sí** tienen observación, así que los recortes salen de las mismas secciones que deben crecer.
4. **Preferir las 20 citas existentes** antes que añadir nuevas. Solo se añade si ninguna existente sostiene la afirmación.
5. **Todo recorte se registra** en el Anexo A con texto original y motivo, **y además se muestra en la carta** — tachado en el bloque `*Original*` si responde a un comentario, o como fila del `Summary of removed and condensed text` si es un recorte por límite de página. Regla del usuario (10-ago): lo borrado se ve igual que lo añadido.
6. **Respuestas directas y puntuales.** Prohibido "We thank the reviewer…". **`Author's action` en ítems, no en tabla** (cambiado el 10-ago-2026 por el usuario: con el cuadro no se entendía qué se había hecho, sobre todo en los ítems 4 y 5 del R1-C1, que solo existían como fila). Formato fijo de cada ítem: **`**Item N — ubicación.**` + una acción brevísima** (lo que antes iba en la celda "Change") **+ el bloque `*Original*` con lo borrado tachado + el bloque `*Revised*` con lo añadido resaltado**. Si no se borró nada, el ítem lo dice explícitamente ("Nothing removed"); si no se añadió nada, igual. **El bloque `*Original*` va siempre que se toque una frase que ya existía, aunque el cambio sea solo añadir** (pedido del usuario, 10-ago: le faltaba en el R2-5, donde solo se veía la cláusula nueva y no la frase de partida). **Si de verdad no hay original** — párrafo o frase enteramente nueva, como R2-3 y R2-4 — el ítem escribe `*Original:* none` y explica que el manuscrito enviado no decía nada de eso, que es justo lo que el revisor señala; así "sin original" nunca se confunde con "se nos olvidó ponerlo". Las únicas tablas que quedan en la carta son de **datos**, no de acciones: la de los cinco valores de RMSE$_{norm}$ (R2-2) y las dos del `Summary of removed and condensed text`. *(La de conversión %BW↔N de R2-8 estaba en esta lista hasta la cuarta pasada del 10-ago, cuando se bajó a bloque interno — ver arriba.)*

⚠️ **Dos excepciones al formato de la regla 6, ambas del 10-ago-2026 y ambas pedidas por el usuario, que NO hay que "corregir" de vuelta:** en **R2-8** el `Author's action` es **un solo párrafo corrido**, sin ítems; en **R2-9** los ítems **pierden la etiqueta `Item N`** y pasan a encabezarse por su ubicación con una descripción brevísima (`**Abstract, first mention.**`, `**Conclusion, one occurrence.**`, …), **cada uno con su propio bloque `*Original*`/`*Revised*` con el texto exacto del manuscrito**, en vez de un solo par de bloques genéricos al final que representaba las siete apariciones con un `"~~inter-repetition~~ ICC(3,1)"` abstracto. Motivo del usuario: con el par genérico no se veía qué frase concreta se tocó en cada sitio. Los otros 13 comentarios siguen con `**Item N — ubicación.**`.
7. **Estilo IEEE en citas:** una referencia no puede ser sujeto ni parte gramatical; la frase debe leerse bien sin el corchete.
8. **Los ` ``` ` son solo para bloques de respuesta del usuario.** Nunca para encajonar texto explicativo — lo vuelve menos legible.
9. **Al reorganizar documentos, no borrar explicaciones.** El usuario las quiere para consultar después.
10. Lo que se resuelva por chat **se marca en el `.md`** con ✅ CERRADA, para que ninguna pregunta quede aparentemente abierta.
11. **La carta contesta únicamente lo que el revisor preguntó.** No se abren temas que él no abrió, aunque los veamos — señalárselos es invitar un comentario nuevo en la segunda ronda. (Fijada por el usuario en P-R2-2.3, a propósito de *fidelity*.)

## Renumeración de referencias — crítico

Se añadió **[4] Sadeghi et al. 2000** (*Gait & Posture* 12(1):34-45) en posición ordinal para no romper el orden de citación IEEE. Consecuencia: **[4]–[20] del original son [5]–[21] en la revisión.** La **[20]** que citan los revisores es la **[21]** revisada. La **[2]** que objeta R2 **no cambia**. La carta ya lo advierte al inicio.

## 📏 Espacio — MEDIDO sobre el PDF compilado (09-ago-2026). Esto sustituye a toda estimación anterior

`PDF_Overleaf.pdf` (Revisor 1 + Fase 1 + Fase 2, verificado) **tiene 7 páginas**. El desbordamiento es de **10 líneas en la columna izquierda de la pág. 7** — los finales de las referencias [20] y [21] —, o sea **88.7 pt de altura de columna**.

| Constante medida | Valor |
|---|---|
| Interlineado del cuerpo | 11.96 pt |
| Palabras por línea de cuerpo | 9 (mediana) |
| **Recorte necesario en texto** | **~8 líneas ≈ 67 palabras** |
| **O bien, reducción de figura a 2 columnas** | **~45 pt de alto** (vale doble: desplaza el flujo de ambas columnas) |

**La estimación por conteo de palabras (~146) era pesimista por un factor de ~2** — el reajuste de párrafo absorbe texto añadido sin generar línea nueva. **Medir > estimar; volver a medir tras cada compilación.**

**Alturas de figura medidas:** Fig. 1 = 155 pt (1 col) · Fig. 2 = **280 pt (2 col)** · Fig. 3 = 230 pt (1 col) · Fig. 4 = 112 pt (1 col) · **Fig. 5 = 148 pt (2 col)**.

**Restricción de diseño para R2-7:** una Figura 5 rediseñada de **≤ 103 pt** absorbe el desbordamiento actual sin tocar una palabra. Pero **falta añadir R2-3 (~+45 palabras), R2-4 (~+45) y R2-8 (~+10)** — otros ~133 pt. **Total real a recuperar: ~222 pt de columna.** No sale solo de la Fig. 5: hay que repartir con la **Fig. 2 (280 pt, la más holgada y sin observación en contra)**.

**Verificado también en el PDF:** orden de citación IEEE ascendente estricto en el cuerpo (1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 16, 20, 21) ✔️ · *agreement* 0 apariciones ✔️ · `\hl{}` compila sin errores ✔️

⚠️ **Números de referencia — corregido un error en la carta.** En el PDF, `\cite{ref9,ref10}` renderiza **[10], [11]** (no [9],[10]) y `\cite{ref6}` renderiza **[7]**. La regla real es: **refN → [N+1] para N ≥ 4**, por la inserción de Sadeghi como [4]. `ref20` → [21] es el único que ya estaba bien anotado. **Comprobar contra el PDF cualquier número de referencia que se escriba en la carta.**

## Balance de espacio tras el Revisor 1 y la Fase 1 del Revisor 2 (estimado, superado por la medición de arriba)

| | Delta |
|---|---:|
| Introduction (466→519) | +53 |
| Functional Assessment (758→801) | +43 |
| Discussion (351→386) | +35 |
| Bibliografía (ref. nueva) | +33 |
| Figura 1 nueva (174→156 pt de alto) | −20 |
| **Subtotal tras Revisor 1** | **≈ +144 palabras (~12 líneas)** |
| Fase 1 de R2 (R2-1 +18 car., R2-9 −61 car., frase 221 +18 palabras, subíndices +20 car.) | +14 |
| Fase 2 de R2 (R2-6 −2, ¶2 redundante −19, trabajo futuro −16, texto del revisor +23, tracking error +2) | −12 |
| **Déficit actual** | **≈ +146 palabras (~12 líneas)** |

⚠️ **La Fase 2 devolvió casi exactamente lo que costó la Fase 1 — el déficit de fondo del Revisor 1 sigue igual.** Y lo que falta gasta: R2-3 (~+45) y R2-4 (~+45) tienen que ir dentro del paper sí o sí, más R2-8 (~+10). **Proyección: ~240 palabras, media columna.** Con recortes de texto solos no se paga: el espacio real tiene que salir del **rediseño de la Figura 5 que obliga R2-7**, igual que la Figura 1 nueva devolvió 20 pt.

**Cómo pagarlo, ya identificado:** R2-6 (quitar *"cost-effective"*, **resta**) · R2-10 (la conclusión que propone el revisor es más corta, **probablemente resta**) · Discusión ¶2 (repite *r = 0.9501, ICC = 0.9984*, ~8 palabras — tocar al llegar a **R2-7**, junto con la frase del doble pico, para no editar la misma frase dos veces).

## REVISOR 2, en 4 fases

| Fase | Comentarios | Nota |
|---|---|---|
| 1 — baratos | ✔️ R2-1, R2-9, R2-2, **R2-5** | **CERRADA.** Ref. [2] confirmada como Perry & Burnfield, 2.ª ed., SLACK, 2010. R2-5 se adelantó aquí porque toca la misma frase que R2-2 |
| 2 — restan espacio | ✔️ R2-6, R2-10 | **CERRADA.** Devolvió 12 palabras, menos de lo esperado. R2-10 ya nombra el **participante único**, que es lo que R2-5 prometía en la carta |
| 3 — figura | ⬜ **R2-7 — es lo siguiente** | Arrastra **P3.2** y **P3.3** (ver abajo). Es donde hay que recuperar el espacio de verdad |
| 4 — los caros | ⬜ R2-8, R2-3, R2-4 | **Los tres dependen de datos del equipo.** R2-8 exige la Fz en newtons y %BW — el subíndice `norm` no lo resuelve |

### Preguntas aparcadas que se retoman aquí

- **P3.2** → en R2-7. La Discusión afirma *"accurate reproduction of the characteristic double-peak pattern"*, **pero la Fig. 5(c) muestra que el simulador NO reproduce el doble pico**: la referencia tiene la M (~97 %BW al 18 %, valle ~92 % al 28 %, ~102 % al 45 %) y el simulador sube sostenido hasta **un único pico de ~157 %BW al 45 %**. La r = 0.9501 es alta porque Pearson no distingue una M de una cúpula. R2-7 pide añadir picos, anotaciones temporales y curva residual — o sea, **una figura que contradice esa frase**. Hay que ajustarla.
- **P3.3** → en R2-7 y R2-8. Faltan los **valores pico exactos de Fz de MATLAB** (referencia y simulador). Los actuales son lectura de píxel.

### Datos que hay que pedirle al equipo

- **R2-3:** filtro y orden, frecuencia de corte y criterio, cómo se detectaron contacto inicial y despegue, a cuántos puntos se normalizó cada fase, si hubo remuestreo, y si se perdió algún marcador.
- **R2-4:** velocidad de marcha, duración del ciclo, duración del apoyo, duración de ejecución del simulador.
- **R2-7/R2-8:** valores pico exactos de Fz.

> ⚠️ **R2-3 y R2-4 no se pueden levantar solo explicando en la carta.** El revisor pide *"Describe signal-processing procedures"* y *"Please complete the information of…"* — esos datos **tienen que estar en el paper**. Se escribirán ultracomprimidos (una frase densa cada uno, ~45 palabras en vez de ~120).

## Acciones físicas pendientes (equipo / Overleaf)

- [ ] Sustituir `fig_test_setup.png` por la **versión de 2 paneles (a)+(b)** — el dibujo del panel (b) con M1–M4 y θ **ya está hecho**, falta montarlo. Hay comentario marcándolo en el `.tex`.
- [ ] Confirmar que en Overleaf la Figura 1 se llame **`fig_CAD_model.png`**.
- [ ] Añadir al preámbulo `\usepackage{soul}` y `\sethlcolor{yellow}` — **sin eso `\hl{}` no compila**. Ya está en `articulo corregido.md`.
- [ ] Compilar y medir cuánto sobra o falta respecto a las 6 páginas.

## Verificaciones que conviene correr tras cada cambio al manuscrito

- Bloques `\hl{}` que contengan `\cite`, `\ref` o matemáticas → **rompen la compilación**. Hay que partirlos: `\hl{texto} \cite{ref} \hl{sigue}`.
- Balance de llaves `{ }` y de delimitadores `$`.
- **Orden de citación ascendente** por primera aparición (IEEE). El original cumplía 1→20 estricto; el corregido cumple 1→21.
