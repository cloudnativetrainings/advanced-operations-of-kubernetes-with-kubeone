# TODOs `container-image/dockerfile`

Findings aus dem Review vom 2026-09-07, nach Schwere sortiert.

## Korrektheit

## Image-Größe

- [ ] **`dockerfile:123` — Cleanup-Layer spart nichts.**
      Die apt-Listen sind in `dockerfile:9`, `:71`, `:78`, `:87` bereits commited; ein `rm` im späteren Layer
      legt nur eine Whiteout-Markierung darüber, die Daten bleiben im Image. Genau darauf zielt DL3009 — die
      Ignores in `:8`, `:70`, `:75`, `:83` unterdrücken die Warnung statt das Problem zu lösen.
      Fix: `&& rm -rf /var/lib/apt/lists/*` ans Ende **jedes** apt-RUN, danach Zeile 123 und alle
      DL3009-Ignores entfernen.

- [ ] **`dockerfile:46-49` — krew räumt nicht auf.**
      `/training/krew-linux_amd64.tar.gz` und das entpackte Verzeichnis bleiben liegen.
      helm, helmfile und velero löschen ihre Artefakte.

- [ ] **`dockerfile:48,55,64,93` — `tar -zxvf`.**
      Das `v` schreibt jede einzelne Datei ins Build-Log.

## Reproduzierbarkeit

- [ ] **`dockerfile:31` — code-server ungepinnt.**
      Jeder Rebuild liefert eine andere Version, während alle anderen Tools über ARGs festgenagelt sind.
      Fix:
      ```dockerfile
      ARG CODE_SERVER_VERSION=4.x.y
      RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}
      ```

- [ ] **`dockerfile:106-110` — oh-my-zsh und Plugins ungepinnt.**
      Installation von `master`, dazu drei `git clone --depth 1` ohne Tag.

## Konsistenz

- [ ] `dockerfile:94` — velero mit `0755`, kubectl/helm/helmfile in `:40`, `:56`, `:65` mit `0500`
- [ ] `dockerfile:55,57,58,63,64,66,67,93,95,96` — relative Pfade, während `:47-49` absolut `/training/...` schreibt
- [ ] `dockerfile:77,89` — `tee -a`, überall sonst `>>`
- [ ] `dockerfile:33` — `RUN mkdir /training/` überflüssig, `WORKDIR` legt das Verzeichnis selbst an
- [ ] `dockerfile:6` — `ENV DEBIAN_FRONTEND` leakt in die Laufzeit, als `ARG` deklarieren
- [ ] `dockerfile:54,62,92` — doppeltes Leerzeichen nach `curl -LO`
- [ ] `dockerfile:132-137` — toter auskommentierter Block am Dateiende

## Die zwei TODOs im Dockerfile

- [ ] **`dockerfile:3` — "do I need this?" zum `SHELL`-Statement: ja.**
      Drei RUN-Blöcke enthalten Pipes — `:31`, `:76`, `:84`. Ohne `-o pipefail` zählt nur der Exit-Code des
      letzten Kommandos in der Pipe; ein fehlgeschlagenes `curl` liesse den Build stillschweigend durchlaufen.
      Kommentar durch die Begründung ersetzen.

- [ ] **`dockerfile:139` — "cross processor build".**
      Alle Abhängigkeiten haben arm64 (geprüft: ubuntu:26.04, kubectl, krew, helm, helmfile, velero,
      gcloud-apt, terraform-apt). Es fehlt die `TARGETARCH`-Parametrisierung der Zeilen `:39`, `:46-49`,
      `:54-58`, `:62-66`, `:92-96`, plus Build über `docker buildx --platform linux/amd64,linux/arm64 --push`.
      Achtung: die Labs pinnen amd64 ebenfalls fest — `01_install-k1/README.md:14`,
      `15_upgrade-k1/README.md:16`, `14_upgrade-cluster/README.md:23`.

## Anmerkung, kein Befund

`dockerfile:71-72` installiert kubectx aus dem Ubuntu-Repo — auf 26.04 ist das `0.9.5-2build1`, nicht das
aktuelle `0.11.0`. Falls 0.11.0 gewünscht ist, geht das nur über das `.deb` aus dem `stonking`-Pool:

```dockerfile
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
     http://archive.ubuntu.com/ubuntu/pool/universe/k/kubectx/kubectx_0.11.0-1_amd64.deb \
  && rm -rf /var/lib/apt/lists/*
```

## Reihenfolge der Umsetzung

1. Korrektheit + Image-Größe — echte Defekte, in einem Rutsch
2. Konsistenz — optional dazu
3. Reproduzierbarkeit — braucht eine Versionsentscheidung (code-server, oh-my-zsh)
4. Multi-Arch — eigener Schritt, betrifft auch die Lab-READMEs
