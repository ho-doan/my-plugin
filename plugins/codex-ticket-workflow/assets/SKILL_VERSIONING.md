# Skill Versioning Policy

## Định danh

Mỗi skill được định danh theo dạng:

```text
<skill-name>@<semver>
```

Ví dụ:

```text
browser-operations@1.0.0
bug-history-root-cause@1.0.0
scope-escalation-and-decomposition@1.0.0
```

Workflow không được gọi skill chỉ bằng tên khi chạy production. Phải resolve qua
`skills-lock.yaml` để lấy version chính xác.

## Semantic Versioning

### PATCH — `1.0.0 → 1.0.1`

Dùng khi:

- sửa câu chữ hoặc typo;
- làm rõ instruction nhưng không thay contract;
- thêm validation không đổi output schema;
- sửa bug nội bộ nhưng giữ nguyên behavior đã cam kết.

PATCH không được thay đổi:

- required inputs;
- output fields bắt buộc;
- status semantics;
- approval gates;
- side effects;
- Browser MCP write behavior.

### MINOR — `1.0.0 → 1.1.0`

Dùng khi:

- thêm capability tương thích ngược;
- thêm optional field;
- thêm optional branch;
- thêm evidence mới nhưng không phá consumer cũ.

Workflow cũ vẫn phải chạy được mà không cần sửa.

### MAJOR — `1.x.x → 2.0.0`

Dùng khi:

- đổi input/output contract;
- đổi gate hoặc status semantics;
- thay behavior write lên Jira/Git/Browser;
- đổi quyền hoặc approval requirement;
- xóa field/branch;
- thay đổi khiến workflow hoặc chatbot cũ không còn tương thích.

## Quy tắc pin version

Workflow production phải pin exact version:

```yaml
skills:
  browser_operations: browser-operations@1.0.0
  bug_rca: bug-history-root-cause@1.0.0
```

Không dùng:

```yaml
browser_operations: latest
browser_operations: ^1.0.0
browser_operations: 1.x
```

cho production run.

Range chỉ được dùng trong môi trường test hoặc compatibility check.

## Upgrade flow

```text
Current locked version
  → install candidate version
  → compatibility validation
  → dry-run / replay historical evidence
  → benchmark comparison
  → approval
  → update skills-lock.yaml
  → controlled rollout
```

Không ghi đè version cũ. Version mới phải nằm song song hoặc có artifact riêng.

## Rollback flow

Nếu `browser-operations@1.0.1` không đạt:

```yaml
resolved_skills:
  browser-operations:
    version: 1.0.0
    id: browser-operations@1.0.0
```

Sau đó:

1. tạo lock file revision mới;
2. giữ evidence của lần rollback;
3. chạy lại readiness;
4. replay test hoặc benchmark;
5. chỉ resume workflow khi version cũ PASS.

Rollback không được sửa trực tiếp nội dung của `1.0.1` rồi tiếp tục gọi cùng version.
Một version đã publish phải bất biến.

## Immutability

Artifact của một version đã publish là immutable.

Không được:

```text
sửa nội dung browser-operations@1.0.0 nhưng vẫn giữ version 1.0.0
```

Nếu nội dung đổi, phải tạo version mới.

## Run evidence

Mỗi run phải ghi:

```yaml
skill_resolution:
  browser_operations:
    requested: browser-operations@1.0.0
    resolved: browser-operations@1.0.0
    manifest_version: 1.0.0
    lock_file_revision: ""
    content_digest: ""
```

Nhờ đó report có thể trả lời chính xác:

- skill nào đã chạy;
- version nào;
- nội dung nào;
- lock revision nào;
- rollback về version nào.

## Candidate lifecycle

```text
DRAFT
  → TESTING
  → CANDIDATE
  → APPROVED
  → ACTIVE
  → DEPRECATED
  → RETIRED
```

Version `CANDIDATE` không được dùng cho production nếu chưa có explicit approval.

## Recommended directory layout

```text
skills/
  browser-operations/
    1.0.0/
      SKILL.md
    1.0.1/
      SKILL.md
```

Trong giai đoạn POC hiện tại vẫn có thể giữ:

```text
skills/browser-operations/SKILL.md
```

nhưng `skills-manifest.yaml` và `skills-lock.yaml` phải pin version. Trước khi phát
hành nhiều version song song, nên chuyển sang layout theo version directory.
