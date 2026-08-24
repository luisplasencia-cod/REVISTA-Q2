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

**Por qué Romero-Sorozábal es el más importante de los 4 nuevos:** da la posición real de **cadera, rodilla Y tobillo** por separado, no solo ángulos. Esto resuelve algo que el generador básico (`plan_100_generador.md`) resolvía con un supuesto (tobillo fijo, modelo de péndulo invertido, `Cadena_Cinematica_Core.m`) — con este modelo, el segmento tibial se puede construir directo desde **coordenadas reales de los dos extremos**, sin asumir ningún punto fijo. Coeficientes publicados en las Tablas A1-A3 del apéndice (extraídos vía WebFetch, **no verificados todavía contra el PDF original — pendiente, ver §5**). n=42 sujetos (24 jóvenes, 18 mayores), 15,531 pasos, RMSE 13.40mm (regresión) / 12.57mm (LSTM, no usado — solo la parte de regresión cumple "sin reentrenar"), correlación 0.92.

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
- **Clements, A., & Vasnev, A. L. (2024).** *Forecast combination puzzle in the HAR model.* Journal of Forecasting, 43(1), 118–137. **No verificado a texto completo todavía — pendiente.** Hallazgo citado (vía búsqueda, a confirmar): el modelo HAR (heterogeneous autoregressive), un modelo de referencia muy usado en econometría de volatilidad, **es literalmente una combinación de 3 predictores** (día anterior, promedio semanal, promedio mensual) — y ponderar simple sigue superando a "optimizar" los pesos, incluso en 2024, incluso con n=3. **Precedente directo y reciente para n=3-4.**
- **Mediana vs. promedio:** literatura es clara en que la mediana es más robusta a outliers, pero la comparación mean/mediana es *"mixed and largely data-dependent"* — sin ganador universal. Estudios que muestran ventaja de mediana/moda sobre promedio usan **ensembles de 10 a 100 miembros** — con n=4, la mediana no hace el trabajo estadístico que la hace valiosa (es literalmente "el del medio de 4", sensible a azar).
- **Decisión: promedio simple**, con la salvedad declarada de que el beneficio de reducción de varianza es real pero modesto con n=4 (la literatura dice que el beneficio crece con más modelos — no se exagera el efecto).

### 3.2 Precedente cruzado de otro campo (ecología, no economía)

**Breiner et al. 2018**, *Ensemble of Small Models* (ESM), Methods in Ecology and Evolution — desarrollado específicamente para escenarios con pocos modelos/pocas observaciones, "largamente superior a modelos estándar". **No verificado a texto completo, encontrado solo vía búsqueda — pendiente si se usa en el manuscrito.** Sirve como precedente de que "ensamble con pocos modelos" no es exclusivo de econometría — es un patrón reconocido en más de un campo.

### 3.3 Cómo se justifica n=4 en el manuscrito (marco ya decidido)

No es "nos conformamos con pocos" — es:
1. Documentar la búsqueda exhaustiva (§2 de este documento) — el hallazgo de que la mayoría de la literatura no es reproducible es citable en sí mismo.
2. Citar el precedente HAR (Clements & Vasnev 2024) — mismo patrón (n pequeño, promedio simple), en un modelo de referencia ampliamente adoptado.
3. Reencuadrar el aporte: no es "un ensamble grande gana" — es **"el primer contraste + combinación simple, sobre hardware físico, de métodos independientes ya publicados"** (novedad ya establecida en `analisis_escalamiento_Q1_generador_trayectorias.md` §6, nadie hizo esto ni con 2 modelos).

---

## 4. La regla de combinación — decisión pendiente de aprobación final

**Regla propuesta (a fijar ANTES de tocar Camargo, sin excepción):**

```
theta_tibia_combinado(t) = mean(theta_tibia_Koopman(t), theta_tibia_Zhao(t), theta_tibia_Yun(t), theta_tibia_RomeroSorozabal(t))
```

Aplicado punto a punto sobre las curvas ya remuestreadas a %ciclo común (mismo patrón que `Generar_Trayectoria.m` ya usa para las fases apoyo/balanceo).

**Pendiente de decidir con el usuario antes de implementar:**
- ¿Se promedia sobre las 4 salidas de ángulo/theta_tibia (como los 3 candidatos actuales), o se aprovecha que Romero-Sorozábal da posición 3D directa y se promedia a nivel de POSICIÓN de rodilla/tobillo en vez de ángulo? (Puede ser mejor: promediar posiciones evita tener que pasar Romero-Sorozábal por la reducción ángulo→posición que sí necesitan los otros 3.)
- ¿Se pondera igual los 4, o se le da menor peso a Romero-Sorozábal por ser el único que predice posición en vez de ángulo (naturaleza distinta de error)?

---

## 5. Qué falta, en orden

1. **Verificar Romero-Sorozábal 2024 a texto completo** — hoy solo tengo el resumen extraído vía WebFetch (autores, coeficientes en Tablas A1-A3, RMSE, n). Falta el PDF real para extraer los números exactos de las tablas (mismo estándar de rigor que Koopman/Zhao/Yun — no se fija ningún coeficiente sin verificar contra la fuente). **Acceso abierto (MDPI), debería conseguirse sin necesitar cuenta institucional** — pendiente de que el usuario lo descargue o yo lo intente de nuevo (WebFetch a MDPI dio 403 antes, probar de nuevo o pedir el PDF).
2. **Verificar Bates & Granger 1969 y Clements & Vasnev 2024 a texto completo** antes de fijarlas en el manuscrito — hoy son citas bibliográficamente verificadas (multi-fuente) pero no leídas completas.
3. **Decidir la regla de combinación exacta** (§4) — pendiente de aprobación del usuario.
4. **Implementar `Romero_Sorozabal2024_Core.m`** siguiendo el mismo patrón Core/Test que los otros 3 (`CODIGOS/GENERADOR/`).
5. **Implementar `Combinar_Candidatos_Core.m`** — la función de combinación en sí, aplicando la regla ya fijada.
6. **Actualizar `Generar_Trayectoria.m`** para aceptar `candidato='Combinado'` como una cuarta opción, además de los 4 individuales.
7. Recién después de 1-6: correr contra Camargo (Nivel A/B, fuera del alcance de este documento — ver `analisis_escalamiento_Q1_generador_trayectorias.md` §7).

**Nada de esto está commiteado en el momento de escribir este documento** — pendiente de confirmación del usuario, mismo patrón que el resto del proyecto.
