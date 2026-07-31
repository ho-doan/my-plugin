# Codex Ticket Workflow Plugin

Plugin cá nhân dùng trong mọi project, chạy trực tiếp bằng Codex.

## Cài đặt từ GitHub Release

Repository:

```text
https://github.com/ho-doan/my-plugin
```

### 1. Thêm marketplace

Pin theo release tag để có thể rollback:

```bash
codex plugin marketplace add ho-doan/my-plugin --ref v1.0.1
```

Kết quả mong đợi:

```text
Added marketplace `my-plugins` from https://github.com/ho-doan/my-plugin.git#v1.0.1.
```

### 2. Kiểm tra marketplace

```bash
codex plugin marketplace list --json
```

Phải thấy marketplace:

```text
my-plugins
```

### 3. Xem plugin có thể cài

`marketplace add` chỉ đăng ký nguồn plugin, chưa cài plugin.

```bash
codex plugin list \
  --marketplace my-plugins \
  --available \
  --json
```

Phải thấy:

```text
codex-ticket-workflow@my-plugins
```

### 4. Cài plugin

```bash
codex plugin add codex-ticket-workflow@my-plugins --json
```

### 5. Kiểm tra plugin đã cài

```bash
codex plugin list --json
```

Danh sách installed phải chứa:

```text
codex-ticket-workflow@my-plugins
```

### 6. Mở phiên Codex mới

Đóng phiên Codex hiện tại rồi mở lại trong project cần làm việc:

```bash
cd /path/to/project
codex
```

Sau đó chạy:

```text
implement ticket https://company.atlassian.net/browse/TASK-A
```

Hoặc gọi skill trực tiếp:

```text
Use $ticket-workflow-orchestrator to implement ticket https://company.atlassian.net/browse/TASK-A
```

## Cập nhật marketplace

Khi có release mới:

```bash
codex plugin marketplace upgrade my-plugins --json
```

Nếu marketplace đang pin một tag cũ và cần chuyển sang tag mới, xóa rồi thêm lại:

```bash
codex plugin marketplace remove my-plugins

codex plugin marketplace add \
  ho-doan/my-plugin \
  --ref v1.0.2
```

Sau đó cài hoặc cài lại plugin:

```bash
codex plugin add codex-ticket-workflow@my-plugins --json
```

## Rollback release

Ví dụ rollback từ `v1.0.2` về `v1.0.1`:

```bash
codex plugin remove codex-ticket-workflow@my-plugins

codex plugin marketplace remove my-plugins

codex plugin marketplace add \
  ho-doan/my-plugin \
  --ref v1.0.1

codex plugin add codex-ticket-workflow@my-plugins --json
```

Kiểm tra:

```bash
codex plugin list --json
```

## Troubleshooting

### Marketplace đã thêm nhưng `plugin list --json` trống

Đây là bình thường nếu plugin chưa được cài.

Xem plugin khả dụng:

```bash
codex plugin list \
  --marketplace my-plugins \
  --available \
  --json
```

Sau đó cài:

```bash
codex plugin add codex-ticket-workflow@my-plugins --json
```

### Plugin không xuất hiện trong danh sách available

Kiểm tra marketplace:

```bash
codex plugin marketplace list --json
```

Refresh marketplace:

```bash
codex plugin marketplace upgrade my-plugins --json
```

Sau đó kiểm tra lại:

```bash
codex plugin list \
  --marketplace my-plugins \
  --available \
  --json
```

## Sử dụng trong bất kỳ project nào

Mở Codex tại repository rồi nhập:

```text
implement ticket https://company.atlassian.net/browse/TASK-A
```

Codex sẽ tự kích hoạt `ticket-workflow-orchestrator`, đọc flow versioned trong
plugin, resolve skill và lưu evidence vào:

```text
<repo>/.codex-runs/<run-id>/
```

Repository không cần chứa `codex-flows`, skill bundle hoặc `.my-ai`.

## Rollback plugin

Installer tự backup version đang cài trước khi ghi đè:

```bash
./scripts/rollback-personal.sh
```

Plugin version và skill version là hai lớp riêng:

- `.codex-plugin/plugin.json`: version gói plugin.
- `assets/skills-lock.yaml`: exact version của từng skill.
- `assets/flows/*.yaml`: exact version và thứ tự step của từng flow.

## Cập nhật

Tạo plugin version mới, ví dụ `1.0.1`, cài bằng installer và chạy lại benchmark.
Nếu chưa đạt, dùng rollback script để quay về bản backup trước.

## Cấu trúc

```text
.codex-plugin/plugin.json
skills/
  ticket-workflow-orchestrator/
  work-intake/
  readiness-assessment/
  implementation-traceability/
  bug-history-root-cause/
  scope-escalation-and-decomposition/
  task-planning/
  code-execution/
  verification/
  browser-operations/
  delivery-report/
  workflow-retrospective/
assets/
  flows/
  skills-manifest.yaml
  skills-lock.yaml
  SKILL_VERSIONING.md
```
