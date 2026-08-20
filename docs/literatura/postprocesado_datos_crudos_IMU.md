# Post-procesado de datos crudos de IMU — qué sí y qué no afecta a este proyecto

> 🚨 **SUPERADO en su mayor parte — 19-ago-2026.** Este documento asumía captura de sujetos nuevos con iSen, que queda abandonada como plan vigente (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20/P-21 — se descartó capturar base propia por requerir ética). El hallazgo específico del filtro de suavizado calibrado a la velocidad del simulador sigue siendo válido si en algún momento se vuelve a medir la salida física del banco, pero no es tarea activa hoy.

**Para quién es este documento:** responde una pregunta concreta de sesión (03-ago-2026): ¿el post-procesado de los datos crudos de los IMU (iSen) tiene algo que pueda afectar los resultados del proyecto? Resumen corto: **la mayoría de los problemas clásicos de post-procesado de IMU ya están cubiertos por el diseño actual (fusión de sensores propia de iSen + protocolo de calibración estática ya planeado) — pero hay un punto real y específico de este proyecto que sí hay que resolver: el filtro de suavizado tiene que calibrarse para la velocidad real del simulador, no asumir la de marcha humana normal.**

---

## 1. Los problemas clásicos de post-procesado de IMU (literatura general)

| Problema | En qué consiste | ¿Aplica a este proyecto? |
|---|---|---|
| **Deriva de giroscopio (drift/bias)** | Si se integra la velocidad angular cruda para obtener orientación, un sesgo tan chico como 0.05°/s puede acumular ~18° de error en 6 minutos de caminata. | **Mitigado por diseño** — iSen no entrega giroscopio crudo integrado a mano, entrega orientación ya fusionada (acelerómetro+giroscopio+magnetómetro, referencia de gravedad) con corrección continua de deriva. Esto es justo la ventaja de usar un sistema comercial validado en vez de una integración casera (como habría sido el caso con el IMU de Alessandro). |
| **Ruido de alta frecuencia** | Microvibraciones, ruido de sensor. | Se resuelve con filtro pasa-bajos — el proyecto ya usa esto (`sgolayfilt` en las señales de ángulo, `filtfilt` con Butterworth en Fz). |
| **Desfase de fase por filtrado** | Un filtro mal implementado (no zero-phase) introduce retraso temporal en la señal filtrada. | **Ya resuelto en el pipeline existente** — `Validacion_Fuerza.m` ya usa `filtfilt` (zero-phase) para Fz. Aplicar el mismo criterio a los ángulos de iSen cuando se construya el pipeline de carga (`Cargar_Sujetos_CSV.m` u otro). |
| **Calidad de la calibración estática (T-pose/N-pose)** | Toda la cadena de orientación depende de que la pose de referencia inicial esté bien capturada — un error ahí se propaga a todos los ángulos posteriores. | **Ya contemplado** — el protocolo de piloto (`docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md`, sección 0) ya incluye "calibración estática (N-pose o T-pose)... practicarla antes, no improvisarla el mismo día". |
| **Interferencia magnética (yaw/rumbo)** | Estructuras metálicas o motores cerca del sensor pueden distorsionar el magnetómetro. | **No aplica al ángulo que se necesita** — el ángulo de interés es inclinación (pitch/roll, referenciado a gravedad vía acelerómetro), no rumbo (yaw, que sí depende del magnetómetro). Ver nota técnica en `CLAUDE.md`. |

## 2. El punto real que sí hay que resolver: el filtro tiene que calibrarse a la velocidad del simulador, no a la de marcha humana normal

La literatura general recomienda, para IMU en muslo/tibia a ~100 Hz, un filtro Butterworth pasa-bajos de 4to orden con corte alrededor de 5 Hz para marcha humana normal — valor consistente con el `fcorte_cinematica = 6` Hz que ya usa `Validacion_Plataforma.m` (mismo orden de magnitud). Pero la misma literatura advierte algo importante: **si la velocidad del movimiento varía respecto a la marcha humana normal, un filtro de corte fijo puede atenuar picos reales y distorsionar la duración de eventos** (subestimar transiciones, "aplanar" el pico de la curva).

**Por qué esto es directamente relevante para este proyecto:** en la sesión del 02-ago-2026 se estimó que el dial de velocidad del simulador (1-30) puede correr trials hasta **~30 veces más rápido** que la marcha real (factor de velocidad 30.2x, estimado con `REFERENCIAS/BaseDatos_Plataforma_Apoyo.mat`, ver `docs/literatura/literatura_GRF_protesica.md`). Un filtro pensado para la frecuencia de un ciclo de marcha humano normal (~1-2 Hz de frecuencia fundamental) puede ser completamente inadecuado para una curva del simulador corriendo 30 veces más rápido — el contenido de frecuencia relevante de la señal se corre hacia arriba proporcionalmente a la velocidad, y un filtro de 5-6 Hz fijo podría estar cortando información real de la curva rápida, o dejando pasar ruido que en marcha normal habría sido descartado.

**Qué hacer con esto (no es una limitación bloqueante, es un chequeo pendiente):**
- Al procesar los datos del propio simulador con iSen (no los de los sujetos, que sí caminan a velocidad humana normal), **no asumir el mismo corte de filtro que se usa para los sujetos** — evaluar el contenido de frecuencia real de la señal del simulador (por ejemplo con un espectro de Fourier rápido) antes de fijar el corte, en vez de reusar 5-6 Hz por costumbre.
- Los sujetos nuevos (captura natural, marcha humana real) sí pueden usar el corte estándar de la literatura (5-6 Hz) sin este problema — el punto de atención es específicamente para las curvas de salida del simulador cuando corre a velocidad no-humana.

## 3. Resumen — respuesta directa a la pregunta de la sesión

**¿El post-procesado de datos crudos de IMU tiene algo que afecte los resultados?** Mayormente no, porque el diseño actual (fusión de sensores propia de iSen + calibración estática ya planeada + filtro zero-phase ya usado en el proyecto) ya cubre los problemas clásicos de la literatura. **Sí hay un punto concreto a resolver**, específico de este proyecto y no genérico de IMU: el filtro de suavizado para las curvas del simulador necesita calibrarse a la velocidad real de operación del simulador (potencialmente ~30x la marcha humana), no asumir el corte estándar de marcha humana normal que sí es válido para los sujetos.

## 4. Fuentes consultadas

- [MGait: Model-Based Gait Analysis Using Wearable Bend and Inertial Sensors (arXiv)](https://arxiv.org/pdf/2102.11895)
- [Development of an IMU-Based Post-Stroke Gait Data Acquisition and Analysis System (PMC)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11991240/)
- [IMU machine learning: preprocessing and alignment (Fibion)](https://web.fibion.com/articles/preprocess-align-imu-coordinates/)
- [Improved running gait parameter estimation from single foot-mounted IMU data based on refined event detection (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12835337/)
