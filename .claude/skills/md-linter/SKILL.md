---
name: md-linter
description: Checks a lab README for typos and grammar issues. Invoke when the user says "lint md", "lint markdown" or "lint".
---

# Markdown linter

Check the lab `README.md` files for typos and grammar issues.

- If the user names a specific lab, check only that one. A bare numeric prefix in the arguments (e.g. `01`, `12`) counts as naming a lab — resolve it to the single top-level directory whose name begins with that prefix followed by `_` (e.g. `01` → `01_install-kcp-locally/`) and lint only the files under that directory. If no directory matches, or more than one matches, stop and ask the user which one they meant.
- Otherwise, if the working tree has unstaged changes (`git diff --name-only` returns at least one path), restrict the run to those changed files only (READMEs, YAML, makefiles — skip `.99_todos/` and `.secrets/`). Do not fall through to the full-repo scan in that case.
- Otherwise check every top-level `*/README.md` (skip `.99_todos/`).
- Check on usage of file paths that only absolute paths are used, starting with `/training`. Verify if the paths are correct.
- Ignore code blocks, commands, YAML, and identifiers — only check prose.
- Report findings as `file_path:line_number` with the fix suggestion.
- If you find any TODO make me aware of this.
- Ask before changing files if this should be done

## Must not

- Do not change pinned versions (`K1_VERSION`, `KKP_INSTALLER_VERSION`, Kubernetes versions, image tags).
- Do not read, open, or grep files under `.secrets/` — passwords, SSH keys, service-account JSON are off-limits.
- Do not read, open, or grep files under `.99_todos/` 
- Do not "fix" placeholders (`TODO`, `XXXXX`, `TODO-STUDENT-EMAIL@...`) — they are intentional.
- Do not rewrite or reorder commands, YAML, or code blocks — only prose is in scope.
- [Don't fix LetsEncrypt spelling](feedback_letsencrypt_spelling.md) — leave `LetsEncrypt` alone in lab READMEs; user rejected the brand-correct edit.