//
//  RootCore.swift
//  App
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import Core
import DesignSystem
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
    var isCheckingForUpdates: Bool = false
    var showUpdateAlert: Bool = false
    var latestVersion: String = ""
    var currentVersion: String = ""
    
    var showToast: Bool = false
    var toastMessage: String = ""
    var toastType: ToastType = .error
    
    public init(
      destination: Destination.State? = nil
    ) {
      self.destination = destination
    }
  }
  
  public enum Action: BindableAction {
    case onAppear
    
    case splashCompleted
    case checkForUpdatesResponse(TaskResult<String>)
    case updateButtonTapped
    case dismissUpdateAlert
    
    case showToast(String, ToastType)
    case dismissToast
    
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
  }
  
  @Dependency(\.bundleClient) var bundleClient
  @Dependency(\.versionCheckClient) var versionCheckClient
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.destination = .splash(SplashCore.State())
        state.isCheckingForUpdates = true
        
        let versionCheckClient = self.versionCheckClient
        
        return .merge(
          .run { send in
            try await Task.sleep(for: .seconds(2))
            
            await send(.checkForUpdatesResponse(
              TaskResult { try await versionCheckClient.checkForUpdate() }
            ))
          },
          .run { send in
            for await notification in NotificationCenter.default.notifications(named: .showToast) {
              if let userInfo = notification.userInfo,
                 let message = userInfo["message"] as? String,
                 let typeRaw = userInfo["type"] as? String,
                 let type = ToastType(rawValue: typeRaw) {
                await send(.showToast(message, type))
              }
            }
          }
        )
        
      case let .checkForUpdatesResponse(.success(latestVersion)):
        state.isCheckingForUpdates = false
        state.latestVersion = latestVersion
        
        do {
          let currentVersion = try bundleClient.getCurrentVersion()
          state.currentVersion = currentVersion
          
          if versionCheckClient.isForceUpdateRequired(currentVersion, latestVersion) {
            state.showUpdateAlert = true
            return .none
          } else {
            return .send(.splashCompleted)
          }
        } catch {
          return .send(.splashCompleted)
        }
        
      case .checkForUpdatesResponse(.failure):
        state.isCheckingForUpdates = false
        return .send(.splashCompleted)
        
      case .updateButtonTapped:
        return .run { _ in
          await MainActor.run {
            if let url = URL(string: "https://apps.apple.com/app/6743315707") {
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
              }
            }
          }
        }
        
      case .dismissUpdateAlert:
        state.showUpdateAlert = false
        return .none
        
      case .splashCompleted:
        if !state.isCheckingForUpdates && !state.showUpdateAlert {
          state.destination = .mainCoordinator(
            MainCoordinatorCore.State(
              routes: [.root(.tabs(TabCore.State()),
                             embedInNavigationView: true)]
            )
          )
        }
        return .none
        
      case let .showToast(message, type):
        state.toastMessage = message
        state.toastType = type
        state.showToast = true
        return .none
        
      case .dismissToast:
        state.showToast = false
        return .none
        
      case .binding:
        return .none
        
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}
