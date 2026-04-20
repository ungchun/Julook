import XCTest

@testable import Core

final class MyMakgeolliEntityTests: XCTestCase {

  // MARK: - Init defaults

  func test_init_defaultsOptionalsToNilAndIsFavoriteFalse() {
    let id = UUID()
    let date = Date()
    let entity = MyMakgeolliEntity(
      id: id,
      name: "장수",
      createdAt: date,
      updatedAt: date
    )

    XCTAssertEqual(entity.id, id)
    XCTAssertEqual(entity.name, "장수")
    XCTAssertNil(entity.imageName)
    XCTAssertNil(entity.feedback)
    XCTAssertFalse(entity.isFavorite)
    XCTAssertNil(entity.comment)
  }

  // MARK: - Equatable

  func test_equality_sameFieldsAreEqual() {
    let id = UUID()
    let date = Date()
    let a = MyMakgeolliEntity(
      id: id, name: "A",
      imageName: "a.png", feedback: "F",
      isFavorite: true, comment: "C",
      createdAt: date, updatedAt: date
    )
    let b = MyMakgeolliEntity(
      id: id, name: "A",
      imageName: "a.png", feedback: "F",
      isFavorite: true, comment: "C",
      createdAt: date, updatedAt: date
    )

    XCTAssertEqual(a, b)
  }

  func test_equality_differentFavorite_notEqual() {
    let id = UUID()
    let date = Date()
    let a = MyMakgeolliEntity(
      id: id, name: "A",
      isFavorite: true,
      createdAt: date, updatedAt: date
    )
    let b = MyMakgeolliEntity(
      id: id, name: "A",
      isFavorite: false,
      createdAt: date, updatedAt: date
    )

    XCTAssertNotEqual(a, b)
  }

  // MARK: - Hashable

  func test_hashable_sameValuesSameHash() {
    let id = UUID()
    let date = Date()
    let a = MyMakgeolliEntity(
      id: id, name: "A",
      createdAt: date, updatedAt: date
    )
    let b = MyMakgeolliEntity(
      id: id, name: "A",
      createdAt: date, updatedAt: date
    )

    XCTAssertEqual(a.hashValue, b.hashValue)
  }

  func test_hashable_usableAsSetMember() {
    let id = UUID()
    let date = Date()
    let entity = MyMakgeolliEntity(id: id, name: "A", createdAt: date, updatedAt: date)

    var set: Set<MyMakgeolliEntity> = []
    set.insert(entity)
    set.insert(entity)

    XCTAssertEqual(set.count, 1)
  }
}

final class MakgeolliReactionEntityTests: XCTestCase {

  func test_init_preservesFields() {
    let id = UUID()
    let makgeolliId = UUID()
    let createdAt = Date(timeIntervalSince1970: 1000)
    let updatedAt = Date(timeIntervalSince1970: 2000)

    let entity = MakgeolliReactionEntity(
      id: id,
      makgeolliId: makgeolliId,
      reactionType: "like",
      createdAt: createdAt,
      updatedAt: updatedAt
    )

    XCTAssertEqual(entity.id, id)
    XCTAssertEqual(entity.makgeolliId, makgeolliId)
    XCTAssertEqual(entity.reactionType, "like")
    XCTAssertEqual(entity.createdAt, createdAt)
    XCTAssertEqual(entity.updatedAt, updatedAt)
  }

  func test_init_acceptsNilReactionType() {
    let entity = MakgeolliReactionEntity(
      id: UUID(),
      makgeolliId: UUID(),
      reactionType: nil,
      createdAt: Date(),
      updatedAt: Date()
    )

    XCTAssertNil(entity.reactionType)
  }

  func test_equality_differentReactionType_notEqual() {
    let shared = (id: UUID(), makgeolliId: UUID(), date: Date())
    let a = MakgeolliReactionEntity(
      id: shared.id, makgeolliId: shared.makgeolliId,
      reactionType: "like", createdAt: shared.date, updatedAt: shared.date
    )
    let b = MakgeolliReactionEntity(
      id: shared.id, makgeolliId: shared.makgeolliId,
      reactionType: nil, createdAt: shared.date, updatedAt: shared.date
    )

    XCTAssertNotEqual(a, b)
  }
}
