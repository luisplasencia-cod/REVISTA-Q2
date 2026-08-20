# Configurar Claude Code en una laptop nueva (o la otra laptop)

Guía para dejar la segunda laptop (Mac u otra) al mismo nivel que esta: mismo repo, mismo skill de proyecto (`matlab`), y los mismos plugins/skills globales de Claude Code.

Hecha el 19-ago-2026, a partir de lo instalado en la laptop principal (Windows). Si en el futuro se agrega o quita un plugin, actualizar esta lista.

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

## Notas

- Los pasos 2-4 son instalación **global de usuario** (`~/.claude`), no tocan el repo — no hace falta commitear ni pushear nada por esto.
- `.claude/settings.local.json` (permisos locales) **no** se sincroniza por diseño — cada laptop arma su propio historial de permisos allow/deny a medida que se usa. No es necesario copiarlo.
- Si se agrega un plugin nuevo en una laptop, conviene volver a este archivo y sumarlo a la lista para que la otra laptop no se quede desactualizada.
