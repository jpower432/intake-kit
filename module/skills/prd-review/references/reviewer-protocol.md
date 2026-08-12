# Reviewer Protocol

Shared rules for every `prd-*` review agent (`module/agents/prd-guard.md`,
`prd-adversary.md`, `prd-tester.md`, `prd-operator.md`, `prd-curator.md`).
Each agent's Source Documents section references this file instead of
restating these rules.

## Tool Access

Read-only PRD files. No edits. No shell or network access — except Guard,
which alone may run `gh issue view <ref>` (read-only, no writes) for
Feature Traceability Grounding. No other exceptions for any agent.

## Domain Ownership

Each finding belongs to exactly one agent. If a topic below isn't your
row, don't flag it — the owning agent will.

| Domain | Owner |
|---|---|
| Persona/ID/workflow consistency, feature traceability, scope/value coherence | Guard |
| Auth boundaries, credential scope, trust model, ambiguity hiding a security decision | Adversary |
| Behavioral language, testability, AC quality, technology-naming-as-implementation-choice | Tester |
| Deployment, environment, and connectivity assumptions | Operator |
| Evidence capture, audit trail, retention, provenance, open-question/dependency hygiene | Curator |

This table is the single source of truth for cross-agent boundaries. Each
agent's own Out of Scope section states only the boundary cases specific
to that agent's lens — for the full ownership map, see this table.

## Phased Process Skeleton

Every agent's own Phased Process states only its Read & Map step (what to
build a map of — specific to that agent's lens). Steps 2 and 3 are the
same for all 5 agents and aren't restated per agent:

- **Step 2 — Evaluate** — apply the Review Criteria against the map built
  in Read & Map.
- **Step 3 — Self-Check** — re-scan draft findings against the Red Flags
  list. Drop or fix any finding that matches one.

## Evidence Discipline

- Read every provided PRD file in full before drafting any finding.
- Ground every cited identifier — FR ID, NFR ID, AC ID, persona string,
  workflow step — in text you have actually read in the cited file.
- Never assert a field is absent without having read the whole section of
  the file where it would appear.
- Never fabricate a quote. `evidence` is a byte-for-byte substring of the
  file `location` is scoped to — no ellipses, no paraphrase, no stitching
  two passages together.

## Severity Self-Check

Before finalizing your findings, ask of every BLOCKER and WARNING: "would
this actually block before a senior PM approves this PRD?" If the answer
is no, downgrade or drop it. Never inflate severity to look thorough.
Never invent a finding to justify the review having run. A clean review
that returns no findings is a correct outcome, not a failure to find
something.

## External Standard Verification

Some findings depend on a source outside the PRD files themselves — an
external ticket, issue, or standard. Treat that citation as a claim to
verify, not a fact to assume:

- If the external source is reachable and contradicts or fails to support
  the PRD's claim, raise the finding with both the PRD text and the
  external text as evidence.
- If the external source is unreachable, unauthenticated, or the fetch
  fails for any reason, do not block and do not fabricate alignment. Emit
  an INFO finding: "linkage to `<ref>` unverified, could not fetch issue."
- A failed fetch is never treated as proof of misalignment. Silence about
  an unreachable source is not acceptable either — always emit the INFO.

## Verdict Schema

Your entire response is a single fenced ```json block. Nothing else —
no prose before or after it.

```json
{
  "agent": "prd-guard",
  "sections_read": ["parent.personas", "phase1.functional_requirements"],
  "verdict": "APPROVE | REQUEST CHANGES",
  "findings": [
    {
      "severity": "BLOCKER|WARNING|INFO",
      "location": "FR-003-02",
      "title": "Short headline naming the defect",
      "evidence": "<verbatim quote from the cited PRD file>",
      "issue": "What is wrong, one sentence",
      "fix": "What to change, one sentence"
    }
  ]
}
```

- `evidence` MUST be a byte-for-byte quote from the file `location`
  implicitly scopes to (the PRD family file containing that ID) — no
  ellipses, no paraphrase, no stitching two passages together.
- A clean review returns `"verdict": "APPROVE", "findings": []` — never
  manufacture findings to justify review effort.
- `verdict` here is per-agent and informational only. The council-level
  verdict (BLOCKED / NEEDS REVISION / APPROVED) is computed separately by
  `SKILL.md` from the aggregated severities of all agents' surviving
  findings.

## Output

Entire response is the fenced json block above, with `"agent"` set to
your agent id (`prd-guard`, `prd-adversary`, `prd-tester`, `prd-operator`,
or `prd-curator`). No prose outside it.
