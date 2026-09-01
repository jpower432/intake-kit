---
description: Run the PRD Review Council against a PRD family — Guard review pass by default, or the full five-agent council with --full.
---

Run the PRD Review Council on the specified PRD files.

Usage: /prd-review [--full] [--serial] [--schema <path>] <parent.yaml> [phase1.yaml phase2.yaml ...]

Checks CUE schema conformance and FR/journey coverage in one `cue vet` pass (the structural floor), then selects review depth for a `Draft` PRD by invocation: by default a fresh PRD gets a `cue vet` + Guard review (gates nothing); with `--full` a matured PRD gets the full five agents (Guard, Adversary, Tester, Operator, Curator) that gate `Draft → Ready` — on APPROVED the skill asks the author to confirm before mutating `state.status` to `Ready`, and emits a BLOCKED / NEEDS REVISION / APPROVED verdict. A `Ready` or later PRD triggers no gating dispatch; `Ready → Approved` is a manual human sign-off outside this command. Default `parallel` mode dispatches agents as independent subagents; `--serial` runs them sequentially in one context for lower token cost.

$ARGUMENTS
