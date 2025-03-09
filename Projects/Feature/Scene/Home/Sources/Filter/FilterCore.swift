//
//  FilterCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import ComposableArchitecture
import Supabase

@Reducer
public struct FilterCore {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public var selectedFilters: Set<String> = []
    public var initSelectedFilters: String?
    public var showSortOptions: Bool = false
    
    // TODO: enum
    public var selectedSort: String = "추천순"
    public var sortOptions: [String] = ["추천순", "높은 도수순", "낮은 도수순"]
    
    public init(
      initSelectedFilters: String? = nil
    ) {
      self.initSelectedFilters = initSelectedFilters
    }
  }
  
  public enum Action {
    case onAppear
    
    case toggleFilter(String)
    case toggleSortOptions
    case selectSort(String)
    case dismissSortOptions
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        if let filter = state.initSelectedFilters {
          state.selectedFilters.insert(filter)
        }
        return .none
        
      case let .toggleFilter(filter):
        if state.selectedFilters.contains(filter) {
          state.selectedFilters.remove(filter)
        } else {
          state.selectedFilters.insert(filter)
        }
        return .none
        
      case .toggleSortOptions:
        state.showSortOptions.toggle()
        return .none
        
      case let .selectSort(sort):
        state.selectedSort = sort
        state.showSortOptions = false
        return .none
        
      case .dismissSortOptions:
        state.showSortOptions = false
        return .none
      }
    }
  }
}
