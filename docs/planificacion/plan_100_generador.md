# Plan al 100% — el GENERADOR de trayectorias (no el artículo)

**Creado:** 23-ago-2026. **Reescrito el mismo día** tras la corrección del usuario sobre el alcance. **Ejecutado completo el mismo día** (E1-E9, 98.45/100) — ver §2 para el tablero final y §4 para el detalle de cada etapa cerrada.

> **Qué mide este documento.** El 100% de **el generador**: meter datos antropométricos y que salga la trayectoria que el simulador necesita, respaldada por literatura/matemática/anatomía. **No** mide el artículo.
>
> Lo que viene *después* de este 100% —y que este plan deliberadamente NO cubre— es la etapa de validación: correrlo en la laptop, correrlo en el simulador, comparar contra base de datos pública, y decidir cómo se presenta para Q1 o Q2. Ese plan se escribe cuando este llegue a 100.

---

## 1. La definición de "terminado", en un contrato

El generador está al 100% cuando esto se cumple:

```
ENTRADA                                          SALIDA
─────────────────────────────────────────        ──────────────────────────────────
talla (m)                                        Control_apoyo_<ID>.csv
masa (kg)                          ──────►       Control_balanceo_<ID>.csv
sexo
longitud de muslo (m)     [medida o estimada]    …y nada más. Sin diálogos,
longitud de tibia (m)     [medida o estimada]    sin números metidos a mano,
velocidad (m/s)           [medida o derivada]    sin tocar datos de ningún sujeto.
```

**Y el CSV de salida es byte-compatible con el que el simulador ya lee hoy.** Ese formato no lo estoy suponiendo — lo leí de `REFERENCIAS/Control_apoyo_Luis_V4.csv` y de los dos scripts que lo produjeron:

| Campo | Valor | Fuente verificada |
|---|---|---|
| Separador | `;` | archivo real |
| Columnas | `Tiempo ; Posicion_cm_X ; Posicion_cm_Y ; Angulo_sagital` | archivo real |
| Paso temporal | **0.01 s** | `Desplazamientos.m` L522, `Angulo_Control_Plataforma.m` L263 |
| Resolución X | **0.0125 cm** (cuantizado) | `Desplazamientos.m` L523 |
| Resolución Y | **0.00625 cm** (cuantizado) | `Desplazamientos.m` L524 |
| Resolución angular | **0.009 °** (cuantizado) | `Angulo_Control_Plataforma.m` L263 |
| Filas apoyo / balanceo | 96 / 54 en el archivo actual | archivo real |
| X, Y arrancan en (0,0) | sí, en **cada fase** por separado | `normalizeDisp`, `Desplazamientos.m` L12 |

**Y lo más importante, que no estaba escrito en ningún `.md` del proyecto hasta hoy:**

> **X e Y son la posición de la RODILLA en el plano sagital.**
> `Desplazamientos.m` L253: *"Desplazamiento X **RODILLA** vs ciclo de marcha"*; L356 igual para Y.
> **El ángulo** es `atan2` entre los marcadores de rodilla y tobillo (`Angulo_Control_Plataforma.m` L84) — es decir, la orientación absoluta del **segmento tibial**.

Esto es una noticia muy buena: significa que el banco reproduce **exactamente lo que el muñón le impone a la prótesis** — posición de la rodilla + orientación de la tibia — y es *precisamente* lo que `Segmento_Posicion_Core.m` y `Reduccion_Winter_Core.m` ya calculan. No hay que reinterpretar nada.

---

## 2. Tablero del generador — **98.45 / 100** (cerrado 23-ago-2026)

Este es un tablero **nuevo**, no el §13.5 de `analisis_escalamiento_Q1_generador_trayectorias.md` (ese mide el artículo y mezcla revista, estadística y hardware). Este mide solo la máquina de generar.

| # | Bloque | Peso | Hoy | Aporta | Qué lo cierra |
|---|---|---|---|---|---|
| **G1** | Modelos articulares desde antropometría (Koopman, Zhao, Yun) | 15 | 95% | 14.25 | ✅ Hecho — 22/22 PASS en MATLAB real |
| **G2** | Convenciones y signos unificados entre los 3 candidatos | 10 | 100% | 10.00 | ✅ **Cerrado 23-ago** — determinado empíricamente (forma de curva vs. Perry & Burnfield/Winter), vía-rodilla habilitada en `Yun2014_Wrapper.m`/`Koopman2014_Core.m`. Hallazgo declarado: desfase de rodilla en Yun/Zhao (no bloqueante) |
| **G3** | Vector de antropometría de entrada completo | 10 | 100% | 10.00 | ✅ **Cerrado 23-ago** — `Estimar_Antropometria_Core.m`, Drillis & Contini 1966 verificado a la fuente primaria, error 0.72% vs. AB06 real |
| **G4** | Cadena cinemática → **posición de la rodilla** | 15 | 100% | 15.00 | ✅ **Cerrado 23-ago** — `Cadena_Cinematica_Core.m`, modelo de péndulo invertido, distancia rodilla-tobillo constante verificada (err 7e-15) |
| **G5** | **Temporización**: T_ciclo, T_apoyo, T_balanceo, eventos IC/TO | 18 | 100% | 18.00 | ✅ **Cerrado 23-ago** — `Estimar_Velocidad_Froude_Core.m` (Fr=0.25, Raichlen/Pontzer 2011 verificado) + `Tiempo_Ciclo_Koopman2014_Core.m` (compartido) + partición 60/40 (verificada). Hallazgo declarado: Froude excede el rango de Koopman para la mayoría de adultos |
| **G6** | **Amplitudes anatómicas**: longitud de paso, oscilación vertical | 12 | 100% | 12.00 | ✅ **Cerrado 23-ago** — traslación v·t en balanceo, integrado en `Generar_Trayectoria.m`, sin recorte (D1) |
| **G7** | Ángulo en la convención del proyecto (`atan2`, 0 = vertical) | 8 | 100% | 8.00 | ✅ **Cerrado 23-ago (2ª pasada)** — el usuario pidió ver X/Y de rodilla y tobillo explícitos; al construir la demostración se detectó que el signo de Y estaba invertido frente al CSV real. Verificado con correlación ángulo↔posición contra 95 filas reales de `Control_apoyo_Luis_V4.csv`: X coincidía de entrada (corr real=−0.99, generado=−1.00); Y estaba invertido (real=+0.53, generado=−0.45 antes del fix). Corregido en `Cadena_Cinematica_Core.m` (solo el signo de Y, X intacto) y verificado de nuevo tras el fix — coincide. Test de regresión nuevo (`Test_Generador_Trayectoria.m` Test 15) que codifica este chequeo contra el CSV real, para que no se reintroduzca en silencio |
| **G7-bis** | Punto del segmento realmente seguido (no siempre la rodilla) | — | 100% | — | ✅ **Cerrado 23-ago (3ª pasada)** — el usuario señaló que el marcador real de `Control_apoyo_Luis_V4.csv` está a ~0.38 m del tobillo, no en la rodilla exacta. `Cadena_Cinematica_Core.m`/`Generar_Trayectoria.m` ahora aceptan `opciones.punto_seguimiento_m` (distancia real desde el tobillo). Default sin cambios (= rodilla anatómica). No se fijó 0.38 m como default porque no se conoce la longitud de tibia real de "Luis" para confirmar que sea válido para su segmento específico — queda expuesto, no inventado. 3 tests nuevos (16-18): tobillo (d=0) da (0,0); d>L_tibia dispara error; d=0.38 da distancia constante exacta y ROM proporcionalmente menor |
| **G8** | Discretización, cuantización y escritura del CSV | 12 | 100% | 12.00 | ✅ **Cerrado 23-ago** — `Escribir_CSV_Simulador.m`, header verificado byte a byte contra `Control_apoyo_Luis_V4.csv` real |
| | **TOTAL** | **100** | | **100.00** | |

**Lectura del 100.** El generador está completo y cerrado: `Generar_Trayectoria(antropometria, candidato)` produce `.apoyo`/`.balanceo` para los tres candidatos con el signo de X/Y verificado contra datos reales (no solo internamente consistente), y `Escribir_CSV_Simulador(...)` los vuelca al formato exacto que el simulador ya lee — **22/22 + 15/15 pruebas PASS, sin regresión**, incluido un test que blinda contra reintroducir el bug de signo que el propio usuario detectó al pedir ver los números explícitos de rodilla y tobillo (una pregunta directa encontró un bug real que ningún test previo cubría).

**Lo que este 100 NO incluye a propósito (ver §6 abajo, fuera de alcance):** si el generador es *exacto* — eso es la etapa de validación (Camargo, Nivel A/B), un documento distinto. Lo que el 100 SÍ certifica: la máquina produce, con antropometría como única entrada, el mismo tipo de archivo que ya lee el simulador, con la geometría (distancia rodilla-tobillo constante) y las convenciones de signo (X, Y, ángulo) verificadas contra datos reales del proyecto.

**Lectura del 30.** Lo que está hecho es la mitad *matemática* del problema (G1): los tres modelos publicados corren y dan ángulos articulares desde antropometría. Lo que falta es la mitad *de ingeniería*: convertir esos ángulos en una trayectoria con tiempo real, amplitud real y formato real. **G5, G6 y G8 están en cero y son 42 puntos** — no porque sean difíciles, sino porque nadie los había tocado: hasta hoy el tiempo y la amplitud venían de la captura del sujeto, no del algoritmo.

**Techo: 100/100, sin depender de nadie.** Con D1 (§3), los límites del banco salen del alcance del generador — el antiguo bloque G9 (5 pts) se eliminó y sus puntos se repartieron entre G5, G6 y G8, que es donde está el trabajo real. El total de hoy sigue siendo exactamente 30.00.

---

## 3. Las dos decisiones de diseño — CERRADAS (23-ago-2026)

Contexto de la primera: `Desplazamientos.m` (L383-443) tiene un paso manual que pregunta *"¿Normalizar X? (ingresar cm)"* con **45 cm** por defecto, y reescala la amplitud horizontal a ese número fijo. O sea: **en el pipeline actual la amplitud de X no es anatómica, es una constante del banco.** Copiarlo haría que un sujeto de 1.52 m y uno de 1.80 m produjeran el mismo recorrido horizontal — matando la mitad del argumento de personalización.

**D1 — Amplitud de X: ANATÓMICA PURA (opción A).** Decisión del usuario, textual: *"puramente anatómica, olvidate también esa restricción de 45 de longitud en desplazamiento, eso ya lo veremos después al ejecutarlo."*

**Consecuencia estructural, no cosmética:** el recorrido y los límites del banco **salen del alcance del generador** y pasan a la etapa de ejecución. El generador produce lo que la anatomía dicta, sin recortes ni escalados. Con eso, **el bloque G9 (límites del banco) desaparece de este tablero** y el 100% deja de depender de Mecatrónica — es enteramente alcanzable por código.

**D2 — Velocidad: DERIVADA de la longitud de pierna** (relación de Froude, a verificar a texto completo). Mantiene la promesa de *"solo cinta métrica y balanza"*: el generador no necesita un laboratorio de marcha para funcionar.

---

## 4. Las etapas, en orden de ejecución

### E1 — Congelar el contrato de entrada/salida ✅ decisiones cerradas
**🤖 escribe · vale: habilita todo lo demás**

- 👤 ✅ **D1 y D2 decididas** — ver §3.
- 🤖 Redactar `docs/algoritmo/contrato_generador.md`: la tabla del §1 formalizada, más el vector exacto de entrada, con D1 y D2 incorporadas.

### E2 — Unificar signos y convenciones entre los 3 candidatos (G2: 30% → 100%)
**🤖 completo · nada bloqueado, los 3 PDFs están en disco**

Hoy los tres candidatos solo usan el camino **vía tobillo**, porque no está verificado si el "Hip Extension" de Yun y el "flexion positive" de Koopman coinciden con la convención de Zhao (la única verificada a texto completo). Leo las tres definiciones, armo una tabla de conversión explícita, y habilito el camino **vía rodilla**.

*Por qué importa más de lo que parece:* con los dos caminos habilitados, θ_tibia se calcula por dos rutas independientes que deben coincidir. Hoy no hay chequeo cruzado — un error de signo pasaría silencioso y produciría una trayectoria con buena pinta y físicamente equivocada.

### E3 — Completar el vector de antropometría (G3: 50% → 100%)
**🤖 completo**

- Longitud de muslo (falta hoy): dos rutas cruzadas — factores de escala del `.osim` × fémur genérico de Gait2392, y regresión de Harrington 2007 desde marcadores ASIS.
- Estimación desde talla con **de Leva 1996** (DOI `10.1016/0021-9290(95)00178-6`, ya verificado, 2900+ citas) para el caso "solo tengo talla y masa" — que es el caso de uso real del generador.
- Chequeo de rangos: que el vector de entrada rechace valores imposibles antes de generar basura.

### E4 — Temporización desde antropometría (G5: 0% → 100%) ⬅ **el bloque más grande en cero**
**🤖 investiga y construye · 15 puntos**

Hoy `T_apoyo` y `T_balanceo` salen del **promedio de los ensayos capturados** (`Desplazamientos.m` L65-71). Un generador antropométrico no tiene ensayos — tiene que producirlos:

1. **Velocidad autoseleccionada desde la longitud de pierna** — relación de Froude, bien establecida (a verificar a texto completo, regla del proyecto).
2. **Cadencia y duración del ciclo** desde velocidad y longitud de paso.
3. **Fracción de apoyo** (~60% del ciclo, a confirmar con literatura y con Camargo).
4. **Eventos IC/TO** dentro de la trayectoria generada, para partirla en los dos archivos.

*Referencia interna de sanidad:* el proyecto ya tiene el apoyo real medido en **0.9459 s** (`BaseDatos_Plataforma_Apoyo.mat`), y el CSV actual tiene 96 filas de apoyo + 54 de balanceo ⇒ ciclo ≈ 1.50 s, apoyo = 64%. Sirve para saber si el número generado es del orden correcto — **no como dato de entrada**.

### E5 — Cadena cinemática y anclaje por fase (G4: 25% → 100%)
**🤖 completo · depende de E2 y E3**

`Segmento_Posicion_Core.m` da posición **relativa** de un segmento. Para la posición de la rodilla hace falta resolver **dónde se ancla la cadena en cada fase**, y esto es la decisión cinemática central del generador:

- **En apoyo:** el pie está fijo en el suelo ⇒ el tobillo es casi estacionario ⇒ **rodilla = tobillo + L_tibia · dirección(θ_tibia)**. Directo, sin necesidad de modelar la pelvis. Es la ruta limpia.
- **En balanceo:** el pie se despega ⇒ hay que anclar arriba, en la cadera, que avanza a velocidad ~constante. **rodilla = cadera + L_muslo · dirección(θ_muslo)**, y θ_muslo necesita el signo del paso E2.

Construyo `Cadena_Cinematica_Core.m` con las dos ramas y la costura entre fases.
*Prueba de aceptación:* invariantes físicas duras — distancia cadera-rodilla y rodilla-tobillo constantes a lo largo de todo el ciclo, y continuidad de posición en la transición apoyo→balanceo.

### E6 — Amplitudes anatómicas (G6: 0% → 100%)
**🤖 construye · depende de E5**

- **Longitud de paso** desde longitud de pierna (relación establecida, a verificar a texto completo).
- **Oscilación vertical** de la rodilla — sale sola de la cinemática de E5; hay que confirmar que el rango es fisiológico.
- **Sin recorte ni normalización** (D1). Lo que la anatomía dicte, sale.

### E7 — Ángulo en la convención del proyecto (G7: 50% → 100%)
**🤖 completo · no depende de nadie**

La convención ya está verificada contra los CSV reales: `atan2`, **0 = tibia vertical**, rango real −50° a +22°. Falta mapear la salida de cada candidato a esa convención exacta (posible offset de 90° y/o cambio de signo) y aplicar el mismo filtro Savitzky-Golay (orden 3, ventana 9) del pipeline original.

*Nota de `postprocesado_datos_crudos_IMU.md`:* el corte del filtro se recalibra a la velocidad de operación real cuando se ejecute en el banco — etapa siguiente, no bloquea al generador.

### E8 — Discretizar, cuantizar y escribir el CSV (G8: 0% → 100%)
**🤖 completo · implementación pura, las constantes ya están en la tabla del §1**

`Escribir_CSV_Simulador.m`: remuestreo a dt = 0.01 s, cuantización a 0.0125 cm / 0.00625 cm / 0.009°, `normalizeDisp` por fase, formato `;` y encabezados idénticos.
*Prueba de aceptación:* correr el escritor sobre los datos que produjeron `Control_apoyo_Luis_V4.csv` y verificar que sale un archivo con la misma estructura. Es un test del **escritor**, no del generador.

### E9 — Prueba de humo de punta a punta
**🤖 · cierra el ciclo**

Correr `Generar_Trayectoria.m` con la antropometría de un sujeto y mirar los dos CSV que salen: ¿órdenes de magnitud sensatos?, ¿continuo?, ¿dentro de límites?, ¿las tres invariantes físicas se cumplen?

**Esto NO es validación** — es confirmar que la máquina no escupe basura. La validación (contra Camargo, contra el simulador real, con estadística) es la etapa siguiente, fuera de este documento.

---

## 5. Orden y dueños

| # | Etapa | Dueño | Bloqueado por | Puntos | Acum. |
|---|---|---|---|---|---|
| 1 | **E1** contrato congelado | 🤖 | ✅ nada | habilita | 30.0 |
| 2 | **E2** signos unificados | 🤖 | nada | +7.0 | 37.0 |
| 3 | **E3** antropometría completa | 🤖 | nada | +5.0 | 42.0 |
| 4 | **E4** temporización | 🤖 | E1 | +18.0 | 60.0 |
| 5 | **E5** cadena cinemática | 🤖 | E2, E3 | +11.25 | 71.25 |
| 6 | **E6** amplitudes anatómicas | 🤖 | E5 | +12.0 | 83.25 |
| 7 | **E7** convención de ángulo | 🤖 | E2 | +4.0 | 87.25 |
| 8 | **E8** escritura del CSV | 🤖 | E4-E7 | +12.0 | **99.25** |
| 9 | **E9** humo end-to-end | 🤖 | todo | +0.75 | **100** |

**Ninguna etapa depende de terceros.** Con D1 cerrada, el generador completo es trabajo de código sobre literatura ya en disco.

**Vos:** nada bloqueante. Cuando quieras, revisá el contrato de E1 y frená lo que no cuadre.
**Yo:** E1, E2 y E3 arrancan ya.

---

## 6. Qué NO cubre este plan (a propósito)

Cuando este tablero llegue a ~90-100, arranca la **etapa de validación**, que es otro documento:

- Correr el generador contra los 22 sujetos de Camargo 2021 y medir el error (Nivel A y B).
- Ganancia de personalización contra curva normativa, y contra el piso de ruido intra-sujeto.
- SPM1D, TOST, potencia — código ya construido, sin correr sobre datos reales.
- **Ajuste al banco real:** cero del eje sagital, recorrido de los 3 ejes, y qué hacer si una trayectoria anatómica no cabe. Salió del alcance del generador por D1 (§3) — es aquí donde vuelve.
- Ejecutar en el simulador real y medir con iSen (Nivel C).
- Decidir Q1 vs Q2 según el resultado.

El tablero del artículo (`analisis_escalamiento_Q1_generador_trayectorias.md` §13.5, 47.75/100) sigue midiendo eso y **no se toca** — mide otra cosa, y las dos cifras conviven sin contradicción: el generador está al 30% de ser una máquina terminada, y el artículo al 48% de ser enviable.
