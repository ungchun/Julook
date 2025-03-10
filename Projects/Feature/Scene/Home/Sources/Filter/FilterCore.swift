//
//  FilterCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core

import ComposableArchitecture
import Supabase

@Reducer
public struct FilterCore {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public var selectedFilters: Set<FilterType> = []
    public var initSelectedFilters: FilterType?
    public var showSortOptions: Bool = false
    public var selectedSort: SortOption = .recommended
    
    public init(
      initSelectedFilters: FilterType? = nil
    ) {
      self.initSelectedFilters = initSelectedFilters
    }
  }
  
  public enum Action {
    case onAppear
    
    case toggleFilter(FilterType)
    case toggleSortOptions
    case selectSort(SortOption)
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
