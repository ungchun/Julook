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

@DependencyClient
public struct SupabaseClient: Sendable {
  public var initialize: @Sendable () async -> Void
  
  public var fetchNewReleases: @Sendable () async throws -> [Makgeolli]
  public var fetchAwards: @Sendable () async throws -> [Award]
  public var getPublicURL: @Sendable (String, String) async throws -> URL
}

extension SupabaseClient: DependencyKey {
  public static var liveValue: SupabaseClient {
    let clientRef = LockIsolated<Supabase.SupabaseClient?>(nil)
    
    return SupabaseClient(
      initialize: {
        // TODO: 강제 언래핑 수정
        let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_KEY"] as! String
        let trimmedKey = supabaseKey.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let client = Supabase.SupabaseClient(
          supabaseURL: URL(string: "https://avfwwfpwpdpsoegwehry.supabase.co")!,
          supabaseKey: trimmedKey
        )
        clientRef.setValue(client)
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
      
      getPublicURL: { bucket, path in
        guard let client = clientRef.value else {
          throw SupabaseClientError(
            code: .clientNotInitialized,
            underlying: nil
          )
        }
        
        return try client.storage.from(bucket).getPublicURL(path: path)
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
    case unknownError
  }
}
