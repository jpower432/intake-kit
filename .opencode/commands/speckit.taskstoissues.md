---
description: Convert existing tasks into actionable, dependency-ordered GitHub issues for the feature based on available design artifacts.
tools: ['github/github-mcp-server/issue_write']
---

Convert tasks.md into GitHub issues.

## Initialization

Run `.specify/scripts/bash/check-prerequisites.sh --json` from
the repo root and parse the JSON output. Extract `FEATURE_DIR`
from the result. If the script fails or `FEATURE_DIR` is not
set, **STOP** with an error.

## Workflow

1. **Validate GitHub remote**

   Run `git remote get-url origin` to get the remote URL.
   Parse the owner and repository name from the URL.

   If no remote is configured or the URL cannot be parsed,
   **STOP** with an error:
   > "No valid GitHub remote found. Configure a remote with
   > `git remote add origin <url>` first."

2. **Read tasks**

   Read `FEATURE_DIR/tasks.md`. Parse the task list, preserving:
   - Task descriptions
   - Task groupings / sections
   - Dependencies between tasks (if specified)
   - Completion status (`[x]` vs `[ ]`)

   Skip tasks already marked complete (`[x]`).

3. **Read context artifacts**

   Read available context for issue body content:
   - `FEATURE_DIR/spec.md` (requirements context)
   - `FEATURE_DIR/plan.md` (implementation plan)

4. **Create issues in dependency order**

   For each incomplete task:
   - Create a GitHub issue using the MCP tool
   - Title: the task description
   - Body: include relevant spec/plan context, acceptance
     criteria, and dependency references
   - Labels: add feature label if available
   - If the task depends on another task, reference the
     previously created issue number in the body

   **CRITICAL**: Only create issues in the repository matching
   the remote URL parsed in step 1. NEVER create issues in any
   other repository.

5. **Report results**

   Show:
   - Number of issues created
   - Issue numbers and titles
   - Repository where issues were created
   - Any tasks that were skipped (already complete)

## Guardrails

- This command creates **GitHub issues via** the MCP API.
  It does NOT write local files.
- Issues MUST only be created in the repository matching
  the current Git remote. NEVER create issues in
  unrelated repositories.
- Do NOT modify source code, spec artifacts, or any
  local files.
