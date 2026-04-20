import XCTest

@testable import Core

final class SupabaseClientErrorTests: XCTestCase {

  func test_init_defaultsUserInfoToEmpty() {
    let error = SupabaseClientError(code: .clientNotInitialized, underlying: nil)

    XCTAssertEqual(error.code, .clientNotInitialized)
    XCTAssertNil(error.underlying)
    XCTAssertTrue(error.userInfo.isEmpty)
  }

  func test_init_preservesCode() {
    let codes: [SupabaseClientError.Code] = [
      .clientNotInitialized,
      .failToFetch,
      .failToGetPublicURL,
      .failToSaveRequest,
      .failToSaveReaction,
      .failToDeleteReaction,
      .failToSaveUserComment,
      .failToDeleteUserComment,
      .failToAnalyzeLabel,
      .unknownError
    ]

    for code in codes {
      let error = SupabaseClientError(code: code)
      XCTAssertEqual(error.code, code)
    }
  }

  func test_init_preservesUnderlyingError() {
    struct DummyError: Error, Equatable {
      let tag: String
    }
    let underlying = DummyError(tag: "original")

    let error = SupabaseClientError(code: .failToFetch, underlying: underlying)

    XCTAssertEqual(error.underlying as? DummyError, underlying)
  }

  func test_init_preservesUserInfo() {
    let error = SupabaseClientError(
      userInfo: ["requestId": "abc-123"],
      code: .failToFetch
    )

    XCTAssertEqual(error.userInfo["requestId"] as? String, "abc-123")
  }

  func test_code_rawValuesAreStable() {
    // Analytics 집계가 raw value 기반이므로 순서 변경 감지용 회귀 테스트
    XCTAssertEqual(SupabaseClientError.Code.clientNotInitialized.rawValue, 0)
    XCTAssertEqual(SupabaseClientError.Code.failToFetch.rawValue, 1)
    XCTAssertEqual(SupabaseClientError.Code.unknownError.rawValue, 9)
  }
}
