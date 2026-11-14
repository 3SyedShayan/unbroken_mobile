# Hygen — Unbroken Mobile Code Generation

Templates live in `_templates/`. Use generators to scaffold consistent, architectural code.

---

## All Generators

| Command | Purpose |
|---|---|
| `hygen screen new <name>` | Create a full screen (root + state + widgets + routes) |
| `hygen screen consumer <name>` | Add a BlocConsumer listener to an existing screen |
| `hygen screen listener <name>` | Add a BlocListener to an existing screen |
| `hygen screen _widget <name>` | Add a private widget file to an existing screen |
| `hygen cubit nested <name>` | Create a new cubit + repo (full 6-file structure) |
| `hygen cubit update <name>` | Inject new action modules into an existing cubit |
| `hygen provider new <name>` | Create an app-level ChangeNotifier provider |

---

## `screen new` — Create a Screen

```bash
hygen screen new <name>
hygen screen new <name> --formData false
hygen screen new <name> --formData true --formKeys "title,description" --widgets "header,body"
```

## `cubit nested` — Create a Cubit

```bash
hygen cubit nested <name>
```

