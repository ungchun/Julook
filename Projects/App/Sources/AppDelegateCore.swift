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
  
  @Dependency(\.supabaseClient) var supabaseClient
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .didFinishLaunching:
        return .run { send in
          await send(.setupSupabase)
        }
        
      case .setupSupabase:
        return .run { send in
          await supabaseClient.initialize()
        }
        
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
