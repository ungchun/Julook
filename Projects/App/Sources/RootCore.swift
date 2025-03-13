//
//  RootCore.swift
//  App
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import MainCoordinator

import FeatureTabs
import FeatureSplash

import ComposableArchitecture

@Reducer
public struct RootCore {
  @Reducer
  public enum Destination {
    case splash(SplashCore)
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
    case onAppear
    
    case splashCompleted
    
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
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
        state.destination = .splash(SplashCore.State())
        return .run { send in
          try await Task.sleep(for: .seconds(3))
          await send(.splashCompleted)
        }
        
      case .splashCompleted:
        state.destination = .mainCoordinator(
          MainCoordinatorCore.State(
            routes: [.root(.tabs(TabCore.State()),
                           embedInNavigationView: true)]
          )
        )
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}
