# CRediT — borrador de roles de autoría

> 🟡 **Parcialmente vigente tras el pivote — 19-ago-2026.** Los roles CRediT en sí (quién hizo qué tipo de trabajo) no dependen del enfoque del artículo, siguen siendo una plantilla útil. Lo que sí puede cambiar es el reparto real de quién hace qué, dado el nuevo enfoque (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20). Revisar cuando se defina el nuevo plan de trabajo.

**Estado: estructura lista, sin nombres asignados salvo el ya confirmado.** No se encontró un requisito explícito de sección CRediT en `guia_autor_JTEHM.md` ni en la plantilla real (`IEEEJERM.cls`/`JERM Demo.tex`) — **no se inventa una sección nueva en el `.tex` sin confirmar que la revista la pide**. Este documento existe para tener los roles ya pensados y listos de pegar, en el `.tex` o en el sistema de envío de la revista (muchas revistas IEEE los piden en el portal de submission, no en el manuscrito), en cuanto se confirme dónde van.

**Taxonomía usada:** CRediT (Contributor Roles Taxonomy, estándar de facto en revistas científicas — https://credit.niso.org/, 14 roles). Se listan los 14; no todos van a tener contribuyentes en este artículo.

| Rol CRediT | Qué cubre en este proyecto | Quién *(completar)* |
|---|---|---|
| Conceptualization | Argumento central del artículo, diseño de las 3 comparaciones (fidelidad, representatividad, repetibilidad) | [PENDIENTE] |
| Data curation | Organización de `REFERENCIAS/`, `SIMULADOR/`, datos de sujetos nuevos cuando lleguen | [PENDIENTE] |
| Formal analysis | SPM1D, TOST, ICC, potencia a priori — `CODIGOS/ESTADISTICA/`, `CODIGOS/POTENCIA_EQUIVALENCIA/` | [PENDIENTE] |
| Funding acquisition | APC de JTEHM, recursos del laboratorio LIBRA | [PENDIENTE] — probablemente el asesor |
| Investigation | Captura de sujetos, operación del simulador y del iSen | [PENDIENTE] |
| Methodology | Diseño de la calibración de offset, corrección de Fz, protocolo de captura | [PENDIENTE] |
| Project administration | Coordinación del equipo, cronograma, comité de ética | [PENDIENTE] — probablemente Luis y/o el asesor |
| Resources | Simulador físico, plataforma AMTI, sistema iSen/STT-IWS, laboratorio LIBRA | [PENDIENTE] — probablemente el asesor / LIBRA |
| Software | `CODIGOS/CALIBRACION/`, `CODIGOS/ESTADISTICA/`, `CODIGOS/MULTISUJETO/`, `CODIGOS/POTENCIA_EQUIVALENCIA/`, pipeline de iSen del compañero | [PENDIENTE] |
| Supervision | Asesor del proyecto | [PENDIENTE] — probablemente el asesor |
| Validation | Pruebas con datos sintéticos de cada herramienta (`Test_*.m`, 7/7 y 9/9 PASS) | [PENDIENTE] |
| Visualization | Figuras de las herramientas (paleta accesible a daltonismo, estilo artículo) | [PENDIENTE] |
| Writing – original draft | Borrador de Introducción/Métodos (`metodos_introduccion_borrador.md`, `manuscrito_JTEHM.tex`) | [PENDIENTE] |
| Writing – review \& editing | Revisión de citas (`referencias_verificadas.md`), corrección de decisiones metodológicas | [PENDIENTE] |

**Lo único ya confirmado:** Luis Marcos Plasencia Janampa es el autor de correspondencia (`DISCUSION_Q2.md` P-8, 13-ago-2026), correo `luis.plasencia@pucp.edu.pe`. El resto de la lista de autores, su orden y su afiliación siguen pendientes — el usuario los dará "cuando sea indispensable".

**Cómo usar esto cuando llegue el momento:**
1. ~~Confirmar si JTEHM pide CRediT en el manuscrito, en el portal de envío, o no lo pide~~ — **verificado 16-ago-2026:** la página oficial "Instructions for Authors" de JTEHM (embs.org/jtehm/instructions-for-authors/) **no menciona ningún requisito de CRediT ni de "Author Contributions"** en ningún lugar del texto (se revisaron abstract estructurado, index terms, impact statement y secciones del manuscrito — nada sobre esto). **No confirma del todo** que el portal de envío (ScholarOne u otro sistema, al que no se tiene acceso) no lo pida por separado — eso solo se sabe al momento de enviar. Con esto, **no hace falta reservar espacio para una sección de CRediT en el `.tex`** salvo que el portal lo exija después.
2. Completar la columna "Quién" con nombres reales.
3. Si el portal de envío llegara a pedirlo pero no en el manuscrito: exportar esta tabla tal cual.
4. Si en algún momento se confirma que sí va en el `.tex` (poco probable según el punto 1): agregar como sección `\section*{Author Contributions}` antes de Acknowledgment, formato: "X.Y. conceived the study; A.B. developed the software; ..." (formato de frase, no tabla, es la convención habitual en IEEE).

**Trazabilidad:** este documento es una tarea del candidato de trabajo adelantado ("qué podemos ir haciendo para ahorrar tiempo después") pedida por el usuario el 13-ago-2026 — no es una decisión aplicada al manuscrito todavía.
