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
    
    case setupSupabase
    case setupSwiftData
    
    case logError(AppDelegateCoreError)
  }
  
  @Dependency(\.supabaseClient) var supabaseClient
  @Dependency(\.myMakgeolliClient) var myMakgeolliClient
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .didFinishLaunching:
        return .run { send in
          await send(.setupSupabase)
          await send(.setupSwiftData)
        }
        
      case .setupSupabase:
        return .run { send in
          await supabaseClient.initialize()
        }
        
      case .setupSwiftData:
        return .run { send in
          do {
            try await myMakgeolliClient.initialize()
          } catch {
            await send(.logError(AppDelegateCoreError(code: .failToSwiftDataInitialized, underlying: error)))
          }
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
  
  public init(
    code: Code,
    underlying: Error? = nil
  ) {
    self.code = code
    self.underlying = underlying
  }
  
  public enum Code: Int, Sendable {
    case failToSupabaseInitialized
    case failToSwiftDataInitialized
  }
}
