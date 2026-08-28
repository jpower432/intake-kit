---
rubric_version: "1"
pass_threshold: 0.6
weights:
  detection: 0.5
  evidence: 0.25
  false_positives: 0.15
  no_flapping: 0.10
---

# Rubric: case-001-unknown-executor

The agent was asked to run `/prd-review` on a two-file PRD family
(`parent.yaml` + `phase1.yaml`) that is schema-valid but contains one
seeded cross-file defect:

- The phase journey "Create a short link" names
  `executor: ghost-admin`, but the parent's `job-executors` list
  declares only `end-user`. This is the **UNKNOWN_EXECUTOR** condition —
  a journey referencing an executor id that no parent job-executor
  defines. It is a BLOCKER and is only catchable by the Guard agent's
  cross-file check, since each file passes `cue vet` in isolation.

Score each component in [0.0, 1.0].

## detection (weight 0.5)

Did the review identify the unknown executor `ghost-admin` (the journey
referencing an executor absent from the parent's job-executors list)?

- 1.0 — the review explicitly flags `ghost-admin` as an executor not
  declared in the parent (UNKNOWN_EXECUTOR or an equivalent description),
  at BLOCKER severity.
- 0.5 — the review notes an executor/journey problem but is vague about
  which executor is undefined or does not treat it as blocking.
- 0.0 — the defect is not reported.

## evidence (weight 0.25)

Does the finding cite the specific location — the phase file's journey and
the executor id `ghost-admin`, and ideally that the parent declares only
`end-user`?

- 1.0 — names `ghost-admin`, the journey it appears in, and contrasts it
  with the parent's declared executor(s).
- 0.5 — names the executor OR the journey but not both, or is approximate.
- 0.0 — no specific location cited.

## false_positives (weight 0.15)

Did the review avoid inventing findings that do not exist? The only real
defect is the unknown executor; the rest of the family is well-formed
(the FR is implemented by a journey step, satisfies a real desired
outcome, and the phase is Draft so acceptance criteria are optional).

- 1.0 — zero fabricated findings.
- 0.5 — one fabricated finding.
- 0.0 — two or more fabricated findings.

## no_flapping (weight 0.10)

Did the agent load its instruction files (SKILL.md, phase files, agent
definitions) cleanly?

- 1.0 — clean load, no searching or retrying.
- 0.5 — minor searching behavior.
- 0.0 — extensive searching, multiple retries, or errors.

## output

Return strict JSON:

```
{
  "components": {
    "detection": "<float>",
    "evidence": "<float>",
    "false_positives": "<float>",
    "no_flapping": "<float>"
  },
  "explanation": "<one-paragraph rationale>"
}
```
