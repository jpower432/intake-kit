---
description: Perform a non-destructive cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md after task generation.
---

Perform a cross-artifact consistency and quality analysis.

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

1. **Load artifacts**

   Read the following files from `FEATURE_DIR`:
   - `spec.md`
   - `plan.md`
   - `tasks.md`

   Also read `.specify/memory/constitution.md` if it exists.

   If any of the three core artifacts are missing, report which
   are absent and **STOP** -- analysis requires all three.

2. **Run 6 detection passes**

   Analyze the loaded artifacts across these dimensions:

   **Pass 1 -- Duplication**: Identify requirements, tasks, or
   plan items that express the same intent in different words.
   Flag near-duplicates with both locations.

   **Pass 2 -- Ambiguity**: Find vague language ("should
   support", "may need", "as appropriate", "etc."), undefined
   terms, and requirements that lack measurable acceptance
   criteria.

   **Pass 3 -- Underspecification**: Detect requirements
   referenced in plan or tasks that have no corresponding detail
   in spec.md, or tasks that lack sufficient context to
   implement without guessing.

   **Pass 4 -- Constitution alignment**: If constitution.md
   exists, check whether spec, plan, and tasks respect its
   constraints (tech stack, boundaries, conventions). Flag
   violations.

   **Pass 5 -- Coverage gaps**: Identify spec requirements that
   have no corresponding plan item or task. Identify plan items
   with no corresponding task.

   **Pass 6 -- Inconsistency**: Find contradictions between
   artifacts -- e.g., spec says "REST API" but plan says
   "GraphQL", or tasks reference components not mentioned in
   design.

3. **Assign severity**

   For each finding, assign a severity:
   - **CRITICAL** -- Blocks implementation (contradictions,
     missing core requirements)
   - **HIGH** -- Likely to cause rework (ambiguous requirements,
     coverage gaps)
   - **MEDIUM** -- Should be addressed before implementation
     (duplication, minor inconsistency)
   - **LOW** -- Informational (style, optional improvements)

4. **Produce report**

   Output a Markdown analysis report. Do NOT write any files.

   ```
   ## Cross-Artifact Analysis: <feature-name>

   **Artifacts analyzed**: spec.md, plan.md, tasks.md
   **Constitution**: loaded / not found

   ### Summary
   | Severity | Count |
   |----------|-------|
   | CRITICAL | N     |
   | HIGH     | N     |
   | MEDIUM   | N     |
   | LOW      | N     |

   ### Findings

   #### CRITICAL
   - [C1] <description> (spec.md:L42 vs tasks.md:L18)

   #### HIGH
   - [H1] <description> (plan.md:L7)

   ...
   ```

5. **Offer remediation** (optional)

   After presenting findings, ask whether the user wants
   suggested fixes for any CRITICAL or HIGH items. If yes,
   provide concrete text edits (but do NOT apply them -- this
   command is read-only).

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
