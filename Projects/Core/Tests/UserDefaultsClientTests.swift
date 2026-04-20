import XCTest

import ComposableArchitecture

@testable import Core

final class UserDefaultsClientTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // 테스트 격리
    UserDefaults.standard.removeObject(forKey: UserDefaultsClient.Key.recentSearches.rawValue)
    UserDefaults.standard.removeObject(
      forKey: UserDefaultsClient.Key.hasRequestedAppReview.rawValue
    )
    UserDefaults.standard.removeObject(
      forKey: UserDefaultsClient.Key.interactionCount.rawValue
    )
  }

  // MARK: - Keys

  func test_key_rawValuesStable() {
    XCTAssertEqual(UserDefaultsClient.Key.recentSearches.rawValue, "recentSearches")
    XCTAssertEqual(UserDefaultsClient.Key.hasRequestedAppReview.rawValue, "hasRequestedAppReview")
    XCTAssertEqual(UserDefaultsClient.Key.interactionCount.rawValue, "interactionCount")
  }

  // MARK: - Live: set/get roundtrip

  func test_liveValue_stringArrayRoundtrip() throws {
    let client = UserDefaultsClient.liveValue
    client.set(.recentSearches, ["a", "b", "c"])

    let loaded = try client.stringArray(.recentSearches)
    XCTAssertEqual(loaded, ["a", "b", "c"])
  }

  func test_liveValue_integerRoundtrip() throws {
    let client = UserDefaultsClient.liveValue
    client.set(.interactionCount, 5)

    let loaded = try client.integer(.interactionCount)
    XCTAssertEqual(loaded, 5)
  }

  func test_liveValue_boolRoundtrip() throws {
    let client = UserDefaultsClient.liveValue
    client.set(.hasRequestedAppReview, true)

    let loaded = try client.bool(.hasRequestedAppReview)
    XCTAssertTrue(loaded)
  }

  // MARK: - Missing key / type mismatch

  func test_liveValue_missingKey_throwsKeyNotFound() {
    let client = UserDefaultsClient.liveValue
    XCTAssertThrowsError(try client.integer(.interactionCount)) { error in
      guard let err = error as? UserDefaultsClientError else {
        return XCTFail("Expected UserDefaultsClientError")
      }
      XCTAssertEqual(err.code, .keyNotFound)
    }
  }

  func test_liveValue_typeMismatch_throwsTypeMismatch() {
    let client = UserDefaultsClient.liveValue
    client.set(.recentSearches, 42) // Int인데 stringArray로 조회 시도

    XCTAssertThrowsError(try client.stringArray(.recentSearches)) { error in
      guard let err = error as? UserDefaultsClientError else {
        return XCTFail("Expected UserDefaultsClientError")
      }
      XCTAssertEqual(err.code, .typeMismatch)
    }
  }

  // MARK: - removeObject

  func test_liveValue_removeObject_clearsValue() {
    let client = UserDefaultsClient.liveValue
    client.set(.recentSearches, ["a"])
    client.removeObject(.recentSearches)

    XCTAssertThrowsError(try client.stringArray(.recentSearches))
  }

  // MARK: - testValue substitutable

  func test_testValue_canOverride() throws {
    var client = UserDefaultsClient.testValue
    client.integer = { _ in 42 }

    let result = try client.integer(.interactionCount)
    XCTAssertEqual(result, 42)
  }
}
