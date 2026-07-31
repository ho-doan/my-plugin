---
name: task-planning
description: Tạo kế hoạch nhỏ, bounded, có test và rollback trước khi sửa code.
version: 1.0.0
---

# Task Planning

## Mục tiêu

Chuyển requirement đã sẵn sàng thành các bước nhỏ có thể chứng minh.

Kế hoạch không được tự phát minh logic. Nó phải sử dụng:
- `implementation-traceability.yaml` cho task/proposal;
- `bug-history.yaml` cho bug.

## Quy trình

1. Đọc traceability/history evidence.
2. Xác định requirement, task, commit, PR hoặc contract là nguồn của thay đổi.
3. Xác định file/module có khả năng bị ảnh hưởng.
2. Dùng search, AST, call graph hoặc test hiện có để xác định impact.
3. Tạo hypothesis cho bug hoặc design choice cho task.
4. Chia thay đổi thành bước nhỏ.
5. Xác định test cần chạy trước và sau.
6. Xác định rollback.
7. Xác định browser action cần thực hiện sau verification.
8. Đánh dấu các thay đổi ngoài scope thành proposal, không làm lẫn vào task.

## Giới hạn

- Ưu tiên patch nhỏ nhất đáp ứng AC.
- Không refactor diện rộng nếu task không yêu cầu.
- Không nâng dependency không liên quan.
- Không đổi public contract nếu chưa có approval.

## Output

`.my-ai/runs/<run_id>/plan.md`

Bắt buộc có:

```markdown
# Plan
## Objective
## Scope
## Evidence inspected
## Impacted components
## Steps
## Tests
## Browser actions
## Risks
## Rollback
## Out-of-scope proposals
```
