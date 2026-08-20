# Guía de autor — IEEE JTEHM (Journal of Translational Engineering in Health and Medicine)

> 🚨 **REVISTA REABIERTA — 19-ago-2026.** El pivote de enfoque (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20) dejó la revista **sin decidir** — puede seguir siendo JTEHM (Q2) o moverse a algo tipo IEEE TNSRE (Q1), según lo que recomendaba `planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` §11. Esta guía se conserva íntegra por si JTEHM se reconfirma, pero **no asumir que aplica** hasta que se cierre la decisión de revista.

**Estado:** revista **decidida** el 03-ago-2026, vigente hasta que se diga lo contrario (ver `CLAUDE.md`). Quinta y última vuelta de la decisión de revista de esta sesión — reemplaza POI, Bioengineering y Prosthesis, evaluadas antes en la misma sesión.

**Actualizado 03-ago-2026 (misma sesión, más tarde) contra la plantilla oficial real** que el usuario descargó de IEEE (`docs/manuscrito/JTEHM_LaTex_Template/`) — corrige dos cosas que la página pública de instrucciones no dejaba claras o decía distinto. Ver el detalle en las secciones 3 y 4 de abajo, marcado explícitamente dónde cambió.

**Para quién es este documento:** todo lo verificado directamente en las páginas oficiales de JTEHM (`embs.org/jtehm`) sobre cómo tiene que estar armado el manuscrito — para no descubrir una restricción de formato a último momento.

---

## 1. Enlaces oficiales

- **Página principal:** https://www.embs.org/jtehm/
- **Instrucciones para autores:** https://www.embs.org/jtehm/instructions-for-authors/
- **FAQs:** https://www.embs.org/jtehm/about/faqs/
- **Plantillas (redirige a selector genérico de IEEE, no a un archivo directo):** https://journals.ieeeauthorcenter.ieee.org/create-your-ieee-journal-article/authoring-tools-and-templates/ieee-article-templates/templates-for-ieee-journal-of-translational-engineering-in-health-and-medicine/
- **Selector interactivo de plantillas IEEE:** https://template-selector.ieee.org/
- **Organización oficial de IEEE en Overleaf:** https://www.overleaf.com/org/ieee
- **Esqueleto ya armado para este proyecto:** `docs/manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` — **actualizado 03-ago-2026 contra la plantilla real** que el usuario descargó de IEEE (`docs/manuscrito/JTEHM_LaTex_Template/`: `IEEEJERM.cls`, `JERM Demo.tex`, `references.bib`). La clase real es **`IEEEJERM`** (una variante de IEEEtran modificada específicamente para esta revista), no `IEEEtran` genérico como se había asumido antes de tener el archivo real.

---

## 1-ter. Enfoque editorial real de JTEHM — qué buscan, y qué hay que ajustar (03-ago-2026)

**Enlaces usados para este análisis:** [Topics](https://www.embs.org/jtehm/about/topics/), [About](https://www.embs.org/jtehm/about/), [artículos con tag "wearable-sensors"](https://www.embs.org/jtehm/articles/tag/wearable-sensors/).

### Categorías temáticas confirmadas (encaje directo)

JTEHM no lista "gait analysis" ni "prosthetics" como categoría explícita, pero el proyecto cae de lleno en tres de sus categorías reales: **"Rehabilitation Devices and Systems"**, **"Medical Devices and Systems"**, y **"Wearable Sensors and Health Monitoring Systems"** (esta última por el uso de iSen). Buen encaje temático, sin ambigüedad.

### El hallazgo importante: JTEHM tiene preferencia explícita por TRL 5-9

La revista declara que **prioriza manuscritos en Technology Readiness Level (TRL) 5 a 9** — tecnología ya validada o demostrada en un entorno clínico/de salud *relevante*, no investigación de etapa temprana (TRL 1-4: principios básicos, conceptos, validación de laboratorio sin contexto clínico). Cita textual encontrada: **"Poor Fit: Early-stage research (TRL 1-4) focusing on basic principles, concepts, or lab validation without clinical context."**

**Por qué esto importa para nuestro artículo, directamente:** tal como está planteado hoy, el estudio es una validación de banco de pruebas en el Laboratorio LIBRA — sin contexto clínico explícito, sin prostesistas ni personal clínico involucrado, sin pacientes/amputados todavía (los sujetos nuevos son personas sin amputación, per las decisiones ya tomadas). Leído sin cuidado, esto puede sonar a TRL 3-4 ("lab validation without clinical context") — justo el perfil que la propia revista dice que rechaza.

**Cómo se corrige esto — no cambia el diseño experimental, cambia el encuadre:**
1. **Agregar explícitamente una frase de posicionamiento TRL** en Introducción o Discusión, encuadrando el simulador como una herramienta de **pre-evaluación clínica** ya en TRL 5-6 (validado/demostrado en un entorno relevante — el laboratorio actuando como banco de pruebas equivalente a un taller de prótesis, con datos de sujetos reales, no sintéticos), no como ciencia básica de laboratorio.
2. **Reforzar el argumento de traducción clínica** en el campo "Clinical impact" del abstract y en Discusión: el punto no es "medimos ángulos con precisión" — es que esta herramienta **reduce el tiempo/costo/riesgo de las pruebas continuas con sujetos humanos durante el desarrollo de prótesis**, acelerando la iteración de diseño antes de que un paciente real la use. Esto calza casi textual con dos ítems del alcance oficial de la revista: *"Technological relevance to healthcare cost reduction"* y *"Technology affecting healthcare management"*.
3. **Precedentes reales publicados en JTEHM** que siguen exactamente este patrón (tecnología accesible/de bajo costo, validada con sujetos reales, encuadrada en su beneficio práctico, no solo en su precisión técnica) — usarlos como modelo de tono, no para citarlos como referencia bibliográfica salvo que se lean a fondo:
   - *"A Low-Cost Instrumented Shoe System for Gait Phase Detection Based on Foot Plantar Pressure Data"* (JTEHM 2023, DOI 10.1109/JTEHM.2023.3319576)
   - *"The feasibility and validity of a wearable sensor system to assess the stability of high-functioning lower-limb prosthesis users"* — estructuralmente el más parecido a este proyecto: estudio de factibilidad/validez de un sistema de sensores en usuarios de prótesis de miembro inferior.
   - *"Design and Integration of an Inexpensive Wearable Mechanotactile Feedback System for Myoelectric Prostheses"* (JTEHM 2018)

### Recomendación práctica adicional

La propia revista invita a autores inseguros del encaje a **enviar un abstract para evaluación preliminar antes del envío completo**. Dado que este es justo el tipo de duda que tenemos (encaje de TRL), es una forma barata de reducir el riesgo antes de invertir en redactar el manuscrito completo — vale la pena considerarlo cuando el abstract esté más maduro.

---

## 1-bis. Qué archivos subir al proyecto de Overleaf (03-ago-2026)

Claude no tiene acceso a tu cuenta de Overleaf — no puede ver ni editar tu proyecto ahí directamente. Esto es lo que tienes que subir/mantener tú mismo, además del `.tex`:

- **`IEEEJERM.cls`** — OBLIGATORIO. Es la clase de LaTeX específica de esta revista (no es una clase estándar que Overleaf ya tenga instalada). Sin este archivo en el mismo proyecto, `\documentclass{IEEEJERM}` falla y nada compila. Ya lo tienes en el ZIP que descargaste de IEEE — debe quedar en la raíz del proyecto de Overleaf, junto al `.tex`.
- **`references.bib`** — OBLIGATORIO para que las citas (`\cite{...}`) y la bibliografía final compilen. El que trae el ZIP de IEEE es solo un ejemplo — hay que reemplazar sus entradas por las citas reales del proyecto (lista completa al final de este documento y de la plantilla `.tex`, sección de comentarios antes de `\bibliography`).
- **`JERM Demo.pdf`** — no es necesario subirlo, es solo el PDF de ejemplo que genera el `.tex` de muestra, para que veas cómo se ve. No afecta la compilación de tu propio archivo.
- El `.tex` que reemplaza a `template.tex`/`JERM Demo.tex` con el contenido del proyecto: `docs/manuscrito/JTEHM_LaTex_Template/manuscrito_JTEHM.tex` (ya actualizado contra la plantilla real).

**En resumen:** sí, tienes que subir la carpeta completa que te dio IEEE (al menos `.cls` + `.bib`), no solo el `.tex` — el `.tex` por sí solo no compila sin la clase.

## 2. Límite de extensión — el más estricto de todas las revistas evaluadas

**Papers (la categoría que aplica a este artículo): 8 páginas de texto, incluyendo referencias.** No cuentan apéndices ni material suplementario.

Esto es mucho más estricto que MDPI o SAGE, que no tenían límite duro de página. **El contenido que ya está redactado va a necesitar recortarse de forma significativa** — no es un simple cambio de plantilla.

Existe también la categoría **Communications**: máximo 5 páginas totales (4 de texto + 1 de agradecimientos/referencias) — más corta todavía, con una estructura distinta (ver sección 4). Si el volumen final de resultados es modesto, Communications podría ser más realista que Papers — decidir esto cuando haya más claridad del volumen real de resultados.

**Letters to the Editor:** 500 palabras — no aplica a este artículo (es para comentarios cortos, no investigación original).

---

## 3. Abstract y metadatos

- **Máximo 250 palabras** (Papers) — los subtítulos no cuentan para el límite.
- **Estructura real, confirmada contra la plantilla oficial (corrige lo que decía la página pública):** Objective, Methods and procedures, Results, Conclusion — **más dos campos adicionales que la página pública no mencionaba:**
  - **"Clinical impact:"** — un campo aparte, corto, sobre la relevancia clínica práctica del trabajo. Distinto del Impact Statement de abajo.
  - **"Clinical and Translational Impact Statement"** — ver el punto siguiente.
- **Keywords:** hasta 5, en orden alfabético (esto viene de la página pública; la plantilla real no lo contradice ni lo confirma explícitamente en el demo, pero no hay razón para no seguirlo).
- **Clinical and Translational Impact Statement — OBLIGATORIO, máximo 30 palabras.** Es lo más distintivo de esta revista: resume en una frase muy corta el impacto clínico/traslacional del trabajo. **Los envíos sin esto se devuelven sin revisar** — no es opcional ni se puede omitir "para después". **Detalle nuevo, solo visible en la plantilla real, no en la página pública:** el statement debe indicar además una categoría del espectro clínico del NIH: *Early/Pre-Clinical Research*, *Clinical Research*, *Clinical Implementation*, o *Public Health*. Para este proyecto, lo más probable es **Early/Pre-Clinical Research** (es validación de una herramienta de evaluación, no una intervención en pacientes todavía) — confirmar cuando se redacte la versión final. Ya está como placeholder en la plantilla `.tex`, pero falta redactarlo de verdad antes de enviar.

---

## 4. Estructura del manuscrito — distinta según la categoría

**Papers** (la que aplica aquí) — **corregido 03-ago-2026 contra la plantilla real:**
> Introduction → Methodology → Results → **Discussion** → Conclusion → Acknowledgment → References

**Corrección importante:** la página pública de instrucciones decía que "Papers" no tiene sección Discussion separada (todo iría en Conclusion). **La plantilla oficial real que descargó el usuario contradice eso** — trae Discussion y Conclusion como secciones distintas, una después de la otra. Se sigue la plantilla real, no el resumen de la página web, porque es la fuente más autorizada. Ya está corregido en `JTEHM_LaTex_Template/manuscrito_JTEHM.tex`: Discussion es para interpretación/limitaciones/trabajo futuro, Conclusion es un cierre breve aparte.

Las subsecciones de Methodology en la plantilla real van sin numerar (`\subsection*{...}`), no `\subsection{...}` numerado — también ya ajustado.

**Communications** (alternativa más corta, por si se reconsidera):
> Introduction and Clinical Need → Results → Discussion → Methods → Future Directions and Potential Clinical Impact
> (nota: aquí Methods va *después* de Results, orden invertido respecto a lo habitual — típico de formatos "traslacionales" que priorizan mostrar el resultado clínico antes que el detalle técnico)

---

## 5. Figuras — requisitos verificados (política general de IEEE, aplica a JTEHM)

- **Formatos aceptados:** PS, EPS, PDF, PNG, TIFF. Se prefiere **vectorial** (PS/EPS/PDF) sobre raster para que se vea nítido en la versión final. JPEG solo se acepta para fotos de autor. **No se aceptan** VSD, GIF, ni BMP.
- **Resolución:** 600 dpi para monocromo, 300 dpi para color/escala de grises.
- **Color:** si la figura va a aparecer en color (impreso o web), debe enviarse en **RGB**.
- **Nomenclatura de archivos:** las primeras 5 letras del apellido del primer autor + un número secuencial (p. ej. `garci01.eps`, `garci02.eps`).

---

## 6. Otros requisitos de la revista

- **Declaración de uso de IA:** obligatoria si se usó IA en la redacción del texto. La IA **no puede** usarse para crear o alterar imágenes/videos del artículo.
- **Lenguaje inclusivo:** preferido — evitar términos con género innecesario y terminología tipo "master/slave" (relevante si en algún momento se describe la arquitectura de control Raspberry Pi–ESP32, evitar esa terminología específica si aparece en la jerga técnica del equipo).
- **Material suplementario:** videos, datos y código se alientan explícitamente y se publican junto con el artículo — encaja bien con la intención ya declarada del proyecto de dejar el repositorio de GitHub actualizado (`CLAUDE.md`, Semana 5 del plan).
- **Declaración de aprobación ética:** obligatoria para investigación con sujetos humanos, va en Acknowledgments.

---

## 7. Costo — APC y descuentos

- **APC 2026: USD 2160**, Gold Open Access obligatorio (no hay ruta gratuita como en POI/SAGE — publicar ahí siempre tiene este costo). Dentro del tope de USD 2500 de la universidad.
- **Descuentos verificados:**
  - 5% para miembros IEEE.
  - 20% para miembros de EMBS (la sociedad que edita JTEHM) — **revisar si algún autor o el asesor tiene membresía EMBS**, sería el descuento más grande disponible.
  - Posible exoneración/descuento para autor de correspondencia de países de bajos ingresos (definición del Banco Mundial) — no aplica a Perú (no está en esa categoría del Banco Mundial), pero vale la pena confirmar la lista vigente por si acaso.

---

## 8. Checklist antes de enviar

- [ ] Manuscrito dentro de 8 páginas (Papers) incluyendo referencias.
- [ ] Abstract ≤250 palabras, con los 4 subtítulos obligatorios.
- [ ] Clinical and Translational Impact Statement redactado, ≤30 palabras — **no lo dejes para el final, sin esto rechazan el envío sin revisar**.
- [ ] Hasta 5 keywords en orden alfabético.
- [ ] Estructura de Papers respetada (sin sección Discussion separada — todo en Conclusion).
- [ ] Figuras en formato/resolución/color correctos, nombradas según la convención.
- [ ] Declaración de uso de IA (si aplica) y de aprobación ética listas.
- [ ] Confirmar la plantilla exacta de JTEHM en https://template-selector.ieee.org/ antes del envío final — este documento usa `IEEEtran` estándar, no se pudo verificar si JTEHM pide alguna variante especial.
- [ ] Revisar si algún coautor/asesor tiene membresía IEEE o EMBS para el descuento del APC.
