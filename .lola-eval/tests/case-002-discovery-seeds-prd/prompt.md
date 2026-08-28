I have a problem domain but no PRD yet — just the brief in `problem.md`.

Use the intake-kit discovery skill to seed a **parent PRD** for this
initiative from that brief. The discovery skill and its agents are
pre-installed in this project's `.lola/` directory.

    /discovery --serial "$(cat problem.md)"

Constraint: work from the problem brief only. Do **not** perform any
external web research or query any tracker — treat those tools as
unavailable and degrade gracefully, as the discovery protocol allows.

I want the end result to be a complete **parent PRD** I can save and
validate against `prd.cue`: header, slug, title, description,
job-executors, desired-outcomes, scope, stakeholders, and the distilled
open-questions. Do not author phases, functional requirements, or
journeys — parent framing only.

Produce the parent PRD as YAML.
