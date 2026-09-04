---
Estado: PROTOCOLO DEFINIDO, SIN EJECUTAR — planteamiento del usuario, 02-sep-2026.
Depende de dos bloqueos que siguen sin resolverse a la fecha: (1) `Escribir_CSV_
Simulador.m`/`Generar_Trayectoria.m` sin conectar al Paso 4 nuevo del generador
(ver informe_tecnico_generador.tex, Limitaciones), y (2) integración Raspberry
Pi-ESP32 del banco físico (LIBRA, 3 GDL), sin cambio de estado reciente conocido.
No confundir con `propuesta_anclaje_absoluto_altura.md` (esa es sobre anclar la
altura ABSOLUTA de la trayectoria generada al piso; esta es sobre calibrar la
FUERZA que mide la plataforma del banco físico variando su altura inicial de
arranque). Son dos usos distintos de la palabra "altura" en este proyecto.
---

# Protocolo: calibración altura inicial del banco → GRF medido en plataforma

## 1. Motivación

El generador predice el GRF vertical esperado (Newtons) a partir de talla+masa,
ya validado en software contra Kuopio (r=0.866, `Predecir_GRF_Personalizado_
Core.m`). Pero el banco físico de 3 GDL (LIBRA-PUCP) que ejecuta la trayectoria
sobre una prótesis transtibial real, apoyada en una plataforma de fuerza, **no
tiene una entrada de masa variable** — sus únicos dos controles son (a) la
trayectoria de referencia (CSV) y (b) la altura inicial de arranque del
mecanismo. El usuario confirmó (02-sep-2026) que el mecanismo por el cual la
altura inicial cambia el GRF medido es de **compresión/offset** (no de
impacto/caída libre): la posición vertical de arranque desplaza toda la
trayectoria respecto al plano fijo de la plataforma, así que el talón de la
prótesis se "hunde" más o menos en cada apoyo según esa altura — un
comportamiento tipo Hooke ($F\approx k\cdot\Delta h$), no $F\propto\sqrt{h}$
como sería en un modelo de impacto.

Objetivo del protocolo: construir, para una trayectoria de talla dada, una
curva empírica GRF(Δaltura) medida en la propia plataforma del banco, e
invertirla para encontrar qué altura inicial reproduce el GRF objetivo que el
generador predice para una masa candidata — cerrando el lazo software→hardware.

**Encaje en el artículo (decidido en conversación, 02-sep-2026):** esto NO se
presenta como un hallazgo biomecánico ("así varía el GRF real con el peso") —
sería sobregeneralizar de un solo banco con su propia rigidez de contacto,
el mismo error que ya se evitó con Ferber. Se presenta como **aporte de
instrumentación/calibración de sistema**: un protocolo (idealmente redactado de
forma reutilizable, no solo "así ajustamos nuestra máquina") que demuestra que
el sistema completo generador+banco puede calibrarse para reproducir con
fidelidad conocida el GRF objetivo de un perfil antropométrico dado. Va en una
sección propia del artículo, después de la validación puramente computacional
(Kuopio/Ferber) — p.ej. "Validación instrumental: del generador al banco
físico" — nunca mezclada con la validación cinemática.

## 2. Protocolo de medición

1. **Tarado (altura cero) por talla.** Para cada trayectoria de talla a
   probar, bajar el mecanismo hasta el primer toque leve del talón de la
   prótesis contra la plataforma — ese punto es Δaltura=0 para esa talla. No
   reutilizar el cero de una talla en otra: cada trayectoria tiene su propia
   geometría de contacto (ángulo del talón, velocidad vertical al tocar).
2. **Barrido de alturas, resolución fina cerca de cero.** Desde el cero
   tarado, bajar en incrementos pequeños (orden de 1-2mm cerca del cero, donde
   la rigidez de contacto es más probable que sea no lineal; incrementos algo
   mayores después si la curva ya se ve lineal). El rango total de variación
   esperado es de pocos centímetros o menos.
3. **Repeticiones por nivel.** Varios ciclos por cada altura (misma
   trayectoria, mismo talón) antes de pasar al siguiente nivel — reportar
   media±SD del GRF pico (y de la curva completa) por nivel, para separar
   señal real de ruido de la plataforma.
4. **Registrar la curva completa de GRF por ciclo, no solo el pico** — se
   necesita si luego se quiere mostrar concordancia de forma, no solo de
   magnitud, en el artículo.
5. **Repetir el procedimiento completo (1-4) para 3-4 tallas representativas**
   del rango ya validado en software (p.ej. percentiles bajo/medio/alto), no
   un barrido continuo de tallas — la interpolación entre tallas queda al
   modelo de software, no al banco físico.

## 3. Análisis esperado (una vez con datos)

1. Ajustar, por talla, la curva GRF_pico(Δaltura) medida — decidir si un
   modelo lineal (Hooke) es suficiente o si hace falta un término no lineal
   cerca del cero (ver §2.2).
2. Para una masa candidata (misma talla), calcular el GRF objetivo con
   `Predecir_GRF_Personalizado_Core.m` (ya validado, r=0.866 vs Kuopio).
3. Invertir la curva ajustada del paso 1 para encontrar la Δaltura que
   reproduce ese GRF objetivo — esa es la "altura equivalente a tal peso" que
   pidió el usuario. Es una tabla de calibración propia de este banco físico,
   no una constante universal ni un hallazgo biomecánico generalizable.
4. Reportar el error de reproducción: GRF objetivo (software) vs. GRF medido
   en la plataforma al ajustar el banco a esa altura calibrada — con una
   métrica clara (%error o RMSE). Ese es el resultado central de la sección
   de instrumentación.

## 4. Bloqueadores para ejecutar esto (a la fecha de este documento)

1. `Escribir_CSV_Simulador.m`/`Generar_Trayectoria.m` todavía no exportan el
   CSV del Paso 4 nuevo (modelo de posición ya validado) — sin esto no hay
   trayectoria real que enviarle al banco.
2. Integración Raspberry Pi-ESP32 del banco físico — bloqueo de hardware
   preexistente, sin cambio de estado reciente conocido a la fecha.
3. Disponibilidad física del banco y de una prótesis transtibial montada
   sobre la plataforma de fuerza para correr el barrido.

## 5. Explícitamente NO hecho todavía

- No se ha corrido ningún ensayo físico de este barrido.
- No se ha escrito ningún script de análisis/ajuste de la curva GRF(Δaltura)
  — se hará cuando existan los primeros datos reales.
- No se ha tocado el informe técnico ni ningún manuscrito con este contenido
  — este documento es solo el protocolo, para no perder el hilo hasta que el
  banco esté disponible.
