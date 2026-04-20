import XCTest

@testable import Core

final class UserCommentTests: XCTestCase {

  // MARK: - Codable snake_case mapping

  func test_decode_mapsSnakeCaseKeys() throws {
    let id = UUID()
    let userId = UUID()
    let makgeolliId = UUID()
    let iso = ISO8601DateFormatter()
    let createdAt = iso.date(from: "2024-01-01T00:00:00Z")!
    let updatedAt = iso.date(from: "2024-02-01T00:00:00Z")!

    let json = """
    {
      "id": "\(id.uuidString)",
      "user_id": "\(userId.uuidString)",
      "makgeolli_id": "\(makgeolliId.uuidString)",
      "comment": "맛있어요",
      "is_public": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-02-01T00:00:00Z"
    }
    """.data(using: .utf8)!

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let comment = try decoder.decode(UserComment.self, from: json)

    XCTAssertEqual(comment.id, id)
    XCTAssertEqual(comment.userId, userId)
    XCTAssertEqual(comment.makgeolliId, makgeolliId)
    XCTAssertEqual(comment.comment, "맛있어요")
    XCTAssertTrue(comment.isPublic)
    XCTAssertEqual(comment.createdAt, createdAt)
    XCTAssertEqual(comment.updatedAt, updatedAt)
  }

  func test_hashable_sameIdHashesEqual() {
    let id = UUID()
    let date = Date()
    let a = UserComment(
      id: id, userId: UUID(), makgeolliId: UUID(),
      comment: "A", isPublic: true,
      createdAt: date, updatedAt: date
    )
    let b = UserComment(
      id: id, userId: a.userId, makgeolliId: a.makgeolliId,
      comment: "A", isPublic: true,
      createdAt: date, updatedAt: date
    )

    XCTAssertEqual(a.hashValue, b.hashValue)
  }
}
