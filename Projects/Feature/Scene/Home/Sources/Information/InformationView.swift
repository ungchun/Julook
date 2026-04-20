import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

public struct InformationView: View {
  let store: StoreOf<InformationCore>

  public init(store: StoreOf<InformationCore>) {
    self.store = store
  }

  public var body: some View {
    if #available(iOS 26.0, *) {
      NavigationView {
        ZStack {
          DesignSystemAsset.Colors.darkbase.swiftUIColor
            .ignoresSafeArea()

          ScrollView {
            VStack(spacing: 0) {
              MakgeolliDetailSectionView()

              ReactionButtonsView()

              MyCommentSection()

              AwardsView()

              MakgeolliEvaluationAndCommentsSection()

              MakgeolliIngredientsSection()

              BreweryWebsiteSection()
            }
            .padding(.horizontal, 16)
          }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Image(systemName: store.state.isFavorite ? "heart.fill" : "heart")
              .font(.SF17B)
              .foregroundColor(store.state.isFavorite ? .red : .w25)
              .onTapGesture {
                store.send(.favoriteButtonTapped)
              }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Image(systemName: "xmark")
              .foregroundColor(.w)
              .font(.system(size: 16, weight: .bold))
              .onTapGesture {
                store.send(.dismiss)
              }
          }
        }
        .accentColor(DesignSystemAsset.Colors.primary.swiftUIColor)
      }
      .sheet(isPresented: .init(
        get: { store.state.isShowingCommentsSheet },
        set: { store.send(.showCommentsSheet($0)) }
      )) {
        AllCommentsSheetView(store: store)
      }
      .onAppear {
        store.send(.onAppear)
      }
    } else {
      ZStack {
        DesignSystemAsset.Colors.darkbase.swiftUIColor
          .ignoresSafeArea()

        ScrollView {
          VStack(spacing: 0) {
            NavigationBar()

            MakgeolliDetailSectionView()

            ReactionButtonsView()

            MyCommentSection()

            AwardsView()

            MakgeolliEvaluationAndCommentsSection()

            MakgeolliIngredientsSection()

            BreweryWebsiteSection()
          }
          .padding(.horizontal, 16)
        }
      }
      .accentColor(DesignSystemAsset.Colors.primary.swiftUIColor)
      .sheet(isPresented: .init(
        get: { store.state.isShowingCommentsSheet },
        set: { store.send(.showCommentsSheet($0)) }
      )) {
        AllCommentsSheetView(store: store)
      }
      .onAppear {
        store.send(.onAppear)
      }
    }
  }
}
