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
import Functions

public enum Bucket {
  public static let MAKGEOLLIIMAGE = "makgeolli_image"
}

@DependencyClient
public struct SupabaseClient: Sendable {
  public var initialize: @Sendable () async -> Void

  public var fetchNewReleases: @Sendable () async throws -> [Makgeolli]
  public var fetchRandomMakgeollis: @Sendable () async throws -> [Makgeolli]
  public var fetchAwards: @Sendable () async throws -> [Award]
  public var fetchMakgeollis: @Sendable (Int, Int) async throws -> [Makgeolli]
  public var fetchMakgeolliTranslations: @Sendable (SupportedLocale) async throws -> [MakgeolliTranslation]
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
  public var getPublicComments: @Sendable (UUID) async throws -> [UserComment]
  public var getUserReaction: @Sendable (UUID, UUID) async throws -> String?
  public var getUserComments: @Sendable (UUID) async throws -> [UserComment]
  public var getRecentComments: @Sendable () async throws -> [UserComment]
  public var getRecentCommentsPaginated: @Sendable (Int, Int) async throws -> [UserComment]
  public var analyzeLabelImage: @Sendable (Data) async throws -> LabelAnalysisResult
}

public extension DependencyValues {
  var supabaseClient: SupabaseClient {
    get { self[SupabaseClient.self] }
    set { self[SupabaseClient.self] = newValue }
  }
}
