INICIO DEL LOOP: 2026-08-27 23:57:56 SAPST

# Control interno del loop de revisión — NO se lee por el usuario

## Fases
- [x] Setup: branch `revision/2026-08-27`, `_REVISION/` creado — 23:57:56 → 23:59 (~1m)
- [x] Ronda 1 · A1 INVENTARIO — 23:57:56 → 00:18:40 (~21m). 543 filas (538 individuales + 5 dataset-agregado). 0 FALLA, 8 NO COMPROBABLE. Hallazgos: 140 archivos con hash duplicado (123 en `Articulo de conferencia/codigos y base original/` = copia casi completa de CODIGOS/PERSONA SANA/REFERENCIAS/SIMULADOR; 7 en CALIBRACION/EJEMPLO_PRUEBA); Sudeesh2024.pdf ahora SÍ tiene capa de texto (contradice bloqueo 403 documentado en CLAUDE.md — para A5); tensión interna en CLAUDE.md sobre revista JTEHM "vigente" vs "sin decidir" tras pivote (para A4); `CODIGOS/GENERADOR/RODILLA/Fukuchi/` nueva, sin gitignore.
- [x] Ronda 1 · A2 GRAFO — 00:18:40 → 00:31:28 (~13m). ~230 vínculos, 1 ROTO (`\includegraphics{figuras/spm1d_comparacion3_subjectN.png}` en manuscrito_JTEHM.tex:397, comentado), 6 huérfanos genuinos (destaca `GRF_Newton_ApoyoSimple_Core.m` nuevo de hoy, sin llamador ni mención). Confirmado: sin vínculo de código activo entre proyecto principal y `Articulo de conferencia/codigos y base original/`. Flujo GENERADOR→CSV→simulador NO encadenado en producción, solo en `Test_Generador_Trayectoria.m` (datos sintéticos). Bibliografía: 10/10 claves citadas resuelven en .bib, solo 2/10 tienen PDF (Sudeesh2024, Piché2022).
- [~] Ronda 2 · A3 CÓDIGO — 1er intento 00:31→~02:20 FALLÓ (rate limit de sesión, HTTP 429, sin escribir archivo). Relanzado 02:21.
- [~] Ronda 2 · A4 REDACCIÓN — 1er intento 00:31→~02:20 FALLÓ (rate limit de sesión, HTTP 429, sin escribir archivo). Relanzado 02:21.
- [~] Ronda 2 · A5 FUENTES — 1er intento 00:31→~02:20 FALLÓ (rate limit de sesión, HTTP 429, sin escribir archivo). Relanzado 02:21.
- [~] Ronda 2 · A6 DATOS — 1er intento 00:31→~02:20 FALLÓ (rate limit de sesión, HTTP 429, sin escribir archivo). Relanzado 02:21.
- [ ] Ronda 3 · Justificación (07)
- [ ] Ronda 3 · Hallazgos (08)
- [ ] Ronda 3 · REVISION.md final
- [ ] Commit final + FIN DEL LOOP

## Sub-tareas por carpeta de primer nivel (para A1/A2 y para checklist de cobertura)
- [ ] Articulo de conferencia/  (proyecto separado, ver su propio CLAUDE.md — no mezclar argumentos con el Q2)
- [ ] CODIGOS/
- [ ] docs/
- [ ] PERSONA SANA/
- [ ] REFERENCIAS/
- [ ] SIMULADOR/
- [ ] raíz (CLAUDE.md, .gitignore, TESIS AGUILAR - GONZALES.pdf)

## Notas de ejecución
- Repo tiene cambios sin commitear preexistentes (ver `git status` al inicio) — no se tocan,
  no se agregan al commit de `_REVISION/`.
- No se toca nada modificado en los últimos 7 días (regla dura 5) — filtrar en A1/A2 por fecha
  de modificación antes de proponer BORRAR.
