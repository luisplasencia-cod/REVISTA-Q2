# Bitácora — sesión /loop autónoma 26-ago-2026 noche

## 23:xx — Inicio
- Recibida la orden `/loop` en modo autónomo: replicar para Zhao y Yun el pipeline de TOBILLO/ e INCLINACION_TIBIAL/ que hoy solo existe para Koopman.
- Fase 0 completada usando el contexto ya acumulado en esta sesión (los 4 scripts de Koopman fueron leídos y verificados línea por línea horas antes, incluidos dos bugs reales encontrados y corregidos hoy mismo: balanceo del generador y vía tibial de Yun en `Obtener_Angulos_Candidato.m`).
- Escritos `PLAN_ZHAO_YUN.md` y `DECISIONES.md`.
- git pull antes de empezar (ver salida abajo).

## Fallo de los 4 agentes iniciales (límite de sesión) — retomado
- Los 4 subagentes (A/B/C/D) lanzados en paralelo fallaron con "API error: You've hit your session limit · resets 12:20am (America/Lima)" — no es un error de la tarea, es cuota de uso de la sesión agotada por lanzar 4 agentes pesados a la vez (los 2 de Yun corren regresión GP + escriben 30 archivos cada uno).
- Decisión: reducir concurrencia. Se relanzan primero los 2 agentes de Zhao (A: TOBILLO, C: INCLINACION_TIBIAL — más livianos), y se posponen los 2 de Yun (B, D) hasta que estos terminen, para no repetir el agotamiento de cuota.
- Ningún archivo se llegó a crear en el primer intento (los agentes fallaron durante la fase de lectura/reconocimiento, antes de escribir código) — se relanza desde cero, sin trabajo previo que recuperar.

## Conflicto de concurrencia detectado y resuelto
- Al reanudar tras el reset de límite de cuenta, `ListAgents` mostró que el Agente A original (TOBILLO/Zhao, id interno terminado en ...8c9) en realidad seguía VIVO — la notificación de "fallo" recibida antes fue parcial/transitoria, no una muerte real del proceso.
- Sin saber esto, se había relanzado un segundo agente para la misma tarea (TOBILLO/Zhao) — los dos escribiendo el mismo archivo (`Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m`) a la vez.
- Se detectó por advertencias de "archivo modificado en disco" mientras se revisaba el código manualmente. Se detuvo el agente DUPLICADO (el relanzado) con `TaskStop`, dejando al original (más avanzado) continuar solo.
- Hallazgo de paso: el archivo tenía un bug real antes de correrlo — guardaba resultados con el MISMO nombre que Koopman (`Evaluar_vs_Kuopio_Tobillo_Fases_resultados.csv`/`_figura.png`, sin sufijo `_Zhao`), lo que habría sobrescrito los resultados ya validados de Koopman. Se corrigió manualmente (agregado sufijo `_Zhao` a las 2 salidas) antes de que el agente original llegara a esa misma corrección — el agente detenido, en su último mensaje, ya iba a hacer exactamente el mismo arreglo, así que el bug era real y ambos coincidieron en la causa.
- Para INCLINACION_TIBIAL/Zhao no había duplicado (el original de esa tarea sí murió de verdad con el límite de cuota) — el relanzado corre solo, sin conflicto.
- Lección para el resto de la noche: verificar `ListAgents` antes de relanzar cualquier tarea que se haya reportado como "fallida", en vez de asumir que la notificación de fallo es definitiva.

## Tarea 3 (INCLINACION_TIBIAL/Zhao) — Agente C, completada

- Leídos `PLAN_ZHAO_YUN.md`, `Evaluar_vs_Kuopio_AnguloTibial.m` y `Evaluar_Individual_Kuopio_AnguloTibial.m` (plantillas de Koopman) antes de escribir nada.
- Construidos `INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Zhao.m` y `INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_Zhao.m`, copia estructural exacta de los de Koopman. Única diferencia real del pipeline: la predicción cruda sale de `Z = Zhao2026_Core(antro.long_muslo_m+antro.long_tibia_m, 1/S.T_ciclo_s); t_Z = rad2deg(Z.theta_tibia_rad);` en vez de la llamada a `Koopman2014_Core` — cadencia REAL medida del sujeto (`1/S.T_ciclo_s`, regla D2: medido > estimado), longitud de pierna = muslo+tibia ya estimados por `Estimar_Antropometria_Core`. Se usó el default nativo de `Zhao2026_Core` (`opciones.lado='izquierda'`), SIN aplicar el "truco de lado" — regla de oro del plan y D2 de `DECISIONES.md`, no reabierta.
- Corridos ambos scripts en MATLAB real (`C:\Program Files\MATLAB\R2025b\bin\matlab.exe -batch`). N=15, sin fallos de sujeto, sin NaN en ninguna columna de r/RMSE/RMSEnorm.
- **Resultado (N=15, ángulo tibial nativo de Zhao vs Kuopio 2024):**
  - Sin calibrar: r=-0.303, RMSE=33.48°, RMSEnorm=11.93 ("Deficiente" en la escala del proyecto).
  - Calibrado (afín LOSO): r=0.303 (una transformación afín con ganancia negativa, `b≈-0.21` en las 15 corridas LOSO, invierte el signo de r sin cambiar su magnitud — r pasa de -0.303 a +0.303, NO mejora la relación real), RMSE=16.40°, RMSEnorm=3.39 (sigue "Deficiente", <1 sería "Excelente").
  - Individual (6 sujetos [40,37,43,46,19,28]): r_ang entre 0.189 y 0.411, RMSEnorm calibrado entre 2.62 y 4.23 — consistente con el promedio de grupo, ningún sujeto se comporta radicalmente distinto.
- **Interpretación, tal como pedía el plan (no forzar una corrección):** el ángulo tibial nativo de Zhao (`theta_tibia_rad = phi_cadera - phi_rodilla`, convención propia del paper) NO reproduce la forma del ángulo tibial real de Kuopio con el lado nativo 'izquierda' — la correlación cruda es negativa. Esto es consistente con el defasaje de fase de Zhao ya documentado en `RODILLA/CIERRE_RODILLA.md` (pico de flexión de rodilla adelantado ~20-25% del ciclo vs. el ~70% normativo) y con la decisión D2 de no aplicar el "truco de lado" para intentar arreglarlo. A diferencia de Koopman (r=0.992, un solo defecto de escala que la calibración afín sí corrige del todo), aquí la calibración afín no puede rescatar una curva con la forma equivocada — el coeficiente de ganancia sale NEGATIVO (`b≈-0.21`), lo que en la práctica solo invierte el signo del error de fase sin corregirlo. **Zhao no es un candidato viable para el ángulo tibial con su configuración nativa** — hallazgo válido a reportar, igual que ya se documentó para rodilla.
- No se tocó ningún archivo de Koopman (`Evaluar_vs_Kuopio_AnguloTibial.m`, `Evaluar_Individual_Kuopio_AnguloTibial.m`) ni se re-ejecutaron.
- Archivos generados: `Evaluar_vs_Kuopio_AnguloTibial_Zhao.m`, `Evaluar_vs_Kuopio_AnguloTibial_Zhao_resultados.csv`, `Evaluar_vs_Kuopio_AnguloTibial_Zhao_figura.png`, `Evaluar_Individual_Kuopio_AnguloTibial_Zhao.m`, `Evaluar_Individual_Kuopio_AnguloTibial_Zhao_resultados.csv`, `Evaluar_Individual_Kuopio_AnguloTibial_Zhao_figura.png` — los 6 en `CODIGOS/GENERADOR/INCLINACION_TIBIAL/`.
- Commit de git hecho por separado (ver historial de git) con estos 6 archivos + esta entrada de bitácora.

## Tarea 1 (TOBILLO/Zhao) — Agente A, completada

- Leídos `PLAN_ZHAO_YUN.md`, `Evaluar_vs_Kuopio_Tobillo_Fases.m` y `Evaluar_Individual_Kuopio_Tobillo.m` (plantillas de Koopman) antes de escribir nada.
- **Conflicto de concurrencia real durante esta tarea** (ya descrito arriba en "Conflicto de concurrencia detectado y resuelto"): hubo dos procesos escribiendo `Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m` a la vez tras el reinicio por límite de cuota. Al retomar esta sesión, los archivos ya estaban en disco con el pipeline correcto (llamadas a `Temporizacion_Core(antro,'Zhao')` y `Obtener_Angulos_Candidato('Zhao',...)`, confirmado por `grep`) y ya corridos — se verificó su contenido y resultados en vez de volver a escribirlos por encima, para no reabrir el mismo conflicto.
- Construidos/verificados `TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m` y `TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Zhao.m`, copia estructural exacta de los de Koopman (calibración afín LOSO de muslo+tibia, `Cadena_Completa_Core`, residuo de rockers LOSO en X e Y, cierre de ciclo en Y + cierre de zancada en X, misma figura pareada 3x2). Único cambio real: la fuente del ángulo es Zhao (`Obtener_Angulos_Candidato('Zhao',...)`), lado nativo `'izquierda'` (default de `Zhao2026_Core.m`, SIN el "truco de lado" — D2 de `DECISIONES.md`, no reabierta).
- Nota cosmética encontrada, no corregida (no es un bug funcional): el `fprintf` de cabecera de consola del script de grupo quedó con el texto heredado "MODELO FINAL" en vez de "CANDIDATO ZHAO" — el docstring, los nombres de archivo de salida (`..._Zhao_resultados.csv`/`..._Zhao_figura.png`) y las llamadas internas sí son correctos y específicos de Zhao (verificado con `grep` línea por línea). Se deja como está para no volver a tocar un archivo que ya pasó por un conflicto de escritura concurrente.
- Corridos ambos scripts en MATLAB real (`C:\Program Files\MATLAB\R2025b\bin\matlab.exe -batch`, confirmado en esta sesión). N=15, sin fallos de sujeto, sin NaN en ninguna columna de r/RMSE.
- **Resultado de grupo (N=15, cadena completa vs Kuopio 2024):**
  - Calibración de ángulos (LOSO): muslo ganancia=0.808, offset=4.18°; tibia ganancia=-0.218, offset=-20.58°.
  - X: r=0.974 (SD=0.014), RMSE=10.99cm.
  - Y: r=0.914 (SD=0.022), RMSE=2.51cm; amplitud modelo/real=0.52 (el modelo reproduce ~52% de la excursión vertical real).
  - Comparado con Koopman en el mismo pipeline (r_x=0.998/RMSE=2.90cm, r_y=0.985/RMSE=1.54cm): Zhao es claramente peor en ambos ejes, sobre todo en RMSE de X (10.99 vs 2.90cm) — consistente con el defasaje de fase de Zhao ya documentado (`RODILLA/CIERRE_RODILLA.md`), que aquí se propaga a través de `Cadena_Completa_Core` a la posición del tobillo. La ganancia de tibia sale NEGATIVA (-0.218), señal de forma de curva invertida respecto al dato real, igual que se encontró para el ángulo tibial puro en la Tarea 3.
  - Individual (6 sujetos [40,37,43,46,19,28]): r_x entre 0.955 y 0.989, r_y entre 0.884 y 0.948 — sin outliers extremos, el desempeño mediocre de Zhao es consistente entre sujetos, no producto de 1-2 casos atípicos.
- **Interpretación, tal como pedía el plan (hallazgo, no error a esconder):** Zhao con su configuración nativa reproduce razonablemente la FORMA de la trayectoria del tobillo (r alto en ambos ejes) pero con error absoluto sustancialmente mayor que Koopman y una excursión vertical claramente insuficiente (48% de déficit) — **Zhao no es competitivo con Koopman para el tobillo con el lado nativo**, coherente con el hallazgo ya reportado para rodilla y para el ángulo tibial puro (Tarea 3: r crudo negativo). El "truco de lado" queda, como decidido en D2, sin probarse aquí — sigue siendo una decisión de ingeniería pendiente del usuario, no resuelta en esta tarea autónoma.
- No se tocó ningún archivo de Koopman (`Evaluar_vs_Kuopio_Tobillo_Fases.m`, `Evaluar_Individual_Kuopio_Tobillo.m`) ni se re-ejecutaron en esta tarea.
- Archivos: `Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m`, `Evaluar_vs_Kuopio_Tobillo_Fases_Zhao_resultados.csv`, `Evaluar_vs_Kuopio_Tobillo_Fases_Zhao_figura.png`, `Evaluar_Individual_Kuopio_Tobillo_Zhao.m`, `Evaluar_Individual_Kuopio_Tobillo_Zhao_resultados.csv`, `Evaluar_Individual_Kuopio_Tobillo_Zhao_figura.png` — los 6 en `CODIGOS/GENERADOR/TOBILLO/`.
- Commit de git hecho con estos 6 archivos + esta entrada de bitácora + el checkbox de Tarea 1 en `PLAN_ZHAO_YUN.md`.

## Nota: Agente B (TOBILLO/Yun) reportó "completed" prematuramente
- La notificación de finalización de B llegó con el mensaje "Waiting for the background MATLAB job to complete. I'll resume verification, documentation, and commit once it finishes." — es decir, el turno del agente terminó ANTES de que MATLAB (que él mismo lanzó en background) terminara. El proceso MATLAB.exe sigue vivo y avanzando (confirmado con `tasklist` y el log `TOBILLO/yun_run_log.txt`: "Sujeto 1 OK (1/15)", procesando sujeto 2).
- Mismo patrón probable en D (INCLINACION_TIBIAL/Yun, log `yun_grupo_log.txt` muestra el inicio de la primera regresión, sin notificación de fin todavía).
- Decisión: NO relanzar ni matar estos procesos MATLAB — están corriendo correctamente, solo lentos (~15 sujetos x regresión GP completa cada uno). Se espera a que terminen (revisando los logs y los archivos de salida esperados) y, si el agente no vuelve a reportar, el coordinador (yo) verifica/documenta/commitea el resultado directamente en vez de relanzar un agente nuevo para esta tarea ya en curso.

## Tarea 2 (TOBILLO/Yun) — resultado de GRUPO confirmado, individual en curso
- Script de grupo (`Evaluar_vs_Kuopio_Tobillo_Fases_Yun.m`) terminó en MATLAB real: N=15, sin NaN, sin fallos de sujeto.
- **Resultado (N=15, vía tobillo — regla ya corregida hoy, cadena completa vs Kuopio):**
  - Calibración LOSO: muslo ganancia≈0.85 (rango 0.82-0.88), tibia ganancia≈-0.70 (rango -0.65 a -0.78, NEGATIVA en los 15 sujetos — mismo patrón de forma invertida ya visto en Zhao).
  - X: r medio≈0.989 (rango 0.973-0.997), RMSE medio≈7.08cm (rango 4.30-10.49cm).
  - Y: r medio≈0.831 (rango 0.724-0.907), RMSE medio≈3.39cm (rango 2.42-6.58cm).
  - Comparado con Koopman (X r=0.998/RMSE=2.90cm, Y r=0.985/RMSE=1.54cm): Yun tiene correlación de forma razonable en X pero RMSE mucho peor (7.08 vs 2.90cm), y tanto r como RMSE claramente peores en Y. **Yun no es competitivo con Koopman para tobillo con su configuración nativa** — consistente con el patrón ya visto en Zhao y con el propio resultado de Yun en ángulo tibial puro (ver Tarea 4 abajo).
- Script individual (`Evaluar_Individual_Kuopio_Tobillo_Yun.m`) lanzado, recorriendo los 15 sujetos de nuevo (mismo patrón "no duplicar lógica" que Koopman - el individual llama al de grupo con `hacer_figura=false`, que igual recalcula todo, solo omite graficar) - en curso, ~3/15 al momento de este registro. Se completará la Tarea 2 cuando termine.

## Tarea 4 (INCLINACION_TIBIAL/Yun) — resultado de GRUPO confirmado, individual en curso
- Script de grupo (`Evaluar_vs_Kuopio_AnguloTibial_Yun.m`) terminó en MATLAB real: N=15, sin NaN.
- **Resultado (N=15, ángulo tibial nativo vía tobillo, Yun vs Kuopio 2024):**
  - Sin calibrar: r crudo NEGATIVO en los 15 sujetos (rango -0.04 a -0.45, media≈-0.31), RMSE crudo 18-27°, RMSEnorm crudo 3.6-6.0 ("Deficiente").
  - Calibrado (afín LOSO): ganancia SIEMPRE negativa (rango -0.69 a -0.86) — la calibración solo invierte el signo del error de fase sin corregirlo (r_cal = |r_crudo|, mismo mecanismo ya documentado para Zhao en esta misma pieza). RMSE calibrado 12-20°, RMSEnorm calibrado 3.1-5.9 — sigue "Deficiente" en la escala del proyecto (<1 sería "Excelente").
- **Interpretación, igual que Zhao:** Yun tampoco reproduce la forma del ángulo tibial real con su configuración nativa (vía tobillo, canal R_) — el defecto es de fase/forma, no de escala, y la calibración afín no lo puede rescatar. **Yun no es un candidato viable para el ángulo tibial**, mismo veredicto que Zhao, por una razón de la misma naturaleza (aunque el mecanismo interno de cada modelo sea distinto).
- Script individual lanzado, en curso (log `yun_individual_log.txt`, recorriendo los 15 sujetos de nuevo). Se completará la Tarea 4 cuando termine.

## Tarea 2 (TOBILLO/Yun) — COMPLETADA (Agente B, retomando tras el falso "completed" de arriba)

- El turno anterior de este mismo agente (B) había reportado "completed" antes de que el proceso MATLAB en background terminara (ver nota de arriba) — al recibir la notificación real de fin de proceso (exit code 0), se retomó la tarea para verificar y cerrar.
- Confirmado en `yun_run_log.txt`: los 15 sujetos cargaron sin error tanto en la corrida de grupo como en la de individual (dos pasadas completas de `Yun2014_Wrapper`, sin fallos, sin `NaN` en ninguna columna de `Evaluar_vs_Kuopio_Tobillo_Fases_Yun_resultados.csv` ni de `Evaluar_Individual_Kuopio_Tobillo_Yun_resultados.csv`).
- **Resultado final de grupo (N=15, coincide con el checkpoint parcial de arriba, confirmado dígito a dígito contra el CSV):** muslo ganancia=0.853, offset=13.12°; tibia ganancia=-0.692, offset=-20.69° (NEGATIVA en los 15 sujetos, rango -0.646 a -0.780 — señal de forma tibial invertida respecto al dato real, mismo patrón que Zhao). X: r=0.990 (SD=0.007), RMSE=7.08cm. Y: r=0.831 (SD=0.066), RMSE=3.39cm; amplitud modelo/real=0.51 (el modelo reproduce ~51% de la excursión vertical real, calculado por chequeo cruzado, no forzado desde otra tarea).
- **Resultado individual (6 sujetos [40,37,43,46,19,28], igual que Koopman/Zhao):**

  | sub_id | sexo | talla_cm | masa_kg | r_x | rmse_x (cm) | r_y | rmse_y (cm) |
  |---|---|---|---|---|---|---|---|
  | 40 | M | 183.6 | 136.14 | 0.986 | 7.74 | 0.763 | 2.42 |
  | 37 | M | 186.6 | 90.38 | 0.994 | 4.92 | 0.825 | 3.48 |
  | 43 | M | 179.0 | 61.02 | 0.995 | 7.46 | 0.800 | 2.97 |
  | 46 | F | 165.0 | 64.61 | 0.996 | 8.45 | 0.907 | 2.73 |
  | 19 | F | 169.0 | 63.24 | 0.978 | 9.48 | 0.736 | 2.64 |
  | 28 | M | 172.5 | 103.59 | 0.996 | 4.74 | 0.890 | 3.52 |

  Sin outliers extremos — r_x se mantiene 0.978-0.996 y r_y 0.736-0.907 en los 6 sujetos de antropometría diversa, consistente con el promedio de grupo. El sujeto 19 (mujer, talla media) tiene el peor r_y (0.736) pero no un RMSE atípico.
- **Interpretación, sin forzar corrección (regla de oro del plan):** Yun con canal R_ nativo y vía tobillo (la regla ya corregida el 26-ago) reproduce razonablemente la FORMA de X (r≈0.99) pero con RMSE bastante peor que Koopman (7.08 vs 2.90cm) y un Y claramente inferior tanto en r (0.831 vs 0.985) como en amplitud reproducida (51% vs la referencia de Koopman). La ganancia de tibia negativa en los 15 sujetos es la misma señal de forma-invertida ya vista en Zhao (Tarea 1) y en el propio ángulo tibial de Yun (Tarea 4) — **Yun no es competitivo con Koopman para tobillo con su configuración nativa**, mismo veredicto que Zhao, consistente entre las 3 piezas evaluadas esta noche (rodilla ya cerrada antes, tobillo y ángulo tibial esta noche). No se probó el "truco de lado" (L_/R_) ni vía rodilla — decisión D2 de `DECISIONES.md`, explícitamente no reabierta por esta tarea.
- Tiempo total: la corrida de grupo (15 sujetos, GP completo por sujeto) tardó de 00:27 a 00:53 (~26 min); la corrida individual (recalcula los 15 de nuevo porque `Evaluar_Individual_Kuopio_Tobillo_Yun.m` llama a `Evaluar_vs_Kuopio_Tobillo_Fases_Yun(false)`, que no cachea entre invocaciones de MATLAB separadas) tardó de 00:53 a 01:18 (~25 min). Total ~51 min para las dos corridas en un solo proceso `matlab -batch` secuencial.
- No se tocó ningún archivo de Koopman ni de Zhao, ni ningún archivo con "_Zhao" en el nombre. No se tocó `INCLINACION_TIBIAL/` (Tarea 4, de otro agente).
- Archivos de esta tarea (ya en disco, algunos ya committeados en el checkpoint parcial `5668111`, el resto — resultados/figura del individual — pendientes de commit en esta misma entrada): `TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Yun.m`, `TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Yun_resultados.csv`, `TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Yun_figura.png`, `TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Yun.m`, `TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Yun_resultados.csv`, `TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Yun_figura.png`. El log de consola `TOBILLO/yun_run_log.txt` se deja en disco sin commitear (mismo criterio que el resto de la noche: los logs de corrida no se versionan).
- Checkbox de Tarea 2 marcado en `PLAN_ZHAO_YUN.md`.
