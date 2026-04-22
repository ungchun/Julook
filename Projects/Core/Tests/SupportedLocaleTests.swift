import XCTest

@testable import Core

final class SupportedLocaleTests: XCTestCase {

  // MARK: - rawValue

  func test_rawValue_matchesString() {
    XCTAssertEqual(SupportedLocale.ko.rawValue, "ko")
    XCTAssertEqual(SupportedLocale.en.rawValue, "en")
  }

  // MARK: - from(languageCode:)

  func test_fromLanguageCode_returnsKoForKorean() {
    XCTAssertEqual(SupportedLocale.from(languageCode: "ko"), .ko)
  }

  func test_fromLanguageCode_returnsEnForEnglish() {
    XCTAssertEqual(SupportedLocale.from(languageCode: "en"), .en)
  }

  func test_fromLanguageCode_fallbacksToEnForUnsupportedLocale() {
    // 정책: ko/en 외 모든 언어는 영어 폴백 (글로벌 유저에게 영어 UX 제공).
    // 한국어 1순위 유저만 ko 유지, 나머지는 전부 en.
    XCTAssertEqual(SupportedLocale.from(languageCode: "fr"), .en)
    XCTAssertEqual(SupportedLocale.from(languageCode: "ja"), .en)
    XCTAssertEqual(SupportedLocale.from(languageCode: "zh"), .en)
    XCTAssertEqual(SupportedLocale.from(languageCode: nil), .en)
  }
}
