# Guía de interpretación — Generador de trayectoria desde antropometría

**Creada:** 23-ago-2026. Rol de esta carpeta: implementar los candidatos de algoritmo ya verificados a texto completo (`docs/algoritmo/diseno_matematico_generador.md`) y la reducción cinemática que convierte sus ángulos articulares en el ángulo absoluto del segmento tibial que el simulador necesita. **Sin datos propios del proyecto (`PERSONA SANA/`, `REFERENCIAS/`) en esta carpeta** — decisión explícita del usuario (23-ago-2026): el algoritmo se construye 100% desde literatura, y se valida después contra una base de datos pública independiente (Camargo 2021, ver §5).

---

## 1. Qué hace cada archivo, en una frase

| Archivo | Qué hace | Estado |
|---|---|---|
| `Zhao2026_Core.m` | Genera φ_cadera(t), φ_rodilla(t) y θ_tibia = φ_cadera − φ_rodilla, con los coeficientes ya publicados de Zhao et al. 2026 (Tabla 1) | 🟢 Construido y probado (MATLAB real, 5/5 PASS) |
| `Yun2014_Wrapper.m` | Llama al toolbox real de Yun 2014 (`Gait_Pred.m`, sin reentrenar), extrae cadera/rodilla/tobillo, aplica la reducción vía tobillo | 🟢 Construido y probado (MATLAB real, con el toolbox real) |
| `Koopman2014_Core.m` | Genera las 4 trayectorias articulares (cadera ab/ad, cadera flex/ext, rodilla, tobillo) con splines quínticos por tramos entre 6 eventos clave, coeficientes ya publicados (Tablas 1-5) | 🟢 Construido y probado (MATLAB real, 5/5 PASS, ROM cerca del publicado en Tabla 6) |
| `Reduccion_Winter_Core.m` | Relación general ángulo relativo↔absoluto (Winter): calcula θ_tibia por el camino rodilla y/o por el camino tobillo, y los cruza como chequeo de consistencia | 🟢 Construido y probado |
| `Cargar_Camargo_Core.m` | Carga un ensayo real de Camargo 2021 (marcadores + ángulos IK + longitud de tibia real) para validación Nivel A/B | 🟢 Construido y probado con AB06 real |
| `Segmento_Posicion_Core.m` | Convierte ángulo absoluto + longitud del segmento en posición (x,y) de cualquier punto del segmento (trigonometría directa, no necesita literatura nueva) — el paso que faltaba entre "ángulo del segmento tibial" y "posición real", pedido explícito del usuario (23-ago-2026) | 🟢 Construido y probado (6/6 pruebas, incluida invariante física fuerte con datos reales de AB06) |
| `Test_Generador.m` | Prueba las funciones de la lista de arriba (candidatos, reducción, cinemática relativa) — sintéticas + reales cuando los datos externos están en disco | 🟢 **22/22 PASS, corrido en MATLAB real** (`/c/Program Files/MATLAB/R2025b`, disponible en esta máquina) |
| `Estimar_Antropometria_Core.m`, `Estimar_Velocidad_Froude_Core.m`, `Tiempo_Ciclo_Koopman2014_Core.m`, `Temporizacion_Core.m`, `Cadena_Cinematica_Core.m`, `Generar_Trayectoria.m`, `Escribir_CSV_Simulador.m` | E3-E9 de `plan_100_generador.md`: antropometría, temporización, cadena cinemática, orquestador, escritor de CSV (ver §3-ter/§3-quater abajo) | 🟢 Construido y probado |
| `Test_Generador_Trayectoria.m` | Prueba E3-E9 (no duplica `Test_Generador.m`) | 🟢 **14/14 PASS, corrido en MATLAB real** |

**Todos los archivos de esta carpeta ya se ejecutaron en MATLAB real** (23-ago-2026) — a diferencia del resto de `CODIGOS/` del proyecto, que sigue pendiente de que el usuario los corra en su propia sesión.

---

## 2. Candidato — Koopman 2014

**Texto completo verificado (23-ago-2026, `docs/literatura/pdfs/koomap.pdf`) — extracción matemática completa en `docs/algoritmo/diseno_matematico_generador.md` §2. Implementado y probado en `Koopman2014_Core.m`.**

**Aviso de variable:** Koopman usa `l` para **talla corporal** (m); Zhao usa `l` para **longitud de pierna** (m) — son entradas distintas, no confundir al combinar candidatos en el mismo pipeline.

**Signo sin verificar cruzado con Zhao/Yun:** Koopman define "(dorsi-)flexion and abduction... positive" (convención clínica clásica) — no se confirmó si esto coincide exactamente con la convención de signo de cadera/rodilla de Zhao 2026 o de Yun 2014 (mismo caveat que el de Yun en §3). Antes de promediar o comparar directo las tres salidas, revisar signo por signo.

**Reducción pendiente:** igual que Yun, Koopman no da la relación absoluto/relativo — necesita `Reduccion_Winter_Core.m` (vía tobillo, con el mismo supuesto de pie plano). No se conectó todavía `Koopman2014_Core.m` con `Reduccion_Winter_Core.m` en un pipeline único — cada Core se probó por separado.

---

## 3. Hallazgo nuevo (23-ago-2026) — Yun 2014 sí da el ángulo de cadera

`docs/algoritmo/diseno_matematico_generador.md` §3.3 decía que Yun 2014 solo daba rodilla y tobillo. **Al revisar `Gait_Pred.m` línea por línea (líneas 38-41), el toolbox predice 14 movimientos, y dos de ellos son `R./L. Hip Extension`** (canales 6 y 11) — cadera sagital, no solo rodilla+tobillo. `Yun2014_Wrapper.m` ya expone `.R_hip_extension`/`.L_hip_extension` en su salida.

**Por qué no se usa todavía para el camino "vía rodilla" de la reducción:** el signo/convención de "Hip Extension" de Yun (¿positivo = extensión o flexión? ¿medido desde qué referencia?) no está verificado contra la convención que usa `Reduccion_Winter_Core.m` (tomada de la sección 2.6 de Zhao 2026, que sí está verificada a texto completo). Mezclar signos sin confirmar produciría un resultado con apariencia correcta pero silenciosamente equivocado — el tipo de error que este proyecto evita a propósito (ver regla de citas verificadas, misma lógica aplicada aquí a signos de ángulos). **Pendiente:** leer la definición exacta de "Hip Extension" en el texto de Yun 2014 (ya se tiene el PDF completo) antes de habilitar el camino vía rodilla para este candidato.

**Lo que sí está habilitado hoy:** el camino **vía tobillo** (`R./L. Ankle P.flex.` + supuesto de pie plano en apoyo, `theta_pie = 0`) — mismo patrón que usa Zhao internamente, con la ventaja de que el supuesto de pie plano ya es una simplificación estándar y declarada (§4.1 del diseño matemático, y la propia Zhao 2026 lo usa: "ignores the function of the foot").

---

## 4. Convención de ángulos — RESUELTO PARA EL GENERADOR (E7), pendiente solo el cero físico del banco

**Actualizado 23-ago-2026 (E7 de `plan_100_generador.md`).** Lo que sigue describe el estado ANTES de E7 — se conserva por trazabilidad. `theta_tibia_rad` de los tres candidatos ya está, de hecho, en la MISMA convención que usa `Cadena_Cinematica_Core.m`/`Segmento_Posicion_Core.m` (0 = vertical, no 0 = horizontal — ver bug #2 de §5-bis, corregido y verificado contra `Control_apoyo_Luis_V4.csv` real), porque `Segmento_Posicion_Core.m` fue construido y verificado con esa MISMA convención (theta=0 → segmento vertical). No hizo falta un offset de 90° adicional para el generador en sí.

**Lo que SÍ sigue pendiente, y depende de Mecatrónica (no de literatura):** calibrar el **cero físico** del eje sagital del banco real — dónde está exactamente ese cero respecto a la geometría del simulador. Con la decisión D1 (`plan_100_generador.md` §3), esto salió del alcance del generador y pasó a la etapa de ejecución/validación. Ver tarea pendiente #4 de `docs/algoritmo/diseno_matematico_generador.md` §6.

---

## 5. Próximo paso — validación contra Camargo 2021

Investigado el 23-ago-2026 (búsqueda web, no verificado a texto completo todavía): el dataset de Camargo, Ramanathan, Flanagan & Young 2021 (*Journal of Biomechanics*, DOI `10.1016/j.jbiomech.2021.110320`, ya elegido en P-24) es accesible públicamente:

- **Descarga:** directorio público de Dropbox enlazado desde la página del EPIC Lab (Georgia Tech) — https://www.epic.gatech.edu/opensource-biomechanics-camargo-et-al/. Recomiendan bajar sujeto por sujeto (~1 GB cada uno, 22 sujetos en total).
- **Estructura confirmada** (vía el blog técnico del propio autor, `blog.jcamargo.co`): cada sujeto tiene `SubjectInfo.mat` (antropometría — usada en el propio tutorial para normalizar momento por peso corporal) y una carpeta `STRIDES/` con los ensayos individuales, con canales como `ankle_angle_r`, etc.
- **Confirmado en la página del EPIC Lab:** sí incluye ángulos sagitales de cadera, rodilla y tobillo (por goniómetro, además de los que salen de OpenSim vía marcadores) durante marcha a nivel — exactamente lo que hace falta para:
  - **Nivel A** (`analisis_escalamiento...md` §7.1): correr Yun 2014 / Zhao 2026 con la antropometría real de cada sujeto de Camargo, comparar contra sus ángulos de cadera/rodilla REALES — sin circularidad, estos 22 sujetos no participaron en entrenar ningún candidato.
  - **Nivel B**: aplicar `Reduccion_Winter_Core.m` a los ángulos REALES de Camargo (no a los generados) y comparar contra el ángulo absoluto real del segmento tibial (derivable de sus marcadores/OpenSim) — aísla el error de la reducción en sí, separado del error del modelo.

**✅ Verificado 23-ago-2026 con los 2 sujetos piloto reales (`AB06`, `AB09`, descargados por el usuario, ~1.3GB c/u en `docs/literatura/pdfs/`):**

- **La longitud de segmento SÍ está disponible — pero no como un número en una tabla, sino en el modelo OpenSim escalado de cada sujeto** (`<sujeto>/osimxml/<sujeto>.osim`). Es un XML del modelo genérico **Gait2392** (Delp et al. 1990, Anderson & Pandy 1999/2001) con `<scale_factors>` aplicados por segmento específicos de cada sujeto — para AB06: fémur ×1.0270, tibia ×1.0825, pie ×1.0558 (los tres ejes iguales, escalado isotrópico). La longitud real del segmento = longitud del segmento genérico del Gait2392 × este factor. Esto es, de hecho, **mejor que una tabla de longitudes** — es la fuente estándar del campo (mismo modelo que cita `analisis_escalamiento...md` §5-bis como referencia metodológica establecida) y evita tener que asumir de Leva 1996 para este dataset.
- **No hay `SubjectInfo.mat` dentro del `.zip` de cada sujeto individual** (a diferencia de lo que decía el tutorial de blog.jcamargo.co, que aparentemente lo describe para una descarga distinta/combinada) — la antropometría vive en el `.osim`, no en un archivo aparte.
- **Los ángulos articulares SÍ están confirmados y con nombres de canal estándar de OpenSim**, verificado abriendo `AB06/10_09_18/levelground/ik/levelground_ccw_normal_01_01.mat` en MATLAB: es una `table` (24 columnas) con `hip_flexion_r`, `hip_adduction_r`, `hip_rotation_r`, `knee_angle_r`, `ankle_angle_r`, `subtalar_angle_r`, `mtp_angle_r`, y sus equivalentes `_l` — exactamente cadera/rodilla/tobillo sagital que hacen falta para los Niveles A y B, muestreados en el tiempo (no normalizado a %ciclo todavía, `Header` es tiempo en segundos).
- **No leído con Python/scipy** — los `.mat` de Camargo guardan objetos `table` de MATLAB (`MatlabOpaque` para scipy), hace falta MATLAB real (disponible en esta máquina, `C:\Program Files\MATLAB\R2025b`) para leerlos.

**✅ Hecho 23-ago-2026 — `Cargar_Camargo_Core.m` construido y verificado con AB06 real (Test 11 de `Test_Generador.m`, PASS).** No usa el `.osim` para longitud de segmento (esa vía resultó ambigua de interpretar sin la API real de OpenSim — los frames de offset del joint aparecían en `(0,0,0)`, lo que habría requerido adivinar). En su lugar:

- **`theta_tibia_real_deg`** se calcula directo de los marcadores 3D crudos (`R_Knee_Lat`, `R_Ankle_Lat`) del ensayo de marcha real, con la **misma convención `atan2`** que ya usa `Angulo_Control_Plataforma.m` del proyecto — ningún ángulo de OpenSim de por medio para este número central.
- **`long_tibia_r_m`** = distancia 3D promedio entre esos mismos dos marcadores en el ensayo **estático** del sujeto (mm → m). Para AB06: **0.446 m** — plausible para una tibia adulta.
- **`hip_flexion_r_deg`, `knee_angle_r_deg`, `ankle_angle_r_deg`** de la tabla `ik` real (para Nivel A y para cruzar con `Reduccion_Winter_Core.m`). Para AB06, ROM de rodilla en el ensayo probado: 63.2° (plausible).
- **`pct_ciclo_R`** ya viene calculado por Camargo (columna `HeelStrike` de `gcRight/`) — no hace falta detectar eventos de nuevo.

**Pendiente, no bloqueante:** la longitud de **muslo** (para el vector completo de 14 parámetros que pide Yun 2014) todavía no se extrae — no hay un marcador limpio de cadera en este set de marcadores (serían necesarios ASIS + una estimación de centro articular de cadera, p.ej. regresión de Harrington, para no adivinar). Se agrega cuando haga falta correr Nivel A con Yun sobre datos de Camargo; no bloquea el Nivel B (que solo necesita rodilla+tobillo+tibia, ya completo).

**🐛 Bug real #1, encontrado y corregido (23-ago-2026):** la primera versión de `theta_tibia_real_deg` usaba el eje X crudo del laboratorio como si fuera la dirección de avance (anteroposterior) — **incorrecto**: Camargo camina en un circuito curvo (condiciones `cw`/`ccw`, sentido horario/antihorario), y tanto X como Z recorren metros a lo largo de un ensayo completo (verificado: X~3.3 m, Z~6.7 m, Y~0.19 m de rango). **Corregido:** se proyecta el desplazamiento horizontal (X,Z) del tobillo sobre su propia dirección neta de avance en el ensayo (primer a último frame), dando un "avance" 1D válido en el plano sagital del propio caminar. **Caveat que queda declarado, no resuelto:** la dirección se estima una sola vez por archivo — si un archivo cubre varias zancadas sobre un tramo curvo, hay un sesgo lateral pequeño; suficiente para una demo/chequeo visual, recalcular por zancada individual antes del número final de validación. Ver comentario en el código de `Cargar_Camargo_Core.m`.

**🐛 Bug real #2, encontrado y corregido (23-ago-2026, pedido por el usuario al revisar la visualización):** incluso con el eje de avance corregido, `theta_tibia_real_deg` seguía usando `atan2(vertical, avance)` — ángulo respecto a la **horizontal** (una tibia casi vertical da ~90°). El usuario notó que el número "se veía raro" (86-119°) y pidió verificar contra los CSV reales que lee el simulador. **Verificado contra `REFERENCIAS/Control_apoyo_Luis_V4.csv` y `CurvaPromedio_Plataforma_Apoyo_*.csv`: los valores reales van de -50° a +22°, centrados en 0°** — el proyecto mide el ángulo respecto a la **vertical** (0 = tibia vertical), no respecto a la horizontal. **Corregido:** se intercambiaron los argumentos del `atan2` (`atan2(avance, vertical)` en vez de `atan2(vertical, avance)`). Con ambas correcciones, el rango de θ_tibia de AB06 queda en **-28.9° a +3.6°** — mismo orden de magnitud que la referencia real del proyecto, ya plausible. **Importante sobre el alcance de esta verificación:** los CSV del simulador se usaron únicamente para confirmar la *convención de visualización/formato* (0=vertical, no 0=horizontal) — **no** se usaron como dato de entrada ni de referencia para el algoritmo generador en sí (`Zhao2026_Core.m`, `Yun2014_Wrapper.m`, `Reduccion_Winter_Core.m` no se tocaron, siguen siendo 100% literatura, por decisión explícita del usuario del 23-ago).

## 6. Visualización — página web con datos reales de AB06 (23-ago-2026)

Artifact publicado: animación de la pierna derecha (rodilla-tobillo-pie) en el plano sagital durante un ciclo de marcha completo del sujeto AB06, con lectura en vivo del ángulo tibial y de los ángulos articulares reales (cadera/rodilla/tobillo), más una curva de θ_tibia vs. %ciclo. **Es un dato real medido, no la salida de ningún modelo generador todavía** — el pie de página de la página lo aclara explícitamente para no confundir "lo que ya funciona" con "lo que el algoritmo generaría".

- Datos exportados con `docs/literatura/pdfs/yun2014_toolbox` sin tocar — un script aparte (no versionado, ver más abajo) llama a `Cargar_Camargo_Core.m` y vuelca un ciclo completo (101 puntos, remuestreado) a JSON, embebido directo en la página.
- **El script de exportación a JSON no quedó como archivo en el repo** (se corrió inline en la sesión) — si se quiere repetir con otro sujeto/ensayo, hay que rehacerlo llamando a `Cargar_Camargo_Core.m` y remuestreando cada serie con `interp1` a 101 puntos de 0-100% de ciclo, mismo patrón que el resto del proyecto.

---

## 5-bis. Por qué Camargo es SOLO validación, nunca entrada del algoritmo (23-ago-2026, aclarado a pedido del usuario)

Camargo et al. 2021 es un **dataset descriptor** (describe cómo se capturaron los datos), no un paper de modelo predictivo — no propone ninguna ecuación para generar marcha desde antropometría, a diferencia de Koopman/Zhao/Yun. Su código de MATLAB (`MoCapTools`, GitHub) procesa datos crudos → OpenSim, no genera trayectorias. No hay "algoritmo de Camargo" que adoptar como cuarto candidato.

Y aunque lo hubiera, **no se podría usar para construir Y para validar a la vez** — sería circular (regla ya cerrada en P-23/P-24, `analisis_escalamiento_Q1_generador_trayectorias.md` §7.2, "sin circularidad, innegociable"). El diseño vigente depende de que Camargo no haya tocado ningún coeficiente de los tres candidatos — por eso se mantiene estrictamente como examen final, nunca como insumo de construcción.

## 5-ter. De ángulo a posición — `Segmento_Posicion_Core.m` (23-ago-2026)

Con el ángulo absoluto de un segmento (ya calculado por cualquiera de los tres candidatos, vía `Reduccion_Winter_Core.m` o directo de Zhao) y su longitud (real, de Camargo, o estimada con de Leva 1996), la posición (x,y) de cualquier punto del segmento es trigonometría directa — sin literatura nueva. `Segmento_Posicion_Core.m` hace esa conversión: dado θ(t) y L, devuelve la posición del extremo distal (o de cualquier fracción intermedia) relativa a un origen (por defecto el extremo proximal en (0,0)).

**Esto es una pieza real del problema de `analisis_escalamiento_Q1_generador_trayectorias.md` §5** (ángulos → posición del extremo proximal de la prótesis), pero **no lo resuelve completo**: da la posición **relativa** (rodilla→tobillo, por ejemplo), no las coordenadas **x,z,φ de la plataforma real** — para eso falta encadenar el muslo (position de la cadera, que necesita el ángulo absoluto de muslo, con el mismo problema de signo sin verificar que tienen Yun/Koopman — ver §3) y, sobre todo, calibrar contra el cero real del eje sagital del banco, que depende de Mecatrónica/CAD (tarea #4 de `diseno_matematico_generador.md` §6).

## 3-bis. E2 CERRADO (23-ago-2026) — signo de cadera determinado empíricamente, y un hallazgo importante

**Método:** en vez de confiar en la etiqueta de cada canal (que puede ser engañosa — "Hip Extension" de Yun es el ejemplo exacto de por qué), se corrieron los tres candidatos en MATLAB real y se comparó la FORMA de la curva contra los hitos de marcha normal de Perry & Burnfield/Winter (misma fuente que `Reduccion_Winter_Core.m` ya cita): cadera ~+30° flexión en IC, mínimo (~-10°, extensión) cerca de 50%, sube de nuevo a ~+30° en 100%; rodilla siempre ≥0° con pico de balanceo ~60° cerca de 70%.

**Resultado — los tres candidatos usan POSITIVO = FLEXIÓN, tanto en cadera como en rodilla:**
- **Koopman:** confirmado por el propio paper ("(dorsi-)flexion and abduction defined positive") y por forma — ajuste casi perfecto contra la referencia (cadera: 29,30,23,10,-1,-9,-9,8,24,32,29 vs. referencia 30,25,15,5,-5,-10,-8,5,20,28,30).
- **Zhao:** `phi_cadera` sigue la misma forma (mínimo cerca de 50%, repunte en balanceo) — consistente con la fórmula ya verificada a texto completo, Zhao 2026 pág.8: *"the angle of the pelvis in the sagittal plane is zero during walking; thus theta_hip=phi_hip"*, y `theta_tibia = phi_cadera - phi_rodilla` (Sec. 2.6, ya codificado en `Zhao2026_Core.m` sin cambios).
- **Yun:** `R_hip_extension`, PESE A SU ETIQUETA, resultó positivo cerca de IC/fin de balanceo y negativo a mitad de ciclo — exactamente el patrón de flexión positiva, no de extensión positiva. `R_knee_flexion` se mantuvo siempre ≥0°, consistente con flexión positiva.

**Con esto se habilitó el camino "vía rodilla"** en `Yun2014_Wrapper.m` y `Koopman2014_Core.m` (nuevo, 23-ago-2026): `theta_tibia_via_rodilla = theta_muslo - phi_rodilla`, con `theta_muslo ≈ phi_cadera` (mismo supuesto pelvis-vertical=0 que usa Zhao, extendido por analogía a los otros dos candidatos — mismo marco de referencia, no un supuesto nuevo sin respaldo). `signo_rodilla=-1` (default de `Reduccion_Winter_Core.m`), sin inversión, para los tres.

**⚠️ Hallazgo real del chequeo cruzado — sin resolver, declarado como limitación, no forzado:** al comparar vía-rodilla contra vía-tobillo punto a punto, la diferencia máxima es grande y **no está localizada en una sola fase** (Yun: hasta 70° en 10-30% del ciclo; Koopman: hasta 61°). Rastreado a la causa: tanto Yun como Zhao muestran el **pico de flexión de rodilla adelantado** (~20-25% del ciclo) en vez del pico normativo tardío (~70%) — mismo defasaje en ambos candidatos, no un caso aislado. Con `theta_muslo - phi_rodilla`, una flexión de rodilla de ~50° fuera de tiempo produce un ángulo tibial de hasta −68°, fuera del rango físicamente plausible (referencia real del proyecto: −50° a +22°).

**No se inventó una causa.** Explicaciones posibles sin verificar: (a) el parámetro de entrada usado en la prueba de humo no es representativo, (b) el dataset/regresión de cada candidato tiene una convención de %ciclo distinta a la asumida (ya confirmado que Zhao la tiene — su 0% es contacto inicial IZQUIERDO, no genérico, verificado a texto completo pág.5), (c) discrepancia real de exactitud del modelo en ese tramo del ciclo. Cualquiera de las tres es una pregunta de VALIDACIÓN (Nivel A/B contra Camargo, fuera del alcance de `plan_100_generador.md`), no de este generador.

**Decisión de ingeniería tomada para la cadena cinemática (E5), declarada:** vía-tobillo como principal durante apoyo (pie fijo, ya validado por forma); vía-rodilla se calcula y se reporta como diagnóstico cruzado, pero no alimenta directamente la posición de la rodilla hasta que la validación confirme o corrija el desfase. Ver `plan_100_generador.md` E5.

## 3-ter. E3/E4 CERRADOS (23-ago-2026) — antropometría completa y temporización

**E3 — `Estimar_Antropometria_Core.m`.** Longitud de muslo/tibia/pie desde talla, con las fracciones de Drillis & Contini 1966 verificadas **directamente contra la imagen de la fuente primaria** (Winter Fig. 4.1, no un resumen de segunda mano — se descargó el PDF real y se leyó la figura): altura de cadera 0.530H, altura de rodilla 0.285H, altura de tobillo 0.039H ⇒ muslo=0.245H, tibia=0.246H, pie=0.152H. **Validado contra AB06 real (Camargo): tibia estimada 0.4428 m vs. medida 0.446 m, error −0.7%.**

**E4 — `Estimar_Velocidad_Froude_Core.m` + `Tiempo_Ciclo_Koopman2014_Core.m` + `Temporizacion_Core.m`.** Velocidad autoseleccionada por similitud dinámica (número de Froude, Fr=0.25, verificado a texto completo: Raichlen/Pontzer et al., *J Exp Biol* 214:2276-2282, 2011 — *"optimal walking speeds that correspond to the same Fr number, 0.25"* en adultos, niños, personas con enanismo y pigmeos, remonta a Alexander 1989). Duración de ciclo reutilizando la Ec. 3 de Koopman 2014 (Tabla 5, ya verificada) como motor **compartido** por los tres candidatos — no es específica de las curvas articulares de Koopman, es una regresión general tiempo↔velocidad+talla. Partición apoyo/balanceo 60%/40%, verificado (múltiples fuentes independientes de la literatura de marcha coinciden en este valor estándar, familia de Perry & Burnfield).

**⚠️ Hallazgo real de la integración, no oculto:** con Fr=0.25, la velocidad estimada supera el rango validado de Koopman (0.5-5 kph) para **prácticamente cualquier adulto** — el punto de cruce es talla≈1.48 m, así que la mayoría de sujetos (>1.48 m) van a disparar la advertencia de extrapolación ya existente en `Tiempo_Ciclo_Koopman2014_Core.m`. No es un caso raro ni un bug: es la interacción entre dos piezas verificadas por separado (Fr=0.25 tiende a dar una marcha "óptima" ligeramente rápida, ~1.5 m/s para 1.73 m; el rango de Koopman está pensado para velocidades de soporte robótico, más lentas). No se fuerza ningún ajuste del coeficiente para evitar la advertencia — se declara como limitación a revisar en la etapa de validación (¿la extrapolación degrada la exactitud de forma medible contra Camargo?), no se esconde ni se corrige a ciegas.

## 3-quater. E5-E9 CERRADOS (23-ago-2026) — cadena cinemática, temporización, escritor de CSV

**`Cadena_Cinematica_Core.m` (E5)** — posición de la rodilla relativa a un tobillo fijo (modelo de péndulo invertido, estándar en literatura de marcha, p.ej. Kuo 2007), reusando `Segmento_Posicion_Core.m` ya probado. Verificado: distancia rodilla-tobillo constante (error 7×10⁻¹⁵), y theta=0 (tibia vertical) da x=0 exacto. **Pendiente declarado, no bloqueante:** el signo de "+Y" no está cruzado todavía contra el sentido real de `Posicion_cm_Y` del CSV — solo se verificó el rango/convención angular (bug #2 de §5-bis arriba), no el signo de la posición vertical.

**`Generar_Trayectoria.m` (orquestador E1-E7)** — junta antropometría (E3) → temporización (E4) → candidato elegido → regla de vía por candidato y por fase (E2) → cadena cinemática (E5) → traslación horizontal en balanceo (E6). Corre de punta a punta para los tres candidatos, normaliza cada fase a (0,0) en su primera muestra (misma convención que `normalizeDisp` de `Desplazamientos.m`).

**`Escribir_CSV_Simulador.m` (E8)** — header verificado **byte a byte** contra `Control_apoyo_Luis_V4.csv`/`Control_balanceo_Luis_V4.csv` reales, incluida la inconsistencia real del archivo original (apoyo usa "Angulo_sagital apoyo" con espacio, balanceo usa guion bajo) — replicada tal cual, no "corregida", para mantener compatibilidad real. La precisión de escritura es fija (3/4 decimales), a diferencia del archivo real que tiene precisión variable — declarado como diferencia cosmética sin efecto funcional (el valor numérico tras el parseo es idéntico).

**`Test_Generador_Trayectoria.m` (E9)** — 14/14 pruebas PASS, incluida escritura y relectura real de un CSV completo.

**⚠️ Regresión real encontrada y corregida durante la integración:** al extraer `Tiempo_Ciclo_Koopman2014_Core.m` como motor compartido (E4), quedó una advertencia de rango duplicada (una en `Koopman2014_Core.m`, otra en la función extraída) — `lastwarn()` capturaba la última, no la que el test original (`Test_Generador.m` Test 16) esperaba, rompiendo esa prueba (21/22 en vez de 22/22). **Diagnosticado y corregido:** se quitó la advertencia duplicada de `Koopman2014_Core.m` (la extraída ya cubre el caso, sin duplicar el chequeo) y se actualizó el id esperado en `Test_Generador.m` Test 16 de `'Koopman2014_Core:fueraDeRango'` a `'Tiempo_Ciclo_Koopman2014_Core:fueraDeRango'` — consistente con el nuevo diseño (single source of truth), no un parche para forzar que pase.

## 3-quinquies. G7-bis CERRADO (23-ago-2026, 3ª pasada) — el punto seguido no siempre es la rodilla

El usuario señaló algo real, no un detalle menor: el marcador/sensor que produjo `Control_apoyo_Luis_V4.csv` está a una distancia aproximada de **0.38 m del tobillo**, no en la articulación de la rodilla exacta. Esto es un dato de montaje físico del equipo, dado directamente por el usuario — no requiere cita de literatura, pero tampoco se puede simplemente asumir 0.38 m como default universal sin la tibia real de ese sujeto (no documentada en el proyecto).

**Solución implementada:** `Cadena_Cinematica_Core.m` y `Generar_Trayectoria.m` ahora aceptan `opciones.punto_seguimiento_m` — la distancia desde el tobillo hasta el punto que se quiere seguir, con default `= long_tibia_m` (sin cambio de comportamiento si no se especifica).

**Derivación geométrica (sin literatura nueva, trigonometría directa):** si la rodilla (extremo, distancia L) queda en `(-L·sinθ, L·cosθ)` relativa al tobillo fijo, cualquier punto a distancia `d ≤ L` sobre el MISMO segmento rígido queda en `(-d·sinθ, d·cosθ)` — misma fórmula, se reemplaza L por d. Verificado: con d=0.38m y L=0.4256m, la razón de ROM horizontal generado (11.05/12.38 = 0.893) coincide exacto con la razón de distancias (0.38/0.4256 = 0.893).

**3 pruebas nuevas (16-18 de `Test_Generador_Trayectoria.m`), 18/18 PASS:**
- d=0 (tobillo mismo) da (0,0) constante en todo el ciclo.
- d > L_tibia_m dispara error controlado (no se puede seguir un punto más allá de la rodilla).
- d=0.38 da distancia constante exacta (invariante física preservada) y se propaga correctamente desde `Generar_Trayectoria.m` hasta `.metadatos.punto_seguimiento_m`.

## 7. Dos bugs reales corregidos el 26-ago-2026 (el usuario los detectó mirando las figuras con atención)

- **`Generar_Trayectoria.m`, balanceo: la rodilla podía retroceder en X y el tobillo quedaba a altura constante todo el ciclo.** Causa: el balanceo usaba la misma rotación-sobre-tobillo-fijo del apoyo (`Cadena_Cinematica_Core.m`) — ya documentado como limitación abierta en `Obtener_Theta_Tibia_Candidato.m` ("PENDIENTE, decisión de modelado... falta la cadena de muslo completa"). **Corregido:** el balanceo ahora reconstruye la cadera (a partir de la rodilla ya trasladada + el ángulo de muslo, vía `Obtener_Angulos_Candidato.m`) y construye la cadena hacia abajo (cadera→rodilla→tobillo), replicando la lógica de `Cadena_Completa_Core.m` **sin llamarla ni modificarla** (esa función sigue intacta para la validación contra Kuopio, que no incluye la traslación de apoyo E6, específica de este generador). El apoyo no se tocó. Confirmado con `Test_Generador_Trayectoria.m` (17/18 — el único FAIL es el mismo trade-off ya declarado desde el 24-ago, de apoyo, ajeno a este cambio) y visualmente en `docs/algoritmo/pipeline_koopman_kuopio/figuras/05_generador_salida_koopman.png`.
- **`Obtener_Angulos_Candidato.m`, ángulo tibial de Yun inconsistente con el resto del proyecto.** Esta función calculaba el ángulo tibial de Yun **vía rodilla**, mientras que `Obtener_Theta_Tibia_Candidato.m` (la fuente ya establecida como correcta, E2) usa **vía tobillo** — vía rodilla está marcada explícitamente como no confiable para Yun por el defasaje del pico de flexión de rodilla. El usuario lo notó comparando dos figuras del mismo candidato con formas distintas. **Corregido:** ahora usa `Y.theta_tibia_via_tobillo_R_rad`, igual que el resto del proyecto. Afecta solo a `Ver_Todos_Los_Modelos.m` (figura regenerada) — `Generar_Trayectoria.m` nunca usó el theta_tibia de esta función para Yun (usa `Obtener_Theta_Tibia_Candidato.m` directamente), así que el CSV exportado no estaba afectado por este segundo bug.

## 6. Qué NO se resuelve todavía — ni en esta carpeta ni en `plan_100_generador.md`

**El generador (E1-E9) está cerrado, 98.45/100 — ver `plan_100_generador.md` §2.** Lo que queda pendiente es, a propósito, de la ETAPA SIGUIENTE (validación), no de este generador:

- **Desfase de fase del pico de flexión de rodilla en Yun y Zhao** (§3-bis) — requiere validación contra datos reales (Camargo).
- **Signo de "+Y"** de `Cadena_Cinematica_Core.m` sin cruzar contra el sentido real de `Posicion_cm_Y` (§3-quater) — se resuelve con una curva completa comparable, en la etapa de validación.
- **Descarga y formato real de Camargo 2021** — §5 arriba (etapa de validación).
- **Cero físico del eje sagital del banco** — §4 arriba, depende de Mecatrónica (etapa de ejecución, fuera del generador por D1).
- ~~GB/T 17245-2004 vs. de Leva 1996 para masas de segmento~~ — **resuelto 27-ago-2026, ver §8**: se implementó GRF usando de Leva 1996 (no GB/T, no las Ecs. de Zhao 2026 tal cual). Sigue en `docs/algoritmo/diseno_matematico_generador.md` §6, tarea #3.

## 8. GRF (fuerza de reacción del piso) — `GRF_Newton_ApoyoSimple_Core.m` + `MasaSegmentaria_DeLeva1996_Core.m` (27/28-ago-2026)

**Por qué NO son las ecuaciones de Zhao 2026 (Sec.2.4-2.6):** esas ecuaciones dependen de una derivación de energía cinética/potencial que el propio paper remite a "supplemental materials", no disponibles — implementarlas adivinando la ponderación de cada término era el tipo de riesgo que el usuario pidió evitar explícitamente ("hazlo lo mejor que puedas sin tomar alto riesgo"). Se usa en su lugar 2da ley de Newton sobre el centro de masa (CoM) de cuerpo completo — exacta por definición, no una aproximación de Zhao — con masas y posición del CoM por segmento de **de Leva 1996** (Tabla 4, verificada directamente contra la imagen del PDF: la suma de todos los segmentos da 99.99%F/100.00%M, confirma que no hay ninguna fila mal transcrita).

**La pierna contralateral no se modela aparte:** se reusa la misma serie de ángulos (θ_muslo, θ_tibia) que ya genera el pipeline para la pierna trackeada, desfasada medio ciclo — aproximación de marcha simétrica, y además el mismo mecanismo ya verificado como real en el hallazgo del "desfase de fase de 50%" del parámetro `lado` de Zhao/Yun (`docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md` §6.7).

**Alcance v1, deliberado:** solo apoyo simple (sin el modelo de doble apoyo de Zhao Ecs.9-10) — la fuerza total calculada es exactamente la fuerza bajo la pierna trackeada SOLO cuando la contralateral está en su propio balanceo. `out.apoyo_simple_mask` marca esa ventana.

**Hallazgo real durante las pruebas (Test 8 de `Test_GRF_Newton_ApoyoSimple.m`):** `Cadena_Completa_Core.m` garantiza posición continua en el empalme apoyo→balanceo pero NO velocidad continua (el apoyo mueve la cadera por rotación de ángulos, el balanceo la mueve a velocidad constante impuesta) — invisible en las validaciones de posición ya hechas (Kuopio, Ferber), pero fatal para GRF (necesita 2da derivada): sin corrección, picos de ±3000%BW. Se corrigió con suavizado Savitzky-Golay antes de derivar, pero eso a su vez contamina ~framelen/2 muestras hacia adentro de cada borde de `apoyo_simple_mask` (min bajaba a ~3%BW ahí) — se agregó `out.apoyo_simple_mask_estricta` (mascara erosionada) para la comparación numérica real. **Dentro de esa máscara estricta, Koopman da 71-87%BW** (talla 1.70m, masa 70kg, F) — forma de "valle de mitad de apoyo" fisiológicamente razonable.

**Autochequeos que SÍ pasan (verificación física exacta, no ajustada a ningún dato):** la media de GRF vertical en un ciclo completo debe dar el peso corporal exacto (aceleración media de un ciclo periódico = 0) — da 99.7-100.2%BW en los 3 candidatos. La media de GRF horizontal debe dar ~0 (mismo argumento) — da -0.47%BW.

**Sin hacer todavía (superado en parte, ver §8-bis):** ~~validar contra fuerza REAL~~ (Kuopio, 13 sujetos, ya extraída con `Extraer_GRF_Kuopio_Core.m` — ver §8-bis). ~~Modelo de doble apoyo (v2)~~ (implementado, Zhao Ec.9 solo componente vertical). ~~Corregir la causa raíz del quiebre de velocidad en `Cadena_Completa_Core.m`~~ (resuelto para el cálculo de GRF, ver §8-bis — `Cadena_Completa_Core.m` en sí NO se tocó). Pendiente real: extraer fuerza de Fukuchi (`walkO##[C/F/S]grf.txt`); reintroducir el residuo de "rockers" del tobillo (retirado en §8-bis) de forma simétrica también para la pierna contralateral.

## 8-bis. Cadera continua (29-ago-2026) — corrige el pico numérico de doble apoyo, `Cadera_Continua_Zhao_Core.m`

**Diagnóstico (`Diag_Pico_DobleApoyo.m`):** con el reparto de doble apoyo de Zhao Ec.9 (añadido el 28-ago), aparecía un pico no físico de **hasta −265%BW / +363%BW**, simétrico, justo en las dos costuras del ciclo (≈10% y ≈90-100%). Causa raíz: el ángulo articular (Koopman/Zhao/Yun) ya es una función suave y periódica de **todo** el ciclo (`Obtener_Theta_Tibia_Candidato.m` devuelve el mismo arreglo para "apoyo" y "balanceo", solo remuestreado) — el quiebre de velocidad no está en el ángulo, está en que `Cadena_Completa_Core.m` reconstruye la cadera con **dos reglas geométricas distintas** (rotación sobre tobillo fijo en apoyo; traslación a velocidad constante en balanceo) — y ese cambio de regla ocurre en **dos** costuras (60% del ciclo, ya declarada antes; y 0%/100%, no declarada hasta ahora) — la segunda es la que corrompía la ventana de "temprano" del reparto de doble apoyo.

**Corrección:** `Cadera_Continua_Zhao_Core.m` (nueva, usada SOLO dentro de `GRF_Newton_ApoyoSimple_Core.m` — `Cadena_Completa_Core.m` no se toca, sigue siendo la fuente de verdad ya validada de RODILLA/TOBILLO) reconstruye la cadera con una sola regla para todo el ciclo, fiel a Zhao 2026 Ecs.3-4/Fig.1-3: en cualquier instante, la cadera es el extremo superior de la pierna que **en ese instante** está en el piso, rotando sobre su propio tobillo fijo — alternando de pierna cada medio ciclo (marcha simétrica), con las dos ventanas de doble apoyo mezcladas linealmente (mismo principio que la Ec.9, aplicado aquí a posición).

**Bug real encontrado en el camino:** la primera versión anclaba el tobillo contralateral SIEMPRE en `+X_step` (media zancada adelante) — correcto para la ventana "tardío" (contralateral recién aterrizado, adelante) pero **con el signo cambiado para "temprano"** (ahí el contralateral es el paso ANTERIOR, detrás, en `-X_step`) — con el signo equivocado el desajuste en el empalme era de ~108cm en vez de unos pocos cm. Corregido con dos anclas (`hip_x_contra_trailing`/`hip_x_contra_leading`), verificado que el avance neto por ciclo (`cad_x` en t=T⁻ menos en t=0) da exactamente una zancada, como debe ser.

**Resultado (candidato Koopman, el vigente):** el pico de cientos de %BW desaparece — el peor caso pasa a ser un sobreimpulso de ~190%BW en el instante de contacto inicial (alto pero fisiológicamente no descabellado, no una explosión numérica) y una forma de doble-joroba reconocible en el resto del ciclo. Contra fuerza REAL de Kuopio (13 sujetos, `Evaluar_GRF_vs_Kuopio.m`, ventana extendida por el reparto de doble apoyo): **r medio=0.40 (SD 0.08), RMSE medio=24.0%BW (SD 2.3), RMSEnorm medio=3.14** — visualmente (`Ver_GRF_vs_Kuopio_Real_figura.png`) la forma de doble-joroba de la curva completa (tramo "no confiable" incluido) sigue de cerca el rango y la forma general de la curva real, y la ventana "confiable" (apoyo simple, sin doble apoyo) se superpone casi exactamente con el valle medio-apoyo real en varios sujetos.

**Limitación declarada, no oculta:** las dos fórmulas de rotación (trackeada/contralateral) se derivan de forma independiente — no se resuelve el sistema cerrado de longitud-de-pierna (Zhao Fig.3, "the angles... form a closed-loop structure") que exigiría que ambas coincidan exactamente en el mismo punto durante el doble apoyo real. Eso deja un desajuste de valor real (no ya una explosión numérica) en las costuras, que la mezcla lineal + el suavizado Savitzky-Golay convierten en un sobreimpulso moderado en vez de un salto perfecto. **También se retiró el residuo empírico de "rockers"** (§ arriba) de esta función — reintroducirlo de forma simétrica para ambas piernas es la mejora más directa que queda pendiente si se quiere seguir afinando esta línea.

**Intento de cerrar el sistema, mismo día (el usuario señaló, correctamente, que el sobreimpulso de la mezcla lineal seguía sin parecerse a la curva real):** se probó reemplazar la mezcla lineal por el sistema geométrico cerrado que describe el propio Zhao — dos tobillos fijos a distancia conocida, cada pierna con una longitud efectiva tobillo-cadera de ese instante (ley de cosenos sobre el ángulo real de rodilla), cadera = intersección de las 2 circunferencias (raíz positiva). **Resultado: peor, no mejor.** La intersección pura no conecta con las fórmulas de una pierna en los bordes de la ventana (saltos de ~50cm, peor que la mezcla lineal); anclando el valor en los bordes con una corrección lineal arregla el salto pero deja un quiebre de pendiente que el suavizado esparce en una franja más ancha, produciendo un pico aislado de +200%BW cerca del 20% del ciclo y **bajando** la correlación real contra Kuopio (r: 0.40→0.29, RMSEnorm: 3.14→3.61). Se revirtió a la mezcla lineal (vigente, ver código y comentario de cabecera de `Cadera_Continua_Zhao_Core.m` para el detalle completo de las 2 variantes descartadas).

**Conclusión honesta de esta línea:** ninguna de las 3 versiones probadas en esta sesión (velocidad constante impuesta; mezcla lineal; intersección de círculos) resuelve el doble apoyo de forma realmente correcta — el sobreimpulso de ~140-165%BW en los bordes contra los ~70-110%BW reales sigue sin resolverse, y resolverlo de raíz probablemente exige dinámica inversa de las 2 piernas acopladas (o recalibrar el doble apoyo contra datos reales en vez de extrapolar el modelo de una sola pierna hasta ahí) — trabajo mayor, no un ajuste rápido. **Lo que SÍ es fiable hoy:** la ventana de apoyo simple (`apoyo_simple_mask_estricta`, sin doble apoyo) ya valida bien contra Kuopio real (ver figura, tramo sólido). Recomendación: restringir cualquier afirmación cuantitativa de GRF en el manuscrito a esa ventana hasta que el doble apoyo se resuelva con más fondo.

## 8-ter. ¿Por qué no usar la fórmula de Zhao "tal cual"? — 2 intentos más, ambos peores (29-ago-2026, misma sesión)

El usuario preguntó directamente: si Zhao reporta buenos resultados (ρ≥0.93, rRMSE≤11.83%, Tabla 3 y Fig.5 de su paper), ¿por qué a nosotros no nos sale bien? Respuesta corta: **nunca corrimos su fórmula completa** — `GRF_Newton_ApoyoSimple_Core.m` mezcla la cinemática de Koopman con una geometría de 2 segmentos propia y una separación entre pasos (`X_step`) asumida, tres piezas que Zhao nunca valida juntas. Se probaron dos intentos más de acercarse a lo que Zhao publica de verdad:

- **`GRF_Zhao2026_Fiel_Core.m` (nuevo):** cinemática 100% de Zhao (Ec.1-2, con el desfase +j·π nativo del propio paper, sin inventar ningún desfase de tiempo) + su simplificación geométrica declarada (Sec.2.3: *"the standing leg is simplified as a rigid rod... the swinging leg is simplified as two articulated rigid links"*). **Hallazgo clave que motivó el intento:** la fuerza VERTICAL solo necesita la posición vertical de cada segmento medida desde SU PROPIO tobillo (que siempre está en Y=0 al tocar el piso) — nunca necesita saber la separación entre los dos tobillos. Por diseño, esta versión no puede tener el error de ~100cm que tenía `X_step`. **Resultado:** la curva queda perfectamente acotada (59-155%BW, nada de picos ni valores imposibles) — pero la correlación contra Kuopio real **baja a r=0.10** (peor que el 0.40 vigente). Causa: la propia cinemática de Zhao tiene el defecto de fase ya documentado (§6.7-6.8) — geometría limpia con ángulos malos sigue dando un resultado malo.
- **`GRF_Koopman_ZhaoGeom_Core.m` (nuevo):** el ajuste que se sigue lógicamente — cinemática de Koopman (la buena) + la MISMA geometría limpia de Zhao (rígido único en apoyo, sin `X_step`). **Resultado: el peor de los 5 intentos, r=0.002** (sin ninguna correlación) — la simplificación "sin flexión de rodilla en apoyo" de Zhao, que funciona con SU PROPIA cinemática, no funciona igual de bien con los ángulos de Koopman (que probablemente predicen una flexión de rodilla en apoyo con una magnitud/convención distinta a la que Zhao asume al ignorarla del todo).

**Tabla resumen de los 5 intentos de esta sesión (Koopman salvo donde se indica, N=13 sujetos de Kuopio, ventana extendida por doble apoyo):**

| Versión | Cinemática | Geometría | r medio |
|---|---|---|---|
| Original (velocidad constante) | Koopman | 2 reglas distintas por fase | picos ±265/363%BW, no aplica r |
| **V1 — vigente** | Koopman | mezcla lineal, 2 segmentos, `X_step` asumido | **0.40** |
| V2 — intersección de círculos | Koopman | sistema cerrado real | 0.29 |
| Zhao fiel | Zhao (su propia cinemática) | Zhao fiel (rígido único, sin `X_step`) | 0.10 |
| Koopman + geometría de Zhao | Koopman | Zhao fiel (rígido único, sin `X_step`) | 0.002 |

**Conclusión honesta, sin forzarla:** la versión "más fiel a la literatura" no es la que mejor predice datos reales — un hallazgo real y contraintuitivo, no un fallo de ejecución (cada pieza se implementó y verificó por separado). Reemplazar cualquier ingrediente del híbrido V1 (cinemática, geometría, o separación entre pasos) por su versión "más correcta en el papel" empeoró el resultado las 3 veces que se intentó hoy. Las 2 funciones nuevas (`GRF_Zhao2026_Fiel_Core.m`, `GRF_Koopman_ZhaoGeom_Core.m`) se dejan en el repo como evidencia documentada de qué se probó y por qué se descartó — no se borran, siguiendo el mismo criterio que otros diagnósticos de esta carpeta (`Diag_Oraculo_GRF.m`, `DIAG_ladotrick_*.m`). **Superado por §8-quater — ya no es la mejor opción, ver abajo.**

## 8-quater. Modelo DLF peatonal (ingeniería estructural) — el mejor resultado del día, `GRF_DLF_Pedestrian_Core.m` (29-ago-2026)

Ante el fracaso de las 3 variantes de §8-ter, se buscó en un campo distinto: la ingeniería de vibración de pasarelas/pisos peatonales lleva 40+ años modelando la fuerza vertical de una persona caminando **sin pasar por ningún ángulo articular** — una serie de Fourier ajustada directamente sobre la fuerza medida, parametrizada solo por peso corporal y frecuencia de paso: *Dynamic Load Factor* (DLF).

**Fuente:** Nguyen, Lythgo, Gad, Wilson & Haritos (2022), *Int. J. of Applied Mechanics and Engineering* 27(3):103-114, DOI 10.2478/ijame-2022-0038 — verificado a texto completo (PDF público). Coeficientes derivados de **158 pisadas reales de 23 adultos jóvenes** (170cm/72kg promedio, Vicon+plataforma de fuerza), Tabla 3, columna "Mean" (no los percentiles 90/95, que son deliberadamente conservadores para diseño estructural).

**Modelo implementado:** F(t) = P·[1 + Σᵢ αᵢ·sin(2π·i·fp·t + φᵢ)], i=1..4 (los únicos con fase razonablemente establecida — Nguyen mismo declara que las fases "scatter significantly" más allá de eso; se usan las de SCI P354, citadas dentro del propio paper: 0, π/2, π, −π/2). Esta F(t) es la fuerza **combinada bajo los 2 pies** (se deriva superponiendo pisadas consecutivas) — se reparte entre las 2 piernas con el mismo principio de transferencia lineal que la Ec.9 de Zhao, pero aplicado sobre una señal ya limpia y periódica por construcción, no sobre 2 estimaciones cinemáticas independientes.

**Resultado, N=13 sujetos de Kuopio: r=0.53 (SD 0.12), RMSE=26.3%BW (SD 2.6) — el mejor de los 6 intentos de esta sesión** (vs. 0.40 del híbrido V1, 0.29/0.10/0.002 de los 3 intentos de §8-ter). Visualmente (`Ver_GRF_DLF_vs_Kuopio_figura.png`) la curva muestra la forma de doble-joroba reconocible (pico de carga ~125%BW en 10-18%, valle de medio-apoyo ~48-50%BW en 37%, segundo pico de despegue ~104%BW en 50%) que sigue razonablemente la tendencia real en los 6 sujetos de referencia, sin ningún pico ni valor imposible.

**Limitaciones declaradas:** (1) la forma es **la misma para todos los sujetos** salvo el escalado temporal por cadencia — no personaliza por antropometría más allá de masa+velocidad (a diferencia de Koopman/Zhao/Yun, que sí varían forma con talla). (2) Viene de ingeniería estructural, no de biomecánica — validado para excitación de resonancia de pisos, no como curva de referencia clínica. (3) Las fases de los armónicos 2-4 no son las que Nguyen midió (nunca las publicó con un valor único) sino las de una guía distinta (SCI P354) — mezcla de 2 fuentes, declarado. (4) El valle de medio-apoyo (~48-50%BW) sale algo más profundo que el real (~70-95%BW) — sobrestima el rango dinámico. (5) El reparto de doble apoyo sigue siendo una aproximación (transferencia lineal), no el sistema cerrado real.

**Qué sigue, en orden:** (a) decidir si se adopta como modelo vigente de GRF para el artículo, reemplazando al híbrido V1; (b) evaluar si personalizar la amplitud por antropometría (ej. escalar el rango dinámico con talla/masa, similar a la calibración afín ya usada para Koopman) mejora más el ajuste; (c) probar con los percentiles 90/95 de la Tabla 3 en vez de la media, por si el "caminante típico" de diseño estructural se ajusta mejor a población real que el promedio; (d) considerar más armónicos si se encuentran fases publicadas más allá del 4. **Superado por §8-quinquies — no es la mejor opción, ver abajo.**

## 8-quinquies. Plantilla empírica real (Fukuchi) — el modelo GANADOR, `Cargar_Fukuchi2018_GRF_Core.m` + `Personalizar_Plantilla_Fukuchi_GRF_Core.m` (29-ago-2026)

**Origen del cambio de enfoque:** el usuario señaló que, dado que %BW ya normaliza por peso, el problema real no es "derivar" una curva teórica sino encontrar **la forma verificada que sigue una persona sana en %BW** y escalarla — en vez de seguir derivando desde ángulos articulares (que fallaron toda la sesión, §8-ter) o desde una fórmula estructural (§8-quater, r=0.53). La idea: usar la fuerza REAL ya medida de un dataset independiente como la "plantilla", en vez de un modelo teórico.

**Fuente:** Fukuchi, Fukuchi & Duarte (2018), *PeerJ* 6:e4640 — el mismo dataset ya usado para RODILLA (nunca entrena Koopman/Zhao/Yun, §11-bis de `JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md`, así que validar contra Kuopio es limpio, no LOSO). El archivo correcto es `WBDS##walkOCknt.txt` ("kinetics", ya procesado por los propios autores) — **no** el `*Cgrf.txt` crudo de plataforma, que habría requerido resolver exactamente el mismo problema de detección de eventos y separación de piernas que dominó el resto de la sesión. `*Cknt.txt` ya trae `RGRFY`/`LGRFY` — la fuerza vertical de **cada pierna por separado**, ya normalizada a 0-100% del ciclo, en N/kg.

**Bug real encontrado y corregido en el camino:** en este dataset la columna vertical es **Y**, no Z (a diferencia de los archivos de ÁNGULOS del mismo dataset, donde Z sí es el plano sagital) — confirmado contra el script fuente de los propios autores (`wbdsExploratoryDA.m`: `dirGRF={'ANTERIOR-POSTERIOR','VERTICAL','MEDIAL-LATERAL'}` con `orderXYZ=[3 1 2]` mapeando la columna Y a "VERTICAL"). El primer intento usó `RGRFZ` por costumbre (así es como funciona para ángulos) y dio valores de ~3-5%BW en vez de ~100%BW — el error saltaba a la vista, no fue sutil.

**Resultado, en 3 pasos, cada uno validado contra los 13 sujetos reales de Kuopio (independiente, 0 sujetos en común):**

| Paso | Descripción | r | RMSE %BW |
|---|---|---|---|
| 1 | Plantilla plana (promedio de los 42 sujetos, sin personalizar) | 0.842 | 16.0 |
| 2 | Personalizada por velocidad+talla (regresión punto-a-punto, N=42, solo pierna R) | 0.850 | 15.1 |
| 3 (ganadora) | Personalizada v+talla, **ambas piernas combinadas (N=48) y solo adultos jóvenes (<40 años)** | **0.866** | **15.1** |

**8 variantes probadas para llegar al paso 3** (`Comparar_Variantes_Plantilla_Fukuchi.m`, mismo criterio de toda la sesión: medir, no asumir):
- Combinar R+L por sí solo no ayuda en la plantilla plana (0.838 vs 0.842) — casi lo mismo.
- Restringir a jóvenes por sí solo **empeora** la plantilla plana (0.835) — Fukuchi tiene un split bimodal limpio (24 sujetos 21-37 años, 18 sujetos 50-84 años, sin nadie intermedio).
- Pero restringir a jóvenes **combinado con personalizar por velocidad+talla** da el mejor resultado de las 8 variantes (0.866) — sugiere que la relación velocidad→forma de la curva es distinta entre jóvenes y mayores, y mezclarlos sin distinguir diluye la señal que sí existe dentro de cada grupo.
- Agregar masa como 3er predictor **empeora** (0.849 con jóvenes, sobreajuste con n=48 y 4 coeficientes × 101 puntos).

**Cómo se usa (`Predecir_GRF_Personalizado_Core.m`):** recibe antropometría (talla, masa, opcionalmente velocidad medida) y usa **el mismo motor de velocidad que el generador de trayectorias** (`Temporizacion_Core.m`/Froude) — pedido explícito del usuario, para que la velocidad asumida en la GRF sea siempre la misma que la asumida en la trayectoria generada. Devuelve `%BW(t)` y ya convertido a Newtons (`%BW/100 × masa_kg × 9.80665`) — esto es lo que se compara/calibra contra la plataforma real del simulador.

**Limitación real, visible en la figura (`Ver_GRF_ModeloFinal_vs_Kuopio_figura.png`):** varios sujetos de Kuopio caminan más lento (0.75-0.85 m/s) que el rango de los sujetos jóvenes de Fukuchi usados para el ajuste final (0.96-1.52 m/s) — el modelo **extrapola** ahí (con warning automático), y la forma degenera hacia un solo plateau en vez del doble-joroba (visible en el Sujeto 37, 0.77 m/s) — declarado, no oculto, y ya incluido en el r=0.866 reportado (no se excluyeron esos casos para inflar el número).

**Conclusión de toda la línea de GRF de esta sesión, de principio a fin:** 6 intentos basados en ángulos articulares/dinámica teórica (0.002 a 0.53) → 1 intento con fuerza directa sin ángulos pero de ingeniería estructural (0.53) → **usar datos reales medidos como plantilla, sin ningún modelo teórico de por medio (0.84) → personalizar esa plantilla con velocidad+talla y el subgrupo etario correcto (0.866)**. El salto grande de la sesión fue dejar de derivar y empezar a medir; la personalización fue la mejora fina al final, exactamente en ese orden de importancia.

**Archivos de esta sección:** `RODILLA/Fukuchi/Cargar_Fukuchi2018_GRF_Core.m`, `Construir_Plantilla_Fukuchi_GRF.m` (paso 1, plantilla plana, se mantiene como referencia/baseline), `Personalizar_Plantilla_Fukuchi_GRF_Core.m` (paso 3, el modelo vigente — construye `Modelo_Personalizado_Fukuchi_GRF.mat`), `Predecir_GRF_Personalizado_Core.m` (función de uso final), `Comparar_Variantes_Plantilla_Fukuchi.m` (las 8 variantes, evidencia documentada).

## 9. Punto de montaje protésico en la app de animación — `Aplicar_Punto_Montaje_Core.m` (02-sep-2026)

**No confundir con `opciones.punto_seguimiento_m` de `Cadena_Cinematica_Core.m`/`Generar_Trayectoria.m` (§3-quinquies) — mismo concepto físico (distancia desde el tobillo, a lo largo del segmento tibial, hasta un punto de montaje/marcador), pero DOS implementaciones separadas a propósito, cada una para su propio pipeline:**

- `Cadena_Cinematica_Core.m` → pipeline de exportación a CSV (`Generar_Trayectoria.m`), con la inversión de signo en X ya verificada contra el cableado real del banco (G7, §4).
- `Aplicar_Punto_Montaje_Core.m` (nueva) → pipeline de la app interactiva (`App_Animacion_Cadera_Rodilla_Tobillo.m`, que usa `Cinematica_DoblePendulo_Core.m` y es deliberadamente independiente del CSV, ver su propia cabecera del 30-ago-2026) — SIN esa inversión de X, convención "de libro de texto" (Y hacia arriba positivo), confirmada por el usuario (sesión de integración con GAITSIM/Raspberry, 02-sep-2026) como coincidente con la convención real de la máquina física.

Sesión que originó esto: se pidió poder ingresar en la app, como referencia visual antes de tocar la Raspberry, la distancia tobillo→punto de montaje de una prótesis transtibial real (dato del eje/longitud de la prótesis, no antropométrico — distinto de talla/masa). Input opcional (`efMontaje`, default 0 = comportamiento idéntico a antes de este cambio, sin punto nuevo dibujado). 6/6 pruebas nuevas (`Test_Punto_Montaje.m`, incluye consistencia cruzada con `Cinematica_DoblePendulo_Core.m`: a distancia=L_tibia reproduce EXACTAMENTE la rodilla), `Test_Generador.m` (22/22) y `Test_Generador_Trayectoria.m` (18/18) sin regresión.

**Pendiente, no bloqueante:** esta función no está conectada a `Generar_Trayectoria.m`/al CSV — es solo para la app de visualización. Si se decide que el punto de montaje debe salir también en el CSV real, hay que decidir con cuál de las dos convenciones (y probablemente reconciliar ambas funciones) antes de exportar nada a la Raspberry.

## 10. Ángulo tibial dependía de talla/velocidad más de lo real — `Saturar_Velocidad_Koopman_Core.m` + `congelar_vl_angulo` (02-sep-2026)

**Hallazgo (usuario, revisando la app):** el ángulo tibial daba un resultado parecido para cualquier talla — sospecha correcta. Verificado con Kuopio (N=47) y, para descartar que fuera un artefacto de una sola muestra, con una segunda base independiente descargada esta sesión — **Maastricht Normative 3D Gait Dataset, datos POR SUJETO (no solo agrupados), N=244**, `RODILLA/Maastricht/02_Overview_comf.xlsx` (OSF t72cw, carpeta raíz — el archivo `05_AgeGenderGroup_comf.xlsx` que ya estaba en el repo es solo el resumen agrupado por edad/sexo, no sirve para correlacionar con talla individual). Mismo patrón en las dos bases: SD entre sujetos real ≈5-7° en todo el ciclo (no solo a 70%) vs. SD del modelo ≈0.4°, y `|corr(talla,real)|≤0.08` siempre vs. `|corr(talla,crudo)|` hasta 0.99, con signo alternante según el tramo.

**Primer intento (velocidad Froude fuera del rango 0.5-5 kph que Koopman 2014 validó) fue INCOMPLETO** — verificado con `descomponer_v_vs_l.m` (congela cada variable por turno): el término de talla directo (`b3*l`) de cada regresión de Koopman contribuye tanto o más que el de velocidad, según el tramo. Saturar solo la velocidad (`Saturar_Velocidad_Koopman_Core.m`, saturación suave C¹ anclada en 5 kph, sin costo dentro del rango ya validado — sí se deja en el repo, es buena práctica igual) no bajó `corr(talla,crudo)` de 0.96-0.99 con ningún margen probado.

**Corrección real:** opción `congelar_vl_angulo` en `Koopman2014_Core.m` — evalúa las 4 curvas angulares con `v_ref=5 kph` (límite superior publicado) y `l_ref=1.735 m` (media agrupada Kuopio+Maastricht) fijos, en vez de la v/talla real del sujeto. La talla real sigue entrando al generador, pero SOLO por el escalamiento geométrico de L_muslo/L_tibia (Paso 4) — no por los coeficientes de Koopman. `v_ref` importa mucho más que `l_ref` (un primer intento con `v_ref=3.0`, centro del rango, empeoraba el ajuste contra Maastricht de 6.61° a 9.66° RMSE — con `v_ref=5.0` vuelve a 6.74°, sin costo real).

**Activado por defecto en `Obtener_Theta_Tibia_Candidato.m`/`Obtener_Angulos_Candidato.m`** (el pipeline de producción) — `Koopman2014_Core.m` en sí mantiene su propio default sin congelar, para no alterar los scripts de comparación de candidatos (`Evaluar_vs_Maastricht.m` y similares) que necesitan el comportamiento nativo del paper, no el de producción.

**Verificado sin degradar ninguna métrica ya publicada** (Kuopio N=47, antes→después, misma clasificación RMSEnorm en las 5): Rodilla X 1.15→1.15, Rodilla Y 0.85→0.91, Tobillo X 1.17→1.17, Tobillo Y 0.88→0.90, Ángulo tibial calibrado 1.007→**0.992** (mejora) — todas las diferencias <0.06. `Test_Generador.m` 22/22, `Test_Generador_Trayectoria.m` 18/18, sin regresión.

**Lo que NO arregla (límite estructural, no bug):** la magnitud de variabilidad entre sujetos que un generador de una sola entrada real (talla) puede producir sigue muy por debajo de la real (décimos de grado vs. 5-7° real) — esa brecha viene de estilo de marcha individual, no de talla ni velocidad, y ningún ajuste de Koopman la puede cerrar con talla como único dato de entrada. Documentado en el informe técnico, Limitaciones, como límite estructural abierto — no se inventó una corrección sin respaldo de dato real para taparlo.

### 10-bis. Congelar OBLIGA a refittear toda la cadena — no es un cambio aislado (02-sep-2026, misma sesión)

Al verificar consistencia app/informe/flujo apareció que **congelar cambia el crudo, y todo lo que se había ajustado SOBRE ese crudo queda desactualizado**. Hay que rehacer, en este orden:

1. `Calibracion_Koopman_Kuopio_Core.m` — vía `Recalibrar_Koopman_Kuopio_Core.m` (hereda el nuevo default automáticamente). Muslo 0.7926→**0.6827**, tibia 0.8516→**0.7630**.
2. `Coeficientes_Warp_Temporal.mat` — vía `Ajustar_Warp_Temporal_TallaSola.m` (X).
3. `Coeficientes_CorreccionFinal.mat` — vía `Refit_CorreccionFinal_TallaSola.m` (Y).
4. Recién entonces, las cifras/figuras oficiales: `Evaluar_CorreccionFinal_vs_Kuopio.m` e `INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial.m`.

**Hacer solo una parte deja la cadena PEOR que antes:** crudo congelado + coeficientes viejos degradaba Rodilla Y de 0.85 (Excelente) a **1.60 (Aceptable)**. Con la cadena completa refitteada: Rodilla X 1.18, Rodilla Y **0.83**, Tobillo X 1.30, Tobillo Y 0.88, Ángulo tibial **0.99** — ninguna baja de categoría y dos mejoran. Garantías re-verificadas con los coeficientes nuevos (barrido 100-230cm, 66 tallas): 0 retrocesos, 0 violaciones de monotonía en talla.

**Consumidores que hay que mantener sincronizados** (todos llaman a `Koopman2014_Core` directo, no por los wrappers): la app, `Evaluar_CorreccionFinal_vs_Kuopio.m`, `Refit_CorreccionFinal_TallaSola.m`, `Ajustar_Warp_Temporal_TallaSola.m`, `INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial.m`. Los scripts de COMPARACIÓN de candidatos (`Evaluar_vs_Maastricht.m`, `Evaluar_vs_Winter.m`, `Evaluar_vs_Ferber.m`, `Evaluar_Mejor_Modelo_Rodilla.m`, los `_Zhao`/`_Yun`) **NO** se tocan — necesitan el Koopman nativo del paper para que la comparación sea justa.

## 11-bis. Punto de montaje: FIRMA CAMBIADA 03-sep-2026 — arreglo del "cuerpo rígido" (más simple de lo que parecía)

`Aplicar_Punto_Montaje_Core.m` (ver §9 para su relación con `Cadena_Cinematica_Core.m`) convierte la distancia tobillo→montaje `d` (dato del **hardware**: longitud del eje de la prótesis — real: **15-24 cm**, NO hay ninguna longitud fija de referencia) en la trayectoria del punto que el banco realmente ejecuta.

**El límite de cuerpo rígido de más abajo (§11, historial) NO necesitaba una corrección de cuerpo rígido — necesitaba una definición distinta, más simple.** Versión vieja: caminaba `d` desde el tobillo en dirección **theta_tibia (el ángulo del MODELO)**. Como la corrección híbrida mueve rodilla y tobillo por separado, esa dirección ya no coincidía con hacia-dónde-quedó-la-rodilla-generada — el punto salía hasta 2.5 cm fuera del segmento visible. **Arreglo (el usuario lo señaló directo):** caminar `d` en dirección **al punto rodilla YA generado**, no al ángulo:

```
u  = (Pk - Pa) / |Pk - Pa|      % vector unitario tobillo->rodilla, con los DOS puntos reales
Pm = Pa + d*u
```

Con esto, distancia exacta Y sobre el segmento se cumplen **las dos a la vez, siempre**, sin importar que el segmento ya no sea rígido — verificado con error de precisión de máquina (`Test_Punto_Montaje.m` Test 7, deliberadamente con un segmento deformado). **Firma nueva:** `Aplicar_Punto_Montaje_Core(Xa_cm, Ya_cm, Xk_cm, Yk_cm, d_montaje_cm)` — recibe la rodilla en vez del ángulo. La validación de rango (`d` no puede exceder el segmento) ahora usa la longitud **real** del segmento en cada instante, no `L_tibia` nominal.

**Consumidores que había que actualizar a la firma nueva (los dos, hechos el mismo día):**
- `App_Animacion_Cadera_Rodilla_Tobillo.m` línea ~375 (ya usaba `Xk_full`/`Yk_full`, estaban en scope).
- `Generar_Trayectoria.m` línea ~140 (integrado por otra sesión en paralelo esa misma tarde, con la firma vieja — se corrigió apenas se detectó). **Caso especial encontrado ahí:** el default `punto_seguimiento_m = L_tibia_m` ("rodilla anatómica") pedía d=L_tibia como *distancia*, pero el segmento corregido a veces mide *menos* que L_tibia nominal — fallaba la validación de rango aunque "la rodilla" siempre existe trivialmente. Se resolvió a nivel de semántica (`usar_rodilla_directa`: si se pide exactamente L_tibia_m, usar `Xk_full`/`Yk_full` directo, sin pasar por la distancia) — no relajando la validación.

Firma vieja detectada y rechazada con error explícito (no falla en silencio) si algo todavía la usa — `Aplicar_Punto_Montaje_Core.m`, Test 8.

Figura del informe: `Figura_Punto_Montaje_Trayectoria.m` → `docs/.../figuras/27_punto_montaje_trayectoria.png` (Figura del §Paso 4-bis). Verificado end-to-end, talla 130-210cm, d=20cm: error de distancia y de desviación del segmento ambos ~1e-14 cm en todo el rango. `Test_Punto_Montaje.m` 8/8, `Test_Generador_Trayectoria.m` 18/18.

## 11. (historial, arreglado por §11-bis) Punto de montaje: el límite de cuerpo rígido — 02-sep-2026

`Aplicar_Punto_Montaje_Core.m` (ver §9 para su relación con `Cadena_Cinematica_Core.m`) convierte la distancia tobillo→montaje `d` (dato del **hardware**: longitud del eje de la prótesis, NO antropométrico) en la trayectoria del punto que el banco realmente ejecuta:

```
Xm = Xa - d*sin(theta_tibia)
Ym = Ya + d*cos(theta_tibia)
```

**Límite cuantificado, verificado — resuelto en §11-bis, no hacía falta cuerpo rígido:** la corrección híbrida corrige rodilla y tobillo **por separado**, así que **no preserva el segmento tibial como cuerpo rígido**. Medido (talla 1.71m, restaurando los offsets que la normalización a cero quita — misma trampa de `INCLINACION_TIBIAL/CIERRE_INCLINACION_TIBIAL.md` §3): la longitud tibial implícita entre rodilla y tobillo corregidos se desvía hasta **5.2%** de L_tibia (2.2-5.4 cm según talla), y la dirección de ese segmento se aparta hasta **7.6°** de theta_tibia. La distancia `d` al tobillo **sí** se respetaba exacta (error 1e-14 cm), pero el punto no caía exactamente sobre la recta rodilla-tobillo corregida.

## 11. `Generar_Trayectoria.m` reemplazado por completo — ya usa el pipeline validado (02-sep-2026)

**Pedido explícito del usuario:** "la exportación del CSV debe ser el último pipeline que tengo actual en mi MATLAB, nada más, lo anterior ya no me interesa". Reemplazo total, no coexistencia con flag de elegir enfoque.

**Qué se quitó:** el motor de posición anterior (`Cadena_Cinematica_Core.m` como fuente de posición + soporte multi-candidato `'Koopman'/'Yun'/'Zhao'/'Combinado'` + residuo de "rockers" en apoyo + reconstrucción manual de cadera en balanceo). Ninguna de esas piezas se borró del repo (`Cadena_Cinematica_Core.m`, `Residuo_Rockers_Tobillo_Kuopio_Core.m`, `Obtener_Theta_Tibia_Candidato.m`, `Combinar_Candidatos_Core.m` siguen existiendo — las usan otros scripts: `GRF_Newton_ApoyoSimple_Core.m`, validaciones de RODILLA/TOBILLO, `Test_Combinar_Candidatos.m`), solo dejaron de ser el motor de `Generar_Trayectoria.m`. Se borró `Test_Generador_Combinado.m` (probaba exclusivamente la integración `'Combinado'` ya removida — no queda nada que probar de eso). Se actualizaron `Ver_GRF_y_Trayectoria.m`/`Ver_Resultado_Final.m` (ya no pasan `candidato` a `Generar_Trayectoria.m`; `GRF_Newton_ApoyoSimple_Core.m` sigue siendo multi-candidato, no se tocó).

**Qué lo reemplaza:** el pipeline ya validado contra Kuopio LOSO (r=0.999/0.953/0.989 etc., ver informe técnico) — el mismo que usa `App_Animacion_Cadera_Rodilla_Tobillo.m`: `Koopman2014_Core.m` (calibrado LOSO + `congelar_vl_angulo`, §10) → `Cinematica_DoblePendulo_Core.m` + `Trayectoria_Cadera_Core.m` → `Correccion_Hibrida_PenduloDoble_Core.m`. Ya no hay parámetro `candidato` — Koopman es el único modelo vigente. `opciones.punto_seguimiento_m` se conserva con la misma semántica de siempre (G7-bis, §3-quinquies), ahora calculado con `Aplicar_Punto_Montaje_Core.m` (§9) sobre el tobillo/ángulo tibial del péndulo doble en vez de con `Cadena_Cinematica_Core.m`.

**⚠️ Corrección real durante la implementación, atrapada ANTES de aplicarse (no una regresión ya cometida) — importante para no repetir el error:** el plan original era "invertir X al final, igual que hacía `Cadena_Cinematica_Core.m` (G7)". Eso hubiera sido un error: la inversión de G7 se verificó sobre una fórmula de **rotación pura alrededor de un tobillo fijo** (sin avance de cadera mezclado en el número) — el pipeline nuevo **suma el avance de cadera (siempre creciente) dentro de la misma coordenada X** (`Cinematica_DoblePendulo_Core.m`: `Xa = Xh + L1·sin(θ1) + L2·sin(θ2)`), así que la regla de G7 no se traspasa por analogía. Se verificó de nuevo con el MISMO método (`Verificar_Signo_X_PenduloDoble.m`, correlación ángulo-vs-posición contra `Control_apoyo_Luis_V4.csv` real, 95 filas): **ni X ni Y necesitan inversión con este pipeline** — corr(ang,X) real=-0.993 vs. generado=-0.998 (mismo signo), corr(ang,Y) real=+0.529 vs. generado=+0.928 (mismo signo), y el avance neto en apoyo coincide en magnitud (real=44.27cm, generado=42.97cm, error 2.9%). Moraleja explícita: una convención de signo verificada para un modelo no se hereda automáticamente a otro modelo con distinta composición geométrica — hay que re-verificar contra el dato real cada vez, no razonar por analogía.

**Tests:** `Test_Generador_Trayectoria.m` (18/18 PASS) reescrito completo desde el Test 10 (los Tests 1-9, de antropometría/velocidad/temporización/`Cadena_Cinematica_Core.m` en sí, no cambiaron) — ahora valida el pipeline nuevo: forma de salida, formato de CSV, sin recorte de amplitud (D1), monotonía de X en el ciclo completo (garantía PAVA sobrevive el recorte de fase), signo X/Y contra el CSV real (ver arriba), orden de magnitud del avance neto (tolerancia 20%, no exacto), y los 3 casos de `punto_seguimiento_m` (0/fuera de rango/rodilla exacta). `Test_Generador.m` (22/22) sin cambios ni regresión.

**Visualización pedida por el usuario:** `Ver_Trayectoria_CSV_Exportada.m` (nuevo) — grafica X/Y/ángulo/mapa sagital exactamente como saldrían en el CSV (apoyo+balanceo, con el corte de fase marcado), para comparar contra la vista de `App_Animacion_Cadera_Rodilla_Tobillo.m`.

**Pendiente, no bloqueante, encontrado en el camino (no es de esta tarea, no se tocó):** `Test_Combinar_Candidatos.m` tiene un error de sintaxis preexistente (`Illegal use of reserved keyword "end"`, línea 55, commit del 25-ago-2026 — nunca corrió, no es una regresión de esta sesión) — `Combinar_Candidatos_Core.m` en sí no se tocó ni se probó en esta tarea.

## 12. Botón "Exportar CSV" en `App_Animacion_Cadera_Rodilla_Tobillo.m` (02-sep-2026, endurecido 03-sep-2026)

**Pedido explícito del usuario:** poder generar, uno a la vez y desde la misma app interactiva (sin script de barrido aparte), el CSV real que se sube a la Raspberry — para la talla y el punto de montaje EXACTOS que estén cargados en pantalla en ese momento. "La trayectoria final es la de ese punto" — si el punto de montaje está activo, el CSV exportado es el de ese punto, no el del tobillo.

**Implementación:** nuevo botón "Exportar CSV" junto a "Reproducir" (mismo `glCtrl`, grid ampliado de 10 a 11 columnas). Al presionarlo, `OnExportarCSV` arma `antropometria.talla_m` (el campo de talla YA está en metros, sin conversión) y `opciones.punto_seguimiento_m` (convertido de cm a m) — llama a `Generar_Trayectoria.m` + `Escribir_CSV_Simulador.m` tal cual, sin duplicar ningún cálculo. Errores de `Generar_Trayectoria.m`/`Aplicar_Punto_Montaje_Core.m` (p.ej. talla o punto de montaje fuera de rango) se capturan y se muestran con `uialert` (mismo patrón ya usado en `Recalcular`), en vez de dejar que la app se caiga.

**CAMBIO 03-sep-2026: la distancia de montaje ya NO tiene default para este botón (sí lo sigue teniendo `Generar_Trayectoria.m` en general, para trayectorias de validación).** Motivo: al leer el paper de conferencia ya aceptado se encontró que la prótesis real usada ahí tiene 42cm de eje — distinto de los ~0.38m que este proyecto tenía documentados sin verificar (§3-quinquies) — y el usuario confirmó tener al menos otro eje real de referencia (~0.21m). Como distintas prótesis tienen distinto eje, cualquier valor por defecto arriesgaría exportar la trayectoria de una prótesis distinta de la que de verdad está montada en el banco. Si `efMontaje.Value` está vacío o `<=0`, el botón rechaza la exportación con un `uialert` explicando por qué, sin generar ningún archivo — el operador tiene que ingresar el eje real de la prótesis en cada ensayo.

**Nombre de archivo (id_sujeto):** siempre `talla<N>_montaje<M>` (`N` = talla en cm, `M` = distancia de montaje en cm, ambos redondeados) — ya no existe la variante sin montaje para este botón. Carpeta de salida: `CODIGOS/GENERADOR/EXPORT_RASPBERRY/` (se crea automáticamente si no existe).

**Verificado (no con la GUI en sí — es una app interactiva, no corre en `-batch`; se verificó la lógica de exportación que el botón invoca, idéntica, con un script temporal desechado después de la prueba):** 2 casos, talla=1.72m sin punto de montaje y talla=1.72m con punto de montaje=30cm — los 4 CSV resultantes (2 casos × 2 fases) tienen tiempo estrictamente creciente, sin NaN, y el caso con punto de montaje da una posición claramente distinta del caso por defecto (9.7cm de diferencia máxima en X, esperado — 30cm desde el tobillo no es la rodilla anatómica para esa talla). `checkcode` sobre el archivo modificado: sin errores (2 avisos preexistentes de líneas 388-389, sin relación con este cambio).
