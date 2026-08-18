---
name: prd-review
description: Multi-lens AI review council for PRDs. Run before advancing a PRD from Draft to Review state.
---

# Helper paths
# SKILL_DIR=$(dirname "$(realpath <path-to-this-SKILL.md>)")
# Agent files: "$(dirname "$SKILL_DIR")/../agents/prd-*.md" resolved relative to module root
# Reviewer protocol: "$SKILL_DIR/references/reviewer-protocol.md"

# PRD Review Council

Multi-lens AI review council for structured PRDs. Checks CUE schema
conformance, then dispatches 5 specialist review agents against a PRD
family (parent + phase files). Produces a consolidated finding report and
a verdict that gates state advancement.

## When to Use

- PRD is transitioning from `Draft` → `Review` state
- User invokes `/prd-review` with PRD file paths
- User asks for "PRD review" or "run the review council on this PRD"

Do not auto-invoke. This skill is triggered explicitly only.

## Input

Provide the parent PRD YAML path and all phase YAML paths for the initiative.
Optionally specify a review mode: `parallel` (default) or `serial`.
Optionally specify `--schema <path>` — a local CUE file to fall back to
for Phase 0 if the published registry schema can't be resolved.

Example:
```
/prd-review prds/my-feature.yaml prds/my-feature-phase1.yaml
/prd-review --serial prds/my-feature.yaml prds/my-feature-phase1.yaml
```

`--schema <path>` is optional — only needed if the registry is
unreachable and you want a local fallback:
```
/prd-review --schema prd.cue prds/my-feature.yaml prds/my-feature-phase1.yaml
```

If no paths are given, ask for them before proceeding.

**Review mode is a cost/speed tradeoff, not a capability fallback:**

- **`parallel`** (default) — all 5 agents dispatch as independent
  subagents, each ingesting its own copy of the full PRD family plus
  `reviewer-protocol.md`. For a PRD family of N tokens this costs roughly
  5N tokens of ingestion (plus five ~1K-token persona files), against
  ~1N for a single-context read. Faster wall-clock, higher token cost —
  the cost grows with PRD family size, not just with a fixed checklist.
- **`serial`** — the orchestrator adopts each of the 5 personas in this
  same context, one at a time, reusing the PRD text already read in
  Phase 1 (see below) instead of re-ingesting it per agent. Cost stays
  near ~1N regardless of how many agents run. Slower wall-clock (5
  sequential passes instead of 5 concurrent ones), lower token cost.
- If the user does not specify a mode and the host cannot do named-agent
  dispatch at all, `serial` is the only option regardless of request —
  this is a hard capability fallback, separate from the cost/speed choice
  above.

## Process

### Phase 0: Schema Conformance

Before any content review, check structural conformance against the
project's CUE schema — this catches type errors, malformed IDs, invalid
enum values, and disallowed fields that no `prd-*` agent is designed to
catch (they read for behavior and quality, not structural validity).

1. If the `cue` binary is unavailable on this host, skip this phase
   entirely and note in the final report:
   `Schema conformance check skipped: cue binary not found.` Do not block
   on a missing tool — this is a capability-dependent enhancement, not a
   hard requirement (tool-agnosticism graceful degradation, per
   `module/AGENTS.md`).
2. Otherwise, resolve the schema, registry first:
   - **Registry** (primary): the schema is published to the CUE Central
     Registry from this module's `cue.mod/module.cue`
     (`github.com/unbound-force/intake-kit@v0`, definition
     `#PRDDocument` in the `prds` package at the module root). The
     caller needs no local CUE module of their own — vet directly
     against the registry import like the following command:
     ```
     cue vet <prd-file> github.com/unbound-force/intake-kit@<version>:prds -d '#PRDDocument'
     ```
     If the module isn't published yet, the registry is unreachable,
     this attempt fails — that is expected and not an error; fall
     through to the next option.
   - **`--schema <path>`** (fallback): if given, vet against that local
     file's `#PRDDocument` definition instead.
   - **Neither resolves**: skip this phase and note in the final report:
     `Schema conformance check skipped: registry unreachable/unpublished
     and no --schema path given.` Never block on this — degrade
     gracefully, same as the missing-binary case above.
3. For every provided PRD file, against whichever schema source resolved:
   ```
   cue vet <prd-file> <schema-file-or-registry-import> -d '#PRDDocument'
   ```
4. If every file passes (exit 0), proceed to Phase 1.
5. If any file fails, stop — do not dispatch the 5 agents. Emit the same
   report format as Phase 4 below, with `Verdict: BLOCKED`,
   `Schema conformance: BLOCKED`, a single BLOCKERs entry containing the
   raw `cue vet` error output verbatim (it already names the exact field,
   constraint, and file/line), and empty WARNINGs/INFO sections — the 5
   agents never ran. A structurally invalid PRD isn't reviewable for
   behavioral quality until the schema violation itself is fixed.

### Phase 1: Preparation

Read all provided PRD files and hold the raw file text verbatim in
context for each one — not just extracted fields. Phase 3 needs to
byte-match `evidence` quotes against this raw text later; extracting only
a field summary here would force a second full read in Phase 3.

Also extract, for convenience during Dispatch and Synthesis:

- **Parent**: `title`, `slug`, `description`, `personas`, `nonfunctional_requirements`, `kpis`, `features`, `stakeholders`, `open_questions` (each with its own `context`, if present)
- **Each phase**: `phase`, `state`, `workflow`, `functional_requirements` (with ACs), `dependencies`, and `features` if this phase file declares its own (see the Feature Traceability note in Phase 2's Guard row — `features` isn't parent-exclusive)

Note the PRD `state.status`. If already `Approved` or `Superseded`, warn the user and ask whether to continue.

### Phase 2: Dispatch

Hand each agent the PRD context, file paths, and
`$SKILL_DIR/references/reviewer-protocol.md`:

| Agent | File | Reviews |
|---|---|---|
| Guard | `module/agents/prd-guard.md` | Intent fidelity, scope discipline, persona/ID/workflow integrity, FR-to-value traceability |
| Adversary | `module/agents/prd-adversary.md` | Security gaps + ambiguity/completeness |
| Tester | `module/agents/prd-tester.md` | Behavioral language, testability, AC quality |
| Operator | `module/agents/prd-operator.md` | Deployment/environment/connectivity assumptions |
| Curator | `module/agents/prd-curator.md` | Evidence capture, audit trail, retention, provenance, open-question hygiene |

`features` is not parent-exclusive — a phase file may declare its own
`features` list too. Guard's Feature Traceability Grounding runs against
every `features` entry across the whole PRD family, not just the
parent's.

**`parallel` mode** (default, host-capable): dispatch all 5 as independent
subagents concurrently. Each receives the PRD file paths and
`reviewer-protocol.md` and reads the PRD family itself — it does not
inherit the orchestrator's Phase 1 context.

**`serial` mode** (requested, or forced by host capability): stay in this
context. For each of the 5 agents in turn, adopt its persona from its
full file, apply its Phased Process against the PRD text already held
from Phase 1 — do not re-read the PRD files — collect its JSON output,
then move to the next persona. This is what makes `serial` cheaper: the
PRD ingestion cost is paid once in Phase 1, not once per persona.

Each agent returns its own fenced JSON block per
`reviewer-protocol.md` — no prose, no summaries, no praise.

### Phase 3: Verify

For every finding across all 5 agents' JSON output, confirm `evidence` is
a literal substring of the PRD file `location` is scoped to (the parent
or phase file containing the cited ID or section), checked against the
raw text held from Phase 1. Drop any finding whose `evidence` cannot be
found verbatim in that file. Report the count of dropped findings in the
final report as `<n> findings dropped — evidence not found in cited file`.

This is an LLM re-check pass over the raw PRD text already held from
Phase 1 — no re-reading files, no scripts, no schema-as-code, keeping the
module script-free per `AGENTS.md`.

### Phase 4: Synthesis & Verdict

Collect the findings that survived Verify. Group by severity:

- **BLOCKER** — must be resolved before PRD advances to Review
- **WARNING** — author must respond with rationale to skip, or resolve
- **INFO** — advisory, no response required

Determine verdict:

| Verdict | Condition |
|---|---|
| `APPROVED` | No BLOCKERs, no WARNINGs |
| `NEEDS REVISION` | No BLOCKERs, ≥1 WARNING |
| `BLOCKED` | ≥1 BLOCKER |

Emit the report in this format:

```
# PRD Review — <PRD title>

Verdict: BLOCKED | NEEDS REVISION | APPROVED
Reviewed: <parent slug> + <phase slugs>
Schema conformance: PASSED | SKIPPED (<reason>) | BLOCKED
<n> findings dropped — evidence not found in cited file

## BLOCKERs (<n>)
<findings>

## WARNINGs (<n>)
<findings>

## INFO (<n>)
<findings>

## Next Steps
<one sentence per verdict type — what the author must do>
```

If `APPROVED`: state the PRD may advance to `Review` state.
If `NEEDS REVISION`: list each WARNING and state the author must resolve or respond before merge.
If `BLOCKED`: list each BLOCKER and state nothing advances until they are resolved.

## Rules

- Never edit PRD files.
- Report findings only — do not propose rewrites unless the user explicitly asks after the report.
- If a PRD file cannot be read, report `BLOCKED` with reason.
- If Phase 0 finds a schema violation, report `BLOCKED` with the raw `cue vet` output and stop — do not dispatch the 5 agents against a structurally invalid file.
- If Phase 0 is skipped (no schema found, or `cue` unavailable), say so plainly in the report — never imply schema conformance was checked when it wasn't.
- Walk one finding at a time if user asks for interactive mode — otherwise emit the full report.
- Findings from different agents may overlap in location. Do not deduplicate across agents — each agent owns its own scope.
- Findings whose evidence fails the Verify phase are dropped silently from the report body but counted in the drop-count line — never listed as findings.
