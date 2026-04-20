import XCTest

@testable import Core

final class MakgeolliReactionRemoteTests: XCTestCase {

  // MARK: - Codable snake_case mapping

  func test_decode_mapsSnakeCaseKeys() throws {
    let id = UUID()
    let userId = UUID()
    let makgeolliId = UUID()
    let json = """
    {
      "id": "\(id.uuidString)",
      "user_id": "\(userId.uuidString)",
      "makgeolli_id": "\(makgeolliId.uuidString)",
      "reaction_type": "like",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-02-01T00:00:00Z"
    }
    """.data(using: .utf8)!

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let reaction = try decoder.decode(MakgeolliReactionRemote.self, from: json)

    XCTAssertEqual(reaction.id, id)
    XCTAssertEqual(reaction.userId, userId)
    XCTAssertEqual(reaction.makgeolliId, makgeolliId)
    XCTAssertEqual(reaction.reactionType, "like")
  }

  func test_encode_roundtripPreservesValues() throws {
    // ISO8601은 millisecond 이하를 잘라내므로 초 단위 타임스탬프로 고정
    let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    let original = MakgeolliReactionRemote(
      id: UUID(),
      userId: UUID(),
      makgeolliId: UUID(),
      reactionType: "dislike",
      createdAt: fixedDate,
      updatedAt: fixedDate
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(original)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let decoded = try decoder.decode(MakgeolliReactionRemote.self, from: data)

    XCTAssertEqual(decoded, original)
  }

  // MARK: - Default init

  func test_init_defaultsIdAndTimestamps() {
    let userId = UUID()
    let makgeolliId = UUID()
    let reaction = MakgeolliReactionRemote(
      userId: userId,
      makgeolliId: makgeolliId,
      reactionType: "like"
    )

    XCTAssertEqual(reaction.userId, userId)
    XCTAssertEqual(reaction.makgeolliId, makgeolliId)
    XCTAssertEqual(reaction.reactionType, "like")
    // id/createdAt/updatedAt 은 default init 값이 주입됐는지만 확인
    XCTAssertNotNil(reaction.id)
  }

  // MARK: - Equatable

  func test_equality_sameFieldsAreEqual() {
    let id = UUID()
    let userId = UUID()
    let makgeolliId = UUID()
    let date = Date()

    let a = MakgeolliReactionRemote(
      id: id, userId: userId, makgeolliId: makgeolliId,
      reactionType: "like", createdAt: date, updatedAt: date
    )
    let b = MakgeolliReactionRemote(
      id: id, userId: userId, makgeolliId: makgeolliId,
      reactionType: "like", createdAt: date, updatedAt: date
    )

    XCTAssertEqual(a, b)
  }

  func test_equality_differentReactionType_notEqual() {
    let shared = (id: UUID(), userId: UUID(), makgeolliId: UUID(), date: Date())
    let a = MakgeolliReactionRemote(
      id: shared.id, userId: shared.userId, makgeolliId: shared.makgeolliId,
      reactionType: "like", createdAt: shared.date, updatedAt: shared.date
    )
    let b = MakgeolliReactionRemote(
      id: shared.id, userId: shared.userId, makgeolliId: shared.makgeolliId,
      reactionType: "dislike", createdAt: shared.date, updatedAt: shared.date
    )

    XCTAssertNotEqual(a, b)
  }
}

final class MakgeolliReactionCountTests: XCTestCase {

  // MARK: - Codable snake_case mapping

  func test_decode_mapsSnakeCaseKeys() throws {
    let id = UUID()
    let makgeolliId = UUID()
    let json = """
    {
      "id": "\(id.uuidString)",
      "makgeolli_id": "\(makgeolliId.uuidString)",
      "like_count": 42,
      "dislike_count": 7,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-02-01T00:00:00Z"
    }
    """.data(using: .utf8)!

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let count = try decoder.decode(MakgeolliReactionCount.self, from: json)

    XCTAssertEqual(count.id, id)
    XCTAssertEqual(count.makgeolliId, makgeolliId)
    XCTAssertEqual(count.likeCount, 42)
    XCTAssertEqual(count.dislikeCount, 7)
  }

  // MARK: - Default init

  func test_init_defaultCountsAreZero() {
    let count = MakgeolliReactionCount(makgeolliId: UUID())

    XCTAssertEqual(count.likeCount, 0)
    XCTAssertEqual(count.dislikeCount, 0)
  }

  // MARK: - Encode roundtrip

  func test_encode_roundtripPreservesCounts() throws {
    let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    let original = MakgeolliReactionCount(
      id: UUID(),
      makgeolliId: UUID(),
      likeCount: 15,
      dislikeCount: 3,
      createdAt: fixedDate,
      updatedAt: fixedDate
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(original)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let decoded = try decoder.decode(MakgeolliReactionCount.self, from: data)

    XCTAssertEqual(decoded, original)
  }
}
