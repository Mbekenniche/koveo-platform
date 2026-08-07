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
docs
```

**Body.** Optional for trivial changes, required whenever the *why* is not obvious from the subject. Explain the reason, not the diff — the diff is already in the commit.

**Breaking changes.** `!` after the scope, and a `BREAKING CHANGE:` footer describing the migration.

---

## Branches

```
<type>/<short-description>
```

Types match the commit types above. Example: `feat/gateway-api-routes`.

`main` is the only long-lived branch, and it must always be in a state that can be deployed.

**Direct commits to `main` are not allowed**, with one exception: the commit that initialises an empty repository. Everything else goes through a branch. The reason is not process for its own sake — a branch gives every change a reviewable boundary, keeps `main` revertable as a unit, and provides the place where automated verification will run once the delivery pipeline exists.

**Branch lifetime.** A branch inactive for **two weeks** must be merged if the work is finished, or deleted if it is abandoned or superseded. Long-lived branches accumulate divergence and lose the context that made them understandable.

---

## Integrating a branch

Explicit merge commits (`git merge --no-ff`).

* **What this gains.** The history stays factual: branch topology, original commit order and original hashes are preserved, and a merge commit marks the boundary of a complete unit of work.
* **What this costs.** The graph is harder to read than a linear history, and `git bisect` has more nodes to traverse — which adds noise when isolating the commit that introduced a fault.

---

## Automated checks

Two layers, and they are not equivalent.

**Local — [`pre-commit`](https://pre-commit.com/).** Runs on every commit. Install once per clone:

```bash
pre-commit install
pre-commit install --hook-type commit-msg
```

It validates the commit message format, blocks credentials and private keys, rejects oversized files, and checks YAML and JSON syntax.

**Pipeline — the layer that actually gates.** A local hook is bypassable with `git commit --no-verify`, so it is a convenience, not a control. The control is the pipeline, which re-runs secret scanning over the full history and fails the build on a finding. *The pipeline does not exist yet; it arrives with the delivery workflow.* Until then the local hooks are the only layer, and they are only as strong as the discipline not to bypass them.

**If a real secret is ever committed:** rotate the credential first, then clean the history — in that order, because rotation is the only step that actually removes the risk. Once pushed, a secret must be treated as compromised no matter what happens to the history afterwards: rewriting Git does not retract what has already been fetched, cached, mirrored or indexed.

---

## Tooling versions

Tool versions are **pinned**, and lifted deliberately on a schedule rather than continuously.

Hook revisions in `.pre-commit-config.yaml` are pinned to released tags — never to a branch. Version bumps are an explicit, reviewable change (`pre-commit autoupdate`), not something that happens silently between two commits.

* **What this gains.** The environment is reproducible: a checkout from three months ago behaves the way it behaved three months ago. Upgrades arrive as a diff that can be read, tested and reverted, and a failure is attributable to a change that was made rather than to the passage of time.
* **What this costs.** Maintenance. Pinned versions age, security fixes are not picked up automatically, and keeping them current takes a deliberate act that is easy to postpone. The debt is real — but it is visible and dated, which is the point: an unpinned toolchain does not avoid that debt, it converts it into a build that breaks on a morning when nothing was changed.

---

## Architecture decision records

Decisions scoped to this repository are recorded in [`docs/adr/`](docs/adr/), numbered sequentially, following [MADR](https://adr.github.io/madr/). Decisions spanning several repositories are recorded in `koveo-journal` — see ADR-0001 for the repository layout this follows.

An ADR is required when a choice is expensive to reverse, when a credible alternative was rejected, or when the reasoning will be invisible in six months. It states the context, the options considered, the decision, and **at least one accepted downside**. An ADR without a downside is advertising, not a record.

ADRs are never deleted. A superseded ADR is marked as superseded and links to the one that replaced it.

---

## Definition of done

A change is complete when:

- [ ] It does what it claims, verified rather than assumed
- [ ] Automated checks pass
- [ ] Documentation reflects the state of the repository at this commit — no future tense, nothing that does not exist
- [ ] Any structural decision it embodies is recorded as an ADR
- [ ] No credential, personal address or local configuration file entered the history
- [ ] Cloud resources created for the change are destroyed, or explicitly labelled as persistent
