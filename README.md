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

Validation requires [CUE](https://cuelang.org/docs/introduction/installation/)
v0.17.0 or later. From a checkout of this repository:

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
criteria. These additions target the unreleased 0.3.0 schema; existing
documents can omit them. See the
[structured parent](examples/structured-parent.yaml) and
[phase](examples/structured-phase.yaml) for a complete family with open and
resolved decisions, both allocation statuses, and exit references to FRs,
ACs, and a parent NFR.

### Document Model

PRDs use parent-child relationships. The parent defines the initiative's
title, overview, job executors, desired outcomes, scope, stakeholders, and
shared nonfunctional requirements. Phase PRDs identify the parent through
`header.parent` and define delivery behavior through journeys and functional
requirements. A phase's `slug` is its stable reference; `phase` is a display
label.

Decisions, feature mappings, lifecycle notes, reading guides, and glossary
entries may appear on either document type. Only `phase-exit-criteria` is
phase-only. Omit optional collections when unused; new collections must be
nonempty when present. Legacy `open-questions: []` remains valid.

### Decisions and Allocation

An `open-questions` entry can keep its original `question` and `context`
alongside a structured `decision`. Each decision names an ID, Open or
Resolved status, operational authority, and an explicit `blocks` list.
Each blocking entry names a phase **slug** and a specific activity. An empty
`blocks: []` records a nonblocking decision. Blocking one activity does not
block every activity in that phase.

Operational `authority.status` may be `confirmed` or `unconfirmed`; it is
independent of stakeholder `approver: true`. A Resolved decision requires
both `resolution` and `rationale`. Those fields are forbidden while Open.
Retain the question and context after resolution; its blocking pairs then
describe historical scope.

`feature-mappings` link a feature to canonical FR IDs. Each mapping records
`allocated` or `unconfirmed` and the evidence supporting that status.
Unconfirmed allocation makes uncertainty explicit without waiving reference
checks. Phase-exit descriptions summarize exit conditions and may cite
canonical FR, AC, or NFR IDs instead of duplicating requirements.

### Markdown and Rendering

Use YAML block scalars (`|`) for multiline prose. Markdown is supported as
content in `description`, question `context`, decision authority descriptions,
resolutions and rationales, mapping evidence, lifecycle descriptions,
`reading-guide`, glossary definitions, and exit descriptions. Keep IDs,
feature references, and glossary terms as plain text.

`lifecycle.diagram` stores diagram source, such as Mermaid, without an outer
Markdown fence. A consumer can place it inside a `mermaid` fence and show
`lifecycle.description` beneath it. CUE checks nonblank text, not diagram
syntax. Consumers without diagram support should show a fenced source block.
Render `reading-guide` as Markdown and glossary entries as a term/definition
list or table. For example, the structured parent's guide links to its phase.

Intake Kit emits review findings rather than rendered PRDs. Reviewers use
these narrative fields as context and retain raw YAML when citing evidence.
The canonical requirements remain the behavioral contract. A separate
document renderer must preserve decision status, authority confirmation,
blocking scope, allocation evidence, and exit requirement links.

### Validation Boundaries

Run `cue vet` separately for each file; passing multiple YAML PRDs in one
invocation unifies them rather than checking family relationships.

| Check | Single-file CUE validation | Guard family review |
|---|---|---|
| Field types, IDs, decision state, required fields, nonblank new prose | Yes | Content quality |
| Mapping feature | Against local `features`, when declared | Against parent `features` when omitted locally |
| Mapping FR IDs | Against local FR list, when declared | Across phases when the mapping document has no FR list |
| Exit FR/AC IDs | Against the phase's own FRs/ACs | Whether descriptions match cited requirements |
| Exit NFR IDs | Format only | Against parent and phase NFRs |
| Blocked phase | Slug format only | Against phase document `slug` values |
| Executors, outcomes, duplicate IDs across files | Format and local structure | Parent/phase consistency |

Supply the parent and all phase files to `/prd-review` for these family
checks. Missing target documents produce an unverified-reference note,
not proof that a reference is invalid. Curator's full-council pass checks
decision authority, resolution quality, and activity-specific blocking.

### Migration from Embedded Metadata

The new fields are optional. PRDs using the existing kebab-case model can
keep narrative content in `description`, `state.remarks`, or question
`context`; those strings remain opaque, even when they look like YAML.
Earlier field-name changes have separate guidance in [CHANGELOG.md](CHANGELOG.md).

To adopt structured metadata:

1. Keep `description` as the overview. Move reader navigation, terminology,
   and lifecycle detail into `reading-guide`, `glossary`, and `lifecycle`.
2. Move decision metadata out of question context into a sibling `decision`.
   Preserve the original question and explanatory context. Keep an existing
   valid decision ID; assign a stable `DEC-<PREFIX>-001` ID if none exists.
3. Extract feature allocations and phase-exit notes from `description` or
   `state.remarks` into the corresponding fields. Retain unrelated remarks.
   Record uncertain authority/allocation as `unconfirmed` rather than guessing.
4. Set `header.schema-version` to `0.3.0` when adopting these additions.
   Preserve requirement IDs, `header.parent`, slugs, document versions,
   `state.status`, and stakeholder approvals. Record document revisions and
   dates under your existing versioning policy. Migration grants no approval.
5. Validate each file against this checkout, then review the complete family.
   Use the local schema while 0.3.0 is unpublished:

   ```text
   /prd-review --schema prd.cue --full prds/my-feature.yaml prds/my-feature-phase1.yaml
   ```

For example, this legacy question stores metadata inside a string:

```yaml
open-questions:
  - question: Who approves processing?
    context: |
      The source owner must be identified before accepting a maintenance change.
      decision-id: DEC-MF-001
      status: Open
      blocked-phase: my-feature-phase1
      blocked-activity: Accept a maintenance change
      authority: Source owner, unconfirmed
```

Replace that entry with structured fields while retaining its question and
explanation:

```yaml
open-questions:
  - question: Who approves processing?
    context: |
      The source owner must be identified before accepting a maintenance change.
    decision:
      id: DEC-MF-001
      status: Open
      blocks:
        - phase: my-feature-phase1
          activity: Accept a maintenance change
      authority:
        status: unconfirmed
        description: Source owner, contact awaiting confirmation.
```

The review council checks whether requirements meet user needs and whether
journey executors and outcome references match the parent. For development
and review details, see [AGENTS.md](AGENTS.md) and the
[review skill](module/skills/prd-review/SKILL.md).

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE), including attribution
for the lola-eval scaffolding adapted from
[Review Council](https://github.com/lolables/lola-mod-review-council).
