import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

public struct MyMakgeolliView: View {
  let store: StoreOf<MyMakgeolliCore>

  public init(store: StoreOf<MyMakgeolliCore>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()

      VStack(spacing: 0) {
        HeaderView()
        FilterTabsView()

        Group {
          if store.state.isLoading {
            VStack(spacing: 20) {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            }
            .frame(maxHeight: .infinity)
          } else if store.state.myMakgeollis.isEmpty {
            VStack(spacing: 20) {
              Text(L10n.MyMakgeolli.Empty.title)
                .foregroundColor(.w50)
                .font(.SF17R)

              DesignSystemAsset.Images.searchJulook.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            }
            .frame(maxHeight: .infinity)
          } else {
            VStack(spacing: 0) {
              GeometryReader { geometry in
                ScrollView {
                  LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
                    spacing: 16
                  ) {
                    ForEach(store.state.myMakgeollis, id: \.id) { makgeolli in
                      MyMakgeolliGridItem(
                        makgeolli: makgeolli,
                        imageURL: store.state.makgeolliImages[makgeolli.id],
                        reactionType: getReactionType(for: makgeolli, state: store.state),
                        hasComment: hasComment(for: makgeolli, state: store.state)
                      )
                      .frame(width: (geometry.size.width - 32 - 32) / 3)
                      .background(
                        Rectangle()
                          .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
                          .cornerRadius(18)
                      )
                      .onTapGesture {
                        store.send(.myMakgeolliItemTapped(makgeolli))
                      }
                    }
                  }.padding(.horizontal, 16)

                  Spacer()
                    .frame(height: 16)
                }
              }
            }
          }
        }
      }
    }
    .onAppear {
      store.send(.viewAppeared)
    }
    .onReceive(NotificationCenter.default.publisher(for: .myMakgeolliDataChanged)) { _ in
      store.send(.myMakgeolliDataChanged)
    }
  }
}
