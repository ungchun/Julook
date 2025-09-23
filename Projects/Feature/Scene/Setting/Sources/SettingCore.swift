//
//  SettingCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 9/21/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import UIKit
import StoreKit

import Core

import ComposableArchitecture

@Reducer
public struct SettingCore {
  @ObservableState
  public struct State: Equatable {
    public var user: UserEntity?
    public var isLoadingUser: Bool = false

    public init() { }
  }
  
  public enum Action {
    case onAppear
    case dismiss
    case contactTapped
    case reviewTapped
    case termsTapped
    case privacyTapped
    case loadUser
    case userLoaded(UserEntity?)
    case profileImageTapped
    case moveToProfileImagePicker(String)
  }
  
  public init() { }
  
  @Dependency(\.userClient) var userClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .send(.loadUser)

      case .dismiss:
        return .none

      case .profileImageTapped:
        let currentProfileImage = state.user?.profileImage ?? "p1"
        return .send(.moveToProfileImagePicker(currentProfileImage))
        
      case .loadUser:
        state.isLoadingUser = true
        let userClient = self.userClient
        return .run { send in
          do {
            let user = try await userClient.getUser()
            await send(.userLoaded(user))
          } catch {
            await send(.userLoaded(nil))
          }
        }
        
      case let .userLoaded(user):
        state.isLoadingUser = false
        state.user = user
        return .none

      case .moveToProfileImagePicker:
        return .none
        
      case .contactTapped:
        return .run { _ in
          await MainActor.run {
            if let url = URL(string: "mailto:julookOfficial@gmail.com") {
              UIApplication.shared.open(url)
            }
          }
        }
        
      case .reviewTapped:
        return .run { _ in
          await MainActor.run {
            let reviewURL = "https://apps.apple.com/app/id6743315707?action=write-review"
            if let url = URL(string: reviewURL) {
              UIApplication.shared.open(url)
            }
          }
        }
        
      case .termsTapped:
        return .run { _ in
          await MainActor.run {
            if let url = URL(string: "https://yawner.notion.site/1c792ec2705581ec8b98d5b25d5d94ab") {
              UIApplication.shared.open(url)
            }
          }
        }
        
      case .privacyTapped:
        return .run { _ in
          await MainActor.run {
            if let url = URL(string: "https://yawner.notion.site/1c792ec270558160a0f0c57392e4d1de") {
              UIApplication.shared.open(url)
            }
          }
        }
      }
    }
  }
}
