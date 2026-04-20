import XCTest

@testable import Core

final class MakgeolliTests: XCTestCase {

  // MARK: - Codable snake_case mapping

  func test_decode_mapsSnakeCaseKeys() throws {
    let id = UUID()
    let json = """
    {
      "id": "\(id.uuidString)",
      "name": "장수 생막걸리",
      "brewery": "서울탁주",
      "website": null,
      "awards": null,
      "sweetness": 3,
      "sourness": 2,
      "thickness": 4,
      "carbonation": 1,
      "has_sweetener": false,
      "ingredients": ["쌀", "누룩"],
      "alcohol_percentage": 6.0,
      "image_name": "jangsu.png",
      "created_at": null,
      "updated_at": null
    }
    """.data(using: .utf8)!

    let makgeolli = try JSONDecoder().decode(Makgeolli.self, from: json)

    XCTAssertEqual(makgeolli.id, id)
    XCTAssertEqual(makgeolli.name, "장수 생막걸리")
    XCTAssertEqual(makgeolli.brewery, "서울탁주")
    XCTAssertEqual(makgeolli.sweetness, 3)
    XCTAssertEqual(makgeolli.hasSweetener, false)
    XCTAssertEqual(makgeolli.alcoholPercentage, 6.0)
    XCTAssertEqual(makgeolli.imageName, "jangsu.png")
    XCTAssertEqual(makgeolli.ingredients, ["쌀", "누룩"])
  }

  func test_decode_allOptionalsMissing() throws {
    let id = UUID()
    let json = """
    {
      "id": "\(id.uuidString)",
      "name": "최소",
      "brewery": null,
      "website": null,
      "awards": null,
      "sweetness": null,
      "sourness": null,
      "thickness": null,
      "carbonation": null,
      "has_sweetener": null,
      "ingredients": null,
      "alcohol_percentage": null,
      "image_name": null,
      "created_at": null,
      "updated_at": null
    }
    """.data(using: .utf8)!

    let makgeolli = try JSONDecoder().decode(Makgeolli.self, from: json)

    XCTAssertEqual(makgeolli.name, "최소")
    XCTAssertNil(makgeolli.brewery)
    XCTAssertNil(makgeolli.sweetness)
    XCTAssertNil(makgeolli.alcoholPercentage)
  }

  // MARK: - Equatable

  func test_equality_sameIdDifferentFields_notEqual() {
    let id = UUID()
    let a = Makgeolli(
      id: id, name: "A", brewery: nil, website: nil, awards: nil,
      sweetness: 1, sourness: nil, thickness: nil, carbonation: nil,
      hasSweetener: nil, ingredients: nil, alcoholPercentage: nil,
      imageName: nil, createdAt: nil, updatedAt: nil
    )
    let b = Makgeolli(
      id: id, name: "A", brewery: nil, website: nil, awards: nil,
      sweetness: 2, sourness: nil, thickness: nil, carbonation: nil,
      hasSweetener: nil, ingredients: nil, alcoholPercentage: nil,
      imageName: nil, createdAt: nil, updatedAt: nil
    )

    // 같은 id + 이름이지만 필드 다름 → Equatable이 전체 필드 비교 (TCA State용)
    XCTAssertNotEqual(a, b)
  }

  func test_identifiable_idMatches() {
    let id = UUID()
    let makgeolli = Makgeolli(
      id: id, name: "A", brewery: nil, website: nil, awards: nil,
      sweetness: nil, sourness: nil, thickness: nil, carbonation: nil,
      hasSweetener: nil, ingredients: nil, alcoholPercentage: nil,
      imageName: nil, createdAt: nil, updatedAt: nil
    )

    XCTAssertEqual(makgeolli.id, id)
  }
}
