# Contrato del generador — entrada/salida congelada

**Creado:** 23-ago-2026, E1 de `docs/planificacion/plan_100_generador.md`. Formaliza el contrato ya descrito en ese plan §1 y las decisiones D1/D2 de §3.

---

## Entrada

| Campo | Unidad | Obligatorio | Fuente si falta |
|---|---|---|---|
| `talla_m` | m | sí | — |
| `masa_kg` | kg | sí | — |
| `sexo` | `'M'`/`'F'` | sí | — |
| `edad_anios` | años | no | valor por defecto 25 (rango de validez de de Leva 1996: adultos jóvenes) |
| `long_muslo_m` | m | no | estimado de de Leva 1996 desde talla |
| `long_tibia_m` | m | no | estimado de de Leva 1996 desde talla |
| `velocidad_ms` | m/s | no | **D2: derivada** de `long_pierna_m` vía relación de Froude (E4) |
| `punto_seguimiento_m` (opción de `Generar_Trayectoria`, no de `antropometria`) | m, desde el tobillo | no | default = `long_tibia_m` (rodilla anatómica). Ver §"Punto de seguimiento" abajo |

**Regla:** cualquier campo opcional que SÍ se mida (p. ej. longitud de tibia real de una cinta métrica) tiene prioridad sobre el valor estimado — el generador nunca sobrescribe un dato medido.

**E3 cerrado (23-ago-2026):** `Estimar_Antropometria_Core.m` implementa las fracciones de talla de Drillis & Contini 1966 (verificadas directamente contra la figura fuente, Winter *Biomechanics and Motor Control of Human Movement* Fig. 4.1 — no contra un resumen): muslo = 0.245×talla, tibia = 0.246×talla, pie = 0.152×talla. **Validado contra AB06 real (Camargo): tibia estimada 0.4428 m vs. medida 0.446 m, error −0.7%.**

## Salida

Dos archivos, formato **idéntico** al que ya lee el simulador (verificado contra `REFERENCIAS/Control_apoyo_Luis_V4.csv` y `Control_balanceo_Luis_V4.csv` reales, y contra `Desplazamientos.m`/`Angulo_Control_Plataforma.m`):

```
Control_apoyo_<ID>.csv
Control_balanceo_<ID>.csv

Encabezado : Tiempo_sagital_<fase>;Posicion_cm_X_<fase>;Posicion_cm_Y_<fase>;Angulo_sagital_<fase>;;;
Separador  : ;
dt         : 0.01 s
Resol. X   : 0.0125 cm  (cuantizado, round a este paso)
Resol. Y   : 0.00625 cm (cuantizado, round a este paso)
Resol. ang.: 0.009 °    (cuantizado, round a este paso)
X,Y        : posición de la RODILLA en el plano sagital, arrancan en (0,0)
             en CADA fase por separado (normalizeDisp: d - d(1))
Ángulo     : atan2(avance, vertical) entre marcadores rodilla-tobillo,
             0° = tibia vertical, rango real de referencia: -50° a +22°
Sin recorte de amplitud (D1) — la longitud de paso es 100% anatómica,
el ajuste a los límites físicos del banco es tarea de la ETAPA DE EJECUCIÓN,
no de este generador.
```

## Contrato de la función

```matlab
function out = Generar_Trayectoria(antropometria)
% antropometria: struct con los campos de la tabla de Entrada
%
% out.apoyo.t_s, out.apoyo.x_cm, out.apoyo.y_cm, out.apoyo.angulo_deg
% out.balanceo.t_s, out.balanceo.x_cm, out.balanceo.y_cm, out.balanceo.angulo_deg
% out.metadatos: candidato usado, T_ciclo_s, T_apoyo_s, velocidad_ms,
%                longitudes usadas (medidas vs. estimadas), version
```

`Escribir_CSV_Simulador.m` (E8) consume esta salida y escribe los dos `.csv`. Separar "generar" de "escribir" deja `Generar_Trayectoria` testeable sin tocar disco.

## Punto de seguimiento — no siempre es la rodilla (2ª pasada, 23-ago-2026)

**Hallazgo del usuario, no de literatura:** el marcador/sensor que produjo `Control_apoyo_Luis_V4.csv` no estaba puesto exactamente en la articulación de la rodilla — estaba a una distancia aproximada de **0.38 m desde el tobillo**, a lo largo de la tibia. Es un detalle de montaje físico del equipo (dato operativo del propio usuario, no requiere cita externa), y antes de esta revisión el generador **siempre** asumía que el punto seguido era el extremo del segmento (la rodilla anatómica, distancia = `long_tibia_m`).

**Solución:** `Cadena_Cinematica_Core.m` y `Generar_Trayectoria.m` ahora aceptan `opciones.punto_seguimiento_m` — la distancia (m) desde el tobillo hasta el punto real que se quiere seguir. Default sin cambios (= `long_tibia_m`, la rodilla). La geometría es directa (mismo segmento rígido, mismo ángulo, solo cambia cuánto se avanza por esa dirección desde el tobillo — ver derivación completa en el docstring de `Cadena_Cinematica_Core.m`).

**Por qué NO se fijó 0.38 m como default:** no tenemos la longitud de tibia real del sujeto "Luis" documentada en el proyecto (revisado `PERSONA SANA/` y todos los `.md`, sin resultado) — sin ese dato no se puede confirmar que 0.38 m sea un punto físicamente válido de *su* segmento específico (podría ser inconsistente para otro sujeto con tibia más corta). El parámetro queda expuesto y documentado; usar 0.38 m es una decisión del llamador, no un valor inventado por el generador.

## Estado de implementación (23-ago-2026)

**Cerrado — E1 a E9 de `plan_100_generador.md`, 22/22 + 14/14 pruebas PASS en MATLAB real:**

| Etapa | Archivo | Qué hace |
|---|---|---|
| E1 | este documento | Contrato entrada/salida |
| E2 | `Yun2014_Wrapper.m`, `Koopman2014_Core.m` | Signo de cadera/rodilla determinado empíricamente, vía-rodilla habilitada |
| E3 | `Estimar_Antropometria_Core.m` | Muslo/tibia/pie desde talla (Drillis & Contini 1966, verificado a la fuente) |
| E4 | `Estimar_Velocidad_Froude_Core.m`, `Tiempo_Ciclo_Koopman2014_Core.m`, `Temporizacion_Core.m` | Velocidad (Froude), duración de ciclo, partición 60/40 |
| E5 | `Cadena_Cinematica_Core.m` | Posición de rodilla relativa a tobillo (modelo de péndulo invertido) |
| E6 | integrado en `Generar_Trayectoria.m` | Traslación horizontal en balanceo (v·t), sin recorte (D1) |
| E7 | `Segmento_Posicion_Core.m` (ya existía) | Convención atan2/vertical, ya verificada |
| E8 | `Escribir_CSV_Simulador.m` | CSV con header idéntico byte a byte al real |
| E9 | `Test_Generador_Trayectoria.m` | 14/14 PASS, incluida escritura y relectura real de CSV |

**Función de entrada única:** `Generar_Trayectoria(antropometria, candidato)` → struct con `.apoyo`/`.balanceo` → `Escribir_CSV_Simulador(...)`.

**Limitaciones declaradas, no ocultas (ver `CODIGOS/GENERADOR/GUIA_INTERPRETACION.md` para el detalle completo):**
1. Yun y Zhao muestran un pico de flexión de rodilla adelantado (~20-25% del ciclo) frente al normativo (~70%) — afecta la vía-rodilla de Yun (por eso se excluye, usa vía-tobillo en ambas fases) y es inherente a la salida nativa de Zhao (sin alternativa). Sin resolver, pendiente de Nivel A/B contra Camargo.
2. La velocidad estimada por Froude (Fr=0.25) excede el rango validado de Koopman (0.5-5 kph) para la mayoría de adultos — advertencia activa, no bloqueante, declarada.
3. El signo de "+Y" del modelo cinemático (E5) no está cruzado todavía contra el sentido real de `Posicion_cm_Y` de los CSV del proyecto (solo se verificó el rango/convención angular, no el signo vertical de posición) — ver nota en `Cadena_Cinematica_Core.m`.
4. Modelo de péndulo invertido con tobillo fijo + traslación lineal en balanceo — no es la cadena de muslo completa (diferida, `GUIA_INTERPRETACION.md` §5-ter), es la aproximación de primer orden más simple y justificada dado el alcance de este plan.

## Trazabilidad de justificación (regla del proyecto: nada sin respaldo)

Cada número que entra en la fórmula de E4/E6 debe citar su fuente en un comentario del código: paper + ecuación/tabla, o "medido directo de Camargo AB06/AB09" (nunca de los 22 completos, por la regla de no-circularidad — Camargo es solo examen final). Si una relación no tiene cita verificada a texto completo, se marca `% [SIN VERIFICAR]` y se declara en `GUIA_INTERPRETACION.md`, nunca se inventa un coeficiente.
