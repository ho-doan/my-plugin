---
name: workflow-retrospective
description: Đánh giá sau mỗi run để chứng minh skill đúng, phát hiện điểm yếu và đề xuất cải thiện có kiểm soát.
version: 1.0.0
---

# Workflow Retrospective

## Mục tiêu

Mỗi task thật đồng thời là một lần kiểm thử workflow.

## Câu hỏi bắt buộc

1. Flow có bước nào bị bỏ qua không?
2. Gate có chặn đúng lúc không?
3. Evidence có đủ để người khác kiểm tra lại không?
4. Có thao tác thủ công nào chưa được skill bao phủ?
5. Có command nào không idempotent?
6. Có retry dư thừa hoặc tốn token không?
7. Có dữ liệu nào Codex phải đọc quá rộng?
8. Có criterion benchmark nào chưa rõ?
9. Kết quả thực tế có khớp report?
10. Lần sau có thể giảm scope hoặc tăng độ chắc chắn thế nào?

## Phân loại cải tiến

- `skill_bug`: skill hướng dẫn sai hoặc thiếu.
- `flow_gap`: thiếu bước hoặc gate.
- `tool_gap`: terminal/Browser MCP không hỗ trợ.
- `benchmark_gap`: criterion không đánh giá được.
- `environment_gap`: quyền, network, dependency.
- `project_gap`: repo hoặc quy trình team không chuẩn.

## Không tự sửa skill trong cùng run

Skill chỉ được tự tạo proposal patch. Patch skill phải được review riêng để tránh workflow tự thay luật nhằm báo PASS.

## Output

`.my-ai/runs/<run_id>/retrospective.md`

```markdown
# Retrospective
## Result
## Evidence quality
## Problems found
## Proposed skill changes
## Proposed benchmark changes
## Automation candidates
## Decision
```
