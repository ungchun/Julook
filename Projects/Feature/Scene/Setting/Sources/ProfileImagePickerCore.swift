//
//  ProfileImagePickerCore.swift
//  FeatureSetting
//
//  Created by Kim SungHun on 9/23/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core

import ComposableArchitecture

@Reducer
public struct ProfileImagePickerCore {
  @ObservableState
  public struct State: Equatable {
    public var selectedProfileImage: String = "p1"
    public var currentUserProfileImage: String = "p1"
    
    public init(currentProfileImage: String = "p1") {
      self.currentUserProfileImage = currentProfileImage
      self.selectedProfileImage = currentProfileImage
    }
  }
  
  public enum Action {
    case onAppear
    case dismiss
    case profileImageSelected(String)
    case saveButtonTapped
    case profileImageUpdated
    case profileImageUpdateFailed
  }
  
  public init() { }
  
  @Dependency(\.userClient) var userClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
        
      case .dismiss:
        return .none
        
      case let .profileImageSelected(imageName):
        state.selectedProfileImage = imageName
        return .none
        
      case .saveButtonTapped:
        let selectedImage = state.selectedProfileImage
        let userClient = self.userClient
        return .run { send in
          do {
            try await userClient.updateProfileImage(selectedImage)
            await send(.profileImageUpdated)
          } catch {
            await send(.profileImageUpdateFailed)
          }
        }
        
      case .profileImageUpdated:
        return .none
        
      case .profileImageUpdateFailed:
        return .none
      }
    }
  }
}
