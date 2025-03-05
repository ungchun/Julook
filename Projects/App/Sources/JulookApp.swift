//
//  JulookApp.swift
//  App
//
//  Created by Kim SungHun on 3/5/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import ComposableArchitecture

@main
struct JulookApp: App {
  var body: some Scene {
    WindowGroup {
      RootView(
        store: Store(
          initialState: RootCore.State(),
          reducer: RootCore.init
        )
      )
    }
  }
}
