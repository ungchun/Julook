import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct RecentCommentsView: View {
  let store: StoreOf<HomeCore>

  var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text(L10n.Home.Section.recentComments)
          .foregroundColor(.w)
          .font(.SF20B)

        DesignSystemAsset.Images.arrowRight.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 16)
          .foregroundColor(.w)

        Spacer()
      }
      .onTapGesture {
        Amp.track(event: "comment_list_header_clicked")
        store.send(.moveToCommentList)
      }
      .padding(.horizontal, 16)

      if store.isLoadingRecentComments {
        VStack(spacing: 12) {
          ForEach(0..<4, id: \.self) { _ in
            HStack(spacing: 16) {
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkgray)
                .frame(width: 60, height: 60)

              VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.darkgray)
                  .frame(height: 16)

                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.darkgray)
                  .frame(height: 12)

                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.darkgray)
                  .frame(width: 80, height: 12)
              }

              Spacer()
            }
            .padding(.horizontal, 16)
          }
        }
      } else {
        VStack(alignment: .leading, spacing: 0) {
          ForEach(Array(store.recentComments.enumerated()), id: \.element.id) { idx, comment in
            if let makgeolli = store.state.localizedRecentCommentMakgeolli(for: comment.makgeolliId) {
              RecentCommentItemView(
                comment: comment,
                makgeolli: makgeolli,
                imageUrl: store.recentCommentImages[makgeolli.id],
                reactionType: store.recentCommentReactions[comment.id],
                isLast: idx == store.recentComments.count - 1,
                onTap: {
                  Amp.track(event: "recent_comment_clicked", properties: [
                    "makgeolli_name": makgeolli.name
                  ])
                  store.send(.recentCommentItemTapped(comment))
                }
              )
              .equatable()
            }
          }
        }
        .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 20)
  }
}
