---
description: Generate a custom checklist for the current feature based on user requirements.
---

Generate a requirements quality checklist ("unit tests for
English") for the current feature.

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

1. **Read existing artifacts**

   Read `FEATURE_DIR/spec.md` and any other available artifacts
   (plan.md, tasks.md) for context.

2. **Ask clarifying questions**

   Before generating the checklist, ask up to 3 targeted
   questions to understand what quality dimensions the user
   cares most about. Examples:
   - "Which domain does this feature touch? (API, data model,
     UX, infrastructure, security)"
   - "Are there specific areas you're uncertain about?"
   - "Is there a particular quality dimension you want to
     focus on? (completeness, clarity, consistency,
     measurability, coverage)"

3. **Generate the checklist**

   Create a NEW checklist file at:
   `FEATURE_DIR/checklists/<domain>.md`

   where `<domain>` is derived from the user's answers
   (e.g., `api-design.md`, `data-model.md`, `security.md`).

   **Never overwrite** an existing checklist file. If the file
   exists, append a numeric suffix (e.g., `api-design-2.md`).

   Create the `checklists/` directory if it doesn't exist:
   ```bash
   mkdir -p FEATURE_DIR/checklists
   ```

4. **Checklist format**

   Each checklist item MUST:
   - Use question format: "Are [X] defined for [Y]?"
   - Include a quality dimension tag: `[Completeness]`,
     `[Clarity]`, `[Consistency]`, `[Measurability]`, or
     `[Coverage]`
   - Test REQUIREMENTS quality, NOT implementation behavior

   Example:
   ```markdown
   ## API Design Checklist

   - [ ] Are all endpoint paths explicitly defined in the spec? [Completeness]
   - [ ] Are request/response schemas specified for each endpoint? [Completeness]
   - [ ] Are error codes and their meanings documented? [Clarity]
   - [ ] Are rate limiting requirements stated with specific numbers? [Measurability]
   - [ ] Are authentication requirements consistent across all endpoints? [Consistency]
   - [ ] Are all query parameters from the plan covered in the spec? [Coverage]
   ```

5. **Report results**

   Show:
   - Path to the created checklist file
   - Number of items generated
   - Quality dimensions covered
   - Suggestion to review and customize before using

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
