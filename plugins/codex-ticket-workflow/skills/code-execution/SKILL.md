---
name: code-execution
description: Thực thi thay đổi trong terminal theo kế hoạch, ghi log command, diff và checkpoint.
version: 1.0.0
---

# Code Execution

## Precondition

- readiness = PASS;
- plan tồn tại;
- repository sạch hoặc dirty state đã được ghi nhận;
- branch đúng.

## Quy trình

1. Chụp baseline:
   - `git status`;
   - branch;
   - commit HEAD;
   - test baseline phù hợp.
2. Tạo hoặc chuyển sang branch theo policy.
3. Thực hiện từng bước trong plan.
4. Sau mỗi bước:
   - lưu command;
   - exit code;
   - stdout/stderr tóm tắt;
   - files changed;
   - reason.
5. Chạy formatter/linter liên quan.
6. Kiểm tra diff:
   - không có secret;
   - không có file ngoài scope;
   - không có debug code;
   - không sửa test để che lỗi.
7. Tạo checkpoint local khi thay đổi đủ nhỏ và ổn định.

## Khi lệnh thất bại

- Không lặp vô hạn.
- Tối đa 2 retry nếu nguyên nhân rõ và cách retry khác nhau.
- Sau đó đánh dấu BLOCKED hoặc cập nhật hypothesis.
- Không xóa evidence lỗi.

## Output

- `.my-ai/runs/<run_id>/commands.jsonl`
- `.my-ai/runs/<run_id>/diff.patch`
- `.my-ai/runs/<run_id>/execution.json`
