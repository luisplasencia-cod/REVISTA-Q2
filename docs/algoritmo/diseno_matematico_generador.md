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

**Estado: 🔴 PENDIENTE — texto completo no leído todavía.** Solo se verificó DOI, autores, cita y adopción (`analisis_escalamiento_Q1_generador_trayectorias.md` §4.1/§4.5) — no las ecuaciones. **No se completa esta sección con supuestos** (regla 3 del proyecto). Necesita el mismo camino que ya funcionó con Yun 2014 y Zhao 2026: acceso PUCP a ScienceDirect.

- DOI: `10.1016/j.jbiomech.2014.01.037`
- ScienceDirect: https://www.sciencedirect.com/science/article/abs/pii/S0021929014000682

Lo único que se sabe hoy (del abstract/metadatos, no verificado a fondo): splines quínticos ajustados entre eventos clave del ciclo de marcha, entrada velocidad + talla, salida ángulos articulares, diseñado explícitamente para soporte robótico de marcha.

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
| 1 | Leer Koopman 2014 a texto completo | Acceso PUCP del usuario (mismo patrón que Yun/Zhao) |
| 2 | Descargar y revisar el código de Zhao 2026 (GitHub) | Nada — se puede hacer ya |
| 3 | Decidir: ¿GB/T 17245-2004 (Zhao) o de Leva 1996 (§5-bis) para masas/segmentos, si se usa la parte de fuerza de Zhao? | Decisión de equipo, no de investigación |
| 4 | Confirmar con Mecatrónica/CAD si la reducción es exactamente 3-DOF o hay acoplamientos (`analisis_escalamiento...md` §5, "comprobación pendiente") | Equipo, no literatura |
| 5 | Escribir el código del pipeline (`CODIGOS/GENERADOR/` — nombre tentativo, sigue el patrón Core/Test/Guía del resto de `CODIGOS/`) | Tareas 1-4, al menos parcialmente |

**Nada de esto está bloqueado por falta de más búsqueda bibliográfica — los tres candidatos y la reducción ya están (o casi están) matemáticamente completos.** El siguiente paso es técnico y de equipo, no de investigación.
