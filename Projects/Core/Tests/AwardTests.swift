import XCTest

@testable import Core

final class AwardTests: XCTestCase {

  func test_init_preservesAllFields() {
    let id = UUID()
    let award = Award(
      id: id,
      name: "대한민국 주류대상",
      nameEn: "Korea Awards",
      year: 2024,
      type: "korea_award"
    )

    XCTAssertEqual(award.id, id)
    XCTAssertEqual(award.name, "대한민국 주류대상")
    XCTAssertEqual(award.nameEn, "Korea Awards")
    XCTAssertEqual(award.year, 2024)
    XCTAssertEqual(award.type, "korea_award")
  }

  func test_init_allowsNilNameEn() {
    let award = Award(id: UUID(), name: "A", nameEn: nil, year: 2024, type: "korea_award")
    XCTAssertNil(award.nameEn)
  }

  func test_decode_withNameEn_mapsSnakeCaseKey() throws {
    let id = UUID()
    let json = """
    {
      "id": "\(id.uuidString)",
      "name": "2024 대한민국 주류대상",
      "name_en": "2024 Korea Awards",
      "year": 2024,
      "type": "korea_award"
    }
    """.data(using: .utf8)!

    let award = try JSONDecoder().decode(Award.self, from: json)

    XCTAssertEqual(award.nameEn, "2024 Korea Awards")
    XCTAssertEqual(award.name, "2024 대한민국 주류대상")
  }

  func test_decode_withoutNameEn_isNil() throws {
    let id = UUID()
    let json = """
    {
      "id": "\(id.uuidString)",
      "name": "A",
      "year": 2024,
      "type": "korea_award"
    }
    """.data(using: .utf8)!

    let award = try JSONDecoder().decode(Award.self, from: json)

    XCTAssertNil(award.nameEn)
  }

  // MARK: - localizedName(for:)

  func test_localizedName_ko_returnsName() {
    let award = Award(
      id: UUID(), name: "2024 대한민국 주류대상",
      nameEn: "2024 Korea Awards", year: 2024, type: "korea_award"
    )
    XCTAssertEqual(award.localizedName(for: .ko), "2024 대한민국 주류대상")
  }

  func test_localizedName_en_withNameEn_returnsNameEn() {
    let award = Award(
      id: UUID(), name: "2024 대한민국 주류대상",
      nameEn: "2024 Korea Awards", year: 2024, type: "korea_award"
    )
    XCTAssertEqual(award.localizedName(for: .en), "2024 Korea Awards")
  }

  func test_localizedName_en_withoutNameEn_fallsBackToName() {
    let award = Award(
      id: UUID(), name: "A", nameEn: nil, year: 2024, type: "korea_award"
    )
    XCTAssertEqual(award.localizedName(for: .en), "A")
  }

  func test_equality() {
    let id = UUID()
    let a = Award(id: id, name: "A", nameEn: nil, year: 2024, type: "korea_award")
    let b = Award(id: id, name: "A", nameEn: nil, year: 2024, type: "korea_award")
    let c = Award(id: id, name: "A", nameEn: "A-en", year: 2024, type: "korea_award")

    XCTAssertEqual(a, b)
    XCTAssertNotEqual(a, c)
  }
}
