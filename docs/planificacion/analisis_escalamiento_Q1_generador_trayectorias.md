# Análisis exploratorio — Escalar a Q1 mediante generación de trayectorias desde antropometría

**Creado:** 05-ago-2026 · **Revisión 2:** 05-ago-2026 (misma sesión, tras reformulación del usuario)

> 🚨 **PROMOVIDO A PLAN VIGENTE — 19-ago-2026.** Hasta aquí este documento decía "no modifica ninguna decisión vigente, es para un artículo futuro" — **eso ya no es cierto.** El equipo decidió en reunión (`DISCUSION_Q2.md` P-20) reemplazar por completo el artículo que estaba en curso (validación multi-sujeto por fidelidad de seguimiento, IEEE JTEHM) por **esta línea**. Lo que sigue en este documento es, desde hoy, el análisis técnico más completo que existe del plan vigente — léelo entero antes de proponer nada nuevo sobre el proyecto.
>
> **Lo que cambia respecto a lo escrito originalmente aquí (dejado sin editar abajo, por trazabilidad):**
> - **Ya no arranca "después de cerrar JTEHM"** — arranca ahora. El checkpoint es 14-set-2026, "buen avance en implementación" (no el envío).
> - **La revista NO está decidida.** TNSRE (§11) sigue siendo la recomendación técnica de este documento, pero el usuario pidió "ordenar mejor las ideas" antes de comprometerse — no asumir TNSRE como definitivo todavía.
> - **Ningún modelo de §4.1 ni ninguna base de datos de validación está seleccionada todavía.** El equipo pidió explícitamente ampliar la búsqueda, no partir directo de esos 5 candidatos sin revisión. Preferencia nueva y explícita para la validación: **bases de datos de marcha peruanas o sudamericanas** verificadas (no estaba en el análisis original) — argumento del equipo: el algoritmo toma talla/peso/sexo/etc. como entrada, así que es independiente de la región, y una base de datos sudamericana refuerza esa independencia mejor que una norteamericana/europea genérica.
> - **Los tres bloqueos de `ESTADO_Y_RUMBO.md` (RPi-ESP32, ética, iSen) ya no son el cuello de botella del artículo** — el diseño de este documento (§2.4) ya señalaba que la captura de sujetos y la generación numérica (niveles A y B de §7.1) no dependen del simulador. El hardware solo hace falta para el nivel C (validación física), más adelante.
>
> **Rol original de este documento (histórico, ya no vigente — se conserva sin editar por trazabilidad):**

**Rol de este documento:** **NO es un plan ni una decisión.** Es un análisis de consulta, guardado para retomarlo cuando corresponda. **No modifica ninguna decisión vigente de `CLAUDE.md`** — el artículo en curso sigue siendo la validación multi-sujeto en IEEE JTEHM (setiembre 2026), y el simulador sigue ejecutando CSV pregrabado en ese ciclo.

## Qué cambió en la revisión 2

El usuario corrigió dos premisas de la primera versión:

1. **No se reclama haber creado un algoritmo.** El planteamiento es: *buscar cómo se generan estas trayectorias en la literatura, adoptar uno de esos métodos, implementarlo en la Raspberry Pi del simulador, adaptarlo a lo que el banco necesita, ejecutarlo y validarlo contra personas reales cuyos datos antropométricos alimentaron la generación.*
2. **Se elimina la fecha límite dura** para esta línea (sin alargarla indefinidamente).

**Ambas correcciones mejoran la propuesta.** La primera especialmente: la versión 1 de este documento ya concluía que la novedad no podía estar en el modelo (campo saturado, ver §4) — el usuario llegó a la misma conclusión por su cuenta y la convirtió en punto de partida en vez de en obstáculo. Eso reorienta el artículo hacia donde el hueco real sí existe.

---

## 1. La propuesta, formalizada

**Hoy (paper de conferencia IBITeC 2026, ya aceptado):**

```
CSV grabado del sujeto X → RPi → ESP32 → 3 motores → ¿reproduce el CSV?
```

El lazo es cerrado sobre sí mismo: se valida que el simulador **repite lo que se le sube**. Es fidelidad de seguimiento, no capacidad predictiva.

**Propuesta (artículo 2):**

```
{talla, masa, long. muslo, long. pierna, sexo, edad}
        │
        ▼
  [modelo publicado de generación de marcha]          ← adoptado de literatura, NO inventado
        │
        ▼
  ángulos articulares (cadera, rodilla, tobillo) + parámetros espaciotemporales
        │
        ▼
  [REDUCCIÓN CINEMÁTICA A 3 DOF]                      ← ESTO SÍ ES APORTE PROPIO (§5)
        │
        ▼
  {desplazamiento horizontal, desplazamiento vertical, ángulo sagital} → CSV
        │
        ▼
  RPi → ESP32 → 3 motores + prótesis real montada
        │
        ▼
  medición con iSen + AMTI
        │
        ▼
  COMPARACIÓN contra la marcha real del sujeto del que solo se usaron las medidas
```

La diferencia de fondo con el paper de conferencia: **ahí el sujeto tenía que ser medido antes; aquí basta una cinta métrica y una balanza.** El sujeto real solo aparece al final, como criterio de verdad, no como fuente de la entrada.

---

## 2. El cambio de rol de los sujetos — y las seis consecuencias que se desprenden

**Confirmado y correcto** (aclaración del usuario, 05-ago-2026): en este diseño **los sujetos ya no programan nada**. El simulador se programa solo con el algoritmo y con medidas antropométricas. Los sujetos se seleccionan y capturan **únicamente para verificar que lo que el simulador produce coincide con ellos**.

No es un detalle de flujo de trabajo — es un cambio de rol: el sujeto pasa de ser **entrada del sistema** a ser **criterio de verdad**. De ahí se desprenden seis consecuencias, y varias son mejores noticias de lo que parece:

### 2.1 El requisito de tamaño de muestra baja mucho

Si los modelos se usan **tal como están publicados**, sin reajustar coeficientes con datos propios, **no hay entrenamiento** — y todo el argumento de "un modelo con 4-6 predictores necesita 40-60 sujetos" desaparece. Lo que queda es una **muestra de validación**, y para eso **n = 15-20 es defendible**, que es exactamente el rango que el artículo 1 ya va a reclutar.

**Esto vuelve la línea completa mucho más viable de lo que decía el análisis anterior.** Corrige lo que dije en la revisión 1 (*"un artículo Q1 sólido necesita 30-40 sujetos"*): eso solo aplica si se reentrena. Con modelos adoptados sin reajuste, no aplica.

**Condición para que valga:** no tocar los coeficientes. En el momento en que se ajuste aunque sea un parámetro con datos propios, vuelve la circularidad, vuelve el LOSO obligatorio y vuelve el requisito de n alto. Vale la pena mantener esa disciplina aunque el ajuste tiente.

### 2.2 Se habilita el diseño más fuerte disponible: predicción prospectiva

Como los sujetos no intervienen en generar nada, **es posible generar y congelar todas las trayectorias ANTES de capturar a nadie**:

1. Medir antropometría de los sujetos reclutados (cinta métrica y balanza, sin captura de marcha).
2. Generar los CSV de los N sujetos, guardarlos con fecha, **y no volver a tocarlos**.
3. Recién entonces capturar la marcha natural de cada sujeto.
4. Comparar.

Esto convierte el estudio de "comparación retrospectiva" a **predicción prospectiva verificada**, que es un escalón metodológico claramente superior y elimina de raíz cualquier sospecha de ajuste posterior. Es prácticamente un preregistro sin el trámite de preregistrar. Si además se deja constancia verificable del congelamiento (commit de git con fecha, o hash de los archivos), es un argumento que un revisor de Q1 no puede discutir.

**Costo de implementarlo: cero.** Es solo el orden en que se hacen las cosas. Pero hay que decidirlo antes, porque no se puede reconstruir después.

### 2.3 El protocolo de ética se vuelve más liviano

Los sujetos **solo caminan con el iSen puesto**. No se les monta ninguna prótesis, no interactúan con el simulador, no hay intervención de ningún tipo. Es observacional de riesgo mínimo — un protocolo bastante más simple de justificar y probablemente más rápido de aprobar que uno que implique al dispositivo.

**Lo que sí hay que asegurar en el protocolo:** que la toma de medidas antropométricas (longitudes de segmento, incluida la medición sobre trocánter y maléolo) esté explícitamente contemplada, porque implica contacto físico y palpación de referencias óseas.

### 2.4 Captura de sujetos y trabajo de hardware se desacoplan

Hoy, en el artículo 1, la integración RPi–ESP32 bloquea casi todo. En este diseño, **la captura de sujetos no depende del simulador en absoluto** — se puede hacer en paralelo, o incluso antes de que el banco esté operativo. El hardware solo hace falta para el nivel C de validación (§7.1). Eso reduce mucho el riesgo de cronograma respecto del artículo actual.

### 2.5 Cuidado con la palabra "igual" — el criterio hay que definirlo antes

*"Validar que lo generado por el simulador es igual"* es la intención correcta, pero **"igual" no es un criterio alcanzable ni evaluable**. Ningún modelo genérico reproduce a un individuo exactamente, y plantear la barra ahí garantiza un resultado que parece fracaso.

El criterio correcto, y que además ya está implementado en el proyecto: **¿la trayectoria generada cae dentro de la banda de variabilidad natural del propio sujeto?** Es decir, comparar la discrepancia generado-vs-sujeto contra la discrepancia que el sujeto tiene **consigo mismo** entre pasadas (% de puntos dentro de ±1 SD, ICC(3,1)).

> Si la diferencia entre lo generado y el sujeto no es mayor que la diferencia entre el sujeto y sí mismo, la reproducción es indistinguible del ruido natural de esa persona — y eso es lo máximo que cualquier método puede reclamar.

Esa formulación es honesta, alcanzable y mucho más fuerte ante un revisor que un "igual" sin definir. **Definir este umbral por escrito antes de mirar los datos**, no después.

### 2.6 Trampa estadística: "no hubo diferencia significativa" NO prueba equivalencia

Es el error que más fácilmente hunde un artículo con este diseño, y hay que anticiparlo.

Si se corre SPM1D y sale "sin diferencia significativa", un revisor de Q1 responde: *"eso no demuestra que sean iguales, demuestra que su muestra no tuvo potencia para detectar la diferencia"*. Ausencia de evidencia no es evidencia de ausencia — y con n modesto, es exactamente lo que se espera que pase.

Para reclamar equivalencia hay que usar **pruebas de equivalencia** (tipo TOST / two one-sided tests, o su versión para curvas), lo cual **obliga a declarar de antemano cuál es la diferencia mínima que importa** — que es justamente lo que resuelve §2.5: el umbral es la variabilidad intra-sujeto.

**Implicación para el código:** `SPM1D_Core.m` está construido para detectar diferencias, no para probar equivalencia. Habría que extenderlo o agregar un módulo de equivalencia. Es trabajo acotado, pero hay que preverlo — no es algo que se improvise en la semana de redacción.

**Nota de vocabulario:** a lo largo del documento, donde el planteamiento original decía *"igual"*, se lee **"similitud dentro de la variabilidad natural del sujeto"** — que es lo que efectivamente se busca y lo que se puede demostrar.

> **Estado cuantificado (§13):** afecta a la fila 6 del tablero (*diseño anti-objeción*), hoy en **20%**, aportando **2.0 de 10 puntos**. Cierra al **decidir por escrito y antes de capturar** tres cosas: (a) generación congelada previa a la captura, (b) reclutamiento estratificado con rango de talla ≥ 25 cm, (c) compromiso de no reajustar coeficientes. Las tres juntas la llevan a 80% → **+6.0 puntos por ~1 semana de trabajo, el mejor retorno de todo el proyecto.**

---

## 3. Respuesta corta

1. **El encuadre "adoptamos un método publicado" es el correcto, y no baja el techo.** El presupuesto de novedad nunca iba a alcanzar para el modelo (§4). Al no gastarlo ahí, queda libre para el lugar donde sí hay hueco.
2. **Los sujetos como criterio de verdad, no como entrada, es el eje del artículo** — y trae seis consecuencias, dos de ellas muy favorables: el n necesario baja a 15-20, y se habilita un diseño de predicción prospectiva. §2.
3. **Pero el hueco es más estrecho de lo que parecía.** Hay tres líneas de trabajo previo que se acercan mucho, incluida una que es casi el mismo proyecto (§4). Eso no mata la idea, pero obliga a posicionarla con precisión quirúrgica. **Leer esos tres papers es la primera tarea, antes de cualquier otra cosa.**
4. **La contribución técnica real, que hoy no está en la propuesta y hay que poner en el centro, es la reducción de espacio articular a las 3 DOF del banco** (§5). Sin eso el artículo es "implementamos el modelo de otro"; con eso es un problema de ingeniería con solución propia y verificable.
5. **Revista: IEEE TNSRE** (Q1, IF 5.2, Gold OA USD 2160 — mismo costo que JTEHM, dentro del tope). §11.
6. **Horizonte realista: envío a mediados/finales de 2027**, ~12 meses de trabajo efectivo tras cerrar el artículo de JTEHM. §9.

---

## 4. Estado del arte real — lo que hay que leer antes de seguir

### 4.1 Los modelos de generación ya existen (campo saturado)

Búsqueda verificada. Ninguno de estos se puede reclamar como aporte propio, y todos hay que citarlos:

| Trabajo | Entrada | Método | Nota |
|---|---|---|---|
| [Sci Rep 2019](https://www.nature.com/articles/s41598-019-45397-4) | velocidad, sexo, edad, IMC | Regresión múltiple | Error dentro de ±1 SD de las curvas originales. **El más fácil de reimplementar** |
| [J Biomech 2013](https://www.sciencedirect.com/science/article/abs/pii/S0021929013004879) | 14 parámetros corporales | Gaussian Process Regression | 113 sujetos, 14 movimientos articulares, **entrega incertidumbre asociada** |
| [J Biomech 2014](https://www.sciencedirect.com/science/article/abs/pii/S0021929014000682) | velocidad + talla | Splines quínticos entre eventos clave, con regresión | **Diseñado explícitamente para soporte robótico de marcha** — el más cercano al uso que se le quiere dar |
| [MTAP 2023](https://link.springer.com/article/10.1007/s11042-023-14733-2) | antropometría + velocidad | LSTM + CNN | r = 0.98, rango 0.49–1.76 m/s |
| [Electronics 2025](https://doi.org/10.3390/electronics14234554) | long. muslo, long. pierna, peso | GPR + series de Fourier | Personalización para exoesqueleto. Acceso abierto |

**Esto es bueno, no malo:** son cinco métodos publicados, documentados, con parámetros disponibles. Adoptar uno es legítimo y rápido.

#### Candidato nuevo, 19-ago-2026 — el más fuerte encontrado hasta ahora

Búsqueda ampliada tras el pivote de P-20 (`DISCUSION_Q2.md`). **Verificado a texto completo:**

- **[Zhao et al. 2026, PLOS ONE](https://doi.org/10.1371/journal.pone.0338041)** — *"A predictive model of joint dynamics and ground reaction force using only leg length, body mass, and walking cadence"*. Entrada: **solo** longitud de pierna, masa corporal y cadencia — ni siquiera pide edad/sexo, la entrada más mínima de todos los candidatos, calza perfecto con "cinta métrica y balanza". Método: series de Fourier (parte cinemática) + ecuaciones de Lagrange (parte dinámica). Salida: ángulos de cadera/rodilla y momentos de cadera/rodilla/tobillo en plano sagital, **más GRF vertical y anteroposterior** — cubre de una vez la parte cinemática y la de fuerza que el proyecto ya trabajaba por separado. **Coeficientes publicados en su Tabla 1, y código + datos en GitHub** (`github.com/zhaoxiaohuan13/predictive-model-of-joint-dynamics-and-ground-reaction-force` — URL corregida 20-ago-2026 tras leer el texto completo, antes decía "zhaohuan13"). Validado con SPM1D contra Vicon+AMTI — **el mismo motor estadístico que ya está construido y probado en `CODIGOS/ESTADISTICA/SPM1D_Core.m`**, cero adaptación necesaria del lado del análisis. Entrenado con 10 sujetos sanos, validado con 4 sanos separados (Xi'an Jiaotong University) — **sin validación externa independiente todavía**, que es exactamente el rol que puede cumplir este proyecto.
- **Dato colateral, no es un generador pero es evidencia de viabilidad de hardware:** [Karakish, Fouz & Elsawaf 2022, *Sensors*](https://doi.org/10.3390/s22218441) corre un MLP de estimación de marcha **desplegado en un ESP32** — el mismo microcontrolador que ya está instalado en el banco — con 2.4 ms de tiempo de inferencia. No usa antropometría como entrada (usa IMU de shank/foot), así que no sirve como generador, pero confirma que un modelo de este tamaño cabe en el hardware que ya existe sin necesitar más cómputo.
- **Vacío que se confirma, no se resuelve:** sigue sin existir ningún modelo de generación de trayectoria desde antropometría entrenado/ajustado a marcha protésica o población amputada — todos los candidatos (los 5 de agosto + Zhao 2026) están ajustados a sujetos sanos. Sigue siendo el riesgo de la fila 2 de §8.

**Con Zhao 2026 en la mesa, se actualiza la recomendación del §6:** sigue siendo razonable partir de J Biomech 2014 (pensado para robótica) o Sci Rep 2019 (más simple) como candidatos, pero **Zhao 2026 es hoy el más fuerte de los seis** — entrada más mínima, salida más completa (cinemática + GRF juntas), y ya compatible con la herramienta de análisis que el proyecto tiene construida.

### 4.2 Los tres precedentes que definen el hueco — prioridad de lectura máxima

Aquí está el hallazgo que reordena el análisis. **No es cierto que "nadie haya cerrado el lazo sobre hardware"** — como decía la versión 1 de este documento. Hay que corregirlo:

**(a) [Hardware-in-the-Loop Test of a Prosthetic Foot](https://doi.org/10.3390/app11209492) — Applied Sciences 2021.**
Prueba HiL donde **el amputado se modela** (modelo Virtual Pivot Point) y la prótesis se ensaya físicamente, intercambiando información en tiempo real. Miden trayectoria del centro de masa, GRF y torque de cadera.
→ **Ya existe la idea de accionar un banco de prótesis desde un modelo en vez de desde una grabación.** Es el precedente conceptual más directo.
→ **Pero:** el modelo VPP es un modelo de plantilla genérico, basado en física, **no personalizado por antropometría**, y **no se valida contra sujetos reales individuales**. Ahí está la diferencia, y es la diferencia que hay que defender.

**(b) [A compact and cost-effective gait simulator to advance prosthesis development with reduced reliance on human subject testing: Development, validation and application](https://www.sciencedirect.com/science/article/abs/pii/S1350453324001553) — Medical Engineering & Physics 2024.**
→ **Este es prácticamente el mismo proyecto**: simulador de marcha compacto y de bajo costo, con el objetivo explícito de reducir la dependencia de ensayos con sujetos humanos, y con estructura "desarrollo + validación + aplicación".
→ **Es la referencia más importante de todo este documento.** Hay que conseguir el texto completo y leerlo entero antes de comprometer nada. Determina tres cosas: qué ya está tomado, cuál es el estándar de validación que un revisor va a esperar, y —dato práctico— que este tipo de artículo se publica en Q3 (Med Eng Phys), lo cual es una señal de cuánto hay que añadir para llegar a Q1.

**(c) Ankle–foot prosthesis emulators** ([Caputo & Collins, universal emulator](https://www.academia.edu/25964910/A_Universal_Ankle_Foot_Prosthesis_Emulator_for_Human_Locomotion_Experiments); [human-in-the-loop optimization](https://royalsocietypublishing.org/doi/10.1098/rsos.202020)).
→ Es la línea dominante del campo, pero es el problema **inverso**: el emulador va montado sobre una persona real que camina. El banco de LIBRA es lo contrario — sin persona. Sirve para posicionarse por contraste, y para citar el argumento de por qué un banco sin persona tiene valor propio (repetibilidad, sin riesgo, sin fatiga, sin aprobación de ética por cada iteración de diseño).

### 4.3 El hueco, tras triangular los tres

> Existe generación de trayectorias desde antropometría (sin hardware). Existe accionamiento de bancos de prótesis desde un modelo (sin personalización, sin validación individual). Existen simuladores de marcha para desarrollo de prótesis (reproduciendo curvas normativas o grabadas).
>
> **No existe: generación de trayectorias personalizada por antropometría, ejecutada físicamente en un banco de prótesis, y validada contra los sujetos individuales para los que fue personalizada.**

Esa frase es el aporte, y es defendible — pero es una frase estrecha. Cualquier desviación (no personalizar, no validar contra los mismos sujetos, no ejecutar físicamente) la devuelve a territorio ya ocupado.

### 4.4 Bases de datos de validación externa — búsqueda 19-ago-2026, resultado honesto

El pivote (P-20, `DISCUSION_Q2.md`) pide validar el modelo generado contra datos que **no** participaron en construirlo — sin circularidad, mismo principio del §7.2 — y con preferencia explícita del equipo por una base **peruana o sudamericana**, porque el argumento de independencia regional del modelo (entrada = antropometría, no geografía) se sostiene mejor si la validación cruza de continente.

**No existe ninguna base de datos pública de marcha peruana o sudamericana, con antropometría, verificada y disponible hoy.** Búsqueda en español e inglés, sin resultado — no es que falte buscar más, es un vacío real del campo en esta región. Si el equipo insiste en el criterio regional, **la opción realista es capturar la base propia** (con el iSen que ya está disponible y probado) en vez de esperar encontrar una publicada que probablemente no existe.

Alternativas generales, sí verificadas como públicas y activas hoy:

| Dataset | Qué mide | Población | Por qué serviría / por qué no |
|---|---|---|---|
| [GaitRec — Horsak et al. 2020, *Scientific Data*](https://doi.org/10.1038/s41597-020-0481-z) *(DOI corregido 19-ago-2026, ver §4.5 — el original apuntaba a un dataset distinto)* | GRF bilateral, 75,732 ensayos | 211 sanos + 2084 pacientes | Grande y público, pero **solo fuerza, no cinemática articular** — no sirve para validar la trayectoria generada, sí podría servir para la parte de Fz |
| [Camargo, Ramanathan, Flanagan & Young 2021, *Journal of Biomechanics*](https://doi.org/10.1016/j.jbiomech.2021.110320) | Cinemática 3D completa + sensores, escaleras/rampas/nivel | 22 sanos | Bien documentado, el más citado y reutilizado de los tres (§4.5) — buena opción genérica si no se insiste en sudamericano |
| **[Hood, Ishmael, Gunnell, Foreman & Lenzi 2020, *Scientific Data*](https://doi.org/10.1038/s41597-020-0494-7)** | Cinemática y cinética completas, múltiples velocidades | **18 amputados transfemorales reales** | **El más valioso pese a no ser transtibial exacto** — es población protésica real, no sana. Sirve además para acercarse al vacío del §4.1 (no hay generador ajustado a amputados): compararía un modelo entrenado en sanos contra marcha protésica real, que es honestamente lo que este proyecto puede reclamar sin inventar un modelo nuevo |

**Recomendación con esto:** llevar esta decisión a discusión explícita en `DISCUSION_Q2.md` (P-21) — no se elige por cuenta propia entre "capturar base propia con iSen" vs. "usar Hood 2020 (amputados, no regional)" vs. "usar Camargo (sanos, no regional)" sin que el equipo lo confirme, porque cambia qué tan fuerte es el argumento de independencia regional del artículo.

### 4.5 Verificación de confiabilidad y adopción — 19-ago-2026

El equipo pidió explícitamente que ningún candidato (algoritmo o base de datos) se adopte solo por estar publicado — tiene que haber evidencia de que es **confiable y ha servido a estudios o equipos profesionales reales**, no solo un paper aislado. Verificación hecha en dos pasadas: (1) búsqueda de adopción por terceros vía Semantic Scholar/búsqueda dirigida: (2) **contraverificación directa de cada DOI contra Crossref y la página del editor**, hecha después, porque la pasada 1 reportó dos DOIs como "incorrectos" que al verificarlos resultaron ser correctos — **la única corrección real que sobrevivió fue el DOI de GaitRec en la tabla de arriba** (apuntaba a un dataset distinto, ya corregido). Las citas son de Semantic Scholar, consultadas el 19-ago-2026 — cambian con el tiempo, no son un número fijo.

**Candidatos de algoritmo:**

| Candidato (autor real, verificado) | Venue | Citas | Evidencia de adopción por terceros | Confianza |
|---|---|---|---|---|
| Moissenet, Leboeuf & Armand 2019 *(antes "Sci Rep 2019")* | *Scientific Reports* (Nature) | 73 (4 influyentes) | Volumen moderado, sin ejemplos puntuales confirmados en esta pasada | **Media-alta** |
| Yun, Kim, Shin, Lee, Deshpande & Kim 2014 *(antes "J Biomech 2013" — el año correcto es 2014, el DOI ya estaba bien)* | *Journal of Biomechanics* | 108 (7 influyentes) | Bien establecido en la línea de predicción de marcha por GPR | **Alta** |
| Koopman, van Asseldonk & van der Kooij 2014 | *Journal of Biomechanics* 47(6):1447-1458 | 87 (8 influyentes) | Confirmado: el enfoque de "eventos clave por regresión" se reutiliza en robots de rehabilitación de marcha posteriores (línea LOPES/LOPES II) | **Alta** — sigue siendo el candidato de partida más defendible (§6) |
| Semwal, Jain, Maheshwari & Khatwani 2023 *(antes "MTAP 2023")* | *Multimedia Tools and Applications* (Springer) | 59 (9 influyentes — mejor ratio de todos) | Sin ejemplos puntuales confirmados en esta pasada | **Media-alta** |
| Xin, Li, Qin, Liu, Wang, Luo, Zhuang & Zhou 2025 *(antes "Electronics 2025")* | MDPI *Electronics* | 0 | Ninguna — demasiado reciente, no es defecto de calidad | **Media** |
| Zhao, Wei, Xie, Liu, Qu, Cao, Ding & Liao 2026 | *PLOS ONE* | 0 | Ninguna — publicado en 2026 | **Media** — código y datos verificables en GitHub compensan la falta de adopción, pero es la apuesta más nueva de las seis |
| *(no es generador, dato colateral de viabilidad de hardware)* Karakish, Fouz & ELsawaf 2022, "Gait Trajectory Prediction on an Embedded Microcontroller Using Deep Learning" | MDPI *Sensors* | — | Confirma que un modelo de este tamaño corre en un ESP32 a 2.4 ms | — |

**Candidatos de base de datos de validación:**

| Candidato | Venue | Citas | Evidencia de adopción por terceros | Confianza |
|---|---|---|---|---|
| Horsak, Slijepcevic, Raberger, Schwab, Worisch & Zeppelzauer 2020 (GaitRec) | *Scientific Data* (Nature) | 80 (7 influyentes) | Confirmada — artículo de divulgación propio y reúso documentado en literatura de ML de marcha | **Alta** — recordar: solo GRF, no cinemática articular |
| Camargo, Ramanathan, Flanagan & Young 2021 | *Journal of Biomechanics* | **329 (59 influyentes)** | **El más verificado de los nueve** — usado en clasificación de fase de marcha con SVM, control de exoesqueletos con deep learning, múltiples estudios de ML citándolo directamente | **Muy alta** |
| Hood, Ishmael, Gunnell, Foreman & Lenzi 2020 | *Scientific Data* (Nature) | 1 | Prácticamente ninguna evidencia de reúso por terceros todavía | **Media-baja** — venue confiable, adopción real no demostrada |

**Lectura honesta de esta tabla:** los candidatos más recientes (Zhao 2026, Electronics 2025, Hood 2020) tienen cero o casi cero evidencia de adopción — no porque sean poco confiables, sino porque son demasiado nuevos para que otros equipos ya los hayan reutilizado. Eso es una limitación real a declarar si se adoptan, no un motivo automático de descarte. **Los dos candidatos con adopción más sólida y verificable son Koopman 2014 (algoritmo, ya recomendado en §6) y Camargo 2021 (base de datos, con el margen más amplio de los tres).**

**Importancia de parámetros por candidato — búsqueda 20-ago-2026 (para P-23, combinar sin reentrenar):**

| Candidato | ¿Reporta importancia/peso de sus parámetros? |
|---|---|
| Yun 2014 (14 parámetros, GPR) | **Verificado a texto completo 20-ago-2026 (PDF conseguido por el usuario vía acceso PUCP).** Respuesta honesta: **no reporta un ranking numérico de importancia.** Los 14 parámetros se eligieron por literatura previa (Vaughan 1992, Murray 1967, Hanavan 1964) que ya los identificaba como relevantes — no es un resultado propio del paper. Sí existe, en teoría, una matriz de longitud de escala por parámetro (Λb, λb1…λb14) en la función de covarianza GPR que técnicamente codifica sensibilidad — pero sus valores ajustados **no están en el texto principal**, solo podrían estar en el material suplementario (ver hallazgo nuevo abajo) |
| Koopman 2014 | No aplica — usa solo 2 parámetros (velocidad, talla), no hay "ranking" con tan pocos |
| Moissenet 2019 | Los coeficientes de su regresión (4 predictores) indican peso relativo implícitamente, pero no se confirmó que el paper lo discuta como "importancia" explícita |
| Semwal 2023 (LSTM+CNN) | No — es caja negra, sin desglose de features |
| Xin 2025 | No encontrado — 3 parámetros mapeados por GPR a coeficientes de Fourier, sin ranking |
| Zhao 2026 | Ya minimalista por diseño (3 parámetros) — no hay ranking que hacer con tan pocos |

**Lectura honesta:** la pregunta "qué parámetros influyen más" (P-23, Candidato 2) es más difícil de responder de lo que parecía — la mayoría de los seis candidatos no reportan esto explícitamente, sea porque usan pocos parámetros (Koopman, Zhao) o porque son caja negra (Semwal). **Cerrado 20-ago-2026, con el texto completo de Yun 2014 ya en mano: tampoco Yun la responde.** Sus 14 parámetros se adoptaron de literatura previa (Vaughan 1992, Murray 1967, Hanavan 1964), no de un análisis de importancia propio del paper — la matriz de sensibilidad del modelo GPR (Λb) existe matemáticamente pero sus valores no están en el texto principal. **Conclusión: ningún candidato de los seis responde directamente "qué parámetros importan más"** — no vale la pena seguir buscando esa respuesta puntual en más papers; se puede abandonar esa sub-pregunta sin que bloquee nada, ya que P-24 (Koopman + Zhao) no depende de ella.

**Confirmado 20-ago-2026 — el material suplementario existe y se consiguió.** El usuario descargó de ScienceDirect dos PDF adjuntos: el manual del toolbox (`docs/literatura/pdfs/yun2014_supp/1-s2.0-S0021929013004879-mmc1.pdf`) y un compilado de figuras extra (`...-mmc2.pdf`, 3.2 MB — resultados de predicción completos para los 113 sujetos, referenciados en la Fig. 7 del artículo principal, no es código ni datos).

**El manual confirma que el toolbox real (código + base de datos) no está en ScienceDirect — está hospedado aparte:**

- **Descarga:** el link de la página personal de UT Austin (`me.utexas.edu/~reneu/...`) está **muerto (404)**, esperable después de 13 años. **El de SourceForge sigue vivo** — verificado indirectamente (la cadena de redirecciones entrega un archivo real con ID de proyecto válido, no una página de error): `https://sourceforge.net/projects/gaitkinematicsprediction/files/Gait_Kinematics_Prediction_V1.01_Release.zip/download`. Falta que alguien lo descargue y confirme el contenido real del `.zip`.
- **Contenido esperado según el manual:** `Gait_Pred.m` (predicción, usa hiperparámetros ya optimizados en `./hyp/*` — **esto es exactamente "adoptar sin reentrenar"**, cumple P-23 al pie de la letra), `Gait_Model.m` (ajusta un hiperparámetro nuevo para una base de datos propia — **NO usar esta función**, cruzaría la línea de P-23 y reabriría el requisito de LOSO/muestra grande), `demo_Gait_Pred.m` (demo lista para correr), y la base `Data_x.mat`/`Data_y.mat` (108 sujetos, 14 parámetros → 14 movimientos articulares, nombrados con convención roll/pitch/yaw).
- **⚠️ Restricción de licencia real, hay que respetarla:** el código (`Gait Kinematics Prediction Toolbox`) es BSD permisivo, libre de usar. **Pero la base de datos `KIST Human Gait Pattern Data` tiene copyright reservado del KIST y su licencia dice explícitamente: "solo puede usarse para este toolbox, toda redistribución o uso para otros propósitos, con o sin modificación, no está permitido"** — sin contactar a los autores. Como P-24 ya decidió validar contra Camargo 2021 (no contra KIST), esto no bloquea nada: el toolbox se usaría solo para **generar** predicciones desde antropometría (uso permitido), nunca para redistribuir o reusar la base KIST como si fuera la base de validación del proyecto.

**Consecuencia práctica:** Yun 2014, vía este toolbox, pasa a ser **el candidato más fácil de cumplir P-23 al pie de la letra** de los tres en danza (Koopman, Zhao, Yun) — no hay que programar nada, solo correr `Gait_Pred.m` con los hiperparámetros ya publicados. Candidato a sumarse como tercer modelo del contraste, una vez que alguien del equipo descargue el `.zip` de SourceForge y confirme que corre.

**✅ Verificado 20-ago-2026 — el `.zip` de SourceForge se descargó y el código se revisó (no solo el manual).** 120 archivos, íntegro: `database/Data_x.mat` + `Data_y.mat` (108 sujetos), `Gait_Pred.m`, `Gait_Model.m`, dependencias GPR completas en `GP/`, y los 14 archivos de hiperparámetros ya optimizados (`hyp/hyp_op1.mat`…`hyp_op14.mat` + `hyp_op_P.mat` para el período). Copia local en `docs/literatura/pdfs/yun2014_toolbox/`.

**Interfaz confirmada, lista para usar sin modificar nada:**

```matlab
Gait_Kinematics = Gait_Pred(test_body_parameter, 'database', 'hyp')
```

- **Entrada:** vector de 14 valores — `[Edad, Talla(cm), Masa(kg), Sexo(0:f 1:m), Long.Muslo(mm), Long.Pantorrilla(mm), Ancho Bi-trocantéreo(mm), Ancho Bi-ilíaco(mm), ASIS(mm), Diámetro Rodilla(mm), Long.Pie(mm), Altura Maléolo(mm), Ancho Maléolo(mm), Ancho Pie(mm)]`.
- **Salida:** celda de 15 elementos (14 movimientos articulares + período de marcha), cada uno con `.mean` (trayectoria predicha, tiempo normalizado) y `.std` (incertidumbre). **Los que importan para la reducción del §5: `R./L. Knee Flexion` y `R./L. Ankle P.flex.` — exactamente rodilla y tobillo, sin nada más que extraer.**
- Corre en Matlab **y** Octave (detecta `OCTAVE_VERSION` automáticamente) — mismo patrón de compatibilidad dual que ya sigue el resto de `CODIGOS/` del proyecto.

**Con esto, Yun 2014 deja de ser "en espera" — es un tercer candidato confirmado y listo**, junto a Koopman 2014 y Zhao 2026 (P-24). No hace falta ninguna acción más del equipo para este candidato en particular; el siguiente paso es técnico (construir el pipeline de comparación), no de investigación.

---

## 5. La contribución técnica que falta poner en el centro: la reducción a 3 DOF

**Esto es lo más valioso de esta revisión, y no estaba en la propuesta original.**

Todos los modelos de §4.1 producen **ángulos articulares**: cadera, rodilla, tobillo. El simulador **no tiene cadera, rodilla ni tobillo** — tiene tres ejes de plataforma (horizontal, vertical, sagital) y una prótesis real montada, que aporta su propia articulación de tobillo.

Es decir: **la salida del modelo publicado no es ejecutable en el banco.** Hace falta una transformación entre el espacio articular del modelo y el espacio de tarea del banco:

```
θ_cadera(t), θ_rodilla(t), θ_tobillo(t)   +   longitudes de segmento del sujeto
                        │
                        ▼  cinemática directa de muslo + pierna
        posición y orientación del encaje / extremo proximal de la prótesis
                        │
                        ▼  proyección al plano sagital, referida a la plataforma
        x(t) horizontal,  z(t) vertical,  φ(t) ángulo sagital     →  CSV del simulador
```

Por qué esto convierte el artículo:

- **Deja de ser "implementamos el modelo de otro".** Es un problema cinemático con una solución propia, verificable y reutilizable por cualquiera que tenga un banco de prótesis de pocos grados de libertad — que son casi todos.
- **La antropometría entra dos veces**, y eso refuerza el argumento de personalización: una vez como entrada del modelo publicado, y otra como longitudes de segmento en la cinemática directa. Aunque el modelo publicado apenas discrimine entre sujetos (riesgo real, §7.1), **el escalado por longitudes de segmento sí produce trayectorias de plataforma mediblemente distintas** — es geometría, no estadística. Esto es una defensa concreta contra la objeción "todas las trayectorias salen iguales".
- **Genera una fuente de error propia y aislable**, que se suma limpiamente al presupuesto de errores que el proyecto ya sabe descomponer.
- **La adaptación deja de ser "a nuestro antojo"** y pasa a ser justificable. Importante: un revisor castiga las modificaciones ad hoc. Toda modificación al modelo publicado tiene que tener una razón declarada (restricción del banco, rango de los motores, límite de velocidad) y, si se puede, una **ablación** que muestre qué aporta cada una.

**Comprobación pendiente:** confirmar si la reducción es exactamente 3 DOF o si el banco impone acoplamientos adicionales (p. ej. si el eje sagital rota sobre un punto fijo y no sobre el centro articular anatómico, aparece un error de offset que hay que modelar). Esto se resuelve con el CAD y con el equipo de Mecatrónica, no con literatura.

### 5-bis. Respaldo bibliográfico de la reducción — búsqueda 20-ago-2026

Se buscó si esta transformación (ángulos articulares → orientación del segmento tibial) ya está resuelta en literatura, en vez de derivarla desde cero. **Resultado: sí, y es biomecánica clásica bien establecida — no hay que inventarla, hay que citarla.**

- **Es la relación estándar entre ángulo relativo (articular) y ángulo absoluto (de segmento).** Cadera/rodilla/tobillo son ángulos **relativos** (entre dos segmentos adyacentes); la inclinación del segmento tibial respecto a la horizontal —exactamente la convención `atan2` que ya usa este proyecto— es un ángulo **absoluto**. La relación entre ambos es directa: el ángulo absoluto de un segmento se obtiene sumando/restando los ángulos relativos articulares desde una referencia (típicamente el pie o el suelo) a lo largo de la cadena cinemática. **Cita de respaldo:** Winter, *Biomechanics and Motor Control of Human Movement* — el texto de referencia estándar del campo para esta distinción (edición/DOI a verificar antes de fijarla en el manuscrito, no confirmado a texto completo todavía).
- **Reencuadre honesto de la novedad, no una mala noticia:** que la transformación en sí sea cinemática de libro de texto **no le quita valor al aporte** — al contrario, lo hace más defendible ante un revisor porque no es un método ad hoc inventado por el equipo. La novedad real está en **aplicar** esta reducción estándar al problema específico de un banco de prótesis de 3-DOF y **validarla** contra bases de datos independientes — no en la matemática de la transformación misma.
- **OpenSim, confirmado como la herramienta/referencia metodológica establecida del campo** para este tipo de cálculo (orientación de segmento desde ángulos articulares, vía su motor de cinemática directa/inversa, con modelos de pierna que usan `hip_flexion`/`knee_angle`/`ankle_angle` como coordenadas generalizadas). No hace falta instalarlo, pero es una cita de respaldo metodológico reconocida — más fuerte que presentar la reducción como un cálculo propio sin precedente.

**Consecuencia práctica para las longitudes de segmento (entrada de la reducción):** si el equipo no mide directamente todas las longitudes de segmento de cada sujeto, existe el estándar de facto del campo para estimarlas desde talla/masa/sexo: **de Leva 1996**, *"Adjustments to Zatsiorsky-Seluyanov's segment inertia parameters"*, *Journal of Biomechanics* 29(9):1223-1230, DOI `10.1016/0021-9290(95)00178-6` — verificado (2900+ citas, PDF completo disponible). **Caveat real:** calibrado para adultos jóvenes; existe un ajuste posterior para adultos mayores (2015, ScienceDirect) si la cohorte de validación elegida no es de adultos jóvenes — revisar según qué base de datos se termine usando (Camargo/GaitRec/Hood).

---

## 6. Qué modelo adoptar — y una jugada que sube el nivel del artículo

### Criterios de selección

1. **Parámetros completamente publicados** (coeficientes en el paper o material suplementario) — si hay que pedirle datos a los autores, el cronograma queda a merced de un correo sin responder.
2. **Entrada compatible** con lo que se puede medir con cinta métrica y balanza.
3. **Salida en ángulos articulares sagitales** de miembro inferior (es lo que la reducción del §5 necesita).
4. Preferentemente, **pensado para ejecución robótica** — ya viene con restricciones de suavidad y continuidad resueltas.

Por esos cuatro, el candidato de partida más razonable es el de **[J Biomech 2014](https://www.sciencedirect.com/science/article/abs/pii/S0021929014000682)** (splines quínticos, velocidad + talla, diseñado para soporte robótico de marcha), con la **regresión múltiple de [Sci Rep 2019](https://www.nature.com/articles/s41598-019-45397-4)** como línea base simple e interpretable.

### La jugada: no adoptar uno, adoptar dos o tres y compararlos en el banco

En vez de *"implementamos el modelo X"*, el artículo puede ser:

> **El primer contraste experimental, sobre hardware físico, de métodos publicados de generación de trayectorias de marcha desde antropometría — evaluados por lo que producen cuando un banco de prótesis real tiene que ejecutarlos.**

Esto es sustancialmente más fuerte, y encaja perfecto con lo que el usuario quiere (no reclamar autoría del algoritmo). Ventajas:

- **Responde una pregunta que nadie respondió.** Los cinco métodos de §4.1 se comparan entre sí solo en RMSE numérico. Nadie ha reportado cuál sobrevive a la ejecución física — y las diferencias importan: un modelo puede tener excelente RMSE y a la vez producir aceleraciones que el banco no puede seguir, o discontinuidades en la transición de ciclo que en simulación no se ven y en el hardware sí.
- **Convierte una debilidad en fortaleza.** "No inventamos un algoritmo" deja de sonar a carencia y pasa a ser el diseño del estudio.
- **Reutiliza infraestructura ya construida.** `Procesar_Multisujeto_Core.m`, `SPM1D_Core.m` y `Calcular_Metricas_Curva.m` sirven tal cual para comparar N modelos × M sujetos, que es la misma estructura de datos que N sujetos × M ensayos.
- **Costo marginal bajo:** implementar el segundo y tercer modelo es trabajo de días; la campaña experimental (que es lo caro) es la misma.

**Riesgo a vigilar:** que los modelos den resultados casi idénticos y el contraste no arroje nada. Mitigación: elegir modelos deliberadamente distintos en familia (uno de regresión, uno de splines, uno de aprendizaje profundo) en vez de tres variantes del mismo enfoque.

---

## 7. Diseño de validación

### 7.1 Tres niveles, y la descomposición de error en tres vías

Este es el esqueleto de Resultados, y es lo que sostiene el rigor del artículo:

| Nivel | Qué se compara | Qué error aísla |
|---|---|---|
| **A — Numérico** | Trayectoria generada vs. marcha real medida del sujeto (sin tocar el simulador) | **Error del modelo** |
| **B — Reducción** | Trayectoria de plataforma reducida (§5) vs. trayectoria de plataforma derivada de la marcha real medida del sujeto | **Error de la reducción cinemática** |
| **C — Físico** | Salida medida del simulador (iSen sobre la plataforma) vs. marcha real del sujeto | **Cadena completa** |

Y entonces: **error de hardware = C − B**, con B y A ya separados. Es la misma lógica de tres fuentes desacopladas que el proyecto ya aplica al problema de Fz (offset, fidelidad de seguimiento, corrección inercial) — no hay que inventar metodología, hay que reaplicarla. Ese paralelismo es además un buen argumento de coherencia metodológica ante un revisor.

### 7.2 Sin circularidad — innegociable

Si el modelo se recalibra con los mismos sujetos contra los que se valida, el resultado no vale nada. Obligatorio:

- Si los modelos se usan **tal como están publicados** (sin reajustar coeficientes), no hay circularidad y el problema desaparece — **y esta es una razón fuerte para no reentrenar nada.** Otra ventaja del encuadre "adoptamos, no creamos".
- Si se reajusta cualquier coeficiente con datos propios: **validación cruzada dejando un sujeto fuera (LOSO)** obligatoria, más un conjunto de prueba físico separado (3-4 sujetos que solo se usan para las corridas del nivel C).

### 7.3 Ganancia de personalización contra el piso de ruido

El resultado que decide si el artículo es Q1 o Q2:

```
RMSE_generico      = usar una curva normativa única para todos los sujetos
RMSE_personalizado = usar la trayectoria generada con la antropometría de cada uno
Piso de ruido      = variabilidad ensayo-a-ensayo del MISMO sujeto (ICC(3,1), ya implementado)

Ganancia = RMSE_generico − RMSE_personalizado     →  ¿supera el piso de ruido?
```

Si la ganancia no supera el piso de ruido, la personalización no es demostrable y el hallazgo honesto es negativo (publicable, pero Q2). Si lo supera, el artículo tiene su resultado titular.

**Nota del §5:** el escalado geométrico por longitudes de segmento juega a favor aquí, porque produce diferencias de trayectoria de plataforma que no dependen de que el modelo estadístico discrimine bien.

---

## 8. Riesgos

| Riesgo | Gravedad | Mitigación |
|---|---|---|
| **Rango antropométrico estrecho** (muestra de conveniencia universitaria: talla 1.55–1.80, edad casi constante) → las trayectorias generadas salen casi idénticas y el revisor escribe *"esto no es personalización, es la media del grupo"* | **Alta — sigue siendo el riesgo principal** | Reclutar **estratificado por talla**, forzando activamente los extremos (<1.60 m y >1.80 m, ambos sexos). Es gratis si se decide antes de reclutar e imposible de arreglar después. Más el argumento geométrico del §5 |
| **Marcha sana ≠ marcha protésica.** Todos los modelos de §4.1 están ajustados con sujetos sanos; el banco acciona una prótesis | **Alta — objeción segura de revisor** | Declararlo explícitamente como decisión de diseño: el banco emula **la entrada que el miembro residual impone a la prótesis**, no la marcha protésica completa. Evaluar si existen modelos ajustados a población amputada. Si el artículo 1 (JTEHM) ya deja establecido este encuadre, el artículo 2 lo hereda |
| **El precedente de Med Eng Phys 2024** (§4.2b) cubre más de lo que se cree | **Media-alta, sin evaluar** | Conseguir y leer el texto completo **antes que cualquier otra tarea** |
| **La velocidad domina sobre la antropometría** — es el predictor más influyente en la literatura, y medirla rompe el argumento "solo cinta métrica y balanza" | Media | Predecir la velocidad autoseleccionada desde la longitud de pierna (relación de Froude, bien establecida) y usarla como variable interna. Decisión a declarar y defender en Métodos, no a dejar implícita |
| **Modificaciones ad hoc al modelo publicado** leídas como falta de rigor | Media | Cada modificación con razón declarada (rango de motores, límite de aceleración, continuidad de ciclo) + ablación cuando sea posible |
| **Reclamar equivalencia desde un "no hubo diferencia significativa"** | **Alta — error frecuente y fatal en revisión de Q1** | Prueba de equivalencia con umbral declarado a priori, no test de diferencia. Ver §2.6 — implica extender `SPM1D_Core.m` |
| **n insuficiente** si se reajustan coeficientes | Media (se vuelve Baja si no se reajusta) | No reajustar (§2.1, §7.2). Si se reajusta: n ≥ 30-40, no 15-20 |
| Integración RPi–ESP32 sigue bloqueada | Alta hoy, se resuelve sola | Es prerrequisito del artículo 1 también — se resuelve antes por necesidad. Además, en este diseño **no bloquea la captura de sujetos** (§2.4) |

---

## 9. Cronograma sin fecha dura — horizonte propuesto

Sin plazo impuesto, pero sin alargarlo. Arranca **después** de cerrar el envío a JTEHM (quincena de setiembre 2026):

| Fase | Duración | Contenido | Depende de |
|---|---|---|---|
| **0 — Lectura crítica** | 2-3 semanas | Los tres precedentes de §4.2, sobre todo Med Eng Phys 2024. Decidir posicionamiento definitivo | Nada. **Se puede empezar hoy mismo** |
| **1 — Reducción a 3 DOF** | 4-6 semanas | Derivar y verificar la transformación del §5 contra los datos que ya existen (marcha medida → trayectoria de plataforma → comparar con el CSV real que se usó). **Verificable sin sujetos nuevos y sin ética** | Datos del artículo 1 |
| **2 — Implementación** | 3-4 semanas | 2-3 modelos publicados en Python sobre la RPi, generando CSV | Fase 1 |
| **3 — Validación numérica (niveles A y B)** | 3-4 semanas | Contra la cohorte del artículo 1, sin tocar hardware | Fases 1-2 + antropometría capturada (§10) |
| **4 — Cohorte de validación** | 6-10 semanas | **Solo si hace falta ampliar o rebalancear.** Con modelos sin reajuste, la cohorte de 15-20 del artículo 1 puede alcanzar (§2.1) — lo que sí conviene es reclutar complementos en los extremos de talla, no más sujetos del centro | Comité de ética |
| **5 — Campaña física (nivel C)** | 6-8 semanas | Ejecución en el banco + medición | Fase 4 + integración RPi–ESP32 |
| **6 — Análisis y redacción** | 8-10 semanas | Reutilizando `MULTISUJETO/`, `ESTADISTICA/`, `VALIDACIONES/` + módulo nuevo de equivalencia (§2.6) | Fase 5 |

**Total ≈ 9-12 meses de trabajo efectivo → envío a mediados/finales de 2027.** Las fases 0 y 1 son las de mejor relación valor/costo: no dependen de ética, ni de sujetos nuevos, ni de que el hardware esté integrado, y **la fase 1 es la que decide si el artículo es viable** — si la reducción cinemática no reproduce las trayectorias de plataforma ya conocidas, todo lo demás se cae, y es mejor saberlo en octubre de 2026 que en 2027.

~~**Ventaja secundaria del plazo largo:** para 2027, el paper de conferencia IBITeC 2026 ya estará publicado y el artículo de JTEHM también. El artículo 2 **puede y debe citar a ambos**, construyendo una línea de trabajo propia y citable — con lo que el problema de superposición de publicación que forzó el pivote del 03-ago desaparece por completo.~~

> 🚨 **CORREGIDO 20-ago-2026 — el párrafo de arriba ya NO aplica.** Se basaba en un envío a 2027; con el pivote (`CLAUDE.md` banner inicial, `DISCUSION_Q2.md` P-20, checkpoint interno 14-set-2026), este es el artículo que se está escribiendo **ahora**, no dentro de un año. El paper de conferencia IBITeC 2026 **casi con certeza no estará publicado todavía** cuando se envíe este manuscrito, y el manuscrito de JTEHM del enfoque anterior nunca se llegó a enviar. **Vuelve a aplicar la regla original, sin excepción:** este artículo **no cita ni menciona** el paper de conferencia IBITeC 2026 (mismo dataset del sujeto original, mismo laboratorio — riesgo real de superposición de publicación/auto-plagio si se detecta después) — reafirmado explícitamente por el usuario el 20-ago-2026. El enfoque, la redacción y el encuadre de este artículo tienen que ser propios, no una reformulación de lo ya escrito para la conferencia.

---

## 10. Lo único que hay que hacer YA, y que si no se hace se pierde

Cuando el comité apruebe y se capture a los 15-20 sujetos del **artículo 1**, medir y registrar en ese mismo momento:

- Talla, masa, edad, sexo
- **Longitud de muslo y de pierna** (trocánter–línea articular de rodilla; línea articular–maléolo) — **críticas para la reducción cinemática del §5**, no solo para el modelo
- Longitud de pie, ancho de pelvis
- **Velocidad autoseleccionada** de cada pasada (m/s, calculada, no estimada)

**Dos minutos por sujeto.** Son medidas antropométricas no invasivas que deberían estar ya en el protocolo de ética (confirmarlo antes de que se apruebe, no después). Sin esto, el artículo 2 arranca con cero datos y hay que volver a reclutar con ética de por medio.

Segunda acción de costo cero: en el trabajo futuro del artículo 1, **anunciar esta línea explícitamente** — algo como *"the present validation establishes the tracking-fidelity envelope within which model-generated, subject-specific trajectories can be executed; ongoing work addresses the generation of platform trajectories from anthropometric parameters alone, removing the need for prior motion capture of the target subject."* Da continuidad citable y convierte la objeción "sigue siendo un CSV pregrabado" en hoja de ruta declarada.

---

## 11. Revista

**Artículo 1 (en curso): IEEE JTEHM, sin cambios.**

**Artículo 2: IEEE TNSRE.** Dentro de editoriales aprobadas por la universidad (IEEE/IET):

| Revista | Cuartil | IF | Costo | Ajuste |
|---|---|---|---|---|
| **IEEE TNSRE** | **Q1** | 5.2 | **Gold OA, APC USD 2160 (2026)** — dentro del tope | **El mejor.** Método + hardware + rehabilitación es literalmente su alcance. El requisito de "metodología sustancialmente novedosa" lo cubre la reducción a 3 DOF + el contraste experimental de modelos |
| JNER (Springer) | **Q1** | 6.0 | ≈USD 2440 (verificar) | Muy bueno, más competitivo |
| IEEE JTEHM | Q2 | 3.9 | USD 2160 | Sirve, pero desaprovecha el salto. Además 8 páginas es muy poco para modelo + reducción + validación en 3 niveles |
| Scientific Reports (Nature) | Q1 | 4.9 | USD 1990 | Q1 "por definición", cumple el requisito del VRI al menor costo, sin público específico |
| IEEE/ASME T-Mech | Q1 | 7.3 | Híbrida | Exige novedad de control/mecatrónica — encaje débil |
| Medical Engineering & Physics | Q3 | 2.3 | — | **Donde se publicó el precedente más cercano** (§4.2b). Referencia de nivel: hay que estar claramente por encima de eso |

### Dos correcciones a las notas actuales del proyecto

1. **TNSRE ya no es híbrida — es Gold OA obligatoria, APC USD 2160 para 2026.** `revistas_candidatas_Q2.md` la registra como "Híbrida" sin costo. Cuesta **exactamente lo mismo que JTEHM** y está dentro del tope, siendo Q1/IF 5.2 en vez de Q2/IF 3.9. *(Verificar en la [lista oficial de APC de IEEE](https://journals.ieeeauthorcenter.ieee.org/wp-content/uploads/sites/7/IEEE-Article-Processing-Charges-List.pdf) antes de comprometerse.)*
2. **JNER figura hoy en ≈USD 2440**, no ~USD 3690 como registran las notas del 03-ago — entraría en el tope. Fuente secundaria, confirmar con Springer.

**Aparte, no relacionado con esta línea pero pertinente:** *Progress in Biomedical Engineering* aparece en `revistas_candidatas_Q2.md` como candidata Q1 viva, pero es de **IOP Publishing**, que **no figura en la lista cerrada de editoriales aprobadas**. Por el mismo criterio que descartó a SAGE/POI, probablemente también está fuera — confirmar.

---

## 12. Preguntas abiertas

- **¿Qué cubre exactamente el precedente de Med Eng Phys 2024?** Tarea número uno, bloquea el posicionamiento.
- **¿La reducción a 3 DOF es exacta o el banco impone acoplamientos?** Resolver con el CAD y el equipo de Mecatrónica.
- **¿Existen modelos de generación de trayectorias ajustados a población amputada**, o solo a sujetos sanos? Determina la fuerza de la respuesta al riesgo de §8.
- **¿La ganancia de personalización supera el piso de ruido en la población disponible?** Comprobable con los datos del artículo 1 sin construir nada — si las curvas normalizadas de los 15-20 sujetos salen casi indistinguibles, esta línea está muerta antes de empezar. **Hacer ese chequeo apenas haya datos multi-sujeto.**
- ¿El protocolo de ética cubre las medidas antropométricas adicionales, o hay que enmendarlo?
- ¿Modelo interpretable (regresión) o con incertidumbre explícita (GPR)? El GPR entrega bandas de confianza por punto del ciclo, comparables directamente contra la banda ±1 SD del sujeto real — figura muy fuerte.
- Confirmar montos y modelos de acceso de TNSRE y JNER contra las páginas oficiales.

---

## 13. Tablero cuantificado — dónde estamos y qué falta para Q1

**Cómo leer esto:** los pesos y puntajes son un juicio informado, no una medición — pero están construidos sobre criterios verificables (cada fila tiene una condición de cierre concreta), así que sirven para comparar avance contra avance y para decidir en qué gastar las próximas semanas. Se recalcula cada vez que se cierre un hito.

### 13.1 Estado actual: **29 / 100**

| # | Dimensión | Peso | Hoy | Aporta | Qué la cierra |
|---|---|---|---|---|---|
| 1 | **Posicionamiento frente al estado del arte** | 20 | 35% | 7.0 | Leer los 3 precedentes de §4.2 (sobre todo Med Eng Phys 2024) y poder escribir en una frase qué hace este trabajo que ninguno hace |
| 2 | **Contribución técnica propia** (reducción a 3 DOF, §5) | 20 | 10% | 2.0 | Derivarla y **verificarla numéricamente** contra datos ya existentes |
| 3 | **Datos / cohorte de validación** | 15 | 5% | 0.75 | 15-20 sujetos capturados **con antropometría de segmentos** y velocidad real |
| 4 | **Hardware operativo** | 15 | 40% | 6.0 | Integración RPi–ESP32 terminada + fidelidad de seguimiento caracterizada |
| 5 | **Rigor estadístico** | 15 | 65% | 9.75 | Ya hay SPM1D, ICC(3,1), RMSEnorm y motor multi-sujeto construidos y probados. Falta el **módulo de equivalencia** (§2.6) |
| 6 | **Diseño anti-objeción** (prospectivo, estratificado, no circular) | 10 | 20% | 2.0 | Decidir y dejar por escrito: congelamiento previo, estratificación por talla, no reajustar coeficientes |
| 7 | **Encaje editorial y formato** | 5 | 30% | 1.5 | Plantilla TNSRE, confirmación de APC, Impact Statement |
| | **TOTAL** | **100** | | **29.0** | |

**Lectura honesta del 29:** casi un tercio del camino — **pero el tercio que está hecho es el de las herramientas** (fila 5, y parte de la 4), que es lo que normalmente consume más tiempo pero **no es lo que decide la aceptación**. Las tres filas que sí deciden si un revisor de Q1 lo acepta — posicionamiento, contribución propia y datos — están entre 5% y 35%. No es un mal punto de partida; es un punto de partida desbalanceado.

**Umbrales de referencia:** ≥80 = envío creíble a Q1 · 60-79 = Q2 sólido (JTEHM, Gait & Posture) · 45-59 = Q3 · <45 = no enviable.

### 13.2 Ruta al 83 — qué suma cada hito

| Hito | Fila | Salta | Puntos | Semanas | **Pts/semana** |
|---|---|---|---|---|---|
| **Congelar el diseño**: prospectivo + estratificación por talla + no reajustar | 6 | 20→80% | **+6.0** | ~1 | **6.0** ⬅ |
| **Leer los 3 precedentes** y fijar posicionamiento | 1 | 35→80% | **+9.0** | 2-3 | **3.6** |
| **Derivar y verificar la reducción a 3 DOF** | 2 | 10→70% | **+12.0** | 4-6 | **2.4** |
| **Módulo de equivalencia** en `SPM1D_Core.m` | 5 | 65→95% | **+4.5** | 2-3 | **1.8** |
| **Cohorte capturada** con antropometría completa | 3 | 5→85% | **+12.0** | 8-12 | **1.2** |
| **Integración RPi–ESP32** + caracterización | 4 | 40→90% | **+7.5** | — | fuera de control directo |
| Plantilla y formato TNSRE | 7 | 30→90% | **+3.0** | 1 | 3.0 |
| | | | **29 → 83** | | |

**Conclusión operativa:** la acción de mayor retorno por lejos **no cuesta dinero ni datos ni hardware — es una decisión**. Congelar el diseño (generar antes de capturar, reclutar por extremos de talla, no tocar coeficientes) vale 6 puntos por una semana de trabajo, y **hay que tomarla antes de la campaña de captura del artículo 1**, porque después es irrecuperable. Le sigue leer tres papers.

Entre las dos primeras filas: **15 de los 54 puntos que faltan se consiguen sin un solo sujeto, sin ética y sin que el hardware funcione.**

### 13.3 Compuertas go/no-go con umbral numérico

Criterios verificables, a fijar **antes** de ver los datos:

| # | Compuerta | Umbral | Si no pasa |
|---|---|---|---|
| **G1** | Med Eng Phys 2024 no cubre la personalización antropométrica ni la validación individual | Binario | **Stop** — replantear el hueco antes de invertir más |
| **G2** | La reducción a 3 DOF reconstruye una trayectoria de plataforma conocida a partir de la marcha medida | **RMSEnorm ≤ 1.0** (la escala del proyecto marca "Deficiente" desde >2) | Revisar el modelo cinemático; si no baja de 2, la línea no es viable |
| **G3** | Dispersión antropométrica de la cohorte | **Rango de talla ≥ 25 cm** y ambos sexos representados | La personalización no será demostrable → replantear como estudio normativo (Q2) |
| **G4** | Ganancia de personalización sobre curva normativa única | **Ganancia ≥ 2 × piso de ruido intra-sujeto** | Resultado negativo honesto → publicable, pero Q2 |
| **G5** | Equivalencia generado-vs-sujeto | **≥ 80% de puntos del ciclo dentro de ±1 SD intra-sujeto**, con prueba de equivalencia (no de diferencia) | Reportar como caracterización de discrepancia, no como equivalencia |
| **G6** | Fidelidad de seguimiento del banco bajo carga | A definir con los datos del artículo 1 | El error de hardware domina y enmascara el del modelo → el artículo pasa a ser sobre el banco, no sobre el generador |

**G1 y G2 son las decisivas**, y ninguna necesita sujetos nuevos, aprobación de ética ni el simulador funcionando. Ambas se pueden resolver antes de que termine 2026. **Si G1 o G2 fallan, esta línea se cancela con un costo de ~8 semanas en vez de ~12 meses** — esa es la razón principal para ordenarlas primero.

### 13.4 Convención para este documento

Toda sección que se agregue de aquí en adelante cierra con su **estado cuantificado**: la fila del tablero que afecta, el puntaje actual y la condición numérica de cierre. Y al cerrar cualquier hito, se recalcula §13.1 con fecha.

**Historial de recálculos:** 05-ago-2026 → 29/100 (línea base).

### 13.5 Recálculo post-pivote (23-ago-2026) — nuevo tablero, dimensiones distintas

**Por qué es una tabla nueva y no un recálculo de §13.1:** las filas de §13.1 (hardware RPi-ESP32, ética, cohorte capturada) pertenecían al plan **anterior al pivote de P-20** (`docs/DISCUSION_Q2.md`) — la fase activa hoy es 100% computacional (P-22), esas filas ya no miden lo que decide si esta línea llega a buen puerto. §13.1 se conserva sin tocar como registro histórico. Esta tabla mide el plan vigente: generar la trayectoria desde antropometría (literatura, sin datos propios) y validarla contra Camargo 2021.

| # | Dimensión | Peso | Hoy | Aporta | Qué la cierra |
|---|---|---|---|---|---|
| 1 | **Candidatos de algoritmo implementados y probados** (Koopman + Zhao + Yun) | 20 | 95% | 19.0 | Ya cerrado — 17/17 pruebas PASS en MATLAB real, incluida validación externa (ROM de Koopman cerca del publicado en su Tabla 6). El 5% que falta: una celda ambigua en las tablas de Koopman (documentada, no bloqueante) |
| 2 | **Reducción cinemática** (ángulos articulares → segmento tibial → x,z,φ de plataforma, §5) | 15 | 40% | 6.0 | Vía tobillo lista y conectada para los 3 candidatos. `Segmento_Posicion_Core.m` (23-ago) ya convierte ángulo+longitud en posición (x,y) relativa, con invariante física verificada contra datos reales. Falta encadenar el muslo (mismo problema de signo de Yun/Koopman) y calibrar contra el cero real del banco — **eso último sigue bloqueado por Mecatrónica/CAD** |
| 3 | **Validación Nivel A/B contra Camargo 2021** | 20 | 25% | 5.0 | `Cargar_Camargo_Core.m` listo y probado con AB06 real (marcadores, ángulos IK, longitud de tibia real). **La comparación en sí — correr los 3 candidatos con antropometría real de un sujeto de Camargo y medir el error contra sus ángulos reales — todavía no se ejecutó ni una vez** |
| 4 | **Rigor estadístico reutilizado** (SPM1D, ICC(3,1), TOST, potencia a priori) | 15 | 85% | 12.75 | Ya construido y probado con sintéticos en sesiones previas (`ESTADISTICA/`, `POTENCIA_EQUIVALENCIA/`) — reutilizable tal cual. Falta aplicarlo con los datos reales de esta línea específica |
| 5 | **Posicionamiento en la literatura** (diseño de validación en 3 niveles A/B/C, §7) | 10 | 40% | 4.0 | Diseño ya definido en este documento. Precedente clave (Sudeesh 2024 / R4) sigue bloqueado por 403 de ScienceDirect sin acceso institucional — pendiente desde antes del pivote |
| 6 | **Encaje editorial / revista** | 10 | 10% | 1.0 | Sin decidir tras el pivote (banner de `CLAUDE.md`) — puede ser Q1 tipo TNSRE o quedarse en Q2, depende de qué tan lejos llegue el camino físico (fila 7) |
| 7 | **Camino físico final** (cinemática completa + banco real, Nivel C) | 10 | 0% | 0.0 | Diferido, no descartado (P-22) — depende de Mecatrónica/CAD y, más adelante, de la integración RPi-ESP32 |
| | **TOTAL** | **100** | | **47.75** | |

**Lectura honesta del ~48:** casi la mitad del camino, y a diferencia del 29 de §13.1, **este casi-mitad sí es del tipo que decide si la línea funciona** (filas 1 y 2, el algoritmo en sí y su conversión a posición). Pero el patrón de riesgo se repite: lo más rápido de construir (código) ya está; lo que realmente prueba que sirve (fila 3, la validación real) sigue en 25%. **Ese es el próximo cuello de botella, no falta de código — falta correr el código que ya existe contra datos reales y mirar el número que sale.**

**Palanca de mayor retorno inmediata:** cerrar la fila 3 (correr Nivel A/B real con AB06/AB09) no depende de nadie más que de escribir el script comparador (reusa `Calcular_Metricas_Curva.m`/`SPM1D_Core.m`, ya construidos) — sube esa fila de 25% a ~70% y el total a ~57/100, sin esperar a Mecatrónica, a una decisión de revista, ni a ningún acceso bloqueado.

**Historial de recálculos (post-pivote):** 23-ago-2026 → 46.25/100 (línea base de esta tabla) · 23-ago-2026 (mismo día, más tarde, `Segmento_Posicion_Core.m`) → 47.75/100 · **27-ago-2026 → ~55/100, recalculado con dimensiones actualizadas en `docs/algoritmo/JUSTIFICACION_MODELOS_Y_ESTADO_Q1.md` §6 (documento único de referencia para la comparación completa de los 3 candidatos, sus figuras, y el estado hacia Q1 — léase ese archivo primero, este §13.5 queda como historial).**

---

## Fuentes consultadas (05-ago-2026)

**Modelos de generación de trayectorias**
- [Lower limb sagittal gait kinematics can be predicted based on walking speed, gender, age and BMI — Scientific Reports 2019](https://www.nature.com/articles/s41598-019-45397-4)
- [Statistical method for prediction of gait kinematics with Gaussian process regression — J. Biomechanics 2013](https://www.sciencedirect.com/science/article/abs/pii/S0021929013004879)
- [Speed-dependent reference joint trajectory generation for robotic gait support — J. Biomechanics 2014](https://www.sciencedirect.com/science/article/abs/pii/S0021929014000682)
- [Gait reference trajectory generation at different walking speeds using LSTM and CNN — MTAP 2023](https://link.springer.com/article/10.1007/s11042-023-14733-2)
- [A Personalized Trajectory Planning Approach for Exoskeleton Robots Using GPR and Fourier Series — Electronics 2025](https://doi.org/10.3390/electronics14234554)

**Precedentes de banco/hardware — prioridad de lectura**
- [A compact and cost-effective gait simulator to advance prosthesis development with reduced reliance on human subject testing — Medical Engineering & Physics 2024](https://www.sciencedirect.com/science/article/abs/pii/S1350453324001553)
- [Hardware-in-the-Loop Test of a Prosthetic Foot — Applied Sciences 2021](https://doi.org/10.3390/app11209492)
- [A Universal Ankle–Foot Prosthesis Emulator for Human Locomotion Experiments](https://www.academia.edu/25964910/A_Universal_Ankle_Foot_Prosthesis_Emulator_for_Human_Locomotion_Experiments)
- [Shortcomings of human-in-the-loop optimization of an ankle-foot prosthesis emulator — Royal Society Open Science](https://royalsocietypublishing.org/doi/10.1098/rsos.202020)

**Métricas de revistas**
- [IEEE TNSRE — IF 5.2, Q1](https://www.journalmetrics.org/journal/ieee-transactions-on-neural-systems-and-rehabilitation-engineering) · [instrucciones para autores](https://www.embs.org/tnsre/for-authors/) · [lista oficial de APC IEEE 2026](https://journals.ieeeauthorcenter.ieee.org/wp-content/uploads/sites/7/IEEE-Article-Processing-Charges-List.pdf)
- [JNER — IF 6.0, Q1](https://www.journalmetrics.org/journal/journal-of-neuroengineering-and-rehabilitation)
- [IEEE/ASME T-Mech — IF 7.3, Q1](https://www.journalmetrics.org/journal/ieee-asme-transactions-on-mechatronics-4)
