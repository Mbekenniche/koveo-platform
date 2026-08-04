# Contributing

Conventions for this repository. They apply from the first commit and are enforced automatically where possible.

---

## Commit messages

Commits follow [Conventional Commits](https://www.conventionalcommits.org/).

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Subject line.** Imperative mood, lowercase, no trailing period, 72 characters maximum. Write `add gateway api route for the tracking service`, not `Added routes.` or `updates`.

**Types**

| Type | Use for |
|---|---|
| `feat` | A new capability |
| `fix` | A correction to existing behaviour |
| `refactor` | A change that alters neither behaviour nor interface |
| `docs` | Documentation only, including ADRs |
| `test` | Tests only |
| `build` | Build system, dependencies, container images |
| `ci` | Pipeline definitions |
| `chore` | Housekeeping with no effect on the delivered artefact |

**Scopes.** The scope names the area touched, and the vocabulary is fixed so that history stays greppable:

```
network  system  dns  tls  k8s  gateway  helm  gitops
terraform  ansible  ci  supply-chain  identity  observability
docs  bootstrap
```

**Body.** Optional for trivial changes, required whenever the *why* is not obvious from the subject. Explain the reason, not the diff — the diff is already in the commit.

**Breaking changes.** `!` after the scope, and a `BREAKING CHANGE:` footer describing the migration.

---

## Branches

```
<type>/<short-description>
```

Types match the commit types above. Example: `feat/gateway-api-routes`.

`main` is the only long-lived branch. It must always be in a state that can be deployed.

<!-- ─────────────────────────────────────────────────────────────
     DECISION 1 — Branch lifetime
     Decide and write it here:
       - How long may a branch live before it must be merged or dropped?
       - May you commit directly to `main`, or is a branch always required?
     A solo project is not a team, and pretending otherwise creates ceremony
     you will abandon in week three. Pick something you will actually follow,
     and say why.
     ───────────────────────────────────────────────────────────── -->

---

## Integrating a branch

<!-- ─────────────────────────────────────────────────────────────
     DECISION 2 — Merge strategy
     Choose one and justify it here. This answers soutenance question 2,
     so the reasoning matters more than the choice.

       (a) Squash        one commit per branch on `main`.
                         Linear, readable history; loses intermediate steps.

       (b) Rebase        every commit replayed onto `main`.
                         Linear and detailed; rewrites hashes, and requires
                         every intermediate commit to be worth keeping.

       (c) Merge commit  history preserved as it happened.
                         Truthful; harder to read, and `git bisect` gets noisier.

     State what you lose with your choice, not only what you gain.
     ───────────────────────────────────────────────────────────── -->

---

## Automated checks

Two layers, and they are not equivalent.

**Local — [`pre-commit`](https://pre-commit.com/).** Runs on every commit. Install once per clone:

```
pre-commit install
pre-commit install --hook-type commit-msg
```

It checks commit-message format, blocks credentials and private keys, rejects oversized files, and validates YAML and JSON.

**Pipeline — the actual gate.** Local hooks can be bypassed with `git commit --no-verify`, so they are a convenience, not a control. Secret scanning is re-run over the full history in CI, and a positive result fails the build.

**If a real secret is ever committed:** rotate the credential first, then clean the history. In that order. Once a secret has been pushed, it must be treated as compromised regardless of what happens to the history afterwards — rewriting Git does not retract what has already been fetched, cached or indexed.

---

## Tooling versions

<!-- ─────────────────────────────────────────────────────────────
     DECISION 3 — Pinning
     Decide whether the workstation toolchain (bootstrap/) pins exact
     versions or tracks latest, and write the reasoning here.
     This answers soutenance question 4. Both answers are defensible;
     they are not defensible for the same reasons.
     ───────────────────────────────────────────────────────────── -->

---

## Architecture decision records

Any structural decision gets an ADR in `docs/adr/`, numbered sequentially, following [MADR](https://adr.github.io/madr/).

An ADR is required when a choice is expensive to reverse, when a credible alternative was rejected, or when the reasoning will be invisible in six months. It states the context, the options considered, the decision, and **at least one accepted downside**. An ADR without a downside is advertising, not a record.

ADRs are never deleted. A superseded ADR is marked as superseded and links to the one that replaced it.

---

## Definition of done

A change is complete when:

- [ ] It does what it claims, verified rather than assumed
- [ ] Automated checks pass
- [ ] Documentation reflects the new state — no future tense, nothing that does not exist
- [ ] Any structural decision it embodies is recorded as an ADR
- [ ] No credential, personal address or local configuration file entered the history
- [ ] Cloud resources created for the change are destroyed, or explicitly labelled as persistent