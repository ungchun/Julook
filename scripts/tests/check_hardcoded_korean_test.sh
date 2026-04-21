#!/usr/bin/env bash
# scripts/tests/check_hardcoded_korean_test.sh
# scripts/check-hardcoded-korean.sh 의 동작을 검증한다.
# bats 미설치 환경을 가정한 POSIX-친화 bash 테스트 러너.

set -uo pipefail

ROOT="$(git rev-parse --show-toplevel)"
DETECTOR="$ROOT/scripts/check-hardcoded-korean.sh"

RED='\033[0;31m'; GRN='\033[0;32m'; NC='\033[0m'
PASS=0
FAIL=0

make_tmp() {
  mktemp -d "${TMPDIR:-/tmp}/julook_detector_test.XXXXXX"
}

run_detector() {
  # $1 = target dir. stdout/stderr 버리고 종료 코드만 echo.
  local ec=0
  bash "$DETECTOR" "$1" >/dev/null 2>&1 || ec=$?
  echo "$ec"
}

pass() {
  echo -e "  ${GRN}✓${NC} $1"
  PASS=$((PASS + 1))
}

fail() {
  echo -e "  ${RED}✗${NC} $1 — $2"
  FAIL=$((FAIL + 1))
}

assert_exit() {
  local name="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    pass "$name"
  else
    fail "$name" "expected exit=$expected, got $actual"
  fi
}

# ── test 1 ─────────────────────────────────────────────────
echo "▶ test_detector_exits1_whenKoreanLiteralExists"
t1=$(make_tmp)
mkdir -p "$t1/Projects/Foo/Sources"
cat > "$t1/Projects/Foo/Sources/Sample.swift" <<'EOF'
import Foundation
struct S { let title = "막걸리 추천" }
EOF
ec=$(run_detector "$t1/Projects")
assert_exit "test_detector_exits1_whenKoreanLiteralExists" 1 "$ec"
rm -rf "$t1"

# ── test 2 ─────────────────────────────────────────────────
echo "▶ test_detector_exits0_whenNoKoreanLiteral"
t2=$(make_tmp)
mkdir -p "$t2/Projects/Foo/Sources"
cat > "$t2/Projects/Foo/Sources/Sample.swift" <<'EOF'
import Foundation
struct S { let title = "Makgeolli recommendations" }
EOF
ec=$(run_detector "$t2/Projects")
assert_exit "test_detector_exits0_whenNoKoreanLiteral" 0 "$ec"
rm -rf "$t2"

# ── test 3 ─────────────────────────────────────────────────
echo "▶ test_detector_ignoresComments"
t3=$(make_tmp)
mkdir -p "$t3/Projects/Foo/Sources"
cat > "$t3/Projects/Foo/Sources/Sample.swift" <<'EOF'
// 이 주석은 한글이지만 무시되어야 한다
import Foundation
struct S {
    let x = "ok" // 주석 속 한글도 무시되어야 한다
}
EOF
ec=$(run_detector "$t3/Projects")
assert_exit "test_detector_ignoresComments" 0 "$ec"
rm -rf "$t3"

# ── test 4 ─────────────────────────────────────────────────
echo "▶ test_detector_respectsSwiftgenIgnoreMarker"
t4=$(make_tmp)
mkdir -p "$t4/Projects/Foo/Sources"
cat > "$t4/Projects/Foo/Sources/Sample.swift" <<'EOF'
import Foundation
func debug() {
    print("디버그: 요청 시작") // swiftgen-ignore
}
EOF
ec=$(run_detector "$t4/Projects")
assert_exit "test_detector_respectsSwiftgenIgnoreMarker" 0 "$ec"
rm -rf "$t4"

# ── test 5 ─────────────────────────────────────────────────
echo "▶ test_detector_excludesGeneratedAndTests"
t5=$(make_tmp)
mkdir -p "$t5/Projects/Foo/Sources/Generated" "$t5/Projects/Foo/Tests/Sources"
cat > "$t5/Projects/Foo/Sources/Generated/Strings.swift" <<'EOF'
let generated = "자동 생성된 문자열"
EOF
cat > "$t5/Projects/Foo/Tests/Sources/Bar.swift" <<'EOF'
let testStr = "테스트용 문자열"
EOF
ec=$(run_detector "$t5/Projects")
assert_exit "test_detector_excludesGeneratedAndTests" 0 "$ec"
rm -rf "$t5"

# ── summary ─────────────────────────────────────────────────
echo
echo "Passed: $PASS, Failed: $FAIL"
if [[ "$FAIL" != "0" ]]; then
  exit 1
fi
