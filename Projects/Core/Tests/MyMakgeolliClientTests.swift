import XCTest

import ComposableArchitecture

@testable import Core

final class MyMakgeolliClientTests: XCTestCase {

  // MARK: - Error type

  func test_errorCodeRawValuesStable() {
    XCTAssertEqual(MyMakgeolliClientError.Code.failToInitializeContainer.rawValue, 0)
    XCTAssertEqual(MyMakgeolliClientError.Code.containerNotInitialized.rawValue, 1)
    XCTAssertEqual(MyMakgeolliClientError.Code.failToToggleFavorite.rawValue, 2)
    XCTAssertEqual(MyMakgeolliClientError.Code.failToCheckFavoriteStatus.rawValue, 3)
    XCTAssertEqual(MyMakgeolliClientError.Code.failToFetchMyMakgeollis.rawValue, 4)
  }

  func test_error_init_preservesCode() {
    struct Dummy: Error {}
    let error = MyMakgeolliClientError(
      code: .failToToggleFavorite,
      underlying: Dummy()
    )

    XCTAssertEqual(error.code, .failToToggleFavorite)
    XCTAssertTrue(error.underlying is Dummy)
  }

  // MARK: - Custom init 치환 가능성 (@DependencyClient 생성자 활용)

  func test_customInit_isFavoriteReturnsStub() async throws {
    let client = MyMakgeolliClient(
      initialize: { },
      toggleFavorite: { _ in },
      isFavorite: { _ in true },
      getMyMakgeollis: { [] },
      checkCloudKitStatus: { true }
    )

    let result = try await client.isFavorite(UUID())
    XCTAssertTrue(result)
  }

  func test_customInit_getMyMakgeollisReturnsStub() async throws {
    let entity = MyMakgeolliEntity(
      id: UUID(), name: "테스트",
      createdAt: Date(), updatedAt: Date()
    )
    let client = MyMakgeolliClient(
      initialize: { },
      toggleFavorite: { _ in },
      isFavorite: { _ in false },
      getMyMakgeollis: { [entity] },
      checkCloudKitStatus: { true }
    )

    let result = try await client.getMyMakgeollis()
    XCTAssertEqual(result, [entity])
  }
}
