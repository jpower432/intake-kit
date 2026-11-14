# Intake Kit

Intake Kit validates YAML product requirements with CUE and reviews them with
an AI review council.

## Installation

Install with [Lola](https://github.com/LobsterTrap/lola) in an AI assistant
that supports Lola skills:

```bash
lola install github.com/unbound-force/intake-kit
```

## Usage

Copy a parent and phase PRD from [examples/](examples/). The parent describes
the initiative, job executors, desired outcomes, and scope; each phase defines
functional requirements, journeys, and delivery state.

From a checkout of this repository, validate your PRD with
[CUE](https://cuelang.org/docs/introduction/installation/):

```bash
cue vet prd.cue -d '#PRDDocument' your-prd.yaml
```

In your assistant, run a Guard review while drafting or the full five-agent
council when the PRD is ready for review:

```
/prd-review prds/my-feature.yaml prds/my-feature-phase1.yaml          # Guard-only, gates nothing
/prd-review --full prds/my-feature.yaml prds/my-feature-phase1.yaml   # full council, gates Draft → Ready
```

The full review asks for confirmation before changing `Draft` to `Ready`.
`Ready` phases require acceptance criteria and outcome references on every
functional requirement. Human approval is a separate, manual step.

### Structured Metadata

Optional fields record decisions on open questions, feature-to-requirement
mappings, lifecycle diagrams, a reading guide, glossary terms, and phase-exit
criteria. Existing documents can omit them. See the
[structured parent](examples/structured-parent.yaml) and
[phase](examples/structured-phase.yaml) examples for the proposed, unreleased
0.3.0 schema additions.

The review council checks whether requirements meet user needs and whether
journey executors and outcome references match the parent. For development
and review details, see [AGENTS.md](AGENTS.md) and the
[review skill](module/skills/prd-review/SKILL.md).

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE), including attribution
for the lola-eval scaffolding adapted from
[Review Council](https://github.com/lolables/lola-mod-review-council).
