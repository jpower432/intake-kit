---
rubric_version: "1"
pass_threshold: 0.6
weights:
  produces_parent_prd: 0.30
  schema_shape: 0.30
  framing_quality: 0.20
  outcome_quality: 0.10
  question_quality: 0.10
---

# Rubric: case-002-discovery-seeds-prd

The agent was given a bare problem brief (`problem.md`) and **no PRD**,
and asked to use the intake-kit discovery skill to seed a complete
**parent PRD** from nothing — the "full parent PRD, no FRs" contract:

- Required top-level keys: `header`, `slug`, `title`, `description`,
  `job-executors`, `desired-outcomes`, `scope`, `stakeholders`,
  `open-questions`.
- `header` carries `schema-version`, `version`, `last-updated`.
- Each `job-executor` has `id` (kebab-case), `label`, `core-job`.
- Each `desired-outcome` has `id` (`DO-[A-Z]+-\d{3}`), `statement`, and an
  `executor-id` that resolves to a declared job-executor.
- `scope` has `in-scope` and `out-of-scope` lists.
- **No** phases, `functional-requirements`, or `journeys` — parent framing
  only.

The known gap this baseline measures: the current discovery skill emits
only `open-questions`, not a full parent PRD. A low score here is the
expected baseline finding, not a rubric error.

Score each component in [0.0, 1.0].

## produces_parent_prd (weight 0.30)

Did the agent actually output a parent PRD as YAML (not merely a list of
open-questions, prose, or a refusal)?

- 1.0 — a single coherent parent-PRD YAML document is produced.
- 0.5 — a partial PRD or PRD-shaped fragment (e.g. only some sections, or
  framing described in prose but not assembled into a YAML document).
- 0.0 — no PRD produced (only open-questions, only prose, or a refusal).

## schema_shape (weight 0.30)

Does the produced YAML have the required top-level keys and correctly
shaped sub-fields listed above, and does it correctly OMIT phases /
functional-requirements / journeys?

- 1.0 — all required keys present and well-formed; ids match their
  patterns; every `executor-id` resolves; no FRs/phases/journeys.
- 0.5 — most keys present but with gaps (a missing section, a malformed id,
  an unresolved `executor-id`) OR it leaks FR/phase/journey content.
- 0.0 — not recognizably a parent PRD shape.

## framing_quality (weight 0.20)

Is the framing faithful to the brief and well-formed as jobs-to-be-done?
`job-executors` name real actors from the brief (e.g. the person saving
and reading links), `core-job` is expressed as a job (not a feature or
solution), `title` and `description` reflect the save-and-rediscover
read-later problem.

- 1.0 — executors and core-jobs are accurate, JTBD-shaped, solution-agnostic.
- 0.5 — plausible but partly solution-anchored, vague, or missing an actor.
- 0.0 — framing is wrong, fabricated, or a restatement of a solution.

## outcome_quality (weight 0.10)

Are `desired-outcomes` measurable and solution-agnostic (an outcome for the
executor, not a feature to build), each tied to a real executor?

- 1.0 — outcomes are measurable, solution-agnostic, correctly attributed.
- 0.5 — outcomes present but soft, unmeasurable, or feature-shaped.
- 0.0 — no usable outcomes, or outcomes are disguised requirements.

## question_quality (weight 0.10)

Are the distilled `open-questions` sharp, non-duplicative, and genuine
unknowns (not solution-anchored build instructions)?

- 1.0 — questions are crisp, deduplicated, genuine unknowns.
- 0.5 — some questions are vague, redundant, or lightly solution-anchored.
- 0.0 — no questions, or they are build instructions in disguise.

## output

Return strict JSON:

```
{
  "components": {
    "produces_parent_prd": "<float>",
    "schema_shape": "<float>",
    "framing_quality": "<float>",
    "outcome_quality": "<float>",
    "question_quality": "<float>"
  },
  "explanation": "<one-paragraph rationale>"
}
```
