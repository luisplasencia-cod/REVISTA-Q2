# Plan de trabajo — 5 semanas hacia el artículo Q2
### Simulador de marcha 3-DOF · Validación multi-instrumento y multi-sujeto

> 🚨 **SUPERADO por el pivote — 19-ago-2026.** Este cronograma y su matriz de comparaciones describen el enfoque de fidelidad de seguimiento multi-sujeto, reemplazado por completo (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20/P-21). Las fórmulas estadísticas (RMSEnorm, ICC(3,1), SPM1D, etc.) siguen siendo válidas y reutilizables — el diseño de validación en sí, no. El plan vigente está en `analisis_escalamiento_Q1_generador_trayectorias.md`.

**Objetivo del ciclo:** artículo enviado antes de la quincena de setiembre, con manuscrito prácticamente cerrado para la sesión de aceptación del 27-28 de agosto.

**Regla de oro de todo el plan:** ningún cambio de instrumento o de metodología reemplaza lo que ya existe hasta que se pruebe que funciona. Nada se ejecuta con sujetos (ni el original ni nuevos) hasta que el comité de ética apruebe el protocolo.

**Actualización 03-ago-2026 — pivote a instrumentación única:** Kinovea queda fuera de este artículo (ya no "respaldo hasta demostrar concordancia" — se decidió no usarlo ni compararlo, ver `../../CLAUDE.md`, decisión "Cambio de foco"). Todo el ciclo captura con un solo sistema, STT-IWS/iSen, condicionado a confirmar en el piloto en curso que un solo IMU en la plataforma da el ángulo de inclinación directamente (ver nota técnica en `CLAUDE.md`).

---

## 0 · Prueba piloto — lunes 3 de agosto

**Antes de la semana 1 formalmente, pero cae dentro de su rango de fechas.**

**Propósito:** confirmar si iSen entrega una trayectoria de posición (X,Y) utilizable, no solo el ángulo. Es la bisagra de la que depende si se puede reprogramar el simulador con datos inerciales más adelante.

**Con quién:** cualquier persona disponible, **no** un sujeto del estudio — esto es una prueba de software/hardware, no recolección de datos de investigación, así que no depende de la aprobación de ética.

**Configuración de sensores:**
- 1 a 3 STT-IWS. No usar los 14 — con uno en la tibia (posición equivalente a donde iban M1/M2 en Kinovea) alcanza para esta prueba. Si hay tiempo, agregar un segundo en el pie para tener referencia de segmento adyacente.
- Frecuencia de muestreo: 100 Hz mínimo (el sistema soporta hasta 400 Hz; no hace falta el máximo para esta prueba, pero sí superar los 120 fps que usaba la cámara Sony, para no perder resolución temporal).

**Protocolo de la prueba:**
1. Calibración estática del sistema (N-pose o T-pose según indique el manual de iSen) — practicarla antes, no improvisarla el mismo día.
2. Caminar 3 a 5 ciclos de marcha en el mismo espacio de laboratorio usado antes.
3. Exportar en paralelo: (a) ángulo crudo de orientación de cada sensor (no el ángulo articular del protocolo de marcha por defecto — el que se necesita es la inclinación absoluta respecto a la gravedad, no el ángulo relativo entre dos segmentos), y (b) cualquier variable de posición/desplazamiento que el software ofrezca.

**Criterio de decisión (medirlo, no estimarlo a ojo):**
- Marcar con cinta métrica una distancia caminada conocida (por ejemplo, 3 m, la misma referencia que ya usan para la calibración píxel-métrica de Kinovea).
- Comparar la distancia horizontal reportada por iSen contra esa distancia real.
- **Umbral sugerido:** si el error de posición es menor al 10-15% de la distancia real y la curva no muestra deriva creciente y evidente ciclo a ciclo → posición utilizable, seguir adelante con el plan de reprogramación. Si el error es mayor o la curva se ve inestable → descartar la posición para este ciclo, usar iSen solo para el ángulo.

**Qué comparte esta sesión con el resto del equipo:** un archivo corto (crudo + procesado) y una conclusión de una línea: "posición utilizable" o "posición no utilizable, seguimos con Kinovea para X,Y".

---

## Semana 1 · 30 jul – 5 ago

| Actividad | Detalle |
|---|---|
| Enviar protocolo de ética | Máxima prioridad del lunes. Sin esto, nada de lo que sigue con sujetos avanza. |
| Prueba piloto iSen (lunes) | Ver sección 0. |
| Elegir revista Q2 | Define desde ya el formato de figuras, límite de palabras, y si el abstract es estructurado o no. Candidatas razonables dado el tema: *Medical Engineering & Physics*, *Sensors*, *Prosthetics and Orthotics International*, *IEEE Transactions on Neural Systems and Rehabilitation Engineering*. |
| ~~Pesar el ensamblaje móvil del simulador~~ | **SUPERADA (13-ago-2026, `DISCUSION_Q2.md` P-5) — no se hace.** El equipo descartó pesaje y CAD: el peso del ensamblaje no se distribuye uniforme, así que un número único de masa no lo resuelve. `m_eje` se infiere ahora del barrido de alturas de offset (fila siguiente) — ver el detalle resuelto más abajo, sección "Corrección inercial por eje". Fila conservada como historial, no como tarea vigente. |
| **Calibración del offset vertical inicial** *(nuevo, 31-jul)* | Variar la altura de arranque de la trayectoria vertical en pasos de mm/cm y medir el efecto en Fz vía AMTI, con una prueba de carga independiente de los sujetos del estudio. Fijar el offset (criterio: mínimo RMSE contra literatura de GRF protésica) y congelarlo antes de las pruebas reportadas en Resultados. **Sin ejecutar todavía — pendiente.** |
| Revisar logs de encoder del ESP32 | Si ya existen, extraerlos. Si no, programar que se guarden — necesarios para separar error de control de error de medición. Incluye comparar posición comandada vs. ejecutada bajo carga de reacción, para detectar sobre-recorrido mecánico (p. ej. holgura de cadena/piñón en el eje vertical). |
| Correr SPM1D sobre curvas existentes | Ángulo tibial (apoyo y balanceo) y Fz (apoyo), simulador vs. referencia Kinovea/AMTI. **Listo (02-ago-2026):** `CODIGOS/ESTADISTICA/Aplicar_SPM_BlandAltman_CurvasExistentes.m`, solo falta correrlo con las carpetas reales. |
| ~~Correr Bland-Altman sobre esas mismas curvas~~ | **Revisado (02-ago-2026): no aplica con los datos actuales.** Los `.mat` de referencia solo tienen media±SD, no ensayos individuales de Kinovea — sin pares reales no hay Bland-Altman honesto. Lo que sí corre hoy sobre esas curvas es SPM1D de una muestra (fila de arriba). El primer Bland-Altman real del proyecto es la comparación IMU de Alessandro vs. STT-IWS (semana 2, ver abajo) — detalle completo en `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md` sección 3. |
| Buscar literatura de GRF en marcha protésica real | No la del sujeto sano — el benchmark correcto para explicar la sobreestimación de Fz. |
| Alessandro: revisión de estado del arte | Simuladores instrumentados / sensórica embebida en gait simulators. |

**Cierre de la semana:** ética enviada, prueba piloto resuelta (posición sí/no), peso del ensamblaje registrado, primeros resultados de SPM/Bland-Altman sobre datos existentes.

---

## Semana 2 · 6 – 12 ago

| Actividad | Detalle |
|---|---|
| Corrección inercial de Fz | Aplicar las tres etapas desacopladas (ver sección de fórmulas): offset vertical ya calibrado y congelado → fidelidad de seguimiento ya verificada → corrección inercial por eje sobre lo que quede, restando de la Fz medida por el AMTI. Depende de que la calibración del offset (semana 1) ya tenga resultado. |
| Comparación de tres curvas de Fz | Cruda / corregida por inercia / referencia de literatura protésica — en una sola figura. |
| Comparación trayectoria comandada vs. ejecutada (encoder) | Si el dato quedó disponible en semana 1. |
| Redactar Introducción y Métodos (borrador) | Diseño condensado (remite al paper de conferencia) + protocolo de validación con las métricas ya definidas. |
| Armar tabla comparativa contra simuladores previos | Con la revisión de Alessandro de semana 1. |
| Preparar protocolo de la sesión de recaptura oficial | Checklist de calibración iSen, número de sensores, ubicación anatómica, cuántos ciclos por fase — dejar todo listo para ejecutar apenas llegue la aprobación de ética. |
| ~~Sesión conjunta: IMU de Alessandro vs. STT-IWS~~ | **Fuera de alcance de este artículo (revisado 03-ago-2026)** — el pivote a instrumentación única (solo STT-IWS/iSen) saca al IMU de Alessandro de este ciclo por completo, no solo como comparación secundaria. Sigue siendo válida para el segundo artículo de Alessandro si él quiere hacerla por su cuenta, pero ya no es una entrega de esta semana. |

**Cierre de la semana:** explicación cuantificada de la sobreestimación de Fz lista, Métodos redactado, protocolo de recaptura listo para ejecutar, concordancia Alessandro-vs-STT calculada.

---

## Semana 3 · 13 – 19 ago — semana de decisión

**Punto de control día 1 de la semana:** ¿llegó la aprobación de ética?

### Si SÍ llegó:

**Revisado 03-ago-2026:** con el pivote a instrumentación única, la recaptura del sujeto original ya no necesita doble instrumentación simultánea — se simplifica a una sola sesión con STT-IWS/iSen. Esta recaptura **reemplaza** la base de referencia derivada de Kinovea (`PERSONA SANA/`, `REFERENCIAS/*.mat`) como fuente de la trayectoria fija del simulador para este artículo — no se compara contra Kinovea, no se cita el paper de conferencia (ver `../../CLAUDE.md`).

| Sesión | Quién | Qué capturar | Parámetros |
|---|---|---|---|
| Recaptura del sujeto original (86 kg / 1.74 m) | Solo STT-IWS/iSen (un único instrumento, montado en la plataforma para medir su salida y sobre el sujeto para su captura natural — ver nota técnica de un solo IMU en `../../CLAUDE.md`) | Ángulo tibial (inclinación absoluta respecto a la gravedad, no ángulo articular calibrado a T-pose), apoyo y balanceo | **10 ciclos por fase**, igual que en la Fase 0 original — mantiene comparabilidad de diseño, aunque el RMSE intra-sujeto ya reportado (1.41° apoyo, 2.53° balanceo) es de la conferencia y no se cita como referencia numérica en este artículo |
| Sujetos nuevos (objetivo 15-20 personas, ver `CODIGOS/MULTISUJETO/`) | Solo STT-IWS/iSen | Marcha natural, sin reprogramar el simulador todavía | **Mínimo 5 ciclos por fase, ideal 10** si el tiempo alcanza — si se reduce a 5, dejarlo declarado como limitación menor en Métodos |

**Con los datos del sujeto original recapturado:**
- Regenerar el CSV con los datos del STT-IWS/iSen, reprogramar el simulador, ejecutar, capturar la salida del simulador (STT-IWS/iSen montado en la plataforma) → establece la nueva trayectoria fija de referencia para todas las comparaciones de este artículo, reemplazando la base derivada de Kinovea.
- `GENERAR CURVS DE REFERENCIA/` (`Angulo_Control_Plataforma.m`, `Desplazamientos.m`, `Base_Datos_GRF.m`) está construido para parsear CSV de marcadores de Kinovea, no orientación de iSen — va a necesitar adaptarse o un script equivalente nuevo para este formato de datos antes de poder regenerar `REFERENCIAS/*.mat` con la nueva fuente.

**Con los datos de cada sujeto nuevo:**
- **Comparación A (representatividad):** su captura natural vs. la salida **ya existente y fija** del simulador (la que corre con la trayectoria del sujeto original) — sin gastar nada adicional, es el mismo dato que usarían para programar su propio CSV, comparado una segunda vez.
- **Comparación B (robustez del seguimiento):** generar su propio CSV, reprogramar el simulador, ejecutar, capturar la salida, comparar contra su propia captura — repite la validación de fidelidad tantas veces como sujetos nuevos haya.

### Si NO llegó la aprobación:
- No se toca a nadie, ni al sujeto original ni a los nuevos — recapturar es recolección de datos nueva, aplica la misma regla.
- Se redacta con honestidad la limitación de n = 1 para el brazo cinemático, apoyada en la concordancia Alessandro-vs-STT y en todo lo construido en semanas 1-2.

**Cierre de la semana, en cualquiera de los dos casos:** todos los números de Resultados quedan definitivos — nada entra "preliminar" a la semana 4.

---

## Semana 4 · 20 – 26 ago

| Actividad | Detalle |
|---|---|
| Redactar Resultados completo | Con la matriz de comparaciones de la sección 10 de este documento. |
| Redactar Discusión | Comparación con literatura, fuentes de error desacopladas, generalización (o su ausencia) según lo que haya pasado en semana 3, párrafo de trabajo futuro (algoritmo generador de trayectorias, control PID con sensores de Alessandro). |
| Redactar Conclusiones | |
| Ensamblar manuscrito completo | Secciones, figuras, tablas, referencias. |
| Revisión cruzada interna | Cada uno lee una sección que no escribió. |
| Enviar a Dante y esperar su revisión | Bloquear tiempo real de respuesta. |
| Iterar según comentarios | |

---

## Hito · 27–28 de agosto — sesión de aceptación
El manuscrito debe estar en versión casi final para esta fecha.

---

## Semana 5 · 29 ago – 4 sep

| Actividad |
|---|
| Incorporar comentarios de la sesión de aceptación |
| Formatear según la revista elegida |
| Redactar carta de presentación (relación con el paper de conferencia, qué es nuevo) |
| Revisar porcentaje de contenido nuevo vs. paper de conferencia |
| Actualizar repositorio de GitHub con scripts y datos nuevos |
| Revisión final de figuras, tablas, referencias |
| Enviar |

## Colchón · 5–15 sep
Margen de seguridad para imprevistos y firmas de coautores.

---

## Estructura estándar del manuscrito (IMRaD)

1. **Title** — evitar "Experimental Validation" a secas. Título de trabajo (revisado 03-ago-2026 tras el pivote a instrumentación única): *"Multi-Subject Functional Validation of a 3-DOF Gait Simulator for Transtibial Prosthesis Testing Using Inertial Motion Capture"* (detalle y alternativas en `propuesta_articulo_Q2.md`, sección 2).
2. **Abstract** (estructurado o no, según la revista elegida)
3. **Keywords**
4. **Introduction** — motivación clínica, estado del arte, brecha respecto al paper de conferencia
5. **Methods**
   - 5.1 System description (condensado, autocontenido — ya no cita el paper de conferencia, ver `../../CLAUDE.md`)
   - 5.2 Instrumentation (STT-IWS/iSen, AMTI — revisado 03-ago-2026, ya no incluye Kinovea ni el IMU de Alessandro)
   - 5.3 Experimental protocol (sujeto original, sujetos nuevos, número de ciclos, calibración)
   - 5.4 Statistical analysis (fórmulas de la sección siguiente)
6. **Results** — un subapartado por cada fila de la matriz de comparaciones (sección 10)
7. **Discussion** — interpretación, limitaciones explícitas, trabajo futuro
8. **Conclusion**
9. **Declarations** — aprobación ética, conflicto de interés, financiamiento, disponibilidad de datos/código
10. **References**

---

## Fórmulas estadísticas a aplicar

**RMSE normalizado** (ya usado en la conferencia, mantener):

```
RMSEnorm = sqrt( (1/N) · Σ [ (S(ti) − E(ti)) / σ(ti) ]² )
```
S = señal del simulador, E = señal de referencia, σ = desviación estándar de la referencia en cada punto.

**Coeficiente de correlación de Pearson (r)** — mantener, pero interpretar con cautela en curvas monótonas (ver nota en Discusión sobre por qué no basta solo).

**Porcentaje de puntos dentro de ±1 SD** — mantener.

**ICC(3,1)** — mantener para repetibilidad entre repeticiones y para concordancia entre instrumentos.

**Statistical Parametric Mapping (SPM1D)** — nuevo. Se aplica sobre las curvas completas del ciclo (no solo el resumen numérico), identifica en qué porcentaje del ciclo hay diferencia estadísticamente significativa entre dos curvas. **Implementado y validado (02-ago-2026):** versión no paramétrica por permutación (sign-flip para diseño pareado, shuffle de etiquetas para independiente) en vez del SPM paramétrico clásico de random field theory — el propio paquete `spm1d` recomienda permutación para el tamaño de muestra esperado aquí (5-10 ensayos, 2-3 sujetos nuevos). Herramienta: `CODIGOS/ESTADISTICA/SPM1D_Core.m`, validada con datos sintéticos en `Test_SPM1D_BlandAltman.m` (7/7 pruebas OK). Guía de interpretación con literatura de respaldo: `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md`.

**Bland-Altman** — implementado (02-ago-2026): `CODIGOS/ESTADISTICA/BlandAltman_Core.m`, con IC95% de bias y límites de acuerdo (Bland & Altman, 1999) y chequeo de sesgo proporcional; validado con datos sintéticos. **Sin uso en este artículo (revisado 03-ago-2026):** estaba pensado para comparar pares de mediciones entre dos instrumentos (Kinovea vs. STT-IWS, Alessandro-IMU vs. STT-IWS) — ambas comparaciones quedaron fuera de alcance tras el pivote a instrumentación única (ver `../../CLAUDE.md`, decisión "Cambio de foco"). La herramienta queda construida y probada, disponible si el equipo retoma esa validación cruzada más adelante (segundo artículo). Detalle completo en `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md` sección 3.

**Explicación de la sobreestimación de Fz** — nuevo, revisado en sesión del 31-jul-2026: tres fuentes de error desacopladas, no un solo término de corrección. El simulador no es un sólido rígido único (tablero electrónico fijo en un lado, tres motores independientes — horizontal, vertical, sagital — cada uno con su propia cadena cinemática en el otro), así que `m_plataforma × a(t)` sobre la masa total no es representativo.

1. **Calibración de offset vertical inicial (datum).** El eje vertical arranca la trayectoria desde una altura de referencia que puede no coincidir exactamente con la superficie real del AMTI, generando compresión sistemática de más o de menos. Se calibra variando esa altura de arranque en pasos de mm/cm y midiendo el efecto en Fz, con una prueba de carga **independiente** de los sujetos que luego se reportan en Resultados (para no caer en ajustar el instrumento con el mismo dato que después se usa para validar). Criterio de offset óptimo: el que minimiza el RMSE contra la referencia de literatura de GRF protésica, no contra la curva de ningún sujeto del estudio. Se fija una sola vez y queda congelado para todas las pruebas del artículo. **Estado: pendiente, sin datos aún.**
2. **Fidelidad de seguimiento.** Comparar posición comandada por el CSV vs. posición real del encoder del ESP32, por eje, con y sin carga de reacción. Si hay sobre-recorrido sistemático (p. ej. el eje vertical baja más de lo comandado bajo carga, por holgura de cadena/piñón o torque insuficiente del motor), se calibra el actuador una sola vez, de forma genérica, antes de continuar — esto es calibración de instrumento, no cambia la forma de operar el simulador (sigue siendo CSV pregrabado, sin lazo cerrado).
3. **Corrección inercial por eje**, sobre lo que quede después de (1) y (2):
```
a_eje(t) = d²x_eje(t)/dt²        (trayectoria programada de cada eje, derivada dos veces, filtrada)
F_inercial,eje(t) = m_eje · a_eje(t)
Fz_corregida(t) = Fz_medida(t) − Σ F_inercial,eje(t)
```
   `m_eje` es la masa que efectivamente acelera con cada motor (horizontal, vertical, sagital) según el orden real de montaje de la cadena cinemática (ejes anidados: el motor de más aguas arriba mueve todo lo que está montado sobre él) — no la masa total del ensamblaje, y excluyendo componentes fijos al bastidor (p. ej. el tablero electrónico) que no aceleran. Para el eje sagital, si es rotacional y desplaza verticalmente el punto de contacto, usar cinemática rotacional del punto (`a = α×r + ω×(ω×r)`) en vez de tratarlo como aceleración lineal de una trayectoria.
   **Resuelto (13-ago-2026, ver `DISCUSION_Q2.md` P-5):** el equipo descarta CAD y pesaje por una razón más sólida que "poco preciso" — la fuerza y el peso del ensamblaje móvil no se distribuyen de forma uniforme, así que un número único de masa no lo resuelve. `m_eje` deja de calcularse a priori (CAD/balanza) y pasa a **inferirse indirectamente del mismo barrido de alturas de offset del punto (1)**: se corre la prueba de calibración de offset en varios puntos de altura de arranque, y de la curva altura→Fz resultante (contra la plataforma real) se infiere qué parte del residuo, más allá de lo que explica la compresión de offset, es atribuible a efecto inercial — en vez de un `m_eje` fijo multiplicado por `a_eje(t)` conocido de antemano. Los puntos (1) y (3) pasan a ser **un solo ensayo empírico**, no dos independientes: la misma prueba de calibración del offset vertical (`CODIGOS/CALIBRACION/`, bloqueada por la integración RPi-ESP32) alimenta ambos. El aislamiento exacto de cuánto del residuo es inercia vs. offset residual queda como parte del análisis a definir cuando haya datos reales — se declara la limitación de que no es una separación perfecta, pero es una fuente cuantificada, no narrada.

### Protocolo detallado de la prueba de calibración del offset vertical (punto 1)

**Bloqueada hasta que termine la integración Raspberry Pi–ESP32** — sin ella no hay ningún movimiento posible del eje vertical, ni siquiera estático. Diseñar ahora para ejecutar sin fricción el día que se pueda.

Informado por el formato real de exportación del AMTI (visto en `SIMULADOR/FUERZA GRF - SIM/*.txt`, reutilizable para esta prueba):

1. **Carga de referencia:** usar un peso muerto conocido (no un sujeto ni la curva de marcha de referencia) — p. ej. una masa calibrada colocada de forma estática sobre la plataforma. El valor esperado de Fz en reposo es conocido de antemano (`peso_kg × 9.81`), lo que da una verdad de referencia exacta para calibrar el offset, a diferencia de usar Fz de un sujeto caminando.
2. **Barrido de offset:** mover el eje vertical (una vez disponible) en incrementos de 2-5 mm dentro de un rango razonable alrededor de la altura nominal de contacto (p. ej. ±20 mm), sosteniendo cada posición en estático el tiempo suficiente para una lectura estable del AMTI (no un tránsito rápido tipo paso).
3. **Formato de exportación:** cada punto de offset genera un `.txt` de 6 columnas separadas por coma (probablemente Fx, Fy, Fz, Mx, My, Mz — Fz en columna 3, igual que en los archivos existentes), muestreado a 1000 Hz. **Cuidado con la conversión lbf→N:** el pipeline existente (`Validacion_Fuerza.m`) decide la conversión con la heurística `max(Fz_raw) < 500`, que asume magnitudes de un sujeto caminando (cientos de N/lbf); con un peso muerto de calibración más pequeño esa heurística puede fallar — mejor confirmar la unidad directamente en la configuración del software de adquisición del AMTI, no inferirla del valor.
4. **Higiene de datos — lección de esta sesión:** verificar que cada archivo exportado sea único (checksum) antes de analizar. Se encontraron archivos duplicados byte a byte en `SIMULADOR/FUERZA GRF - SIM/` (`Trial00960`≡`Trial00966`, `Trial00961`≡`Trial00967`), probablemente por guardado repetido del software del AMTI — revisar que no vuelva a pasar con los datos nuevos.
5. **Lectura de Fz:** tomar la media de Fz en la ventana estable de cada offset (no un pico transitorio, porque es una prueba estática, no un paso).
6. **Criterio de offset óptimo:** graficar offset (mm) vs. Fz medio (N). Si la relación es aproximadamente lineal (esperable por rigidez estructural), el offset óptimo es el que hace que Fz medido coincida con el peso conocido de la carga de referencia (sin amplificación ni déficit). Ese offset se fija una sola vez y se congela para todas las pruebas del artículo.
7. **Convención de nombres de archivo (obligatoria, nueva 31-jul-2026):** `Offset_<mm_con_signo>_<numero_de_ensayo>.txt` — ejemplos: `Offset_+10_1.txt`, `Offset_-5_2.txt`, `Offset_0_1.txt`. El signo (positivo = más alto que el nominal, negativo = más bajo) lo define el equipo antes de capturar; lo importante es ser consistente, porque el script de análisis (punto siguiente) parsea el offset directamente del nombre del archivo.

**Script listo para analizar esto en cuanto haya datos** (nivel de rigor tipo curva de calibración de instrumento, no solo un ajuste lineal de cortesía — validado con datos sintéticos, ver abajo):

- `CODIGOS/CALIBRACION/Calibracion_Offset_Core.m` — núcleo del análisis, sin diálogos. Regresión lineal offset(mm)→Fz(N) sobre ensayos individuales (no promedios), con IC95% de pendiente e intercepto, R²/R² ajustado, prueba F global, **prueba de falta de ajuste (lack-of-fit)** cuando hay réplicas en ≥3 niveles de offset (Draper & Smith 1998; mismo principio que ISO 8466-1), predicción inversa del offset óptimo con su IC95% propagado (fórmula clásica de calibración inversa, Miller & Miller), y diagnóstico de normalidad de residuos (Jarque-Bera). Exporta CSV, `.mat` y dos figuras (curva de calibración + diagnóstico de residuos).
- `CODIGOS/CALIBRACION/Calibracion_Offset_Vertical.m` — interfaz interactiva (diálogos para carpeta y peso de referencia), llama al núcleo.
- `CODIGOS/CALIBRACION/Test_Calibracion_Offset.m` — prueba automatizada: genera `.txt` sintéticos con una relación offset↔Fz conocida de antemano y verifica que el núcleo la recupere. **Ya se corrió (31-jul-2026) y el pipeline recupera correctamente pendiente, intercepto y offset óptimo dentro de su IC95%.**
- **Lección de la prueba, ya incorporada al script:** si la ventana "estable" se promedia completa desde su primer punto, una cola residual del transitorio de asentamiento (antes de que la fuerza termine de estabilizarse) deja un sesgo sistemático que escala con la magnitud de Fz — apareció como una curvatura significativa en la prueba de falta de ajuste. Se corrigió promediando solo la segunda mitad de la meseta detectada. **Recomendación para la prueba real:** sostener cada punto de offset el tiempo suficiente para que el transitorio mecánico se asiente completamente antes de terminar la captura, no cortar apenas se estabiliza.
- Parámetros que siguen siendo de partida, no calibrados: el umbral de variabilidad para considerar una meseta "estable" (3 N) — hay que ajustarlo con el ruido real del AMTI en cuanto existan datos reales.

---

## Matriz de comparaciones — qué va contra qué

| # | Comparación | Qué demuestra | Depende de |
|---|---|---|---|
| 1 | ~~Kinovea vs. STT-IWS (mismo sujeto, misma sesión)~~ | ~~Concordancia entre instrumentos~~ | **Fuera de alcance de este artículo (03-ago-2026)** — instrumentación única, ver `../../CLAUDE.md`. Herramienta (`BlandAltman_Core.m`) construida y disponible si se retoma más adelante. |
| 2 | ~~IMU de Alessandro vs. STT-IWS (montados juntos en la plataforma)~~ | ~~Confiabilidad del sensor de bajo costo~~ | **Fuera de alcance de este artículo (03-ago-2026)** — el IMU de Alessandro no forma parte de este ciclo. Queda para su segundo artículo. |
| 3 | Simulador reprogramado por sujeto vs. captura propia de ese sujeto | Robustez de la fidelidad de seguimiento (no es un golpe de suerte de una sola curva) | Ética (sujetos nuevos) |
| 4 | Salida fija del simulador (trayectoria original) vs. variabilidad natural de sujetos nuevos | Representatividad de la trayectoria por defecto | Ética (sujetos nuevos) — mismo dato que la comparación 3, sin costo adicional |
| 5 | Fz cruda vs. Fz corregida (offset + seguimiento + inercia por eje) vs. literatura protésica real | Explicación cuantificada del error, desacoplada en sus tres fuentes, no solo narrada | Calibración del offset vertical (pendiente, sin datos aún) — el resto se puede hacer en semana 2 |
| 6 | Repetibilidad inter-repetición (ICC) por condición | Consistencia del simulador | Ya existe para el dataset original, se repite para cada condición nueva |

---

## Checklist rápido de parámetros de captura (para pegar en el cuaderno de laboratorio)

- [ ] Sensores STT-IWS: 1-3 para pruebas, ubicación tibial (+ pie si hay tiempo)
- [ ] Frecuencia de muestreo: ≥100 Hz
- [ ] Calibración estática (N-pose/T-pose) antes de cada sesión
- [ ] Ángulo exportado en crudo (orientación por sensor), no el protocolo de articulación completo
- [ ] Verificar convención de ejes contra el atan2 ya usado (positivo arriba de la horizontal)
- [ ] Ciclos por fase: 10 (sujeto original), 5-10 (sujetos nuevos)
- [ ] Registrar peso corporal y altura de cada sujeto nuevo (igual que se hizo con el original)
- [ ] Guardar tanto el archivo crudo por sensor como la curva procesada
