//
//  RootCore.swift
//  App
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import MainCoordinator

import FeatureTabs

import ComposableArchitecture

@Reducer
public struct RootCore {
  @Reducer
  public enum Destination {
    case mainCoordinator(MainCoordinatorCore)
  }
  
  @ObservableState
  public struct State {
    @Presents var destination: Destination.State?
    
    public init(
      destination: Destination.State? = nil
    ) {
      self.destination = destination
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    
    case onAppear
  }
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .destination:
        return .none
        
      case .onAppear:
        state.destination = .mainCoordinator(
          MainCoordinatorCore.State(
            routes: [.root(.tabs(TabCore.State()),
                           embedInNavigationView: true)]
          )
        )
        return .none
      }
    }
  }
}
