# Cierre: TOBILLO — 25-ago-2026

> **Modelo vigente: §8.** Las secciones §1-§7-bis son el historial de cómo se llegó ahí y conservan números ya superados. La prueba de referencia es la individual, §9.

Continuación directa de `CODIGOS/GENERADOR/RODILLA/CIERRE_RODILLA.md`, mismo método que ya funcionó para la rodilla, un segmento más abajo en la cadena. Carpeta separada por pedido explícito del usuario.

## 1. Por qué no se repite el chequeo con Control_Luis

El ángulo tibial de Koopman (`theta_tibia_via_rodilla`) ya está decidido como ganador con evidencia real de sobra — Control_Luis r=0.982, Maastricht N=246 r=0.933, Winter r=0.816 (ver `RODILLA/mejor_modelo_rodilla.md`) — y es el MISMO ángulo que gobierna el segmento tibia→tobillo. Repetirlo aquí no aporta nada nuevo (objeción correcta del usuario, 25-ago-2026).

## 2. Modelo

```
tobillo_relativo_a_cadera(t) = rodilla_relativa_a_cadera(t)  [ya validado, rodilla]
                                + L_tibia * [sin(theta_tibia), 1-cos(theta_tibia)]
X_tobillo_absoluto(t) = velocidad_real·t + tobillo_relativo_a_cadera_X(t)
Y_tobillo_absoluto(t) = plantilla_cadera_LOSO(t) + tobillo_relativo_a_cadera_Y(t)
```

Misma fórmula geométrica que ya se usó para el segmento muslo (cadera→rodilla), con `theta_tibia` en vez de `theta_muslo` — mismo signo, misma convención (0=vertical), ya verificada. Misma plantilla de cadera vertical (LOSO) que rodilla — el vaivén de cadera no depende de qué segmento se está prediciendo.

## 3. Resultado (N=15, Kuopio, overground real)

| Eje | r medio | SD | rango | RMSE medio |
|---|---|---|---|---|
| Horizontal | **0.981** | 0.018 | 0.948–1.000 | 5.5cm (con restricción física, ver §4-bis) |
| Vertical | 0.754 | 0.060 | 0.658–0.848 | 5.1cm |

Más débil que rodilla (X=0.996, Y=0.892) — esperado, el tobillo hereda el error de DOS ángulos encadenados (muslo+tibia) en vez de uno.

## 4. Bug real encontrado y corregido (25-ago-2026): velocidad de entrada a Koopman

El usuario señaló, correctamente, que el "retroceso" visible en X no era lógico (el tobillo debería avanzar, no retroceder, con pendiente negativa). Se investigó a fondo:

1. **Primer diagnóstico (equivocado, corregido en el camino):** se comparó contra la curva REAL individual y pareció que el retroceso también estaba en el dato real — **esto fue un error de lectura visual**, no confirmado numéricamente. Al revisar los NÚMEROS reales de `S.x_horiz_tobillo_cm` (no solo la figura), el mínimo real está SIEMPRE en %ciclo=0 para los 15 sujetos — es decir, **el tobillo real NUNCA retrocede**, punto que el usuario tenía razón en cuestionar.
2. **Diagnóstico correcto:** el modelo sí retrocedía de verdad, hasta -35cm en el peor caso (sujeto 37). Se aisló la causa comparando componente por componente: el término de avance (velocidad×tiempo) no era el problema (verificado que el avance lineal aproxima muy bien al avance real, error <2cm) — el problema estaba en la curva relativa a cadera (muslo+tibia), que retrocedía más de lo real.
3. **Causa raíz:** `Koopman2014_Core` se llamaba con `tempo0.velocidad_ms` — la velocidad **estimada por número de Froude** (`Temporizacion_Core`, basada solo en la talla) — en vez de `S.speed_ms`, la **velocidad REAL medida** por Kuopio para ese sujeto en ese trial. Para el sujeto 37 (186.6cm), Froude estimaba 5.61 km/h cuando su velocidad real en el trial era 2.77 km/h — **más del doble**. Como la amplitud angular de Koopman escala con la velocidad de entrada, esto inflaba artificialmente el rango de flexión de rodilla/tobillo, y por lo tanto el retroceso.
4. **Corrección aplicada:** usar `S.speed_ms*3.6` en vez de `tempo0.velocidad_ms*3.6` al llamar a `Koopman2014_Core`, en las 4 funciones de evaluación (rodilla agregado+individual, tobillo agregado+individual) — la velocidad real ya estaba disponible (viene de los propios datos de Kuopio), no había razón para usar una estimación de otro módulo del pipeline cuando el dato real existe.

**Resultado de la corrección — mejora en los 4 análisis, no solo tobillo:**

| | Antes (Froude) | Después (velocidad real) |
|---|---|---|
| Rodilla X | r=0.984 | r=0.996 |
| Rodilla Y | r=0.867 | r=0.892 |
| Tobillo X | r=0.953 | **r=0.981** |
| Tobillo Y | r=0.748 | r=0.754 |

El retroceso de tobillo bajó de hasta -35cm a prácticamente 0 en la mayoría de los 15 sujetos (solo el sujeto 37 conserva un retroceso residual de ~-18cm — ver `Evaluar_Individual_Kuopio_Tobillo_figura.png`, todavía sin explicar del todo, candidato a seguir investigando si hace falta más precisión).

**Nota para uso futuro del generador (no solo de esta validación):** esta corrección es específica de córmo se corrió *esta prueba* (donde había velocidad real medida disponible para comparar). El generador real (`Generar_Trayectoria.m`) sigue usando la velocidad estimada por Froude porque, en su caso de uso real, no hay velocidad medida — el usuario da solo antropometría. El hallazgo de esta sección no invalida Froude como estimador, solo muestra que mezclar una velocidad estimada con una real en la MISMA prueba de validación introduce error evitable.

## 4-bis. Restricción física aplicada a X: el tobillo real NUNCA retrocede

El usuario insistió, correctamente, en que el residuo de retroceso que quedaba tras la corrección de velocidad (§4) seguía sin ser lógico. Se verificó con precisión: **el mínimo de `S.x_horiz_tobillo_cm` está en pct=0 en los 15/15 sujetos** — el tobillo real jamás retrocede, ni un centímetro, en ningún sujeto de la muestra. Aun con la velocidad ya corregida, el modelo (cadena muslo+tibia) seguía retrocediendo en 8/15 sujetos (hasta -16cm), correlacionado con velocidad de marcha más lenta.

**Solución aplicada:** forzar la restricción física con máximo acumulado (`cummax`, MATLAB) sobre la posición X predicha — no es un ajuste arbitrario de forma, es imponer un hecho ya confirmado en el 100% de los datos reales disponibles. Probado antes de aplicar: **r_x no cambia** (0.9809 igual, la correlación es invariante a este tipo de recorte porque no cambia el orden relativo de los puntos donde ya iba bien) pero **el RMSE medio baja de 7.72cm a 5.51cm** — mejora neta, sin ningún costo. Aplicado en `Evaluar_vs_Kuopio_Tobillo.m` y `Evaluar_Individual_Kuopio_Tobillo.m`.

**Resultado final X: r=0.981 (SD=0.018), RMSE=5.51cm.** Ver figura individual actualizada — ya no hay ninguna pendiente negativa en ningún sujeto.

## 5. Y verificado a fondo — no hay corrección con respaldo disponible, r=0.754 se mantiene

El usuario pidió verificar bien Y para afinarlo más. Se investigó si existe un factor de corrección de amplitud sistemático (similar al `cummax` de X):

- Se calculó, sujeto por sujeto (N=15, LOSO), la razón `amplitud_real / amplitud_predicha` del pico-a-pico vertical del tobillo.
- **Resultado: la razón NO es consistente** — media=1.148 pero **rango 0.804–1.601** (SD=0.217). Es decir, en algunos sujetos el modelo YA sobreestima (ratio<1, p.ej. sujeto 22: 0.80), en otros subestima bastante (sujeto 31: 1.60) — no hay un sesgo sistemático único que corregir con un factor global.
- **Aclaración importante:** los 6 sujetos usados en la figura individual (`Evaluar_Individual_Kuopio_Tobillo_figura.png`) fueron elegidos deliberadamente por ser los MÁS EXTREMOS en talla/masa (para maximizar diversidad) — por eso esa figura, por sí sola, dio la impresión visual de "subestima siempre" — no es representativa de los 15 sujetos completos, donde el patrón es mixto.
- **Conclusión: forzar una corrección de amplitud empeoraría a la mitad de los sujetos para mejorar a la otra mitad** — mismo hallazgo que el intento de escalar por velocidad en rodilla (§2 de este documento y `CIERRE_RODILLA.md`): con variabilidad real de este tamaño y N=15, no hay ganancia neta. **r_y=0.754 (SD=0.060) queda como resultado final**, no por falta de intento sino porque ya se probó el camino obvio y no hay evidencia de que ayude.
- La brecha restante en Y es variabilidad real entre sujetos en la dinámica exacta del tobillo/pie (posiblemente ligada a estrategia individual de despegue, plantiflexión) que un modelo poblacional de 2 segmentos rígidos no captura — igual que con rodilla, ampliar N o modelar el pie por separado son los únicos caminos de mejora real, no ajustes de escala.

## 6. MODELO FINAL (25-ago-2026, reemplaza §3-5): fases + residuo de rockers (LOSO)

Después de declarar Y como "limitación sin corrección disponible" (§5), el usuario insistió en verificar más — con razón: separando mínimo y máximo del pico (no solo la amplitud pico-a-pico, que mezclaba dos sesgos y ocultaba el patrón) apareció un sesgo **sistemático en los 15/15 sujetos**, no ruido:

| | Real | Predicho (fórmula continua) |
|---|---|---|
| Mínimo (apoyo) | -0.67 a -3.08cm | -4.48 a -7.71cm (siempre más profundo) |
| Máximo (balanceo) | 8.26 a 19.16cm | 4.07 a 6.25cm (siempre más chico) |

**Causa raíz:** `dy = L·(1-cos(θ))` es una función PAR — no distingue si el ángulo está adelante o atrás de la vertical, tratando ambos como "elevación". En marcha real el tobillo casi no se mueve verticalmente en apoyo (pie plantado) pero se eleva mucho en balanceo (flexión de rodilla) — la fórmula continua aplana el balanceo y exagera el apoyo, en TODOS los sujetos igual.

**Solución en dos pasos, con mapeo explícito de dónde viene cada pieza** (pedido del usuario, para trazabilidad en el artículo):

1. **`Cadena_Completa_Core.m`** (nuestro aporte, construido el 24-ago-2026 pero nunca validado contra datos reales hasta hoy): modelo consciente de fase — apoyo: tobillo pivote FIJO, cadena hacia arriba; balanceo: cadera avanza, cadena hacia abajo. Probado también en RODILLA: la empeora (r_y 0.892→0.689, con una subida irreal de +4.8cm en apoyo) — **se usa solo para tobillo, rodilla se queda con el modelo continuo** (`RODILLA/Kuopio/Evaluar_vs_Kuopio_Avance.m`, sin cambios).
2. **Residuo de rockers, LOSO** (nuevo, este archivo): el pivote "fijo" en apoyo es a su vez una idealización — el usuario señaló que se veía forzado. Mecanismo real conocido con respaldo bibliográfico (los 3 "rockers" de la marcha: talón→tobillo→antepié, Perry & Burnfield, PM&R KnowledgeNow) pero sin una curva cuantitativa publicada reusable (búsqueda 25-ago-2026, solo descripción cualitativa). En vez de importar un número de otra fuente con población/instrumentación distinta, se construyó el residuo **empíricamente con LOSO** sobre los mismos 15 sujetos de Kuopio (misma técnica ya validada para el vaivén de cadera de rodilla) — el residuo real de apoyo de cada sujeto se predice con el promedio de los OTROS 14, nunca con su propia curva.

**MAPEO de atribución (Koopman / aporte propio / Kuopio):**
- **De Koopman 2014 (sin modificar):** θ_cadera(t), θ_tibia_vía_rodilla(t).
- **Aporte propio #1:** reconstrucción de posición consciente de fase (`Cadena_Completa_Core.m`).
- **Aporte propio #2:** residuo empírico de rockers vía LOSO (nuevo, este documento).
- **Rol de Kuopio:** examen real independiente (N=15, overground, antropometría y velocidad medidas) que reveló el sesgo, y fuente del residuo LOSO — nunca se usó para ajustar los coeficientes de Koopman ni la lógica de fases, que ya estaban fijados antes de esto.

**Resultado final tobillo:**

| Eje | Fórmula continua (§3) | Fases + rockers LOSO | + calibración afín LOSO (§7, final) |
|---|---|---|---|
| X | r=0.981 (con cummax) | r=0.994, RMSE=6.71cm | **RMSE=4.76cm** |
| Y | r=0.754 | r=0.884, RMSE=2.87cm | **RMSE=2.53cm** |

Ver `Evaluar_vs_Kuopio_Tobillo_Fases.m` (+figura, +CSV) — el pico vertical ahora coincide casi exacto (11.7cm predicho vs 11.9cm real, antes 4-6cm vs 8-19cm), y el tramo de apoyo ya no está forzado en 0 exacto, sigue el pequeño hundimiento real. Único residuo visible: un pequeño rebote extra del modelo entre 85-100% que el real no muestra tan marcado — declarado, no oculto, candidato a revisar si se busca más precisión.

**Archivos superados por este modelo:** la versión con fórmula continua + cummax (`Evaluar_vs_Kuopio_Tobillo.m`, `Evaluar_Individual_Kuopio_Tobillo.m`, §3-4-bis) **se eliminó del repo** (25-ago-2026, pedido del usuario: no acumular versiones superadas de código/figuras — el historial y los números ya quedan documentados en este archivo, no hace falta conservar el código muerto).

## 7. Calibración de ganancia (SIN offset), LOSO — 25-ago-2026

Mismo principio que en `RODILLA/` e `INCLINACION_TIBIAL/` (mismo día). **Primer intento (afín completo, con offset) tuvo un bug real detectado visualmente por el usuario**: la curva calibrada dejaba de empezar en 0 y quedaba plana un tramo al inicio — mismo problema exacto que en rodilla (§ ver `RODILLA/CIERRE_RODILLA.md` §7-bis para la explicación completa: el offset no tiene sentido en curvas forzadas a 0 en pct=0). Corregido a regresión por el origen (solo ganancia, sin intercepto), LOSO:

| | RMSE (fases+rockers) | RMSE con ganancia LOSO |
|---|---|---|
| X | 6.71cm | 6.67cm (±ruido, sin mejora neta pero ya sin el artefacto) |
| Y | 2.87cm | 2.53cm |

`RMSEnorm` no se usa aquí por el mismo motivo que en rodilla (curvas de posición forzadas a 0 en pct=0, distorsiona la normalización).

## 7-bis. Residuo de rockers también en X, y cierre de ciclo en Y — 25-ago-2026

Dos correcciones más, ambas pedidas por el usuario tras revisar las figuras con atención:

**1) El residuo de rockers (§6) solo se aplicaba a Y — se agregó también a X.** El modelo fijaba el tobillo en **exactamente (0,0)** durante todo el apoyo (constante matemática perfecta, por construcción de `Cadena_Completa_Core.m`) — físicamente imposible, y el propio dato real lo contradice: el tobillo real SÍ avanza un poco en X durante el apoyo (3-13cm según el sujeto). Se aplicó el mismo residuo empírico LOSO a X.

**2) Cierre de ciclo en Y — hallazgo importante.** En marcha periódica sobre piso plano, el tobillo debe terminar el ciclo (pct=100%) a la misma altura de donde partió (pct=0%). Verificado en el dato real: los 15 sujetos cierran entre -0.6 y +1.8cm (~0, dentro del ruido). El modelo, en cambio, **terminaba sistemáticamente ~8-11cm más alto en los 15 sujetos** — un sesgo real y grande, no ruido, acumulado durante el balanceo. Se corrigió con una rampa suave aplicada SOLO al balanceo (el apoyo ya estaba bien) que fuerza el cierre exacto — es una restricción física exacta (periodicidad del ciclo), no un ajuste arbitrario. X no se corrige así (avanza una zancada real cada ciclo, no cierra ni debe cerrar).

**Resultado final (reemplaza la tabla de §7):**

| | RMSE antes de estas 2 correcciones | RMSE final |
|---|---|---|
| X | 6.67cm | **4.46cm** (r sube de 0.994 a 0.997) |
| Y | 2.53cm | **1.99cm** (r sube de 0.884 a **0.953**) |

El cierre de ciclo fue la mejora individual más grande de toda la carpeta tobillo — confirma que "verificar contra restricciones físicas conocidas" (nunca retrocede en X, cierra en Y) fue más productivo que seguir afinando la forma de la curva.

Aplicado en `Evaluar_vs_Kuopio_Tobillo_Fases.m` — MODELO FINAL vigente de tobillo.

## 8. MODELO FINAL VIGENTE (25-ago-2026, reemplaza §7 y §7-bis): calibración del ÁNGULO + cierre de zancada

Las secciones §3 a §7-bis quedan **superadas** como resultado final; se conservan como historial. Dos cambios, ambos originados en revisar el modelo sujeto a sujeto en vez de en promedio (ver §9):

**1) La corrección se mueve de la posición al ángulo.** Igual que en rodilla (`RODILLA/CIERRE_RODILLA.md` §8, mismo día, el diagnóstico completo está ahí): Koopman reproduce la **forma** del ciclo casi exacta pero **sobreestima la excursión angular ~20-23%** en esta población. Como el tobillo cuelga de **dos** ángulos encadenados, se calibran los dos con una afín LOSO antes de propagar por la cadena:

| Ángulo | Ganancia LOSO | Offset | De dónde viene |
|---|---|---|---|
| Muslo | 0.769 | −2.69° | medido en `RODILLA/` |
| Tibia | 0.811 | −11.33° | ya medido en `INCLINACION_TIBIAL/` §5, **antes y por separado** |

Que las dos ganancias caigan en el mismo rango, habiéndose medido de forma independiente contra segmentos distintos, es lo que confirma que es **un solo defecto del modelo publicado**, no un ajuste por eje. Con esto, **la calibración de ganancia por eje sobre X/Y (§7) se elimina** — deja de hacer falta.

**2) Cierre de zancada en X.** Mismo principio que el cierre de ciclo en Y (§7-bis), aplicado al eje que sí avanza: en marcha periódica el pie recorre **exactamente una zancada por ciclo**, y la zancada es `velocidad × T_ciclo` — una cantidad que el generador conoce sin ningún dato medido. La cadena por fases, en cambio, generaba su propia zancada y se desviaba hasta ~15 cm en algunos sujetos. Se reparte la diferencia de forma proporcional al avance ya recorrido (no toca el apoyo, no introduce saltos).
- **Caveat declarado:** `velocidad × T` sobreestima en ~7 cm el desplazamiento del tobillo realmente medido al cierre del ciclo (101.6 vs 94.5 cm de media, N=15) — probablemente por el desfase entre la detección de eventos de Zeni y el marcador de tobillo. Aun así el error del modelo baja, porque el error propio de la cadena era mayor (10.9 cm).

**Resultado final:**

| | §7-bis (ganancia de posición) | **Modelo final** |
|---|---|---|
| X — r / RMSE | 0.997 / 4.46 cm | **0.998 / 2.90 cm** |
| Y — r / RMSE | 0.953 / 1.99 cm | **0.985 / 1.54 cm** |
| Y — amplitud modelo/real | 0.86× | **0.91×** |

Con esto el tobillo queda **mejor que la rodilla en el eje vertical** (r=0.985 vs 0.920) — se invierte lo que decía §3 ("más débil que rodilla, hereda el error de dos ángulos"): heredar dos ángulos deja de ser un problema una vez que los dos están calibrados.

**Nota sobre §5.** La conclusión de §5 ("no hay corrección de amplitud con respaldo, r_y=0.754 se mantiene") era correcta *dado el modelo de entonces* — se buscó un factor de escala sobre la posición y efectivamente no lo había. El error no estaba ahí: estaba un nivel más arriba, en el ángulo. Queda como recordatorio de que buscar el factor de corrección en el nivel equivocado puede dar un "no hay nada que corregir" falso.

## 9. Prueba individual, y por qué la de grupo cambió (25-ago-2026)

Ver `RODILLA/CIERRE_RODILLA.md` §9 para el razonamiento completo (mismo cambio en las 3 carpetas): la figura de grupo ya no promedia trayectorias de sujetos con antropometría distinta — muestra pares por sujeto, curvas de error y histogramas de r. `Evaluar_Individual_Kuopio_Tobillo.m` (nuevo, reemplaza al que se había eliminado por error junto con la versión superada en §6) es la prueba de referencia, con **los mismos 6 sujetos** que rodilla y ángulo tibial, y **sin duplicar la lógica del modelo** — llama a `Evaluar_vs_Kuopio_Tobillo_Fases(false)`.

Resultado individual (los 6, modelo final): r_x entre 0.996 y 0.999, r_y entre 0.972 y 0.997.

## 10. Archivos de esta carpeta

| Archivo | Qué es |
|---|---|
| `Evaluar_vs_Kuopio_Tobillo_Fases.m` (+figura, +CSV) | **MODELO FINAL vigente** (§8) — ángulos calibrados + fases + rockers + cierre de zancada |
| `Evaluar_Individual_Kuopio_Tobillo.m` (+figura, +CSV) | **La prueba de referencia** (§9) — 6 sujetos de antropometría diversa, uno por uno |
| `CIERRE_TOBILLO.md` | Este documento |

(Versiones superadas ya eliminadas del repo el 25-ago-2026 — ver §6 para el historial completo con los números de cada intento.)

Depende de `CODIGOS/GENERADOR/RODILLA/Kuopio/Cargar_Kuopio2024_Core.m` (cargador compartido, ya extendido con campos de tobillo) — no duplicado aquí. También depende de `Cadena_Completa_Core.m` y `Obtener_Angulos_Candidato.m` (carpeta `CODIGOS/GENERADOR/`, construidos el 24-ago-2026, validados contra datos reales por primera vez en este documento).

## 9. Qué sigue

Pendiente: ángulo de inclinación tibial (puede no necesitar modelo propio, ya se deriva de cadera+rodilla+tobillo resueltos). Recién con rodilla+tobillo+tibia resueltos, decidir cómo se juntan y si esto reemplaza el plan de ensamble de 4 modelos (pregunta pospuesta desde el 24-ago).
