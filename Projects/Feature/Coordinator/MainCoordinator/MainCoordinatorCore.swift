//
//  MainCoordinatorCore.swift
//  Feature
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import FeatureTabs

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
public enum MainScreen {
  case tabs(TabCore)
}

@Reducer
public struct MainCoordinatorCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    var routes: [Route<MainScreen.State>]
    
    public init(routes: [Route<MainScreen.State>]) {
      self.routes = routes
    }
  }
  
  public enum Action {
    case router(IndexedRouterActionOf<MainScreen>)
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .router(.routeAction(id: _, action: .tabs)):
        return .none
        
      default:
        return .none
      }
    }
    .forEachRoute(\.routes, action: \.router)
  }
}
