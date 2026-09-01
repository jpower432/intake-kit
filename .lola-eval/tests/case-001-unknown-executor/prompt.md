Review this PRD family using the intake-kit prd-review skill.

The initiative has a parent PRD (`parent.yaml`) and one phase PRD
(`phase1.yaml`). The `prd-review` skill and its agents are pre-installed
in this project's `.lola/` directory. Run the review with the local
schema as fallback:

    /prd-review --schema prd.cue parent.yaml phase1.yaml

Report all findings from the review, including their severity and the
specific location (file and id) each finding refers to.
