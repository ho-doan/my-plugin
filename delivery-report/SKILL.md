---
name: delivery-report
description: Tạo báo cáo giao việc có evidence, thay đổi, test, rủi ro và việc cần review.
version: 1.0.0
---

# Delivery Report

## Báo cáo bắt buộc

```markdown
# Delivery Report

## Work item
## Objective
## What changed
## Files changed
## Commands executed
## Verification
## Acceptance criteria mapping
## Browser actions
## Risks and limitations
## Manual review required
## Rollback
## Evidence
```

## Quy tắc

- Không dùng từ "done" nếu còn AC UNKNOWN.
- Không nói "all tests passed" khi chỉ chạy một subset.
- Phân biệt rõ:
  - verified;
  - inferred;
  - not verified.
- Đính kèm commit, branch, PR, issue link nếu có.
- Nếu blocked, report phải nêu chính xác blocker và owner cần xử lý.

## Output

`.my-ai/runs/<run_id>/report.md`


## Báo cáo khi scope vượt ticket

Phải có:

```markdown
## Scope assessment
## Why the current ticket is insufficient
## Changes intentionally not made
## Temporary mitigation
## Raised parent ticket
## Created subtasks
## Dependencies and owners
## Remaining systemic risk
```

Không dùng trạng thái `DONE` nếu chỉ mitigation. Dùng trạng thái phù hợp như:

- `MITIGATED`;
- `ROOT_CAUSE_IDENTIFIED`;
- `SYSTEMIC_FIX_RAISED`;
- `BLOCKED_BY_FOLLOW_UP`.


## Blocked scope report

Khi scope lớn, report bắt buộc ghi cụ thể:

```markdown
## Decision
BLOCKED — SCOPE_EXCEEDS_CURRENT_TICKET

## Impacted services/modules
| Component | Repository | Symbols/contracts | Required change | Owner | Risk |
|---|---|---|---|---|---|

## Why implementation stopped
## Work intentionally not performed
## Jira comment
## Proposed parent ticket and subtasks
## Required unblock authority
## Exact next decision needed
```

Không được dùng câu mơ hồ như “ảnh hưởng nhiều nơi”. Phải nêu tên cụ thể.
