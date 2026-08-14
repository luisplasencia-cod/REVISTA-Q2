# Carpeta del manuscrito JTEHM — qué es cada archivo

**Reorganizado el 05-ago-2026** a pedido del usuario, para distinguir de un vistazo **qué es borrador y qué es lo final que va a Overleaf**.

## Regla de oro

> **Se redacta en el borrador (`.md`), se traslada al `.tex` cuando está resuelto.**
> Si el `.md` y el `.tex` difieren, **manda el `.tex`** — es lo que se envía.

---

## En ESTA carpeta (`docs/manuscrito/JTEHM_LaTex_Template/`) — lo FINAL

| Archivo | Qué es | ¿Se edita? |
|---|---|---|
| **`manuscrito_JTEHM.tex`** | **El manuscrito final.** Espejo de lo que está en Overleaf. Antes vivía suelto como `../plantilla_overleaf_JTEHM.tex`; se movió aquí para que quede junto al `.cls` y al `.bib` que necesita | **Sí** — es el archivo de trabajo principal |
| **`references.bib`** | **Bibliografía final.** Ya trae las referencias reales del manuscrito, con el estado de verificación de cada una anotado dentro (`[OK]` / `[PARCIAL]` / `[REVISAR]`) | **Sí** — no agregar entradas sin verificar |
| `IEEEJERM.cls` | Clase LaTeX oficial de IEEE JTEHM. Sin ella no compila nada | **No** — archivo de IEEE, no tocar |
| `JERM Demo.tex` | Plantilla de ejemplo oficial de IEEE. **Es la referencia de "cómo se redacta"**: muestra la estructura de secciones, el formato del abstract de 5 campos, el Impact Statement y las convenciones de la revista | **No** — se consulta, no se edita |
| `JERM Demo.pdf` | El demo anterior ya compilado — sirve para ver cómo debe quedar visualmente | **No** |
| `README_ESTRUCTURA.md` | Este archivo | — |

**Para subir a Overleaf hacen falta tres:** `manuscrito_JTEHM.tex` (pegado dentro de `JERM Demo.tex` del proyecto), `IEEEJERM.cls` y `references.bib`.

---

## En la carpeta de arriba (`docs/manuscrito/`) — BORRADORES y apoyo

| Archivo | Qué es |
|---|---|
| **`metodos_introduccion_borrador.md`** | **El borrador en prosa.** Donde siempre estuvo y donde se sigue redactando primero. Tiene los tramos `[PENDIENTE: ...]` con la razón de por qué cada uno sigue abierto |
| **`referencias_verificadas.md`** | **Control de la bibliografía.** Estado de verificación de cada cita, advertencias de uso, y la lista de acciones para cerrar las que faltan. Es el "por qué" detrás de los `[OK]`/`[PARCIAL]` del `.bib` |
| `guia_autor_JTEHM.md` | Reglas de la revista: límite de 8 páginas incluyendo referencias, abstract estructurado ≤250 palabras, Impact Statement obligatorio ≤30 palabras con categoría del espectro clínico del NIH, figuras, APC |
| `plantilla_overleaf_POI.tex`<br>`plantilla_overleaf_Bioengineering_MDPI.tex`<br>`plantilla_overleaf_Prosthesis_MDPI.tex` | **Históricas, no vigentes.** Revistas descartadas (SAGE y MDPI, fuera de las editoriales aprobadas por la universidad). Se conservan como referencia, no se editan |

---

## Flujo de trabajo

```
   Decisión / dato nuevo
            │
            ▼
   metodos_introduccion_borrador.md      ← se redacta en prosa, en español o inglés
            │  (cuando queda resuelto)
            ▼
   manuscrito_JTEHM.tex                  ← versión final, en inglés, con formato IEEE
            │
            ▼
   Overleaf  →  envío
```

Bibliografía, en paralelo:

```
   Cita candidata  →  verificar contra la fuente  →  referencias_verificadas.md
                                                              │
                                                              ▼
                                                        references.bib
```

**No saltarse el paso de verificación.** En la ronda del 05-ago-2026, de 5 citas identificadas por búsqueda, 3 tenían errores reales: un título equivocado, un resumen de congreso de una página confundido con artículo completo, y un paper de congreso confundido con artículo de revista.
