# Discovery Protocol

Shared rules for the discovery agents
(`module/agents/discovery-researcher.md`,
`module/agents/discovery-gatherer.md`). The `discovery-distiller` agent
has its own contract (it consumes this output); it does not follow this
protocol.

## Independence (normative)

The **researcher** receives ONLY the problem framing: the initiative's
`title`, `description`, `job-executors`, and `scope`. It MUST NOT be given —
and MUST NOT ask for — the `functional-requirements` or `journeys` of
any PRD in the family. Those may encode the proposed solution; 
seeing them anchors research to a pre-baked answer, which is
exactly the bias this stage exists to remove. If the researcher's input
contains FRs or journeys, it ignores them and notes in
`sources_consulted` that it deliberately withheld the proposed solution.

The **gatherer** is the exception: it DOES see the full PRD family,
because detecting duplicates requires knowing what is being proposed.
Its job is prior-art and dedup against the org's tracker, not unbiased
domain research, so the independence rule does not apply to it.

The two agents never see each other's output. Overlap is expected and is
resolved later by the distiller.

## Tool Access

Read-only. An agent may use whatever research tools the host exposes in
its lane (see each agent's own file), but performs no writes and never
edits PRD files. If a tool an agent would use is unavailable,
unauthenticated, or fails, do not block and do not fabricate: record the
gap in `sources_consulted` (e.g. `"web search unavailable"`,
`"no issue-tracker detected"`) and return whatever findings the
reachable sources support. Silence about an unreachable source is not
acceptable — name it.

## Evidence Discipline

- Ground every finding in a source you actually consulted this pass.
- `evidence` is a verbatim quote from that source (a doc line, an issue
  body line, a spec clause). For a finding that rests on established
  domain knowledge rather than a quotable artifact, set
  `source: "domain knowledge"` and leave `evidence` an empty string —
  never fabricate a quote to fill the field.
- Never invent a solution. Discovery agents surface patterns, problems,
  risks, constraints, and existing tickets — they never propose
  functional requirements.

## Output Schema

Your entire response is a single fenced ```json block. Nothing else —
no prose before or after it.

```json
{
  "agent": "discovery-researcher",
  "sources_consulted": ["<url | issue ref | 'domain knowledge' | '<tool> unavailable'>"],
  "findings": [
    {
      "kind": "pattern | problem | risk | constraint | duplicate",
      "title": "Short headline for this finding",
      "observation": "One to three sentences stating what you found.",
      "evidence": "<verbatim quote from the source, or empty string for domain knowledge>",
      "source": "<url | issue ref | 'domain knowledge'>",
      "relevance": "One sentence: why this matters to the stated initiative.",
      "tracker_ref": "<issue key/URL — gatherer only, omit otherwise>"
    }
  ]
}
```

- Set `"agent"` to your own agent id
  (`discovery-researcher` or `discovery-gatherer`).
- A discovery pass that genuinely surfaces nothing returns
  `"findings": []` — never manufacture findings to look thorough.
- `kind` is the lens the finding came through: an existing industry
  `pattern`, a recurring `problem` in the domain, an execution `risk`,
  an external `constraint` (regulatory, data-model, interop), or — for
  the gatherer only — a `duplicate` (an existing tracker item that
  already covers the proposed initiative or part of it).
- `tracker_ref` is emitted ONLY by the gatherer, and only when the
  finding points at a specific tracker item (its key or URL). The
  researcher never sets it.
