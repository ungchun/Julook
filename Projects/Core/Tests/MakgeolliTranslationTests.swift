import XCTest

@testable import Core

final class MakgeolliTranslationTests: XCTestCase {

  // MARK: - Codable snake_case mapping

  func test_decode_mapsSnakeCaseKeys() throws {
    let id = UUID()
    let json = """
    {
      "makgeolli_id": "\(id.uuidString)",
      "locale": "en",
      "name": "Jangsu Saengmakgeolli",
      "brewery": "Seoul Takju",
      "awards": ["2024 Korea Liquor Awards"],
      "ingredients": ["Rice", "Nuruk"],
      "description": "Crisp and clean."
    }
    """.data(using: .utf8)!

    let translation = try JSONDecoder().decode(MakgeolliTranslation.self, from: json)

    XCTAssertEqual(translation.makgeolliId, id)
    XCTAssertEqual(translation.locale, "en")
    XCTAssertEqual(translation.name, "Jangsu Saengmakgeolli")
    XCTAssertEqual(translation.brewery, "Seoul Takju")
    XCTAssertEqual(translation.awards, ["2024 Korea Liquor Awards"])
    XCTAssertEqual(translation.ingredients, ["Rice", "Nuruk"])
    XCTAssertEqual(translation.description, "Crisp and clean.")
  }

  func test_decode_allOptionalsMissing() throws {
    let id = UUID()
    let json = """
    {
      "makgeolli_id": "\(id.uuidString)",
      "locale": "en",
      "name": "Minimum",
      "brewery": null,
      "awards": null,
      "ingredients": null,
      "description": null
    }
    """.data(using: .utf8)!

    let translation = try JSONDecoder().decode(MakgeolliTranslation.self, from: json)

    XCTAssertEqual(translation.makgeolliId, id)
    XCTAssertEqual(translation.name, "Minimum")
    XCTAssertNil(translation.brewery)
    XCTAssertNil(translation.awards)
    XCTAssertNil(translation.ingredients)
    XCTAssertNil(translation.description)
  }

  // MARK: - Equatable

  func test_equality_sameFields_equal() {
    let id = UUID()
    let a = MakgeolliTranslation(
      makgeolliId: id, locale: "en", name: "A", brewery: nil,
      awards: nil, ingredients: nil, description: nil
    )
    let b = MakgeolliTranslation(
      makgeolliId: id, locale: "en", name: "A", brewery: nil,
      awards: nil, ingredients: nil, description: nil
    )

    XCTAssertEqual(a, b)
  }
}
