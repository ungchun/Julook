import XCTest

import ComposableArchitecture

@testable import Core

final class VersionCheckClientTests: XCTestCase {

  // MARK: - isForceUpdateRequired pure logic

  func test_isForceUpdateRequired_majorOlder_returnsTrue() {
    let client = VersionCheckClient.liveValue
    XCTAssertTrue(client.isForceUpdateRequired("1.0.0", "2.0.0"))
  }

  func test_isForceUpdateRequired_minorOlder_returnsTrue() {
    let client = VersionCheckClient.liveValue
    XCTAssertTrue(client.isForceUpdateRequired("1.5.0", "1.6.0"))
  }

  func test_isForceUpdateRequired_sameVersion_returnsFalse() {
    let client = VersionCheckClient.liveValue
    XCTAssertFalse(client.isForceUpdateRequired("1.5.0", "1.5.0"))
  }

  func test_isForceUpdateRequired_patchOlder_returnsFalse() {
    // 패치 버전 차이는 force update 트리거 안 함
    let client = VersionCheckClient.liveValue
    XCTAssertFalse(client.isForceUpdateRequired("1.5.0", "1.5.1"))
  }

  func test_isForceUpdateRequired_currentNewer_returnsFalse() {
    let client = VersionCheckClient.liveValue
    XCTAssertFalse(client.isForceUpdateRequired("2.0.0", "1.0.0"))
  }

  func test_isForceUpdateRequired_emptyStrings_returnsFalse() {
    let client = VersionCheckClient.liveValue
    XCTAssertFalse(client.isForceUpdateRequired("", ""))
  }

  // MARK: - Error types

  func test_error_lookupFailed_isError() {
    let error: Error = VersionCheckError.lookupFailed
    XCTAssertNotNil(error)
  }

  func test_error_invalidBundleID_isError() {
    let error: Error = VersionCheckError.invalidBundleID
    XCTAssertNotNil(error)
  }

  // MARK: - testValue

  func test_testValue_canOverrideCheckForUpdate() async throws {
    var client = VersionCheckClient.testValue
    client.checkForUpdate = { "9.9.9" }

    let version = try await client.checkForUpdate()
    XCTAssertEqual(version, "9.9.9")
  }
}
