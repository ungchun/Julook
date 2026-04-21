// 한글 하드코딩 탐지 스크립트 테스트용 샘플 파일
// 이 파일은 실제 빌드 타깃에 포함되지 않음 (scripts/fixtures/ 경로)

import Foundation

struct HardcodedKoreanSample {
    // case A — 문자열 리터럴에 한글 (탐지되어야 함)
    let title: String = "막걸리 추천"

    // case B — 단순 함수 호출 인자 안의 한글 리터럴 (탐지되어야 함)
    func greeting() -> String {
        return String(format: "%@님 환영합니다", "홍길동")
    }

    // case C — 주석 속 한글은 무시되어야 함 (탐지되면 안 됨)
    // 이 줄은 주석이므로 스캐너가 건너뛰어야 한다
    let englishOnly: String = "refresh"

    // case D — 코드 + 인라인 주석 순서 (앞 부분의 리터럴은 한글 없음)
    let code: String = "ok" // 이 뒤의 한글은 주석이므로 무시되어야 함

    // case E — swiftgen-ignore 마커 (탐지되면 안 됨)
    func debugLog() {
        print("디버그: 요청 시작") // swiftgen-ignore
    }

    // case F — 영문 리터럴만 (탐지되면 안 됨)
    let url: String = "https://example.com/api"
}
