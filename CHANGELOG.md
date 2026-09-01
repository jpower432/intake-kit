# Changelog

## Unreleased

### Breaking schema changes (`prd.cue`)

Shipped in #8 (already on `main`); documented here for the first time —
this entry backfills migration guidance that was missing at merge time,
it does not describe a pending change.

The PRD schema was renamed for readability and stage-aware review. Existing
PRD YAML files written against the previous schema will fail `cue vet`
until migrated. Field names are now kebab-case throughout (was
snake_case).

| Old field | New field | Notes |
|---|---|---|
| `personas?: [...string]` (parent, required) | removed | replaced by `job-executors` + `desired-outcomes` |
| `kpis?: [...#KPI]` | `desired-outcomes?: [...#DesiredOutcome]` | parent-level; `#KPI{metric,target,baseline}` → `#DesiredOutcome{id,statement,executor-id}` |
| `workflow?: #Workflow` (single, phase-level) | `journeys?: [...#Journey]` (list) | a phase now declares one or more journeys, each with its own `executor` |
| `#FunctionalRequirement.persona` | `#FunctionalRequirement.satisfies` (list of outcome IDs) | requirements now trace to `desired-outcomes`, not a free-text persona string |
| `functional_requirements` | `functional-requirements` | snake_case → kebab-case |
| `nonfunctional_requirements` | `nonfunctional-requirements` | snake_case → kebab-case |
| `open_questions` | `open-questions` | snake_case → kebab-case |
| `scope.in_scope` / `scope.out_of_scope` | `scope."in-scope"` / `scope."out-of-scope"` | snake_case → kebab-case |
| `state.status: "Review"` | `state.status: "Ready"` | enum value rename |
| `acceptance_criteria` | `acceptance-criteria` | snake_case → kebab-case |

Also new: `job-executors` (parent) — the actor whose job-to-be-done a
PRD serves — and the acceptance-criteria maturity gate (`acceptance-criteria`
and `satisfies` become required on functional requirements once a phase
reaches `Ready` or `Approved`; optional at `Draft`).

**Migrating an existing PRD by hand:**
1. Rename all snake_case fields listed above to kebab-case.
2. Replace `personas` with `job-executors` (one entry per persona,
   `{id, label, core-job}`) and add `desired-outcomes` capturing what
   each executor needs (`{id, statement, executor-id}`).
3. Replace `kpis` entries with `desired-outcomes` entries.
4. Replace the phase's single `workflow: {label, steps}` with a
   `journeys: [{label, executor, steps}]` list — each journey names the
   `job-executors` id it serves.
5. On each functional requirement, drop `persona` and add `satisfies:
   [...]` naming the `desired-outcomes` ids it satisfies.
6. Rename any `state.status: Review` to `state.status: Ready`.
7. Run `cue vet prd.cue -d '#PRDDocument' your-prd.yaml` and fix
   remaining errors — the CUE error output names the exact field.

### Added
- Two-tier stage-aware review: `/prd-review` (default) runs `cue vet` +
  Guard only against a `Draft` PRD; `/prd-review --full` runs the full
  five-agent council and gates `Draft → Ready`.
- CUE-native FR/journey coverage floor (`ORPHAN_FR`, `UNKNOWN_FR`) and an
  acceptance-criteria maturity gate, enforced directly by `prd.cue`.
- `lola-eval` behavioral harness (`.lola-eval/`, `.taskfiles/lola-eval.yml`)
  for regression-testing the review skill against starter PRDs.
- `NOTICE` file for third-party attribution (lola-eval harness scaffolding,
  Apache-2.0).

### Changed
- `/prd-review` default behavior: previously always ran the full 5-agent
  council; now runs `cue vet` + Guard only unless `--full` is passed. Pass
  `--full` to get the prior behavior and the `Draft → Ready` gate.
