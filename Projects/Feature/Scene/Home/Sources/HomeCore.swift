//
//  HomeCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct HomeCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    public init() { }
  }
  
  public enum Action {
    case onAppear
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
      }
    }
  }
}
