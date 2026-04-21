import XCTest

@testable import Core

final class FilterTypeTests: XCTestCase {

  func test_allCases_containsFiveFilters() {
    XCTAssertEqual(FilterType.allCases.count, 5)
    XCTAssertEqual(Set(FilterType.allCases), [
      .thick, .sweet, .sour, .carbonated, .noSweetener
    ])
  }

  func test_rawValues_areEnglishIdentifiers() {
    XCTAssertEqual(FilterType.thick.rawValue, "thick")
    XCTAssertEqual(FilterType.sweet.rawValue, "sweet")
    XCTAssertEqual(FilterType.sour.rawValue, "sour")
    XCTAssertEqual(FilterType.carbonated.rawValue, "carbonated")
    XCTAssertEqual(FilterType.noSweetener.rawValue, "noSweetener")
  }

  func test_id_equalsRawValue() {
    for filter in FilterType.allCases {
      XCTAssertEqual(filter.id, filter.rawValue)
    }
  }

  func test_description_returnsLocalizedDisplayName() {
    XCTAssertEqual(FilterType.thick.description, L10n.Filter.Kind.thick)
    XCTAssertEqual(FilterType.sweet.description, L10n.Filter.Kind.sweet)
    XCTAssertEqual(FilterType.sour.description, L10n.Filter.Kind.sour)
    XCTAssertEqual(FilterType.carbonated.description, L10n.Filter.Kind.carbonated)
    XCTAssertEqual(FilterType.noSweetener.description, L10n.Filter.Kind.noSweetener)
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

  func test_rawValues_areEnglishIdentifiers() {
    XCTAssertEqual(SortOption.recommended.rawValue, "recommended")
    XCTAssertEqual(SortOption.highAlcohol.rawValue, "highAlcohol")
    XCTAssertEqual(SortOption.lowAlcohol.rawValue, "lowAlcohol")
  }

  func test_id_equalsRawValue() {
    for option in SortOption.allCases {
      XCTAssertEqual(option.id, option.rawValue)
    }
  }

  func test_description_returnsLocalizedDisplayName() {
    XCTAssertEqual(SortOption.recommended.description, L10n.Filter.Sort.recommended)
    XCTAssertEqual(SortOption.highAlcohol.description, L10n.Filter.Sort.highAlcohol)
    XCTAssertEqual(SortOption.lowAlcohol.description, L10n.Filter.Sort.lowAlcohol)
  }
}
