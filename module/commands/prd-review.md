---
description: Run the PRD Review Council (5 specialist agents) against a PRD family.
---

Run the PRD Review Council on the specified PRD files.

Usage: /prd-review [--serial] [--schema <path>] <parent.yaml> [phase1.yaml phase2.yaml ...]

Checks CUE schema conformance (registry first, falling back to `--schema <path>` if the published schema can't be resolved), then dispatches 5 specialist agents (Guard, Adversary, Tester, Operator, Curator) against the PRD family and emits a BLOCKED / NEEDS REVISION / APPROVED verdict. Default `parallel` mode dispatches all 5 as independent subagents (faster, ~5x PRD ingestion cost). `--serial` runs all 5 personas sequentially in one context, reusing the already-read PRD text (slower, ~1x ingestion cost).

$ARGUMENTS
