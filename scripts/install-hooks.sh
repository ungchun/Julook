#!/usr/bin/env bash
# scripts/install-hooks.sh
# 로컬 저장소에 pre-push 훅을 연결한다. 저장소 clone 직후 1회 실행.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

git config core.hooksPath scripts/git-hooks
chmod +x scripts/pre-push.sh scripts/git-hooks/pre-push

echo "✓ core.hooksPath = scripts/git-hooks 설정됨."
echo "✓ pre-push 훅 실행권한 부여됨."
echo ""
echo "이제 git push 시 scripts/pre-push.sh 가 자동 실행됩니다."
echo "비상 우회: SKIP_ALL=1 git push"
