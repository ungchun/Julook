import XCTest

@testable import Core

final class FilterTypeTests: XCTestCase {

  func test_allCases_containsFiveFilters() {
    XCTAssertEqual(FilterType.allCases.count, 5)
    XCTAssertEqual(Set(FilterType.allCases), [
      .thick, .sweet, .sour, .carbonated, .noSweetener
    ])
  }

  func test_rawValues_matchKoreanLabels() {
    XCTAssertEqual(FilterType.thick.rawValue, "걸쭉한")
    XCTAssertEqual(FilterType.sweet.rawValue, "달달한")
    XCTAssertEqual(FilterType.sour.rawValue, "시큼한")
    XCTAssertEqual(FilterType.carbonated.rawValue, "탄산감 많은")
    XCTAssertEqual(FilterType.noSweetener.rawValue, "감미료 없는")
  }

  func test_id_equalsRawValue() {
    for filter in FilterType.allCases {
      XCTAssertEqual(filter.id, filter.rawValue)
    }
  }

  func test_description_equalsRawValue() {
    for filter in FilterType.allCases {
      XCTAssertEqual(filter.description, filter.rawValue)
    }
  }

  func test_identifiable_allIdsAreUnique() {
    let ids = FilterType.allCases.map(\.id)
    XCTAssertEqual(Set(ids).count, ids.count)
  }
}

final class SortOptionTests: XCTestCase {

  func test_allCases_containsThreeOptions() {
    XCTAssertEqual(SortOption.allCases.count, 3)
    XCTAssertEqual(Set(SortOption.allCases), [
      .recommended, .highAlcohol, .lowAlcohol
    ])
  }

  func test_rawValues_matchKoreanLabels() {
    XCTAssertEqual(SortOption.recommended.rawValue, "추천순")
    XCTAssertEqual(SortOption.highAlcohol.rawValue, "높은 도수순")
    XCTAssertEqual(SortOption.lowAlcohol.rawValue, "낮은 도수순")
  }

  func test_id_equalsRawValue() {
    for option in SortOption.allCases {
      XCTAssertEqual(option.id, option.rawValue)
    }
  }

  func test_description_equalsRawValue() {
    for option in SortOption.allCases {
      XCTAssertEqual(option.description, option.rawValue)
    }
  }
}
