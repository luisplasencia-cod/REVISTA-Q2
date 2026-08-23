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
| `Test_Generador.m` | Prueba las cinco funciones de arriba — sintéticas (Partes A/B) + reales cuando los datos externos están en disco (Partes C/D/E) | 🟢 **16/16 PASS, corrido en MATLAB real** (`/c/Program Files/MATLAB/R2025b`, disponible en esta máquina) |

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

## 4. Convención de ángulos — lo que falta antes de generar un CSV real

**`theta_tibia_rad` de `Zhao2026_Core.m` y `theta_tibia_via_tobillo_*_rad` de `Yun2014_Wrapper.m` NO están todavía en la convención `atan2` del proyecto** (positivo por encima de la horizontal, negativo por debajo — la misma que usa `Angulo_Control_Plataforma.m` y todo `REFERENCIAS/`).

- Zhao 2026 define su ángulo respecto al **eje vertical del mundo**, no a la horizontal.
- El supuesto de pie plano (`theta_pie = 0`) fija el cero en el ángulo del pie, no necesariamente en la horizontal de la plataforma.

Antes de que cualquier salida de esta carpeta alimente un CSV real del simulador, hace falta un paso de conversión explícito (posible offset de 90° y/o cambio de signo) — **y ese paso depende de cómo el equipo de Mecatrónica define el cero del eje sagital del banco**, no es una decisión de literatura. Ver tarea pendiente #4 de `docs/algoritmo/diseno_matematico_generador.md` §6 ("confirmar con Mecatrónica/CAD").

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

## 6. Qué NO se resuelve todavía en esta carpeta

- **Signo del camino "vía rodilla" para Yun 2014** — §3 arriba.
- **Conversión a la convención `atan2`/horizontal del proyecto** — §4 arriba.
- **Descarga y formato real de Camargo 2021** — §5 arriba.
- **GB/T 17245-2004 vs. de Leva 1996** para masas de segmento — solo importa si se usa la parte dinámica (GRF/momentos) de Zhao 2026, que esta carpeta no implementa (solo cinemática). Sigue en `docs/algoritmo/diseno_matematico_generador.md` §6, tarea #3.
