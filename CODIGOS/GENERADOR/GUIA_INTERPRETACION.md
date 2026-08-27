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
- **GB/T 17245-2004 vs. de Leva 1996** para masas de segmento — solo importa si se usa la parte dinámica (GRF/momentos) de Zhao 2026, que esta carpeta no implementa (solo cinemática). Sigue en `docs/algoritmo/diseno_matematico_generador.md` §6, tarea #3.
