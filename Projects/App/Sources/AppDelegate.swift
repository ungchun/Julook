//
//  AppDelegate.swift
//  App
//
//  Created by Kim SungHun on 3/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import UIKit

import Core

import ComposableArchitecture
import Firebase

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
    FirebaseApp.configure()
    if let key = Bundle.main.infoDictionary?["AMPLITUDE_KEY"] as? String {
      Amp.configure(apiKey: key)
    }
    
    store.send(.didFinishLaunching)
    return true
  }
}
