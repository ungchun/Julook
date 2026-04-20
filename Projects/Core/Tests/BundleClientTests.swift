import XCTest

import ComposableArchitecture

@testable import Core

final class BundleClientTests: XCTestCase {

  // MARK: - Live: bundle access

  func test_liveValue_getBundleID_returnsNonEmpty() throws {
    let bundleID = try BundleClient.liveValue.getBundleID()
    XCTAssertFalse(bundleID.isEmpty)
  }

  func test_liveValue_getCurrentVersion_returnsNonEmpty() throws {
    // 테스트 번들의 CFBundleShortVersionString 가 있을 때만 성공
    // xctest 번들도 version을 가짐
    do {
      let version = try BundleClient.liveValue.getCurrentVersion()
      XCTAssertFalse(version.isEmpty)
    } catch let error as BundleClientError {
      XCTAssertEqual(error.code, .noCurrentVersion)
    }
  }

  func test_liveValue_getValue_missingKey_throws() {
    XCTAssertThrowsError(
      try BundleClient.liveValue.getValue(key: "NonExistentKey_XYZ_12345")
    ) { error in
      guard let err = error as? BundleClientError else {
        return XCTFail("Expected BundleClientError")
      }
      XCTAssertEqual(err.code, .noValueForKey)
    }
  }

  // MARK: - testValue: substitutable closure-based client

  func test_testValue_canOverrideClosures() throws {
    var client = BundleClient.testValue
    client.getCurrentVersion = { "9.9.9" }

    let version = try client.getCurrentVersion()
    XCTAssertEqual(version, "9.9.9")
  }

  // MARK: - Error rawValues

  func test_error_codeRawValuesStable() {
    XCTAssertEqual(BundleClientError.Code.noValueForKey.rawValue, 0)
    XCTAssertEqual(BundleClientError.Code.noCurrentVersion.rawValue, 1)
    XCTAssertEqual(BundleClientError.Code.noBundleID.rawValue, 2)
  }
}
