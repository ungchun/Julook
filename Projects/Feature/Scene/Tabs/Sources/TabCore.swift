//
//  TabCore.swift
//  FeatureTabs
//
//  Created by Kim SungHun on 3/5/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import FeatureHome
import FeatureSearch
import FeatureMyMakgeolli

import ComposableArchitecture

public enum Tab: Equatable {
  case home
  case search
  case myMakgeolli
}

@Reducer
public struct TabCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    var selectedTab: Tab
    
    var homeTab: HomeCore.State
    var searchTab: SearchCore.State
    var myMakgeolliTab: MyMakgeolliCore.State
    
    public init(
      selectedTab: Tab = .home,
      
      homeTab: HomeCore.State = .init(),
      searchTab: SearchCore.State = .init(),
      myMakgeolliTab: MyMakgeolliCore.State = .init()
    ) {
      self.selectedTab = selectedTab
      
      self.homeTab = homeTab
      self.searchTab = searchTab
      self.myMakgeolliTab = myMakgeolliTab
    }
  }
  
  public enum Action {
    case tabSeoected(Tab)
    
    case homeTab (HomeCore.Action)
    case searchTab (SearchCore.Action)
    case myMakgeolliTab (MyMakgeolliCore.Action)
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.homeTab, action: \.homeTab) {
      HomeCore()
    }
    
    Scope(state: \.searchTab, action: \.searchTab) {
      SearchCore()
    }
    
    Scope(state: \.myMakgeolliTab, action: \.myMakgeolliTab) {
      MyMakgeolliCore()
    }
    
    Reduce { state, action in
      switch action {
      case let .tabSeoected(tab):
        state.selectedTab = tab
        return .none
        
      case .homeTab:
        return .none
        
      case .searchTab:
        return .none
        
      case .myMakgeolliTab:
        return .none
      }
    }
  }
}
