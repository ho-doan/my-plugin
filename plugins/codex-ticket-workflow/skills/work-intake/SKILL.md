---
name: work-intake
description: Thu thập và chuẩn hóa yêu cầu từ Jira, GitHub, terminal, comment hoặc prompt trước khi thực hiện.
version: 1.0.0
---

# Work Intake

## Mục tiêu

Tạo một bản mô tả công việc duy nhất, có nguồn gốc và không bỏ sót comment quan trọng.

## Hành động

1. Đọc issue chính.
2. Đọc toàn bộ comment có liên quan.
3. Thu thập:
   - mục tiêu;
   - expected behavior;
   - current behavior;
   - acceptance criteria;
   - scope;
   - out of scope;
   - owner/assignee/reporter;
   - dependency;
   - deadline/sprint;
   - link thiết kế, log, PR, tài liệu;
   - quyết định mới nhất.
4. Với bug:
   - reproduction steps;
   - environment;
   - frequency;
   - impact;
   - logs/screenshots.
5. Với proposal:
   - problem;
   - intended benefit;
   - constraints;
   - alternatives;
   - success metrics.
6. So sánh description và comment mới nhất. Khi mâu thuẫn, đánh dấu rõ.

## Không được làm

- Không tự bổ sung AC chưa được xác nhận.
- Không coi comment cũ là quyết định cuối nếu có comment mới hơn.
- Không bắt đầu code.

## Output

`.my-ai/runs/<run_id>/intake.json`

```json
{
  "work_type": "task|bug|proposal",
  "summary": "",
  "objective": "",
  "acceptance_criteria": [],
  "constraints": [],
  "dependencies": [],
  "conflicts": [],
  "missing_information": [],
  "source_refs": [],
  "status": "PASS|UNKNOWN|BLOCKED"
}
```
