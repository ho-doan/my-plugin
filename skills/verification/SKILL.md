---
name: verification
description: Chứng minh thay đổi đúng bằng test, lint, build, benchmark và AC mapping.
version: 1.0.0
---

# Verification

## Mục tiêu

Không báo "done" chỉ vì compile thành công.

## Lớp kiểm chứng

1. Static:
   - format;
   - lint/clippy/analyzer;
   - type check.
2. Unit:
   - test trực tiếp logic thay đổi.
3. Integration:
   - test luồng qua module liên quan.
4. Regression:
   - test các hành vi cũ bị ảnh hưởng.
5. Acceptance:
   - map từng AC sang evidence cụ thể.
6. Runtime:
   - log, browser hoặc app behavior khi cần.

## Quy tắc

- Test fail phải phân loại:
  - implementation defect;
  - test defect;
  - environment defect;
  - flaky;
  - missing fixture.
- Không sửa expected output chỉ để pass.
- Nếu không thể chạy một test bắt buộc, trạng thái không được là PASS.
- Build success không thay thế acceptance verification.

## Output

`.my-ai/runs/<run_id>/verification.json`

```json
{
  "status": "PASS|FAIL|UNKNOWN|BLOCKED",
  "checks": [],
  "acceptance_mapping": [
    {
      "criterion": "",
      "status": "PASS|FAIL|UNKNOWN",
      "evidence_refs": []
    }
  ],
  "unverified_risks": []
}
```


## Traceability verification

Với feature mới:

- mỗi AC phải map tới symbol và test;
- mỗi symbol mới phải map lại source requirement;
- decision table phải được phủ test;
- không được có business branch không có source.

Với bug:

- regression test phải fail trên phiên bản trước fix khi có thể;
- phải chứng minh solution xử lý root cause;
- phải ghi originating task/commit/PR hoặc `unknown_origin`;
- phải phân biệt `introduced_by`, `exposed_by`, `regressed_by`.


## Root-mechanism verification for bugs

Verification không chỉ kiểm tra symptom biến mất.

Bắt buộc xác minh:

- root mechanism đã bị loại bỏ hoặc bị kiểm soát bởi invariant;
- ít nhất một sibling failure mode cùng lớp được test;
- fix không chỉ thêm guard tại điểm crash;
- regression test bao phủ điều kiện tạo lỗi, không chỉ output cuối;
- systemic escape cause có follow-up action khi cần.

Nếu symptom pass nhưng root mechanism chưa được chứng minh:

```yaml
status: UNKNOWN
reason: Symptom is removed, but root mechanism removal is unproven.
```
