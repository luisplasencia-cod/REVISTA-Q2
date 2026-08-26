# Plan de ensamble multi-modelo — combinar Koopman+Zhao+Yun+Romero-Sorozábal

**Creado:** 24-ago-2026 (sesión larga, continuación directa de `plan_100_generador.md`, que cerró en 100/100 el 23-ago). **Este documento existe porque el usuario, tras ver el generador funcionando, decidió que quiere ir más allá de "comparar candidatos" — quiere **combinarlos** como aporte propio, apuntando a que el artículo sea Q1.**

> **Relación con los otros planes:** `plan_100_generador.md` (generador básico, un candidato a la vez) queda cerrado y sin tocar — este documento es la ETAPA SIGUIENTE, no lo reemplaza. `analisis_escalamiento_Q1_generador_trayectorias.md` sigue siendo el documento de diseño de fondo (Niveles A/B/C de validación, compuertas G1-G6) — este plan es más específico: cómo construir el ensamble y con qué respaldo.

---

## 1. La pregunta de fondo que se resolvió esta sesión

El usuario preguntó: *"¿por qué no integrarlo para agarrar lo mejor de cada uno?"* — la respuesta completa, en orden de cómo se fue cerrando:

1. **Combinar SALIDAS (cada modelo corre completo, se promedian las curvas resultantes) es legítimo.** Combinar **estructura interna** (mezclar coeficientes de spline de Koopman con armónicos de Fourier de Zhao) NO es viable — los tres modelos no comparten parametrización, sería literalmente inventar una regla de mezcla sin base matemática (el "ad hoc sin respaldo" que un revisor de Q1 rechaza).
2. **La regla de combinación tiene que fijarse ANTES de mirar los datos de validación (Camargo)** — si se ajusta después de ver qué "funciona mejor", deja de ser validación y se vuelve circular (misma regla ya establecida en el proyecto para los coeficientes de cada candidato individual, P-23).
3. **Con pocos modelos (n=4), el promedio simple es la opción más defendible**, no la mediana — respaldado por el "forecast combination puzzle" (ver §3).

---

## 2. Los 4 candidatos viables — de 12 investigados a fondo

**Búsqueda sistemática, 24-ago-2026** (partiendo de los 6 ya identificados el 19/20-ago en `analisis_escalamiento_Q1_generador_trayectorias.md` §4.5, más 6 nuevos encontrados esta sesión). Criterio de inclusión: publica coeficientes/parámetros **usables sin reentrenar** (regla P-23) Y personaliza por **antropometría estática** (talla/masa/velocidad — no por sensor en tiempo real, no solo por pendiente del terreno).

### 2.1 Adoptados

| # | Candidato | Venue | Método | Entrada | Salida | Estado |
|---|---|---|---|---|---|---|
| 1 | Koopman, van Asseldonk & van der Kooij 2014 | J Biomech 47(6) | Splines quínticos por tramos | velocidad + talla | cadera(ab/ad, flex/ext), rodilla, tobillo | ✅ Implementado (`Koopman2014_Core.m`) |
| 2 | Zhao, Wei, Xie, Liu, Qu, Cao, Ding & Liao 2026 | PLOS ONE | Fourier | pierna + masa + cadencia | cadera, rodilla (+ GRF, no usado) | ✅ Implementado (`Zhao2026_Core.m`) |
| 3 | Yun, Kim, Shin, Lee, Deshpande & Kim 2014 | J Biomech | GPR (toolbox real, sin reentrenar) | 14 parámetros antropométricos | cadera, rodilla, tobillo | ✅ Implementado (`Yun2014_Wrapper.m`) |
| 4 | **Romero-Sorozábal, Delgado-Oleas, Laudanski, Gutiérrez & Rocon 2024** | *Biomimetics* (MDPI, acceso abierto) | Regresión (β₀+β₁·v+β₂·v²+β₃·h) | talla + velocidad | **posición 3D (x,y,z) de cadera, rodilla Y tobillo directo** — no ángulos | ⬜ **Sin implementar todavía** — ver §5 |

**Por qué Romero-Sorozábal es el más importante de los 4 nuevos:** da la posición real de **cadera, rodilla Y tobillo** por separado, no solo ángulos. Esto resuelve algo que el generador básico (`plan_100_generador.md`) resolvía con un supuesto (tobillo fijo, modelo de péndulo invertido, `Cadena_Cinematica_Core.m`) — con este modelo, el segmento tibial se puede construir directo desde **coordenadas reales de los dos extremos**, sin asumir ningún punto fijo. Coeficientes publicados en las Tablas A1-A3 del apéndice.

**✅ VERIFICADO A TEXTO COMPLETO — 24-ago-2026, sesión de continuación.** PDF descargado del repositorio institucional UPM (acceso abierto, `oa.upm.es/89695/1/10239024.pdf`), copia local en `docs/literatura/pdfs/RomeroSorozabal2024_Biomimetics.pdf`. Extracción con `pdfplumber` (mismo método que resolvió el problema de signos de Koopman). Confirmado línea por línea contra el PDF real:
- **Dataset:** Fukuchi, Fukuchi & Duarte 2018, *PeerJ* 6:e4640 — público, independiente, **no es Camargo 2021** (sin riesgo de solapamiento con la base de validación ya elegida). n=42 (24 adultos jóvenes, media 27.6 años/171.1cm/68.4kg; 18 adultos mayores, media 62.7 años/161.8cm/66.9kg). 28 marcadores, mocap 12 cámaras a 150Hz (Raptor-4), fuerza a 300Hz. 8 velocidades por sujeto derivadas del **número de Froude** de su velocidad autoseleccionada (40-145%) — **mismo método que ya usa el generador propio para E4** (`Estimar_Velocidad_Froude_Core.m`, Fr=0.25), buen paralelo metodológico citable. 15,531 pasos tras excluir outliers de duración (fuera de rango intercuartil 25-75%).
- **Modelo confirmado:** regresión robusta (peso bicuadrado) sobre 66 key-points (t%ciclo, posición) de las 3 articulaciones × 3 ejes, ecuación exacta: `Y = β0 + β1·v + β2·v² + β3·l`, v=velocidad, l=talla. Reconstrucción final por interpolación spline entre key-points — arquitectura análoga a Koopman (splines por key-points) pero en posición 3D en vez de ángulo.
- **RMSE global 13.40mm/correlación 0.92 (regresión) confirmado en el abstract** — pero el detalle real (Tablas A1-A3, 66 filas) muestra **rango real mucho más amplio por key-point**: de 0.60mm (mejor, tobillo eje-t) a 108.53mm (peor outlier, cadera eje-Z key-point 3) — la cifra global del abstract esconde variabilidad importante entre puntos. **Antes de usar cualquier coeficiente en `Romero_Sorozabal2024_Core.m`, revisar la fila específica, no asumir que todas tienen la precisión del RMSE global.**
- **Las 3 tablas completas (A1 cadera, A2 rodilla, A3 tobillo, 66 filas con β0-β3 y RMSE por key-point) están extraídas y disponibles** — texto crudo en el PDF local, listas para transcribir a `Romero_Sorozabal2024_Core.m` cuando se implemente (paso 4 de §5).
- **LSTM (12.57mm/0.99) no se usa** — confirma la regla P-23/33% de candidatos reutilizables sin reentrenar: la LSTM de este mismo paper tampoco publica pesos entrenados, solo la arquitectura.

### 2.1-bis `Romero_Sorozabal2024_Core.m` implementado y probado — 24-ago-2026, sesión de continuación

**Construido** (`CODIGOS/GENERADOR/Romero_Sorozabal2024_Core.m` + `Test_RomeroSorozabal.m`, mismo patrón Core/Test que los otros 3 candidatos), 66 key-points de las Tablas A1-A3 transcritos y verificados. Dos hallazgos reales durante la verificación en MATLAB:

1. **Bug real (mío, corregido):** con `v` en km/h (como usa Koopman), el parámetro de tiempo (t, %ciclo) de varios key-points salía no-monótono y hasta por encima de 100% incluso con talla/velocidad medianas del propio dataset (171cm/4.6kph) — incompatible con el RMSE de t reportado (0.6-13.17%). Diagnóstico: `v` debe evaluarse en **m/s**, no km/h (a diferencia de Koopman) — el paper nunca lo declara explícitamente, se encontró empíricamente. Con la corrección, t_key queda monótono y cercano a β0, y cadera (hip) en los 3 ejes queda dentro del rango esperado de la Fig.2b/3a del paper.

2. **Anomalía real de la fuente publicada, SIN resolver (no es error de transcripción ni del código):** con la corrección de unidades ya aplicada, la posición vertical (Z) de rodilla y tobillo sale sistemáticamente **~2x más profunda** de lo esperado por las fracciones antropométricas de Winter/Drillis&Contini (las mismas que ya usa `Estimar_Antropometria_Core.m`). Verificado con dos chequeos independientes (distancia absoluta pelvis→articulación, y longitud de segmento por diferencia entre articulaciones adyacentes — este último cancela cualquier supuesto sobre dónde está exactamente el marcador de pelvis): ambos dan el mismo factor ~2x, tanto para muslo como para pierna. Se re-extrajeron las Tablas A2/A3 desde la página HTML de MDPI (fuente independiente del PDF ya leído) y coinciden número por número — descarta error de lectura. No existe fe de erratas ni repositorio de datos/código público de los autores (búsqueda hecha, sin resultado). Cadera (hip) Z sí es consistente, no tiene este problema — el patrón está aislado a rodilla y tobillo.

**Decisión del usuario (24-ago-2026):** no se pierde tiempo escribiendo a los autores ni se usa el dato tal cual con caveat — se **excluye el eje Z de rodilla/tobillo de Romero-Sorozábal del ensamble por completo**. `Combinar_Candidatos_Core.m` (paso 5 de §5) solo tomará el eje **X** (sagital) de este candidato — que sí se ve consistente y monótono en la verificación visual —, y el eje Z se combinará solo entre Koopman/Zhao/Yun (vía `Segmento_Posicion_Core.m`, como ya estaba planeado para esos 3). Los campos `.rodilla.z_m`/`.tobillo.z_m` del Core quedan calculados y disponibles (fieles a la tabla publicada, sin "corregir" con un factor inventado) mas no se consumen aguas abajo — documentado en el encabezado del `.m` para que quede trazable si en el futuro aparece una aclaración de los autores.

**8/8 tests PASS** tras el ajuste (`Test_RomeroSorozabal.m`, corrido en MATLAB R2025b real). Figura de verificación: `CODIGOS/GENERADOR/Test_RomeroSorozabal_figura.png`.

### 2.2 Descartados — investigados a fondo, con motivo verificado (no solo por abstract)

| # | Candidato | Venue | Motivo del descarte |
|---|---|---|---|
| 5 | Semwal, Jain, Maheshwari & Khatwani 2023 | Multimedia Tools and Applications | LSTM+CNN, caja negra, sin pesos publicados |
| 6 | Xin, Li, Qin, Liu, Wang, Luo, Zhuang & Zhou 2025 | Electronics (MDPI) | Demasiado nuevo (0 citas), sin verificar a texto completo |
| 7 | **Hu, Shen, Zhao, Qu & Ye 2020** | J Biomech 112 | **PDF leído completo (6 pág.)** — LASSO regression, RMSE 3.41-4.55°, pero **no publica los coeficientes del LASSO en ningún lado**, ni tabla ni apéndice ni material suplementario |
| 8 | **Luu, Low, Qu, Lim & Hoon 2014** | Gait & Posture 39 | **PDF leído completo** — GRNN, necesita **toda la base de entrenamiento** (600 caminatas de 70 sujetos) para funcionar, no son solo coeficientes reutilizables |
| 9 | **Wu, Liu, Liu, Chen & Guo 2018** | IEEE Trans. Automation Science and Engineering 15(4) | **PDF leído completo (12 pág.)** — autoencoder + GPR con matrices de pesos (W_en, b_en, W_de, b_de) no publicadas. Además solo da cadera+rodilla, sin tobillo |
| 10 | **Luu, Lim, Qu, Hoon & Low 2011** | IEEE ICORR | **PDF leído completo** — MLPNN (red neuronal), pesos entrenados no publicados |
| 11 | Shkedy Rabani, Mizrachi, Sawicki & Riemer 2022 | PLOS ONE | Verificado vía WebFetch — **no personaliza por antropometría**, solo por pendiente del terreno (talla/masa solo se usan para escalar potencia/momento en postproceso, no entran en la ecuación de ángulo) |
| 12 | Al Kouzbary, Al Kouzbary, Liu et al. 2026 | Applied Intelligence | Verificado vía WebSearch — necesita **ángulo tibial en tiempo real** (sensor) como entrada, no antropometría estática. Circular para nuestro caso |

**Hallazgo metodológico, citable en la sección de Métodos:** de 12 candidatos investigados a fondo (no solo por abstract — 4 con PDF completo leído línea por línea), **solo 4 (33%) publican parámetros reutilizables sin reentrenar**. La mayoría de la literatura de predicción de marcha usa redes neuronales que nunca comparten los pesos entrenados — un problema de reproducibilidad real del campo, no una limitación de nuestra búsqueda.

### 2.3 Categorías buscadas y descartadas sin candidato específico

- **Generadores geométricos puros** (círculo en apoyo + elipse en balanceo, convención de robótica de piernas) — encontrados casi exclusivamente en literatura de **robots cuadrúpedos**, no marcha humana, sin un paper específico verificable con parámetros personalizables por antropometría humana.
- **Trayectoria desde IMU en tiempo real** (fusión FMG+IMU, redes de base radial para exoesqueletos) — necesitan sensor en vivo, no antropometría estática.
- **iSen/STT-IWS y sistemas similares** — son **instrumentos de captura**, no algoritmos generadores. No son candidatos, son la herramienta de medición (que el proyecto ya usa para otro propósito, validación).

---

## 3. Respaldo estadístico para combinar con n=4 (no un ensamble grande)

**La pregunta que se resolvió:** ¿es válido combinar solo 4 modelos, o hace falta un ensamble grande (10+) como sugiere parte de la literatura de forecasting?

### 3.1 El método: promedio simple, no mediana ni pesos optimizados

- **Bates, J. M., & Granger, C. W. J. (1969).** *The combination of forecasts.* Operational Research Quarterly, 20(4), 451–468. DOI: 10.1057/jors.1969.103. Verificado bibliográficamente en 4 fuentes independientes (Springer, SciRP, Semantic Scholar, Tandfonline) — **no leído a texto completo todavía**. Combinaron originalmente solo **dos** pronósticos — precedente directo para n pequeño.
- **"Forecast combination puzzle"** (Clemen 1989, revisó 200+ artículos; Stock & Watson 2004): el promedio simple le gana sistemáticamente a combinaciones con pesos optimizados, porque estimar pesos agrega su propio ruido. Hallazgo robusto de décadas.
- **Clements, A., & Vasnev, A. L. (2024).** *Forecast combination puzzle in the HAR model.* Journal of Forecasting, 43(1), 118–137. DOI: 10.1002/for.3029. **✅ VERIFICADO A TEXTO COMPLETO — 24-ago-2026** (PDF conseguido por el usuario con acceso PUCP, `docs/literatura/pdfs/Journal of Forecasting - 2023 - Clements - Forecast combination puzzle in the HAR model.pdf`). Confirmado exacto: el modelo HAR **es literalmente una combinación de 3 predictores** — realización del día anterior (random walk), promedio de la semana anterior, promedio del mes anterior (Sec.2.4, "we take a step back and view the HAR model as a forecast combination that combines three predictors"). El promedio simple (`sa`, n=3, Ec.7 del paper) **supera consistentemente** al HAR con pesos óptimos por OLS en MSE y QLIKE, across horizontes de 1 a 22 días, para el índice Dow Jones, 26 acciones individuales, y otros activos (oro, plata, petróleo, tipos de cambio) — mejoras de hasta ~45-47% en MSE a 10 días (Tabla 1). Es la primera vez que el "forecast combination puzzle" se documenta en este contexto, con n=3 explícito. **Precedente directo y ya verificado para n=3-4** de este proyecto.
- **Mediana vs. promedio:** literatura es clara en que la mediana es más robusta a outliers, pero la comparación mean/mediana es *"mixed and largely data-dependent"* — sin ganador universal. Estudios que muestran ventaja de mediana/moda sobre promedio usan **ensembles de 10 a 100 miembros** — con n=4, la mediana no hace el trabajo estadístico que la hace valiosa (es literalmente "el del medio de 4", sensible a azar).
- **Decisión: promedio simple**, con la salvedad declarada de que el beneficio de reducción de varianza es real pero modesto con n=4 (la literatura dice que el beneficio crece con más modelos — no se exagera el efecto).

### 3.1-bis Verificación a texto completo — 24-ago-2026, sesión de continuación

**Intento inicial bloqueado:** Wiley (`onlinelibrary.wiley.com/doi/full/10.1002/for.3029` y `/epdf/...`) y SSRN dieron 403 sin acceso institucional para ambos papers.

**Clements & Vasnev 2024 — ✅ CERRADO en la misma sesión** (turno posterior): el usuario consiguió el PDF con su acceso PUCP y lo puso en `docs/literatura/pdfs/`. Verificado a texto completo — ver el detalle completo ya volcado en §3.1 arriba. Confirma exactamente lo que estaba citado por búsqueda (n=3, HAR = combinación de 3 predictores, promedio simple gana al óptimo).

**Bates & Granger 1969 — sigue sin verificar a texto completo.** DOI para buscar con acceso PUCP: `10.1057/jors.1969.103` (Journal of the Operational Research Society, 1969). Es el único ítem que queda abierto de todo `plan_ensamble_multimodelo.md`.

**En su lugar, se verificó a texto completo un tercer paper de acceso abierto que trata el mismo fenómeno y cita a ambos como parte de su fundamento** (Frazier, Covey, Martin & Poskitt 2023, *"Solving the Forecast Combination Puzzle"*, arXiv:2308.05263, Monash University — sin verificar si fue publicado en journal con peer review, o si sigue siendo preprint; **si se cita en el manuscrito, aclarar el estatus de publicación**). Confirma lo ya documentado — el "forecast combination puzzle" (pesos optimizados no superan al promedio simple) es un hallazgo empírico de 50+ años, documentado en Stock & Watson 2004, Smith & Wallis (2009), Makridakis et al. 2018/2020 — y explicado formalmente: el ruido de muestreo al estimar los pesos (en vez de fijarlos) introduce una penalización que compensa cualquier ganancia teórica de optimizar.

**Matización nueva, importante para el manuscrito — no estaba en la versión anterior de este documento:** este paper 2023 argumenta que el puzzle es **consecuencia específica del procedimiento en dos pasos** (1. estimar cada modelo constituyente por separado, 2. estimar los pesos de combinación por separado) — y que si la combinación se produce en **un solo paso** (pesos y modelos estimados conjuntamente), el puzzle desaparece y los pesos optimizados sí superan al promedio. **Esto no invalida la decisión de promedio simple para este proyecto — la refuerza**: los 4 candidatos (Koopman/Zhao/Yun/Romero-Sorozábal) son modelos ya publicados con coeficientes fijos de la literatura, no se re-estiman junto con ningún peso — es exactamente el escenario de dos pasos donde el puzzle aplica y el promedio simple es la opción defendible. Declarar esta razón explícitamente en Métodos es más fuerte que solo citar "el promedio gana" sin el mecanismo.

### 3.2 Precedente cruzado de otro campo (ecología, no economía)

**Breiner et al. 2018**, *Ensemble of Small Models* (ESM), Methods in Ecology and Evolution — desarrollado específicamente para escenarios con pocos modelos/pocas observaciones, "largamente superior a modelos estándar". **No verificado a texto completo, encontrado solo vía búsqueda — pendiente si se usa en el manuscrito.** Sirve como precedente de que "ensamble con pocos modelos" no es exclusivo de econometría — es un patrón reconocido en más de un campo.

### 3.3 Cómo se justifica n=4 en el manuscrito (marco ya decidido)

No es "nos conformamos con pocos" — es:
1. Documentar la búsqueda exhaustiva (§2 de este documento) — el hallazgo de que la mayoría de la literatura no es reproducible es citable en sí mismo.
2. Citar el precedente HAR (Clements & Vasnev 2024) — mismo patrón (n pequeño, promedio simple), en un modelo de referencia ampliamente adoptado.
3. Reencuadrar el aporte: no es "un ensamble grande gana" — es **"el primer contraste + combinación simple, sobre hardware físico, de métodos independientes ya publicados"** (novedad ya establecida en `analisis_escalamiento_Q1_generador_trayectorias.md` §6, nadie hizo esto ni con 2 modelos).

---

## 4. La regla de combinación — CERRADA 24-ago-2026 (respuesta del usuario)

**Decisión final, las dos preguntas pendientes resueltas:**

1. **Combinación a nivel de POSICIÓN (x,z), no de ángulo.** Romero-Sorozábal entra directo (ya da posición 3D). Koopman/Zhao/Yun pasan por `Segmento_Posicion_Core.m` (ya construido, misma trigonometría directa del generador básico) para convertir su ángulo + longitud de segmento estimada (`Estimar_Antropometria_Core.m`) a posición (x,z) de rodilla y tobillo, antes de promediar. **Aclaración del usuario:** los componentes x (desplazamiento horizontal) y z (altura) pueden calcularse/combinarse **de forma separada** y unirse recién en el CSV final — no hace falta forzarlos por el mismo pipeline si no es natural.
2. **Peso igual para los 4** — confirmado, consistente con §3 (promedio simple, sin ponderación ad hoc).

**Regla final:**

```
x_rodilla_combinado(t) = mean(x_rodilla_Koopman(t), x_rodilla_Zhao(t), x_rodilla_Yun(t), x_rodilla_RomeroSorozabal(t))
z_rodilla_combinado(t) = mean(z_rodilla_Koopman(t), z_rodilla_Zhao(t), z_rodilla_Yun(t), z_rodilla_RomeroSorozabal(t))
x_tobillo_combinado(t) = mean(x_tobillo_Koopman(t), x_tobillo_Zhao(t), x_tobillo_Yun(t), x_tobillo_RomeroSorozabal(t))
z_tobillo_combinado(t) = mean(z_tobillo_Koopman(t), z_tobillo_Zhao(t), z_tobillo_Yun(t), z_tobillo_RomeroSorozabal(t))
```

Aplicado punto a punto sobre las curvas ya remuestreadas a %ciclo común (mismo patrón que `Generar_Trayectoria.m` ya usa para las fases apoyo/balanceo). El ángulo tibial final para el CSV del simulador se recupera con atan2 sobre (x,z) combinados si hace falta, o se guarda la posición directa — a decidir en el paso 6 según qué formato final espera `Escribir_CSV_Simulador.m`.

---

## 5. Qué falta, en orden

1. ~~Verificar Romero-Sorozábal 2024 a texto completo~~ — **cerrado 24-ago-2026** (ver §2.1, verificado línea por línea contra el PDF real vía `pdfplumber`, no vía MDPI directo que sigue dando 403 — se consiguió por el repositorio institucional UPM en su lugar).
2. **Verificar Bates & Granger 1969 y Clements & Vasnev 2024 a texto completo** — **intentado 24-ago-2026, bloqueado por 403 en Wiley/SSRN sin acceso institucional.** DOIs listos para buscar con acceso PUCP: `10.1057/jors.1969.103` y `10.1002/for.3029` (ver §3.1-bis). Mientras tanto, la afirmación central queda respaldada por un tercer paper de acceso abierto ya leído completo (Frazier et al. 2023, arXiv:2308.05263) — suficiente para redactar Métodos, pero **fijar los dos originales antes del envío final** si el usuario consigue el acceso.
3. ~~Decidir la regla de combinación exacta~~ — **cerrado 24-ago-2026** (§4: posición 3D x,z; K/Z/Y vía `Segmento_Posicion_Core.m`, Romero-Sorozábal directo en X; peso igual para los 4; Z de rodilla/tobillo de Romero-Sorozábal excluido por la anomalía de §2.1-bis).
4. ~~Implementar `Romero_Sorozabal2024_Core.m`~~ — **cerrado 24-ago-2026**, 8/8 tests PASS (ver §2.1-bis).
5. ~~Implementar `Combinar_Candidatos_Core.m`~~ — **cerrado 24-ago-2026**, 6/6 tests PASS (`Test_Combinar_Candidatos.m`, figura `CODIGOS/GENERADOR/Test_Combinar_Candidatos_figura.png`). Combina en el punto de la rodilla anatómica (Restricción #1 del propio archivo), Z solo con Koopman/Zhao/Yun (Restricción #2), y deja declarado sin resolver el desajuste "tobillo fijo" (K/Z/Y) vs. "tobillo real medido" (Romero-Sorozábal) durante el apoyo (Restricción #3) — no se oculta, se documenta como limitación abierta para cuando se conecte la cadena de muslo completa.
6. ~~Actualizar `Generar_Trayectoria.m`~~ — **cerrado 24-ago-2026**: nueva opción `candidato='Combinado'`, con la restricción de que solo admite `punto_seguimiento_m = long_tibia_m` (error explícito si se pide otro punto, ya que Romero-Sorozábal no publica posición de puntos intermedios del segmento). 6/6 tests PASS (`Test_Generador_Combinado.m`).
7. Recién después de 1-6: correr contra Camargo (Nivel A/B, fuera del alcance de este documento — ver `analisis_escalamiento_Q1_generador_trayectorias.md` §7). **Hallazgo visual ya adelantado en la figura del paso 5 (dispersión entre candidatos):** los 4 candidatos discrepan bastante entre sí en X (rango hasta ~60cm en algunos tramos del ciclo) — esperable dado que son modelos independientes con arquitecturas distintas, pero es una señal de que la validación contra Camargo va a ser la que realmente diga si el promedio ayuda o si conviene pesar/filtrar algún candidato. No se actúa sobre este hallazgo todavía — es insumo para el paso 7, no una alarma a resolver aquí.

### 5-bis Hallazgo adicional (bonus, no planeado): bug de robustez de ruta en `Yun2014_Wrapper.m`

Al construir `Combinar_Candidatos_Core.m`, correr `Yun2014_Wrapper.m` como **primer** candidato de la sesión de MATLAB (antes de cualquier llamada a `Koopman2014_Core.m`) hacía que `Reduccion_Winter_Core.m` dejara de resolverse tras el `cd()` interno al toolbox de terceros (error real: `"Incorrect number or types of inputs or outputs for function Reduccion_Winter_Core"`). Causa: la función dependía de que su propia carpeta (`CODIGOS/GENERADOR/`) fuera el directorio de trabajo (resolución dinámica por cwd), no de estar en el `path` persistente de MATLAB — se rompía en cuanto el `cd()` cambiaba el directorio de trabajo a otra carpeta, salvo que algún candidato anterior en la misma sesión ya hubiera "cacheado" la función. **Corregido** con un `addpath(fileparts(mfilename('fullpath')))` al inicio de `Yun2014_Wrapper.m`, antes del `cd()`. Verificado en un proceso de MATLAB limpio llamando a Yun como primer candidato — funciona. Re-corridos `Test_Generador.m` (22/22) y `Test_Generador_Trayectoria.m` (18/18) después del fix — sin regresión.

**Estado final de esta sesión — todos los tests de `CODIGOS/GENERADOR/` en verde:** `Test_Generador.m` 22/22, `Test_Generador_Trayectoria.m` 18/18, `Test_RomeroSorozabal.m` 8/8, `Test_Combinar_Candidatos.m` 6/6, `Test_Generador_Combinado.m` 6/6.

**Nada de esto está commiteado en el momento de escribir este documento** — pendiente de confirmación del usuario, mismo patrón que el resto del proyecto.
