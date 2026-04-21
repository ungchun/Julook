#!/usr/bin/env bash
# scripts/check-hardcoded-korean.sh
# Swift 소스의 "주석이 아닌 문자열 리터럴에 한글이 들어간 라인"을 탐지한다.
# 근거: docs/coding/localization.md

set -uo pipefail

readonly KOREAN_RANGE='[\x{AC00}-\x{D7A3}\x{3131}-\x{314E}]'

usage() {
  cat <<EOF
Usage: $(basename "$0") [target_dir]

Swift 소스에서 주석이 아닌 문자열 리터럴에 한글이 포함된 라인을 탐지한다.
기본 target_dir: Projects

제외 경로: **/Generated/**, **/Tests/**, **/.build/**, scripts/fixtures/**
라인 제외 마커: // swiftgen-ignore (디버그 로그 전용 탈출구)

Exits:
  0 — 위반 없음
  1 — 1건 이상 탐지 (stderr에 "파일:라인:내용" 출력)
  2 — ripgrep 미설치 또는 target_dir 부재

옵션:
  -h, --help   이 도움말 출력
EOF
}

require_ripgrep() {
  if ! command -v rg >/dev/null 2>&1; then
    echo "error: ripgrep (rg) is required but not installed" >&2
    echo "hint: brew install ripgrep" >&2
    exit 2
  fi
}

require_target() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo "error: target directory not found: $dir" >&2
    exit 2
  fi
}

# 한글이 포함된 Swift 소스 라인을 glob 제외 규칙에 따라 수집.
collect_candidates() {
  local target="$1"
  rg -n --pcre2 \
    "$KOREAN_RANGE" \
    --glob '**/Sources/**/*.swift' \
    --glob '!**/Generated/**' \
    --glob '!**/Tests/**' \
    --glob '!**/.build/**' \
    --glob '!scripts/fixtures/**' \
    "$target" 2>/dev/null || true
}

# 후보 라인 중 "주석이 아닌 문자열 리터럴 안의 한글"만 추려낸다.
# - // swiftgen-ignore 마커가 있으면 스킵
# - 문자열 상태를 추적하며 // 이전까지를 effective code 로 간주
# - effective code 안의 "..." 리터럴만 한글 포함 여부를 검사
filter_real_violations() {
  perl -CSD -ne '
    use strict; use warnings;
    chomp;
    next unless /^(.+?):(\d+):(.*)$/;
    my ($file, $ln, $content) = ($1, $2, $3);

    next if $content =~ m{//\s*swiftgen-ignore};

    my @c = split //, $content;
    my $code = "";
    my $in_str = 0;
    my $prev = "";
    for (my $i = 0; $i < @c; $i++) {
        my $ch = $c[$i];
        if (!$in_str && $ch eq "/" && defined $c[$i+1] && $c[$i+1] eq "/") {
            last;
        }
        if ($ch eq q{"} && $prev ne "\\") {
            $in_str = !$in_str;
        }
        $code .= $ch;
        $prev = $ch;
    }

    while ($code =~ /"([^"]*)"/g) {
        my $lit = $1;
        if ($lit =~ /[\x{AC00}-\x{D7A3}\x{3131}-\x{314E}]/) {
            print "$file:$ln:$content\n";
            last;
        }
    }
  '
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  require_ripgrep

  local target="${1:-Projects}"
  require_target "$target"

  local candidates
  candidates="$(collect_candidates "$target")"
  if [[ -z "$candidates" ]]; then
    exit 0
  fi

  local violations
  violations="$(printf '%s\n' "$candidates" | filter_real_violations)"
  if [[ -z "$violations" ]]; then
    exit 0
  fi

  echo "$violations" >&2
  exit 1
}

main "$@"
