---
Estado: PROPUESTA SIN IMPLEMENTAR — planteamiento nuevo del usuario, 30-ago-2026.
No confundir con el informe técnico ya escrito (informe_tecnico_generador/) ni con
el generador ya construido (CODIGOS/GENERADOR/) — nada de lo de acá está aplicado
todavía en ninguno de los dos. El usuario pidió explícitamente guardar esto para
retomarlo en otra sesión porque no estaba seguro de que quedara bien entendido.
---

# Propuesta: anclar la trayectoria a alturas absolutas reales, no solo relativas

## 1. El punto de partida — qué existe hoy

El generador (`Generar_Trayectoria.m`, Paso 4) calcula posición **relativa**: el
tobillo arranca en `(0,0)` (o con el residuo de rockers sumado) y todo lo demás se
construye por rotación de segmentos rígidos encima de eso. El CSV final que lee el
simulador se normaliza a `(0,0)` en el primer punto — el simulador nunca necesita
saber la altura real sobre el piso, solo la forma relativa del movimiento.

Separado de eso, `Estimar_Antropometria_Core.m` calcula (a partir de la talla $H$,
fracciones de Drillis & Contini 1966, verificadas contra Winter Fig. 4.1):
- $L_{muslo}=0.245H$, $L_{tibia}=0.246H$, $L_{pie}=0.152H$ (estas SÍ se calculan y
  se usan como variables reales del pipeline)
- Alturas de segmento parado (cadera=0.530H, rodilla=0.285H, tobillo=0.039H) — estas
  **NO se calculan en el código como variable real**, solo aparecen como álgebra
  intermedia en el informe para explicar de dónde salen las restas de arriba. Hoy
  se reutilizan sueltas y por separado en dos lugares menores: 0.530H de nuevo
  (hardcodeado aparte) en `Estimar_Velocidad_Froude_Core.m` para la "L" de Froude, y
  0.285H solo como offset cosmético de un script de visualización de ejemplo
  (`Ver_Resultado_Final.m`), sin conexión con el pipeline real.

## 2. La idea del usuario, en su forma final

Encadenar dos anclas de altura **absoluta** (independientes de la geometría
relativa que ya se usa) para poder calcular la posición absoluta real en cualquier
punto del ciclo, no solo relativa:

1. **Ancla 1 — postura parada** (ya tenemos los números, de la literatura de
   Drillis & Contini/Winter): con origen `(0,0)` en la planta del pie sobre el
   piso, parado derecho ($\theta=0$ en todo), las coordenadas son exactas y
   triviales (no hace falta ningún ángulo, es geometría de postura recta):

   | Punto | X | Y |
   |---|---|---|
   | Tobillo | 0 | $0.039H$ |
   | Rodilla | 0 | $0.285H$ |
   | Cadera  | 0 | $0.530H$ |

2. **Ancla 2 — un punto conocido, INDEPENDIENTE de Kuopio, en un % específico del
   ciclo de marcha real** (no parado): la idea es buscar en la literatura un valor
   de altura absoluta real (no relativa) de tobillo/rodilla/cadera/pie, medido en
   sujetos reales, en un instante conocido del ciclo — para no depender otra vez de
   Kuopio (que ya se usa para calibrar, reusarla aquí sería circular) ni de ningún
   supuesto de "pivote fijo" sin verificar.

3. Con las dos anclas fijas y los ángulos reales de Koopman para todo el resto del
   ciclo, la idea es que el resto de las coordenadas "saldría matemáticamente
   bien" — y que eso serviría para **justificar/validar** puntos concretos de la
   geometría con literatura independiente, no para reemplazar de raíz el pipeline
   ya construido.

## 3. Lo que ya se analizó en esta sesión — hallazgo importante, no obvio

**Usar SOLO el Ancla 1 (postura parada) como si el tobillo se quedara fijo ahí
durante todo el ciclo es matemáticamente equivalente al supuesto de "pivote fijo"
que YA está en el Paso 4** — la única diferencia es la constante de arranque (antes
`0`, ahora `0.039H`). Se verificó el álgebra: con $\theta_{tibia}(0)=0$ (parado),
$0.039H + L_{tibia}\cdot\cos(0) = 0.039H+0.246H = 0.285H$ — coincide exacto con la
altura de rodilla parado, confirmando que la fórmula es consistente, pero **hereda
el mismo error ya conocido** (el tobillo real sí se mueve un poco en apoyo, el
mecanismo de *rockers*, ya cuantificado con Kuopio: -0.67 a -3.08cm en Y). Cambiar
la constante de `0` a `0.039H` no elimina ese error — solo cambia dónde está el
"cero" del que se mide.

**Por eso el Ancla 2 (independiente, en un % específico del ciclo) es la pieza que
realmente aportaría algo nuevo** — no para reemplazar el residuo ya construido,
sino como una validación/justificación adicional en un punto puntual, con una
fuente distinta a la que ya se usó para calibrar.

## 4. Candidato encontrado para el Ancla 2: Minimum Toe Clearance (MTC)

Búsqueda web hecha en esta sesión (no toda verificada a texto completo todavía —
ver §5 para el estado real de verificación):

- **MTC** = altura mínima que alcanza la punta del pie sobre el piso durante el
  balanceo — variable muy estudiada en biomecánica de marcha (por su relación con
  el riesgo de tropiezo), medida en decenas de estudios de laboratorio
  independientes entre sí, sin relación con Kuopio ni Camargo.
- Ocurre aproximadamente a mitad del balanceo (~45-51% del balanceo según distintas
  fuentes secundarias, sin verificar a texto completo cuál es el % exacto ni si es
  consistente entre estudios).
- Se normaliza en la literatura por longitud de pierna (MTC/leg) — es decir, ya
  viene en una forma escalable con la talla, compatible con lo que necesita este
  proyecto.
- Es la altura de la **punta del pie**, no directamente tobillo/rodilla/cadera —
  para conectarlo hace falta la geometría del pie: altura de punta $\approx$
  altura del tobillo $+ L_{pie}\cdot\sin(\theta_{pie})$, con $L_{pie}=0.152H$ (ya
  calculado, confirmado en `Estimar_Antropometria_Core.m`) y $\theta_{pie}$ (ya
  existe en el proyecto, usado antes en la reducción tibial "vía tobillo" —
  descartada para el ángulo tibial, pero la señal de $\theta_{pie}$ en sí sigue
  siendo calculable).

## 5. Fuente identificada, estado de verificación (regla del proyecto: nunca fijar
   una cita sin verificar a texto completo)

> Winter, D.A. (1992). "Foot Trajectory in Human Gait: A Precise and
> Multifactorial Motor Control Task." *Physical Therapy*, 72(1), 45-53.
> PMID 1728048.

- **Verificado contra el abstract de PubMed** (no el PDF completo — el repositorio
  de Marquette University devolvió 403 al intentar el fetch directo): toe
  clearance mínimo = **1.29 cm**, variabilidad **$\approx$4mm (SD)**, $N=11$
  sujetos, 10 ensayos repetidos cada uno, durante la fase de balanceo.
- El abstract **NO especifica** el % exacto de balanceo en que ocurre el mínimo, ni
  si normaliza por longitud de pierna — eso solo apareció en fuentes secundarias
  sin verificar, no en este abstract.
- Mismo autor (Winter) que ya cita el proyecto (Winter 2009, para las fracciones
  de segmento) — no es casualidad, es la referencia clásica del campo.
- **Dato honesto, declarado:** el valor de MTC varía entre estudios — una fuente
  secundaria (sin verificar a fondo) menciona un rango de 0.85 a 3.5cm citando 7
  estudios distintos (Begg 2007, Johnson 2007, Mills & Barrett 2001, Moosabhoy &
  Gard 2006, entre otros). El 1.29cm de Winter 1992 es defendible por ser la
  fuente clásica más citada y del mismo autor ya usado en el proyecto, pero no es
  "el número universal".

## 6. Qué falta para poder usar esto (pendiente, bloqueado)

1. **Texto completo del paper** — el PDF del repositorio de Marquette dio 403; se
   le pidió al usuario abrirlo con su acceso institucional PUCP (Physical Therapy
   / Oxford Academic), igual que se hizo antes con Piche 2022 en este mismo
   proyecto. **Sin respuesta todavía cuando se guardó este documento.**
2. Con el texto completo, confirmar: el % exacto de balanceo del mínimo, si
   normaliza por longitud de pierna (y con qué factor), y la velocidad de marcha
   usada en el estudio (para saber si es comparable al rango de velocidades que
   usa este generador).
3. Decidir la geometría exacta para conectar tobillo→punta del pie
   ($\theta_{pie}$, qué convención de signo, ya hay precedente en el proyecto de
   la reducción "vía tobillo" pero fue descartada para el ángulo tibial —
   confirmar si sigue siendo válida para este uso distinto).
4. Decidir si esto se implementa como (a) una validación/justificación puntual en
   el informe (barato, solo un chequeo de consistencia en un punto), o (b) una
   pieza real del generador (más caro, cambiaría cómo se ancla la trayectoria).

## 7. Explícitamente NO hecho todavía

- No se tocó `Generar_Trayectoria.m` ni ningún otro `.m` del generador.
- No se agregó nada de esto al informe (`informe_tecnico_generador.tex`) — lo
  único que se tocó ahí en esta sesión fue el reordenamiento de secciones y los
  recuadros Entra/Sale de los Pasos, que son cambios **distintos y ya cerrados**,
  sin relación con esta propuesta.
- No se fijó ninguna cita ni número de este documento en ningún lugar citable
  todavía — sigue en estado "propuesta, sin verificar a texto completo".
