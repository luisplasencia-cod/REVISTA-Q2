# 01 · Inventario — Revisión profunda 2026-08-27/28

> Generado por el subagente A1·INVENTARIO. Rama `revision/2026-08-27`. Comandos usados: `git ls-files`/`git status --porcelain`/`git check-ignore` (solo lectura), `find`, `du -sh`, `sha256sum`/hashlib.sha256, `mlint.exe` standalone (`C:\Program Files\MATLAB\R2025b\bin\win64\mlint.exe`, analisis estatico, sin abrir MATLAB), `pdftotext` (poppler, via mingw64), `python3.14` stdlib (`zipfile`, `json`, `csv`, `py_compile`, `hashlib`) para validar `.xlsx`/`.docx`/`.zip`/`.json`/`.csv`/`.py`. Ningún script del proyecto (`.m`, notebooks) fue ejecutado. `_REVISION/` y `.git/` quedan fuera del inventario (son la propia infraestructura de esta revisión, no contenido del proyecto).

## 1. Perfil del proyecto

**Qué es.** Simulador biomecánico de 3 grados de libertad (horizontal, vertical, sagital) para evaluación experimental de prótesis transtibiales, Laboratorio LIBRA — PUCP. DOCUMENTADO (`CLAUDE.md:29`): *"Simulador biomecánico de 3 grados de libertad (horizontal, vertical, sagital) para evaluación experimental de prótesis transtibiales, desarrollado en el Laboratorio LIBRA — PUCP."*

**Dos artículos, un repositorio.** El repo contiene dos líneas de trabajo editorialmente independientes: (a) el artículo Q2/JTEHM en curso, cuyo contexto vive en `CLAUDE.md` (raíz); (b) `Articulo de conferencia/` — el levantamiento de observaciones del paper de conferencia IBITeC 2026, ya enviado, con su propio `Articulo de conferencia/CLAUDE.md`. DOCUMENTADO (`CLAUDE.md:3-5`, banner de alcance): *"La carpeta `Articulo de conferencia/` es un trabajo aparte y no relacionado... Si la sesión es sobre eso, leer ese archivo y no aplicar nada de este."* Este inventario cataloga ambas carpetas (regla del orquestador: "solo inventaríala, no la mezcles conceptualmente"), sin fusionar sus decisiones. `Articulo de conferencia/codigos y base original/` es una copia casi completa de `CODIGOS/`, `PERSONA SANA/`, `REFERENCIAS/`, `SIMULADOR/` de la raíz — confirmado por hash: 109 archivos de esa subcarpeta tienen el mismo SHA-256 que su contraparte en la raíz (ver hallazgo en la sección de duplicados, más abajo). INFERIDO a partir de comparación de hashes, no de un `.md` que lo declare explícitamente.

**Pivote de fondo, vigente.** El artículo Q2 abandonó el enfoque de "reproducir fielmente una trayectoria pregrabada" y pasó a "generar la trayectoria desde antropometría, validar contra bases públicas". DOCUMENTADO (`CLAUDE.md:9`): *"PIVOTE DE FONDO — 19-ago-2026, decisión de reunión de equipo."* Este pivote es la razón de ser de casi todo `CODIGOS/GENERADOR/` (no existía antes del 19-ago-2026 según el propio historial del archivo). Checkpoint interno: 14-set-2026, "buen avance en implementación" (no manuscrito terminado) — DOCUMENTADO (`CLAUDE.md:21`).

**Tecnologías y formatos presentes** (INFERIDO de la extensión de archivo, ver tabla §2):
- **MATLAB/Octave** (`.m`, 101 archivos individuales catalogados + los toolboxes/datasets de terceros agregados) — el lenguaje dominante del proyecto. Patrón de nombre reconocible: `*_Core.m` (motor de cálculo sin diálogos), `Test_*.m` (pruebas con datos sintéticos), `Evaluar_*`/`Cargar_*`/`DIAG_*` (scripts de análisis por dataset), `Generar_Trayectoria.m`/`Escribir_CSV_Simulador.m` (puntos de entrada del generador).
- **LaTeX** (`.tex`, 6 archivos; `.bib`, 2; `.cls`, 1 — `IEEEJERM.cls`, clase oficial de la revista IEEE JTEHM) — el manuscrito vive en `docs/manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` y hay un segundo `.tex` en `docs/algoritmo/informe_tecnico_generador/`.
- **Python auxiliar** (9 `.py` + 1 `.pyc` de caché) — todos dentro de `.claude/skills/matlab/scripts/` (scripts del skill de Claude Code, no del pipeline científico) salvo `CODIGOS/GENERADOR/RODILLA/Kuopio/extraer_kuopio.py` (extracción de ese dataset).
- **Datos**: `.csv` (203), `.mat` (14 individuales + cientos agregados en los datasets de terceros), `.xlsx`/`.docx` (4), `.json` (4, todos config del skill salvo los agregados de Ferber), `.txt` (67, logs y datos crudos).
- **Figuras**: `.png` (42) + 1 `.jpeg`.
- **Documentación**: `.md` (64 archivos individuales — el patrón dominante del proyecto).
- **Archivos comprimidos**: `.zip` (5) — datasets de terceros o extractos de literatura.

**Convención propia detectada — patrón Core/Test/GUIA_INTERPRETACION.md.** Cada carpeta de análisis de `CODIGOS/` sigue el mismo patrón: un `*_Core.m` sin diálogos (motor), un `Test_*.m` con datos sintéticos, y un `GUIA_INTERPRETACION.md` que explica cómo leer los resultados con literatura de respaldo. DOCUMENTADO (`CLAUDE.md:139`): *"Regla que queda establecida: ninguna carpeta de análisis se queda sin su propio `GUIA_INTERPRETACION.md`."* y (`CLAUDE.md:140`, sobre `VALIDACIONES/`): *"`Calcular_Metricas_Curva.m` extrae... a una función reutilizable con interfaz más simple."* Confirmado en el inventario: existen `GUIA_INTERPRETACION.md` en `CODIGOS/CALIBRACION/`, `CODIGOS/ESTADISTICA/`, `CODIGOS/MULTISUJETO/`, `CODIGOS/POTENCIA_EQUIVALENCIA/`, `CODIGOS/VALIDACIONES/`, `CODIGOS/GENERADOR/`. Las subcarpetas más nuevas de `GENERADOR/` (`RODILLA/`, `TOBILLO/`, `INCLINACION_TIBIAL/`) usan una variante — `CIERRE_<NOMBRE>.md` en vez de `GUIA_INTERPRETACION.md` — mismo rol documental. INFERIDO de la tabla de archivos.

**Puntos de entrada identificados** (INFERIDO de nombre/rol):
- `CLAUDE.md` (raíz) — documento de contexto, se lee al iniciar sesión.
- `docs/DISCUSION_Q2.md` — DOCUMENTADO (`CLAUDE.md`, sección de documentos) como "el único documento de interacción" del ciclo Q2.
- `CODIGOS/GENERADOR/Generar_Trayectoria.m` + `Escribir_CSV_Simulador.m` — el generador de trayectorias en sí (entrada antropometría → salida CSV que lee el simulador real).
- `CODIGOS/GENERADOR/Test_Generador_Trayectoria.m`, `Test_Generador.m`, `Test_Combinar_Candidatos.m`, `Test_RomeroSorozabal.m` — suites de prueba con datos sintéticos.
- `docs/manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` — el manuscrito en curso, compila junto con `IEEEJERM.cls` y `references.bib` (mismo directorio).
- `Articulo de conferencia/` tiene su propio `CLAUDE.md` como punto de entrada — no leído en profundidad por este subagente (fuera de alcance según regla del orquestador), solo catalogado como archivo.

**Documentos principales** (INFERIDO de `CLAUDE.md`, lista de "Documentos de referencia"): `docs/ESTADO_Y_RUMBO.md` (documento maestro), `docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` (plan vigente desde el pivote, `CLAUDE.md:16`), `docs/algoritmo/*` (diseño matemático del generador y cierres por segmento anatómico), `docs/manuscrito/referencias_verificadas.md` (control de bibliografía).

**Formatos/archivos que no se pudieron comprobar del todo, y por qué:**
- `.cls` (`IEEEJERM.cls`) — NO COMPROBABLE: es una clase LaTeX de terceros (paquete oficial de IEEE), no hay validador de sintaxis LaTeX instalado sin red ni sin compilar el documento completo (fuera de alcance, regla 9 prohíbe ejecutar/compilar).
- `.lock` (`.claude/scheduled_tasks.lock`) y `.pyc` (`.claude/skills/matlab/scripts/__pycache__/_common.cpython-314.pyc`) — NO COMPROBABLE: artefactos de runtime de la propia herramienta Claude Code / caché de Python, no son contenido del proyecto de investigación; no trackeados por git.
- `mlint.exe` standalone SÍ estuvo disponible y SÍ se pudo invocar en modo solo-análisis (confirmado con un archivo inexistente, que devolvió un error legible, y con archivos reales, que devolvieron avisos de estilo) — se usó para los 92 archivos `.m` individuales. No se intentó sobre los `.m` dentro de los datasets de terceros agregados (serían cientos, fuera del alcance de "no catalogar dataset agregado archivo por archivo").
- `bibtexparser` (Python) no está instalado en esta máquina y no se instaló (regla 9, sin red) — la validación de `.bib` se hizo con un chequeo manual de balance de llaves `{`/`}`, más conteo de entradas `@`, no un parseo BibTeX real.
- PDFs grandes (`Sudeesh 2024.pdf`, 12.2MB) — no se leyeron completos (regla 10/12); se usó `pdftotext` únicamente para confirmar apertura, capa de texto y una estimación de nº de páginas por conteo de form-feed, descartando el texto extraído sin imprimirlo.

**Hallazgo relevante para el propio inventario (no evaluado por A1, reportado para las siguientes fases):** `docs/literatura/pdfs/Sudeesh 2024.pdf` ya existe en el repo (sin trackear, agregado el 27-ago-2026 según `mtime`) con capa de texto extraíble (~13 páginas, 46,672 caracteres). `CLAUDE.md` (sección "Qué falta, en orden de palanca", 23-ago-2026) documentaba ese PDF como bloqueado por error 403 de ScienceDirect. Con evidencia de que el archivo ahora abre y tiene texto, ese bloqueo parece superado — dato para que A2 (consistencia) o A5 (bibliografía) lo verifiquen y lo reflejen si corresponde; A1 no interpreta el contenido, solo reporta que el archivo es legible.

## 2. Inventario completo

### 2.1 Carpetas de datasets públicos agregadas (5 filas — no catalogadas archivo por archivo, por regla de alcance)

| ruta | tipo | tamaño | última modificación | hash (o "agregado, N archivos") | trackeado git (sí/no) | categoría | comprobación |
|---|---|---|---|---|---|---|---|
| `CODIGOS/GENERADOR/RODILLA/Ferber/muestra40_raw/` | dataset (json) | 997M | (multiples fechas, dataset descargado) | agregado, 40 archivos | no (0/40 trackeados; excluido via .gitignore: CODIGOS/GENERADOR/RODILLA/Ferber/muestra40_raw/) | dataset-público-agregado | NO COMPROBABLE: carpeta agregada por regla de alcance (dataset publico de terceros, decenas/cientos de archivos) — no se abrio archivo por archivo. Contenido: Muestra de 40 sujetos de Ferber et al. 2024 (Running Injury Clinic Kinematic Dataset, Figshare+, CC BY 4.0), un .json crudo por sujeto/sesion. Dataset publico de referencia (rodilla), no se cataloga archivo por archivo. Ver CODIGOS/GENERADOR/RODILLA/Ferber/Cargar_Ferber2024_Core.m y docs/algoritmo/busqueda_modelos_antropometria_rodilla.md para como regenerar la muestra (muestra_40.csv, que SI se versiona, catalogado individualmente abajo). |
| `CODIGOS/GENERADOR/RODILLA/Fukuchi/raw/` | dataset (txt/xlsx/csv/zip + subcarpeta WBDSascii) | 562M | (multiples fechas, dataset descargado) | agregado, 47 archivos | no (0/47 trackeados; no aparece en .gitignore explicitamente pero esta sin trackear igual, ver hallazgo en Perfil) | dataset-público-agregado | NO COMPROBABLE: carpeta agregada por regla de alcance (dataset publico de terceros, decenas/cientos de archivos) — no se abrio archivo por archivo. Contenido: Base de datos Fukuchi et al. 2018 (WBDS, marcha overground), formato ASCII original del publicador (WBDSascii.zip + carpeta descomprimida WBDSascii/ con un archivo por sujeto/condicion, WBDSinfo.xlsx/csv de metadatos, y un script .m del propio publicador wbdsExploratoryDA.m). Dataset publico de referencia (rodilla), no se cataloga archivo por archivo. Codigo propio que lo consume (Cargar_Fukuchi2018_Core.m y los Evaluar_*.m) esta fuera de esta carpeta raw/ y SI se cataloga individualmente abajo. |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/raw/` | dataset (csv/xlsx) | 1.3M | (multiples fechas, dataset descargado) | agregado, 47 archivos | si (47/47 trackeados en git) | dataset-público-agregado | NO COMPROBABLE: carpeta agregada por regla de alcance (dataset publico de terceros, decenas/cientos de archivos) — no se abrio archivo por archivo. Contenido: Base de datos Kuopio 2024 (N=15, marcha overground real), 3 ensayos comfortable-speed por sujeto (nn_l_comf_0X.csv) mas info_participants.xlsx y subjects_meta.csv de antropometria/velocidad medida. Dataset publico de referencia (rodilla/tobillo/angulo tibial — es la base de validacion principal del generador segun CLAUDE.md sesion 25-ago-2026). Pese a ser pequeno en tamano, tiene decenas de archivos (47) de un dataset publico -> se agrega en una sola fila por consistencia con el resto de datasets de esta tabla. Codigo propio que lo consume esta fuera de raw/ y SI se cataloga individualmente. |
| `docs/literatura/pdfs/camargo2021_piloto/` | dataset (csv/mat/otros, estructura OpenSim) | 1.3G | (multiples fechas, dataset descargado) | agregado, 1722 archivos | no (0/1722 trackeados; excluido via .gitignore: docs/literatura/pdfs/camargo2021_piloto/) | dataset-público-agregado | NO COMPROBABLE: carpeta agregada por regla de alcance (dataset publico de terceros, decenas/cientos de archivos) — no se abrio archivo por archivo. Contenido: 2 sujetos piloto (AB06, AB09) de Camargo et al. 2021 — marcadores 3D crudos + angulos IK de OpenSim + metadatos. Es la base de validacion externa 'de examen final' del generador (no participa en construirlo, ver CLAUDE.md sesion 23-ago-2026). Dataset publico de referencia, no se cataloga archivo por archivo. Cargador propio: CODIGOS/GENERADOR/Cargar_Camargo_Core.m (catalogado individualmente abajo). Ver CODIGOS/GENERADOR/GUIA_INTERPRETACION.md para el detalle de como se descarga (Dropbox del EPIC Lab, AB06.zip/AB09.zip tambien gitignored). |
| `docs/literatura/pdfs/yun2014_toolbox/` | toolbox de terceros (codigo .m + .mat + .png de ejemplo) | 7.1M | (multiples fechas, dataset descargado) | agregado, 149 archivos | parcial (118/149 trackeados; el resto excluido via .gitignore: *.mat de la base KIST empaquetada, artefactos de salida de correr Gait_Pred.m) | dataset-público-agregado | NO COMPROBABLE: carpeta agregada por regla de alcance (dataset publico de terceros, decenas/cientos de archivos) — no se abrio archivo por archivo. Contenido: Toolbox MATLAB de terceros 'Gait_Kinematics_Prediction' (Yun et al. 2014, SourceForge) — codigo fuente del propio paquete publicado, no escrito por el equipo. Incluye la base KIST Human Gait Pattern Data (los .mat de datos, gitignored por licencia que prohibe redistribucion). Codigo/dataset de terceros, no se cataloga archivo por archivo (~cientos de archivos, ninguno es trabajo propio del equipo). El wrapper propio que lo usa es CODIGOS/GENERADOR/Yun2014_Wrapper.m, catalogado individualmente abajo. |

### 2.2 Todos los demás archivos (538 filas individuales)

Incluye: los 671 archivos trackeados por git en su totalidad **menos** los que caen dentro de las 5 carpetas agregadas de arriba (165 de esos 671 sí están trackeados: 47 de `Kuopio/raw/` + 118 de `yun2014_toolbox/`) **menos** `_REVISION/PROGRESO.md` (excluido del inventario por ser la propia infraestructura de esta revisión, no contenido del proyecto) — más 33 archivos sueltos sin trackear que no pertenecen a ninguna carpeta de dataset agregada (sesión del 27-ago-2026 en curso, según `git status --porcelain`: nuevos scripts/resultados de `INCLINACION_TIBIAL/`, `TOBILLO/`, `MasaSegmentaria_DeLeva1996_Core.m`, `GRF_Newton_ApoyoSimple_Core.m`, la carpeta nueva `docs/algoritmo/informe_tecnico_generador/`, PDFs y un `.zip` nuevos en `docs/literatura/pdfs/`, y `docs/planificacion/analisis_revistas_Q1_generador.md`). Total: 505 + 33 = 538.

Columnas: `ruta | tipo | tamaño | última modificación | hash | trackeado git | categoría | comprobación`. Hash truncado a 12 caracteres por legibilidad de tabla (el hash completo SHA-256 se calculó para las 538 filas; disponible en el TSV intermedio si se necesita el valor completo — no se adjunta aquí para no duplicar ~35KB de hashes en el documento).

| ruta | tipo | tamaño | última modificación | hash | trackeado git | categoría | comprobación |
|---|---|---|---|---|---|---|---|
| `.claude/scheduled_tasks.lock` | .lock | 124B | 2026-08-28 00:02:36 | `27d3ee5fd9ec…` | no | config | NO COMPROBABLE: sin validador aplicable para .lock |
| `.claude/settings.local.json` | .json | 3.8KB | 2026-08-16 22:18:15 | `de38a2637d75…` | no | config | OK (JSON valido) |
| `.claude/skills/matlab/assets/project_manifest_template.json` | .json | 756B | 2026-07-31 15:02:30 | `32a255f6b8f5…` | si | config | OK (JSON valido) |
| `.claude/skills/matlab/assets/python_compatibility_r2026a.json` | .json | 813B | 2026-07-31 15:02:30 | `7d5aceb92476…` | si | config | OK (JSON valido) |
| `.claude/skills/matlab/assets/reproducibility_manifest_template.json` | .json | 819B | 2026-07-31 15:02:30 | `16e8e002a0e4…` | si | config | OK (JSON valido) |
| `.claude/skills/matlab/references/data-import-export.md` | .md | 8.8KB | 2026-07-31 15:02:30 | `6543c5c3db98…` | si | documento-planificación | OK (utf-8 valido) |
| `.claude/skills/matlab/references/executing-scripts.md` | .md | 9.8KB | 2026-07-31 15:02:30 | `f2ee2a4d207e…` | si | documento-planificación | OK (utf-8 valido) |
| `.claude/skills/matlab/references/graphics-visualization.md` | .md | 7.4KB | 2026-07-31 15:02:30 | `a41f09d37dbb…` | si | documento-planificación | OK (utf-8 valido) |
| `.claude/skills/matlab/references/mathematics.md` | .md | 8.3KB | 2026-07-31 15:02:30 | `d961121f6d12…` | si | documento-planificación | OK (utf-8 valido) |
| `.claude/skills/matlab/references/matrices-arrays.md` | .md | 8.2KB | 2026-07-31 15:02:30 | `f1a38a4c9d79…` | si | documento-planificación | OK (utf-8 valido) |
| `.claude/skills/matlab/references/octave-compatibility.md` | .md | 8.5KB | 2026-07-31 15:02:30 | `9e886a9c8ede…` | si | documento-planificación | OK (utf-8 valido) |
| `.claude/skills/matlab/references/programming.md` | .md | 10.3KB | 2026-07-31 15:02:30 | `9efb403427c9…` | si | documento-planificación | OK (utf-8 valido) |
| `.claude/skills/matlab/references/python-integration.md` | .md | 9.9KB | 2026-07-31 15:02:30 | `9483c097d612…` | si | documento-planificación | OK (utf-8 valido) |
| `.claude/skills/matlab/scripts/__pycache__/_common.cpython-314.pyc` | .pyc | 17.6KB | 2026-08-13 13:04:50 | `04cebc55b034…` | no | otro | NO COMPROBABLE: bytecode Python compilado, sin valor de auditoria de fuente |
| `.claude/skills/matlab/scripts/_common.py` | .py | 8.8KB | 2026-07-31 15:02:30 | `e2b9035222dd…` | si | código | OK (py_compile: sintaxis valida) |
| `.claude/skills/matlab/scripts/generate_function_scaffold.py` | .py | 5.0KB | 2026-07-31 15:02:30 | `60f19acc40c5…` | si | código | OK (py_compile: sintaxis valida) |
| `.claude/skills/matlab/scripts/inventory_mat_file.py` | .py | 12.4KB | 2026-07-31 15:02:30 | `3b9cb905bae4…` | si | código | OK (py_compile: sintaxis valida) |
| `.claude/skills/matlab/scripts/plan_batch_command.py` | .py | 9.0KB | 2026-07-31 15:02:30 | `e4e675f194b8…` | si | código | OK (py_compile: sintaxis valida) |
| `.claude/skills/matlab/scripts/plan_python_compatibility.py` | .py | 6.6KB | 2026-07-31 15:02:30 | `6149380aaee6…` | si | código | OK (py_compile: sintaxis valida) |
| `.claude/skills/matlab/scripts/reproducibility_report.py` | .py | 8.0KB | 2026-07-31 15:02:30 | `142114a075a0…` | si | código | OK (py_compile: sintaxis valida) |
| `.claude/skills/matlab/scripts/scan_m_code.py` | .py | 14.0KB | 2026-07-31 15:02:30 | `9698886b8c28…` | si | código | OK (py_compile: sintaxis valida) |
| `.claude/skills/matlab/scripts/validate_project_manifest.py` | .py | 12.3KB | 2026-07-31 15:02:30 | `27bb5b0a1b24…` | si | código | OK (py_compile: sintaxis valida) |
| `.claude/skills/matlab/SKILL.md` | .md | 14.2KB | 2026-07-31 15:02:30 | `53947c18dade…` | si | documento-planificación | OK (utf-8 valido) |
| `.gitignore` | (sin ext) | 2.1KB | 2026-08-24 20:56:20 | `3fb9a71edf7c…` | si | otro | OK (utf-8 valido, regla comentada revisada aparte) |
| `Articulo de conferencia/_2026__Articulo_conferencia_Simulador_de_marcha_para_prótesis_versión_2.pdf` | .pdf | 3.8MB | 2026-08-06 19:21:39 | `400ab9328745…` | si | otro | OK (abre, capa de texto SI, ~7 paginas segun form-feed, 29390 caracteres extraidos) |
| `Articulo de conferencia/ANALISIS_OBSERVACIONES.md` | .md | 24.8KB | 2026-08-06 17:27:36 | `535ef58a1ad7…` | si | documento-planificación | OK (utf-8 valido) |
| `Articulo de conferencia/articulo corregido.md` | .md | 34.9KB | 2026-08-09 23:30:02 | `1a9c6e6500cd…` | si | documento-planificación | OK (utf-8 valido) |
| `Articulo de conferencia/articulo original.md` | .md | 32.3KB | 2026-08-06 13:41:13 | `adc7fa5f3545…` | si | documento-planificación | OK (utf-8 valido) |
| `Articulo de conferencia/CLAUDE.md` | .md | 39.9KB | 2026-08-10 22:09:20 | `8d409b4d418f…` | si | documento-planificación | OK (utf-8 valido) |
| `Articulo de conferencia/codigos figura 5/Fig5_Datos_Fuerza.m` | .m | 7.9KB | 2026-08-09 15:08:23 | `737170510f0d…` | si | código | OK (mlint: 0 avisos) |
| `Articulo de conferencia/codigos figura 5/Fig5_datos_fuerza.mat` | .mat | 6.8KB | 2026-08-09 18:01:09 | `0902e47c32c7…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `Articulo de conferencia/codigos figura 5/Fig5_Datos_Plataforma.m` | .m | 5.7KB | 2026-08-09 18:02:49 | `cb22a06adb42…` | si | código | OK (mlint: 0 avisos) |
| `Articulo de conferencia/codigos figura 5/Fig5_datos_plataforma.mat` | .mat | 13.2KB | 2026-08-09 18:14:28 | `7f98728c9ab9…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `Articulo de conferencia/codigos figura 5/Fig5_Generar.m` | .m | 10.9KB | 2026-08-09 21:01:41 | `df3744278090…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `Articulo de conferencia/codigos figura 5/fig5_revisada.pdf` | .pdf | 40.0KB | 2026-08-09 21:01:51 | `397240296bc9…` | si | otro | OK (abre, capa de texto SI, ~2 paginas segun form-feed, 569 caracteres extraidos) |
| `Articulo de conferencia/codigos figura 5/fig5_revisada.png` | .png | 362.5KB | 2026-08-09 21:01:51 | `b155c2ebea1b…` | si | figura | OK (firma PNG valida) |
| `Articulo de conferencia/codigos figura 5/Verificar_Replica.m` | .m | 1.7KB | 2026-08-09 15:09:37 | `843cb0dfc4a1…` | si | código | OK (mlint: 0 avisos) |
| `Articulo de conferencia/codigos y base original/CODIGOS/GENERAR CURVS DE REFERENCIA/Angulo_Control_Plataforma.m` | .m | 14.2KB | 2026-07-22 17:32:12 | `4da6a4d213ea…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `Articulo de conferencia/codigos y base original/CODIGOS/GENERAR CURVS DE REFERENCIA/Base_Datos_GRF.m` | .m | 10.8KB | 2026-05-30 15:44:30 | `a1efdb95c4bf…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `Articulo de conferencia/codigos y base original/CODIGOS/GENERAR CURVS DE REFERENCIA/Desplazamientos.m` | .m | 30.3KB | 2026-06-29 01:24:54 | `f62adac80dad…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `Articulo de conferencia/codigos y base original/CODIGOS/VALIDACIONES/Validacion_Fuerza.m` | .m | 24.1KB | 2026-06-30 14:22:53 | `0b2037b821fd…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `Articulo de conferencia/codigos y base original/CODIGOS/VALIDACIONES/Validacion_Plataforma.m` | .m | 18.8KB | 2026-06-27 15:01:48 | `0647410127cc…` | si | código | OK (mlint: 0 avisos) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_10_OF.csv` | .csv | 18.3KB | 2026-06-26 15:59:47 | `930ffe5b43fb…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_1_OF.csv` | .csv | 19.5KB | 2026-06-26 14:21:05 | `1e32eb144a94…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_2_OF.csv` | .csv | 18.5KB | 2026-06-26 14:25:02 | `4cc5c44359fc…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_3_OF.csv` | .csv | 18.8KB | 2026-06-26 14:29:40 | `39e461d2554c…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_4_OF.csv` | .csv | 19.1KB | 2026-06-26 14:59:06 | `234ac2ec5660…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_5_OF.csv` | .csv | 18.4KB | 2026-06-26 15:47:28 | `cf0df92d8c24…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_6_OF.csv` | .csv | 18.2KB | 2026-06-26 15:51:08 | `50c09b4b7290…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_7_OF.csv` | .csv | 18.0KB | 2026-06-26 15:53:54 | `5b6f64945144…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_8_OF.csv` | .csv | 18.5KB | 2026-06-26 15:58:06 | `59060c9650b7…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_9_OF.csv` | .csv | 18.3KB | 2026-06-26 15:59:39 | `930ffe5b43fb…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_10_OF.csv` | .csv | 2.0KB | 2026-06-26 16:00:01 | `5656f9a30dfe…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_1_OF.csv` | .csv | 2.1KB | 2026-06-26 14:21:24 | `d5f97623a758…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_2_OF.csv` | .csv | 2.0KB | 2026-06-26 14:26:10 | `bb78cec82767…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_3_OF.csv` | .csv | 2.0KB | 2026-06-26 14:29:53 | `fa81bbf3bacf…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_4_OF.csv` | .csv | 2.1KB | 2026-06-26 15:04:37 | `b4883768f22b…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_5_OF.csv` | .csv | 2.0KB | 2026-06-26 15:47:43 | `976410c6971a…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_6_OF.csv` | .csv | 2.0KB | 2026-06-26 15:51:33 | `a67f6ff42377…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_7_OF.csv` | .csv | 1.9KB | 2026-06-26 15:54:08 | `096b61a08e62…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_8_OF.csv` | .csv | 2.0KB | 2026-06-26 15:56:35 | `acdc932a81f2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_9_OF.csv` | .csv | 2.0KB | 2026-06-26 15:57:51 | `acdc932a81f2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_10_OF.csv` | .csv | 2.2KB | 2026-06-26 16:00:16 | `d92ba498408b…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_1_OF.csv` | .csv | 2.3KB | 2026-06-26 14:21:48 | `a823c0d006d7…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_2_OF.csv` | .csv | 2.2KB | 2026-06-26 14:26:41 | `f2d0a8d4e173…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_3_OF.csv` | .csv | 2.3KB | 2026-06-26 14:30:04 | `033955cef619…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_4_OF.csv` | .csv | 2.3KB | 2026-06-26 15:04:47 | `5816747d1b41…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_5_OF.csv` | .csv | 2.2KB | 2026-06-26 15:48:02 | `83f6a17ec8df…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_6_OF.csv` | .csv | 2.2KB | 2026-06-26 15:51:45 | `6fcfd26285c5…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_7_OF.csv` | .csv | 2.2KB | 2026-06-26 15:54:21 | `63b2c834308f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_8_OF.csv` | .csv | 2.2KB | 2026-06-26 15:57:40 | `a43692e1372d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_9_OF.csv` | .csv | 2.2KB | 2026-06-26 16:00:11 | `d92ba498408b…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_11_OF.csv` | .csv | 11.1KB | 2026-06-29 00:47:23 | `56e608661f00…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_12_OF.csv` | .csv | 10.3KB | 2026-06-29 00:51:21 | `40e953577cd2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_13_OF.csv` | .csv | 10.2KB | 2026-06-29 00:54:22 | `0739c7420e4c…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_14_OF.csv` | .csv | 10.6KB | 2026-06-29 00:57:27 | `944c0f5ecbfa…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_15_OF.csv` | .csv | 11.3KB | 2026-06-29 01:00:12 | `dc7954c079a7…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_16_OF.csv` | .csv | 11.0KB | 2026-06-29 01:05:02 | `551161e1f72f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_17_OF.csv` | .csv | 11.0KB | 2026-06-29 01:05:15 | `551161e1f72f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_18_OF.csv` | .csv | 11.8KB | 2026-06-29 01:07:37 | `cd1f51f3cc44…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_19_OF.csv` | .csv | 10.2KB | 2026-06-29 01:10:19 | `56d9ceb5fbef…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_20_OF.csv` | .csv | 10.2KB | 2026-06-29 01:10:32 | `56d9ceb5fbef…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_11_OF.csv` | .csv | 1.2KB | 2026-06-29 00:47:57 | `5ed24ce5adda…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_12_OF.csv` | .csv | 1.1KB | 2026-06-29 00:51:49 | `e521051ab8b2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_13_OF.csv` | .csv | 1.1KB | 2026-06-29 00:54:43 | `d2543ae9f710…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_14_OF.csv` | .csv | 1.1KB | 2026-06-29 00:57:47 | `523a55f5ff96…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_15_OF.csv` | .csv | 1.2KB | 2026-06-29 01:00:29 | `cfa9efe0976d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_16_OF.csv` | .csv | 1.2KB | 2026-06-29 01:05:51 | `fc66aa891a66…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_17_OF.csv` | .csv | 1.2KB | 2026-06-29 01:06:01 | `fc66aa891a66…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_18_OF.csv` | .csv | 1.3KB | 2026-06-29 01:07:50 | `c8211b617d3b…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_19_OF.csv` | .csv | 1.1KB | 2026-06-29 00:57:47 | `523a55f5ff96…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_20_OF.csv` | .csv | 1.2KB | 2026-06-29 01:00:29 | `cfa9efe0976d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_11_OF.csv` | .csv | 1.2KB | 2026-06-29 00:48:09 | `9bf903ea66ac…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_12_OF.csv` | .csv | 1.1KB | 2026-06-29 00:52:02 | `917ca9b69b43…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_13_OF.csv` | .csv | 1.1KB | 2026-06-29 00:55:26 | `5d2772dde515…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_14_OF.csv` | .csv | 1.2KB | 2026-06-29 00:58:09 | `cd4f56df0204…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_15_OF.csv` | .csv | 1.2KB | 2026-06-29 01:00:41 | `0b69454e2512…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_16_OF.csv` | .csv | 1.2KB | 2026-06-29 01:03:23 | `d39a47c5fb7a…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_17_OF.csv` | .csv | 1.3KB | 2026-06-29 01:08:03 | `3991b3caec97…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_18_OF.csv` | .csv | 1.3KB | 2026-06-29 01:08:09 | `3991b3caec97…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_19_OF.csv` | .csv | 1.3KB | 2026-06-29 01:08:16 | `3991b3caec97…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_20_OF.csv` | .csv | 1.1KB | 2026-06-29 01:10:50 | `996ea5d5e898…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00926.txt` | .txt | 606.1KB | 2026-06-30 13:26:16 | `787ec39e2a1a…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00927.txt` | .txt | 605.8KB | 2026-06-30 13:26:16 | `4baffc8739ef…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00928.txt` | .txt | 606.0KB | 2026-06-30 13:26:16 | `a2cfc7c12c37…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00929.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `4b4215237597…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00930.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `b3a1759cc671…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00931.txt` | .txt | 605.8KB | 2026-06-30 13:26:16 | `5f1887ef3760…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00932.txt` | .txt | 605.5KB | 2026-06-30 13:26:16 | `aa5a680d09d7…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00933.txt` | .txt | 605.8KB | 2026-06-30 13:26:16 | `8a69ea8bdb81…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00934.txt` | .txt | 605.5KB | 2026-06-30 13:26:16 | `f9328e7ca2b4…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00935.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `6a1c53fe52c6…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00936.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `688811b6410e…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00937.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `6bc8c73229a5…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00938.txt` | .txt | 606.1KB | 2026-06-30 13:26:16 | `c351920930b2…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00939.txt` | .txt | 606.0KB | 2026-06-30 13:26:16 | `f428b0d23343…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00940.txt` | .txt | 606.0KB | 2026-06-30 13:26:16 | `3ded3ae6df7c…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00941.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `63ec66318fff…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00942.txt` | .txt | 605.6KB | 2026-06-30 13:26:16 | `acffa938afd4…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00943.txt` | .txt | 606.1KB | 2026-06-30 13:26:16 | `652b080b9b45…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/PERSONA SANA/FUERZA GRF/Trial00944.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `a05e4efb385e…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/BaseDatos_FuerzaVertical.mat` | .mat | 1.8KB | 2026-08-09 17:55:28 | `5f0b3ff0c124…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/BaseDatos_Plataforma_Apoyo.mat` | .mat | 3.4KB | 2026-08-09 18:08:18 | `43e0bde45e35…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/BaseDatos_Plataforma_Balanceo.mat` | .mat | 3.0KB | 2026-08-09 18:08:18 | `1b88a3774853…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/CurvaPromedio_Plataforma_Apoyo_0.010s_0.009deg.csv` | .csv | 1.3KB | 2026-08-09 18:08:18 | `ebe4867dd6bc…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/CurvaPromedio_Plataforma_Balanceo_0.010s_0.009deg.csv` | .csv | 812B | 2026-08-09 18:08:18 | `37653ff32d1e…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/X_Apoyo.csv` | .csv | 1.3KB | 2026-08-09 20:11:24 | `6a48548fa91a…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/X_Balanceo.csv` | .csv | 782B | 2026-08-09 20:11:24 | `03af12ad08fa…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/Y_Apoyo.csv` | .csv | 1.3KB | 2026-08-09 20:11:24 | `5e6daba1e7b8…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/REFERENCIAS/Y_Balanceo.csv` | .csv | 749B | 2026-08-09 20:11:24 | `72263a277d57…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_10_OF.csv` | .csv | 517.1KB | 2026-06-27 14:27:27 | `dc3e56dd11c4…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_1_OF.csv` | .csv | 427.4KB | 2026-06-27 14:31:52 | `6a0b5e4f5c4d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_2_OF.csv` | .csv | 523.6KB | 2026-06-27 11:39:02 | `049aebe00b5f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_3_OF.csv` | .csv | 520.7KB | 2026-06-27 11:55:51 | `6c924d29066f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_4_OF.csv` | .csv | 522.5KB | 2026-06-27 12:37:26 | `0daab224343f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_5_OF.csv` | .csv | 519.9KB | 2026-06-27 13:25:45 | `a7f5a229484a…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_6_OF.csv` | .csv | 523.3KB | 2026-06-27 14:00:10 | `e5bab760297f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_7_OF.csv` | .csv | 519.8KB | 2026-06-27 14:05:17 | `ce3083d79afc…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_8_OF.csv` | .csv | 522.6KB | 2026-06-27 14:09:50 | `d27bd3f5c493…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_9_OF.csv` | .csv | 514.3KB | 2026-06-27 14:15:14 | `4b92c16eab38…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_10_OF.csv` | .csv | 276.1KB | 2026-07-03 00:52:03 | `34c839d4ce9a…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_1_OF.csv` | .csv | 284.4KB | 2026-07-03 00:01:42 | `35b8cc8b5b1c…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_2_OF.csv` | .csv | 271.6KB | 2026-07-03 00:11:10 | `1c203fdf9e48…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_3_OF.csv` | .csv | 272.7KB | 2026-07-03 00:14:42 | `0728a868e9f6…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_4_OF.csv` | .csv | 270.4KB | 2026-07-03 00:22:24 | `e03aa7316098…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_5_OF.csv` | .csv | 271.6KB | 2026-07-03 00:29:32 | `b4977bf8cfd4…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_6_OF.csv` | .csv | 272.5KB | 2026-07-03 00:32:57 | `7e28002b864d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_7_OF.csv` | .csv | 274.5KB | 2026-07-03 00:36:10 | `7be6b6ee87a2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_8_OF.csv` | .csv | 272.4KB | 2026-07-03 00:40:30 | `fbc9ca0dab01…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_9_OF.csv` | .csv | 274.7KB | 2026-07-03 00:45:01 | `2319b3437e61…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00959.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `88485d2008d9…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00960.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `8dd51e0b8fad…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00961.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `0016a09d6279…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00962.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `9fe702811ec7…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00963.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `9e01562bc66b…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00964.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `99a06df33529…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00965.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `3b25f815779a…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00966.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `8dd51e0b8fad…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00967.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `0016a09d6279…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/codigos y base original/SIMULADOR/FUERZA GRF - SIM/Trial00968.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `9fe702811ec7…` | si | dato-crudo | OK (utf-8 valido) |
| `Articulo de conferencia/DISCUSION_COMENTARIOS.md` | .md | 242.0KB | 2026-08-09 22:27:39 | `7437880e3134…` | si | documento-planificación | OK (utf-8 valido) |
| `Articulo de conferencia/feedbacks y comentarios extra.md` | .md | 8.1KB | 2026-08-06 13:48:41 | `6f60fb705854…` | si | documento-planificación | OK (utf-8 valido) |
| `Articulo de conferencia/figuras_extraidas/Fig1_CAD.png` | .png | 1.7MB | 2026-08-06 19:29:20 | `8420a5f6bc79…` | si | figura | OK (firma PNG valida) |
| `Articulo de conferencia/figuras_extraidas/Fig4_setup.png` | .png | 2.0MB | 2026-08-06 19:29:20 | `effb9206af4a…` | si | figura | OK (firma PNG valida) |
| `Articulo de conferencia/figuras_extraidas/Fig5_resultados.jpeg` | .jpeg | 79.3KB | 2026-08-06 19:29:21 | `3fd96ed06050…` | si | figura | OK (firma JPEG valida) |
| `Articulo de conferencia/figuras_extraidas/fig_CAD_model.png` | .png | 502.8KB | 2026-08-06 23:06:04 | `848824bed89c…` | si | figura | OK (firma PNG valida) |
| `Articulo de conferencia/PDF_REVISAR (3).pdf` | .pdf | 1.8MB | 2026-08-09 23:22:03 | `a2738e5fc974…` | si | otro | OK (abre, capa de texto SI, ~7 paginas segun form-feed, 31483 caracteres extraidos) |
| `Articulo de conferencia/Response to reviewer's comments .pdf` | .pdf | 1.5MB | 2026-08-10 22:03:08 | `9292532cd693…` | si | otro | OK (abre, capa de texto SI, ~15 paginas segun form-feed, 31319 caracteres extraidos) |
| `Articulo de conferencia/RESPUESTA_REVISORES.md` | .md | 81.4KB | 2026-08-10 22:08:58 | `c61cfddec0b8…` | si | documento-planificación | OK (utf-8 valido) |
| `CLAUDE.md` | .md | 100.1KB | 2026-08-25 22:58:18 | `324f70e02678…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/Calibracion_Offset_Core.m` | .m | 18.3KB | 2026-07-31 17:25:55 | `45e46a4efead…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/CALIBRACION/Calibracion_Offset_Vertical.m` | .m | 2.0KB | 2026-07-31 17:01:36 | `85780c21e9e1…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/CALIBRACION/EJEMPLO_PRUEBA_NO_ES_DATO_REAL/Offset_145_1.txt` | .txt | 2.1MB | 2026-07-31 17:15:40 | `88485d2008d9…` | si | dato-crudo | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/EJEMPLO_PRUEBA_NO_ES_DATO_REAL/Offset_147_1.txt` | .txt | 2.1MB | 2026-07-31 17:15:40 | `8dd51e0b8fad…` | si | dato-crudo | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/EJEMPLO_PRUEBA_NO_ES_DATO_REAL/Offset_150_1.txt` | .txt | 2.1MB | 2026-07-31 17:15:40 | `0016a09d6279…` | si | dato-crudo | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/EJEMPLO_PRUEBA_NO_ES_DATO_REAL/Offset_152_1.txt` | .txt | 2.1MB | 2026-07-31 17:15:40 | `9fe702811ec7…` | si | dato-crudo | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/EJEMPLO_PRUEBA_NO_ES_DATO_REAL/Offset_155_1.txt` | .txt | 2.1MB | 2026-07-31 17:15:40 | `9e01562bc66b…` | si | dato-crudo | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/EJEMPLO_PRUEBA_NO_ES_DATO_REAL/Offset_157_1.txt` | .txt | 2.1MB | 2026-07-31 17:15:41 | `99a06df33529…` | si | dato-crudo | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/EJEMPLO_PRUEBA_NO_ES_DATO_REAL/Offset_160_1.txt` | .txt | 2.1MB | 2026-07-31 17:15:41 | `3b25f815779a…` | si | dato-crudo | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/GUIA_INTERPRETACION.md` | .md | 12.5KB | 2026-08-19 23:41:57 | `27936effcf88…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/CALIBRACION/Test_Calibracion_Offset.m` | .m | 5.6KB | 2026-07-31 17:03:35 | `1e2853b9b1f2…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/ESTADISTICA/Aplicar_SPM_BlandAltman_CurvasExistentes.m` | .m | 10.0KB | 2026-08-03 00:23:56 | `e5d6cf2eec15…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/ESTADISTICA/BlandAltman_Core.m` | .m | 10.9KB | 2026-08-02 18:36:07 | `644655064277…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/ESTADISTICA/Extraer_Features0D.m` | .m | 2.9KB | 2026-08-02 18:36:27 | `d78ed4461504…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/ESTADISTICA/GUIA_INTERPRETACION.md` | .md | 15.9KB | 2026-08-19 23:42:05 | `b8cd1404c241…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Angulo_Apoyo/spm1d_clusters.csv` | .csv | 246B | 2026-08-03 10:44:59 | `6a16aad8fba5…` | si | dato-procesado | OK (cabecera 6 columnas, consistente en muestra de 5 filas) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Angulo_Apoyo/spm1d_curva.csv` | .csv | 2.3KB | 2026-08-03 10:44:59 | `48a7ae316711…` | si | dato-procesado | OK (cabecera 2 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Angulo_Apoyo/spm1d_curva.png` | .png | 41.2KB | 2026-08-03 10:45:01 | `554a7d14035f…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Angulo_Apoyo/spm1d_resultado.mat` | .mat | 8.6KB | 2026-08-03 10:44:59 | `6dd4fa16afca…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Angulo_Balanceo/spm1d_clusters.csv` | .csv | 197B | 2026-08-03 10:45:02 | `f23d78540079…` | si | dato-procesado | OK (cabecera 6 columnas, consistente en muestra de 4 filas) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Angulo_Balanceo/spm1d_curva.csv` | .csv | 2.3KB | 2026-08-03 10:45:02 | `1a4fd416d082…` | si | dato-procesado | OK (cabecera 2 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Angulo_Balanceo/spm1d_curva.png` | .png | 49.8KB | 2026-08-03 10:45:03 | `02122660bc95…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Angulo_Balanceo/spm1d_resultado.mat` | .mat | 8.5KB | 2026-08-03 10:45:02 | `60a06209fb32…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Fz_Apoyo/spm1d_clusters.csv` | .csv | 138B | 2026-08-03 10:46:11 | `81dcc4e56785…` | si | dato-procesado | OK (cabecera 6 columnas, consistente en muestra de 3 filas) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Fz_Apoyo/spm1d_curva.csv` | .csv | 1.3KB | 2026-08-03 10:46:11 | `a2dd5ad0f904…` | si | dato-procesado | OK (cabecera 2 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Fz_Apoyo/spm1d_curva.png` | .png | 43.4KB | 2026-08-03 10:46:11 | `eaec121e5334…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/ESTADISTICA/Resultados_SPM1D_CurvasExistentes/Fz_Apoyo/spm1d_resultado.mat` | .mat | 1.4KB | 2026-08-03 10:46:11 | `76229fa50ed3…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `CODIGOS/ESTADISTICA/SPM1D_Core.m` | .m | 14.3KB | 2026-08-02 18:38:16 | `c0d1675dc426…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/ESTADISTICA/Test_SPM1D_BlandAltman.m` | .m | 6.6KB | 2026-08-02 18:37:15 | `7978bf64e27d…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/BITACORA_NOCHE.md` | .md | 25.5KB | 2026-08-27 01:22:32 | `d3a96fbd43da…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/Cadena_Cinematica_Core.m` | .m | 8.6KB | 2026-08-23 19:29:47 | `3dcff90acd4a…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Cadena_Completa_Core.m` | .m | 4.6KB | 2026-08-24 19:38:07 | `e3875038fbf0…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Cargar_Camargo_Core.m` | .m | 9.6KB | 2026-08-23 14:28:05 | `b636f6c20618…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Combinar_Candidatos_Core.m` | .m | 8.2KB | 2026-08-24 17:44:25 | `7da0f72895c7…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Comparar_Caminos_vs_ControlLuis.m` | .m | 5.0KB | 2026-08-24 19:26:37 | `bd6742b63e86…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Comparar_Caminos_vs_ControlLuis_figura.png` | .png | 111.5KB | 2026-08-24 19:26:57 | `1119435d0e57…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/DECISIONES.md` | .md | 2.1KB | 2026-08-26 23:50:57 | `661cc7bcab86…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/Escribir_CSV_Simulador.m` | .m | 4.1KB | 2026-08-23 18:39:53 | `e513deaa0540…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Estimar_Antropometria_Core.m` | .m | 3.7KB | 2026-08-23 18:25:50 | `23bd7506acc7…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Estimar_Velocidad_Froude_Core.m` | .m | 2.7KB | 2026-08-23 18:28:19 | `e052f5d5c3cc…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Generar_Trayectoria.m` | .m | 15.6KB | 2026-08-26 22:50:31 | `1a676a42d2fc…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/GRF_Newton_ApoyoSimple_Core.m` | .m | 14.7KB | 2026-08-28 00:01:57 | `c57a2748031d…` | no | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/GUIA_INTERPRETACION.md` | .md | 31.2KB | 2026-08-26 22:36:49 | `ac3a68ac44ec…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/CIERRE_INCLINACION_TIBIAL.md` | .md | 10.0KB | 2026-08-27 01:26:46 | `02a6ffe23ef8…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/DIAG_ladotrick_AnguloTibial.m` | .m | 4.4KB | 2026-08-27 10:18:59 | `2b300be97bc7…` | no | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/DIAG_ladotrick_AnguloTibial_resultados.csv` | .csv | 6.4KB | 2026-08-27 10:46:56 | `05e9cafc6fd4…` | no | dato-procesado | OK (cabecera 7 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial.m` | .m | 4.3KB | 2026-08-25 18:51:22 | `1393336ec8b1…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_figura.png` | .png | 225.4KB | 2026-08-27 01:25:41 | `7590225ca49a…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_resultados.csv` | .csv | 769B | 2026-08-27 01:24:40 | `6f06b48e7622…` | si | dato-procesado | OK (cabecera 9 columnas, consistente en muestra de 7 filas) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_Yun.m` | .m | 4.3KB | 2026-08-27 00:29:03 | `449129b11049…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_Yun_figura.png` | .png | 327.3KB | 2026-08-27 01:20:22 | `0a3d3f5cad0e…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_Yun_resultados.csv` | .csv | 765B | 2026-08-27 01:20:20 | `a6d6a2337fd7…` | si | dato-procesado | OK (cabecera 9 columnas, consistente en muestra de 7 filas) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_Zhao.m` | .m | 4.3KB | 2026-08-27 00:23:02 | `119fe64d19aa…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_Zhao_figura.png` | .png | 225.7KB | 2026-08-27 00:24:01 | `df3931af72c4…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_Individual_Kuopio_AnguloTibial_Zhao_resultados.csv` | .csv | 766B | 2026-08-27 00:23:58 | `9bd05391fa78…` | si | dato-procesado | OK (cabecera 9 columnas, consistente en muestra de 7 filas) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial.m` | .m | 9.5KB | 2026-08-25 19:18:10 | `7b967b48425b…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_figura.png` | .png | 331.8KB | 2026-08-27 01:25:41 | `92d1337f27e1…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_resultados.csv` | .csv | 2.6KB | 2026-08-27 01:24:40 | `c93c5f2d94b6…` | si | dato-procesado | OK (cabecera 12 columnas, consistente en muestra de 16 filas) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Yun.m` | .m | 10.1KB | 2026-08-27 00:28:40 | `b027e46b6e7e…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Yun_figura.png` | .png | 371.7KB | 2026-08-27 00:54:41 | `ca4235e41235…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Yun_resultados.csv` | .csv | 2.6KB | 2026-08-27 01:20:19 | `793b133927d4…` | si | dato-procesado | OK (cabecera 12 columnas, consistente en muestra de 16 filas) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Zhao.m` | .m | 8.5KB | 2026-08-27 00:22:39 | `21e663279bb2…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Zhao_figura.png` | .png | 336.5KB | 2026-08-27 00:23:25 | `ca548bbbb45e…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/Evaluar_vs_Kuopio_AnguloTibial_Zhao_resultados.csv` | .csv | 2.6KB | 2026-08-27 00:23:56 | `61faf9690a23…` | si | dato-procesado | OK (cabecera 12 columnas, consistente en muestra de 16 filas) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/yun_grupo_log.txt` | .txt | 13.4KB | 2026-08-27 00:54:41 | `fa9b772e1e2b…` | no | dato-procesado | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/INCLINACION_TIBIAL/yun_individual_log.txt` | .txt | 12.9KB | 2026-08-27 01:20:22 | `c2eb4f90b484…` | no | dato-procesado | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/Koopman2014_Core.m` | .m | 15.9KB | 2026-08-23 18:48:16 | `d38cd8950658…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/MasaSegmentaria_DeLeva1996_Core.m` | .m | 6.0KB | 2026-08-27 23:52:14 | `f3114a5d7cdc…` | no | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Obtener_Angulos_Candidato.m` | .m | 3.5KB | 2026-08-26 22:19:39 | `fa97a0602889…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Obtener_Theta_Tibia_Candidato.m` | .m | 6.9KB | 2026-08-24 19:36:45 | `cab04476f6bc…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/PLAN_ZHAO_YUN.md` | .md | 11.0KB | 2026-08-27 01:28:50 | `48cbb8064385…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/Reduccion_Winter_Core.m` | .m | 5.1KB | 2026-08-23 12:40:49 | `4fbe521b9858…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/REPORTE_NOCHE.md` | .md | 7.1KB | 2026-08-27 01:28:34 | `698f51e1915e…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/RODILLA/CIERRE_RODILLA.md` | .md | 33.1KB | 2026-08-26 23:41:06 | `a419cf77dd74…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/RODILLA/DIAG_ferber_lados.m` | .m | 4.5KB | 2026-08-26 23:31:26 | `ff386f0d7e69…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/DIAG_ferber_lados_resultados.csv` | .csv | 7.6KB | 2026-08-26 23:35:24 | `d298a8786165…` | si | dato-procesado | OK (cabecera 11 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_Mejor_Modelo_Rodilla.m` | .m | 6.9KB | 2026-08-26 22:07:46 | `16f4747a3f74…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_Mejor_Modelo_Rodilla_figura.png` | .png | 144.9KB | 2026-08-24 19:55:40 | `c48f1310182d…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Ferber.m` | .m | 9.1KB | 2026-08-26 18:43:09 | `22d3d04965f6…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Ferber_figura.png` | .png | 558.6KB | 2026-08-26 18:46:11 | `29bf05d287cc…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Ferber_resultados.csv` | .csv | 3.8KB | 2026-08-26 18:46:01 | `8ec91d2b586d…` | si | dato-procesado | OK (cabecera 9 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Maastricht.m` | .m | 5.6KB | 2026-08-26 23:01:41 | `3e6df7d8fa08…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Maastricht_figura.png` | .png | 136.1KB | 2026-08-26 23:03:16 | `93a07b70793a…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Winter.m` | .m | 5.1KB | 2026-08-26 22:07:56 | `13ecf322a6fb…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Winter_figura.png` | .png | 112.9KB | 2026-08-24 20:06:23 | `153c4ff17fe6…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/RODILLA/Extraer_Winter_CSV.m` | .m | 2.6KB | 2026-08-24 20:00:14 | `284586d38dc6…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/Cargar_Ferber2024_Core.m` | .m | 9.2KB | 2026-08-24 22:25:35 | `02fe516a50b4…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/event_data_TD.mat` | .mat | 221.9KB | 2026-08-24 20:51:30 | `aaf9b7752f71…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/event_data_TO.mat` | .mat | 221.9KB | 2026-08-24 20:51:30 | `1223e6d477dc…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/gait_kinematics.m` | .m | 36.9KB | 2026-08-24 20:51:29 | `10975884e715…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/gait_steps.m` | .m | 83.0KB | 2026-08-24 20:51:29 | `69f0134ba077…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/gaitClass.mat` | .mat | 11.1KB | 2026-08-24 20:51:30 | `5d1fa68aae22…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/LICENSE_RunningInjuryClinic.txt` | .txt | 1.1KB | 2026-08-24 20:51:30 | `f4a538bfa483…` | si | otro | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/muestra_40.csv` | .csv | 6.9KB | 2026-08-24 20:56:04 | `26e44e3f5606…` | si | dato-crudo | OK (cabecera 26 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/pca_td.m` | .m | 6.9KB | 2026-08-24 20:51:29 | `74b9104b6bad…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/pca_to.m` | .m | 5.3KB | 2026-08-24 20:51:30 | `8afe412ad413…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/processing_code_example.m` | .m | 3.6KB | 2026-08-24 20:51:30 | `d34cfe29e8fb…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/Ferber/README_Ferber2024_original.txt` | .txt | 10.9KB | 2026-08-24 20:56:04 | `9f9d9c079e2a…` | si | otro | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/RODILLA/Fukuchi/Cargar_Fukuchi2018_Core.m` | .m | 6.5KB | 2026-08-27 14:18:45 | `81dde675ad71…` | no | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/Fukuchi/Evaluar_Individual_Fukuchi2018_Angulos.m` | .m | 7.6KB | 2026-08-27 14:23:57 | `ef05553ecfa4…` | no | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/Fukuchi/Evaluar_vs_Fukuchi2018_Angulos.m` | .m | 9.6KB | 2026-08-27 14:17:20 | `d3b258378684…` | no | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/Fukuchi/Evaluar_vs_Fukuchi2018_KoopmanZhao.m` | .m | 6.5KB | 2026-08-27 14:28:53 | `810a56100778…` | no | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/Fukuchi/Evaluar_vs_Fukuchi2018_KoopmanZhao_figura.png` | .png | 447.3KB | 2026-08-27 14:29:29 | `412f63c4b1c1…` | no | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/RODILLA/Fukuchi/Evaluar_vs_Fukuchi2018_KoopmanZhao_resultados.csv` | .csv | 14.6KB | 2026-08-27 14:29:16 | `94c9c6ec4182…` | no | dato-procesado | OK (cabecera 6 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/Cargar_Kuopio2024_Core.m` | .m | 10.5KB | 2026-08-25 19:00:11 | `811e0eb3f665…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/Evaluar_Individual_Kuopio.m` | .m | 4.0KB | 2026-08-25 18:48:30 | `586721a7c18b…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/Evaluar_Individual_Kuopio_figura.png` | .png | 226.3KB | 2026-08-25 19:19:24 | `8c3d719e502f…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/Evaluar_Individual_Kuopio_resultados.csv` | .csv | 642B | 2026-08-25 19:19:21 | `065c15413966…` | si | dato-procesado | OK (cabecera 8 columnas, consistente en muestra de 7 filas) |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/Evaluar_vs_Kuopio_Avance.m` | .m | 13.0KB | 2026-08-25 19:18:27 | `e1f7d1255fcc…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/Evaluar_vs_Kuopio_Avance_figura.png` | .png | 365.6KB | 2026-08-25 19:19:17 | `dba370ab65a9…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/Evaluar_vs_Kuopio_Avance_resultados.csv` | .csv | 3.4KB | 2026-08-25 19:19:19 | `e9a1385ab91e…` | si | dato-procesado | OK (cabecera 16 columnas, consistente en muestra de 16 filas) |
| `CODIGOS/GENERADOR/RODILLA/Kuopio/extraer_kuopio.py` | .py | 6.8KB | 2026-08-24 22:13:54 | `05515456372f…` | si | código | OK (py_compile: sintaxis valida) |
| `CODIGOS/GENERADOR/RODILLA/Maastricht/01_Demo_PhysEx.xlsx` | .xlsx | 92.6KB | 2026-08-24 20:13:15 | `90a44b555ecb…` | si | dato-crudo | OK (xlsx valido, estructura interna reconocida, 13 entradas) |
| `CODIGOS/GENERADOR/RODILLA/Maastricht/05_AgeGenderGroup_comf.xlsx` | .xlsx | 4.9MB | 2026-08-24 20:13:20 | `7fcceef7ef7d…` | si | dato-crudo | OK (xlsx valido, estructura interna reconocida, 83 entradas) |
| `CODIGOS/GENERADOR/RODILLA/Maastricht/28_Description_parameters.docx` | .docx | 59.8KB | 2026-08-24 20:13:11 | `9a59e3d01ba0…` | si | dato-crudo | OK (docx valido, estructura interna reconocida, 13 entradas) |
| `CODIGOS/GENERADOR/RODILLA/Winter_Appendix_data.xlsx` | .xlsx | 132.5KB | 2026-08-24 19:58:59 | `788bf9bd2f8f…` | si | dato-crudo | OK (xlsx valido, estructura interna reconocida, 16 entradas) |
| `CODIGOS/GENERADOR/RODILLA/Winter_Cadera_Rodilla_Tobillo.csv` | .csv | 4.9KB | 2026-08-24 20:00:31 | `d379801054a2…` | si | dato-crudo | OK (cabecera 8 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/GENERADOR/Romero_Sorozabal2024_Core.m` | .m | 15.0KB | 2026-08-24 17:30:43 | `5c128454d9b3…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Segmento_Posicion_Core.m` | .m | 4.5KB | 2026-08-23 16:49:47 | `10a0d4bbb5f0…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Temporizacion_Core.m` | .m | 4.7KB | 2026-08-23 18:29:04 | `6fac466b4af0…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Test_Combinar_Candidatos.m` | .m | 7.5KB | 2026-08-24 18:23:27 | `d3a0920ac63c…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/Test_Combinar_Candidatos_figura.png` | .png | 229.9KB | 2026-08-24 18:24:08 | `9be198638b1a…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/Test_Generador.m` | .m | 20.4KB | 2026-08-23 18:48:26 | `378dd79ae4fa…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Test_Generador_Combinado.m` | .m | 3.5KB | 2026-08-24 18:03:01 | `5945b6086371…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Test_Generador_Trayectoria.m` | .m | 10.3KB | 2026-08-24 19:14:12 | `4a3b64e388f7…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/Test_RomeroSorozabal.m` | .m | 7.8KB | 2026-08-24 17:32:27 | `9e583ec5cba2…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/Test_RomeroSorozabal_figura.png` | .png | 171.3KB | 2026-08-24 17:32:52 | `8b8786640b76…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/Tiempo_Ciclo_Koopman2014_Core.m` | .m | 2.2KB | 2026-08-23 18:28:33 | `c64f4e9ac6c5…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/TOBILLO/CIERRE_TOBILLO.md` | .md | 22.1KB | 2026-08-27 01:26:16 | `600c19be8b1b…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/TOBILLO/DIAG_ladotrick_Tobillo.m` | .m | 6.7KB | 2026-08-27 10:19:58 | `45b32d2a85c8…` | no | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/TOBILLO/DIAG_ladotrick_Tobillo_resultados.csv` | .csv | 5.3KB | 2026-08-27 10:47:34 | `a218ce99199f…` | no | dato-procesado | OK (cabecera 6 columnas, consistente en muestra de 20 filas) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo.m` | .m | 3.6KB | 2026-08-25 18:49:57 | `d99d6b50767a…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo_figura.png` | .png | 213.9KB | 2026-08-27 01:25:41 | `df58d6e0b0c4…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo_resultados.csv` | .csv | 638B | 2026-08-27 01:24:11 | `ef0d37c35eba…` | si | dato-procesado | OK (cabecera 8 columnas, consistente en muestra de 7 filas) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Yun.m` | .m | 3.7KB | 2026-08-27 00:27:55 | `5bce5e1846a8…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Yun_figura.png` | .png | 291.6KB | 2026-08-27 01:18:29 | `a7b7d6bdf065…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Yun_resultados.csv` | .csv | 637B | 2026-08-27 01:18:28 | `9ef9eea30499…` | si | dato-procesado | OK (cabecera 8 columnas, consistente en muestra de 7 filas) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Zhao.m` | .m | 3.5KB | 2026-08-27 00:23:15 | `e44f46138f61…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Zhao_figura.png` | .png | 209.5KB | 2026-08-27 00:23:35 | `7144a75c021f…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_Individual_Kuopio_Tobillo_Zhao_resultados.csv` | .csv | 638B | 2026-08-27 00:23:32 | `66eeecda9837…` | si | dato-procesado | OK (cabecera 8 columnas, consistente en muestra de 7 filas) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases.m` | .m | 18.4KB | 2026-08-25 19:18:37 | `314341380fd0…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_figura.png` | .png | 312.4KB | 2026-08-27 01:25:41 | `6e361376deef…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_resultados.csv` | .csv | 2.6KB | 2026-08-27 01:24:10 | `f56642042132…` | si | dato-procesado | OK (cabecera 12 columnas, consistente en muestra de 16 filas) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Yun.m` | .m | 18.6KB | 2026-08-27 00:27:33 | `0b6f7937fa93…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Yun_figura.png` | .png | 351.5KB | 2026-08-27 00:53:27 | `d119342b3208…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Yun_resultados.csv` | .csv | 2.6KB | 2026-08-27 01:18:27 | `df8d2c193166…` | si | dato-procesado | OK (cabecera 12 columnas, consistente en muestra de 16 filas) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Zhao.m` | .m | 18.3KB | 2026-08-27 00:23:23 | `56d17d5ac231…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Zhao_figura.png` | .png | 327.7KB | 2026-08-27 00:27:44 | `8135dc2f98b4…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/TOBILLO/Evaluar_vs_Kuopio_Tobillo_Fases_Zhao_resultados.csv` | .csv | 2.6KB | 2026-08-27 00:27:38 | `8bb26aff098d…` | si | dato-procesado | OK (cabecera 12 columnas, consistente en muestra de 16 filas) |
| `CODIGOS/GENERADOR/TOBILLO/yun_run_log.txt` | .txt | 23.9KB | 2026-08-27 01:18:30 | `f3b7e7dbbc0b…` | no | dato-procesado | OK (utf-8 valido) |
| `CODIGOS/GENERADOR/Ver_Resultado_Final.m` | .m | 4.7KB | 2026-08-24 19:21:48 | `619e15ab1186…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Ver_Resultado_Final_figura.png` | .png | 157.9KB | 2026-08-26 22:34:11 | `6a3b64e46ee0…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/Ver_Todos_Los_Modelos.m` | .m | 5.1KB | 2026-08-24 19:39:19 | `4347a184146e…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERADOR/Ver_Todos_Los_Modelos_figura.png` | .png | 253.0KB | 2026-08-26 22:27:11 | `15e1c6bd8ec0…` | si | figura | OK (firma PNG valida) |
| `CODIGOS/GENERADOR/Yun2014_Wrapper.m` | .m | 8.4KB | 2026-08-24 17:52:51 | `e8b7a50a421b…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERADOR/Zhao2026_Core.m` | .m | 4.3KB | 2026-08-23 12:40:23 | `422ee81747e2…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/GENERAR CURVS DE REFERENCIA/Angulo_Control_Plataforma.m` | .m | 14.2KB | 2026-07-22 17:32:12 | `4da6a4d213ea…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERAR CURVS DE REFERENCIA/Base_Datos_GRF.m` | .m | 10.8KB | 2026-05-30 15:44:30 | `a1efdb95c4bf…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/GENERAR CURVS DE REFERENCIA/Desplazamientos.m` | .m | 30.3KB | 2026-06-29 01:24:54 | `f62adac80dad…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/INCERTIDUMBRE/GUIA_INTERPRETACION.md` | .md | 12.4KB | 2026-08-19 23:42:14 | `5b9268156452…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/INCERTIDUMBRE/PresupuestoIncertidumbre_Core.m` | .m | 7.8KB | 2026-08-17 08:26:12 | `5f315085d21f…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/INCERTIDUMBRE/Test_PresupuestoIncertidumbre.m` | .m | 7.2KB | 2026-08-17 08:26:45 | `9e8ca728c8ff…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/MULTISUJETO/Cargar_Sujetos_CSV.m` | .m | 5.8KB | 2026-08-03 10:36:08 | `0048c8a7ecc0…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/MULTISUJETO/GUIA_INTERPRETACION.md` | .md | 12.0KB | 2026-08-19 23:42:22 | `b6b93a709369…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/MULTISUJETO/Procesar_Multisujeto_Core.m` | .m | 11.4KB | 2026-08-03 10:35:09 | `0e0f5aa7a0e9…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/MULTISUJETO/Test_Procesar_Multisujeto.m` | .m | 6.7KB | 2026-08-03 10:37:44 | `909f0fe19516…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/POTENCIA_EQUIVALENCIA/GUIA_INTERPRETACION.md` | .md | 11.4KB | 2026-08-19 23:42:29 | `cf4dc1e06308…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/POTENCIA_EQUIVALENCIA/PotenciaApriori_Core.m` | .m | 11.7KB | 2026-08-13 13:08:00 | `c0e179b358d9…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/POTENCIA_EQUIVALENCIA/Test_PotenciaApriori_TOST.m` | .m | 7.1KB | 2026-08-13 13:09:21 | `071b69075042…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/POTENCIA_EQUIVALENCIA/TOST_Core.m` | .m | 7.6KB | 2026-08-13 13:08:36 | `a9c1ca2807e2…` | si | código | OK (mlint: 0 avisos) |
| `CODIGOS/VALIDACIONES/Calcular_Metricas_Curva.m` | .m | 4.1KB | 2026-08-03 10:30:19 | `20e87e989d66…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/VALIDACIONES/GUIA_INTERPRETACION.md` | .md | 10.2KB | 2026-08-19 23:42:37 | `ac0e952cc5a0…` | si | documento-planificación | OK (utf-8 valido) |
| `CODIGOS/VALIDACIONES/Validacion_Fuerza.m` | .m | 24.1KB | 2026-06-30 14:22:53 | `0b2037b821fd…` | si | código | OK (mlint: 1 avisos de estilo/rendimiento, sin errores de sintaxis) |
| `CODIGOS/VALIDACIONES/Validacion_Plataforma.m` | .m | 18.8KB | 2026-06-27 15:01:48 | `0647410127cc…` | si | código | OK (mlint: 0 avisos) |
| `docs/_archivo/plantilla_overleaf_Bioengineering_MDPI.tex` | .tex | 13.3KB | 2026-08-03 12:34:44 | `e23e45e8e808…` | si | documento-manuscrito | OK (abre como texto, 13567 caracteres; sin \input/\include) |
| `docs/_archivo/plantilla_overleaf_POI.tex` | .tex | 13.6KB | 2026-08-03 12:34:55 | `f40eee0447ec…` | si | documento-manuscrito | OK (abre como texto, 13884 caracteres; sin \input/\include) |
| `docs/_archivo/plantilla_overleaf_Prosthesis_MDPI.tex` | .tex | 14.3KB | 2026-08-03 12:47:49 | `839bcf3a33cd…` | si | documento-manuscrito | OK (abre como texto, 14684 caracteres; sin \input/\include) |
| `docs/_archivo/preguntas_SIBUC_VRI.md` | .md | 4.2KB | 2026-08-03 12:52:55 | `3f863df925e6…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/_archivo/README.md` | .md | 1.1KB | 2026-08-05 17:22:24 | `cbf69fbac26a…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/algoritmo/busqueda_modelos_antropometria_rodilla.md` | .md | 9.4KB | 2026-08-24 20:30:04 | `6b8a268f428b…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/algoritmo/contrato_generador.md` | .md | 7.5KB | 2026-08-23 19:31:48 | `721fe60a8da8…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/algoritmo/diseno_matematico_generador.md` | .md | 18.9KB | 2026-08-23 15:03:16 | `c5c90f171ab8…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/algoritmo/informe_tecnico_generador/informe_tecnico_generador.tex` | .tex | 10.0KB | 2026-08-27 12:03:47 | `547965006d5c…` | no | documento-manuscrito | OK (abre como texto, 10096 caracteres; sin \input/\include) |
| `docs/algoritmo/informe_tecnico_generador/referencias_informe.bib` | .bib | 1.2KB | 2026-08-27 11:57:38 | `2a06b9a1a9d2…` | no | bibliografía | OK (llaves balanceadas: 27; ~3 entradas @; sin bibtexparser instalado, chequeo manual) |
| `docs/algoritmo/informe_tecnico_generador/referencias_verificadas_informe.md` | .md | 1.2KB | 2026-08-27 11:57:45 | `144124f2ff78…` | no | documento-planificación | OK (utf-8 valido) |
| `docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md` | .md | 44.9KB | 2026-08-27 14:31:43 | `756304af0ec5…` | no | documento-planificación | OK (utf-8 valido) |
| `docs/algoritmo/mejor_modelo_rodilla.md` | .md | 6.8KB | 2026-08-24 21:10:23 | `b8ed1f99efdf…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/01_seleccion_koopman_vs_control_luis.png` | .png | 93.8KB | 2026-08-26 22:12:23 | `1fbe70ebb850…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/02_seleccion_koopman_vs_maastricht.png` | .png | 93.6KB | 2026-08-26 23:04:58 | `fe83fff6dfd3…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/03_seleccion_koopman_vs_ferber.png` | .png | 268.1KB | 2026-08-26 22:12:23 | `4f499c7160aa…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/04_los_4_candidatos_cadena_completa.png` | .png | 165.5KB | 2026-08-26 22:35:35 | `3366729696b5…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/05_generador_salida_koopman.png` | .png | 110.1KB | 2026-08-26 22:35:35 | `f25f8857e790…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/06_rodilla_vs_kuopio_grupo.png` | .png | 228.9KB | 2026-08-26 22:12:23 | `69c7440062b4…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/07_rodilla_vs_kuopio_individual.png` | .png | 213.4KB | 2026-08-26 22:12:23 | `98b97f30657c…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/08_tobillo_vs_kuopio_grupo.png` | .png | 188.9KB | 2026-08-26 22:12:23 | `d943012c477e…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/09_tobillo_vs_kuopio_individual.png` | .png | 193.8KB | 2026-08-26 22:12:23 | `8233e448249d…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/10_angulo_tibial_vs_kuopio_grupo.png` | .png | 189.3KB | 2026-08-26 22:12:23 | `057009a25307…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/figuras/11_angulo_tibial_vs_kuopio_individual.png` | .png | 226.5KB | 2026-08-26 22:12:23 | `0e87c2afc2ef…` | si | figura | OK (firma PNG valida) |
| `docs/algoritmo/pipeline_koopman_kuopio/PIPELINE_KOOPMAN_KUOPIO.md` | .md | 22.6KB | 2026-08-27 01:27:52 | `5c66fbf73577…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/codigos/INDICE_CODIGOS.md` | .md | 13.7KB | 2026-08-23 15:04:31 | `86bdfa90ab7d…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/configuracion/setup_nueva_laptop.md` | .md | 6.8KB | 2026-08-23 12:24:37 | `69cb29bcd60d…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/DISCUSION_Q2.md` | .md | 128.9KB | 2026-08-23 16:53:39 | `068d875b382c…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/equipo/tarea_alessandro.md` | .md | 2.6KB | 2026-08-13 11:48:29 | `02b17a2b8355…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/ESTADO_Y_RUMBO.md` | .md | 22.4KB | 2026-08-19 21:59:53 | `0027f019265a…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/etica/comite_etica.md` | .md | 3.8KB | 2026-08-19 23:38:26 | `2b4da8eaddcc…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/literatura/bases_datos_candidatas_profesora_23ago.md` | .md | 3.1KB | 2026-08-23 18:10:31 | `1988dd7891a8…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/literatura/literatura_GRF_protesica.md` | .md | 9.8KB | 2026-08-19 23:38:35 | `ebd171b4efb5…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/literatura/normas_ISO_relevantes.md` | .md | 8.3KB | 2026-08-19 23:38:43 | `c0581b07e404…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/literatura/pdfs/22151474.zip` | .zip | 1.7MB | 2026-08-27 15:56:16 | `b5e2950a335e…` | no | otro | OK (zip valido, 262 entradas, sin errores CRC) |
| `docs/literatura/pdfs/AB06.zip` | .zip | 1.2GB | 2026-08-23 13:42:37 | `3eb007a7e3e3…` | no | otro | OK (zip valido, 1781 entradas, sin errores CRC) |
| `docs/literatura/pdfs/AB09.zip` | .zip | 1.2GB | 2026-08-23 13:42:38 | `7820270c4272…` | no | otro | OK (zip valido, 1781 entradas, sin errores CRC) |
| `docs/literatura/pdfs/camargo_articulo.pdf` | .pdf | 4.2MB | 2026-08-23 13:52:52 | `4a01082e0b13…` | si | PDF-literatura | OK (abre, capa de texto SI, ~10 paginas segun form-feed, 36485 caracteres extraidos) |
| `docs/literatura/pdfs/chile_extract/Base_de_datos_cinematica.csv` | .csv | 19.7KB | 2026-08-27 15:55:58 | `bb21a7dfaf8f…` | no | dato-crudo | OK (cabecera 24 columnas, consistente en muestra de 20 filas) |
| `docs/literatura/pdfs/chile_extract/Datos_generales_y_VTE.csv` | .csv | 3.8KB | 2026-08-27 15:55:58 | `df7c62efa50d…` | no | dato-crudo | OK (cabecera 16 columnas, consistente en muestra de 20 filas) |
| `docs/literatura/pdfs/DeLeva1996_JBiomech_SegmentInertiaParameters.pdf` | .pdf | 1.4MB | 2026-08-27 21:40:33 | `db58e482760d…` | no | PDF-literatura | OK (abre, capa de texto SI, ~9 paginas segun form-feed, 37444 caracteres extraidos) |
| `docs/literatura/pdfs/Gait_Kinematics_Prediction_V1.01_Release.zip` | .zip | 4.6MB | 2026-08-20 11:58:20 | `7d0036f7f19b…` | no | otro | OK (zip valido, 120 entradas, sin errores CRC) |
| `docs/literatura/pdfs/Journal of Forecasting - 2023 - Clements - Forecast combination puzzle in the HAR model.pdf` | .pdf | 936.1KB | 2026-08-24 18:17:54 | `f9de4411858c…` | si | PDF-literatura | OK (abre, capa de texto SI, ~21 paginas segun form-feed, 81062 caracteres extraidos) |
| `docs/literatura/pdfs/koomap.pdf` | .pdf | 2.0MB | 2026-08-23 13:36:29 | `1f2f1298dda9…` | si | PDF-literatura | OK (abre, capa de texto SI, ~13 paginas segun form-feed, 52552 caracteres extraidos) |
| `docs/literatura/pdfs/P24.pdf` | .pdf | 3.8MB | 2026-08-20 11:35:25 | `4fac351f37ac…` | si | PDF-literatura | OK (abre, capa de texto SI, ~8 paginas segun form-feed, 38537 caracteres extraidos) |
| `docs/literatura/pdfs/pdf para modelos que necesitas/Hu et al. 2020,.pdf` | .pdf | 692.6KB | 2026-08-24 08:42:51 | `82ed6d3d6719…` | si | PDF-literatura | OK (abre, capa de texto SI, ~7 paginas segun form-feed, 29766 caracteres extraidos) |
| `docs/literatura/pdfs/pdf para modelos que necesitas/Luu, Low, Qu, Lim, Hoon 2014, Gait & Posture.pdf` | .pdf | 701.9KB | 2026-08-24 08:43:54 | `fe50d58aff64…` | si | PDF-literatura | OK (abre, capa de texto SI, ~19 paginas segun form-feed, 30801 caracteres extraidos) |
| `docs/literatura/pdfs/pdf para modelos que necesitas/Subject-specific lower limb waveforms.pdf` | .pdf | 452.4KB | 2026-08-24 08:51:06 | `20ca6207ee9e…` | si | PDF-literatura | OK (abre, capa de texto SI, ~16 paginas segun form-feed, 30944 caracteres extraidos) |
| `docs/literatura/pdfs/pdf para modelos que necesitas/Wu, Liu, Liu, Chen, Gao 2018.pdf` | .pdf | 5.4MB | 2026-08-24 08:46:40 | `f79ab690bd3a…` | si | PDF-literatura | OK (abre, capa de texto SI, ~14 paginas segun form-feed, 59510 caracteres extraidos) |
| `docs/literatura/pdfs/Piche2022_iSen_STT-IWS_validacion_OptiTrack_Measurement198_111442.pdf` | .pdf | 2.7MB | 2026-08-11 11:18:31 | `742e25854b86…` | si | PDF-literatura | OK (abre, capa de texto SI, ~8 paginas segun form-feed, 40716 caracteres extraidos) |
| `docs/literatura/pdfs/RomeroSorozabal2024_Biomimetics.pdf` | .pdf | 8.4MB | 2026-08-24 11:55:22 | `f68c656c6a0f…` | si | PDF-literatura | OK (abre, capa de texto SI, ~23 paginas segun form-feed, 74216 caracteres extraidos) |
| `docs/literatura/pdfs/ScienceDirect_files_20Aug2026_16-42-47.312.zip` | .zip | 3.2MB | 2026-08-20 11:42:49 | `9b9bc479319e…` | no | otro | OK (zip valido, 2 entradas, sin errores CRC) |
| `docs/literatura/pdfs/Sudeesh 2024.pdf` | .pdf | 11.6MB | 2026-08-27 11:06:06 | `d06ff692fa43…` | no | PDF-literatura | OK (abre, capa de texto SI, ~13 paginas segun form-feed, 46672 caracteres extraidos) |
| `docs/literatura/pdfs/yun2014_supp/1-s2.0-S0021929013004879-mmc1.pdf` | .pdf | 133.9KB | 2026-08-20 16:42:46 | `5e489d061458…` | si | PDF-literatura | OK (abre, capa de texto SI, ~9 paginas segun form-feed, 11416 caracteres extraidos) |
| `docs/literatura/pdfs/yun2014_supp/1-s2.0-S0021929013004879-mmc2.pdf` | .pdf | 3.1MB | 2026-08-20 16:42:46 | `56aa5a4662bb…` | si | PDF-literatura | OK (abre, capa de texto SI, ~8 paginas segun form-feed, 8099 caracteres extraidos) |
| `docs/literatura/pdfs/Zhao2026_PLOSONE_predictive_model_joint_dynamics_GRF.pdf` | .pdf | 1.7MB | 2026-08-20 12:22:35 | `0a289cda4d4f…` | si | PDF-literatura | OK (abre, capa de texto SI, ~18 paginas segun form-feed, 52094 caracteres extraidos) |
| `docs/literatura/postprocesado_datos_crudos_IMU.md` | .md | 6.7KB | 2026-08-19 23:38:51 | `0893ddb8cdb5…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/literatura/validacion_instrumentos_IMU.md` | .md | 8.5KB | 2026-08-19 23:39:00 | `633ae45ae6b0…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/manuscrito/creditos_autoria_borrador.md` | .md | 4.7KB | 2026-08-19 23:39:28 | `4769570a6f61…` | si | documento-manuscrito | OK (utf-8 valido) |
| `docs/manuscrito/guia_autor_JTEHM.md` | .md | 15.1KB | 2026-08-19 23:39:38 | `18218ba112c1…` | si | documento-manuscrito | OK (utf-8 valido) |
| `docs/manuscrito/JTEHM_LaTex_Template/IEEEJERM.cls` | .cls | 269.7KB | 2026-08-03 16:02:10 | `17c30542f77e…` | si | config | NO COMPROBABLE: clase LaTeX de terceros (IEEEJERM.cls), sin validador de sintaxis LaTeX disponible offline |
| `docs/manuscrito/JTEHM_LaTex_Template/JERM Demo.pdf` | .pdf | 70.8KB | 2026-08-03 16:02:11 | `b4762d927705…` | si | otro | OK (abre, capa de texto SI, ~2 paginas segun form-feed, 1251 caracteres extraidos) |
| `docs/manuscrito/JTEHM_LaTex_Template/JERM Demo.tex` | .tex | 24.8KB | 2026-08-03 16:02:10 | `ec53e2b06dc4…` | si | documento-manuscrito | OK (abre como texto, 25420 caracteres; sin \input/\include) |
| `docs/manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` | .tex | 29.6KB | 2026-08-19 23:40:22 | `100e4f237a78…` | si | documento-manuscrito | OK (abre como texto, 30271 caracteres; sin \input/\include) |
| `docs/manuscrito/JTEHM_LaTex_Template/README_ESTRUCTURA.md` | .md | 4.2KB | 2026-08-19 23:40:05 | `b95458e86d44…` | si | documento-manuscrito | OK (utf-8 valido) |
| `docs/manuscrito/JTEHM_LaTex_Template/references.bib` | .bib | 16.2KB | 2026-08-16 22:16:43 | `e2caa7c1f05b…` | si | bibliografía | OK (llaves balanceadas: 105; ~13 entradas @; sin bibtexparser instalado, chequeo manual) |
| `docs/manuscrito/metodos_introduccion_borrador.md` | .md | 14.5KB | 2026-08-19 23:39:47 | `eae77f41d9a7…` | si | documento-manuscrito | OK (utf-8 valido) |
| `docs/manuscrito/referencias_verificadas.md` | .md | 21.6KB | 2026-08-19 23:39:57 | `32582f335d84…` | si | documento-manuscrito | OK (utf-8 valido) |
| `docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` | .md | 67.0KB | 2026-08-27 10:00:33 | `1141a71af642…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/planificacion/analisis_revistas_Q1_generador.md` | .md | 8.3KB | 2026-08-27 11:44:12 | `da11ca201e5e…` | no | documento-planificación | OK (utf-8 valido) |
| `docs/planificacion/plan_100_generador.md` | .md | 17.6KB | 2026-08-23 19:37:38 | `d286dd4ad30e…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/planificacion/plan_ensamble_multimodelo.md` | .md | 24.9KB | 2026-08-24 18:19:56 | `66f2690fd0b9…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md` | .md | 27.8KB | 2026-08-19 23:40:40 | `5cb1d2d5f830…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/planificacion/preregistro_OSF_borrador.md` | .md | 11.1KB | 2026-08-19 23:40:48 | `7ea5f34cd9b7…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/planificacion/propuesta_articulo_Q2.md` | .md | 24.1KB | 2026-08-19 23:40:56 | `4268d529df88…` | si | documento-planificación | OK (utf-8 valido) |
| `docs/planificacion/revistas_candidatas_Q2.md` | .md | 28.6KB | 2026-08-19 23:41:06 | `49fa8adbcddc…` | si | documento-planificación | OK (utf-8 valido) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_10_OF.csv` | .csv | 18.3KB | 2026-06-26 15:59:47 | `930ffe5b43fb…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_1_OF.csv` | .csv | 19.5KB | 2026-06-26 14:21:05 | `1e32eb144a94…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_2_OF.csv` | .csv | 18.5KB | 2026-06-26 14:25:02 | `4cc5c44359fc…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_3_OF.csv` | .csv | 18.8KB | 2026-06-26 14:29:40 | `39e461d2554c…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_4_OF.csv` | .csv | 19.1KB | 2026-06-26 14:59:06 | `234ac2ec5660…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_5_OF.csv` | .csv | 18.4KB | 2026-06-26 15:47:28 | `cf0df92d8c24…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_6_OF.csv` | .csv | 18.2KB | 2026-06-26 15:51:08 | `50c09b4b7290…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_7_OF.csv` | .csv | 18.0KB | 2026-06-26 15:53:54 | `5b6f64945144…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_8_OF.csv` | .csv | 18.5KB | 2026-06-26 15:58:06 | `59060c9650b7…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Coordenadas_Apoyo/Coor_Apoyo_9_OF.csv` | .csv | 18.3KB | 2026-06-26 15:59:39 | `930ffe5b43fb…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_10_OF.csv` | .csv | 2.0KB | 2026-06-26 16:00:01 | `5656f9a30dfe…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_1_OF.csv` | .csv | 2.1KB | 2026-06-26 14:21:24 | `d5f97623a758…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_2_OF.csv` | .csv | 2.0KB | 2026-06-26 14:26:10 | `bb78cec82767…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_3_OF.csv` | .csv | 2.0KB | 2026-06-26 14:29:53 | `fa81bbf3bacf…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_4_OF.csv` | .csv | 2.1KB | 2026-06-26 15:04:37 | `b4883768f22b…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_5_OF.csv` | .csv | 2.0KB | 2026-06-26 15:47:43 | `976410c6971a…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_6_OF.csv` | .csv | 2.0KB | 2026-06-26 15:51:33 | `a67f6ff42377…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_7_OF.csv` | .csv | 1.9KB | 2026-06-26 15:54:08 | `096b61a08e62…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_8_OF.csv` | .csv | 2.0KB | 2026-06-26 15:56:35 | `acdc932a81f2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - X - Apoyo/DX_cm_Apoyo_9_OF.csv` | .csv | 2.0KB | 2026-06-26 15:57:51 | `acdc932a81f2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_10_OF.csv` | .csv | 2.2KB | 2026-06-26 16:00:16 | `d92ba498408b…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_1_OF.csv` | .csv | 2.3KB | 2026-06-26 14:21:48 | `a823c0d006d7…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_2_OF.csv` | .csv | 2.2KB | 2026-06-26 14:26:41 | `f2d0a8d4e173…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_3_OF.csv` | .csv | 2.3KB | 2026-06-26 14:30:04 | `033955cef619…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_4_OF.csv` | .csv | 2.3KB | 2026-06-26 15:04:47 | `5816747d1b41…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_5_OF.csv` | .csv | 2.2KB | 2026-06-26 15:48:02 | `83f6a17ec8df…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_6_OF.csv` | .csv | 2.2KB | 2026-06-26 15:51:45 | `6fcfd26285c5…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_7_OF.csv` | .csv | 2.2KB | 2026-06-26 15:54:21 | `63b2c834308f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_8_OF.csv` | .csv | 2.2KB | 2026-06-26 15:57:40 | `a43692e1372d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/APOYO/Desplazamiento - Y - Apoyo/DY_cm_Apoyo_9_OF.csv` | .csv | 2.2KB | 2026-06-26 16:00:11 | `d92ba498408b…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_11_OF.csv` | .csv | 11.1KB | 2026-06-29 00:47:23 | `56e608661f00…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_12_OF.csv` | .csv | 10.3KB | 2026-06-29 00:51:21 | `40e953577cd2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_13_OF.csv` | .csv | 10.2KB | 2026-06-29 00:54:22 | `0739c7420e4c…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_14_OF.csv` | .csv | 10.6KB | 2026-06-29 00:57:27 | `944c0f5ecbfa…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_15_OF.csv` | .csv | 11.3KB | 2026-06-29 01:00:12 | `dc7954c079a7…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_16_OF.csv` | .csv | 11.0KB | 2026-06-29 01:05:02 | `551161e1f72f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_17_OF.csv` | .csv | 11.0KB | 2026-06-29 01:05:15 | `551161e1f72f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_18_OF.csv` | .csv | 11.8KB | 2026-06-29 01:07:37 | `cd1f51f3cc44…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_19_OF.csv` | .csv | 10.2KB | 2026-06-29 01:10:19 | `56d9ceb5fbef…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Coordenadas_Balanceo/Coor_Balanceo_20_OF.csv` | .csv | 10.2KB | 2026-06-29 01:10:32 | `56d9ceb5fbef…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_11_OF.csv` | .csv | 1.2KB | 2026-06-29 00:47:57 | `5ed24ce5adda…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_12_OF.csv` | .csv | 1.1KB | 2026-06-29 00:51:49 | `e521051ab8b2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_13_OF.csv` | .csv | 1.1KB | 2026-06-29 00:54:43 | `d2543ae9f710…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_14_OF.csv` | .csv | 1.1KB | 2026-06-29 00:57:47 | `523a55f5ff96…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_15_OF.csv` | .csv | 1.2KB | 2026-06-29 01:00:29 | `cfa9efe0976d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_16_OF.csv` | .csv | 1.2KB | 2026-06-29 01:05:51 | `fc66aa891a66…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_17_OF.csv` | .csv | 1.2KB | 2026-06-29 01:06:01 | `fc66aa891a66…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_18_OF.csv` | .csv | 1.3KB | 2026-06-29 01:07:50 | `c8211b617d3b…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_19_OF.csv` | .csv | 1.1KB | 2026-06-29 00:57:47 | `523a55f5ff96…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - X - Balanceo/DX_cm_Balanceo_20_OF.csv` | .csv | 1.2KB | 2026-06-29 01:00:29 | `cfa9efe0976d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_11_OF.csv` | .csv | 1.2KB | 2026-06-29 00:48:09 | `9bf903ea66ac…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_12_OF.csv` | .csv | 1.1KB | 2026-06-29 00:52:02 | `917ca9b69b43…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_13_OF.csv` | .csv | 1.1KB | 2026-06-29 00:55:26 | `5d2772dde515…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_14_OF.csv` | .csv | 1.2KB | 2026-06-29 00:58:09 | `cd4f56df0204…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_15_OF.csv` | .csv | 1.2KB | 2026-06-29 01:00:41 | `0b69454e2512…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_16_OF.csv` | .csv | 1.2KB | 2026-06-29 01:03:23 | `d39a47c5fb7a…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_17_OF.csv` | .csv | 1.3KB | 2026-06-29 01:08:03 | `3991b3caec97…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_18_OF.csv` | .csv | 1.3KB | 2026-06-29 01:08:09 | `3991b3caec97…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_19_OF.csv` | .csv | 1.3KB | 2026-06-29 01:08:16 | `3991b3caec97…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/BALANCEO/Desplazamiento - Y- Balanceo/DY_cm_Balanceo_20_OF.csv` | .csv | 1.1KB | 2026-06-29 01:10:50 | `996ea5d5e898…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `PERSONA SANA/FUERZA GRF/Trial00926.txt` | .txt | 606.1KB | 2026-06-30 13:26:16 | `787ec39e2a1a…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00927.txt` | .txt | 605.8KB | 2026-06-30 13:26:16 | `4baffc8739ef…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00928.txt` | .txt | 606.0KB | 2026-06-30 13:26:16 | `a2cfc7c12c37…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00929.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `4b4215237597…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00930.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `b3a1759cc671…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00931.txt` | .txt | 605.8KB | 2026-06-30 13:26:16 | `5f1887ef3760…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00932.txt` | .txt | 605.5KB | 2026-06-30 13:26:16 | `aa5a680d09d7…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00933.txt` | .txt | 605.8KB | 2026-06-30 13:26:16 | `8a69ea8bdb81…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00934.txt` | .txt | 605.5KB | 2026-06-30 13:26:16 | `f9328e7ca2b4…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00935.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `6a1c53fe52c6…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00936.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `688811b6410e…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00937.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `6bc8c73229a5…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00938.txt` | .txt | 606.1KB | 2026-06-30 13:26:16 | `c351920930b2…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00939.txt` | .txt | 606.0KB | 2026-06-30 13:26:16 | `f428b0d23343…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00940.txt` | .txt | 606.0KB | 2026-06-30 13:26:16 | `3ded3ae6df7c…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00941.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `63ec66318fff…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00942.txt` | .txt | 605.6KB | 2026-06-30 13:26:16 | `acffa938afd4…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00943.txt` | .txt | 606.1KB | 2026-06-30 13:26:16 | `652b080b9b45…` | si | dato-crudo | OK (utf-8 valido) |
| `PERSONA SANA/FUERZA GRF/Trial00944.txt` | .txt | 605.9KB | 2026-06-30 13:26:16 | `a05e4efb385e…` | si | dato-crudo | OK (utf-8 valido) |
| `REFERENCIAS/BaseDatos_FuerzaVertical.mat` | .mat | 1.8KB | 2026-08-09 17:55:28 | `5f0b3ff0c124…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `REFERENCIAS/BaseDatos_Plataforma_Apoyo.mat` | .mat | 3.4KB | 2026-08-09 18:08:18 | `43e0bde45e35…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `REFERENCIAS/BaseDatos_Plataforma_Balanceo.mat` | .mat | 3.0KB | 2026-08-09 18:08:18 | `1b88a3774853…` | si | dato-procesado | OK (cabecera MAT-file reconocida) |
| `REFERENCIAS/Control_apoyo_Luis_V4.csv` | .csv | 2.9KB | 2026-06-26 16:28:40 | `5b2caed14fd6…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `REFERENCIAS/Control_balanceo_Luis_V4.csv` | .csv | 1.6KB | 2026-06-30 12:08:48 | `cec48933660a…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `REFERENCIAS/CurvaPromedio_Plataforma_Apoyo_0.010s_0.009deg.csv` | .csv | 1.3KB | 2026-08-09 18:08:18 | `ebe4867dd6bc…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `REFERENCIAS/CurvaPromedio_Plataforma_Balanceo_0.010s_0.009deg.csv` | .csv | 812B | 2026-08-09 18:08:18 | `37653ff32d1e…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `REFERENCIAS/X_Apoyo.csv` | .csv | 1.3KB | 2026-08-09 20:11:24 | `6a48548fa91a…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `REFERENCIAS/X_Balanceo.csv` | .csv | 782B | 2026-08-09 20:11:24 | `03af12ad08fa…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `REFERENCIAS/Y_Apoyo.csv` | .csv | 1.3KB | 2026-08-09 20:11:24 | `5e6daba1e7b8…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `REFERENCIAS/Y_Balanceo.csv` | .csv | 749B | 2026-08-09 20:11:24 | `72263a277d57…` | si | dato-procesado | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_10_OF.csv` | .csv | 517.1KB | 2026-06-27 14:27:27 | `dc3e56dd11c4…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_1_OF.csv` | .csv | 427.4KB | 2026-06-27 14:31:52 | `6a0b5e4f5c4d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_2_OF.csv` | .csv | 523.6KB | 2026-06-27 11:39:02 | `049aebe00b5f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_3_OF.csv` | .csv | 520.7KB | 2026-06-27 11:55:51 | `6c924d29066f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_4_OF.csv` | .csv | 522.5KB | 2026-06-27 12:37:26 | `0daab224343f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_5_OF.csv` | .csv | 519.9KB | 2026-06-27 13:25:45 | `a7f5a229484a…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_6_OF.csv` | .csv | 523.3KB | 2026-06-27 14:00:10 | `e5bab760297f…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_7_OF.csv` | .csv | 519.8KB | 2026-06-27 14:05:17 | `ce3083d79afc…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_8_OF.csv` | .csv | 522.6KB | 2026-06-27 14:09:50 | `d27bd3f5c493…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/APOYO - SIM/Coordenadas_Apoyo/APOYO_SIM_9_OF.csv` | .csv | 514.3KB | 2026-06-27 14:15:14 | `4b92c16eab38…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_10_OF.csv` | .csv | 276.1KB | 2026-07-03 00:52:03 | `34c839d4ce9a…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_1_OF.csv` | .csv | 284.4KB | 2026-07-03 00:01:42 | `35b8cc8b5b1c…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_2_OF.csv` | .csv | 271.6KB | 2026-07-03 00:11:10 | `1c203fdf9e48…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_3_OF.csv` | .csv | 272.7KB | 2026-07-03 00:14:42 | `0728a868e9f6…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_4_OF.csv` | .csv | 270.4KB | 2026-07-03 00:22:24 | `e03aa7316098…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_5_OF.csv` | .csv | 271.6KB | 2026-07-03 00:29:32 | `b4977bf8cfd4…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_6_OF.csv` | .csv | 272.5KB | 2026-07-03 00:32:57 | `7e28002b864d…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_7_OF.csv` | .csv | 274.5KB | 2026-07-03 00:36:10 | `7be6b6ee87a2…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_8_OF.csv` | .csv | 272.4KB | 2026-07-03 00:40:30 | `fbc9ca0dab01…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/BALANCEO - SIM/Coordenadas_Balanceo/BALANCEO_SIM_9_OF.csv` | .csv | 274.7KB | 2026-07-03 00:45:01 | `2319b3437e61…` | si | dato-crudo | OK (cabecera 1 columnas, consistente en muestra de 20 filas) |
| `SIMULADOR/FUERZA GRF - SIM/Trial00959.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `88485d2008d9…` | si | dato-crudo | OK (utf-8 valido) |
| `SIMULADOR/FUERZA GRF - SIM/Trial00960.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `8dd51e0b8fad…` | si | dato-crudo | OK (utf-8 valido) |
| `SIMULADOR/FUERZA GRF - SIM/Trial00961.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `0016a09d6279…` | si | dato-crudo | OK (utf-8 valido) |
| `SIMULADOR/FUERZA GRF - SIM/Trial00962.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `9fe702811ec7…` | si | dato-crudo | OK (utf-8 valido) |
| `SIMULADOR/FUERZA GRF - SIM/Trial00963.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `9e01562bc66b…` | si | dato-crudo | OK (utf-8 valido) |
| `SIMULADOR/FUERZA GRF - SIM/Trial00964.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `99a06df33529…` | si | dato-crudo | OK (utf-8 valido) |
| `SIMULADOR/FUERZA GRF - SIM/Trial00965.txt` | .txt | 2.1MB | 2026-06-30 13:27:02 | `3b25f815779a…` | si | dato-crudo | OK (utf-8 valido) |
| `TESIS AGUILAR - GONZALES.pdf` | .pdf | 292.5KB | 2026-08-19 14:11:05 | `9c395ca3cb8c…` | no | otro | OK (abre, capa de texto SI, ~18 paginas segun form-feed, 39542 caracteres extraidos) |

## 3. Especificación inferida

**Objetivo del proyecto (post-pivote), DOCUMENTADO (`CLAUDE.md:11`):** *"el simulador genera su propia trayectoria a partir de datos antropométricos (y otros), usando un algoritmo/modelo adoptado de literatura publicada — no creado por el equipo —, y esa trayectoria se valida contra bases de datos públicas independientes."*

**Restricción de no-circularidad, DOCUMENTADO** (sesión 23-ago-2026, `CLAUDE.md`): los tres candidatos base (Koopman 2014, Zhao 2026, Yun 2014) se construyen con datos 100% de literatura publicada; las bases públicas (Camargo, Kuopio, Winter, Maastricht, Ferber, Fukuchi) se reservan para *validar*, nunca para *calibrar* los modelos — decisión explícita del usuario para no perder validez externa.

**Estado de la validación por segmento anatómico, DOCUMENTADO** (`CLAUDE.md`, sesión 25-ago-2026): rodilla, tobillo e inclinación tibial ya tienen "mejor modelo" cerrado empíricamente (Koopman 2014 gana en los tres, con calibración afín de ganancia angular por segmento) contra la base Kuopio real (N=15). Cifras citadas textualmente en `CLAUDE.md`: rodilla r=0.998/0.920 (X/Y), tobillo r=0.998/0.985, ángulo tibial r=0.992.

**Punto no resuelto — DOCUMENTADO como pospuesto explícitamente por el usuario** (`CLAUDE.md`, banner "⚠️ POSIBLE SEGUNDO PIVOTE, TODAVÍA SIN CERRAR"): si el resultado de "mejor modelo por segmento" reemplaza el plan de ensamble de 4 candidatos (`docs/planificacion/plan_ensamble_multimodelo.md`) o es solo preparación para él, y cómo se combinan finalmente rodilla+tobillo+ángulo tibial en una sola trayectoria de plataforma (x, z, φ). Ninguna decisión debe asumirse en las fases siguientes de esta revisión sin volver a este banner.

**Revista objetivo, DOCUMENTADO (`CLAUDE.md:108`):** IEEE JTEHM, decisión vigente "hasta que se diga lo contrario" — con el matiz de que el banner de pivote (`CLAUDE.md:15`) aclara que la revista en sí "no está decidida todavía" en el marco del nuevo enfoque del generador, y que la decisión de JTEHM corresponde al plan anterior al pivote del 19-ago. INFERIDO: hay una tensión sin resolver entre estas dos afirmaciones del mismo archivo — probable candidato a hallazgo de consistencia para A2/A4, no resuelto por A1.

**Alcance explícitamente fuera de este ciclo, DOCUMENTADO** (`CLAUDE.md`, banner de pivote): protocolo de ética en revisión, captura de sujetos nuevos, recaptura vía iSen, comparaciones de fidelidad de seguimiento 3/4/6 — "no se descarta, pero hay que reorientarlo".

## Resumen

- **Filas totales del inventario:** 543 (5 agregadas + 538 individuales).
- **Archivos individuales catalogados:** 538 (505 trackeados por git + 33 sin trackear).
- **Carpetas-dataset agregadas:** 5 — `Ferber/muestra40_raw/` (40 archivos, 997M), `Fukuchi/raw/` (47, 562M), `Kuopio/raw/` (47, 1.3M), `camargo2021_piloto/` (1722, 1.3G), `yun2014_toolbox/` (149, 7.1M). Total de archivos "escondidos" tras estas 5 filas: 2005.
- **Fallas de comprobación (`FALLA:`):** 0 sobre 538 archivos individuales comprobables. Ningún `.m`, `.csv`, `.png`, `.pdf`, `.mat`, `.xlsx`/`.docx`, `.zip`, `.json`, `.py` o `.bib` individual falló su chequeo de integridad/estructura básico.
- **No comprobables (`NO COMPROBABLE:`):** 3 individuales (`.lock`, `.pyc`, `.cls` de terceros) + 5 agregadas (por regla de alcance, no por fallo real) = 8.
- **Avisos de `mlint` (no son fallas):** 35 de 92 archivos `.m` individuales tienen avisos de estilo/rendimiento (preasignación de arrays, funciones `nan*` no recomendadas, semicolons faltantes); 0 errores de sintaxis detectados en ningún `.m`.
- **Hallazgo de duplicación real (evidencia por hash, no solo nombre):** 140 de los 538 archivos individuales comparten hash SHA-256 con otro archivo del propio inventario. 123 de esos duplicados caen dentro de `Articulo de conferencia/codigos y base original/` (copia casi completa de `CODIGOS/`, `PERSONA SANA/`, `REFERENCIAS/`, `SIMULADOR/` de la raíz) y 7 dentro de `CODIGOS/CALIBRACION/EJEMPLO_PRUEBA_NO_ES_DATO_REAL/` (reuso documentado de archivos reales renombrados con mm inventados, ver `CLAUDE.md`). A1 no marca ningún archivo como candidato a borrar — esa decisión es del orquestador.
