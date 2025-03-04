import SwiftUI

import FeatureHome

import ComposableArchitecture

@main
struct JulookApp: App {
  static let store = Store(initialState: CounterFeature.State()) {
    CounterFeature()
      ._printChanges()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView(store: JulookApp.store)
    }
  }
}
