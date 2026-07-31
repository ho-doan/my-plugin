---
name: readiness-assessment
description: Đánh giá task, bug hoặc proposal đã đủ điều kiện thực hiện chưa bằng benchmark có version.
version: 1.0.0
---

# Readiness Assessment

## Mục tiêu

Không cho Codex sửa code từ yêu cầu mơ hồ.

## Nguồn đánh giá

- `.my-ai/benchmarks/<flow>.yaml`
- intake evidence
- repository evidence
- tracker evidence

## Tiêu chí mặc định

### Chung

- objective rõ;
- expected result rõ;
- scope xác định;
- AC có thể kiểm chứng;
- dependency đã biết;
- quyền thao tác đủ;
- repository và branch xác định;
- không có conflict chưa giải quyết.

### Bug

- có reproduction hoặc bằng chứng thay thế;
- expected và actual khác nhau rõ;
- môi trường lỗi đã biết;
- mức ảnh hưởng được ghi nhận.

### Proposal

- vấn đề tồn tại có evidence;
- lợi ích kỳ vọng;
- rủi ro;
- tiêu chí chấp nhận hoặc metric;
- cần approval trước implementation nếu thay đổi lớn.

## Quy tắc kết quả

- `PASS`: đủ evidence cho mọi criterion bắt buộc.
- `FAIL`: evidence chứng minh criterion không đạt.
- `UNKNOWN`: thiếu evidence.
- `BLOCKED`: dependency hoặc quyền truy cập ngăn thực hiện.

## Output

`.my-ai/runs/<run_id>/readiness.json`

```json
{
  "benchmark_id": "",
  "benchmark_version": "",
  "status": "PASS|FAIL|UNKNOWN|BLOCKED",
  "criteria": [
    {
      "id": "",
      "status": "PASS|FAIL|UNKNOWN",
      "evidence_refs": [],
      "reason": ""
    }
  ],
  "required_actions": []
}
```
