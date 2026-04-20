import XCTest

import ComposableArchitecture

@testable import Core

final class MakgeolliReactionClientTests: XCTestCase {

  // MARK: - Error

  func test_errorCodeRawValuesStable() {
    XCTAssertEqual(MakgeolliReactionClientError.Code.failToGetReaction.rawValue, 0)
    XCTAssertEqual(MakgeolliReactionClientError.Code.failToGetAllReactions.rawValue, 1)
    XCTAssertEqual(MakgeolliReactionClientError.Code.failToSaveReaction.rawValue, 2)
    XCTAssertEqual(MakgeolliReactionClientError.Code.failToDeleteReaction.rawValue, 3)
  }

  // MARK: - testValue 치환

  func test_testValue_getReaction_isSubstitutable() async throws {
    let entity = MakgeolliReactionEntity(
      id: UUID(), makgeolliId: UUID(),
      reactionType: "like",
      createdAt: Date(), updatedAt: Date()
    )
    var client = MakgeolliReactionClient.testValue
    client.getReaction = { _ in entity }

    let result = try await client.getReaction(UUID())
    XCTAssertEqual(result, entity)
  }

  func test_testValue_getAllReactions_isSubstitutable() async throws {
    var client = MakgeolliReactionClient.testValue
    client.getAllReactions = { [] }

    let result = try await client.getAllReactions()
    XCTAssertTrue(result.isEmpty)
  }

  func test_testValue_saveReaction_doesNotThrow() async {
    var client = MakgeolliReactionClient.testValue
    client.saveReaction = { _, _ in }

    do {
      try await client.saveReaction(UUID(), "like")
    } catch {
      XCTFail("testValue override shouldn't throw")
    }
  }
}
