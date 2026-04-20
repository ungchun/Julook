import XCTest

@testable import Core

final class LabelAnalysisResultTests: XCTestCase {

  // MARK: - Decoding

  func test_decode_fullPayload() throws {
    let json = #"""
    {
      "primaryName": "장수",
      "name": "장수 생막걸리",
      "brewery": "서울탁주",
      "region": "서울",
      "debug": {
        "rawResponse": "raw",
        "parsedJson": "{\"foo\":1}"
      }
    }
    """#.data(using: .utf8)!

    let result = try JSONDecoder().decode(LabelAnalysisResult.self, from: json)

    XCTAssertEqual(result.primaryName, "장수")
    XCTAssertEqual(result.name, "장수 생막걸리")
    XCTAssertEqual(result.brewery, "서울탁주")
    XCTAssertEqual(result.region, "서울")
    XCTAssertEqual(result.debug?.rawResponse, "raw")
    XCTAssertEqual(result.debug?.parsedJson, #"{"foo":1}"#)
  }

  func test_decode_allNullPayload() throws {
    let json = #"""
    {
      "primaryName": null,
      "name": null,
      "brewery": null,
      "region": null,
      "debug": null
    }
    """#.data(using: .utf8)!

    let result = try JSONDecoder().decode(LabelAnalysisResult.self, from: json)

    XCTAssertNil(result.primaryName)
    XCTAssertNil(result.name)
    XCTAssertNil(result.brewery)
    XCTAssertNil(result.region)
    XCTAssertNil(result.debug)
  }

  // MARK: - Encoding roundtrip

  func test_encodeDecodeRoundtrip_preservesValues() throws {
    let original = LabelAnalysisResult(
      primaryName: "장수",
      name: "장수 생막걸리",
      brewery: "서울탁주",
      region: "서울",
      debug: LabelAnalysisDebug(rawResponse: "raw", parsedJson: #"{"ok":true}"#)
    )

    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(LabelAnalysisResult.self, from: data)

    XCTAssertEqual(decoded, original)
  }

  // MARK: - Equatable

  func test_equality_sameFieldsAreEqual() {
    let a = LabelAnalysisResult(primaryName: "A", name: "full", brewery: "B")
    let b = LabelAnalysisResult(primaryName: "A", name: "full", brewery: "B")

    XCTAssertEqual(a, b)
  }

  func test_equality_differentBreweryNotEqual() {
    let a = LabelAnalysisResult(name: "A", brewery: "X")
    let b = LabelAnalysisResult(name: "A", brewery: "Y")

    XCTAssertNotEqual(a, b)
  }

  // MARK: - Init defaults

  func test_init_defaultsOptionalsToNil() {
    let result = LabelAnalysisResult(name: "A", brewery: nil)

    XCTAssertNil(result.primaryName)
    XCTAssertNil(result.region)
    XCTAssertNil(result.debug)
  }
}
