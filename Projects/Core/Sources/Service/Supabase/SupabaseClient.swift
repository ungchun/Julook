//
//  SupabaseManager.swift
//  Core
//
//  Created by Kim SungHun on 3/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import ComposableArchitecture
import Supabase

public enum Bucket {
  public static let MAKGEOLLIIMAGE = "makgeolli_image"
}

@DependencyClient
public struct SupabaseClient: Sendable {
  public var initialize: @Sendable () async -> Void
  
  public var fetchNewReleases: @Sendable () async throws -> [Makgeolli]
  public var fetchAwards: @Sendable () async throws -> [Award]
  public var fetchMakgeollis: @Sendable (Int, Int) async throws -> [Makgeolli]
  public var fetchFilteredMakgeollis: @Sendable (Int, Int, Set<FilterType>) async throws -> [Makgeolli]
  public var fetchMakgeollisByAward: @Sendable (String, Int, Int) async throws -> [Makgeolli]
  public var fetchMakgeolliById: @Sendable (UUID) async throws -> Makgeolli?
  public var getPublicURL: @Sendable (String, String) async throws -> URL
  public var searchMakgeollis: @Sendable (String) async throws -> [Makgeolli]
  public var requestRegisterMakgeolli: @Sendable (String) async throws -> Void
  public var saveReaction: @Sendable (UUID, UUID, String) async throws -> Void
  public var getReaction: @Sendable (UUID, UUID) async throws -> MakgeolliReactionRemote?
  public var getReactionCounts: @Sendable (UUID) async throws -> MakgeolliReactionCount?
  public var deleteReaction: @Sendable (UUID, UUID) async throws -> Void
  public var fetchTopLikedMakgeollis: @Sendable () async throws -> [Makgeolli]
  public var getUserComment: @Sendable (UUID, UUID) async throws -> UserComment?
  public var saveUserComment: @Sendable (UUID, UUID, String, Bool) async throws -> Void
  public var deleteUserComment: @Sendable (UUID, UUID) async throws -> Void
}

extension SupabaseClient: DependencyKey {
  public static var liveValue: SupabaseClient {
    let clientRef = LockIsolated<Supabase.SupabaseClient?>(nil)
    
    return SupabaseClient(
      initialize: {
        do {
          guard let supabaseKeyValue = Bundle.main.infoDictionary?["SUPABASE_KEY"]
                  as? String else {
            throw SupabaseClientError(
              code: .clientNotInitialized,
              underlying: nil
            )
          }
          let trimmedKey = supabaseKeyValue.trimmingCharacters(
            in: CharacterSet(charactersIn: "\"")
          )
          guard let supabaseURL = URL(string: "https://avfwwfpwpdpsoegwehry.supabase.co") else {
            throw SupabaseClientError(
              code: .clientNotInitialized,
              underlying: nil
            )
          }
          let client = Supabase.SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: trimmedKey
          )
          clientRef.setValue(client)
        } catch {
          Log.error(error)
        }
      },
      
      fetchNewReleases: {
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        let result: [Makgeolli] = try await client
          .from("makgeolli")
          .select()
          .order("created_at", ascending: false)
          .limit(5)
          .execute()
          .value
        return result
      },
      
      fetchAwards: {
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        let result: [Award] = try await client
          .from("awards")
          .select()
          .order("year", ascending: false)
          .limit(5)
          .execute()
          .value
        
        return result
      },
      
      fetchMakgeollis: { limit, offset in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        let result: [Makgeolli] = try await client
          .from("makgeolli")
          .select()
          .order("id", ascending: true)
          .order("created_at", ascending: false)
          .range(from: offset, to: offset + limit - 1)
          .execute()
          .value
        return result
      },
      
      fetchFilteredMakgeollis: { pageSize, offset, filters in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        var query = client.from("makgeolli").select()
        for filter in filters {
          switch filter {
          case .sweet:
            query = query.gte("sweetness", value: 3)
          case .sour:
            query = query.gte("sourness", value: 3)
          case .thick:
            query = query.gte("thickness", value: 3)
          case .carbonated:
            query = query.gte("carbonation", value: 3)
          case .noAspartame:
            query = query.eq("has_aspartame", value: false)
          }
        }
        
        let result: [Makgeolli] = try await query
          .order("id", ascending: true)
          .order("created_at", ascending: false)
          .range(from: offset, to: offset + pageSize - 1)
          .execute()
          .value
        
        return result
      },
      
      fetchMakgeollisByAward: { awardType, pageSize, offset in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        let result: [Makgeolli] = try await client
          .from("makgeolli")
          .select()
          .contains("awards", value: [awardType])
          .order("id", ascending: true)
          .order("created_at", ascending: false)
          .range(from: offset, to: offset + pageSize - 1)
          .execute()
          .value
        
        return result
      },
      
      fetchMakgeolliById: { id in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        do {
          let result: [Makgeolli] = try await client
            .from("makgeolli")
            .select()
            .eq("id", value: id.uuidString)
            .execute()
            .value
          
          return result.first
        } catch {
          throw SupabaseClientError(
            code: .failToFetch,
            underlying: error
          )
        }
      },
      
      getPublicURL: { bucket, path in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        return try client.storage.from(bucket).getPublicURL(path: path)
      },
      
      searchMakgeollis: { query in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        do {
          let lowercasedQuery = query.lowercased()
          let result: [Makgeolli] = try await client
            .from("makgeolli")
            .select()
            .or("name.ilike.%\(lowercasedQuery)%,brewery.ilike.%\(lowercasedQuery)%")
            .execute()
            .value
          
          return result
        } catch {
          throw SupabaseClientError(
            code: .failToFetch,
            underlying: error
          )
        }
      },
      
      requestRegisterMakgeolli: { searchText in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        do {
          let result: PostgrestResponse = try await client
            .from("makgeolli_requests")
            .insert(
              [
                "search_text": searchText
              ]
            )
            .execute()
          
          if result.status != 201 {
            throw SupabaseClientError(
              code: .failToSaveRequest,
              underlying: nil
            )
          }
        } catch {
          throw SupabaseClientError(
            code: .failToSaveRequest,
            underlying: error
          )
        }
      },
      
      // 막걸리 반응 저장/업데이트
      saveReaction: { userId, makgeolliId, reactionType in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
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
              throw SupabaseClientError(
                code: .failToSaveReaction,
                underlying: nil
              )
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
              throw SupabaseClientError(
                code: .failToSaveReaction,
                underlying: nil
              )
            }
          }
        } catch {
          throw SupabaseClientError(
            code: .failToSaveReaction,
            underlying: error
          )
        }
      },
      
      // 특정 유저의 막걸리 반응 조회
      getReaction: { userId, makgeolliId in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
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
          throw SupabaseClientError(
            code: .failToFetch,
            underlying: error
          )
        }
      },
      
      // 막걸리 반응 개수 조회
      getReactionCounts: { makgeolliId in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        do {
          let result: [MakgeolliReactionCount] = try await client
            .from("makgeolli_reaction_counts")
            .select()
            .eq("makgeolli_id", value: makgeolliId.uuidString)
            .execute()
            .value
          
          return result.first
        } catch {
          throw SupabaseClientError(
            code: .failToFetch,
            underlying: error
          )
        }
      },
      
      // 막걸리 반응 삭제
      deleteReaction: { userId, makgeolliId in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        do {
          let result: PostgrestResponse = try await client
            .from("makgeolli_reactions")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("makgeolli_id", value: makgeolliId.uuidString)
            .execute()
          
          if result.status < 200 || result.status >= 300 {
            throw SupabaseClientError(
              code: .failToDeleteReaction,
              underlying: nil
            )
          }
        } catch {
          throw SupabaseClientError(
            code: .failToDeleteReaction,
            underlying: error
          )
        }
      },
      
      // 좋아요 수가 가장 많은 막걸리 3개 조회
      fetchTopLikedMakgeollis: {
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        do {
          let topReactionCounts: [MakgeolliReactionCount] = try await client
            .from("makgeolli_reaction_counts")
            .select()
            .order("like_count", ascending: false)
            .order("updated_at", ascending: false)
            .limit(3)
            .execute()
            .value
          
          let makgeolliIds = topReactionCounts.map { $0.makgeolliId.uuidString }
          
          let result: [Makgeolli] = try await client
            .from("makgeolli")
            .select()
            .in("id", values: makgeolliIds)
            .execute()
            .value
          
          let sortedResult = topReactionCounts.compactMap { reactionCount in
            result.first { $0.id == reactionCount.makgeolliId }
          }
          
          return sortedResult
        } catch {
          throw SupabaseClientError(
            code: .failToFetch,
            underlying: error
          )
        }
      },
      
      // 유저 코멘트 조회
      getUserComment: { userId, makgeolliId in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
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
          throw SupabaseClientError(
            code: .failToFetch,
            underlying: error
          )
        }
      },
      
      // 유저 코멘트 저장/수정
      saveUserComment: { userId, makgeolliId, comment, isPublic in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
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
          throw SupabaseClientError(
            code: .failToSaveUserComment,
            underlying: error
          )
        }
      },
      
      // 유저 코멘트 삭제
      deleteUserComment: { userId, makgeolliId in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        do {
          let _: PostgrestResponse = try await client
            .from("user_comments")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("makgeolli_id", value: makgeolliId.uuidString)
            .execute()
        } catch {
          throw SupabaseClientError(
            code: .failToDeleteUserComment,
            underlying: error
          )
        }
      }
    )
  }
}

public extension DependencyValues {
  var supabaseClient: SupabaseClient {
    get { self[SupabaseClient.self] }
    set { self[SupabaseClient.self] = newValue }
  }
}

public struct SupabaseClientError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any]
  public var code: Code
  public var underlying: Error?
  
  public init(
    userInfo: [String: Any] = [:],
    code: Code,
    underlying: Error? = nil
  ) {
    self.userInfo = userInfo
    self.code = code
    self.underlying = underlying
  }
  
  public enum Code: Int, Sendable {
    case clientNotInitialized
    case failToFetch
    case failToGetPublicURL
    case failToSaveRequest
    case failToSaveReaction
    case failToDeleteReaction
    case failToSaveUserComment
    case failToDeleteUserComment
    case unknownError
  }
}
