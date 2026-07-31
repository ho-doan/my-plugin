---
name: implementation-traceability
description: Xác định và chứng minh nguồn gốc của function, logic, contract và design decision trước khi code feature mới.
version: 1.0.0
---

# Implementation Traceability

## Mục tiêu

Không cho Codex tự nghĩ ra function hoặc business logic chỉ từ tên task.

Mỗi function, branch logic, state transition, validation, API call hoặc data mapping mới phải trả lời được:

1. Nó phục vụ acceptance criterion nào?
2. Nó xuất phát từ requirement, comment, design, API contract hay code pattern nào?
3. Tại sao cần tạo mới thay vì tái sử dụng logic hiện có?
4. Input/output và invariant dựa trên đâu?
5. Logic này ảnh hưởng tới module và flow nào?
6. Test nào chứng minh logic đúng?

## Nguồn được phép dùng

Theo thứ tự ưu tiên:

1. Acceptance criteria đã được xác nhận.
2. Requirement hoặc quyết định mới nhất trong tracker comments.
3. API/schema/protocol contract.
4. UI/UX design và expected interaction.
5. Existing domain model hoặc state machine.
6. Existing implementation pattern trong cùng repository.
7. Test hiện có mô tả behavior.
8. Commit/PR trước đó có decision rõ ràng.
9. Tài liệu framework chính thức.
10. Proposal mới được ghi rõ và yêu cầu approval.

Không được biến suy đoán thành requirement.

## Quy trình trước khi code

### 1. Requirement-to-code map

Tạo mapping:

```yaml
- requirement_id: AC-01
  behavior: Người dùng có thể hủy workflow đang chạy.
  source_refs:
    - JIRA-123.description#acceptance-criteria
    - JIRA-123.comment-456
  affected_flow:
    - workflow_run
  planned_symbols:
    - WorkflowRunner::cancel
    - RunState::Cancelling
  invariants:
    - completed run cannot be cancelled
    - cancellation must be idempotent
  tests:
    - cancel_running_workflow
    - cancel_completed_workflow_is_rejected
```

### 2. Existing-code discovery

Trước khi tạo function mới, phải tìm:

- symbol có tên hoặc responsibility tương tự;
- trait/interface/domain service hiện có;
- state machine;
- validation rule;
- adapter;
- test;
- error type;
- event;
- config/benchmark contract.

Phải ghi lại các command/search đã dùng.

### 3. Function justification

Mỗi symbol mới hoặc thay đổi đáng kể phải có:

```yaml
symbol: WorkflowRunner::cancel
kind: function
why_needed: Không có entry point thực hiện transition sang cancelling.
derived_from:
  - AC-01
  - workflow state machine
reuses:
  - RunRepository
  - CancellationToken
does_not_reuse:
  candidate: WorkflowRunner::stop
  reason: stop chỉ dùng cho shutdown process, không bảo toàn run state
inputs:
  - run_id
outputs:
  - Result<CancelOutcome, WorkflowError>
preconditions:
  - run exists
postconditions:
  - run is cancelled or already terminal
side_effects:
  - cancellation event emitted
risks:
  - race with completion
```

### 4. Logic table

Với if/else, match, switch hoặc state transition mới, phải tạo decision table trước:

```text
Current state | Cancel requested | Result
Running       | yes              | transition to Cancelling
Cancelling    | yes              | idempotent success
Completed     | yes              | reject
Failed        | yes              | no-op or reject according to contract
```

### 5. Approval gate

Trạng thái là `UNKNOWN` hoặc `BLOCKED` nếu:

- không xác định được source của logic;
- AC mâu thuẫn với code contract;
- cần thay đổi public API nhưng task không nói;
- phải tạo business rule mới;
- existing implementation có nhiều pattern mâu thuẫn;
- không xác định được invariant.

Không được code cho tới khi traceability đạt PASS.

## Output

`.my-ai/runs/<run_id>/implementation-traceability.yaml`

```yaml
status: PASS | FAIL | UNKNOWN | BLOCKED
requirements: []
existing_symbols_inspected: []
planned_symbols: []
decision_tables: []
unresolved_design_decisions: []
evidence_refs: []
```

## Definition of PASS

PASS chỉ khi:

- mọi behavior mới map tới source;
- mọi symbol mới có justification;
- input/output/invariant đã xác định;
- reuse decision đã được ghi;
- test mapping tồn tại;
- không còn business rule do Codex tự đặt.
