# IDE (code-server)

Notes on how the trainee IDE is configured, plus a review of the current
`vscode_settings.json`. The image runs [code-server](https://github.com/coder/code-server)
as its entrypoint, so the trainee gets a browser IDE at the published port with the repo
root bind-mounted to `/training/`.

Settings are referenced by id rather than by line number, so this document does not go
stale when the files are reordered.

## Configuration surfaces

There is no single place — settings, port and runtime behaviour live in three files.

| What | Where | Notes |
| --- | --- | --- |
| Editor / UI / language settings | `vscode_settings.json` | copied to `/root/.vscode/User/settings.json` |
| Installed extensions | `dockerfile` (`code-server --install-extension`) | resolved against **Open VSX**, not the MS marketplace |
| Port inside the container | `dockerfile` → `CMD --bind-addr 0.0.0.0:8080` | the only effective place; overrides `config.yaml` and `$PORT` |
| Port documentation | `dockerfile` → `EXPOSE 8080` | informational, only acts on `docker run -P` |
| Host port mapping | `makefile` → `-p 8080:8080` | change only the left side to move the host port |
| code-server runtime behaviour | `dockerfile` → `CMD` flags | telemetry, update check, workspace trust — not reachable from `settings.json` |

Neither `.devcontainer/` nor `vscode_settings.json` contains anything about the port.

## Extensions

Every extension must exist on Open VSX, because `code-server --install-extension` resolves
there. Marketplace-only extensions would need a manual `.vsix` install.

Currently installed:

- `esbenp.prettier-vscode`
- `redhat.vscode-yaml`
- `hashicorp.terraform`

`editor.formatOnSave` is enabled globally, so every language the trainees touch needs a
`[language]` → `editor.defaultFormatter` entry — otherwise code-server prompts for a
formatter on save. `terraform.tfvars` has its own language id `terraform-vars` and needs a
separate entry from `terraform`.

Only `editor.defaultFormatter`, `editor.formatOnSave`, `editor.formatOnSaveMode` and
`editor.codeActionsOnSave` work inside a `[language]` block. Extension settings do not —
see the review below.

## AI features

`chat.disableAIFeatures: true` is the master switch. It disables and hides chat, agent mode
and inline suggestions, and disables the Copilot extensions in one go — no further `chat.*`
keys are required.

`hashicorp.terraform` ships a Terraform MCP server integration
(`terraform.mcp.server.enable`), but its manifest default is already `false`. Nothing to do
there.

## Telemetry

`telemetry.telemetryLevel: "off"` covers VS Code's own telemetry. Two channels are **not**
covered by it:

1. **VS Code experiments** are fetched independently of the telemetry level. The
   [VS Code FAQ](https://code.visualstudio.com/docs/supporting/faq) states that
   `workbench.enableExperiments: false` is needed to stop them "regardless of your
   telemetry preferences".
2. **Extension-owned telemetry.** `redhat.vscode-yaml` ships its own channel and asks for
   consent via popup on first start. It is controlled by `redhat.telemetry.enabled`.

Beyond that, code-server has a **telemetry layer of its own**, above VS Code's. It reports
machine id, CPU model and core count, memory, shell type and OS release/arch. It cannot be
switched off from `settings.json` — only via the `--disable-telemetry` flag
([code-server FAQ](https://github.com/coder/code-server/blob/main/docs/FAQ.md)).

## Review of `vscode_settings.json`

Checked against the extension manifests and the VS Code settings reference.

### Ineffective / wrong place

**`experimentalFeatures.validateOnSave` inside `[terraform]` and `[terraform-vars]`** does
nothing. Two reasons: the correct id carries the extension prefix, and the setting is
declared `scope: window` in the extension manifest. Window-scoped settings are not
language-overridable and cannot be set in a `[language]` block at all. Correct form is
top-level:

```json
  "terraform.experimentalFeatures.validateOnSave": true,
```

**`workbench.settings.applyToAllProfiles`** lists `chat.agent.enabled`,
`chat.commandCenter.enabled` and `github.copilot.enable`, none of which are set in the file
any more. The list only controls which *existing* user settings apply across profiles, so
entries without a corresponding setting are dead weight.

**`task.allowAutomaticTasks: "on"`** has nothing to permit — there is no `tasks.json` and
no `.vscode/` in the repo.

### Redundant — identical to the default

| Setting | Default |
| --- | --- |
| `terminal.integrated.hideOnStartup: "never"` | `"never"` |
| `yaml.completion: true` | `true` |
| `yaml.validate: true` | `true` |

`yaml.format.enable: false` is the only one of the three YAML keys that deviates from its
default.

### Redundant — covered elsewhere

- **`editor.inlineSuggest.enabled: false`** — `chat.disableAIFeatures: true` already turns
  inline suggestions off.
- **`workbench.secondarySideBar.defaultVisibility: "hidden"`** — this was aimed at the
  chat panel opening itself. With AI features fully disabled, nothing opens there.
- **`window.restoreWindows: "none"`** — a desktop concept. In the web build the browser tab
  *is* the window, so it has no effect.
- **`update.mode: "none"` / `update.showReleaseNotes: false`** — VS Code's own updater is
  not wired up in code-server; the effective control is the `--disable-update-check` flag.
  Keep only as a second layer.

### Contradiction

`[yaml].editor.defaultFormatter: "redhat.vscode-yaml"` together with
`yaml.format.enable: false`: the global `editor.formatOnSave` invokes the formatter on save,
the extension declines, nothing happens. If YAML should deliberately stay unformatted —
plausible, so the comments in the lab manifests are left alone — then the intent is
clearer as:

```json
  "[yaml]": {
    "editor.formatOnSave": false
  },
```

`yaml.format.enable` can then be dropped and the intent lives in one place.

## Still open: code-server CMD flags

```dockerfile
CMD ["--bind-addr", "0.0.0.0:8080", "--auth", "none", \
     "--user-data-dir", "/root/.vscode", \
     "--disable-telemetry", "--disable-update-check", \
     "--disable-workspace-trust", "--disable-getting-started-override", "."]
```

All four flags are defined in
[`src/node/cli.ts`](https://github.com/coder/code-server/blob/main/src/node/cli.ts).
`--disable-workspace-trust` doubles up on `security.workspace.trust.enabled: false`, and
`--disable-getting-started-override` stops code-server from replacing the start page, which
matters for `workbench.startupEditor: "readme"`.

## Drift against `.devcontainer/devcontainer.json`

Same configuration surface, and it carries real leftovers:

- **`terminal.integrated.shell.linux`** has been deprecated since VS Code 1.56 and replaced
  by `terminal.integrated.defaultProfile.linux` — which `vscode_settings.json` already uses
  correctly.
- **`.gititnore`** in `files.exclude` is a typo for `.gitignore`, so the entry never
  matches.
- The two files have diverged: the devcontainer is missing every new telemetry key,
  `container-image/` and the formatter associations, while it carries `.git/` and
  `teardown.sh` in `files.exclude`, which the image variant lacks.

The duplication itself is not pointless: code-server reads
`/root/.vscode/User/settings.json` because of `--user-data-dir`, whereas the VS Code Server
in a devcontainer reads `~/.vscode-server/data/...`. The image settings therefore do not
apply on the devcontainer path. Both files are needed, but they have to be kept in sync.

## Open points

- `makefile` publishes `-p 8080:8080` twice. Given that `kubeone ui` runs on 8081, one of
  the two lines was probably meant to be `-p 8081:8081`. Docker creates one binding rule
  per `-p`, so two identical ones can make the container collide with itself on startup.
- `--auth none` together with `-p 8080:8080` publishes the IDE without a password on all
  host interfaces. Fine for a local trainer setup; `-p 127.0.0.1:8080:8080` is the tighter
  binding if the host is reachable from the network.
