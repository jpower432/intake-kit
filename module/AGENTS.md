# Intake Kit

Skills in this module support structured product requirements intake.

## Skills

- **discovery** — Stage-0 problem exploration. Invoked via `/discovery` before authoring FRs. A strategic `discovery-researcher` and a tactical `discovery-gatherer` research the problem, then `discovery-distiller` synthesizes their findings. Given a parent PRD it distills deduplicated `open-questions` (spikes) to merge; given only a bare problem brief it seeds a full parent PRD — framing, desired-outcomes (each paired with a confirm question), scope, stakeholder placeholders, open-questions — with no FRs or journeys. Parallel by default, `--serial` for lower token cost.
- **prd-review** — Two-tier multi-agent review council. Invoked via `/prd-review`. Runs `cue vet` (schema conformance + FR/journey coverage floor), then dispatches for a `Draft` PRD by invocation: a fresh PRD gets a `cue vet` + Guard review; `--full` on a matured PRD runs all 5 agents (Guard, Adversary, Tester, Operator, Curator) and gates `Draft → Ready`, mutating `state.status` only after the author confirms. A `Ready` or later PRD triggers no gating dispatch; `Ready → Approved` is a manual human sign-off outside the toolkit. Parallel by default, `--serial` for lower token cost.

## Lifecycle

`discovery (Stage 0) → Draft → [full council] → Ready → Approved(human)`.
Discovery either seeds a full parent PRD from a bare brief or distills
`open-questions` into an existing one; the PRD clusters FRs under journeys
(ACs optional; structural coverage enforced by `cue vet`); the fresh
PRD gets a `cue vet` + Guard review; the author matures it
(outside the toolkit); then the full 5-agent council
(`/prd-review --full`) gates `Draft → Ready` — on pass it asks the author
and mutates `state.status` to `Ready` only on confirmation. `Ready →
Approved` is a MANUAL human sign-off entirely outside the toolkit: no
agent, skill, or command dispatches for it, gates it, or writes
`status: Approved`. `Superseded` retires a PRD.

## Review Agents

Agent definitions live at `module/agents/prd-*.md`. Each is a standalone
dispatchable reviewer with its own phased process and JSON verdict — see
`module/skills/prd-review/references/reviewer-protocol.md` for the shared
schema.

## Discovery Agents

Agent definitions live at `module/agents/discovery-*.md`. The strategic
`discovery-researcher` follows the shared contract in
`module/skills/discovery/references/discovery-protocol.md` and is not aware of
the proposed `functional-requirements`/`journeys` — that independence is
what keeps its research unbiased. The tactical `discovery-gatherer` follows
the same protocol but IS shown the full PRD family, because detecting
duplicates against the org's tracker requires it; it reaches the tracker
through whatever issue-tracker MCP the host mounts (no hard-coded vendor)
and reads `discovery-tracker.yaml` (or the committed `.example`) for scope.
The `discovery-distiller` consumes both and returns either `open-questions`
YAML (a parent PRD exists) or a complete seeded parent PRD (a bare brief
only) — framing and desired-outcomes synthesized, no FRs or journeys.

## PRD Structure

PRDs are structured YAML validated against a CUE schema. The document model uses parent-child relationships:

- **Parent PRDs** define the initiative: title, description, job executors, NFRs, desired outcomes, stakeholders, scope.
- **Phase PRDs** define delivery phases: FRs (ACs required only at Ready), journeys, dependencies, state tracking.

## Key Constraints

- PRDs do not name unmade implementation choices in Draft state — but naming an external compatibility constraint the business has already committed to (a required data model, wire format, or certification) is expected, not a defect.
- Requirements describe behavior, not implementation.
- Each agent owns its own scope — findings from different agents may overlap in location but are not deduplicated.
- PRD content is only reviewed for behavior and quality after it passes CUE schema conformance (`prd.cue`, `#PRDDocument`) — structural violations block before the 5 review agents run.
