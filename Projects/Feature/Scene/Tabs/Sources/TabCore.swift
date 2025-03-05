//
//  TabCore.swift
//  FeatureTabs
//
//  Created by Kim SungHun on 3/5/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import FeatureHome
import FeatureSearch

import ComposableArchitecture

public enum Tab: Equatable {
  case home
  case search
}

@Reducer
public struct TabCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    public init(
      selectedTab: Tab = .home
    ) {
      self.selectedTab = selectedTab
      self.homeTab = HomeCore.State()
      self.searchTab = SearchCore.State()
    }
    var selectedTab: Tab
    var homeTab: HomeCore.State
    var searchTab: SearchCore.State
  }
  
  public enum Action {
    case tabSeoected(Tab)
    case homeTab (HomeCore.Action)
    case searchTab (SearchCore.Action)
  }
  
  public var body: some Reducer<State, Action> {
    Scope(state: \.homeTab, action: \.homeTab) {
      HomeCore()
    }
    Scope(state: \.searchTab, action: \.searchTab) {
      SearchCore()
    }
    Reduce { state, action in
      switch action {
      case let .tabSeoected(tab):
        state.selectedTab = tab
        return .none
      case .homeTab, .searchTab:
        return .none
      }
    }
  }
}
