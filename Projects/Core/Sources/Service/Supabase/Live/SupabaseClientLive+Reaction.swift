import Foundation

import Supabase

extension SupabaseClientLive {
  static func saveReaction(
    _ ref: RawClientRef, userId: UUID, makgeolliId: UUID, reactionType: String
  ) async throws {
    let client = try requireClient(ref)
    do {
      let existingReactions: [MakgeolliReactionRemote] = try await client
        .from("makgeolli_reactions")
        .select()
        .eq("user_id", value: userId.uuidString)
        .eq("makgeolli_id", value: makgeolliId.uuidString)
        .execute()
        .value

      if let existingReaction = existingReactions.first {
        let result: PostgrestResponse = try await client
          .from("makgeolli_reactions")
          .update([
            "reaction_type": reactionType,
            "updated_at": ISO8601DateFormatter().string(from: Date())
          ])
          .eq("id", value: existingReaction.id.uuidString)
          .execute()

        if result.status != 200 && result.status != 204 {
          throw SupabaseClientError(code: .failToSaveReaction, underlying: nil)
        }
      } else {
        let reaction = MakgeolliReactionRemote(
          userId: userId,
          makgeolliId: makgeolliId,
          reactionType: reactionType
        )

        let result: PostgrestResponse = try await client
          .from("makgeolli_reactions")
          .insert(reaction)
          .execute()

        if result.status != 201 {
          throw SupabaseClientError(code: .failToSaveReaction, underlying: nil)
        }
      }
    } catch {
      throw SupabaseClientError(code: .failToSaveReaction, underlying: error)
    }
  }

  static func getReaction(
    _ ref: RawClientRef, userId: UUID, makgeolliId: UUID
  ) async throws -> MakgeolliReactionRemote? {
    let client = try requireClient(ref)
    do {
      let result: [MakgeolliReactionRemote] = try await client
        .from("makgeolli_reactions")
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

  static func getReactionCounts(
    _ ref: RawClientRef, makgeolliId: UUID
  ) async throws -> MakgeolliReactionCount? {
    let client = try requireClient(ref)
    do {
      let result: [MakgeolliReactionCount] = try await client
        .from("makgeolli_reaction_counts")
        .select()
        .eq("makgeolli_id", value: makgeolliId.uuidString)
        .execute()
        .value
      return result.first
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }

  static func deleteReaction(
    _ ref: RawClientRef, userId: UUID, makgeolliId: UUID
  ) async throws {
    let client = try requireClient(ref)
    do {
      let result: PostgrestResponse = try await client
        .from("makgeolli_reactions")
        .delete()
        .eq("user_id", value: userId.uuidString)
        .eq("makgeolli_id", value: makgeolliId.uuidString)
        .execute()

      if result.status < 200 || result.status >= 300 {
        throw SupabaseClientError(code: .failToDeleteReaction, underlying: nil)
      }
    } catch {
      throw SupabaseClientError(code: .failToDeleteReaction, underlying: error)
    }
  }

  static func getUserReaction(
    _ ref: RawClientRef, userId: UUID, makgeolliId: UUID
  ) async throws -> String? {
    let client = try requireClient(ref)
    do {
      let result: [MakgeolliReactionRemote] = try await client
        .from("makgeolli_reactions")
        .select()
        .eq("user_id", value: userId.uuidString)
        .eq("makgeolli_id", value: makgeolliId.uuidString)
        .execute()
        .value
      return result.first?.reactionType
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }
}
