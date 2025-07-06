//
//  MyMakgeolliCore.swift
//  FeatureMyMakgeolli
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct MyMakgeolliCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    public init() { }
  }
  
  public enum Action {
    case viewAppeared
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .viewAppeared:
        return .none
      }
    }
  }
}
