import XCTest

@testable import Core

final class L10nInfraTests: XCTestCase {

  // MARK: - L10n 심볼 존재 & 접근성

  func test_L10nCommonButtonConfirm_returnsNonEmptyString() {
    XCTAssertFalse(L10n.Common.Button.confirm.isEmpty)
  }

  // MARK: - Localizable.strings ko/en 파일 존재

  func test_koLproj_Localizable_containsConfirmKey() throws {
    let bundle = CoreBundle.bundle
    let koPath = try XCTUnwrap(
      bundle.path(forResource: "ko", ofType: "lproj"),
      "Core.framework 번들에 ko.lproj가 복사되지 않았다"
    )
    let koBundle = try XCTUnwrap(Bundle(path: koPath))
    let value = koBundle.localizedString(
      forKey: "common.button.confirm",
      value: "__MISSING__",
      table: "Localizable"
    )
    XCTAssertEqual(value, "확인")
  }

  func test_enLproj_Localizable_containsConfirmKey() throws {
    let bundle = CoreBundle.bundle
    let enPath = try XCTUnwrap(
      bundle.path(forResource: "en", ofType: "lproj"),
      "Core.framework 번들에 en.lproj가 복사되지 않았다"
    )
    let enBundle = try XCTUnwrap(Bundle(path: enPath))
    let value = enBundle.localizedString(
      forKey: "common.button.confirm",
      value: "__MISSING__",
      table: "Localizable"
    )
    XCTAssertNotEqual(
      value, "__MISSING__",
      "en.lproj에 common.button.confirm 키가 없다"
    )
  }

  func test_koLproj_Localizable_containsRequestPromptKey() throws {
    let bundle = CoreBundle.bundle
    let koPath = try XCTUnwrap(
      bundle.path(forResource: "ko", ofType: "lproj"),
      "Core.framework 번들에 ko.lproj가 복사되지 않았다"
    )
    let koBundle = try XCTUnwrap(Bundle(path: koPath))
    let value = koBundle.localizedString(
      forKey: "search.results.requestPrompt",
      value: "__MISSING__",
      table: "Localizable"
    )
    XCTAssertEqual(value, "찾는 막걸리가 없나요?")
  }

  // MARK: - ko/en 키 집합 동기화

  func test_koAndEnLproj_haveIdenticalKeySets() throws {
    let bundle = CoreBundle.bundle
    let koKeys = try loadStringKeys(language: "ko", bundle: bundle)
    let enKeys = try loadStringKeys(language: "en", bundle: bundle)

    let missingInEn = koKeys.subtracting(enKeys)
    let missingInKo = enKeys.subtracting(koKeys)

    XCTAssertTrue(
      missingInEn.isEmpty,
      "en.lproj에서 빠진 키: \(missingInEn.sorted())"
    )
    XCTAssertTrue(
      missingInKo.isEmpty,
      "ko.lproj에서 빠진 키: \(missingInKo.sorted())"
    )
  }

  // MARK: - helpers

  private func loadStringKeys(
    language: String,
    bundle: Bundle
  ) throws -> Set<String> {
    let path = try XCTUnwrap(
      bundle.path(forResource: language, ofType: "lproj"),
      "\(language).lproj 번들을 찾을 수 없다"
    )
    let lprojBundle = try XCTUnwrap(Bundle(path: path))
    let stringsURL = try XCTUnwrap(
      lprojBundle.url(forResource: "Localizable", withExtension: "strings"),
      "\(language).lproj/Localizable.strings를 찾을 수 없다"
    )
    let dict = try XCTUnwrap(
      NSDictionary(contentsOf: stringsURL) as? [String: String],
      "\(language).lproj/Localizable.strings 파싱 실패"
    )
    return Set(dict.keys)
  }
}
