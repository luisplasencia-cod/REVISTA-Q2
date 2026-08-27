# Reporte de la noche — 26/27-ago-2026, tarea autónoma `/loop`

Objetivo: replicar para Zhao 2026 y Yun 2014 el pipeline de validación contra Kuopio (calibración LOSO, cadena completa, validación individual) que hasta anoche solo existía para Koopman 2014, en `TOBILLO/` e `INCLINACION_TIBIAL/`.

## 1. Qué quedó terminado y verificado

**Las 4 tareas de la Fase 2 (código nuevo), completas:**
- `TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m` + individual (N=15 + 6, sin NaN)
- `TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Yun.m` + individual (N=15 + 6, sin NaN)
- `INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Zhao.m` + individual (N=15 + 6, sin NaN)
- `INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Yun.m` + individual (N=15 + 6, sin NaN)

**Fase 3 (validación), completa:**
- No-regresión de Koopman confirmada: los 4 scripts originales (`Evaluar_vs_Kuopio_Tobillo_Fases.m`, `Evaluar_Individual_Kuopio_Tobillo.m`, `Evaluar_vs_Kuopio_AnguloTibial.m`, `Evaluar_Individual_Kuopio_AnguloTibial.m`) se re-corrieron en MATLAB real y producen CSV **byte-idénticos** a los que ya existían antes de esta noche (`md5sum` idéntico). Las 4 figuras PNG se revirtieron a su versión committeada (el re-render cambiaba metadata de bytes sin cambiar el contenido, se descartó ese cambio cosmético).
- `TOBILLO/CIERRE_TOBILLO.md` y `INCLINACION_TIBIAL/CIERRE_INCLINACION_TIBIAL.md` actualizados con tablas de los 3 candidatos lado a lado.
- `docs/algoritmo/pipeline_koopman_kuopio/PIPELINE_KOOPMAN_KUOPIO.md` actualizado (sección 5.7 nueva, sección 8 revisada).

**Resultado central — Koopman gana en TOBILLO e INCLINACION_TIBIAL, con los 3 candidatos en su configuración nativa:**

| TOBILLO | Koopman | Zhao | Yun |
|---|---|---|---|
| X — r / RMSE | **0.998 / 2.90cm** | 0.974 / 10.99cm | 0.990 / 7.08cm |
| Y — r / RMSE | **0.985 / 1.54cm** | 0.914 / 2.51cm | 0.831 / 3.39cm |

| ÁNGULO TIBIAL | Koopman | Zhao | Yun |
|---|---|---|---|
| r crudo | 0.992 | -0.303 | -0.300 |
| RMSEnorm calibrado | **0.92 (Excelente)** | 3.39 (Deficiente) | 4.42 (Deficiente) |

Esto es **distinto** del resultado ya conocido de RODILLA/Maastricht (sesión de ayer), donde Zhao y Yun corregidos ("truco de lado") empataban o superaban a Koopman. Aquí, con la configuración **nativa** (sin ese truco, por decisión explícita D2), Koopman gana con claridad en las 2 piezas nuevas.

## 2. Qué quedó a medias o bloqueado

**Nada quedó bloqueado de verdad.** Hubo un bloqueo transitorio real (límite de cuota de la sesión, ver §4) que se resolvió reintentando con menor concurrencia. Todo el checklist de `PLAN_ZHAO_YUN.md` (Tareas 1-7) está marcado `[x]`.

## 3. Decisiones que tomé por ti y que deberías revisar

1. **D2 (no reabierta, la más importante):** Zhao y Yun se conectaron con su configuración nativa (Zhao lado='izquierda', Yun canal R_/vía tobillo) — **nunca se probó el "truco de lado"** que funcionó para RODILLA/Maastricht. La razón para no probarlo: ese truco corrige un defecto de fase específico del canal de rodilla/flexión nativa (`RODILLA/CIERRE_RODILLA.md` §1-ter), y TOBILLO/INCLINACION_TIBIAL dependen del ángulo tibial combinado (cadera−rodilla), no de ese canal aislado — no hay garantía de que ayude igual. **Esto sigue siendo una decisión de ingeniería tuya, no la tomé yo.** Si quieres que se pruebe, es la siguiente acción de mayor valor.
2. **Nombres de archivo:** sufijo `_Zhao`/`_Yun` sobre el nombre exacto de Koopman (ej. `Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m`). Un agente cometió el error de omitir el sufijo en los nombres de SALIDA (no del archivo .m) una vez — lo until corregí a tiempo antes de correr el script, no se sobrescribió nada de Koopman.
3. **No relanzar agentes sin verificar `ListAgents` primero:** durante la noche, una notificación de "fallo" resultó ser parcial — el agente seguía vivo. Relancé un duplicado sin darme cuenta, lo que causó dos procesos escribiendo el mismo archivo a la vez. Lo detecté y resolví con `TaskStop` sobre el duplicado, sin pérdida de trabajo, pero es una lección para la próxima vez que se use `/loop` con subagentes.

## 4. Anomalías numéricas detectadas

- **Ganancia de tibia (calibración LOSO) sale NEGATIVA para Zhao y Yun en las 3 piezas** (RODILLA, TOBILLO, ÁNGULO TIBIAL) — mientras Koopman siempre da positiva. Es la firma numérica del defecto de fase/forma ya documentado: Zhao/Yun con configuración nativa no reproducen la forma correcta del ángulo, así que la calibración afín solo puede invertir el signo del error (`r_calibrado = |r_crudo|` exactamente, por la matemática de la transformación afín), sin corregir la relación real. No es un bug de código — está reportado tal cual en ambos `CIERRE_*.md`, no oculto.
- **Límite de cuota de la sesión** se agotó dos veces la misma noche al lanzar 4 agentes pesados en paralelo (los 2 de Yun corren regresión GP completa + escriben ~30 archivos cada uno). Se resolvió reduciendo la concurrencia (2 Zhao primero, luego los Yun de a uno). Si se repite este tipo de tarea, lanzar como máximo 2-3 agentes pesados a la vez.
- **Los agentes B y D (Yun) reportaron "completed" antes de que su propio proceso MATLAB en background terminara** — el patrón `run_in_background` dentro de un subagente no garantiza que el agente espere a que termine antes de reportar. Se resolvió con verificación manual del coordinador (yo) cuando no había nadie más vigilando el proceso. Ambos agentes, en al menos un caso, se "despertaron" solos más tarde (notificación repetida del mismo `task-id`) y terminaron su propio trabajo de verificación/commit — pero no hay que asumir que esto siempre pasa; el coordinador debe estar preparado para terminar el trabajo él mismo.

## 5. Siguientes pasos concretos, priorizados

1. **Decidir si se prueba el "truco de lado" de Zhao/Yun en TOBILLO/INCLINACION_TIBIAL** — la pregunta más importante que queda abierta. Si Koopman sigue ganando incluso con el truco aplicado, la elección de Koopman como modelo único queda mucho más sólida. Si no, hay que reconsiderar la estrategia (¿un modelo por pieza en vez de un solo ganador global?).
2. **Re-evaluar Zhao/Yun contra Ferber y Kuopio-RODILLA con el lado corregido** (ya identificado como pendiente desde ayer, `RODILLA/CIERRE_RODILLA.md` §1-ter) — sigue sin hacerse, sigue siendo la acción de mayor valor para cerrar la comparación de RODILLA.
3. Revisar el contenido nuevo de esta noche en los 3 documentos (`CIERRE_TOBILLO.md` §11, `CIERRE_INCLINACION_TIBIAL.md` §9, `PIPELINE_KOOPMAN_KUOPIO.md` §5.7/§8) antes de darlo por definitivo para el manuscrito — es prosa nueva, no pasó por tu aprobación explícita como sí pasaron otras decisiones del proyecto.
4. Limpiar los archivos de log sueltos (`yun_run_log.txt`, `yun_grupo_log.txt`, `yun_individual_log.txt`) — quedaron sin commitear a propósito (son logs de depuración, no resultados), pero siguen en disco; bórralos si ya no los necesitas.

## Archivos de esta tarea (quedan en disco, no se borran)

`PLAN_ZHAO_YUN.md`, `DECISIONES.md`, `BITACORA_NOCHE.md` (log cronológico completo, mucho más detallado que este resumen) — todos en `CODIGOS/GENERADOR/`.
