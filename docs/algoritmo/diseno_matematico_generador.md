# Diseño matemático y de codificación — generador de trayectoria desde antropometría

**Creado:** 20-ago-2026, a pedido del usuario tras cerrar P-24 (`docs/DISCUSION_Q2.md`). **Rol de este documento:** almacenamiento técnico — reúne, candidato por candidato, exactamente qué se extrae de cada referencia (ecuaciones, entradas, salidas, código) para poder construir el pipeline. No es el lugar de discusión — decisiones y preguntas siguen yendo a `DISCUSION_Q2.md`.

**Regla que rige todo este documento (P-23, `DISCUSION_Q2.md` §4-sexies):** solo se usan coeficientes YA publicados por cada referencia. Ningún ajuste, reentrenamiento ni estimación nueva a partir de datos propios — eso reabriría circularidad y el requisito de LOSO/muestra grande.

---

## 1. El pipeline completo, de un vistazo

```
Antropometría del sujeto (talla, masa, long. muslo, long. pierna, cadencia, ...)
                    │
                    ▼
   [Candidato 1, 2 y/o 3 — corridos en paralelo, sin reentrenar]
                    │
                    ▼
      Ángulos articulares: cadera, rodilla (y tobillo si el candidato lo da)
                    │
                    ▼
   [REDUCCIÓN — ángulo relativo articular → ángulo absoluto de segmento]
        (Winter; ver §5-bis de analisis_escalamiento..., y §4 de este doc)
                    │
                    ▼
      Orientación absoluta del segmento tibial (convención atan2 del proyecto)
                    │
                    ▼
      COMPARAR contra Camargo et al. 2021 (P-24) — sujetos que no
      participaron en construir ningún candidato
```

---

## 2. Candidato — Koopman, van Asseldonk & van der Kooij 2014

**Estado: 🟢 Verificado a fondo, implementado y probado — texto completo leído (23-ago-2026, PDF subido por el usuario como `docs/literatura/pdfs/koomap.pdf`), código en `CODIGOS/GENERADOR/Koopman2014_Core.m`, 5/5 pruebas propias PASS (Test_Generador.m, Parte E).**

**Nota sobre fidelidad de extracción (23-ago-2026):** el extractor de texto estándar del PDF perdía los signos negativos de las Tablas 1-5 (el glifo del signo menos del tipografiado del paper no se mapea a un carácter Unicode estándar). Se resolvió con `pdfplumber` (Python), que expone el glifo problemático como `(cid:2)` — inequívoco y verificable: cualquier número precedido por `(cid:2)` sin espacio es negativo. Con esto se transcribieron las 5 tablas completas con alta confianza. **Una sola celda quedó ambigua** (Tabla 4, fila "Min. stance", coeficiente β3 del parámetro Index — en blanco en dos extracciones independientes) — tratada como sin contribución (0), documentada así en el código. **Validación externa de la transcripción:** el ROM reconstruido a velocidad/talla promedio del paper (3 kph, 1.69 m) da 10.4°/36.7°/56.4°/18.4° para cadera ab-ad/cadera flex-ext/rodilla/tobillo — cerca de los ROM publicados en la Tabla 6 del propio paper (9.94°/34.22°/52.76°/20.04°), buena señal de que la transcripción es correcta.

- DOI: `10.1016/j.jbiomech.2014.01.037`
- Sujetos de origen: 15 sanos de mediana edad (47-68 años), 7 rango de velocidades en cinta (0.5-5 kph).

### 2.1 Qué modelo es

**Distinto en estructura a Zhao y Yun.** No es una serie cerrada (Zhao) ni GPR (Yun) — es un **spline quíntico por tramos** ajustado entre **6 "eventos clave"** de cada trayectoria articular (el inicio del ciclo — contacto de talón — más 5 extremos de posición/velocidad, ver Fig. 2 del paper). Cada evento clave se parametriza con 4 valores: `x` (timing, % ciclo), `y` (ángulo, °), `dy/dx` (velocidad angular) y `d²y/dx²` (aceleración angular) — y cada uno de esos 4 valores se predice con su propio modelo de regresión.

### 2.2 Fórmula de regresión — Ec. 2 del paper

```
Y = β0 + β1·v + β2·v² + β3·l
```

Donde **v = velocidad de marcha (kph)** y **l = talla corporal (m)** — ⚠️ **atención al choque de notación: la "l" de Koopman es TALLA, no longitud de pierna como la "l" de Zhao 2026** (§4 de este documento). No mezclar estas dos variables al construir el pipeline combinado — usar nombres de campo distintos en el código (`talla_m` vs. `longitud_pierna_m`).

### 2.3 Articulaciones y coeficientes — Tablas 1-4, ya publicadas

Cadera ab-/aducción (Tabla 1), cadera flexión/extensión (Tabla 2), rodilla flexión/extensión (Tabla 3), tobillo plantar-/dorsiflexión (Tabla 4) — cada una con 6 eventos clave × 4 parámetros × hasta 4 coeficientes (β0, β1-velocidad, β2-velocidad², β3-talla). **Las 4 tablas completas están en el PDF local** (`docs/literatura/pdfs/koomap.pdf`, páginas 6-8) — no se transcriben aquí íntegras por ahora (más de 300 números) para evitar error de trascripción sin doble verificación; se transcriben directo al código (`Koopman2014_Core.m`, pendiente de escribir) leyendo del PDF en el momento de programar, con una prueba sintética que confirme cada coeficiente contra al menos un punto del paper antes de confiar en la tabla completa.

### 2.4 Convención de signos — dato nuevo, no estaba en Zhao/Yun

El paper lo declara explícito (pie de Fig. 1): **"(dorsi-) flexion and abduction are defined positive"** — es decir, positivo = dorsiflexión de tobillo y abducción de cadera, convención clínica clásica (compatible con Conventional Gait Model / Plug-in-Gait). **No confirma explícitamente el signo de flexión de cadera/rodilla en esa misma frase** — inferible por continuidad de la convención clínica (positivo = flexión), pero no citado literalmente así en el texto disponible; no asumir sin re-chequear contra las Tablas 2-3 si el signo importa para la reducción.

### 2.5 Sin ecuación de reducción propia — necesita Winter (§5)

A diferencia de Zhao, Koopman **no da una relación explícita ángulo absoluto↔relativo** — solo ángulos articulares relativos (cadera, rodilla, tobillo). Aplica la reducción general del §5 igual que Yun 2014, con la ventaja de que si se usa el camino "vía cadera+rodilla", Koopman sí tiene un valor de cadera **flexión/extensión** explícito (Tabla 2) — a diferencia de Yun, donde ese canal ("Hip Extension") tiene el signo sin verificar (§3.3).

### 2.6 Tiempo real de ciclo — Ec. 3 y Tabla 5

Como el spline se calcula en % de ciclo (0-100%), hace falta la duración real del ciclo para generar un CSV en segundos:

```
tiempo_ciclo = 2·sqrt(step_ratio / (v/3.6))     (v en kph)
```

con `step_ratio` predicho con la misma fórmula de regresión de la Tabla 5 (β0=−0.532, β1(v)=0.020, β3(talla)=0.47, RMSE=0.073) — también coeficientes ya publicados.

### 2.7 Rango válido y limitación declarada por los propios autores

Válido para **0.5-5 kph** (0.14-1.39 m/s) — más lento que el rango de Yun/Zhao en promedio. Los autores señalan textualmente que la talla corporal "had less effect" que la velocidad — 7 de 24 eventos-clave de ángulo dependen de talla, 19 de velocidad — coherente con el mismo hallazgo ya anotado para Yun 2014 en `analisis_escalamiento_Q1_generador_trayectorias.md` §4.5 (ningún candidato reporta una "importancia de parámetros" fuerte más allá de velocidad).

### 2.8 Qué falta para tener `Koopman2014_Core.m`

Transcribir las Tablas 1-5 al código (con verificación cruzada punto a punto contra al menos un ejemplo del paper, ver Fig. 3), programar el ajuste de spline quíntico por tramos con continuidad C² entre 6 eventos (Ec. en §2.3.4/Fig. 4 del paper) — una tarea de implementación mayor que Zhao (serie cerrada) o Yun (llamar un toolbox ya hecho). Pendiente, no hecho todavía en esta sesión (23-ago-2026).

---

## 3. Candidato — Yun, Kim, Shin, Lee, Deshpande & Kim 2014 (toolbox GPR)

**Estado: 🟢 Verificado a fondo — texto completo + código fuente revisados (20-ago-2026).**

### 3.1 Qué modelo es

Gaussian Process Regression (GPR). No hay una fórmula cerrada simple como Koopman/Zhao — es un modelo no paramétrico: la predicción para un sujeto nuevo se calcula por comparación (distancia euclidiana ponderada) contra los 108 sujetos de entrenamiento, usando una función de covarianza ya ajustada (hiperparámetros ya publicados, uno por cada uno de los 14 movimientos articulares + 1 para el período).

### 3.2 Entrada — vector de 14 parámetros

`[Edad, Talla(cm), Masa(kg), Sexo(0:f 1:m), Long.Muslo(mm), Long.Pantorrilla(mm), Ancho Bi-trocantéreo(mm), Ancho Bi-ilíaco(mm), ASIS(mm), Diámetro Rodilla(mm), Long.Pie(mm), Altura Maléolo(mm), Ancho Maléolo(mm), Ancho Pie(mm)]`

### 3.3 Salida — 15 elementos, con incertidumbre

Cada uno de los 14 movimientos articulares (más el período) devuelve `.mean` (trayectoria, tiempo normalizado 0–1) y `.std` (desviación estándar — banda de confianza). Los que importan para la reducción:

- **`R. Knee Flexion`, `L. Knee Flexion`** — ángulo relativo de rodilla.
- **`R. Ankle P.flex.`, `L. Ankle P.flex.`** — ángulo relativo de tobillo (plantarflexión).

**Diferencia importante con Zhao (§4):** Yun da rodilla **y** tobillo como ángulos relativos clásicos, pero **no da directamente el ángulo absoluto del segmento tibial** — hay que aplicar la reducción general del §5 con ambos (rodilla + tobillo), no un atajo de una sola ecuación como en Zhao.

**Corrección 23-ago-2026 (`CODIGOS/GENERADOR/GUIA_INTERPRETACION.md` §3):** al revisar `Gait_Pred.m` línea por línea, el toolbox **sí predice cadera sagital** — canales 6 y 11 de los 14 movimientos son `R./L. Hip Extension`, no solo rodilla+tobillo como se anotó aquí antes. No se usa todavía para el camino "vía rodilla" porque su signo/convención no está verificado contra el de Zhao 2026 (§4 abajo) — pendiente leer la definición exacta en el texto de Yun 2014. El camino vía tobillo sí está implementado y habilitado.

### 3.4 Interfaz de código, ya lista para llamar

```matlab
Gait_Kinematics = Gait_Pred(test_body_parameter, 'database', 'hyp')
```

- Usa los hiperparámetros ya optimizados en `./hyp/hyp_op1.mat` … `hyp_op14.mat` — **nunca llamar `Gait_Model.m`**, esa función reentrena y rompe P-23.
- Corre en Matlab y Octave. Copia local: `docs/literatura/pdfs/yun2014_toolbox/` (código en el repo; `database/Data_x.mat`/`Data_y.mat` NO están en git por licencia — ver `docs/configuracion/setup_nueva_laptop.md` §5 para conseguirlos).

---

## 4. Candidato — Zhao, Wei, Xie, Liu, Qu, Cao, Ding & Liao 2026

**Estado: 🟢 Verificado a fondo — texto completo leído (20-ago-2026). Corrige dos cosas que se habían anotado mal antes.**

> ⚠️ **Correcciones sobre lo que se había dicho antes de leer el texto completo:**
> 1. **El repositorio de GitHub es `zhaoxiaohuan13`, no `zhaohuan13`** — confirmado en la sección "Data availability statement" del paper: https://github.com/zhaoxiaohuan13/predictive-model-of-joint-dynamics-and-ground-reaction-force
> 2. **Zhao NO predice el ángulo de tobillo.** El modelo cinemático (Fourier) solo da **cadera y rodilla** — el pie se trata como una vara rígida fija al suelo durante el apoyo ("ignores the function of the foot"), sin grado de libertad de tobillo en la cinemática. Sí calcula el **momento** de tobillo (dinámica), pero no su ángulo. Esto es distinto de lo que se había anotado en sesiones anteriores.

### 4.1 Modelo cinemático — Ecs. 1-2, y por qué esto reemplaza directo la "reducción" del §5

Ángulo de cadera o rodilla (izquierda), en radianes:

```
φ_L(t) = B₀·l + Σ_{j=1}^{n} B_j·l·sin(2πjft + φ_j)
```

Derecha (con desfase de π por armónico):

```
φ_R(t) = B₀·l + Σ_{j=1}^{n} B_j·l·sin(2πjft + φ_j + jπ)
```

Donde:
- **l** = longitud de pierna (m), medida ASIS→maléolo medial.
- **f** = cadencia (zancadas/segundo); el período T = 1/f.
- **B_j, φ_j** = coeficientes empíricos **ya publicados** (Tabla 1 del paper, reproducida abajo) — n=3 armónicos para cadera/rodilla.
- **t** = tiempo.

**Coeficientes publicados (Tabla 1, ya verificados a texto completo — usar tal cual, sin reajustar):**

| Parámetro | B₀ | B₁ | B₂ | B₃ | φ₁ | φ₂ | φ₃ |
|---|---|---|---|---|---|---|---|
| Cadera | 0.086 | −0.316 | −0.067 | 0.026 | −1.105 | 1.433 | 0.187 |
| Rodilla | 0.468 | 0.465 | 0.311 | −0.093 | 0.244 | −0.990 | 0.266 |

**El hallazgo clave, 20-ago-2026 — el paper YA da la ecuación de reducción que el proyecto necesitaba derivar en el §5:**

En la sección 2.6 (antes de la Ec. 11), el propio paper establece la relación entre ángulos absolutos (respecto al eje vertical del mundo, θ) y ángulos articulares relativos (φ), asumiendo que la pelvis se mantiene a 0° en el plano sagital durante la marcha (supuesto explícito del paper):

```
θ_cadera = φ_cadera                      (el muslo es directamente el ángulo de cadera, porque la pelvis = 0°)
θ_rodilla = θ_cadera − φ_rodilla          (el ángulo ABSOLUTO de la pierna/tibia = ángulo de cadera − ángulo relativo de rodilla)
```

**`θ_rodilla` en esta notación ES el ángulo absoluto del segmento tibial respecto a la vertical — exactamente lo que el simulador necesita (convención `atan2` del proyecto, con la vertical/horizontal intercambiada según el eje de referencia que se use).** No hace falta aplicar por separado la relación general de Winter (§5 de `analisis_escalamiento...md`) para este candidato — Zhao ya la trae aplicada, con nombre de variable y todo. Es matemáticamente la misma relación (ángulo relativo↔absoluto), solo que Zhao la escribe explícita para este caso concreto.

**Consecuencia práctica:** para Zhao, la "reducción" completa es:

```
θ_tibial(t) = φ_cadera(t) − φ_rodilla(t)
```

con φ_cadera y φ_rodilla calculados directo de las Ecs. 1-2 y la Tabla 1 — **una sola resta, cero cinemática adicional que derivar.**

### 4.2 Modelo dinámico (GRF y momentos) — Ecs. 3-16

Resumen, sin repetir cada ecuación (están completas y verificadas en el PDF local, `docs/literatura/pdfs/` — agregar si se decide usar la parte de fuerza):

- **Posición/velocidad de segmentos** (Ecs. 3-4): cinemática directa estándar de cadena de eslabones rígidos, usando los θ derivados de §4.1.
- **GRF en apoyo simple** (Ecs. 5-6) y **apoyo doble** (Ecs. 7-10): Newton, con masas de muslo/pierna/tronco tomadas de la norma china **GB/T 17245-2004** (coeficientes de masa relativa estándar — análogo a de Leva 1996, pero de otra fuente; **si el equipo usa Zhao, hay que decidir si adopta GB/T o sustituye por de Leva 1996** para no mezclar dos estándares antropométricos distintos sin razón).
- **Momentos articulares** (Ecs. 11-16): método de Lagrange, L = energía cinética − potencial.
- **Validación:** SPM1D (mismo motor que `CODIGOS/ESTADISTICA/SPM1D_Core.m`), RMSE, rRMSE, Pearson r — mismas métricas que el proyecto ya usa.

**Resultados de precisión reportados por los propios autores (4 sujetos de prueba, separados de los 10 usados para los coeficientes):** ángulos cadera/rodilla rRMSE 7.4–9.8%, r=0.97–0.99. Momentos rRMSE 13–21%, r=0.84–0.93. GRF rRMSE 10–12%, r=0.92–0.94.

### 4.3 Código

Repositorio confirmado (§ arriba, URL corregida): https://github.com/zhaoxiaohuan13/predictive-model-of-joint-dynamics-and-ground-reaction-force — contiene datos originales de los 14 sujetos (comprimidos en `.rar`, por sujeto) y código. **Pendiente:** clonar/descargar y confirmar qué lenguaje y qué interfaz expone (no revisado todavía, a diferencia de Yun 2014 que ya se descargó y probó).

---

## 5. La reducción general (Winter) — para Koopman y Yun, que no la traen como Zhao

Cuando el candidato no da la relación absoluto/relativo explícita (Koopman, Yun), aplica el método general ya documentado en `analisis_escalamiento_Q1_generador_trayectorias.md` §5-bis:

```
θ_segmento(t) = θ_referencia(t) ± φ_articular_1(t) ± φ_articular_2(t) ± ...
```

sumando/restando ángulos relativos articulares desde una referencia (pie o pelvis) a lo largo de la cadena cinemática, con signo según convención de flexión/extensión de cada dataset. Para el segmento tibial específicamente, con rodilla y tobillo como las dos referencias articulares (como pidió el usuario, ver `DISCUSION_Q2.md` §4-quinquies, aclaración técnica): `θ_tibia = θ_pie ± φ_tobillo` o, equivalente, `θ_tibia = θ_muslo ∓ φ_rodilla` (la misma cantidad, dos caminos de cálculo — sirve como chequeo cruzado si se tienen ambos ángulos, como en el caso de Yun).

**Con Yun 2014**, que da rodilla y tobillo, hay dos caminos independientes de calcular θ_tibia — una oportunidad de validación cruzada interna gratis (si ambos caminos coinciden, refuerza confianza en la reducción antes de comparar contra Camargo).

---

## 6. Qué falta — plan de trabajo restante

| # | Tarea | Bloqueado por |
|---|---|---|
| 1 | Leer Koopman 2014 a texto completo | 🟢 **Hecho 23-ago-2026** — ver §2 |
| 2 | Descargar y revisar el código de Zhao 2026 (GitHub) | Todavía no hecho — nada lo bloquea, no se priorizó frente a Koopman |
| 3 | Decidir: ¿GB/T 17245-2004 (Zhao) o de Leva 1996 (§5-bis) para masas/segmentos, si se usa la parte de fuerza de Zhao? | Decisión de equipo, no de investigación |
| 4 | Confirmar con Mecatrónica/CAD si la reducción es exactamente 3-DOF o hay acoplamientos (`analisis_escalamiento...md` §5, "comprobación pendiente") | Equipo, no literatura |
| 5 | Escribir el código del pipeline (`CODIGOS/GENERADOR/`, patrón Core/Test/Guía del resto de `CODIGOS/`) | 🟢 **Hecho 23-ago-2026 para los tres candidatos** — `Zhao2026_Core.m`, `Yun2014_Wrapper.m`, `Koopman2014_Core.m`, `Reduccion_Winter_Core.m`, `Cargar_Camargo_Core.m`, `Test_Generador.m` (16/16 PASS, corridas en MATLAB real). Decisión explícita del usuario: **sin datos propios del proyecto** (`PERSONA SANA/`/`REFERENCIAS/`) en esta línea — el algoritmo se construye 100% desde literatura, validado después contra Camargo 2021 |
| 6 | Correr Nivel A/B de validación real contra Camargo (`Cargar_Camargo_Core.m` ya listo, faltan más sujetos que AB06/AB09 y la longitud de muslo para Yun) | Nada bloquea empezar con AB06/AB09 para rodilla+tobillo; Yun completo necesita longitud de muslo (ver `GUIA_INTERPRETACION.md` §5) |

**Nada de esto está bloqueado por falta de más búsqueda bibliográfica — los tres candidatos y la reducción ya están (o casi están) matemáticamente completos.** El siguiente paso es técnico y de equipo, no de investigación.

**Búsqueda 23-ago-2026 — acceso a Camargo 2021 confirmado.** Dataset público descargable (Dropbox, ~1GB/sujeto, vía https://www.epic.gatech.edu/opensource-biomechanics-camargo-et-al/), estructura por sujeto con `SubjectInfo.mat` (antropometría) + `STRIDES/` (ensayos, incluye ángulos sagitales de cadera/rodilla/tobillo por goniómetro). Suficiente para los niveles A y B de validación (§7.1 de `analisis_escalamiento_Q1_generador_trayectorias.md`). Detalle completo, incluido qué falta confirmar (si trae longitud de segmento o solo talla/masa/edad): `CODIGOS/GENERADOR/GUIA_INTERPRETACION.md` §5. Siguiente acción concreta: descargar 1-2 sujetos piloto y escribir `Cargar_Camargo_Core.m` — no hecho todavía, requiere bajar varios GB primero.
