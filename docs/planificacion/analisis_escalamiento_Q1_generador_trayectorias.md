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

- **[Zhao et al. 2026, PLOS ONE](https://doi.org/10.1371/journal.pone.0338041)** — *"A predictive model of joint dynamics and ground reaction force using only leg length, body mass, and walking cadence"*. Entrada: **solo** longitud de pierna, masa corporal y cadencia — ni siquiera pide edad/sexo, la entrada más mínima de todos los candidatos, calza perfecto con "cinta métrica y balanza". Método: series de Fourier (parte cinemática) + ecuaciones de Lagrange (parte dinámica). Salida: ángulos de cadera/rodilla y momentos de cadera/rodilla/tobillo en plano sagital, **más GRF vertical y anteroposterior** — cubre de una vez la parte cinemática y la de fuerza que el proyecto ya trabajaba por separado. **Coeficientes publicados en su Tabla 1, y código + datos en GitHub** (`github.com/zhaohuan13/predictive-model-of-joint-dynamics-and-ground-reaction-force`). Validado con SPM1D contra Vicon+AMTI — **el mismo motor estadístico que ya está construido y probado en `CODIGOS/ESTADISTICA/SPM1D_Core.m`**, cero adaptación necesaria del lado del análisis. Entrenado con 10 sujetos sanos, validado con 4 sanos separados (Xi'an Jiaotong University) — **sin validación externa independiente todavía**, que es exactamente el rol que puede cumplir este proyecto.
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
| [GaitRec (Horsak et al. 2020, *Scientific Data*)](https://doi.org/10.1038/s41597-020-0563-y) | GRF bilateral, 75,732 ensayos | 211 sanos + 2084 pacientes | Grande y público, pero **solo fuerza, no cinemática articular** — no sirve para validar la trayectoria generada, sí podría servir para la parte de Fz |
| [Camargo et al. — EPIC Lab, Georgia Tech](https://www.epic.gatech.edu/opensource-biomechanics-camargo-et-al/) | Cinemática 3D completa + sensores, terreno variado | 22 sanos | Bien documentado, repositorio activo — buena opción genérica si no se insiste en sudamericano |
| **[Hood, Ishmael et al. 2020, *Scientific Data*](https://doi.org/10.1038/s41597-020-0494-7)** | Cinemática y cinética completas, múltiples velocidades | **18 amputados transfemorales reales** | **El más valioso pese a no ser transtibial exacto** — es población protésica real, no sana. Sirve además para acercarse al vacío del §4.1 (no hay generador ajustado a amputados): compararía un modelo entrenado en sanos contra marcha protésica real, que es honestamente lo que este proyecto puede reclamar sin inventar un modelo nuevo |

**Recomendación con esto:** llevar esta decisión a discusión explícita en `DISCUSION_Q2.md` (P-21) — no se elige por cuenta propia entre "capturar base propia con iSen" vs. "usar Hood 2020 (amputados, no regional)" vs. "usar Camargo (sanos, no regional)" sin que el equipo lo confirme, porque cambia qué tan fuerte es el argumento de independencia regional del artículo.

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

**Ventaja secundaria del plazo largo:** para 2027, el paper de conferencia IBITeC 2026 ya estará publicado y el artículo de JTEHM también. El artículo 2 **puede y debe citar a ambos**, construyendo una línea de trabajo propia y citable — con lo que el problema de superposición de publicación que forzó el pivote del 03-ago desaparece por completo.

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
