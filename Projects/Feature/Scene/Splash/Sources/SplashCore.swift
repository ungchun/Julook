//
//  SplashCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import SwiftData

import Core

import ComposableArchitecture

@Reducer
public struct SplashCore {
  public init() { }

  @Dependency(\.userClient) var userClient
  
  @ObservableState
  public struct State: Equatable {
    public var currentImageIndex: Int = 0
    public var isAnimating: Bool = false
    
    public init() { }
  }
  
  public enum Action {
    case onAppear
    case initializeUser
    
    case updateImageIndex
    case timerTick
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        as? String ?? "Unknown"
        Amp.track(event: "app_launched", properties: [
          "app_version": appVersion,
          "launch_time": dateFormatter.string(from: Date())
        ])
        
        state.currentImageIndex = 0
        state.isAnimating = true
        
        return .merge(
          .send(.initializeUser),
          .run { send in
            for await _ in Timer.publish(
              every: 1/18, on: .main, in: .common
            ).autoconnect().values {
              await send(.timerTick)
            }
          }
        )
        
      case .initializeUser:
        let userClient = self.userClient
        return .run { _ in
          do {
            _ = try await userClient.initializeUserProfile()
          } catch {
            // error
          }
        }
        
      case .timerTick:
        return .send(.updateImageIndex)
        
      case .updateImageIndex:
        state.currentImageIndex = (state.currentImageIndex + 1) % 20
        return .none
      }
    }
  }
}
