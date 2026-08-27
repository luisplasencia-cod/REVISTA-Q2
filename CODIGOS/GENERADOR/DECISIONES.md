# Decisiones tomadas de forma autónoma — sesión /loop 26-ago-2026 noche

Registro de cada punto ambiguo resuelto sin preguntar, con la alternativa considerada, por la regla "elige lo más parecido a Koopman; si sigue ambiguo, la opción más conservadora".

## D1 — Nombres de archivo para Zhao/Yun
**Elegido:** sufijo `_Zhao`/`_Yun` sobre el nombre exacto del archivo de Koopman (ej. `Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m`).
**Alternativa considerada:** un solo script con parámetro de candidato (como `Evaluar_vs_Winter.m`/`Ver_Todos_Los_Modelos.m` hacen para comparaciones simples). Descartada porque la calibración LOSO + cadena completa + rockers de TOBILLO/INCLINACION_TIBIAL es mucho más compleja que esas comparaciones simples, y mezclar 3 candidatos en un único script arriesga romper lo ya validado de Koopman. Separar por archivo es más conservador.

## D2 — Lado/canal de Zhao y Yun
**Elegido:** usar el default nativo ya establecido en el proyecto (Zhao 'izquierda', Yun vía R_/tobillo) — NO aplicar los hallazgos de "phi_cadera vs phi_rodilla con distinto lado" descubiertos horas antes en esta misma sesión (`RODILLA/CIERRE_RODILLA.md` §1-ter).
**Alternativa considerada:** usar el "mejor lado por canal" (derecha para theta_tibia, izquierda para theta_muslo, en llamadas separadas a Zhao2026_Core). Descartada explícitamente porque el propio hallazgo de la tarde lo dejó como "decisión de ingeniería pendiente, del usuario" — decidirlo aquí, dentro de una tarea autónoma nocturna, sería inventar metodología nueva sin supervisión, exactamente lo que las instrucciones de esta tarea prohíben. Si el resultado de Zhao/Yun sale con r bajo por este motivo, se reporta como hallazgo, no se oculta ni se corrige aquí.

## D3 — Ubicación de archivos nuevos
**Elegido:** mismas carpetas `TOBILLO/` e `INCLINACION_TIBIAL/`, sin subcarpetas nuevas.
**Sin alternativa real considerada** — es lo que pide el objetivo explícitamente.

## D4 — Qué hacer si un subagente falla
**Elegido:** los demás continúan; el fallo se documenta aquí y en `REPORTE_NOCHE.md`, marcado como BLOQUEADO con la razón exacta.
