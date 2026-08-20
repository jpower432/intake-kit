# Intake Kit

A structured product requirements intake toolkit. CUE-validated PRD authoring paired with a multi-agent AI review
council that gates PRD advancement from Draft to Review.

Installs as a [Lola](https://github.com/LobsterTrap/lola) module and works with Claude Code, Cursor, Gemini CLI, and
OpenCode.

## What's in the box

- **CUE schema** (`prd.cue`) — validates PRD YAML documents. Enforces structure for stakeholders, functional
  requirements, acceptance criteria, workflows, and lifecycle state.
- **prd-review skill** (`module/skills/prd-review/`) — a Lola skill that checks CUE schema conformance, then dispatches
  5 specialist review agents (`module/agents/prd-*.md`) against a PRD family and emits a BLOCKED / NEEDS REVISION /
  APPROVED verdict.
- **Example PRDs** (`examples/`) — parent and phase templates ready to copy and fill in.

## Install

```bash
lola install github.com/unbound-force/intake-kit
```

## PRD Document Model

PRDs are structured YAML. A **parent PRD** defines the initiative (title, description, personas, NFRs, scope). **Phase
PRDs** reference the parent and carry delivery-specific fields (FRs with ACs, workflows, state).

```
parent-prd.yaml          # what + why
├── phase1-prd.yaml      # phase 1 FRs, workflow, state
└── phase2-prd.yaml      # phase 2 FRs, workflow, state
```

See `examples/` for the full field set.

## Validating PRDs

Requires [CUE](https://cuelang.org/docs/introduction/installation/).

```bash
cue vet prd.cue -d '#PRDDocument' your-prd.yaml
```

## Running the Review Council

The `prd-review` skill runs in any AI coding assistant that supports Lola skills.

```
/prd-review prds/my-feature.yaml prds/my-feature-phase1.yaml
```

**Phase 0 is schema conformance.** Before any content review, the PRD family is checked against the CUE schema
(`#PRDDocument`), resolved from the CUE Central Registry first, falling back to a local file if you pass
`--schema <path>`. A structural violation (bad ID format, invalid enum, disallowed field) blocks immediately with the
raw `cue vet` error — no point reviewing behavior in a file that doesn't even parse against the schema.

**Phases 2 – 4 dispatch 5 specialist agents** to review content and quality, by default in parallel (pass `--serial` to run them
sequentially in one context instead — slower, but roughly 1/5th the token cost, since the PRD text is read once
instead of once per agent):

| Agent | Reviews |
|---|---|
| Guard | Intent fidelity, scope discipline, persona/ID/workflow integrity, FR-to-value traceability |
| Adversary | Security gaps (auth boundaries, trust, credential scope) + ambiguity/completeness |
| Tester | Behavioral language, testability, AC quality |
| Operator | Implicit deployment/environment/connectivity assumptions |
| Curator | Evidence capture, audit trail, retention, provenance, open-question hygiene |

Each agent returns a JSON verdict; a Verify phase confirms every finding's evidence is a literal quote from the PRD
before it's allowed into the report. The council then produces a consolidated finding report with severity levels
(BLOCKER, WARNING, INFO) and a verdict that gates PRD state advancement from Draft to Review.

See `module/agents/prd-*.md` for each agent's full review criteria, and `module/skills/prd-review/SKILL.md` for the
full phase-by-phase process.

## Project Layout

```
module/                  ← installable Lola module
  agents/                ← standalone review agent definitions (prd-guard, prd-adversary, ...)
  skills/prd-review/     ← orchestration skill (schema check + agent dispatch + verdict)
  commands/              ← command entry points
prd.cue                  ← CUE schema (published to registry)
cue.mod/                 ← CUE module definition
examples/                ← example PRD YAML files
```

See [AGENTS.md](AGENTS.md) for the full developer guide.

## License

Apache-2.0 — see [LICENSE](LICENSE).
