---
name: discovery
description: Stage-0 discovery loop. A strategic researcher and a tactical tracker gatherer research the problem, a distiller turns their findings into open-questions. From a bare problem brief it also seeds a full parent PRD (framing + outcomes + open-questions, no FRs). Run before authoring FRs.
---

# Helper paths
# SKILL_DIR=$(dirname "$(realpath <path-to-this-SKILL.md>)")
# Agent files: "$(dirname "$SKILL_DIR")/../agents/discovery-*.md" resolved relative to module root
# Discovery protocol: "$SKILL_DIR/references/discovery-protocol.md"

# Discovery (Stage 0)

The lifecycle stage before Draft. Turns a problem domain into either a set
of `open-questions` (spikes) to merge into an existing PRD, or — from a
bare problem brief with no PRD yet — a complete **seeded parent PRD**
(framing, desired-outcomes, and open-questions; no FRs). It works by
researching the domain with a strategic RESEARCHER (blind to the proposed
solution) and a tactical GATHERER (the org's tracker, for prior art +
duplicates), then distilling their findings. A spike here is an open
question, never a build instrument.

Two output modes, selected by input (see Phase 2):

- **Distill** — a parent PRD already exists: emit `open-questions` to merge.
- **Seed** — only a plain-language brief exists: emit a full parent PRD
  the author can save, its synthesized desired-outcomes each paired with a
  confirm open-question. FRs and journeys remain author-owned.

## When to Use

- Before authoring functional requirements for a new initiative.
- User invokes `/discovery` with a problem brief or a parent PRD path.
- User asks to "explore the problem space" or "run discovery" on an idea.

Do not auto-invoke. This skill is triggered explicitly only.

## Input

Either a parent PRD YAML path (framing is read from it) or a
plain-language problem brief. Optionally phase draft paths for the
distiller's gap check and the gatherer's dedup. Optionally a dispatch mode:
`parallel` (default) or `serial`.

Example:
```
/discovery prds/my-feature.yaml
/discovery --serial "People save links to read later but lose track of what they've already read."
```

If no input is given, ask for the problem framing before proceeding.

**Mode is a cost/speed tradeoff, same as prd-review:**

- **`parallel`** (default) — the researcher and gatherer dispatch as
  independent subagents concurrently. Faster wall-clock, higher token cost.
- **`serial`** — the orchestrator adopts each agent persona in turn in
  this context. Lower token cost, slower. If the host cannot dispatch
  named agents at all, `serial` is forced. In this mode the researcher's
  blindness to FRs/journeys is enforced by instruction, not context
  isolation — the orchestrator must actually withhold them while wearing
  the researcher persona, per the "ignore FRs and note the withholding"
  rule in the discovery protocol.

## Process

### Phase 0: Extract or frame the problem

If a parent PRD path was given, extract the problem framing from it:
`title`, `description`, `job-executors`, `scope`. Note separately whether the
PRD carries proposed `functional-requirements` or `journeys` — the
researcher must NOT see them (Phase 1), but the gatherer and distiller do.
This is **Distill** mode.

If the input is a bare problem brief with no parent PRD path, there is no
framing to extract yet — the brief itself is the framing the researcher
receives, and the distiller will SYNTHESIZE the parent framing in Phase 2.
This is **Seed** mode.

### Phase 1: Dispatch the researcher and gatherer

| Agent | File | Sees FRs? | Explores |
|---|---|---|---|
| Researcher (strategic) | `module/agents/discovery-researcher.md` | No | Prior art, patterns, standards, this domain's problems/risks/debt |
| Gatherer (tactical) | `module/agents/discovery-gatherer.md` | Yes | The org's internal tracker: related tickets, prior decisions, duplicates |

Hand the researcher the framing from Phase 0 and
`$SKILL_DIR/references/discovery-protocol.md` — and nothing about the
proposed solution. Hand the gatherer the full PRD family (so it can dedup),
the protocol, and the tracker scope config (`discovery-tracker.yaml` if
present at the repo root, else `discovery-tracker.example.yaml`).

**`parallel` mode:** dispatch both as independent subagents. Neither sees
the other's output.

**`serial` mode:** adopt each agent persona in turn from its file, apply
its Phased Process, collect its JSON, then move to the next — keeping the
passes independent (do not let the researcher's findings leak into the
gatherer's prompt, and never leak FRs into the researcher's prompt).

Each agent returns a single fenced JSON block per the protocol. The
gatherer records a graceful gap and returns `[]` if no issue-tracker MCP
is mounted — discovery never blocks on a missing tracker.

### Phase 2: Distill or seed

Dispatch `discovery-distiller`
(`module/agents/discovery-distiller.md`) with both agents' JSON verbatim
and the mode from Phase 0:

- **Distill mode:** pass every PRD file path in the family. It returns a
  single fenced ```yaml block of `open-questions`, folding gatherer
  duplicates into annotations rather than new questions.
- **Seed mode:** pass the raw problem brief and state that no parent PRD
  exists. It returns a single fenced ```yaml block containing a complete
  seeded parent PRD (framing, desired-outcomes, scope, stakeholder
  placeholders, and open-questions — each synthesized desired-outcome
  paired with a confirm question), with no FRs, journeys, or phase.

### Phase 3: Present & seed

**Distill mode.** Present the distilled `open-questions` to the author
verbatim, grouped under the finding(s) that raised each (surface any
`tracker_ref` so the author can dedup against existing work). The author
may accept, edit, or drop any question. Never write to a PRD file the
author hasn't approved. On approval, merge the accepted questions into the
target PRD's `open-questions:` list (create the list if absent). This
seeds the PRD that the Draft-stage floor then works from.

**Seed mode.** Present the whole seeded parent PRD to the author, calling
out that its `job-executors`, `desired-outcomes`, and `scope` are
synthesized DRAFTS — every desired-outcome carries a confirm question, and
the `stakeholders` handles are placeholders to fill. The author may accept,
edit, or drop any part. Never write a PRD file the author hasn't approved.
On approval, write the accepted PRD to a new parent PRD file at a path the
author names (default `prds/<slug>.yaml`), then run `cue vet <path> prd.cue
-d '#PRDDocument'` to confirm it validates before handing back. The author
answers the confirm questions and authors FRs from there — discovery never
writes FRs.

## Rules

- Never hand `functional-requirements` or `journeys` to the researcher —
  independence is the whole point of the strategic lens.
- The gatherer DOES see the full PRD family — dedup requires it.
- Never let the two agents see each other's output.
- The gatherer reaches the tracker via the host-mounted issue-tracker MCP
  only — no hard-coded vendor.
- Discovery agents surface questions/problems/tickets, and in Seed mode
  synthesize DRAFT parent framing (job-executors, desired-outcomes, scope);
  only the author authors `functional-requirements` and `journeys`.
- Seed mode synthesizes framing but never invents stakeholder handles —
  those stay placeholders for the author to fill.
- Degrade gracefully: if a host tool an agent wanted (web, tracker MCP) is
  unavailable, it records the gap and returns what it can — discovery
  never blocks on a missing tool.
- A discovery run that yields zero open questions is a valid outcome, not
  a failure.
