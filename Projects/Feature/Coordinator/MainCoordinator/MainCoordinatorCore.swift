//
//  MainCoordinatorCore.swift
//  Feature
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import FeatureTabs
import FeatureHome

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
public enum MainScreen {
  case tabs(TabCore)
  case filter(FilterCore)
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
      case .router(.routeAction(id: _, action: .tabs(.homeTab(.moveToFilter)))):
        state.routes.push(.filter(.init()))
        
      case let .router(.routeAction(
        id: _, action: .tabs(.homeTab(.moveToFilterWithSelection(filterName))))):
        state.routes.push(.filter(.init(initSelectedFilters: filterName)))
        return .none
        
      case let .router(.routeAction(
        id: _, action: .tabs(.homeTab(.moveToFilterWithTopic(title))))):
        state.routes.push(.filter(.init(topicTitle: title)))
        return .none
        
      default:
        break
      }
      
      return .none
    }
    .forEachRoute(\.routes, action: \.router)
  }
}
