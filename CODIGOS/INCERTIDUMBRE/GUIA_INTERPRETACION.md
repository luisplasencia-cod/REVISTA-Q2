# Guía de interpretación — Presupuesto de incertidumbre (GUM/ISO 5725)

> 🟢 **Herramienta reutilizable tras el pivote (19-ago-2026) — ver `docs/codigos/INDICE_CODIGOS.md`.** Sigue siendo válida en general; los componentes de incertidumbre concretos (instrumento, calibración) que asumía dependían del flujo de captura con iSen, ahora sin plan vigente — revisar cuando se defina qué se mide físicamente bajo el nuevo enfoque.



**Para quién es este documento:** para leer el reporte de consola de `PresupuestoIncertidumbre_Core.m` sin tener que recordar la metodología GUM de memoria, para saber qué se le puede pedir a esta herramienta y qué no, y para tener listo el texto de respaldo para Métodos/Discusión. Construido el 16-ago-2026 a partir del **candidato E** (`docs/ESTADO_Y_RUMBO.md` §6), aprobado en `docs/DISCUSION_Q2.md` **P-19** ("no depende de nada, avanzar todo lo posible mientras los datos reales demoran").

---

## 1. Qué hace esta herramienta, en una frase

Responde una pregunta distinta a la que ya responden RMSEnorm/ICC/SPM1D (5.4 del manuscrito): no *"¿el simulador reproduce la curva de referencia?"*, sino **de dónde viene la incertidumbre de una medición individual, y cuánto aporta cada fuente** — instrumento, calibración, repetibilidad — a la incertidumbre total. Es el marco de *trueness/precision* de ISO 5725 (ya citado en 5.4 como `ISO5725`) llevado a un número explícito, siguiendo el método de propagación de incertidumbre de la **GUM** (*Guide to the Expression of Uncertainty in Measurement*, JCGM 100:2008).

**Por qué importa para este artículo en particular:** el argumento central promete fuentes de error *cuantificadas, no solo narradas*. Hoy la corrección de Fz ya cumple eso (offset + fidelidad de seguimiento, con el término inercial inferido — ver P-5). Esta herramienta hace lo mismo para el **lado cinemático** (ángulo de plataforma): en vez de decir "el ángulo tiene algo de error de instrumento y algo de error de calibración", produce una tabla con el número exacto de cada uno y el total combinado — un presupuesto de incertidumbre formal es algo que casi ningún artículo de bancos de prueba de marcha reporta, y es coherente con lo que ya se hizo con los candidatos A y B (convertir una limitación narrada en un número declarado a priori).

---

## 2. Qué necesita de entrada — y de dónde sale cada número en este proyecto

Cada "componente" de incertidumbre es un `struct` con `nombre`, `tipo` (`'A'` o `'B'`, ver sección 3), `valor` (la incertidumbre estándar, no expandida) y `gl` (grados de libertad de esa estimación). Los candidatos naturales para el ángulo de plataforma de este proyecto:

| Componente | Tipo GUM | De dónde sale hoy | De dónde debería salir con datos reales |
|---|---|---|---|
| **Validación del instrumento (iSen vs. óptico)** | B | RMSD de Piche et al. 2022 (`Piche2022iSenValidity`, ya verificada a texto completo) — rodilla 3.3°, tobillo 5.6°, cadera 7.3° | Igual — es literatura externa, no cambia con los datos de este proyecto. **Decisión pendiente:** qué articulación de las tres es la analogía correcta para "ángulo de plataforma/inclinación tibial" — no se asume de oficio, ver sección 6 |
| **Residuo de calibración de offset vertical** | A | Placeholder sintético en `Test_PresupuestoIncertidumbre.m` | La SD de los residuos de `Calibracion_Offset_Core.m` una vez que existan datos reales — **bloqueado por la integración RPi-ESP32**, igual que la propia calibración (P-5) |
| **Repetibilidad ensayo-a-ensayo** | A | Placeholder sintético | La misma `sd_trial` que ya usa `PotenciaApriori_Core.m`/`TOST_Core.m` — hoy es la variabilidad de un solo sujeto (mismo caveat de esos dos scripts: recalcular con datos reales en cuanto existan ~5 sujetos) |
| **Resolución/muestreo** (opcional) | B | No incluido en el ejemplo — normalmente despreciable frente a los tres anteriores, pero se puede agregar como `valor = resolucion/sqrt(3)` (distribución rectangular, JCGM 100:2008 4.3.7) si se quiere ser exhaustivo | Igual |

**El diseño es deliberadamente genérico** (no hardcodea ningún número del proyecto dentro de `PresupuestoIncertidumbre_Core.m`) para que sirva tanto para el ángulo de plataforma como, más adelante, para Fz si se quiere el mismo tratamiento — se le pasan los componentes que correspondan cada vez.

---

## 3. Tipo A vs. Tipo B — no es "mejor/peor", es "cómo se estimó"

Viene directo de GUM sección 4, y es una distinción metodológica, no de calidad:

- **Tipo A:** se estimó por análisis estadístico de una serie de observaciones propias (una SD, un error estándar). Tiene grados de libertad reales (`n-1` típicamente).
- **Tipo B:** se estimó por cualquier otro medio — literatura, especificación de fabricante, juicio científico documentado. Puede tener `gl = Inf` (si se asume conocida con certeza, p.ej. una especificación) o un `gl` finito si la fuente misma reporta su tamaño de muestra (como Piche 2022, con 22 sujetos).

**Las dos se combinan exactamente igual** — la ley de propagación de incertidumbre (sección 4) no distingue el tipo al calcular `u_c`. La distinción solo importa para decidir el `gl` de cada componente, que sí afecta el resultado final (sección 5).

---

## 4. Cómo leer el reporte de consola

```
------------------------------------------------------------------
Presupuesto de incertidumbre (GUM/ISO 5725) - Angulo de plataforma
------------------------------------------------------------------
  [B] Validacion iSen vs. optoelectronico (rodilla)  u =    3.300 deg  ( 94.4% de u_c^2, gl=21.0)
  [A] Residuo de calibracion de offset vertical       u =    0.800 deg  (  5.5% de u_c^2, gl=7.0)
  [A] Repetibilidad ensayo-a-ensayo                   u =    0.500 deg  (  2.1% de u_c^2, gl=9.0)
------------------------------------------------------------------
u_c (combinada)      = 3.436 deg
gl efectivos (W-S)   = 24.7
k (nivel 95%)         = 2.064
U (expandida, 95%)   = 7.093 deg
------------------------------------------------------------------
```

| Línea | Qué es | Cómo interpretarla |
|---|---|---|
| `[A]`/`[B]` por componente, con `%% de u_c^2` | La contribución de cada fuente a la varianza combinada | **El diagnóstico más útil de todo el reporte.** Si un componente domina (como el instrumento en el ejemplo, ~94%), mejorar los otros dos casi no cambia el resultado — dice dónde vale la pena invertir esfuerzo de mejora, y también qué citar como "la fuente principal de incertidumbre" en Discusión |
| `u_c` | Incertidumbre estándar combinada — raíz de la suma de cuadrados (RSS) de todos los componentes, asumiendo independencia | Es la incertidumbre "de una sigma" — no es directamente lo que se reporta como intervalo, para eso está `U` |
| `gl efectivos (W-S)` | Grados de libertad efectivos combinados, fórmula de Welch-Satterthwaite | Si tiende al `gl` del componente dominante, es esperado (una sola fuente domina la incertidumbre y también domina cuánta confianza se tiene en ella) |
| `k` | Factor de cobertura — cuantil de la t de Student al nivel de confianza pedido, con `gl_eff` grados de libertad | **No se asume `k=2` de memoria.** Con `gl_eff` grande (>~30), `k` converge a 1.96 (95%) — la aproximación común "k=2" solo es válida ahí. Con `gl_eff` chico (pocas muestras Tipo A dominando), `k` sale más grande, reflejando correctamente que hay menos confianza en el número |
| `U` | Incertidumbre expandida — `k · u_c`, el número que se reporta como "el valor medido ± U" con el nivel de confianza declarado (típicamente 95%) | Es el número final para una tabla de Métodos/Resultados: *"ángulo de plataforma, incertidumbre expandida U₉₅ = X°"* |

---

## 5. Grados de libertad — por qué importan y no se pueden ignorar

Es la parte del método que más se suele saltar en la práctica, y por eso está implementada explícitamente en vez de asumir `k=2` siempre:

- Si **todos** los componentes tienen `gl=Inf` (todo Tipo B "conocido con certeza"), `gl_eff=Inf` y `k` es el cuantil normal exacto (1.95996 para 95%, no el redondeo a 2).
- Si **algún** componente tiene `gl` finito (típicamente los Tipo A, estimados de una muestra chica), `gl_eff` baja y `k` sube — la incertidumbre expandida se ensancha para reflejar que hay menos certeza en la propia estimación de incertidumbre. Con `n=6` repeticiones (`gl=5`), por ejemplo, `k≈2.57` en vez de `1.96` — casi 30% más ancho.

**Consecuencia práctica para este proyecto:** con solo 1 sujeto de referencia y pocos ensayos hoy, cualquier componente Tipo A calculado ahora va a tener `gl` chico y por lo tanto inflar `k` — otra razón más (junto con la de `PotenciaApriori_Core.m`/`TOST_Core.m`) para no citar el número de hoy como final, y recalcular en cuanto haya ~5 sujetos reales con más repeticiones.

---

## 6. Decisión pendiente antes de usar esto con datos reales

**¿Qué articulación de Piche 2022 (rodilla 3.3°, tobillo 5.6°, cadera 7.3°) es la analogía correcta para el "ángulo de plataforma/inclinación tibial" del simulador?** No es una decisión que se tome de oficio — el simulador no mide un ángulo articular en el sentido clínico (relación entre dos segmentos), mide la inclinación de una plataforma sobre la horizontal (convención atan2 del proyecto), que es geométricamente más parecida a un ángulo de segmento (shank/tibia) que a un ángulo articular. Ninguna de las tres cifras de Piche 2022 es una "articulación tibial" exacta — se necesita una decisión metodológica documentada en Métodos (p.ej. "se usa la cifra de tobillo por ser la más próxima anatómicamente al eje medido", con la limitación explícita de que no es una validación directa de ese ángulo específico), no una elección silenciosa. **No aplicado a ningún archivo de almacenamiento todavía** — queda para cuando se redacte la tabla real de Métodos/Resultados.

---

## 7. Validación con datos sintéticos

`Test_PresupuestoIncertidumbre.m` (7 pruebas):
- **Test 1:** dos componentes iguales con `gl=Inf` recuperan `u_c = valor·√2` exacto y `k` = cuantil normal exacto (1.959964, no la aproximación 2).
- **Test 2:** un solo componente reproduce `u_c` y `U` exactos (caso trivial, sin combinación).
- **Test 3:** un componente dominante con `gl` chico hace que `gl_eff` tienda a su propio `gl` (propiedad conocida de Welch-Satterthwaite).
- **Test 4:** `contribucion_pct` suma 100% y ordena correctamente el componente dominante.
- **Test 5:** con `gl` chico (muestra pequeña), `k > 1.96` — la incertidumbre expandida es correctamente más conservadora, no se subestima.
- **Test 6:** un componente sin el campo `gl` produce un error explícito y controlado, no un fallo silencioso.
- **Test 7:** caso de uso real del proyecto (RMSD de Piche 2022 + residuo de offset sintético + repetibilidad sintética) da un `u_c` que coincide con el cálculo manual y confirma que el instrumento domina la incertidumbre total — consistente con lo esperado (P-2/T-1 ya reconocen que la instrumentación no es el flanco débil del proyecto).

**Sin correr todavía en MATLAB/Octave por el usuario** — igual que el resto de herramientas de este proyecto, queda construido y listo, pendiente de confirmación 7/7 antes de usarlo con datos reales.

---

## 8. Literatura de respaldo — verificar antes de citar

- **JCGM 100:2008, "Evaluation of measurement data — Guide to the expression of uncertainty in measurement" (GUM)** — documento base de todo el método (ley de propagación de incertidumbre, clasificación Tipo A/B, fórmula de Welch-Satterthwaite). Es un documento técnico conjunto (BIPM/IEC/IFCC/ILAC/ISO/IUPAC/IUPAP/OIML), de acceso público en bipm.org — **no verificado todavía contra el PDF original** (misma regla que toda cita nueva, `DISCUSION_Q2.md` §2 regla 1); antes de fijarlo en `references.bib` confirmar el título/año exactos de la edición vigente (existe una versión 1995 y una reedición 2008 con correcciones menores — mismo tipo de cuidado que ya hizo falta con ISO 5725, ver P-14).
- **ISO 5725** — ya citado y verificado en el proyecto (`ISO5725`, edición 2023 tras P-14). Este presupuesto de incertidumbre es una extensión natural de ese marco de trueness/precision, no una cita nueva independiente.
- **Piche et al. 2022** — ya citado y verificado a texto completo (`Piche2022iSenValidity`). Es la fuente del componente Tipo B de mayor peso en el ejemplo de uso real.

**Ninguna cita nueva queda en `references.bib` todavía.** Esta sección es el recordatorio de qué falta verificar antes de escribir con este contenido en el manuscrito.
