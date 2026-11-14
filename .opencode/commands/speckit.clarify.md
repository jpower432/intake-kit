---
description: Identify underspecified areas in the current feature spec by asking up to 5 highly targeted clarification questions and encoding answers back into the spec.
---

Scan the current feature spec for ambiguities and resolve them
through targeted questions.

## Initialization

Run `.specify/scripts/bash/check-prerequisites.sh --json` from
the repo root and parse the JSON output. Extract `FEATURE_DIR`
from the result. If the script fails or `FEATURE_DIR` is not
set, **STOP** with an error.

## Outline

**STOP HERE. Do NOT proceed to implementation.**

Your job is done. Report the results and prompt the
user. The user will invoke a separate command
(`/speckit.implement`, `/unleash`, or `/cobalt-crush`)
when they are ready to implement.

## Workflow

1. **Read the spec**

   Read `FEATURE_DIR/spec.md` in full.

2. **Scan for ambiguities**

   Analyze the spec across 10 taxonomy categories:

   1. **Functional scope** -- missing features, unclear
      boundaries
   2. **Data model** -- undefined entities, relationships,
      cardinality
   3. **UX flow** -- unclear user journeys, missing states
   4. **Non-functional** -- missing performance, security,
      scalability requirements
   5. **Integration** -- undefined external dependencies, APIs,
      data flows
   6. **Edge cases** -- unhandled error states, boundary
      conditions
   7. **Constraints** -- unstated technical, business, or
      regulatory constraints
   8. **Terminology** -- undefined or inconsistently used terms
   9. **Completion signals** -- unclear definition of done,
      acceptance criteria
   10. **Placeholders** -- TODO markers, TBD sections, empty
       templates

3. **Ask questions (up to 5)**

   For each ambiguity found, formulate a targeted question.
   Prioritize by impact (CRITICAL/HIGH first). Ask questions
   **one at a time**, not in a batch.

   For each question:
   - State the ambiguity category
   - Quote the relevant spec text
   - Provide a recommended answer with reasoning
   - Ask the user to confirm, modify, or provide their own
     answer

   Stop after 5 questions or when no more HIGH+ ambiguities
   remain, whichever comes first.

4. **Integrate answers into spec**

   For each answered question:
   - Find the relevant section in `spec.md`
   - Integrate the answer directly into that section
   - Preserve existing content -- augment, don't replace

5. **Record Q&A**

   Append a `## Clarifications` section at the end of
   `spec.md` (if one doesn't already exist) documenting:

   ```markdown
   ## Clarifications

   ### C1: <question summary>
   **Category**: <taxonomy category>
   **Question**: <the question asked>
   **Answer**: <the user's answer>
   **Integrated into**: <section name>
   ```

6. **Report results**

   Show:
   - Number of ambiguities found (by category)
   - Number of questions asked and answered
   - Sections of spec.md that were updated
   - Remaining ambiguities (if any) for future runs

## Guardrails

- **NEVER modify source code** -- this command updates
  spec artifacts ONLY. Implementation changes belong in
  `/speckit.implement`, `/unleash`, or `/cobalt-crush`.
- **NEVER modify test files, Go source, Markdown agents,
  convention packs, or config files** outside the
  `specs/NNN-*/` feature directory.
- The ONLY files this command may write are:
  - `FEATURE_SPEC` (the spec.md file)
  - Files within `FEATURE_DIR` (spec artifacts:
    plan.md, tasks.md, research.md, data-model.md,
    quickstart.md, contracts/, checklists/)
- The user needs to review the plan before
  implementation begins. Implementing without review
  defeats the purpose of the spec-first workflow.
