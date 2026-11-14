# Intake Kit — Developer Guide

This repo is the source for the `intake-kit` Lola module.
The installable module lives entirely under `./module/`.

## Project layout

```
module/                            ← installable module (what users get)
  AGENTS.md                        ← injected into user's AGENTS.md by lola
  agents/                          ← standalone review agent definitions
  skills/prd-review/
    SKILL.md                       ← orchestration skill
    references/                    ← reviewer protocol and shared refs
  commands/prd-review.md           ← command entry point
prd.cue                            ← CUE schema (published to CUE registry)
cue.mod/                           ← CUE module definition
examples/                          ← example PRD YAML files
testdata/                          ← CUE schema test fixtures (valid + invalid)
Taskfile.yml                       ← task runner (test, vet-examples)
.github/workflows/                 ← CI (CUE registry publish)
.opencode/                         ← Unbound Force dev tooling overlay
  agents/                          ← agent definitions (Divisor council, etc.)
  commands/                        ← slash command definitions
  skills/                          ← orchestration skills (OpenSpec workflow)
  uf/packs/                        ← convention packs (coding + content standards)
  references/                      ← shared reference documents for agents
openspec/                          ← OpenSpec change management schemas + templates
opencode.json                      ← MCP server configuration (Dewey)
```

## Development tooling vs. module content

The `.opencode/` directory contains Unbound Force development tooling --
agent definitions, convention packs, and workflow commands used by
contributors to this repo. These are NOT part of the installable module.
The `module/` directory contains the PRD review agents and skills that
ship to users via Lola. Do not confuse the two.

The `.opencode/` overlay is scaffolded by `uf init` and may include
agents and commands that reference infrastructure not yet present in
this project (e.g., `.specify/memory/constitution.md`, `specs/`). Agents
are designed to degrade gracefully when referenced infrastructure is
absent.

## Golden rule

**All changes to module content go in `./module/`, never in the installed location.**

The installed copy (typically `~/.config/opencode/skills/prd-review/`
or `.claude/skills/prd-review/`) is a deployment artifact. If you find
yourself editing files outside `./module/`, stop — you're modifying a
copy that will be overwritten on next install.

## Working on review agents

Agent definitions live at `module/agents/prd-*.md`. Each is a standalone
reviewer that runs in parallel during Phase 2 of the review council.
Follow the existing agent files as a template when adding new ones.

## Working on the schema

The CUE schema at `prd.cue` is published to the CUE Central
Registry via the `publish-cue.yml` workflow on tag push. The module
definition at `cue.mod/module.cue` controls the module path and
language version.

## Tool Agnosticism

This module MUST remain target-tool agnostic. It must work identically
whether the hosting tool is Claude Code, OpenCode, Cursor, Windsurf,
Gemini CLI, or any future AI coding assistant.

Rules:

1. **No tool-specific frontmatter.** Skill and agent files use only
   keys every host understands.
2. **No tool-specific dispatch syntax.** Orchestrator docs describe
   dispatch intent with fallback instructions for hosts that lack
   named-agent dispatch.
3. **No tool names in operational text.** References to specific tools
   are permitted only in docs — never in instructions or agent
   definitions that affect runtime behavior.
4. **Graceful degradation over hard requirements.** Features that
   depend on host capabilities must degrade gracefully when the host
   lacks them, not fail.

## Convention Packs

This repository uses convention packs scaffolded by
unbound-force. Agents MUST read the applicable pack(s)
before writing or reviewing code.

- `.opencode/uf/packs/default.md`
- `.opencode/uf/packs/default-custom.md`
- `.opencode/uf/packs/severity.md`
- `.opencode/uf/packs/content.md`
- `.opencode/uf/packs/content-custom.md`
