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

  func test_fromLanguageCode_fallbacksToKoForUnsupportedLocale() {
    XCTAssertEqual(SupportedLocale.from(languageCode: "fr"), .ko)
    XCTAssertEqual(SupportedLocale.from(languageCode: "ja"), .ko)
    XCTAssertEqual(SupportedLocale.from(languageCode: nil), .ko)
  }
}
