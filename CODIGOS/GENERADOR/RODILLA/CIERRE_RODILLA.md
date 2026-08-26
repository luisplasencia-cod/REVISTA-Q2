# Cierre: mejor modelo para la RODILLA — 25-ago-2026

> **Modelo vigente: §8.** Las secciones §1-§7-ter son el historial de cómo se llegó ahí (selección del modelo, bases de datos probadas, correcciones intermedias) y conservan números ya superados. La prueba de referencia es la individual, §9.

Documento de cierre de esta carpeta, pedido explícito del usuario ("necesito ver el modelo, la razón por la que se descartan las otras, la comparación con la base, y el desplazamiento horizontal y vertical, de forma super estructurada"). Es el punto de entrada — el resto de archivos de `RODILLA/` son el detalle que sostiene cada afirmación de aquí.

## 1. Modelo ganador: **Koopman 2014**

Gana sin excepción en las **4 fuentes reales independientes** probadas hasta hoy — desde n=1 (chequeo rápido) hasta n=246 (ángulo, grupo) y n=40 con posición 3D real y antropometría real sujeto-a-sujeto (la prueba más exigente y la única que cumple el criterio que fijó el usuario: "cualquier base que tenga sexo/talla/peso específico, que pueda setearse en el modelo, para una comparación correcta"):

| Fuente real | n | Qué se comparó | Antropometría | Koopman | Zhao | Yun |
|---|---|---|---|---|---|---|
| `REFERENCIAS/Control_apoyo_Luis_V4.csv` + balanceo | 1 | ángulo tibial, ciclo completo | No documentada | **r=0.982** | r=-0.21 | r=-0.28 |
| Winter, Tabla A.1 | 1 | rodilla rel. cadera (X) | No documentada — **por eso queda fuera de la decisión final**, ver §5 | r=0.816 | r=0.613 | r=0.468 |
| Maastricht (OSF t72cw) | 246 (grupo hombres 18-29) | flexión de rodilla nativa | Grupo de edad, no por sujeto exacto | **r=0.933, RMSE=7.6°** | r=-0.30 | r=-0.33 |
| **Ferber 2024 (Figshare+ 24255795)** | **40** (muestra sana estratificada, 20M/20F) | **posición 3D real, rodilla rel. cadera, horizontal Y vertical** | **Sexo+talla+peso REAL por sujeto, seteado en el modelo uno a uno** | **r_x=0.945 (SD 0.045), r_y=0.791 (SD 0.144)** | no evaluado (ya descartado, ver §2) | no evaluado (ya descartado, ver §2) |

Con la prueba más exigente (Ferber, N=40, antropometría real sujeto-a-sujeto, posición no solo ángulo) Koopman predice el desplazamiento horizontal de la rodilla con r=0.945 en promedio (rango 0.795–0.996 entre los 40 sujetos, **ninguno negativo**) y el vertical con r=0.791 (rango 0.390–0.962). Ver figura `Evaluar_vs_Ferber_figura.png` y tabla `Evaluar_vs_Ferber_resultados.csv`.

## 2. Por qué se descartan los demás

### Modelos ya implementados en el proyecto (comparados directamente)

- **Zhao 2026 y Yun 2014**: fase de flexión de rodilla desalineada del ciclo real (pico adelantado ~20-25% del ciclo vs. ~70% fisiológico) — correlación **negativa** contra las 3 primeras fuentes (Control_Luis, Winter, Maastricht). No se volvieron a evaluar contra Ferber porque el patrón ya estaba establecido con evidencia suficiente (3/3 fuentes en contra, mismo signo).
- **Romero-Sorozábal 2024**: da posición 3D directa (sin pasar por ángulo), pero su eje Z (vertical) de rodilla/tobillo sale ~2x más profundo de lo anatómicamente posible — anomalía real de la fuente publicada (verificada dos veces, no es error de transcripción). Se excluyó del ensamble; nunca fue candidato ganador de rodilla por sí solo.

### Candidatos de algoritmo nuevos, de la búsqueda ampliada del 24-ago (ninguno llegó a evaluarse contra datos — se descartaron antes, por diseño del modelo, no por desempeño)

Ver detalle completo en `docs/algoritmo/busqueda_modelos_antropometria_rodilla.md`.

| Candidato | Por qué se descarta |
|---|---|
| Moissenet 2019 | Publica coeficientes reutilizables (raro, buena señal) pero solo predice **puntos discretos** (pico/timing), no la curva completa — sirve de chequeo cruzado 0D, no de generador alternativo |
| Liew 2025 (ShinyFOSR) | Técnicamente el más fuerte encontrado, pero entrena sobre **el mismo Maastricht** que el proyecto usa para validar → circularidad, se descarta por diseño de la búsqueda, no por debilidad |
| Ferreira 2018, Random Forest sin autor confirmado | Mismo patrón que 12 candidatos descartados antes (Hu2020/Luu2014/Wu2018/Luu2011): sin evidencia de pesos/coeficientes entrenados publicados |

### Bases de datos descartadas para la decisión final (aunque se usaron como evidencia complementaria)

- **Winter**: posición real, pero **sin sexo/talla/peso documentados** — no se puede "setear" en el modelo para una comparación sujeto-a-sujeto correcta (criterio explícito del usuario, 24-ago-2026). Se mantiene como chequeo rápido de forma (n=1), no como evidencia decisiva.
- **Palma 2024 (Chile)**: primera base sudamericana real encontrada, pero el detalle antropométrico por sujeto está bloqueado por un 403 (SciELO/Figshare) sin acceso institucional — no incorporada.

## 3. Comparación con la base: Ferber et al. 2024 — el detalle

- **Fuente**: Ferber, Brett, Fukuchi, Hettinga & Osis 2024, *Scientific Data*, DOI 10.1038/s41597-024-04011-7. Figshare+ 10.25452/figshare.plus.24255795.v1 (CC BY 4.0). n=1798 sujetos totales (sanos + lesionados, caminata + carrera); universo filtrado a **561 sujetos sanos con caminata y antropometría completa**, muestra final estratificada por sexo y talla: **40 sujetos (20M/20F), talla 150–195cm, peso 48–105kg**.
- **El dataset NO trae la posición de rodilla ya calculada** — solo picos/timing discretos (mismo problema que Moissenet). Se reconstruyó la posición 3D real corriendo el **pipeline oficial de los propios autores** (`gait_kinematics.m` + `gait_steps.m`, MIT license, sin modificar — en `Ferber/`) sobre los marcadores crudos de los clusters rígidos, más una fórmula de reconstrucción de posición global (rotación del segmento × offset local calibrado) que esas funciones calculan pero no exponen como trayectoria — verificada empíricamente: la velocidad de marcha derivada coincide con el dato de metadata del propio dataset (sujeto 100560: 1.323 vs. 1.322763 m/s).
- **Hallazgo metodológico real, corregido en el camino** (ver §5): el primer intento comparó contra un tobillo fijo (mismo supuesto que usa `Cadena_Cinematica_Core.m` para el CSV del simulador) y dio r=-0.41 en los 40 sujetos a la vez — señal de marco de referencia incorrecto, no de modelo malo. En marco de laboratorio real el tobillo se desplaza durante el balanceo. Corregido a "rodilla relativa a cadera" (mismo principio que ya se había validado con Winter): r_x sube de -0.41 a **0.945**.
- Los archivos crudos de los 40 sujetos (~1GB, públicos pero pesados) están en `Ferber/muestra40_raw/`, **no versionados en git** (ver `.gitignore`) — `Ferber/muestra_40.csv` sí está versionado y alcanza para volver a descargarlos (contiene sub_id/filename; ver cabecera de `Cargar_Ferber2024_Core.m` para el método de descarga vía `remotezip`, sin bajar el ZIP completo de 22.75GB).

## 4. Desplazamiento horizontal y vertical de la rodilla (relativo a la cadera)

Ver `Evaluar_vs_Ferber_figura.png` — panel superior izquierdo (horizontal) y superior derecho (vertical), 40 sujetos individuales en gris, media real en negro, predicción de Koopman en color.

- **Horizontal**: excursión real media de ~29cm (rango de balanceo→apoyo), forma de "U" — la rodilla retrocede durante el apoyo y avanza rápido durante el balanceo. Koopman sigue esta forma casi exactamente (r=0.945).
- **Vertical**: excursión real media de ~5cm, con un patrón de **doble valle** (dos mínimos, ~30% y ~60% del ciclo) que Koopman —con un solo parámetro de cadera— no reproduce del todo (solo un valle) — RMSE medio 2.04cm, r=0.791. Es la única discrepancia real de forma encontrada; queda declarada, no forzada a desaparecer.
- Los 40 sujetos individuales están en `Evaluar_vs_Ferber_resultados.csv` (r_x, rmse_x, r_y, rmse_y, y antropometría de cada uno).

## 5. Hallazgo lateral importante: marco de referencia (tobillo fijo vs. cadera)

`Cadena_Cinematica_Core.m` asume el tobillo fijo durante **todo** el ciclo (apoyo y balanceo) — válido para el CSV del simulador (que por construcción es relativo al tobillo), **no válido para comparar contra datos de laboratorio en marco global** (Winter, Camargo, Ferber), donde el tobillo sí se desplaza en el balanceo. La comparación correcta contra datos de laboratorio es **rodilla relativa a cadera** (cancela la traslación de todo el cuerpo) — ya se había usado así con Winter, ahora queda confirmado y generalizado con N=40. **No se modificó `Cadena_Cinematica_Core.m`** (sigue siendo correcto para su uso real, generar el CSV del simulador) — el ajuste vive solo en los scripts de evaluación (`Evaluar_vs_Winter.m`, `Evaluar_vs_Ferber.m`).

## 6. Mapa de archivos de esta carpeta

| Archivo | Qué es |
|---|---|
| `CIERRE_RODILLA.md` | Este documento — punto de entrada |
| `Evaluar_Mejor_Modelo_Rodilla.m` (+figura) | Primera comparación, ángulo tibial y X, contra `Control_Luis` real (n=1) |
| `Evaluar_vs_Winter.m` (+figura) | Rodilla relativa a cadera (X), contra Winter (n=1, sin antropometría) |
| `Evaluar_vs_Maastricht.m` (+figura) | Flexión de rodilla nativa, contra Maastricht (n=246, grupo, solo ángulo) |
| `Evaluar_vs_Ferber.m` (+figura, +CSV) | Posición horizontal+vertical, N=40, antropometría real por sujeto (cinta — ver §7) |
| `Kuopio/Evaluar_vs_Kuopio_Avance.m` (+figura, +CSV) | **MODELO FINAL vigente**, prueba de grupo (§8) — N=15 overground, pares por sujeto + curvas de error |
| `Kuopio/Evaluar_Individual_Kuopio.m` (+figura, +CSV) | **La prueba de referencia** (§9) — los 6 sujetos de antropometría diversa, uno por uno |
| `Ferber/` | Código oficial de terceros (MIT) + `Cargar_Ferber2024_Core.m` (nuestro, reconstruye posición) + `muestra_40.csv` + `muestra40_raw/` (datos, gitignored) |
| `Maastricht/`, `Winter_*.xlsx/csv`, `Extraer_Winter_CSV.m` | Datos y extractores de las otras 2 bases |

## 7. Adenda 25-ago-2026: avance horizontal ABSOLUTO (overground) — resuelto

Después de este cierre, el usuario aclaró un punto de fondo: el simulador **sí avanza por el piso** (no es un banco tipo cinta) — lo relativo a cadera de arriba no basta, hace falta el desplazamiento neto de la rodilla en el cuarto, `X(t) = velocidad_real·t + X_relativa_a_cadera(t)`.

- **Primer intento, con Ferber, descartado por diseño del dataset, no por error de fórmula:** el README oficial de Ferber (`Ferber/README_Ferber2024_original.txt`) confirma que es marcha **en cinta** ("walking on a treadmill") — en cinta no hay avance neto real que reconstruir (el dato real también vuelve a ~0 al final del ciclo). Probar la fórmula ahí dio r=0.39, RMSE=72cm — no porque la fórmula esté mal, sino porque la verdad de referencia no tiene avance que predecir.
- **Segundo intento, con Kuopio 2024, confirma la fórmula:** `CODIGOS/GENERADOR/RODILLA/Kuopio/` (carpeta nueva) — dataset overground real (3 plataformas de fuerza en el piso, confirmado en el paper), con antropometría **medida** por sujeto (`info_participants.xlsx`: sexo/talla/masa/largo real de muslo y tibia, no estimada). N=15 sujetos piloto (de 51 totales), 3 trials `comf` c/u, eventos de talón detectados con el método cinemático de Zeni et al. 2008 (Kuopio no trae eventos precalculados como sí traía Ferber) — 138 ciclos completos en total.
  - **Resultado: r_x medio = 0.984 (SD=0.015, rango 0.952–0.999), RMSE medio = 7.1cm, N=15.** La rodilla real SÍ avanza netamente (~100cm en un ciclo, forma de "S" — no vuelve a 0), y la fórmula `velocidad·t + Koopman relativo_a_cadera` la reproduce casi exactamente. Confirma lo que el usuario esperaba ver ("la rodilla avanzando"), esta vez con la base de datos correcta.
  - **Vertical, primer intento r_y=0.635 (sin plantilla de cadera) — mejorado el mismo día, ver más abajo.**
  - Ver `Kuopio/Evaluar_vs_Kuopio_Avance_figura.png` y `_resultados.csv` (por sujeto).
- **Vertical mejorado (mismo 25-ago-2026): plantilla de cadera vertical, SOLO con Kuopio (LOSO), r_y sube de 0.635 a 0.867.** El problema del vertical: `Y(t) = cadera_vertical_bob(t) + Y_relativa_a_cadera(t)` — el segundo término ya estaba (Koopman), pero el primero (vaivén propio de la cadera, "double-bump" clásico ~4-5cm) no lo da Koopman (solo ángulos articulares).
  - **Primer intento, descartado por objeción correcta del usuario:** construir la plantilla con los 40 sujetos de Ferber y probarla en Kuopio (`Modelo_Cadera_Vertical_Ferber.m` — eliminado del repo el 25-ago-2026, no se conservan versiones descartadas). El usuario objetó: Ferber es cinta, mismo problema que con el avance horizontal — no se puede asumir sin probar que el vaivén vertical es igual en cinta que en piso real.
  - **Solución aplicada:** plantilla construida y probada **solo con Kuopio**, con validación cruzada dejando-uno-afuera (LOSO) entre los 15 sujetos — el sujeto *i* se predice con el promedio de los otros 14, nunca con su propia curva (evita circularidad sin ningún supuesto cinta=piso). `Cargar_Kuopio2024_Core.m` ahora también exporta `S.y_vert_hip_cm` (vaivén de la cadera sola); la lógica LOSO vive en `Evaluar_vs_Kuopio_Avance.m`.
  - **Resultado: r_y medio sube de 0.635 (SD=0.066) a 0.867 (SD=0.044), RMSE de 3.70cm a 1.95cm**, N=15. La forma de doble rebote (~15% y ~85% del ciclo) ya se reproduce visualmente (ver figura, panel superior derecho — curva azul solida vs. la curva punteada del intento anterior).
  - **Refinamiento probado y descartado (mismo día):** escalar la plantilla por velocidad de marcha del sujeto (la amplitud del vaivén correlaciona r=0.558 con velocidad, regresión ajustada solo con los otros 14, LOSO) — **no mejora** (r_y medio=0.866 vs 0.867, prácticamente igual, empeora en más sujetos de los que mejora). Coincide con el hallazgo ya citado en `plan_ensamble_multimodelo.md` §3: con N chico, el promedio simple no pierde contra versiones "optimizadas". **Modelo final: plantilla LOSO simple, sin escalar.**
  - **Bug real encontrado y corregido el mismo día, durante el trabajo de TOBILLO (ver `TOBILLO/CIERRE_TOBILLO.md` §4 para el detalle completo):** `Koopman2014_Core` se llamaba con la velocidad ESTIMADA por Froude (`Temporizacion_Core`, basada solo en talla) en vez de la velocidad REAL medida por Kuopio para cada sujeto — para sujetos altos, Froude podía duplicar la velocidad real, inflando la amplitud angular de Koopman. Corregido en `Evaluar_vs_Kuopio_Avance.m` y `Evaluar_Individual_Kuopio.m` (usar `S.speed_ms*3.6`). **Resultado tras la corrección: r_x sube de 0.984 a 0.996 (RMSE 7.10→4.72cm), r_y sube de 0.867 a 0.892 (RMSE 1.95→1.33cm)** — mejora en ambos ejes, no solo el que motivó el hallazgo (tobillo). Cifras de esta sección ya actualizadas a la versión corregida.
  - **Figura final limpia** (`Evaluar_vs_Kuopio_Avance_figura.png`, regenerada) — muestra una sola versión (el modelo final), no la comparación "antes/después" que quedaba ambigua; la columna `r_y_abs_sinbob` se conserva en el CSV de resultados solo como referencia histórica.
  - **Validación por sujeto individual** (`Evaluar_Individual_Kuopio.m`, nuevo) — 6 sujetos elegidos para maximizar diversidad de sexo/talla/masa dentro de la muestra de 15 (el más pesado 40=136kg, el más alto 37=186.6cm, el más liviano 43=61kg, la más baja 46=165cm F, más una mujer y un hombre de talla/masa media). Consistente en todos: r_x entre 0.952–0.999, r_y entre 0.845–0.911 — el modelo generaliza razonablemente bien en todo el rango de antropometría disponible, sin un sujeto que falle notoriamente. El sujeto 37 (el más alto) muestra el mayor desfase de forma en X (el modelo se atrasa a mitad de ciclo y alcanza después) — declarado, no oculto. Ver `Evaluar_Individual_Kuopio_figura.png`.
- **Nota de alcance:** usar Kuopio rompe la regla previa "reservada para validación final junto con Camargo" — decisión explícita del usuario (25-ago-2026), consciente de que ya no queda un dataset 100% no tocado para el examen final del generador completo.
- **Pendiente si se quiere más robustez:** ampliar de N=15 a más de los 51 sujetos disponibles (mismo pipeline, solo cambiar la lista `IDS` en `extraer_kuopio.py`); 2 de los 15 sujetos originalmente elegidos (07, 10) no tenían el marcador de tobillo calibrado y se reemplazaron por 08/11.

## 7-bis. Calibración de ganancia (SIN offset), LOSO — 25-ago-2026

Igual que en `INCLINACION_TIBIAL/` (mismo día): con r ya alto (X=0.996, Y=0.892), el usuario pidió evaluar si un ajuste reduce el RMSE. Primer intento: calibración afín completa (`pred_final = a + b·pred_geometrico`, LOSO) — **bug real, detectado visualmente por el usuario**: la curva calibrada dejaba de empezar en 0 (arrancaba en ~5cm) y se veía una línea plana artificial al inicio del ciclo. Causa: estas curvas de posición están **forzadas a 0 en pct=0 para todo sujeto** (real y geométrico, por construcción) — un offset aditivo (`a≠0`) rompe esa restricción sin ningún sentido físico. Matemáticamente, forzar la curva calibrada a volver a empezar en 0 equivale exactamente a **descartar el offset y quedarse solo con la ganancia** (`a` se cancela al re-centrar). Se corrigió usando regresión por el origen (solo ganancia `b`, sin intercepto), ajustada con los otros 14 sujetos (LOSO):

| | r (no cambia) | RMSE geométrico | RMSE con ganancia LOSO |
|---|---|---|---|
| X | 0.996 | 4.72cm | 4.85cm (±ruido, sin mejora neta pero ya sin el artefacto) |
| Y | 0.892 | 1.33cm | 0.83cm |

## 7-ter. Cierre de ciclo en Y — 25-ago-2026

Mismo hallazgo que en tobillo (ver `TOBILLO/CIERRE_TOBILLO.md` §7-bis, mismo día): en marcha periódica, la rodilla debe terminar el ciclo a la misma altura de donde partió. Real cierra entre 0.3-1.9cm (~0); el modelo sin corregir cerraba sistemáticamente ~1.7-1.8cm — más chico que en tobillo (~9cm), pero real y consistente en los 15 sujetos. Se corrigió con una rampa suave en todo el ciclo (aquí no hay división apoyo/balanceo, es el modelo continuo) que fuerza el cierre exacto.

**Resultado (reemplaza la fila Y de la tabla de arriba):** r=0.887 (baja levemente de 0.892), RMSE=1.01cm (sube levemente de 0.83cm). A diferencia de tobillo (donde el cierre fue una mejora grande), aquí el efecto es casi neutro en las métricas — se aplica de todas formas porque es la curva físicamente correcta (cierra en 0 como el dato real), no porque optimice el número. Aplicado en `Evaluar_vs_Kuopio_Avance.m` y `Evaluar_Individual_Kuopio.m`.

**Nota metodológica:** `RMSEnorm` (la métrica propia del proyecto, `Calcular_Metricas_Curva.m`) **no se usa aquí** — estas curvas de posición están forzadas a 0 en pct=0 para todos los sujetos (y varían muy poco entre sí en los primeros % del ciclo), lo que hace que normalizar por el SD entre sujetos en cada punto dispare valores sin sentido cerca del inicio. RMSEnorm sí es la métrica correcta para el ángulo tibial (`INCLINACION_TIBIAL/`), que **no** tiene esta restricción de arranque en 0 — ahí la calibración SÍ incluye offset y es válida tal cual.

Aplicado en `Evaluar_vs_Kuopio_Avance.m` y `Evaluar_Individual_Kuopio.m` — MODELO FINAL vigente de rodilla.

## 8. MODELO FINAL VIGENTE (25-ago-2026, reemplaza §7-bis y §7-ter): la corrección se aplica al ÁNGULO, no a la posición

Las secciones §7-bis/§7-ter quedan **superadas**. Se conservan como historial de cómo se llegó acá, pero el modelo vigente es el de esta sección.

**Qué se encontró.** Al graficar el modelo pareado sujeto a sujeto (objeción del usuario contra promediar curvas de antropometría distinta, ver §9) quedó visible que la curva vertical predicha era **notoriamente más plana que la real**. Medido: el modelo reproducía solo el **51% de la excursión vertical real** (2.42 cm contra 4.75 cm). El RMSE parecía bueno (1.01 cm) solo porque la señal misma es chica — la métrica estaba escondiendo el problema.

**Causa raíz, diagnosticada por etapas.** El defecto no estaba en la geometría sino en el ángulo publicado por Koopman:

| Cantidad | Real (Kuopio) | Koopman | |
|---|---|---|---|
| Ángulo de muslo, correlación | — | — | **r=0.971** — la forma es casi exacta |
| Ángulo de muslo, excursión | 32.5° | 39.2° | **+21% de sobreestimación** |

Al sumar ese término inflado al vaivén de cadera, la amplitud resultante salía 7.12 cm contra 4.75 cm reales, y la ganancia LOSO aplicada **sobre la posición** (b=0.361) la aplastaba para minimizar el RMSE. Es decir: se estaba corrigiendo el síntoma con un factor que no tiene interpretación física, en el lugar equivocado.

**El mismo defecto ya se había encontrado, por separado, en el ángulo tibial** (ganancia 0.811, `INCLINACION_TIBIAL/CIERRE_INCLINACION_TIBIAL.md` §5). Con la ganancia de muslo (0.769) medida acá queda claro que es **un solo defecto del modelo publicado — sobreestima la excursión angular ~20-23% en esta población —, no uno por eje ni por segmento.**

**Corrección aplicada.** Calibración afín `θ_real = a + b·θ_Koopman` sobre el **ángulo de muslo**, ajustada por LOSO (los coeficientes de cada sujeto salen de los otros 14). Luego la geometría propaga a posición **sin ninguna calibración adicional** — la ganancia por eje sobre X/Y se eliminó.

**Resultado — mejora en las tres métricas a la vez:**

| | §7-bis (ganancia de posición) | **Modelo final (ángulo calibrado)** |
|---|---|---|
| Ángulo de muslo, RMSE | (no se calibraba) | 7.34° → **3.60°** |
| X — r / RMSE | 0.996 / 4.85 cm | **0.998 / 3.97 cm** |
| Y — r / RMSE | 0.887 / 1.01 cm | **0.920 / 0.72 cm** |
| Y — amplitud modelo/real | **0.51×** | **0.82×** |

Coeficientes: ganancia 0.769, offset −2.69°. El modelo además queda **más simple**: una sola corrección empírica de escala (en el ángulo) en vez de dos encadenadas (ángulo implícito + posición).

**Probado y descartado el mismo día** (se documenta para no repetirlo):
- **Plantilla LOSO de la desviación horizontal de la cadera** respecto de velocidad constante. El sesgo existe y es real (amplitud 6.9 cm, la cadera va por delante del avance uniforme ~5 cm a mitad de ciclo), pero su consistencia entre sujetos es baja (r=0.61 LOSO, mínimo 0.11) y **empeora X** (RMSE 3.97 → 4.27 cm). Se mantiene el avance a velocidad constante — que además es lo único que el generador puede usar sin datos medidos.
- **Escalar la plantilla del vaivén de cadera** por longitud de pierna (r=0.11 con la amplitud real) o por el modelo de péndulo compás (r=0.58): **no mejora** (RMSE 0.719 → 0.716 cm, r baja de 0.920 a 0.917). Tercer caso en este proyecto en que el promedio simple no pierde contra una versión "optimizada" con N chico — consistente con `plan_ensamble_multimodelo.md` §3.
- **Dato de respaldo que sí quedó:** el péndulo compás predice una amplitud media de vaivén de cadera de **4.18 cm** contra **4.11 cm** medidos — la plantilla empírica coincide en magnitud con un modelo físico independiente, así que no es un ajuste arbitrario.

**Lo que queda declarado, no resuelto:** la amplitud vertical sigue al 82% de la real. El residuo es variabilidad real entre sujetos del vaivén de cadera que una plantilla poblacional no captura; ampliar N es el único camino de mejora que queda, no más ajustes de escala.

## 9. Prueba individual, y por qué la de grupo cambió (25-ago-2026)

Objeción del usuario, correcta: la figura de grupo comparaba `media(real)` contra `media(predicho)`. Como el modelo se alimenta de sexo/talla/masa y velocidad de **cada** sujeto, promediar trayectorias de antropometrías distintas mezcla curvas que no son comparables entre sí — y la conclusión no depende de esa gráfica.

Cambios aplicados en las 3 carpetas:
- **La figura de grupo ya no promedia**: muestra cada sujeto **pareado con su propia predicción**, más las curvas de error por sujeto con banda media±SD, más los histogramas de r. Las tres cosas son válidas con antropometría heterogénea.
- **`Evaluar_Individual_Kuopio.m` es ahora la prueba de referencia** — 6 sujetos elegidos por diversidad máxima (el más pesado 40=136 kg, el más alto 37=186.6 cm, el más liviano 43=61 kg, la más baja 46=165 cm F, una mujer media 19, un hombre de talla media 28). **Son los mismos 6 en las 3 carpetas**, para poder comparar rodilla/tobillo/ángulo sujeto a sujeto.
- **Una sola implementación del modelo**: el script individual ya no duplica la lógica — llama a `Evaluar_vs_Kuopio_Avance(false)` y grafica exactamente las curvas que producen las estadísticas reportadas. Antes ambos duplicaban el cálculo y podían divergir en silencio.

Resultado individual (los 6, modelo final): r_x entre 0.995 y 0.999, r_y entre 0.896 y 0.967. Ningún sujeto falla — el modelo generaliza en todo el rango de antropometría disponible.

## 10. Qué sigue

Pendiente por decisión del usuario: repetir el mismo proceso para el **TOBILLO**, y luego para el **ángulo de inclinación tibial** (que puede no necesitar modelo propio — se deriva de cadera+rodilla ya resueltos vía `Cadena_Completa_Core.m`/`Obtener_Theta_Tibia_Candidato.m`). Recién con los 3 resueltos, decidir cómo se juntan (y si esto reemplaza el plan de ensamble de 4 modelos, pregunta pospuesta desde el 24-ago).
