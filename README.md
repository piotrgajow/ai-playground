# Claude Code Plugins

A personal Claude Code plugins repository that supplies skills and hooks.

## Usage

### Adding the marketplace

Add the plugin marketplace to Claude Code (global):
```
/plugin marketplace add piotrgajow/ai-playground
```

### Installing plugins

Install plugins via
```
/plugin install <name>>@piotrgajow [--scope <scope>]
```
- `<name>` - name of the plugin
- `<scope>` - scope of the plugin; `local` only for this project, not committed; `project` - only for this projectm comitted to the repo; `user` - for the user, globally (defualt)

### Using skills

After installation, skills are available in any Claude Code session as `/piotrgajow:<skill-name>`.

### Updating plugins

To get plugin updates run
```
/plugin marketplace update
/reload-plugins
```

## Working with the repo

### Structure

- `.claude-plugin/marketplace.json` - marketplace catalogue
- `piotrgajow-main` - main plugin for shared skills, hooks, etc.
- `piotrgajow-sounds-starcraft` - plugin for StarCraft sound notifications

### Extending the plugins

- Add skills to the `piotrgajow-main/skills/` directory
- Add hooks to the `piotrgajow-main/hooks/hooks.json` file under the relevant event name
- When referencing files, use `${CLAUDE_PLUGIN_ROOT}` variable to reference the root directory of the plugin
- Executables can be put into the `bin` directory and called by name (will be available in `$PATH`)

### Local testing

You can add a plugin from local repo directory by path via
```bash
claude --plugin-dir /path/to/ai-playground/<plugin>
```
