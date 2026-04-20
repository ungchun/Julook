import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct HomeView: View {
  let store: StoreOf<HomeCore>

  public init(store: StoreOf<HomeCore>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 20) {
          HeaderView()

          MakgeolliFilterView(store: store)

          RandomMakgeolliView(store: store)

          TodaysRankingView(store: store)

          NewReleasesView(store: store)

          MakgeolliTopicView(store: store)

          RecentCommentsView(store: store)
        }
      }
    }
    .onAppear { store.send(.onAppear) }
  }
}
