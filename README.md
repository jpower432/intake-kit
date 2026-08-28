# Intake Kit

A structured product requirements intake toolkit: CUE-validated PRD authoring paired with a multi-agent AI review
council that gates a PRD from Draft to Ready.

Installs as a [Lola](https://github.com/LobsterTrap/lola) module and works with Claude Code, Cursor, Gemini CLI, and
OpenCode.

## What's in the box

- **CUE schema** (`prd.cue`) — validates PRD YAML: stakeholders, functional requirements, journeys, acceptance
  criteria, and lifecycle state.
- **prd-review skill** (`module/skills/prd-review/`) — checks schema conformance, then dispatches review agents against
  a PRD family and emits a BLOCKED / NEEDS REVISION / APPROVED verdict. A default Guard-only pass gates nothing;
  `--full` runs the 5-agent council and is the only pass that gates `Draft → Ready`.
- **discovery skill** (`module/skills/discovery/`) — Stage-0 problem exploration before FRs exist: a researcher and a
  tracker gatherer surface findings, then a distiller either produces `open-questions` for an existing PRD or seeds a
  parent PRD (framing, desired-outcomes, open-questions; no FRs) from a bare brief.
- **Example PRDs** (`examples/`) — parent and phase templates to copy and fill in.

## Install

```bash
lola install github.com/unbound-force/intake-kit
```

## Usage

Validate a PRD against the schema (requires [CUE](https://cuelang.org/docs/introduction/installation/)):

```bash
cue vet prd.cue -d '#PRDDocument' your-prd.yaml
```

Run the review council (in any AI assistant that supports Lola skills):

```
/prd-review prds/my-feature.yaml prds/my-feature-phase1.yaml          # Guard-only, gates nothing
/prd-review --full prds/my-feature.yaml prds/my-feature-phase1.yaml   # full council, gates Draft → Ready
```

Run discovery:

```
/discovery prds/my-feature.yaml                                              # distill open-questions into a PRD
/discovery "People save links to read later but lose track of what they've read."   # seed a parent PRD from a brief
```

## PRD document model

PRDs are structured YAML. A **parent PRD** defines the initiative (title, description, job executors, NFRs, scope) and
carries `desired-outcomes` — solution-agnostic, measurable needs. **Phase PRDs** reference the parent and carry
delivery fields (FRs, journeys, state; ACs required only at Ready). An FR `satisfies` a desired outcome (required at
Ready); an NFR may optionally.

```
parent-prd.yaml          # what + why
├── phase1-prd.yaml      # phase 1 FRs, journeys, state
└── phase2-prd.yaml      # phase 2 FRs, journeys, state
```

`cue vet` validates each file independently (structure + in-file FR/journey coverage). Cross-document checks — a
journey executor missing from the parent, a `satisfies` reference naming no real outcome, and similar — need reasoning
across files and are owned by the review council's Guard agent, not the schema.

See `examples/` for the full field set.

## Project layout

```
module/                  ← installable Lola module
  agents/                ← review + discovery agent definitions
  skills/prd-review/     ← schema check + agent dispatch + verdict
  skills/discovery/      ← Stage-0 research + distillation
  commands/              ← command entry points
prd.cue                  ← CUE schema (published to registry)
cue.mod/                 ← CUE module definition
examples/                ← example PRD YAML files
```

The review council roster, dispatch modes, verdict phases, and cross-document check taxonomy live in
`module/skills/prd-review/SKILL.md` and `module/skills/discovery/SKILL.md`. See [AGENTS.md](AGENTS.md) for the
developer guide.

## License

Apache-2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE).

The lola-eval harness scaffolding under `.taskfiles/` is adapted from the
[Review Council](https://github.com/lolables/lola-mod-review-council) project (Apache-2.0); see [NOTICE](NOTICE) for
attribution.
