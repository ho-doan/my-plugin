---
name: ticket-workflow-orchestrator
description: Implement or investigate Jira/tracker tickets through controlled versioned workflows. Trigger when the user says "implement ticket", provides a ticket URL/key for implementation, asks to fix a ticket bug, or asks Codex to execute a ticket end-to-end. Do not trigger for casual ticket summaries that do not request execution.
version: 1.0.0
---

# Ticket Workflow Orchestrator

This plugin runs directly in Codex across repositories. It is intentionally
independent from the unfinished ai-chatbot and must not read or create `.my-ai/`
configuration unless the current repository explicitly requires it.

## Entry command

Primary trigger:

```text
implement ticket <ticket-url-or-key>
```

## Locate plugin assets

Resolve this skill's plugin root, then read:

```text
assets/flows/manifest.yaml
assets/skills-manifest.yaml
assets/skills-lock.yaml
```

Do not search the target repository for a flow registry unless repository-local
instructions explicitly override this plugin.

## Select flow

1. Read the ticket through available tracker/browser tools.
2. Read title, issue type, description, acceptance criteria, comments, linked
   issues, parent/subtasks, status, assignee, reporter, attachments, and history.
3. Match the ticket against `assets/flows/manifest.yaml` in priority order.
4. Read the selected exact-version flow from `assets/flows/`.
5. Resolve every exact skill version declared by the flow.
6. Validate the skill/version against `assets/skills-manifest.yaml` and
   `assets/skills-lock.yaml`.
7. Never select `latest`, a range, or an unapproved candidate version.

## Run evidence

Store evidence in the target repository under:

```text
.codex-runs/<ticket-key>-<timestamp>/
```

Do not write to `.my-ai/runs`.

At minimum record:

```text
workflow-selection.yaml
skill-resolution.yaml
intake.json
readiness.json
report.md
```

Create the other artifacts required by the selected flow.

## Execution rules

- Follow the selected flow step by step.
- Read each referenced `SKILL.md` only when its step is reached.
- Treat `stop_on` as mandatory.
- Never start production code before all pre-code gates pass.
- For features, trace each new behavior, function, branch, and test to its source.
- For bugs, prove root cause rather than fixing the first visible cause.
- If the correct fix is cross-cutting or architectural, list each affected
  service/module/repository/contract explicitly, report `BLOCKED`, comment the
  ticket when permitted, and stop.
- Creating a comment, ticket, or subtask does not unblock the run.
- Resume only after explicit unblock evidence defines authority and approved scope.
- After unblock, rerun readiness and scope gates.

## Project-specific instructions

Repository `AGENTS.md` remains authoritative for repository conventions, build
commands, permissions, and stricter safety requirements.

If repository guidance conflicts with this plugin:
- use the stricter safety or approval requirement;
- record the conflict;
- stop with `BLOCKED` when the conflict cannot be resolved safely.

## Final response

Return:

```yaml
run_id: ""
ticket: ""
workflow: ""
status: DONE | FAIL | UNKNOWN | BLOCKED
implementation_performed: false
root_cause_status: not_applicable | unknown | identified
scope_class: in_scope | adjacent_scope | cross_cutting | architectural
impacted_components: []
jira_actions: []
verification_status: PASS | FAIL | UNKNOWN
next_action: ""
artifacts: []
```

If blocked, end with:

```text
IMPLEMENTATION STOPPED.
Awaiting explicit unblock decision.
```
