# Literatura de referencia — GRF vertical en marcha protésica transtibial

> 🟡 **Relevancia incierta tras el pivote — 19-ago-2026.** Este benchmark se construyó para la sección de corrección de Fz del artículo anterior (comparaciones simulador-vs-referencia con CSV pregrabado). Con el nuevo enfoque (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20), la relevancia depende de si el algoritmo de generación adoptado también predice GRF (el candidato Zhao et al. 2026 sí lo hace, ver `planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` §4.1) — si es así, este benchmark vuelve a ser útil tal cual. No se descarta, se re-evalúa cuando se decida el algoritmo final.

**Para qué se usa:** benchmark de la sección 5 del artículo (Fz cruda vs. corregida vs. literatura). Búsqueda hecha el 31-jul-2026 con `exa` (web search académico). No sustituye una revisión sistemática — es el punto de partida para el benchmark cuantitativo de Fz.

**Corrección importante sobre un supuesto previo:** en la sesión se había usado 100-120%BW como techo "típico" de vGRF para juzgar si el simulador sobreestima. Esta búsqueda muestra que ese número es válido solo para marcha a paso normal/cómodo — a paso rápido, o comparando el lado sano de amputados transtibiales, los picos reportados en literatura llegan a 150-170%BW. Cualquier benchmark que se use en el artículo debe estar igualado en velocidad y lado (protésico vs. sano) al protocolo real del simulador, no un número único genérico.

---

## 1. Rango de referencia "clásico" (marcha normal, paso cómodo)

**Qué encontraron:** patrón de doble pico en fase de apoyo — primer pico ~110%BW en respuesta de carga, valle ~80%BW en medio-apoyo, segundo pico ~110%BW en extensión terminal.
**Instrumento/muestra:** plataforma Kistler, comparación de GRF multiplanar en amputados transtibiales unilaterales (n=8 adultos).
**Por qué aplica:** es el valor de referencia "de libro" para marcha sana a paso cómodo — útil como piso de comparación, no como techo absoluto.
Fuente: *Abnormal Ground Reaction Forces in Individuals with Transtibial Amputation* — scholarworks.calstate.edu/downloads/vd66w140s

## 2. Picos de vGRF en marcha rápida — el más directamente comparable a picos altos

**Qué encontraron:** pico vGRF temprano en fase de apoyo de **152-170%BW**, tanto en lado sano (152.9-169.9%BW según el pie protésico) como en lado protésico (152.8-162.2%BW), durante marcha a **paso rápido**.
**Instrumento/muestra:** n=20 amputados transtibiales unilaterales, comparando 3 tipos de pie protésico (SACH, ESAR, N-ESAR), plataformas de fuerza instrumentadas.
**Por qué aplica:** es el estudio más parecido en magnitud a lo que se está viendo en los datos crudos del simulador (ver nota de sesión) — sugiere que picos en el rango 150-165%BW no son automáticamente "sobreestimación", dependen de la velocidad de marcha que se programó en el simulador.
Fuente: *Is biomechanical loading reduced in individuals with unilateral transtibial amputation during fast-paced walking when using different ankle/foot prostheses?* — POI, 2025 — journals.lww.com/poijournal

## 3. Asimetría protésico vs. sano en marcha a paso normal

**Qué encontraron:** primer pico de vGRF en lado sano ≈115%BW, sin diferencia significativa vs. grupo control sano (115.4%BW); segundo pico reducido en el lado protésico respecto al sano.
**Instrumento/muestra:** base de datos de 53 amputados transtibiales unilaterales vs. 52 controles sanos, análisis de marcha instrumentado.
**Por qué aplica:** confirma que a paso normal el lado sano se comporta como un sujeto sano (~115%BW), y da el contraste esperado con el lado protésico — relevante porque el sujeto de referencia del simulador es un sujeto sano (86 kg), no un amputado, así que este es el benchmark más cercano al dato de partida real del proyecto.
Fuente: *Gait Characteristics of Transtibial Amputees on Level Ground* — PMC10443493

## 4. Asimetría clásica protésico vs. sano — magnitud relativa

**Qué encontraron:** el lado sano experimenta hasta 21% más fuerza que el lado protésico durante la marcha; asimetría <10% en sujetos sin amputación.
**Instrumento/muestra:** revisión de múltiples estudios de plataforma de fuerza en amputados transtibiales unilaterales.
**Por qué aplica:** da un criterio de magnitud relativa (no solo valor absoluto) útil para la Discusión, al comparar la curva del simulador contra el patrón esperado de asimetría protésico/sano.
Fuente: *Unilateral transtibial prosthesis users load their intact limb more...* — PMC10550186

## 5. Tasa de carga (loading rate) — útil si se reporta la pendiente de subida de Fz, no solo el pico

**Qué encontraron:** tasa de carga de vGRF de 1400-1570 %BW/s en lado sano y 870-1010%BW/s en lado protésico, variando según rigidez del pie protésico.
**Instrumento/muestra:** mismo estudio de marcha rápida (POI 2025).
**Por qué aplica:** si el artículo termina reportando no solo el pico sino la forma/pendiente de la curva de Fz (relevante para SPM1D), esta es la métrica de comparación estándar en la literatura de prótesis.
Fuente: mismo POI 2025 citado en punto 2.

---

## Nota de sesión — diagnóstico con datos existentes (31-jul-2026, corregida)

**Primer intento (superado, no usar):** se reprocesaron los 10 archivos de `SIMULADOR/FUERZA GRF - SIM/*.txt` con la misma lógica de `Validacion_Fuerza.m` (detección de IC/TO por cruce simple de 20 N), sin diálogos interactivos, BW asumido = 86 kg. Salió 9/10 archivos válidos, pico medio 157.7%BW. Ese resultado ya no es válido — ver corrección abajo.

**Duplicados — resuelto:** `Trial00960.txt`≡`Trial00966.txt` y `Trial00961.txt`≡`Trial00967.txt` eran idénticos byte a byte (mismo MD5). Los 3 archivos duplicados (`Trial00966`, `Trial00967`, `Trial00968`) se eliminaron de `SIMULADOR/FUERZA GRF - SIM/` (`git rm`, cambio en stage, no commiteado todavía). Quedan 7 archivos únicos: `Trial00959`–`Trial00965`.

**Forma de la señal — aclarado por el equipo (confirmado 31-jul-2026):** el simulador tiene un dial de velocidad de 1 a 30. Estos trials se capturaron en un ajuste de velocidad reducida, así que toda la trayectoria —incluida la pendiente de subida de Fz— se estira proporcionalmente en el tiempo; por eso la fase de apoyo dura decenas de segundos en vez de <1 s, y por eso se normaliza en 0-60% del ciclo (igual que el resto del proyecto). **No son datos inválidos ni de una prueba distinta** — es la salida real del simulador (carpeta `SIMULADOR/FUERZA GRF - SIM/`), corrida a velocidad reducida.

**Consecuencia práctica:** el algoritmo de `Base_Datos_GRF.m` (umbral de pendiente 50 N/10ms) está calibrado para velocidad real de marcha humana — a un factor de velocidad reducido, la misma pendiente relativa se estira y cae muy por debajo de ese umbral, por lo que ese algoritmo **no detecta IC/TO correctamente en datos de velocidad reducida**, aunque los datos sean legítimos. Antes de sacar cualquier cifra de Fz de esta carpeta hace falta: (a) confirmar el factor/ajuste de velocidad exacto con el que se corrieron estos 7 trials, y (b) segmentar apoyo/balanceo usando ese factor conocido (o la duración de apoyo/balanceo ya calculada en `Angulo_Control_Plataforma.m` para el mismo ajuste de velocidad) en vez de depender de la detección por pendiente de fuerza, que solo funciona a velocidad real.

Nota histórica de esta sesión (por trazabilidad, ya resuelta): se llegó a esta conclusión correcta después de un primer diagnóstico con lógica de `Validacion_Fuerza.m` que dio 157.7%BW de pico medio — ese número parecía descartable, pero la duración que arrojaba (28.5 s) resultó consistente una vez entendido el factor de velocidad (ver abajo). No fue un error de método, fue una comparación contra el benchmark equivocado.

## Resultado validado (31-jul-2026) — sobreestimación real de Fz, primera cifra defendible

Con los 7 archivos ya deduplicados y usando el mismo umbral de cruce simple (20 N, sostenido 20 ms) que había dado la duración correcta desde el principio:

- **Factor de velocidad implícito:** duración media de apoyo observada (28.5 s) / duración real de apoyo de referencia (0.9459 s, de `REFERENCIAS/BaseDatos_Plataforma_Apoyo.mat`) = **30.2x** — consistente con lo que el equipo recordaba del dial de velocidad (aprox. 30, sin ser un valor calibrado exacto).
- **6/7 trials válidos** (`Trial00964` descartado — no se detectó IC/TO, mismo resultado que en el primer intento, probablemente un ensayo real de mala calidad, no un artefacto).
- **Pico medio del simulador: 157.3%BW (SD 5.8)**, BW asumido = 86 kg (sujeto de referencia original).
- **Comparado contra la referencia real del proyecto** (`REFERENCIAS/BaseDatos_FuerzaVertical.mat`, generada por `Base_Datos_GRF.m` a partir de `PERSONA SANA/FUERZA GRF/`, no literatura externa): pico 1 (impacto) = 98.83%BW @17% del ciclo, pico 2 (propulsión) = 104.88%BW @39%.
- **Diferencia: ~52-58 puntos porcentuales de sobreestimación.**
- **RMSEnorm = 21.1** entre la curva media del simulador y la curva de referencia real — la propia escala de clasificación de `Validacion_Fuerza.m` marca "Deficiente" desde RMSEnorm > 2; este valor es ~10 veces ese umbral.

**Interpretación:** hay una sobreestimación de Fz real y grande, no marginal — confirma que vale la pena todo el trabajo de las tres correcciones desacopladas (offset, fidelidad de seguimiento, inercia por eje). **Caveats antes de citar esto en el artículo:** (a) confirmar que BW=86 kg es efectivamente el peso usado en esta tanda específica de pruebas, no un supuesto; (b) n=6 trials de una sola tanda/sesión de captura — no se sabe si son repeticiones del mismo ensayo o condiciones distintas; (c) el factor de velocidad (30.2x) es una estimación indirecta, no un valor registrado — confirmar si el equipo tiene el dato exacto en algún log.
