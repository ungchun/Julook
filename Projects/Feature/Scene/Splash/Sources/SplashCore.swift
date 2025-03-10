//
//  SplashCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core

import ComposableArchitecture

@Reducer
public struct SplashCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    public var currentImageIndex: Int = 0
    public var isAnimating: Bool = false
    
    public init() { }
  }
  
  public enum Action {
    case onAppear
    
    case updateImageIndex
    case timerTick
  }
  
  private enum CancelID { case timer }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.currentImageIndex = 0
        state.isAnimating = true
        return .run { send in
          for await _ in Timer.publish(every: 1/18, on: .main, in: .common).autoconnect().values {
            await send(.timerTick)
          }
        }
        .cancellable(id: CancelID.timer)
        
      case .timerTick:
        return .send(.updateImageIndex)
        
      case .updateImageIndex:
        state.currentImageIndex = (state.currentImageIndex + 1) % 20
        return .none
      }
    }
  }
}
