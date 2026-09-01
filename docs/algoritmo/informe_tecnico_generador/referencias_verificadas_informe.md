# Control de verificación de citas — informe técnico del generador

Solo para este informe. Estado por cita antes de fijarla en el `.tex`.

| Cita | Estado | Fuente de verificación |
|---|---|---|
| Koopman et al. 2014 | [OK] texto completo | `docs/literatura/pdfs/koomap.pdf` |
| Piche et al. 2022 (iSen) | [OK] texto completo | `docs/literatura/pdfs/` (confirmado 11-ago-2026) |
| Zhao et al. 2026 | [OK] | Crossref (10.1371/journal.pone.0338041) — PLOS ONE 21(1):e0338041 |
| Yun et al. 2014 | [OK] | Crossref (10.1016/j.jbiomech.2013.09.032) — J Biomech 47(1):186-192 |
| Winter 2009 (libro, 4ta ed.) | [OK] | Crossref/Wiley DOI 10.1002/9780470549148 — clave `Winter2009` |
| Senden et al. 2024 (Maastricht Gait Dataset) | [OK] | Crossref (10.1016/j.dib.2024.110230) — Data in Brief 53:110230; PMID 38445200. Autor real es Senden et al., no "Maastricht" — clave `Senden2024` |
| Ferber et al. 2024 | [OK] | Crossref (10.1038/s41597-024-04011-7) — Scientific Data 11:1232. DOI de Figshare+ (10.25452/figshare.plus.24255795.v1) es del dataset, no de la publicación — se cita la publicación |
| Kuopio Gait Dataset (Lavikainen et al. 2024) | [OK] | Crossref (10.1016/j.dib.2024.110841) — Data in Brief 56:110841 (publicación citable; DOI de Zenodo 10.5281/zenodo.10559504 es del dataset) — clave `Lavikainen2024` |
| Camargo et al. 2021 | [OK] | Crossref (10.1016/j.jbiomech.2021.110320) — J Biomech 119:110320, autores Camargo/Ramanathan/Flanagan/Young |
| Drillis & Contini 1966 | [OK] | verificado contra imagen de Winter Fig. 4.1; cita exacta confirmada por 2 fuentes independientes — TR 1166-03, NYU School of Engineering and Science, 1966 |
| de Leva 1996 | [OK] | Crossref (10.1016/0021-9290(95)00178-6) — J Biomech 29(9):1223-1230 |
| Zeni, Richards & Higginson 2008 | [OK] | Crossref (10.1016/j.gaitpost.2007.07.007) — Gait & Posture 27(4):710-714 |
| Froude Fr=0.25 (velocidad autoseleccionada) | [OK, CORREGIDO 28-ago-2026] | La pista "Raichlen & Pontzer 2011" era **errónea de autoría**: el artículo que reporta Fr=0.25 en adultos/niños/pigmeos/enanismo — el mismo ya citado a texto completo en el código (`Estimar_Velocidad_Froude_Core.m`) — es Leurs, Ivanenko, Bengoetxea, Cebolla, Dan, Lacquaniti & Cheron (2011), "Optimal walking speed following changes in limb geometry", J Exp Biol 214(13):2276-2282, DOI 10.1242/jeb.054452 (Crossref confirma autores). Corregido en `.tex` (texto y cita) y `.bib` — clave `Leurs2011` |
| Sudeesh et al. 2024 | [OK] texto completo | leído 27-ago-2026 |

[OK] = verificado. [PENDIENTE] = revisar antes de fijar en el `.tex`.

**Actualización 28-ago-2026:** las 9 citas `PENDIENTE_*` del informe (`informe_tecnico_generador.tex`) quedaron verificadas y volcadas a `referencias_informe.bib`. Todas verificadas contra Crossref (DOI resuelto) salvo Drillis & Contini 1966 (reporte técnico sin DOI, verificado contra 2 fuentes secundarias independientes) y Winter 2009 (verificado contra Wiley/Crossref del libro). Hallazgo real: la pista "Raichlen & Pontzer 2011" para el número de Froude tenía la autoría equivocada — ver fila de arriba.
