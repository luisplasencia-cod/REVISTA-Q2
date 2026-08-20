# Redacción para el comité de ética — instrumentación y datos

> 🚨 **SUPERADO por el pivote — 19-ago-2026.** El protocolo de ética descrito aquí (captura de sujetos nuevos, recaptura con iSen) queda **abandonado como plan vigente** — el nuevo enfoque (`CLAUDE.md` banner inicial, `docs/DISCUSION_Q2.md` P-20) valida contra bases de datos públicas ya existentes, no contra sujetos propios capturados bajo este protocolo. Se conserva por si se retoma la captura de sujetos en el futuro (p. ej. si se decide más adelante complementar con datos propios), pero **no es una tarea activa del ciclo actual**.

## Párrafo de instrumentación (pegar en metodología del protocolo)

Se podrá emplear uno o más de los siguientes instrumentos de captura, de forma individual o combinada, según la etapa de validación técnica del sistema y la disponibilidad de cada uno en el momento de la sesión:

Para la captura de las variables cinemáticas y cinéticas de la marcha se emplearán los siguientes instrumentos, todos ellos no invasivos: (1) un sistema de captura óptica bidimensional compuesto por una cámara de video (Sony FDR-AX700, 120 fps) y marcadores reflectivos adheridos externamente sobre la piel o la vestimenta del participante, a la altura del segmento tibial, procesados mediante el software Kinovea; (2) un sistema de sensores inerciales inalámbricos (STT-IWS, STT Systems) sujetos externamente al segmento tibial mediante correas ajustables, sin penetración de la piel ni contacto con mucosas, procesados mediante el software iSen; (3) sensores inerciales adicionales de bajo costo, en desarrollo, utilizados exclusivamente como sistema de validación complementario; y (4) una plataforma de fuerza embebida en el piso del laboratorio (AMTI BP400600), sobre la cual el participante camina de forma natural, sin ningún contacto físico adicional al propio del caminar. Ninguno de estos instrumentos implica exposición a radiación, procedimientos invasivos, ni riesgo físico más allá del asociado a la marcha habitual del participante.

## Datos que se recogerán

**Datos personales y de salud**
- Edad, sexo, peso corporal, talla
- Estado de salud autorreportado (ausencia de alteraciones del patrón de marcha, lesiones musculoesqueléticas recientes o condiciones que afecten la marcha)

**Datos de captura (por sesión, ~5-10 minutos de caminata efectiva)**
- Video del miembro inferior durante la marcha (encuadre limitado a la pierna, sin captura de rostro)
- Orientación/ángulo del segmento tibial, obtenido de los sensores inerciales
- Fuerza de reacción vertical del suelo (solo si el participante también participa en la condición cinética)
- Marcas de tiempo de contacto inicial y despegue del pie

**Datos derivados (procesados, no crudos)**
- Curvas de ángulo de inclinación tibial (apoyo y balanceo)
- Trayectorias de posición horizontal y vertical del segmento

## Puntos que probablemente pidan agregar junto a esto

1. **Consentimiento informado** — voluntariedad explícita, posibilidad de retirarse en cualquier momento sin consecuencias.
2. **Anonimización** — código por participante; videos e imágenes sin datos que permitan identificarlo.
3. **Uso y resguardo de los datos** — dónde se almacenan (repositorio GitHub/Drive del equipo), quién tiene acceso, por cuánto tiempo.
4. **Criterios de inclusión/exclusión** — adultos sanos, sin alteraciones de marcha, sin lesiones activas en miembro inferior; definir rango de edad si se va a fijar uno.

## Nota importante de calendario

Ni la recaptura del sujeto original ni la captura de sujetos nuevos puede iniciarse hasta que este protocolo esté aprobado — sin excepción, incluso si "ya se conoce" al sujeto original. Solo la prueba piloto de software (con una persona ajena al estudio, sin fines de investigación) puede hacerse antes de la aprobación.
