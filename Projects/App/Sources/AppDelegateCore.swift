//
//  AppDelegateCore.swift
//  App
//
//  Created by Kim SungHun on 3/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core

import ComposableArchitecture
import Supabase

@Reducer
struct AppDelegateCore {  
  @ObservableState
  struct State: Equatable {
    var supabaseInitialized: Bool = false
  }
  
  enum Action {
    case didFinishLaunching
    
    // supabase
    case setupSupabase
    case supabaseInitialized(Bool)
    
    case logError(AppDelegateCoreError)
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .didFinishLaunching:
        return .run { send in
          await send(.setupSupabase)
        }
        
      case .setupSupabase:
        guard let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String else {
          return .send(.supabaseInitialized(false))
        }
        let trimmedKey = supabaseKey.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        guard let supabaseURL = URL(string: "https://avfwwfpwpdpsoegwehry.supabase.co") else {
          return .send(.supabaseInitialized(false))
        }
        SupabaseManager.shared.initialize(supabaseURL: supabaseURL, supabaseKey: trimmedKey)
        return .send(.supabaseInitialized(true))
        
      case let .supabaseInitialized(success):
        state.supabaseInitialized = success
        if success {
          return .run { send in
            do {
              let client = SupabaseManager.shared.client
              if let client = client {
                let session = try await client.auth.session
                Log.debug("supabase active \(session.user.id)")
              }
            } catch {
              await send(.logError(AppDelegateCoreError(
                code: .failToSupabaseInitialized,
                underlying: error
              )))
            }
          }
        } else {
          // fail supabase init
        }
        return .none
        
      case let .logError(error):
        return .run { _ in
          Log.error(error)
        }
      }
    }
  }
}

public struct AppDelegateCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?
  
  public enum Code: Int, Sendable {
    case failToSupabaseInitialized
  }
}
