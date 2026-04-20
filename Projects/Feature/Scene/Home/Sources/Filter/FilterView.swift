import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct FilterView: View {
  @Bindable var store: StoreOf<FilterCore>

  public init(store: StoreOf<FilterCore>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()

      VStack {
        if !store.isTopicMode {
          FilterOptionsView(store: store)
        }

        ScrollViewReader { proxy in
          ScrollView {
            Color.clear
              .frame(height: 1)
              .id("SCROLL_TOP")

            SortOptionsView(store: store)

            MakgeolliGridView(store: store)
          }
          .onChange(of: store.scrollToTop) { _, newValue in
            if newValue {
              proxy.scrollTo("SCROLL_TOP", anchor: .top)
              store.send(.resetScroll)
            }
          }
        }
      }
    }
    .accentColor(DesignSystemAsset.Colors.primary.swiftUIColor)
    .addNavigationBar(
      title: store.isTopicMode
      ? store.topicTitle : "특징으로 찾기"
    )
    .onAppear { store.send(.onAppear) }
  }
}
