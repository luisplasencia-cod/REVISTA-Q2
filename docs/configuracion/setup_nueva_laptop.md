# Configurar Claude Code en una laptop nueva (o la otra laptop)

Guía para dejar la segunda laptop (Mac u otra) al mismo nivel que esta: mismo repo, mismo skill de proyecto (`matlab`), y los mismos plugins/skills globales de Claude Code.

Hecha el 19-ago-2026, a partir de lo instalado en la laptop principal (Windows). Si en el futuro se agrega o quita un plugin, actualizar esta lista.

## Estado en la Mac (actualizado 22-ago-2026)

- **Pasos 1-4 (repo, marketplaces, plugins) — completos.** Los 4 marketplaces de terceros agregados y los 7 plugins instalados.
- **Bug encontrado al instalar `thinking-skills@thinking-skills-marketplace`:** el `plugin.json` del repo de terceros (`tjboudreaux/cc-thinking-skills`) declara `"skills": ["skills/"]` (sin prefijo `./`), que la versión actual del CLI rechaza con `skills: Invalid input` — el schema exige que cada ruta empiece con `./` (`"./skills/"` sí valida). Es un bug del repo externo, no de esta instalación. **Fix aplicado localmente en la Mac:** se editó a mano el `plugin.json` cacheado en `~/.claude/plugins/marketplaces/thinking-skills-marketplace/.claude-plugin/plugin.json`, cambiando `"skills/"` → `"./skills/"`. Ese parche vive fuera del repo (`~/.claude`, no se sincroniza por git) y **se pierde si se corre `/plugin marketplace update`** — si el error reaparece en cualquier laptop, aplicar el mismo cambio de una línea.
- **Paso 5 (base de datos KIST) — pendiente, dejado para la próxima sesión en la Mac.** No es bloqueante para nada del código ya escrito, solo hace falta si se va a correr `Gait_Pred.m`/`demo_Gait_Pred.m` del toolbox Yun 2014. Ver instrucciones completas abajo.

## 1. Clonar el repo

```bash
git clone https://github.com/luisplasencia-cod/REVISTA-Q2.git
```

Esto ya trae `.claude/skills/matlab/` incluido — no hace falta ningún paso extra para ese skill, viaja con el repo.

## 2. Agregar los marketplaces de plugins que no son el oficial

`claude-plugins-official` es el marketplace por defecto de Claude Code — no hace falta agregarlo. Los siguientes 4 son de terceros y hay que registrarlos uno por uno, dentro de una sesión de Claude Code:

```
/plugin marketplace add blader/humanizer
/plugin marketplace add tjboudreaux/cc-thinking-skills
/plugin marketplace add alexgreensh/token-optimizer
/plugin marketplace add Imbad0202/academic-research-skills
```

## 3. Instalar/activar los plugins

```
/plugin install claude-md-management@claude-plugins-official
/plugin install exa@claude-plugins-official
/plugin install desktop-commander@claude-plugins-official
/plugin install humanizer@humanizer
/plugin install thinking-skills@thinking-skills-marketplace
/plugin install token-optimizer@alexgreensh-token-optimizer
/plugin install academic-research-skills@academic-research-skills
```

## 4. Verificar

```
/plugin
```

Deberían aparecer los 7 plugins con estado activo, igual que en la laptop principal:

| Plugin | Marketplace |
|---|---|
| claude-md-management | claude-plugins-official |
| exa | claude-plugins-official |
| desktop-commander | claude-plugins-official |
| humanizer | humanizer |
| thinking-skills | thinking-skills-marketplace |
| token-optimizer | alexgreensh-token-optimizer |
| academic-research-skills | academic-research-skills |

Si algún comando de arriba falla por un cambio de sintaxis entre versiones de Claude Code, usar el menú interactivo `/plugin` → "Browse marketplaces" para buscar cada uno por nombre e instalarlo a mano.

## 5. Datos que NO vienen en el repo — hay que descargarlos aparte

Por diseño, algunos archivos quedan fuera de git a propósito (ver `.gitignore`) — normalmente por licencia, no porque falte subirlos. Si en la otra laptop se va a trabajar en el generador de trayectoria (candidato Yun 2014), hace falta este paso manual:

**KIST Human Gait Pattern Data (toolbox de Yun et al. 2014)** — el repo es público y esta base de datos tiene copyright reservado del KIST, con licencia que prohíbe redistribuirla fuera del propio toolbox (ver `docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` §4.5 para el detalle completo). Por eso el código del toolbox sí está en el repo pero los archivos de datos no.

1. Descargar el `.zip` completo (gratis, sin necesitar acceso PUCP) desde:
   `https://sourceforge.net/projects/gaitkinematicsprediction/files/Gait_Kinematics_Prediction_V1.01_Release.zip/download`
2. Extraerlo.
3. Copiar únicamente `database/Data_x.mat` y `database/Data_y.mat` dentro de `docs/literatura/pdfs/yun2014_toolbox/database/` del repo local (esa carpeta ya existe con el resto del toolbox — código, hiperparámetros, demos — solo faltan estos dos archivos).

Sin este paso, `Gait_Pred.m`/`demo_Gait_Pred.m` no van a poder cargar la base y el toolbox no corre.

**Material suplementario del paper Yun et al. 2014 (J Biomech, ScienceDirect)** — manual del toolbox y figuras extra de los 113 sujetos (referenciadas en la Fig. 7 del artículo, ver `docs/planificacion/analisis_escalamiento_Q1_generador_trayectorias.md` línea ~248). Es material de Elsevier con acceso restringido, tampoco va al repo.

1. Con acceso institucional PUCP (VPN o red de campus), abrir:
   `https://www.sciencedirect.com/science/article/abs/pii/S0021929013004879`
2. Descargar los dos adjuntos de "Supplementary data" (`mmc1.pdf` — manual, `mmc2.pdf` — figuras, ~3.2 MB).
3. Colocarlos en `docs/literatura/pdfs/yun2014_supp/` del repo local (crear la carpeta si no existe).

Sin este paso no se pierde funcionalidad de código — solo referencia documental para `docs/algoritmo/diseno_matematico_generador.md`.

## Notas

- Los pasos 2-4 son instalación **global de usuario** (`~/.claude`), no tocan el repo — no hace falta commitear ni pushear nada por esto.
- `.claude/settings.local.json` (permisos locales) **no** se sincroniza por diseño — cada laptop arma su propio historial de permisos allow/deny a medida que se usa. No es necesario copiarlo.
- Si se agrega un plugin nuevo en una laptop, conviene volver a este archivo y sumarlo a la lista para que la otra laptop no se quede desactualizada.
- **Nunca** subir `docs/literatura/pdfs/yun2014_toolbox/database/*.mat`, el `.zip` de SourceForge, ni el `.zip`/carpeta de material suplementario de ScienceDirect a git, aunque git no se queje — los tres están en `.gitignore` a propósito.
