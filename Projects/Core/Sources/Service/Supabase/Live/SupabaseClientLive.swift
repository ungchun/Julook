import Foundation

import ComposableArchitecture
import Supabase

typealias RawClientRef = LockIsolated<Supabase.SupabaseClient?>

enum SupabaseClientLive {
  static func requireClient(_ ref: RawClientRef) throws -> Supabase.SupabaseClient {
    guard let client = ref.value else {
      throw SupabaseClientError(code: .clientNotInitialized, underlying: nil)
    }
    return client
  }

  static func initialize(_ ref: RawClientRef) async {
    do {
      guard let supabaseKeyValue = Bundle.main.infoDictionary?["SUPABASE_KEY"]
              as? String else {
        throw SupabaseClientError(code: .clientNotInitialized, underlying: nil)
      }
      let trimmedKey = supabaseKeyValue.trimmingCharacters(
        in: CharacterSet(charactersIn: "\"")
      )
      guard let supabaseURL = URL(string: "https://avfwwfpwpdpsoegwehry.supabase.co") else {
        throw SupabaseClientError(code: .clientNotInitialized, underlying: nil)
      }
      let client = Supabase.SupabaseClient(
        supabaseURL: supabaseURL,
        supabaseKey: trimmedKey
      )
      ref.setValue(client)
    } catch {
      Log.error(error)
    }
  }
}

extension SupabaseClient: DependencyKey {
  public static var liveValue: SupabaseClient {
    let ref = RawClientRef(nil)

    return SupabaseClient(
      initialize: { await SupabaseClientLive.initialize(ref) },
      fetchNewReleases: { try await SupabaseClientLive.fetchNewReleases(ref) },
      fetchRandomMakgeollis: { try await SupabaseClientLive.fetchRandomMakgeollis(ref) },
      fetchAwards: { try await SupabaseClientLive.fetchAwards(ref) },
      fetchMakgeollis: { try await SupabaseClientLive.fetchMakgeollis(ref, limit: $0, offset: $1) },
      fetchMakgeolliTranslations: { locale in
        try await SupabaseClientLive.fetchMakgeolliTranslations(ref, locale: locale)
      },
      fetchFilteredMakgeollis: {
        try await SupabaseClientLive.fetchFilteredMakgeollis(
          ref, pageSize: $0, offset: $1, filters: $2
        )
      },
      fetchMakgeollisByAward: {
        try await SupabaseClientLive.fetchMakgeollisByAward(
          ref, awardType: $0, pageSize: $1, offset: $2
        )
      },
      fetchMakgeolliById: { try await SupabaseClientLive.fetchMakgeolliById(ref, id: $0) },
      getPublicURL: { try await SupabaseClientLive.getPublicURL(ref, bucket: $0, path: $1) },
      searchMakgeollis: { try await SupabaseClientLive.searchMakgeollis(ref, query: $0) },
      requestRegisterMakgeolli: {
        try await SupabaseClientLive.requestRegisterMakgeolli(ref, searchText: $0)
      },
      saveReaction: {
        try await SupabaseClientLive.saveReaction(ref, userId: $0, makgeolliId: $1, reactionType: $2)
      },
      getReaction: {
        try await SupabaseClientLive.getReaction(ref, userId: $0, makgeolliId: $1)
      },
      getReactionCounts: {
        try await SupabaseClientLive.getReactionCounts(ref, makgeolliId: $0)
      },
      deleteReaction: {
        try await SupabaseClientLive.deleteReaction(ref, userId: $0, makgeolliId: $1)
      },
      fetchTopLikedMakgeollis: { try await SupabaseClientLive.fetchTopLikedMakgeollis(ref) },
      getUserComment: {
        try await SupabaseClientLive.getUserComment(ref, userId: $0, makgeolliId: $1)
      },
      saveUserComment: {
        try await SupabaseClientLive.saveUserComment(
          ref, userId: $0, makgeolliId: $1, comment: $2, isPublic: $3
        )
      },
      deleteUserComment: {
        try await SupabaseClientLive.deleteUserComment(ref, userId: $0, makgeolliId: $1)
      },
      getPublicComments: {
        try await SupabaseClientLive.getPublicComments(ref, makgeolliId: $0)
      },
      getUserReaction: {
        try await SupabaseClientLive.getUserReaction(ref, userId: $0, makgeolliId: $1)
      },
      getUserComments: { try await SupabaseClientLive.getUserComments(ref, userId: $0) },
      getRecentComments: { try await SupabaseClientLive.getRecentComments(ref) },
      getRecentCommentsPaginated: {
        try await SupabaseClientLive.getRecentCommentsPaginated(ref, limit: $0, offset: $1)
      },
      analyzeLabelImage: { try await SupabaseClientLive.analyzeLabelImage(ref, imageData: $0) }
    )
  }
}
