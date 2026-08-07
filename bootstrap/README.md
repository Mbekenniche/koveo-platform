# Workstation bootstrap

The toolchain this project depends on is declared, not accumulated. Every tool used to build, deploy or operate the platform appears in a manifest, and a fresh machine is brought to that state by a single command.

---

## macOS (`arm64`) — primary workstation

**Prerequisite:** [Homebrew](https://brew.sh/).

```
brew bundle --file=bootstrap/Brewfile
```

**Verify** that the machine matches the manifest — reports anything missing:

```
brew bundle check --file=bootstrap/Brewfile --verbose
```

**Prune** anything installed but no longer declared:

```
brew bundle cleanup --file=bootstrap/Brewfile
```

Per-repository hooks still have to be installed once in each clone:

```
pre-commit install
pre-commit install --hook-type commit-msg
```

---

## Linux (`amd64`) — secondary workstation

Added in step 12, when the second machine joins the project. The two machines run different architectures on purpose: container images published from this repository are multi-architecture manifest lists, and the cost of emulated versus native cross-builds is measured rather than assumed.

---

## Architecture check

Homebrew on Apple Silicon can install under emulation without saying so, and a duplicated `PATH` entry then decides which binary wins. Verify the architecture of the binary itself, not the output of `--version`:

```
file $(which <tool>)
```

Anything reporting `x86_64` on this machine is either an intentional exception — documented here — or a mistake.

---

## Verified rebuild

A declaration that has never been exercised is a guess. The rebuild is verified by removing a non-trivial tool, confirming its absence, and restoring it from the manifest alone.

*Evidence recorded in the step journal.*
