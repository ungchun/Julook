import SwiftUI

import MainCoordinator
import FeatureSplash
import FeatureSetting
import DesignSystem

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
          state: \.destination?.nicknameChange,
          action: \.destination.nicknameChange
        ) {
          NicknameChangeView(store: store)
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
    .alert("업데이트가 필요합니다", isPresented: $store.showUpdateAlert) {
      Button("업데이트") {
        store.send(.updateButtonTapped)
      }
    } message: {
      Text("더 나은 서비스를 위해 주룩이 수정되었어요!")
    }
    .toast(
      message: store.toastMessage,
      type: store.toastType,
      isShowing: $store.showToast
    )
  }
}
