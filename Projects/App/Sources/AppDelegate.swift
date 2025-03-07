//
//  AppDelegate.swift
//  App
//
//  Created by Kim SungHun on 3/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import UIKit

import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {
  let store = StoreOf<AppDelegateCore>.init(
    initialState: .init(),
    reducer: {
      AppDelegateCore()
    }
  )
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    store.send(.didFinishLaunching)
    return true
  }
}
