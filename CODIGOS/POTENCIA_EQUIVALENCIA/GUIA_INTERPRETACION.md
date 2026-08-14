# Guía de interpretación — Potencia a priori y TOST

**Para quién es este documento:** para leer el reporte de consola y las figuras de `PotenciaApriori_Core.m` y `TOST_Core.m` sin tener que recordar estadística de memoria, para saber qué decisiones metodológicas quedan tomadas de fábrica (y cuáles hay que ajustar con datos reales), y para tener listo el texto de respaldo para Métodos/Resultados. Construido el 13-ago-2026 a partir de los candidatos **A** (potencia a priori) y **B** (TOST) aprobados en `docs/DISCUSION_Q2.md` P-3.

---

## 1. Qué hace cada herramienta, en una frase

- **`PotenciaApriori_Core.m`** — responde *"¿cuántos sujetos hacen falta?"* simulando repetidamente la Comparación 4 (sujetos nuevos agrupados vs. trayectoria fija, diseño independiente, el mismo `SPM1D_Core.m` que ya se usa en `CODIGOS/MULTISUJETO/`) con una diferencia **conocida** impuesta, y midiendo qué fracción de las repeticiones la detecta.
- **`TOST_Core.m`** — responde una pregunta distinta y más fuerte que "¿hay diferencia?": *"¿la diferencia es lo bastante chica como para no importar?"*, declarando un margen de equivalencia **antes** de ver los datos.

Son complementarias: la potencia a priori dice si el N planeado alcanza para *detectar* una diferencia si existiera; TOST, ya con los datos, dice si se puede *afirmar* equivalencia en vez de solo "no hubo diferencia significativa" (que un revisor Q2 puede leer como falta de potencia, no como evidencia a favor).

---

## 2. La advertencia más importante de este documento — léela antes de citar cualquier número

`PotenciaApriori_Core.m` necesita un estimado de **cuánto varían entre sí sujetos distintos** para simular escenarios realistas. Hoy, el único dato de variabilidad que existe (`sd_plat_apoyo`, `sd_plat_balanceo`, `sd` de `BaseDatos_FuerzaVertical.mat`) es la variabilidad **ensayo-a-ensayo de un único sujeto** (el original) — no la variabilidad **entre** 15-50 personas distintas, que casi siempre es mayor.

**Consecuencia práctica:** los números de potencia que salen hoy son probablemente **optimistas** — sobrestiman la potencia real, o dicho al revés, subestiman el N que realmente va a hacer falta. Por eso `factor_intersujeto` (default 1.5) infla la SD ensayo-a-ensayo como una aproximación conservadora, pero **es un supuesto de trabajo, no un número de la literatura** — no se cita así en el manuscrito sin decirlo explícitamente.

**Qué hacer con esto:**
1. Usar los resultados de hoy para la planificación (cuántos sujetos reclutar, con el margen de 50 que confirmó el usuario en P-3), no como cifra final citable sin más.
2. **En cuanto existan ~5 sujetos nuevos reales**, recalcular `sd_trial` con la variabilidad observada entre esos 5 (no la del sujeto original) y volver a correr `PotenciaApriori_Core.m` — esa segunda corrida sí es la que se cita en Métodos con confianza.
3. Documentar ambos números si terminan siendo distintos: el a priori (con el supuesto declarado) y el recalculado (con datos reales), en vez de reemplazar uno por el otro en silencio.

---

## 3. Cómo leer el reporte de consola de `PotenciaApriori_Core.m`

```
Efecto = 5.00 deg: potencia 0.05 (N=5) -> 0.98 (N=50)
------------------------------------------------------------------
Efecto = 5.00 deg: N minimo estimado para 80% de potencia = 14.3
```

| Línea | Qué es | Cómo interpretarla |
|---|---|---|
| `Efecto = X: potencia A (N=n1) -> B (N=n2)` | Resumen rápido: potencia en el extremo chico y grande del grid de N, para ese tamaño de efecto | Si `A` ya es alto (p.ej. >0.7) con el N más chico, ese efecto es "fácil" de detectar — no hace falta reclutar tanto para verlo. Si `B` sigue bajo con el N más grande del grid, ese efecto es demasiado sutil para el N que se está considerando. |
| `N minimo estimado para 80% de potencia` | El N interpolado sobre el grid donde la potencia cruza el objetivo (default 80%) | Es una interpolación **lineal** entre los dos puntos del grid que rodean el cruce — no es exacta, es una estimación. Si sale `NaN`, ningún N del grid alcanzó el objetivo: hay que ampliar `Ns` o aceptar que ese efecto no es detectable con el N máximo disponible (hasta 50, confirmado en P-3). |
| Efecto = 0 (si se incluye en `.efectos`) | Es el chequeo de **tasa de falso positivo** | Con efecto=0 no hay ninguna diferencia real — la potencia reportada ahí debería acercarse a `alpha` (0.05), no a 0. Si sale muy por encima de 0.05, algo está mal calibrado en la simulación (revisar antes de confiar en el resto de los números). Es exactamente lo que valida el Test 1 de `Test_PotenciaApriori_TOST.m`. |

**Cómo elegir qué `efectos` simular:** no hay un valor "correcto" — depende de qué diferencia sería clínica o biomecánicamente relevante para este simulador. No se fija un umbral tomado de la literatura sin verificarlo primero (regla 1 de `DISCUSION_Q2.md` §2); mientras tanto, se recomienda simular un rango (p.ej. 1°, 2°, 3°, 5° para ángulos; equivalente en %BW para fuerza) y dejar que la tabla de resultados muestre el trade-off, en vez de comprometerse a un solo número sin respaldo.

**Costo computacional:** con los defaults de producción (`n_iter=200`, `n_perm=1000`) y un grid de 4 efectos × 7 tamaños de muestra, son 5600 corridas de `SPM1D_Core.m` — puede tardar varios minutos. Para explorar rápido, bajar `n_iter` y `n_perm` primero (como hace `Test_PotenciaApriori_TOST.m`, con `n_iter=60, n_perm=400`) y solo correr los defaults completos para el número que va a citarse en el manuscrito.

---

## 4. Cómo leer el reporte de consola de `TOST_Core.m`

```
TOST (Schuirmann) - pico_pareado | diseno pareado | margen = [-1.00, 1.00] deg
Diferencia media = 0.15 deg, IC90% = [-0.05, 0.35] deg
p_inferior = 0.0001 | p_superior = 0.0003 | p_TOST = 0.0003
-> EQUIVALENTE dentro del margen declarado (alpha=0.05)
```

| Línea | Qué es | Cómo interpretarla |
|---|---|---|
| `margen = [lo, hi]` | El margen de equivalencia declarado **a priori** | Es la decisión más importante de toda la prueba — ver sección 5 para cómo elegirlo. Cambiar el margen después de ver el resultado invalida la prueba (es "p-hacking" de equivalencia). |
| `Diferencia media`, `IC90%` | La diferencia observada y su intervalo de confianza | Nota: es **IC90%** para `alpha=0.05`, no IC95% — es una propiedad del procedimiento TOST (dos pruebas de una cola de nivel alpha cada una), no un error. Regla gráfica equivalente al resultado numérico: si el IC completo cae dentro de `[lo, hi]`, hay equivalencia. |
| `p_inferior`, `p_superior` | Los dos p-valores de una cola de Schuirmann | `p_TOST` es el **máximo** de los dos, no el mínimo — hay que pasar ambas pruebas, no una sola. |
| `EQUIVALENTE` / `NO equivalente` | La conclusión | "No equivalente" **no** significa "diferente" — solo significa que no se pudo demostrar que la diferencia esté dentro del margen declarado (puede ser que sí lo esté, pero falte potencia para probarlo — de ahí que el candidato A y el B se complementen). |
| `[AVISO] el criterio del IC... da una conclusion distinta` | Discrepancia entre el criterio de p-valor y el del IC | Solo debería pasar cuando `p_TOST` está muy cerca de `alpha` (borde de la decisión) — si aparece con un caso que no está en el borde, revisar los datos de entrada. |

---

## 5. Cómo elegir el margen de equivalencia — la decisión que sostiene todo lo demás

El margen **no** se elige después de ver los datos, y no hay un valor universal. Opciones razonables, de más a menos conservadora:

1. **Variabilidad ensayo-a-ensayo del sujeto original**, ya calculable hoy con `Extraer_Features0D.m` sobre `REFERENCIAS/*.mat` (si se recuperan los ensayos individuales) — el margen sería, por ejemplo, 1 SD de esa variabilidad: si el simulador difiere de la referencia menos de lo que el propio sujeto original varía de un ensayo a otro, la diferencia no es prácticamente relevante.
2. **Un umbral de la literatura de diferencia mínima detectable/clínicamente relevante** para el tipo de métrica (ángulo articular, pico de Fz) — **no fijar ninguno sin buscarlo y verificarlo contra la fuente primero** (misma regla que toda cita del proyecto).
3. **Un porcentaje del rango de movimiento (ROM) típico** de la curva en cuestión (p.ej. 10% del ROM) — más fácil de justificar de forma genérica, más débil como argumento clínico.

**Recomendación de trabajo:** usar la opción 1 como margen por defecto (ya hay datos para calcularla), y si en algún momento se identifica y verifica un umbral de literatura (opción 2), usarlo en su lugar o reportar ambos. **No se fija ninguno de estos en el manuscrito todavía** — es una decisión pendiente, no aplicada de oficio.

---

## 6. Validación con datos sintéticos

`Test_PotenciaApriori_TOST.m` (9 pruebas):
- **Parte A (potencia):** tasa de falso positivo con efecto=0 cerca de alpha; potencia alta con efecto grande y N grande; potencia no decreciente al aumentar N; `N_para_objetivo` finito cuando corresponde.
- **Parte B (TOST):** equivalencia detectada correctamente en casos pareados e independientes con diferencia real chica; NO-equivalencia detectada con diferencia real grande; caso límite SE=0 (datos idénticos) sin errores; consistencia entre el criterio de p-valor y el del IC.

Corre en minutos (parámetros reducidos respecto al default de producción — ver sección 3). **Sin correr todavía en MATLAB/Octave por el usuario** — igual que el resto de herramientas de este proyecto (`CODIGOS/CALIBRACION/`, `CODIGOS/ESTADISTICA/`, `CODIGOS/MULTISUJETO/`), queda construido y listo, pendiente de confirmación 7/7 (o el conteo que corresponda) antes de usarlo con datos reales.

---

## 7. Literatura de respaldo — verificar antes de citar

- **TOST / Schuirmann (1987), "A comparison of the two one-sided tests procedure and the power approach for assessing the equivalence of average bioavailability"** — es la referencia clásica del procedimiento. **No verificada todavía contra la fuente** (misma regla que toda cita nueva del proyecto, `DISCUSION_Q2.md` §2 regla 1) — buscar y confirmar antes de fijarla en `references.bib`.
- Literatura de **equivalencia aplicada a biomecánica/curvas de marcha** (más allá del TOST clásico de bioequivalencia farmacológica) — no identificada ni verificada todavía. Buscar antes de redactar Métodos 5.4 con esta sección.
- **Potencia por simulación para SPM no paramétrico** — no se identificó una referencia específica y verificada de "cómo hacer potencia a priori para SPM1D por permutación"; el diseño de `PotenciaApriori_Core.m` sigue la lógica general de potencia por simulación (imponer un efecto conocido, repetir, medir la tasa de detección), que es estándar en estadística pero no está anclado a una cita puntual todavía. Si se necesita una cita específica para Métodos, buscarla y verificarla antes de fijarla — no usar esta guía como fuente citable en el manuscrito.

**Ninguna de estas tres queda en `references.bib` todavía.** Esta sección es el recordatorio de qué falta verificar antes de escribir Métodos 5.4 con este contenido.
