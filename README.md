# Codex Ticket Workflow Plugin

Plugin cá nhân dùng trong mọi project, chạy trực tiếp bằng Codex và không phụ
thuộc ai-chatbot.

## Cài đặt

```bash
unzip codex-ticket-workflow-plugin.zip
cd codex-ticket-workflow-plugin
./scripts/install-personal.sh
```

Sau đó restart Codex hoặc ChatGPT desktop, mở Plugins và cài
`codex-ticket-workflow` từ marketplace cá nhân.

Có thể đăng ký marketplace bằng CLI:

```bash
codex plugin marketplace add /absolute/path/to/codex-ticket-workflow-plugin
```

## Kiểm tra

```bash
./scripts/verify.sh
```

Hoặc sau khi cài:

```bash
./scripts/verify.sh ~/.codex/plugins/codex-ticket-workflow
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
