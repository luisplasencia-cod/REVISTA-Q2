# Cierre: ÁNGULO DE INCLINACIÓN TIBIAL — 25-ago-2026

Continuación directa de `RODILLA/CIERRE_RODILLA.md` y `TOBILLO/CIERRE_TOBILLO.md`, mismo método (Kuopio 2024, N=15, overground real, velocidad real medida). Carpeta separada, mismo patrón.

## 1. Qué se valida

El ángulo de inclinación tibial (θ_tibia, 0°=tibia vertical, misma convención del proyecto desde el inicio — `Control_apoyo_Luis_V4.csv` real va de -50° a +22°) — es la cantidad que Koopman ya predecía bien en trabajo previo (`RODILLA/mejor_modelo_rodilla.md`: r=0.982 vs Control_Luis n=1, r=0.933 vs Maastricht N=246), pero **nunca antes validado con velocidad real overground vía Kuopio**.

## 2. Método

No hace falta extraer nada nuevo — la posición absoluta de rodilla y tobillo ya la calcula `Cargar_Kuopio2024_Core.m`. El ángulo es geometría pura sobre esas posiciones:
```
theta_tibia_real = atan2(-(rodilla_x - tobillo_x), rodilla_y - tobillo_y)
```
mismo principio que `Cargar_Camargo_Core.m` (atan2 con 0=vertical), con el signo verificado empíricamente contra Koopman (ver bug de normalización abajo).

**Predicho:** `Koopman2014_Core` con velocidad REAL medida (misma metodología ya establecida en rodilla/tobillo, no Froude).

## 3. Bug real encontrado y corregido: normalización destruye la geometría

Primer intento dio **r=-0.79, RMSE=101°** — sin sentido. Causa: `S.x_horiz_cm` (rodilla) y `S.x_horiz_tobillo_cm` (tobillo), tal como los exporta `Cargar_Kuopio2024_Core.m`, están cada uno normalizados independientemente a **empezar en 0 en su propio pct=0** (útil para medir desplazamiento/avance, que es para lo que se diseñaron). Al restar dos curvas cada una reseteada a su propio cero, se **borra la distancia geométrica real entre rodilla y tobillo** — el resultado no es un ángulo real, es basura.

**Corregido:** se agregaron a `Cargar_Kuopio2024_Core.m` dos campos nuevos, **sin normalizar** — `S.dx_tibia_cm`, `S.dy_tibia_cm` (vector rodilla-menos-tobillo directo, preservando el offset real en cada instante). Con eso, primer resultado correcto en forma: **r=-0.992** (espejo casi perfecto contra Koopman) — se verificó empíricamente que invertir el signo de `dx_tibia` alinea la convención con la de Koopman (positivo = misma dirección que la flexión de cadera) → **r=+0.992**.

## 4. Resultado — forma (r=0.992), y por qué el RMSE crudo era engañoso

**r medio = 0.992 (SD=0.007, rango 0.975–0.998), N=15.** Mejor que las validaciones previas de Koopman contra Control_Luis (r=0.982, n=1) y Maastricht (r=0.933, N=246, solo grupo de edad) — la primera vez que se prueba con velocidad real medida por sujeto y overground.

Con r=0.992 tan alto, el RMSE crudo (11.24°) llamó la atención del usuario — con esa forma casi perfecta, un RMSE de dos dígitos sugería un sesgo sistemático (offset/ganancia), no error de forma, y así fue.

## 5. Calibración afín, LOSO — MODELO FINAL

Se midió el sesgo por sujeto: **offset medio +10.09° (SD=2.07°)**, **ganancia media 0.802 (SD=0.096)** — consistentes entre los 15 sujetos, no ruido (Koopman sobreestima el rango angular ~20% de forma sistemática). Se corrigió con una **calibración afín** (`theta_final = a + b·theta_Koopman`), ajustada por **LOSO** (los coeficientes a,b de cada sujeto salen de los OTROS 14, nunca de sí mismo) — mismo principio ya usado para el vaivén de cadera en rodilla/tobillo, y metodológicamente igual a la calibración de offset de instrumento que ya usa `CODIGOS/CALIBRACION/` del proyecto, aplicada aquí a la salida del modelo en vez de a un sensor.

**Evaluado con la métrica propia del proyecto** (`RMSEnorm`, `CODIGOS/VALIDACIONES/Calcular_Metricas_Curva.m` — error normalizado por el SD entre sujetos en cada %ciclo, misma escala que usa el resto del proyecto: <1 Excelente, <1.5 Bueno, <2 Aceptable, >2 Deficiente):

| | r | RMSE | RMSEnorm | Clasificación (escala del proyecto) |
|---|---|---|---|---|
| Sin calibrar | 0.992 | 11.24° | 3.53 | **Deficiente** |
| **Calibrado (afín, LOSO)** | 0.992 (invariante) | **3.50°** | **0.92** | **Excelente** |

(r no cambia — una transformación afín no altera la correlación, solo corrige escala/sesgo, por eso RMSE sí puede mejorar mucho sin que r se mueva.)

Ver `Evaluar_vs_Kuopio_AnguloTibial_figura.png`: panel superior derecho (calibrado) prácticamente se superpone con el dato real; histograma inferior derecho muestra que casi todos los 15 sujetos caen ahora en rango "Bueno"/"Excelente" de RMSEnorm, contra casi todos "Deficiente" antes de calibrar.

## 5-bis. Lo que se encontró acá terminó siendo el hallazgo central de las tres carpetas (25-ago-2026)

La calibración afín de §5 se había planteado como una corrección local del ángulo tibial. **No lo era.** Al revisar rodilla y tobillo sujeto a sujeto el mismo día apareció el mismo defecto, con la misma magnitud, en el ángulo de muslo:

| Ángulo | r (forma) | Excursión real | Excursión Koopman | Ganancia LOSO |
|---|---|---|---|---|
| Tibia (esta carpeta) | 0.992 | — | — | **0.811** |
| Muslo (`RODILLA/` §8) | 0.971 | 32.5° | 39.2° (+21%) | **0.769** |

Medidos de forma independiente, contra segmentos distintos, con la misma técnica LOSO. La conclusión conjunta: **Koopman 2014 reproduce la forma del ciclo de marcha casi exactamente (r=0.97-0.99) pero sobreestima la excursión angular ~20-23% en esta población; una sola calibración afín por ángulo lo corrige.** No es un defecto por eje ni por segmento.

Consecuencia práctica en las otras dos carpetas: la calibración de ganancia que se aplicaba **sobre la posición** se eliminó de rodilla y tobillo, y se reemplazó por esta misma calibración aplicada **al ángulo** antes de propagar por la geometría. Mejoró todas las métricas a la vez en ambas — el caso más marcado es la amplitud vertical de rodilla, que pasó de reproducir 51% de la excursión real a 82%. Detalle completo en `RODILLA/CIERRE_RODILLA.md` §8 y `TOBILLO/CIERRE_TOBILLO.md` §8.

Esta carpeta **no cambia** — ya lo hacía bien desde el principio; es la que fijó el método que las otras dos adoptaron.

## 6. Prueba individual (25-ago-2026)

Objeción del usuario, correcta: la figura de grupo comparaba `media(real)` contra `media(predicho)`, y el modelo se alimenta de sexo/talla/masa y velocidad de **cada** sujeto — promediar curvas de antropometrías distintas mezcla trayectorias no comparables. Ver `RODILLA/CIERRE_RODILLA.md` §9 para el cambio completo (aplicado en las 3 carpetas).

`Evaluar_Individual_Kuopio_AnguloTibial.m` (nuevo) muestra cada sujeto dos veces —crudo a la izquierda, calibrado a la derecha, **en la misma escala vertical**—, con los **mismos 6 sujetos** que rodilla y tobillo. Es la evidencia visual más directa de §5: en el panel crudo la curva naranja va sistemáticamente por encima de la real y con más rango; en el calibrado se superpone casi exactamente. Resultado individual: RMSEnorm de 2.68-4.00 (Deficiente) a **0.50-1.09** (Excelente/Bueno) en los 6.

## 7. Archivos de esta carpeta

| Archivo | Qué es |
|---|---|
| `Evaluar_vs_Kuopio_AnguloTibial.m` (+figura, +CSV) | Modelo final, prueba de grupo (crudo + calibrado LOSO, pares por sujeto y curvas de error) |
| `Evaluar_Individual_Kuopio_AnguloTibial.m` (+figura, +CSV) | **La prueba de referencia** (§6) — 6 sujetos de antropometría diversa, crudo vs calibrado |
| `CIERRE_INCLINACION_TIBIAL.md` | Este documento |

Depende de `RODILLA/Kuopio/Cargar_Kuopio2024_Core.m` (extendido con `dx_tibia_cm`/`dy_tibia_cm`, y con `dx_muslo_cm`/`dy_muslo_cm` para la calibración del ángulo de muslo de `RODILLA/`).

## 8. Qué sigue

Con rodilla + tobillo + ángulo tibial resueltos, decidir cómo se juntan (y si esto reemplaza el plan de ensamble de 4 modelos, pregunta pospuesta desde el 24-ago) — pendiente, decisión del usuario.
