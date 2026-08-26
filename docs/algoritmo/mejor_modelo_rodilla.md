# Mejor modelo para la RODILLA — cerrado 24-ago-2026

**Contexto:** el usuario pidió abandonar el intento de combinar/promediar los 4 candidatos (Koopman/Zhao/Yun/Romero-Sorozábal) y en su lugar ir parte por parte: primero encontrar el mejor modelo individual para la RODILLA, evaluado con datos antropométricos (sexo/talla/peso) contra bases reales — sin usar Camargo ni Kuopio, reservadas para la validación final del proyecto.

## Resultado: **Koopman 2014 gana, sin excepción, en las 3 fuentes reales independientes probadas**

| Fuente real | n | Qué se comparó | Koopman | Zhao | Yun |
|---|---|---|---|---|---|
| `REFERENCIAS/Control_apoyo_Luis_V4.csv` + balanceo | 1 (sujeto del proyecto) | ángulo tibial, ciclo completo | **r=0.982** | r=-0.21 | r=-0.28 |
| Winter, *Biomechanics and Motor Control of Human Movement*, Tabla A.1 (marcadores crudos) | 1 (sujeto clásico del libro) | rodilla relativa a cadera (X) | **r=0.816** | r=0.613 | r=0.468 |
| **Maastricht Normative 3D Gait Dataset** (OSF, ver abajo) | 246 (subgrupo hombres 18-29 usado) | flexión de rodilla nativa, %ciclo completo | **r=0.933, RMSE=7.6°** | r=-0.30, RMSE=32° | r=-0.33, RMSE=31° |

Con la fuente más grande y estadísticamente más sólida (Maastricht, n=246), Koopman reproduce la forma de doble pico real (bache pequeño de apoyo ~15° a ~15% del ciclo, pico grande de balanceo ~60° a ~70%) con error de solo 7.6°. Zhao y Yun ni siquiera reproducen el patrón de dos picos — su fase está desalineada con el ciclo real (ver `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Maastricht_figura.png`).

**Decisión: para la RODILLA, se usa Koopman 2014 en solitario — no un promedio de los 4.** Esto reabre la pregunta (todavía sin decidir, ver `docs/planificacion/plan_ensamble_multimodelo.md`) de si el "ensamble" de 4 modelos sigue siendo el plan vigente para el artículo, o si el hallazgo de hoy inclina la balanza hacia "un modelo ganador por pieza anatómica" en su lugar. **No se cerró esa decisión de fondo todavía** — el usuario la pospuso explícitamente para después de completar tobillo y ángulo.

## Hallazgo lateral: bug de signo encontrado y corregido en el camino

Al calcular "rodilla relativa a cadera" con la misma convención de signo ya verificada para la TIBIA (`Cadena_Cinematica_Core.m`, G7), los 3 candidatos angulares dieron correlación **negativa** contra Winter — los 3 al mismo tiempo, señal clara de una fórmula con signo invertido, no de un problema real de los 3 modelos. Con el signo del MUSLO invertido (`+sin(theta_muslo)` en vez de `-sin`), los 3 se volvieron positivos con la misma magnitud (Koopman pasó de r=-0.816 a r=+0.816). **El signo del muslo NO hereda automáticamente el signo ya verificado de la tibia** — son articulaciones distintas, cada una necesita su propia verificación empírica contra dato real. Corregido en `CODIGOS/GENERADOR/RODILLA/Evaluar_vs_Winter.m`.

## Bases de datos nuevas incorporadas al proyecto

### Winter (n=1, sujeto clásico del libro)
- `CODIGOS/GENERADOR/RODILLA/Winter_Appendix_data.xlsx` — Tabla A.1 (coordenadas crudas cadera/rodilla/tobillo/talón/metatarso/dedo, cm), Tabla A.4 (ángulos articulares relativos), digitalizada por un tercero desde el apéndice del libro de Winter, *Biomechanics and Motor Control of Human Movement* (fuente: dustynrobots.com/academia/research/winters-gait-data-in-excel-form).
- `Extraer_Winter_CSV.m` extrae cadera/rodilla/tobillo a `Winter_Cadera_Rodilla_Tobillo.csv` (106 cuadros, ~71.4Hz, ~1.5s, avance real continuo ~216cm).
- **Advertencia declarada:** es UN sujeto (n=1), sin antropometría documentada en el archivo (no se sabe su sexo/talla/peso reales) — muy citado pedagógicamente pero no es una base poblacional. Sirve de chequeo rápido de forma, no de validación con N.

### Maastricht Normative 3D Gait Dataset (n=246) — **el más fuerte de los dos**
- Fuente: OSF https://osf.io/t72cw/ (CC BY, "Normative 3D gait data of healthy subjects walking at three different speeds on an instrumented treadmill in virtual reality"). 246 adultos sanos, 122 hombres/124 mujeres, edad 18-93 años.
- **Antropometría por sujeto:** sexo, edad, masa corporal (kg), talla (m), longitud de pierna (m, medida real espina ilíaca→maléolo), BMI (`01_Demo_PhysEx.xlsx`).
- **Contenido:** SOLO ángulos articulares (flexión/extensión, ab/aducción, rotación de tronco/pelvis/cadera/rodilla/tobillo) + parámetros espaciotemporales + fuerzas/momentos/potencia — **NO incluye coordenadas de marcadores/posición cruda** (corrección de una lectura inicial equivocada — no hay archivos `.mox` públicos en este repositorio, solo Excel procesados).
- 3 velocidades (`comf`/`fast`/`slow`), pierna izquierda y derecha, por sujeto individual (`HACxxx_X.xlsx`, no descargado — sería 246 archivos) o agregado por grupo de edad/sexo (`AgeGenderGroups_X.xlsx`, el que se usó hoy) o por sujeto individual resumido (`Overview_X.xlsx`, ~20MB, no descargado todavía).
- Descargado en `CODIGOS/GENERADOR/RODILLA/Maastricht/`: `28_Description_parameters.docx` (codebook), `01_Demo_PhysEx.xlsx` (antropometría), `05_AgeGenderGroup_comf.xlsx` (curvas de ángulo por grupo, velocidad cómoda).
- **Usado hoy:** hoja `Rotation_RKneeFlex_comf`, columnas "hombres 18-29 años" (media + DE), como referencia para elegir el mejor modelo de rodilla.
- **Pendiente si se necesita mayor precisión:** descargar `Overview_comf.xlsx` (per-sujeto) para comparar con la talla/masa/sexo EXACTOS de cada sujeto real, en vez del promedio de grupo de edad — hoy se usó el grupo (n=subset de 246), no sujeto por sujeto.

## Cierre 25-ago-2026: confirmado con N=40 y antropometría real (posición, no solo ángulo)

Ver `CODIGOS/GENERADOR/RODILLA/CIERRE_RODILLA.md` (documento de cierre completo, estructurado, con las 4 secciones que pidió el usuario: modelo, por qué se descartan los otros, comparación con la base, desplazamiento horizontal+vertical). Resumen: se incorporó **Ferber et al. 2024** (Scientific Data, n=1798, Figshare+) como la prueba decisiva — a diferencia de Maastricht (solo ángulo, grupo de edad) y Winter (posición real pero sin antropometría documentada), Ferber tiene sexo/talla/peso **reales por sujeto**, "seteables" en el modelo uno a uno (criterio explícito del usuario del 24-ago). Muestra de 40 sujetos sanos, posición 3D real de rodilla reconstruida (el dataset no la trae calculada) corriendo el pipeline oficial de los autores. Resultado: **Koopman r_x=0.945, r_y=0.791** (rodilla relativa a cadera — hallazgo lateral real: relativa a un tobillo fijo, como asume `Cadena_Cinematica_Core.m` para el simulador, da r=-0.41 en marco de laboratorio, porque el tobillo SÍ se mueve en el balanceo real).

## Qué sigue

Pendiente por decisión del usuario: repetir el mismo proceso para el TOBILLO, y luego para el ángulo de inclinación tibial, antes de decidir cómo se juntan los 3 (y si eso reemplaza definitivamente el plan de ensamble de 4 modelos).
