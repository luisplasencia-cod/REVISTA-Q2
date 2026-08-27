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
