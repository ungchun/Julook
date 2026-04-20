import Foundation

import Supabase

extension SupabaseClientLive {
  static func getUserComment(
    _ ref: RawClientRef, userId: UUID, makgeolliId: UUID
  ) async throws -> UserComment? {
    let client = try requireClient(ref)
    do {
      let result: [UserComment] = try await client
        .from("user_comments")
        .select()
        .eq("user_id", value: userId.uuidString)
        .eq("makgeolli_id", value: makgeolliId.uuidString)
        .execute()
        .value
      return result.first
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }

  static func saveUserComment(
    _ ref: RawClientRef, userId: UUID, makgeolliId: UUID, comment: String, isPublic: Bool
  ) async throws {
    let client = try requireClient(ref)
    do {
      struct CommentPayload: Codable {
        let userId: String
        let makgeolliId: String
        let comment: String
        let isPublic: Bool
        let updatedAt: String

        enum CodingKeys: String, CodingKey {
          case userId = "user_id"
          case makgeolliId = "makgeolli_id"
          case comment
          case isPublic = "is_public"
          case updatedAt = "updated_at"
        }
      }

      let commentPayload = CommentPayload(
        userId: userId.uuidString,
        makgeolliId: makgeolliId.uuidString,
        comment: comment,
        isPublic: isPublic,
        updatedAt: ISO8601DateFormatter().string(from: Date())
      )

      let _: PostgrestResponse = try await client
        .from("user_comments")
        .upsert(commentPayload, onConflict: "user_id,makgeolli_id")
        .execute()
    } catch {
      throw SupabaseClientError(code: .failToSaveUserComment, underlying: error)
    }
  }

  static func deleteUserComment(
    _ ref: RawClientRef, userId: UUID, makgeolliId: UUID
  ) async throws {
    let client = try requireClient(ref)
    do {
      let _: PostgrestResponse = try await client
        .from("user_comments")
        .delete()
        .eq("user_id", value: userId.uuidString)
        .eq("makgeolli_id", value: makgeolliId.uuidString)
        .execute()
    } catch {
      throw SupabaseClientError(code: .failToDeleteUserComment, underlying: error)
    }
  }

  static func getPublicComments(
    _ ref: RawClientRef, makgeolliId: UUID
  ) async throws -> [UserComment] {
    let client = try requireClient(ref)
    do {
      let result: [UserComment] = try await client
        .from("user_comments")
        .select()
        .eq("makgeolli_id", value: makgeolliId.uuidString)
        .eq("is_public", value: true)
        .order("created_at", ascending: false)
        .execute()
        .value
      return result
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }

  static func getUserComments(
    _ ref: RawClientRef, userId: UUID
  ) async throws -> [UserComment] {
    let client = try requireClient(ref)
    do {
      let result: [UserComment] = try await client
        .from("user_comments")
        .select()
        .eq("user_id", value: userId.uuidString)
        .order("updated_at", ascending: false)
        .execute()
        .value
      return result
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }

  static func getRecentComments(_ ref: RawClientRef) async throws -> [UserComment] {
    let client = try requireClient(ref)
    do {
      let result: [UserComment] = try await client
        .from("user_comments")
        .select()
        .eq("is_public", value: true)
        .order("created_at", ascending: false)
        .limit(4)
        .execute()
        .value
      return result
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }

  static func getRecentCommentsPaginated(
    _ ref: RawClientRef, limit: Int, offset: Int
  ) async throws -> [UserComment] {
    let client = try requireClient(ref)
    do {
      let result: [UserComment] = try await client
        .from("user_comments")
        .select()
        .eq("is_public", value: true)
        .order("created_at", ascending: false)
        .range(from: offset, to: offset + limit - 1)
        .execute()
        .value
      return result
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }
}
