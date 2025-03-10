import SwiftUI

import MainCoordinator
import FeatureSplash

import ComposableArchitecture

struct RootView: View {
  @Bindable var store: StoreOf<RootCore>
  
  init(store: StoreOf<RootCore>) {
    self.store = store
  }
  
  var body: some View {
    Group {
      switch store.destination {
      default:
        if let store = store.scope(
          state: \.destination?.splash,
          action: \.destination.splash
        ) {
          SplashView(store: store)
        }
        
        if let store = store.scope(
          state: \.destination?.mainCoordinator,
          action: \.destination.mainCoordinator
        ) {
          MainCoordinatorView(store: store)
        }
      }
    }
    .onAppear { store.send(.onAppear) }
  }
}
