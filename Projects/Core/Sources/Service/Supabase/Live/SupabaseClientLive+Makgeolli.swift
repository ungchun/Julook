import Foundation

import Supabase

extension SupabaseClientLive {
  static func fetchNewReleases(_ ref: RawClientRef) async throws -> [Makgeolli] {
    let client = try requireClient(ref)
    let result: [Makgeolli] = try await client
      .from("makgeolli")
      .select()
      .order("created_at", ascending: false)
      .limit(5)
      .execute()
      .value
    return result
  }

  static func fetchRandomMakgeollis(_ ref: RawClientRef) async throws -> [Makgeolli] {
    let client = try requireClient(ref)
    let allMakgeollis: [Makgeolli] = try await client
      .from("makgeolli")
      .select()
      .execute()
      .value
    return Array(allMakgeollis.shuffled().prefix(5))
  }

  static func fetchAwards(_ ref: RawClientRef) async throws -> [Award] {
    let client = try requireClient(ref)
    let result: [Award] = try await client
      .from("awards")
      .select()
      .order("year", ascending: false)
      .limit(5)
      .execute()
      .value
    return result
  }

  static func fetchMakgeollis(
    _ ref: RawClientRef, limit: Int, offset: Int
  ) async throws -> [Makgeolli] {
    let client = try requireClient(ref)
    let result: [Makgeolli] = try await client
      .from("makgeolli")
      .select()
      .order("id", ascending: true)
      .order("created_at", ascending: false)
      .range(from: offset, to: offset + limit - 1)
      .execute()
      .value
    return result
  }

  static func fetchFilteredMakgeollis(
    _ ref: RawClientRef, pageSize: Int, offset: Int, filters: Set<FilterType>
  ) async throws -> [Makgeolli] {
    let client = try requireClient(ref)
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
      case .noSweetener:
        query = query.eq("has_sweetener", value: false)
      }
    }

    let result: [Makgeolli] = try await query
      .order("id", ascending: true)
      .order("created_at", ascending: false)
      .range(from: offset, to: offset + pageSize - 1)
      .execute()
      .value
    return result
  }

  static func fetchMakgeollisByAward(
    _ ref: RawClientRef, awardType: String, pageSize: Int, offset: Int
  ) async throws -> [Makgeolli] {
    let client = try requireClient(ref)
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
  }

  static func fetchMakgeolliById(_ ref: RawClientRef, id: UUID) async throws -> Makgeolli? {
    let client = try requireClient(ref)
    do {
      let result: [Makgeolli] = try await client
        .from("makgeolli")
        .select()
        .eq("id", value: id.uuidString)
        .execute()
        .value
      return result.first
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }

  static func searchMakgeollis(_ ref: RawClientRef, query: String) async throws -> [Makgeolli] {
    let client = try requireClient(ref)
    do {
      // 공백을 무시하고 검색하는 RPC 함수 사용
      let result: [Makgeolli] = try await client
        .rpc("search_makgeolli_flexible", params: ["search_query": query])
        .execute()
        .value
      return result
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }

  static func requestRegisterMakgeolli(
    _ ref: RawClientRef, searchText: String
  ) async throws {
    let client = try requireClient(ref)
    do {
      let result: PostgrestResponse = try await client
        .from("makgeolli_requests")
        .insert(["search_text": searchText])
        .execute()

      if result.status != 201 {
        throw SupabaseClientError(code: .failToSaveRequest, underlying: nil)
      }
    } catch {
      throw SupabaseClientError(code: .failToSaveRequest, underlying: error)
    }
  }

  static func fetchTopLikedMakgeollis(_ ref: RawClientRef) async throws -> [Makgeolli] {
    let client = try requireClient(ref)
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
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }
}
