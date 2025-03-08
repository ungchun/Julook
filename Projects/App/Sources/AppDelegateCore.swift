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
  }
  
  enum Action {
    case didFinishLaunching
    
    // supabase
    case setupSupabase
    
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
          // TODO: ERROR
          return .none
        }
        let trimmedKey = supabaseKey.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        guard let supabaseURL = URL(string: "https://avfwwfpwpdpsoegwehry.supabase.co") else {
          // TODO: ERROR
          return .none
        }
        SupabaseManager.shared.initialize(supabaseURL: supabaseURL, supabaseKey: trimmedKey)
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
