import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

extension MyMakgeolliView {
  @ViewBuilder
  func HeaderView() -> some View {
    ZStack {
      Text(L10n.MyMakgeolli.title)
        .font(.SF17B)
        .foregroundColor(.w)

      HStack {
#if DEBUG
        Button(L10n.MyMakgeolli.Reset.button) {
          Task {
            do {
              try await CloudKitResetHelper.resetAllData()
              store.send(.loadReactionData)
            } catch {
              Log.debug("Reset failed: \(error)")
            }
          }
        }
        .padding(.horizontal, 32)
        .foregroundColor(.red)
        .font(.SF12R)
#endif

        Spacer()
      }
    }
    .frame(height: 44)
  }

  @ViewBuilder
  func FilterTabsView() -> some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        ForEach(MyMakgeolliFilterTab.allCases, id: \.self) { tab in
          VStack(spacing: 0) {
            Spacer()

            Text(tab.displayName)
              .font(.SF15R)
              .foregroundColor(store.state.selectedTab == tab ? .w : .w50)
              .onTapGesture {
                store.send(.tabSelected(tab))
              }

            Spacer()

            Rectangle()
              .fill(store.state.selectedTab == tab ? .primary2 : Color.clear)
              .frame(height: 3)
              .animation(.easeInOut(duration: 0.2), value: store.state.selectedTab)
          }
          .frame(width: geometry.size.width / 5)
        }
      }
    }
    .frame(height: 44)
    .padding(.bottom, 16)
  }

  func getReactionType(
    for makgeolli: MyMakgeolliEntity,
    state: MyMakgeolliCore.State
  ) -> String? {
    if state.likedMakgeollis.contains(where: { $0.id == makgeolli.id }) {
      return "like"
    }
    if state.dislikedMakgeollis.contains(where: { $0.id == makgeolli.id }) {
      return "dislike"
    }
    return nil
  }

  func hasComment(
    for makgeolli: MyMakgeolliEntity,
    state: MyMakgeolliCore.State
  ) -> Bool {
    state.commentMakgeollis.contains(where: { $0.id == makgeolli.id })
  }
}
