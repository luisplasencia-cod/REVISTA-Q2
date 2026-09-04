---
Estado: enfoque confirmado por Luis, revista recomendada bajo criterio JCR (no Scimago,
la universidad exige JCR) — 03-sep-2026, corregido el mismo día tras verificación
adicional. Reemplaza y fusiona dos documentos ya borrados: `enfoque_validacion_fisica_altura_GRF.md`
(el reencuadre del resultado físico) y `analisis_revistas_Q1_generador.md` (27-ago,
búsqueda de revista calculada ANTES de este reencuadre, con candidatas ya
desactualizadas). Plazo: redacción del Q1 en menos de un mes desde el 03-sep-2026.

**BLOQUEANTE antes de someter a cualquier revista de esta lista:** Camargo et al. 2021
(validación pendiente, ver informe técnico, Limitaciones) — es la pieza que el propio
proyecto ya identificó como el examen final de no-circularidad, y la que un revisor de
una revista real de este perfil (biomecánica computacional + validación multi-dataset)
más probablemente pediría si falta. No es opcional, no es "nice to have".
---

# Enfoque y revista — artículo Q1 (generador de trayectorias)

## Enfoque

El generador produce, desde solo la talla, la trayectoria de un punto de la
prótesis (tobillo, o cualquier punto del segmento tibial vía distancia de
montaje) — validado en cinemática contra bases públicas independientes: Kuopio
(N=47, calibración LOSO), Ferber (N=40, validación externa, ambas ya cerradas),
y Camargo (N=22, examen final de no-circularidad, pendiente de ejecutar).

Además del generador, se propone un resultado físico end-to-end: subir la
trayectoria del **punto de montaje** (no tobillo/rodilla sueltos — es el punto
real donde se monta cada prótesis, la distancia se ingresa por ensayo, sin
default, porque distintas prótesis tienen distinto eje) al banco físico, y
barrer distintas alturas iniciales de arranque (protocolo en
`docs/algoritmo/protocolo_calibracion_altura_GRF.md`), midiendo el GRF real en
la plataforma de fuerza en cada una. El banco no tiene ningún canal para
programar fuerza directamente — solo movimiento — así que el peso **deja de
ser una entrada** del ensayo físico y pasa a ser una **interpretación de la
salida**: se invierte el modelo de software ya validado
(`Predecir_GRF_Personalizado_Core.m`) para leer "este GRF a esta altura
equivale a qué masa", repetido en 3-4 tallas.

**Límites declarados, no ocultos:** (1) no hay captura de movimiento disponible
para verificar que el banco ejecuta la posición/ángulo real — el resultado
físico es únicamente sobre GRF, y un buen GRF es evidencia necesaria pero NO
suficiente de que la trayectoria ejecutada es correcta; (2) el GRF medido
incluye la masa estructural del propio banco (confusor no cuantificado, según
el paper de conferencia relacionado) — declarar la curva altura↔GRF como
propiedad del sistema completo, no una medida aislada de "peso de persona";
(3) el banco corre ~30x más lento que la marcha real, así que el GRF medido es
casi cuasi-estático (compresión tipo Hooke), no dinámico.

**No se cita ni referencia** el paper de conferencia relacionado (mismo banco,
mismo laboratorio, ya aceptado mas no publicado hasta fin de 2026) — decisión
explícita de Luis, mantenida pese al riesgo de perder una motivación "nuestro
trabajo previo mostró que..." — el Q1 se sostiene con literatura independiente.

## Aporte

Dos piezas genuinamente nuevas, no una sola:
1. **Metodológica:** un generador de trayectoria de marcha desde antropometría
   mínima (solo talla), validado contra 2 bases públicas independientes con
   una tercera reservada — no un ajuste a un solo sujeto.
2. **Instrumentación/calibración de sistema** (no un hallazgo biomecánico
   nuevo): un protocolo para que un banco sin canal de fuerza programable
   pueda representar, vía altura, el GRF esperado de un peso específico —
   útil para cualquier simulador con la misma limitación de actuación.

## Revistas candidatas (bajo criterio JCR — la universidad de Luis exige JCR, no Scimago)

**1. Computers in Biology and Medicine (Elsevier — aprobada) — recomendación principal bajo JCR.**
Q1 confirmado en JCR en dos categorías (Biology, y Computer Science, Interdisciplinary
Applications; dato 2023, la edición más consistente entre fuentes verificadas
03-sep-2026). IF alto (6.3-8.35 según fuente). APC Gold OA = USD 3080 (sobre el tope
de 2500 — solo importa si se opta por OA; vía suscripción no aplica). Buen encaje si
el manuscrito se redacta con más peso en el pipeline computacional (generador +
calibración como sistema) que en biomecánica pura — ver "Precedentes" abajo.

**2. Journal of Biomechanics — NO CONFIRMADA en JCR, verificar antes de comprometerse.**
Reevaluada 03-sep-2026 con más cuidado tras la corrección de Luis (JCR, no Scimago).
Evidencia encontrada, contradictoria pero con más peso hacia Q3: 3 fuentes
independientes (journalmetrics.org, wos-journal.info, una búsqueda agregada sobre
"Q3 en Medicine") coinciden en **Q3 en JCR** con IF≈2.3-2.4 (dato de ScienceDirect/
Elsevier: IF 2024 = 2.343, CiteScore = 4.9) — consistente entre sí. Una única fuente
(journalmetrics.org) afirma un salto a Q1 con IF 2.9 en "datos 2025, actualizado junio
2026", sin poder confirmarse contra el JCR oficial de Clarivate (mjl.clarivate.com no
devolvió el dato completo por bloqueo de acceso). **Con la evidencia disponible hoy,
tratarla como Q3/NO-Q1 en JCR — no usarla sin que alguien con acceso institucional a
Web of Science/InCites de PUCP confirme el cuartil real directamente.** Antes candidata
principal (bajo Scimago); bajo JCR pasa a no confirmada.

**3. Gait & Posture — descartada bajo JCR.** Q2 en JCR-Engineering (ya verificado antes),
aunque Q1 en Scimago. Como la universidad exige JCR, queda fuera de la lista de
candidatas viables — se mantiene aquí solo por trazabilidad de la pregunta que esto
resolvió.

## Precedentes en las revistas candidatas (búsqueda 03-sep-2026)

**No se encontró un precedente cercano y verificado** que combine, publicado
específicamente en Computers in Biology and Medicine, las dos piezas de este proyecto
a la vez (generador de trayectoria desde antropometría pura + calibración de un banco
físico vía altura vs. GRF) — búsqueda explícita, sin forzar coincidencias débiles.

Lo que sí se confirma con la búsqueda: **CBM sí publica de forma activa contenido de
modelado cinemático de marcha y validación biomecánica computacional** (encaje temático
general confirmado, no solo alcance declarado de la revista) — sin una referencia
puntual lo bastante cercana como para citarla como precedente directo.

**Literatura relacionada encontrada, relevante para la Introducción/Discusión del
manuscrito (ninguna está todavía en `referencias_informe.bib`, confirmar si aplica
citarlas):**
- *GaitDynamics: a generative foundation model for analyzing human walking and running*
  (Nature Biomedical Engineering, 2026) — modelo generativo que estima GRF desde
  cinemática; relevante como referencia de "estado del arte" en generación de marcha,
  pero en una revista de otro perfil (no candidata para este artículo).
- *Benchmarking the predictive capability of human gait simulations* (PLOS
  Computational Biology, 2025) — evalúa si simulaciones a partir de antropometría
  predicen cinemática/cinética medida; comparable en motivación a este proyecto, útil
  como referencia de contraste metodológico.
- Sudeesh, Shunmugam & Sujatha 2024 (*Med. Eng. Phys.*, doi:10.1016/j.medengphy.2024.104254,
  "compact and cost-effective gait simulator...reduced reliance on human subject
  testing") — YA CITADA en el paper de conferencia relacionado (ref. [21]), no es
  hallazgo nuevo; se menciona aquí solo para no perderla de vista, en una revista ya
  descartada por cuartil.

## Preguntas abiertas

1. **Journal of Biomechanics: ¿alguien con acceso a Web of Science/InCites de PUCP
   puede confirmar el cuartil JCR real?** La búsqueda web da evidencia mayoritaria de
   Q3, pero no es la fuente oficial — mientras no se confirme, no usarla como candidata.
