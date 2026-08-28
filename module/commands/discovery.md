---
description: Run Stage-0 discovery — a strategic researcher plus a tactical tracker gatherer, then a distiller — to turn a problem domain into open-questions, or seed a full parent PRD from a bare brief.
---

Run the discovery loop on the specified problem framing.

Usage: /discovery [--serial] <parent.yaml | "problem brief"> [phase1.yaml ...]

Dispatches a strategic RESEARCHER — deliberately unaware of any proposed functional-requirements or journeys so discovery isn't anchored to a pre-baked solution (prior art, patterns, standards, this domain's problems/risks) — and a tactical GATHERER that queries the org's internal issue tracker (via whatever issue-tracker MCP the host has mounted) for related tickets, prior decisions, and duplicates of the proposed initiative. A distiller then synthesizes the findings in one of two modes: given a parent PRD path it emits deduplicated open-questions (spikes) to merge, folding tracker duplicates into annotations; given only a bare problem brief with no PRD it seeds a complete parent PRD — framing, desired-outcomes (each paired with a confirm question), scope, stakeholder placeholders, and open-questions — with no FRs or journeys, for the author to save and validate. Default `parallel` dispatches both research agents as independent subagents; `--serial` runs them sequentially in one context for lower token cost.

$ARGUMENTS
