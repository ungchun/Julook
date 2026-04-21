import XCTest

@testable import Core

final class MakgeolliLocalizedTests: XCTestCase {

  private func makeSample(id: UUID = UUID()) -> Makgeolli {
    Makgeolli(
      id: id,
      name: "해창 막걸리",
      brewery: "해창주조",
      website: "https://example.com",
      awards: ["2024 대한민국 주류대상"],
      sweetness: 3,
      sourness: 2,
      thickness: 4,
      carbonation: 1,
      hasSweetener: false,
      ingredients: ["쌀", "누룩"],
      alcoholPercentage: 12.0,
      imageName: "haechang.png",
      createdAt: nil,
      updatedAt: nil
    )
  }

  // MARK: - nil translation

  func test_localized_nilTranslation_returnsSelf() {
    let original = makeSample()

    let result = original.localized(with: nil)

    XCTAssertEqual(result, original)
  }

  // MARK: - with translation

  func test_localized_withTranslation_replacesLocalizedFields() {
    let id = UUID()
    let original = makeSample(id: id)
    let translation = MakgeolliTranslation(
      makgeolliId: id,
      locale: "en",
      name: "Haechang Makgeolli",
      brewery: "Haechang Brewery",
      awards: ["2024 Korea Liquor Awards"],
      ingredients: ["Rice", "Nuruk"],
      description: "Traditional makgeolli."
    )

    let result = original.localized(with: translation)

    XCTAssertEqual(result.name, "Haechang Makgeolli")
    XCTAssertEqual(result.brewery, "Haechang Brewery")
    XCTAssertEqual(result.awards, ["2024 Korea Liquor Awards"])
    XCTAssertEqual(result.ingredients, ["Rice", "Nuruk"])
  }

  func test_localized_preservesNonLocalizedFields() {
    let id = UUID()
    let original = makeSample(id: id)
    let translation = MakgeolliTranslation(
      makgeolliId: id,
      locale: "en",
      name: "Haechang",
      brewery: "Haechang",
      awards: nil,
      ingredients: nil,
      description: nil
    )

    let result = original.localized(with: translation)

    XCTAssertEqual(result.id, id)
    XCTAssertEqual(result.website, "https://example.com")
    XCTAssertEqual(result.sweetness, 3)
    XCTAssertEqual(result.sourness, 2)
    XCTAssertEqual(result.thickness, 4)
    XCTAssertEqual(result.carbonation, 1)
    XCTAssertEqual(result.hasSweetener, false)
    XCTAssertEqual(result.alcoholPercentage, 12.0)
    XCTAssertEqual(result.imageName, "haechang.png")
  }

  // MARK: - partial translation fallback

  func test_localized_nilTranslationField_fallbacksToOriginal() {
    let id = UUID()
    let original = makeSample(id: id)
    let translation = MakgeolliTranslation(
      makgeolliId: id,
      locale: "en",
      name: "Haechang",
      brewery: nil,  // 영어 양조장명 없음
      awards: nil,   // 영어 수상명 없음
      ingredients: nil,
      description: nil
    )

    let result = original.localized(with: translation)

    // 영어 name만 바뀌고, 나머지는 원본 유지 (brewery/awards/ingredients)
    XCTAssertEqual(result.name, "Haechang")
    XCTAssertEqual(result.brewery, "해창주조", "nil translation.brewery → original brewery 유지")
    XCTAssertEqual(result.awards, ["2024 대한민국 주류대상"], "nil translation.awards → original awards 유지")
    XCTAssertEqual(result.ingredients, ["쌀", "누룩"], "nil translation.ingredients → original ingredients 유지")
  }
}
