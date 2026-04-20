import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct AllCommentsSheetView: View {
  let store: StoreOf<InformationCore>

  var body: some View {
    NavigationView {
      ZStack {
        DesignSystemAsset.Colors.darkbase.swiftUIColor
          .ignoresSafeArea()

        if store.state.publicComments.isEmpty {
          VStack(spacing: 20) {
            Text("공개된 코멘트가 없어요")
              .foregroundColor(.w50)
              .font(.SF17R)

            DesignSystemAsset.Images.searchJulook.swiftUIImage
              .resizable()
              .scaledToFit()
              .frame(height: 140)
          }
          .frame(maxHeight: .infinity)
        } else {
          ScrollView {
            LazyVStack(spacing: 0) {
              ForEach(Array(store.state.publicComments.enumerated()), id: \.element.id) { idx, comment in
                CommentItem(
                  comment: comment,
                  makgeolliName: store.state.makgeolli.name,
                  reactionType: getUserReaction(for: comment.userId)
                )

                if idx != store.state.publicComments.count - 1 {
                  Divider()
                    .padding(.vertical, 12)
                }
              }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
          }
        }
      }
      .navigationTitle("코멘트")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  private func getUserReaction(for userId: UUID) -> String? {
    return store.state.userReactions[userId]
  }
}
