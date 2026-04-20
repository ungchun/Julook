---
참조:
  - docs/tdd/phases.md
  - docs/git/push-check.md
피참조:
  - AGENTS.md
  - docs/workflow/feature.md
  - docs/workflow/refactor.md
  - docs/workflow/bugfix.md
  - docs/git/push-check.md
검증:
  - scripts/pre-push.sh
---

# Git 커밋 규칙

## 메시지 형식

```
{이모지} [{type}] {한 줄 요약}
```

| 이모지 | type | 용도 |
|--------|------|------|
| ✨ | feat | 새로운 기능 |
| 🐛 | fix | 버그 수정 |
| ♻️ | refactor | 리팩토링 |
| 📝 | docs | 문서 |
| 🎨 | style | UI/스타일 변경 |
| 🚀 | deploy | 배포 |
| 🙈 | chore | 기타 |

## 한 커밋 = 한 사이클

Phase 0~5의 한 바퀴가 끝난 시점에 커밋. 여러 사이클을 섞지 않는다.

**왜**: 커밋 단위가 사이클과 일치해야 나중에 `git bisect`로 버그 원인을 빠르게 찾을 수 있다.

## 분리 원칙

- 리팩토링과 기능 추가는 분리 커밋. 먼저 refactor, 그 위에 feat.
- 테스트 추가는 그 테스트가 검증하는 변경과 **같은 커밋**에 둔다 (Phase 1+2+3을 한 커밋으로).

## 브랜치 전략

| 브랜치 | 용도 |
|--------|------|
| `main` | 프로덕션 |
| `develop` | 개발 통합 |
| `feature/*` | 기능 개발 |
| `hotfix/*` | 긴급 수정 |

## 금지

- 테스트 없이 프로덕션 코드만 포함된 커밋 ([../tdd/enforcement.md](../tdd/enforcement.md) 위반).
- `--no-verify` 로 훅 우회 (사용자가 명시적으로 요청한 경우 제외).

## 푸시 차단

커밋이 이 규칙을 따르지 않으면 [push-check](./push-check.md) 단계에서 자동 차단된다.
