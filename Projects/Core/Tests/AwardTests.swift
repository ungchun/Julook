import XCTest

@testable import Core

final class AwardTests: XCTestCase {

  func test_init_preservesAllFields() {
    let id = UUID()
    let award = Award(id: id, name: "대한민국 주류대상", year: 2024, type: "korea_award")

    XCTAssertEqual(award.id, id)
    XCTAssertEqual(award.name, "대한민국 주류대상")
    XCTAssertEqual(award.year, 2024)
    XCTAssertEqual(award.type, "korea_award")
  }

  func test_decode_fullPayload() throws {
    let id = UUID()
    let json = """
    {
      "id": "\(id.uuidString)",
      "name": "대한민국 주류대상",
      "year": 2024,
      "type": "korea_award"
    }
    """.data(using: .utf8)!

    let award = try JSONDecoder().decode(Award.self, from: json)

    XCTAssertEqual(award.id, id)
    XCTAssertEqual(award.year, 2024)
  }

  func test_equality() {
    let id = UUID()
    let a = Award(id: id, name: "A", year: 2024, type: "korea_award")
    let b = Award(id: id, name: "A", year: 2024, type: "korea_award")
    let c = Award(id: id, name: "A", year: 2023, type: "korea_award")

    XCTAssertEqual(a, b)
    XCTAssertNotEqual(a, c)
  }
}
