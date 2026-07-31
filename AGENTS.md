# AGENTS.md

## Standalone Codex workflow

This repository is using Codex directly to validate engineering workflows before
the chatbot is complete.

When the user runs:

```text
implement ticket <ticket-url-or-key>
```

Codex must:

1. Read the ticket, comments, links, and history using available tools.
2. Read `codex-flows/manifest.yaml`.
3. Select the matching versioned flow.
4. Read that flow file.
5. Read and execute the exact versioned skills declared by the flow.
6. Store run evidence in `codex-runs/<run-id>/`.
7. Stop immediately on `BLOCKED`, `UNKNOWN`, or `FAIL`.
8. Never bypass pre-code gates.
9. Never depend on `.my-ai/` or the unfinished chatbot.

`skills-manifest.yaml` validates available skill versions.
`skills-lock.yaml` pins the currently approved skill versions.
