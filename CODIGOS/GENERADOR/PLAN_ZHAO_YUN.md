# Plan: replicar para Zhao y Yun el pipeline de TOBILLO/ e INCLINACION_TIBIAL/ que hoy solo existe para Koopman

**Estado:** en ejecución, modo autónomo (`/loop`), 26-ago-2026 noche. Este archivo es el checklist — se actualiza marcando progreso.

**Regla de oro de todo este plan:** la implementación de Koopman (`TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases.m` + `Evaluar_Individual_Kuopio_Tobillo.m`; `INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial.m` + `Evaluar_Individual_Kuopio_AnguloTibial.m`) es la ESPECIFICACIÓN. No se inventa metodología nueva. No se aplican los "trucos de lado" descubiertos hoy más temprano en la sesión (phi_cadera vs phi_rodilla con distinto `lado` — ver `RODILLA/CIERRE_RODILLA.md` §1-ter) — esa es una decisión de ingeniería explícitamente pendiente y NO se decide dentro de esta tarea autónoma. Zhao y Yun se conectan al pipeline con su configuración NATIVA/default ya establecida en el proyecto (`Obtener_Angulos_Candidato.m`, `Obtener_Theta_Tibia_Candidato.m` — ya arreglados hoy para usar la regla correcta de Yun vía tobillo). Si el resultado sale con `r` bajo por el defasaje ya documentado, ESO ES UN HALLAZGO VÁLIDO A REPORTAR, no un error a esconder ni a "arreglar" con el truco de lado.

## Fase 0 — Contrato de Koopman, reconstruido

### TOBILLO (`TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases.m`)

**Entrada:** N=15 sujetos de `RODILLA/Kuopio/raw/subjects_meta.csv` (mismos IDs que usa el propio archivo, vía `Cargar_Kuopio2024_Core.m` — NO tocar ni duplicar ese loader, es compartido y candidato-agnóstico).

**Pasos, en orden:**
1. Por sujeto: `S = Cargar_Kuopio2024_Core(sid)`.
2. `antro_in = struct('talla_m', S.talla_cm/100, 'masa_kg', S.masa_kg, 'sexo', S.sexo(1), 'velocidad_ms', S.speed_ms, 'long_muslo_m', S.muslo_mm/1000, 'long_tibia_m', S.tibia_mm/1000)` — TODO dato real medido, nunca estimado (D2: medido > estimado).
3. `antro = Estimar_Antropometria_Core(antro_in)`.
4. `tempo = Temporizacion_Core(antro, '<Candidato>')` — **OJO: pasar el nombre del candidato real ('Zhao'/'Yun'), no 'Koopman' fijo** (ver `Temporizacion_Core.m` líneas 15-32 — determina de dónde sale `tiempo_ciclo_s`; para Yun sale NaN y se sobreescribe abajo con dato real, para Zhao reusa la regresión de Koopman por diseño ya documentado, no es un bug).
5. `[th_m, th_t, tempo] = Obtener_Angulos_Candidato('<Candidato>', antro, tempo, npts=101)`.
6. Sobreescribir con datos REALES del sujeto (igual que Koopman): `tempo.tiempo_ciclo_s = S.T_ciclo_s; tempo.tiempo_apoyo_s = tempo.frac_apoyo*tempo.tiempo_ciclo_s; tempo.tiempo_balanceo_s = (1-tempo.frac_apoyo)*tempo.tiempo_ciclo_s;`
7. Ángulos REALES del sujeto (mismo para los 3 candidatos, no cambia): `Thm_real = atan2(-S.dx_muslo_cm, S.dy_muslo_cm)`, `Tht_real = atan2(-S.dx_tibia_cm, S.dy_tibia_cm)`.
8. Ángulos del candidato interpolados a malla 0:100 (`Thm_koop`→`Thm_cand`, `Tht_koop`→`Tht_cand`, mismo patrón de `pct_nat` que ya usa el script de Koopman).
9. **Calibración AFÍN LOSO de los DOS ángulos** (muslo y tibia), exactamente como Koopman: `polyfit` sobre los OTROS 14 sujetos, nunca el propio — ver líneas 148-160 del script de Koopman para la implementación exacta a replicar.
10. `Cadena_Completa_Core(th_m_calibrado, th_t_calibrado, L_muslo_m, L_tibia_m, tempo, npts)` — sin cambios, la función ya es candidato-agnóstica (recibe ángulos, no le importa de dónde vinieron).
11. Residuo de rockers LOSO en X e Y (líneas 180-244 del script de Koopman) — sin cambios, opera sobre posiciones ya calculadas, candidato-agnóstico.
12. Cierre de ciclo en Y (rampa en balanceo) + cierre de zancada en X (`velocidad*T_ciclo`) — sin cambios, candidato-agnóstico.
13. Métricas: `r_x, rmse_x, r_y, rmse_y` por sujeto + tabla + CSV (`<candidato>_gan_muslo/off_muslo/gan_tibia/off_tibia` en vez de genérico).
14. Figura de grupo: PAREADA por sujeto (nunca promediar), 3×2 paneles (X/Y arriba, error X/Y medio, histogramas de r) — mismo layout exacto que Koopman.
15. Guardar: `Evaluar_vs_Kuopio_Tobillo_Fases_<Candidato>_resultados.csv`, `Evaluar_vs_Kuopio_Tobillo_Fases_<Candidato>_figura.png`.

**`Evaluar_Individual_Kuopio_Tobillo_<Candidato>.m`:** llama a `Evaluar_vs_Kuopio_Tobillo_Fases_<Candidato>(false)` — NUNCA duplica la lógica de cálculo. Mismos 6 sujetos exactos que Koopman: `[40, 37, 43, 46, 19, 28]`. Mismo layout de figura (6 filas × 2 columnas).

### INCLINACION_TIBIAL (`INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial.m`)

Más simple — no necesita fases ni cadena completa, solo el ángulo tibial nativo del candidato:
1. Igual pasos 1-4 de arriba.
2. **Koopman usa una llamada DIRECTA** (no `Obtener_Theta_Tibia_Candidato`, porque aquí no hace falta separar apoyo/balanceo): `K = Koopman2014_Core(S.speed_ms*3.6, antro.talla_m); t_K = K.theta_tibia_via_rodilla_deg;` — resampleado directo a pct 0:100 con `pchip`. **Para Zhao/Yun, replicar el mismo patrón de llamada directa** (no pasar por `Obtener_Theta_Tibia_Candidato`, que corta a fases — aquí no corresponde):
   - Zhao: `Z = Zhao2026_Core(antro.long_muslo_m+antro.long_tibia_m, 1/S.T_ciclo_s); t_Z = rad2deg(Z.theta_tibia_rad);` (usar 1/S.T_ciclo_s como cadencia real medida, no estimada — D2).
   - Yun: `Y = Yun2014_Wrapper(vector14_desde_antropometria(antro)); t_Y = rad2deg(Y.theta_tibia_via_tobillo_R_rad);` (vía tobillo, la regla ya establecida y corregida hoy para Yun — NO vía rodilla).
3. Real: `theta_real_deg = rad2deg(atan2(-S.dx_tibia_cm, S.dy_tibia_cm))` — sin cambios.
4. Calibración afín LOSO (un solo ángulo esta vez) — mismo patrón exacto que Koopman.
5. Métricas con `RMSEnorm` (`CODIGOS/VALIDACIONES/Calcular_Metricas_Curva.m`, SD entre sujetos por %ciclo) además de r/RMSE crudo — sin cambios de fórmula.
6. Figura: crudo vs calibrado, pareado, 3×2 paneles — mismo layout que Koopman.
7. Guardar: `Evaluar_vs_Kuopio_AnguloTibial_<Candidato>_resultados.csv`, `..._figura.png`.

**`Evaluar_Individual_Kuopio_AnguloTibial_<Candidato>.m`:** llama a `Evaluar_vs_Kuopio_AnguloTibial_<Candidato>(false)`. Mismos 6 sujetos.

## Diferencias Zhao/Yun vs. Koopman (verificadas en código, no supuestas)

| | Koopman | Zhao | Yun |
|---|---|---|---|
| Función núcleo | `Koopman2014_Core(v_kph, talla_m)` | `Zhao2026_Core(long_pierna_m, cadencia_hz, opts)` | `Yun2014_Wrapper(p14)` — vector 14 elementos |
| Costo computacional | Rápido (fórmula cerrada) | Rápido (serie de Fourier cerrada) | **LENTO** — regresión GP completa + escribe 30 archivos por llamada (ver `docs/algoritmo/pipeline_koopman_kuopio/PIPELINE_KOOPMAN_KUOPIO.md` — corrió ~10+ min para 40 sujetos en una investigación de esta misma sesión) |
| theta_tibia nativo | `theta_tibia_via_rodilla_rad` (ya calculado dentro) | `theta_tibia_rad = phi_cadera - phi_rodilla` (ya calculado dentro, Sec.2.6 del paper) | `theta_tibia_via_tobillo_R_rad` (YA CORREGIDO hoy — antes se usaba vía rodilla por error en `Obtener_Angulos_Candidato.m`, ver `CODIGOS/GENERADOR/GUIA_INTERPRETACION.md` §7) |
| Parámetro de lado | No existe | `lado`: 'izquierda' (default) / 'derecha' — **NO TOCAR, usar default**, ver regla de oro arriba | R_/L_ channels — **usar R_ (default ya establecido en el proyecto)** |
| tiempo_ciclo_s | `Tiempo_Ciclo_Koopman2014_Core` | Reusa la misma regresión de Koopman (ya documentado, no es error) | Propio del toolbox (`Y.periodo_s`) — sale NaN de `Temporizacion_Core`, hay que tomarlo de `Yun2014_Wrapper` directamente |
| `Obtener_Angulos_Candidato.m` / `Obtener_Theta_Tibia_Candidato.m` | Ya soportan 'Koopman' | Ya soportan 'Zhao' (sin cambios necesarios) | Ya soportan 'Yun' (corregido hoy) |

**Consecuencia práctica de que Yun sea lento:** cada script de Yun (grupo + individual, ×2 carpetas = 4 corridas) va a tardar. Los subagentes de Yun deben avisar tiempos esperados y NO deben re-correr sujeto por sujeto más de lo necesario — cachear `Yun2014_Wrapper` por sujeto una sola vez si el script necesita el mismo sujeto para grupo e individual (el individual ya reusa el cálculo del grupo vía `hacer_figura=false`, así que esto ya está resuelto por diseño, solo hay que no romperlo).

## Tareas atómicas

| # | Tarea | Agente | Depende de | Criterio de "hecho" |
|---|---|---|---|---|
| 1 | `TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m` + individual | A | — | CSV + PNG generados, N=15 (o menos con fallos documentados), sin NaN en columnas de r |
| 2 | `TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Yun.m` + individual | B | — | idem |
| 3 | `INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Zhao.m` + individual | C | — | idem, incluye RMSEnorm |
| 4 | `INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Yun.m` + individual | D | — | idem |
| 5 | Auditoría cruzada: re-correr Koopman (ambas carpetas) y confirmar resultados idénticos a antes | E | 1-4 | Diff numérico = 0 contra los CSV ya existentes de Koopman |
| 6 | Actualizar `CIERRE_TOBILLO.md` y `CIERRE_INCLINACION_TIBIAL.md` con los 3 candidatos | E | 1-4 | Tablas con Koopman/Zhao/Yun lado a lado |
| 7 | Actualizar `PIPELINE_KOOPMAN_KUOPIO.md` | E | 6 | Sección Kuopio menciona los 3 |

Sin dependencias entre 1-4 (archivos de escritura distintos) → paralelizables. 5-7 seriales, después de 1-4.

## Ambigüedades y decisiones ya tomadas (no volver a preguntar)

1. **Nombres de archivo:** sufijo `_Zhao`/`_Yun` sobre el nombre exacto de Koopman. Conservador, no rompe nada existente.
2. **Lado de Zhao/Yun:** default nativo del proyecto, sin mezclar canales. Ver regla de oro arriba.
3. **Ubicación:** mismas carpetas `TOBILLO/`, `INCLINACION_TIBIAL/` — no se crean subcarpetas nuevas.
4. **Qué NO se toca:** `Cargar_Kuopio2024_Core.m`, `Cadena_Completa_Core.m`, `Calcular_Metricas_Curva.m`, y los 4 archivos de Koopman ya existentes — se leen, no se editan.

## Progreso

- [x] Tarea 1 (TOBILLO/Zhao) — Agente A — hecho 27-ago-2026, N=15, ver BITACORA_NOCHE.md (X r=0.974/RMSE=10.99cm, Y r=0.914/RMSE=2.51cm — peor que Koopman en ambos ejes, consistente con el defasaje de fase ya documentado; Zhao no competitivo con lado nativo)
- [x] Tarea 2 (TOBILLO/Yun) — Agente B — hecho 27-ago-2026, N=15, ver BITACORA_NOCHE.md (X r=0.990/RMSE=7.08cm, Y r=0.831/RMSE=3.39cm — peor que Koopman en ambos ejes, ganancia de tibia negativa (forma invertida), mismo patrón que Zhao; individual 6 sujetos sin outliers, r_x 0.978-0.996, r_y 0.736-0.907)
- [x] Tarea 3 (INCLINACION_TIBIAL/Zhao) — Agente C — hecho 27-ago-2026, N=15, ver BITACORA_NOCHE.md (r crudo=-0.303, calibrado=0.303/RMSEnorm=3.39 — Zhao no viable para tibia con lado nativo, defasaje de fase, hallazgo reportado tal cual)
- [x] Tarea 4 (INCLINACION_TIBIAL/Yun) — Agente D — hecho 27-ago-2026, N=15, ver BITACORA_NOCHE.md (r crudo=-0.300, calibrado=0.300/RMSEnorm=4.417 — Yun no viable para tibia con canal nativo vía tobillo R_, mismo defecto de forma/fase que Zhao, hallazgo reportado tal cual)
- [ ] Tarea 5 (auditoría no-regresión Koopman) — Agente E
- [ ] Tarea 6 (actualizar CIERRE docs) — Agente E
- [ ] Tarea 7 (actualizar pipeline doc) — Agente E
