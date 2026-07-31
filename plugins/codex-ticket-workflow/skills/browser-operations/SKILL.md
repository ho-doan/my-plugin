---
name: browser-operations
description: Thao tác Jira, GitHub, Mattermost hoặc web UI qua Browser MCP sau khi verification pass.
version: 1.0.0
---

# Browser Operations

## Precondition

- verification = PASS;
- `allow_browser_write = true`;
- đúng URL issue/PR;
- action nằm trong plan.

## Actions hỗ trợ

- cập nhật Jira description;
- thêm comment report;
- đổi status;
- đổi assignee khi policy cho phép;
- log work;
- tạo/link sub-task;
- thêm link PR/commit;
- tạo PR;
- điền title/body theo template;
- gửi report qua Mattermost hoặc web UI được chỉ định.

## Safety

1. Mở đúng entity và xác minh:
   - key/id;
   - title;
   - project/repository;
   - current status.
2. Trước write action, so sánh current state với expected state.
3. Nếu action đã tồn tại, không tạo bản trùng.
4. Không click merge, approve, close hoặc delete nếu chưa được cho phép.
5. Chụp evidence trước và sau.
6. Không ghi dữ liệu nhạy cảm vào comment hoặc PR.

## Output

`.my-ai/runs/<run_id>/browser-actions.jsonl`

Mỗi dòng:

```json
{
  "time": "",
  "url": "",
  "entity_id": "",
  "action": "",
  "before": {},
  "after": {},
  "status": "PASS|FAIL|SKIPPED",
  "evidence_ref": ""
}
```


## Scope escalation actions

Browser MCP có thể tạo ticket/subtask khi `scope-escalation.yaml` yêu cầu:

- tạo systemic-fix hoặc architectural ticket;
- tạo subtasks theo workstream;
- link `blocks`, `is blocked by`, `relates to`, hoặc equivalent;
- comment vào originating bug;
- ghi mitigation là temporary;
- không close originating bug nếu systemic fix chưa hoàn thành, trừ workflow policy.


## Blocked Jira behavior

Khi scope vượt ticket, Browser MCP chỉ được:

- comment báo blocked;
- thêm label/status blocked nếu workflow cho phép;
- tạo draft ticket/subtask nếu được cấp quyền;
- link evidence.

Sau comment, phải dừng. Không được chuyển ticket sang In Progress/In Review/Done
và không được tiếp tục code chỉ vì comment đã được tạo.
