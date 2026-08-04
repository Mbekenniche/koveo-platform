# koveo-platform

Infrastructure and delivery platform for **Koveo Fret**, a fictional regional logistics company based in Grenoble, France.

> **Disclaimer.** Koveo Fret is a fictional company created for a training project. Any resemblance to an existing organisation is coincidental. This platform is **not production**: it has no real users, no on-call rotation and no service commitment. Everything published here is measured on the hardware described below, and every figure is reproducible.

---

## Status

Bootstrapped on 3 August 2026. Repository conventions, tooling and decision records are in place. No infrastructure is deployed yet.

---

## Context

Koveo Fret runs last-mile parcel delivery across three sites — headquarters in Grenoble, a sorting warehouse in Saint-Égrève, a depot in Chambéry — with roughly 140 employees. Its information system grew by accretion over fifteen years: an Active Directory domain set up in 2012 by a contractor who has since left, VLANs added on an ad-hoc basis, an internally written parcel-tracking tool running on an unmaintained Apache server, and backups that have never been restored.

This repository holds the platform that replaces it: a segmented network, a hardened system baseline, a Kubernetes-based application platform on Google Cloud, and the delivery, security and observability pipelines around it.

---

## Architecture

Architecture diagrams live in [`docs/diagrams/`](docs/diagrams/) as versioned Mermaid sources.

*Not yet available — added in step 3 (addressing plan, security zones, flow matrix).*

---

## What is in this repository today

| Path | Contents |
|---|---|
| `docs/adr/` | Architecture decision records |
| `docs/diagrams/` | Versioned Mermaid diagrams |
| `bootstrap/` | Declared workstation toolchain and its rebuild procedure |
| `infra/` | Infrastructure as code (Terraform / OpenTofu) |
| `k8s/` | Kubernetes manifests and Helm charts |
| `ci/` | Pipeline definitions |
| `CONTRIBUTING.md` | Commit and branch conventions, enforced automatically |

---

## Design decisions

Every structural decision is recorded as an ADR. Each one states the context, the options considered, the decision, and at least one accepted downside.

* **[ADR-0001](docs/adr/0001-repository-organisation.md)** — Repository organisation: a monorepo for the platform, separate repositories for applications and AI work.

---

## Related repositories

| Repository | Contents |
|---|---|
| [`koveo-apps`](../../../koveo-apps) | Koveo Fret information system (Flask) and the parcel-tracking microservices |
| [`koveo-ai`](../../../koveo-ai) | Retrieval-augmented search, tool-using agent, evaluation harness, inference service |
| [`ml-from-scratch`](../../../ml-from-scratch) | Core machine learning algorithms implemented in pure NumPy |

---

## Running it

Nothing is deployable yet. Deployment instructions are added as each component lands.

The workstation toolchain, however, is already reproducible:

```
See bootstrap/README.md
```

---

## Environment

The platform is built and operated from two machines, deliberately of different architectures:

| Machine | Architecture | Role |
|---|---|---|
| Apple Silicon M1, 16 GB | `arm64` | Primary workstation, local Kubernetes, ARM-native network lab |
| Ryzen 7 5700X, 16 GB, RTX 4060 Ti | `amd64` | Windows Server and Active Directory lab, network emulation, GPU workloads |

Running both architectures is a constraint, not an accident: container images published from this repository are multi-architecture manifest lists, and the cost of emulated versus native cross-builds is measured rather than assumed.

---

## Known limitations and trade-offs

What is *intentionally* left out of scope, and why:

* **Not production.** No real users, no service-level commitment, no on-call. Load is simulated. Every reliability figure published here — recovery time, error budget, latency — comes from an exercise, and is labelled as such.

* **Self-managed data over PaaS.** No managed database service. PostgreSQL is deliberately self-hosted on virtual machines, to exercise database administration directly — roles and privileges, TLS, replication — rather than delegating it to a managed abstraction.

* **No service mesh.** Istio, Linkerd and equivalents are excluded. The scale of the microservice topology does not justify the operational complexity or the added latency. Choosing *not* to deploy one is itself the deliverable.

* **Cost-constrained by design.** The cloud footprint runs on a fixed, expiring credit allowance. Spot instances are used wherever interruption is tolerable; every resource carries a cost-attribution label; ephemeral resources are destroyed at the end of each session. Reliability is traded for cost, explicitly and on purpose.

* **Single region.** The cloud footprint is confined to `europe-west1`. Multi-region failover is out of scope for budget reasons, not architectural ones — cross-region egress and duplicated control planes are not affordable here.

* **Cloud footprint is temporary.** The Google Cloud environment is deliberately dismantled on 2 October 2026, when the credit allowance expires. Evidence — infrastructure state, dashboards, cost reports, identity federation configuration — is captured before teardown, and the platform continues on local infrastructure. Building something that survives the disappearance of its cloud provider is part of the exercise.

* **No on-premise IaaS.** Building and operating an OpenStack control plane was considered and dropped: the platform targets public-cloud primitives and lightweight local Kubernetes, and the effort was not justified by what it would have taught.

---

## License

See [LICENSE](LICENSE).