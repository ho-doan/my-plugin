---
name: bug-history-root-cause
description: Truy vết bug về task, commit, PR hoặc thay đổi đã sinh ra lỗi; sau khi fix phải xuất root cause, solution và regression evidence.
version: 1.0.0
---

# Bug History and Root Cause

## Mục tiêu

Không fix bug chỉ dựa trên stack trace hiện tại.

Codex phải xác định:

1. Bug được đưa vào từ task, commit, PR hoặc refactor nào.
2. Behavior ban đầu được thiết kế ra sao.
3. Vì sao test/review trước đó không phát hiện.
4. Root cause thực sự nằm ở requirement, design, implementation, integration, data hay environment.
5. Solution sửa nguyên nhân hay chỉ che triệu chứng.
6. Regression test nào ngăn bug quay lại.

## Nguồn history bắt buộc đọc

Tùy repository, dùng các nguồn sau:

- `git log -- <affected files>`
- `git blame <affected lines>`
- `git show <suspect commit>`
- merge commit và PR description
- issue/task được nhắc trong commit
- changelog/release note
- test history
- comment TODO/FIXME
- tracker issue history và comments
- deployment/config history nếu bug liên quan môi trường

Không được chỉ dùng `git blame` như kết luận cuối. Blame chỉ là manh mối.

## Quy trình

### 1. Reproduce và khoanh vùng

Ghi rõ:

```yaml
symptom:
reproduction:
expected:
actual:
first_bad_behavior:
affected_versions:
affected_components:
```

### 2. Tìm điểm thay đổi hành vi

Ưu tiên:

```bash
git log --follow -- path/to/file
git blame -L <start>,<end> path/to/file
git show <commit>
git log -S'<symbol-or-code>' --all
git log -G'<regex>' --all
git bisect
```

Nếu không thể chạy bisect, phải giải thích.

### 3. Liên kết commit với work item

Trích:

- commit hash;
- PR/MR;
- task/bug/proposal key;
- author/date;
- intent trong commit/PR;
- file và symbol đã đổi;
- test được thêm hoặc thiếu.

Kết quả có thể là:

- `introduced_by`: commit thực sự tạo bug;
- `exposed_by`: thay đổi chỉ làm bug cũ lộ ra;
- `regressed_by`: behavior đúng bị phá lại;
- `unknown_origin`: không đủ history.

### 4. Five-whys có evidence

Không viết Five Whys chung chung. Mỗi why phải có evidence:

```yaml
why_1:
  statement: Request bị gửi hai lần.
  evidence: runtime log ...
why_2:
  statement: Retry chạy dù request đầu đã thành công.
  evidence: RetryPolicy::execute ...
why_3:
  statement: Success response không được đánh dấu terminal.
  evidence: commit abc123 changed state handling ...
why_4:
  statement: Task XYZ chỉ mô tả retry on timeout, không mô tả idempotency.
  evidence: JIRA-XYZ acceptance criteria ...
why_5:
  statement: Không có contract test cho duplicate delivery.
  evidence: test search ...
```

### 5. Root cause classification

Chọn một hoặc nhiều:

- `requirement_gap`
- `acceptance_criteria_gap`
- `design_defect`
- `implementation_defect`
- `state_machine_defect`
- `concurrency_race`
- `integration_contract_mismatch`
- `data_migration_defect`
- `configuration_defect`
- `environment_defect`
- `test_gap`
- `review_gap`
- `deployment_gap`

### 6. Solution design

Phải phân biệt:

```yaml
symptom_patch:
  description:
  accepted: false

root_cause_solution:
  description:
  why_it_fixes_root_cause:
  behavior_changed:
  backward_compatibility:
  migration_needed:
  risks:
```

Không được báo fix hoàn tất nếu chỉ áp dụng symptom patch, trừ khi task cho phép mitigation tạm thời và có follow-up issue.

### 7. Regression proof

Bắt buộc có:

- test fail trước fix;
- test pass sau fix;
- test behavior liên quan không bị phá;
- mapping tới root cause;
- nếu race/concurrency: stress hoặc deterministic synchronization test;
- nếu integration: contract/integration test;
- nếu config: validation/startup test.

## Output trước khi sửa

`.my-ai/runs/<run_id>/bug-history.yaml`

```yaml
status: PASS | UNKNOWN | BLOCKED
suspect_commits: []
related_tasks: []
behavior_timeline: []
introduced_by: null
exposed_by: null
regressed_by: null
history_evidence: []
```

## Output sau khi sửa

`.my-ai/runs/<run_id>/root-cause-analysis.md`

```markdown
# Root Cause Analysis

## Symptom
## Expected versus actual
## Reproduction
## Behavior timeline
## Originating task / PR / commit
## Introduced, exposed, or regressed
## Root cause
## Why previous checks missed it
## Solution
## Why the solution fixes the root cause
## Regression tests
## Remaining risks
## Follow-up actions
## Evidence
```

## Definition of PASS

Chỉ PASS khi:

- reproduction hoặc equivalent evidence tồn tại;
- history đã được kiểm tra;
- origin được xác định hoặc ghi trung thực là unknown;
- root cause có evidence;
- solution map trực tiếp tới root cause;
- regression test chứng minh lỗi cũ fail trước và pass sau;
- report ghi task/commit liên quan nếu tìm thấy.


# Root-Cause Gate — bắt buộc trước khi sửa code

## Phân biệt các tầng nguyên nhân

Codex phải phân biệt ít nhất bốn tầng:

```text
Symptom
  ↓
Immediate / Proximate Cause
  ↓
Contributing Conditions
  ↓
Root Cause
  ↓
Systemic Escape Cause
```

### 1. Symptom

Hiện tượng người dùng hoặc hệ thống nhìn thấy.

Ví dụ:

```text
API gửi request hai lần.
```

### 2. Immediate / Proximate Cause

Nguyên nhân trực tiếp tạo ra symptom tại thời điểm lỗi.

Ví dụ:

```text
Retry callback chạy sau khi request đầu tiên đã thành công.
```

Đây chưa mặc định là root cause và chưa đủ để bắt đầu fix.

### 3. Contributing Conditions

Các điều kiện khiến immediate cause có thể xảy ra:

```text
- success state được cập nhật bất đồng bộ;
- timeout callback không bị hủy;
- request không có idempotency key;
- hai executor cùng sở hữu retry state.
```

### 4. Root Cause

Cơ chế nền tảng mà nếu loại bỏ thì bug và toàn bộ biến thể cùng lớp không còn xuất hiện.

Ví dụ:

```text
Retry state machine không có một nguồn trạng thái terminal duy nhất và không đảm
bảo atomic transition giữa success, timeout và retry.
```

### 5. Systemic Escape Cause

Lý do bug vượt qua requirement, review, test và release:

```text
- AC chỉ kiểm tra timeout nhưng không định nghĩa concurrent success/timeout;
- không có state-transition invariant;
- test dùng timing tuần tự nên không tạo race;
- review checklist không yêu cầu idempotency cho retry.
```

## Điều kiện được phép bắt đầu code

`root_cause_gate.status` chỉ được là `PASS` khi có đủ:

1. Symptom tái hiện được hoặc có evidence tương đương.
2. Immediate cause đã được chứng minh.
3. Các contributing conditions đã được liệt kê.
4. Root cause mô tả cơ chế tạo ra cả symptom hiện tại và các biến thể cùng lớp.
5. Có falsification test hoặc evidence để bác bỏ ít nhất một giả thuyết cạnh tranh.
6. Solution candidate map trực tiếp tới root cause.
7. Đã xác định systemic escape cause hoặc ghi rõ vì sao chưa thể xác định.
8. Đã kiểm tra history để phân biệt `introduced`, `exposed`, `regressed`.

Nếu chỉ tìm được immediate cause:

```yaml
root_cause_gate:
  status: UNKNOWN
  reason: Only proximate cause is proven.
  code_change_allowed: false
```

## Root-cause depth test

Trước khi chấp nhận một nguyên nhân là root cause, Codex phải trả lời:

```text
1. Nếu chỉ sửa nguyên nhân này, bug có thể xuất hiện lại qua đường khác không?
2. Nguyên nhân này giải thích được toàn bộ evidence hay chỉ một log hiện tại?
3. Nó có giải thích được vì sao bug chỉ xuất hiện trong một số điều kiện không?
4. Có thể tạo test khiến nguyên nhân này xuất hiện mà không cần symptom hiện tại không?
5. Loại bỏ nguyên nhân này có loại bỏ cả lớp lỗi tương tự không?
6. Có tầng kiểm soát nào đáng lẽ phải ngăn lỗi nhưng đã không ngăn không?
```

Nếu câu 1 là “có” hoặc câu 2 là “chỉ một log”, chưa được coi là root cause.

## Competing hypotheses

Không khóa vào giả thuyết đầu tiên.

Bắt buộc tạo tối thiểu hai giả thuyết khi evidence chưa duy nhất:

```yaml
hypotheses:
  - id: H1
    claim: Timeout callback không bị hủy.
    supporting_evidence: []
    contradicting_evidence: []
    falsification_test: ""
    status: confirmed | rejected | unresolved

  - id: H2
    claim: Hai worker cùng consume một event.
    supporting_evidence: []
    contradicting_evidence: []
    falsification_test: ""
    status: confirmed | rejected | unresolved
```

Không được chọn H1 chỉ vì nó là nguyên nhân đầu tiên nhìn thấy trong log.

## Fix validation matrix

Solution phải được kiểm tra ở ba cấp:

```yaml
validation:
  symptom_removed:
    status: PASS | FAIL
    evidence: []

  root_mechanism_removed:
    status: PASS | FAIL | UNKNOWN
    evidence: []

  sibling_failure_modes_prevented:
    status: PASS | FAIL | UNKNOWN
    evidence: []
```

Ví dụ, thêm `if already_success { return; }` có thể làm symptom biến mất nhưng không loại bỏ race trong state machine. Khi đó:

```yaml
symptom_removed: PASS
root_mechanism_removed: FAIL
sibling_failure_modes_prevented: UNKNOWN
final_status: FAIL
```

## Không chấp nhận các kiểu kết luận sau

```text
- Null pointer xảy ra vì biến null.
- Request trùng vì function được gọi hai lần.
- App crash vì lifecycle chưa initialize.
- Test fail vì expected khác actual.
- Race xảy ra vì hai thread chạy cùng lúc.
```

Đây chỉ là mô tả gần symptom. Codex phải tiếp tục hỏi:

```text
Tại sao contract cho phép trạng thái đó?
Ai sở hữu state?
Invariant nào bị vi phạm?
Transition nào không atomic?
Task hoặc design nào tạo behavior này?
Tại sao test và review không phát hiện?
```

## Output bổ sung trước khi code

`.my-ai/runs/<run_id>/root-cause-gate.yaml`

```yaml
status: PASS | FAIL | UNKNOWN | BLOCKED
code_change_allowed: false

symptom:
  statement: ""
  evidence_refs: []

proximate_cause:
  statement: ""
  evidence_refs: []

contributing_conditions: []

competing_hypotheses: []

root_cause:
  mechanism: ""
  affected_invariant: ""
  explains_all_evidence: false
  sibling_failure_modes: []
  evidence_refs: []

systemic_escape_cause:
  requirement_gap: []
  design_gap: []
  test_gap: []
  review_gap: []
  release_gap: []

history:
  introduced_by: null
  exposed_by: null
  regressed_by: null

solution_candidate:
  description: ""
  maps_to_root_cause: false
  symptom_only_patch: true

required_before_code: []
```

## Quy tắc dừng

Khi chưa tìm được root cause:

- được phép thêm instrumentation;
- được phép viết reproduction test;
- được phép chạy experiment hoặc bisect;
- được phép tạo diagnostic branch;
- không được commit production fix;
- không được cập nhật Jira thành fixed;
- không được tạo PR mang nghĩa hoàn tất;
- report phải là `ROOT_CAUSE_INVESTIGATION`, không phải `BUG_FIX`.


## Scope handoff after root cause

Sau khi root cause đạt PASS, Codex chưa mặc định được phép sửa.

Phải gọi `scope-escalation-and-decomposition`.

Nếu solution đúng cần thay đổi cross-cutting hoặc architectural:

- dừng code production;
- tạo scope escalation evidence;
- raise ticket cha;
- tách subtasks;
- link bug ban đầu;
- chỉ làm mitigation nhỏ nếu được phê duyệt.
