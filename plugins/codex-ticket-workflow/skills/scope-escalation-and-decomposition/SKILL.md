---
name: scope-escalation-and-decomposition
description: Phát hiện bug fix vượt phạm vi, dừng patch lớn, raise ticket cha và tách subtask có dependency, acceptance criteria và ownership rõ ràng.
version: 1.0.0
---

# Scope Escalation and Decomposition

## Mục tiêu

Không cho Codex biến một bug nhỏ thành refactor hoặc sửa diện rộng trong cùng ticket.

Khi root cause cho thấy solution đúng cần thay đổi lớn hơn phạm vi ban đầu, Codex phải:

1. dừng production fix diện rộng;
2. đánh giá scope impact;
3. raise/escalate thành ticket riêng;
4. tách subtask theo workstream;
5. chỉ giữ mitigation tối thiểu trong bug hiện tại nếu được phép;
6. liên kết toàn bộ ticket, evidence và dependency.

## Trigger bắt buộc

Kích hoạt skill khi có một trong các điều kiện:

- thay đổi từ 3 module/domain trở lên;
- thay public API hoặc persisted schema;
- thay state machine trung tâm;
- cần migration dữ liệu;
- ảnh hưởng backward compatibility;
- cần refactor kiến trúc;
- cần nhiều repository/service;
- cần thay CI/CD, infra hoặc deployment;
- cần nhiều owner/team;
- không thể hoàn tất và verify an toàn trong scope hiện tại;
- root cause nằm ngoài component được giao;
- bug nhỏ nhưng solution đúng cần sửa cả lớp lỗi hệ thống;
- estimate vượt policy của ticket hiện tại;
- có rủi ro rollout hoặc rollback đáng kể.

Các ngưỡng số lượng chỉ là trigger mặc định. Contract dự án có thể siết chặt hơn.

## Phân loại thay đổi

```yaml
scope_class:
  type: in_scope | adjacent_scope | cross_cutting | architectural
  reason: ""
```

### in_scope

- patch nhỏ;
- một responsibility;
- không đổi contract công khai;
- regression test bounded.

### adjacent_scope

- chạm module liên quan nhưng vẫn cùng owner và contract;
- cần ticket/subtask bổ sung nếu không thể verify chung.

### cross_cutting

- nhiều module/service/team;
- cần ticket cha và subtasks.

### architectural

- thay state ownership, data model, protocol hoặc kiến trúc;
- phải có proposal/design review trước implementation.

## Quy tắc dừng

Khi `cross_cutting` hoặc `architectural`:

```yaml
production_fix_allowed: false
large_patch_allowed: false
ticket_escalation_required: true
```

Codex không được:

- sửa hàng loạt file để “tiện fix luôn”;
- mở rộng AC ngầm;
- gom refactor và bug fix vào cùng commit;
- tạo một PR khổng lồ dưới bug ticket nhỏ;
- đổi public contract mà không có ticket/approval;
- báo bug đã fix hoàn toàn khi mới mitigation.

## Ticket escalation

Ticket mới phải có:

```markdown
# Problem
# Root cause
# Why current ticket is insufficient
# Impacted systems
# Proposed target state
# Workstreams
# Dependencies
# Risks
# Migration / rollout
# Rollback
# Acceptance criteria
# Evidence
# Linked originating bug
```

Ticket phải link ngược về bug ban đầu và ghi rõ:

```text
originating_bug
root_cause_evidence
temporary_mitigation
remaining_systemic_fix
```

## Subtask decomposition

Tách theo responsibility, không tách tùy tiện theo file.

Ví dụ:

```yaml
subtasks:
  - title: Define atomic retry state contract
    owner_role: backend
    dependency: []
    acceptance_criteria:
      - terminal transitions are explicit
      - duplicate completion is impossible

  - title: Implement retry state machine
    owner_role: backend
    dependency:
      - Define atomic retry state contract

  - title: Add concurrency regression suite
    owner_role: qa_or_backend
    dependency:
      - Implement retry state machine

  - title: Add migration and compatibility handling
    owner_role: platform
    dependency:
      - Define atomic retry state contract

  - title: Rollout and observability
    owner_role: devops
    dependency:
      - Add concurrency regression suite
```

Mỗi subtask phải có:

- objective;
- bounded scope;
- acceptance criteria;
- owner role;
- dependencies;
- verification;
- evidence output;
- rollback nếu cần.

## Mitigation trong ticket bug hiện tại

Chỉ được làm mitigation khi:

- giảm rủi ro ngay;
- thay đổi nhỏ và rollback được;
- không che mất root cause;
- có approval;
- tạo follow-up ticket cho systemic fix;
- report ghi rõ đây không phải final solution.

```yaml
mitigation:
  allowed: true
  temporary: true
  expires_or_removal_condition: ""
  linked_systemic_ticket: ""
  residual_risks: []
```

Nếu mitigation không an toàn hoặc dễ trở thành permanent workaround:

```yaml
mitigation:
  allowed: false
```

## Browser MCP actions

Khi được phép ghi:

1. tạo ticket cha hoặc technical-debt/root-cause ticket;
2. tạo các subtask;
3. link originating bug;
4. thêm dependency/blocking links;
5. comment vào bug hiện tại:
   - root cause;
   - vì sao scope vượt ticket;
   - mitigation hiện tại nếu có;
   - ticket/subtask đã tạo;
6. không tự close bug nếu systemic fix chưa hoàn tất, trừ policy cho phép trạng thái mitigated.

## Output

`.my-ai/runs/<run_id>/scope-escalation.yaml`

```yaml
status: PASS | FAIL | UNKNOWN | BLOCKED
scope_class:
  type: in_scope | adjacent_scope | cross_cutting | architectural
  reason: ""

current_ticket:
  sufficient: false
  allowed_changes: []
  forbidden_changes: []

escalation:
  required: true
  parent_ticket_title: ""
  parent_ticket_body_ref: ""
  linked_originating_bug: ""
  approval_required: true

subtasks: []

mitigation:
  allowed: false
  temporary: true
  linked_systemic_ticket: null
  residual_risks: []

browser_actions_required: []
evidence_refs: []
```

## Definition of PASS

PASS khi:

- scope đã được phân loại;
- patch lớn đã bị chặn;
- ticket cha/subtask có AC và dependency;
- originating bug được liên kết;
- mitigation và systemic fix được phân biệt;
- owner/review gate đã được xác định.


# Mandatory Block-and-Stop Policy

## Nguyên tắc

Khi phạm vi sửa là `cross_cutting` hoặc `architectural`, Codex phải:

1. xác định cụ thể các service/module/repository/team bị ảnh hưởng;
2. tạo scope escalation report;
3. đánh run và work item thành `BLOCKED`;
4. comment Jira nếu có quyền;
5. dừng toàn bộ implementation;
6. chờ explicit unblock decision trước khi chạy tiếp.

Codex không được tự coi việc tạo ticket/subtask là quyền tiếp tục implementation.

## Impact inventory bắt buộc

Report không được ghi chung chung như “ảnh hưởng nhiều service”.

Phải liệt kê cụ thể:

```yaml
impacted_components:
  - name: workflow-api
    type: service
    repository: backend/workflow-api
    symbols:
      - RetryCoordinator
      - WorkflowRunState
    reason: Owns retry state transition
    required_change: Introduce atomic terminal transition
    owner_role: backend
    risk: high

  - name: notification-worker
    type: service
    repository: backend/notification-worker
    symbols:
      - DeliveryRetryConsumer
    reason: Consumes retry events using duplicated local state
    required_change: Use centralized run state contract
    owner_role: platform
    risk: medium

  - name: postgres-workflow-schema
    type: datastore
    repository: infrastructure/database
    symbols:
      - workflow_runs.status
      - workflow_run_version
    reason: Atomic transition requires optimistic versioning
    required_change: Add version or compare-and-set support
    owner_role: database
    risk: high
```

Với mỗi thành phần phải có:

- tên cụ thể;
- loại: module/service/repository/database/client/infra;
- symbol hoặc contract liên quan;
- lý do bị ảnh hưởng;
- thay đổi cần thiết;
- owner/team dự kiến;
- dependency;
- mức rủi ro;
- evidence reference.

## Block decision

```yaml
block_decision:
  status: BLOCKED
  reason_code: SCOPE_EXCEEDS_CURRENT_TICKET
  implementation_stopped: true
  browser_comment_required: true
  unblock_required: true
  unblock_authority:
    - product_owner
    - tech_lead
    - assigned_reviewer
```

## Jira comment template

```markdown
### BLOCKED — Fix vượt phạm vi bug hiện tại

Root cause đã được xác định, nhưng solution đúng cần thay đổi phạm vi lớn hơn ticket này.

**Các thành phần bị ảnh hưởng**
- `<service/module 1>`: `<lý do và thay đổi cần thiết>`
- `<service/module 2>`: `<lý do và thay đổi cần thiết>`
- `<database/API/infra>`: `<lý do và thay đổi cần thiết>`

**Vì sao không tiếp tục trong ticket hiện tại**
- `<scope/contract/migration/team dependency>`
- `<rủi ro nếu sửa gộp>`

**Trạng thái**
- Implementation: STOPPED
- Ticket: BLOCKED
- Production fix: NOT STARTED hoặc STOPPED
- Mitigation: `<none hoặc mô tả rõ>`

**Đề xuất**
- Tạo ticket cha/systemic fix: `<title đề xuất>`
- Tách subtasks: `<danh sách>`
- Cần quyết định từ: `<PO/Tech Lead/Reviewer>`

Codex sẽ không tiếp tục cho đến khi có explicit unblock decision.
```

## Hard stop output

Sau khi đánh blocked, kết quả cuối của run phải là:

```json
{
  "status": "BLOCKED",
  "reason_code": "SCOPE_EXCEEDS_CURRENT_TICKET",
  "implementation_stopped": true,
  "jira_comment_created": true,
  "waiting_for_unblock": true,
  "next_action": "Await explicit unblock decision"
}
```

Không được gọi tiếp:

- `code-execution`;
- production verification;
- push;
- PR creation;
- status transition sang In Review/Done;
- deployment.

Chỉ được phép hoàn tất:

- evidence;
- report;
- Jira comment;
- proposed ticket/subtask drafts.

## Unblock contract

Chỉ được tiếp tục khi có evidence explicit:

```yaml
unblock:
  approved_by: ""
  authority: product_owner | tech_lead | assigned_reviewer
  decision:
    type: proceed_in_current_ticket | create_new_parent | mitigation_only | rejected
  approved_scope: []
  linked_tickets: []
  constraints: []
  evidence_ref: ""
```

Nếu chỉ có comment mơ hồ như “ok làm đi” nhưng không xác định approved scope, vẫn là `BLOCKED`.

## Resume behavior

Khi được unblock:

1. tạo run mới hoặc resume run với reference tới blocked run;
2. đọc lại quyết định;
3. xác nhận approved scope;
4. kiểm tra ticket/subtask đã tồn tại;
5. chạy lại readiness và scope gate;
6. chỉ thực hiện phần nằm trong approved scope.
