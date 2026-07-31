---
name: daily-workflow-orchestrator
description: Điều phối toàn bộ quy trình hằng ngày cho task, bug hoặc proposal bằng terminal và Browser MCP, có gate và evidence.
version: 1.0.0
---

# Daily Workflow Orchestrator

## Khi dùng

Dùng skill này khi Codex được giao một task, bug, proposal hoặc yêu cầu vận hành và cần tự thực hiện theo quy trình đầy đủ.

## Input bắt buộc

```yaml
run_id: string
work_type: task | bug | proposal
source:
  tracker: jira | github | local | other
  issue_url: string | null
repository:
  path: string
  base_branch: string
execution:
  allow_code_change: boolean
  allow_browser_write: boolean
  allow_push: boolean
  allow_pr: boolean
  approval_mode: manual | policy
```

## Trình tự bắt buộc

1. Gọi `work-intake`.
2. Gọi `readiness-assessment`.
3. Nếu readiness là `FAIL`, `UNKNOWN` hoặc `BLOCKED`:
   - không sửa code;
   - tạo report thiếu dữ liệu;
   - chỉ được tiếp tục khi có explicit override hợp lệ.
4. Nếu `work_type = task | proposal`, gọi `implementation-traceability`.
5. Nếu `work_type = bug`, gọi `bug-history-root-cause` và tạo `root-cause-gate.yaml` trước khi lập plan.
6. Với bug, chỉ được sửa production code khi `root_cause_gate.status = PASS` và
   `code_change_allowed = true`. Proximate cause không đủ điều kiện.
7. Với feature/proposal, chỉ tiếp tục khi traceability đạt PASS hoặc có explicit override.

8. Sau root-cause gate, đánh giá phạm vi bằng `scope-escalation-and-decomposition`.
9. Nếu scope là `cross_cutting` hoặc `architectural`, không được thực hiện patch lớn trong ticket hiện tại.
10. Tạo/escalate ticket và subtasks qua Browser MCP khi được cấp quyền.
11. Chỉ cho phép mitigation nhỏ trong ticket hiện tại khi policy và approval cho phép.

7. Gọi `task-planning`.
8. Gọi `code-execution`.
9. Gọi `verification`.
10. Với bug, gọi lại `bug-history-root-cause` để hoàn tất Root Cause Analysis sau fix.
11. Chỉ khi verification đạt PASS mới gọi `browser-operations`.
12. Gọi `delivery-report`.
13. Gọi `workflow-retrospective`.

## State machine

```text
NEW
-> INTAKE_COMPLETE
-> READY
-> TRACEABLE
-> PLANNED
-> IMPLEMENTED
-> VERIFIED
-> DELIVERED
-> REVIEWED
-> DONE
```

Nhánh lỗi:

```text
ANY_STATE -> BLOCKED
ANY_STATE -> FAILED
FAILED -> RETRY_PLANNED
BLOCKED -> WAITING_FOR_INPUT
```

## Evidence

Lưu dưới:

```text
.my-ai/runs/<run_id>/
  run.yaml
  intake.json
  readiness.json
  implementation-traceability.yaml
  bug-history.yaml
  root-cause-analysis.md
  plan.md
  commands.jsonl
  verification.json
  browser-actions.jsonl
  report.md
  retrospective.md
```

## Gate

Không được bỏ qua gate bằng suy luận ngầm.

Override hợp lệ phải có:

```yaml
override:
  approved_by: string
  reason: string
  scope: string
  expires_at: string | null
```

## Kết quả cuối

```json
{
  "run_id": "...",
  "status": "PASS|FAIL|UNKNOWN|BLOCKED",
  "completed_steps": [],
  "failed_step": null,
  "evidence_root": ".my-ai/runs/<run_id>",
  "next_action": "..."
}
```


## Mandatory stop on scope escalation

Nếu `scope_class` là `cross_cutting` hoặc `architectural`:

```text
create impact inventory
→ create escalation report
→ comment Jira if allowed
→ set BLOCKED
→ STOP
```

Orchestrator không được gọi `code-execution` cho tới khi có `unblock` contract hợp lệ.
Việc đã tạo ticket hoặc subtask không tự động gỡ blocked.
