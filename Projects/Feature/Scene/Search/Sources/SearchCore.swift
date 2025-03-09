//
//  SearchCore.swift
//  FeatureTabs
//
//  Created by Kim SungHun on 3/5/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct SearchCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    public init() { }
  }
  
  public enum Action { }
  
  public var body: some Reducer<State, Action> {
    EmptyReducer()
  }
}
