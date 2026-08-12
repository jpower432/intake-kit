# Intake Kit

Skills in this module support structured product requirements intake.

## Skills

- **prd-review** — Multi-agent review council for PRDs. Invoked via `/prd-review` before advancing a PRD from Draft to Review. Checks CUE schema conformance, then runs 5 specialist review agents (Guard, Adversary, Tester, Operator, Curator) — in parallel by default, or `--serial` for lower token cost — and emits a BLOCKED / NEEDS REVISION / APPROVED verdict.

## Review Agents

Agent definitions live at `module/agents/prd-*.md`. Each is a standalone
dispatchable reviewer with its own phased process and JSON verdict — see
`module/skills/prd-review/references/reviewer-protocol.md` for the shared
schema.

## PRD Structure

PRDs are structured YAML validated against a CUE schema. The document model uses parent-child relationships:

- **Parent PRDs** define the initiative: title, description, personas, NFRs, KPIs, stakeholders, scope.
- **Phase PRDs** define delivery phases: FRs with ACs, workflows, dependencies, state tracking.

## Key Constraints

- PRDs do not name unmade implementation choices in Draft state — but naming an external compatibility constraint the business has already committed to (a required data model, wire format, or certification) is expected, not a defect.
- Requirements describe behavior, not implementation.
- Each agent owns its own scope — findings from different agents may overlap in location but are not deduplicated.
- PRD content is only reviewed for behavior and quality after it passes CUE schema conformance (`schema/prd.cue`, `#PRDDocument`) — structural violations block before the 5 review agents run.
