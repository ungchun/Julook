import SwiftUI

import Core
import DesignSystem

struct CommentItem: View {
  let comment: UserComment
  let makgeolliName: String
  let reactionType: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 8) {
        Group {
          if let reactionType = reactionType {
            if reactionType == "like" {
              DesignSystemAsset.Images.circleLike.swiftUIImage
                .resizable()
            } else if reactionType == "dislike" {
              DesignSystemAsset.Images.circleDislike.swiftUIImage
                .resizable()
            } else {
              DesignSystemAsset.Images.circleNone.swiftUIImage
                .resizable()
            }
          } else {
            DesignSystemAsset.Images.circleNone.swiftUIImage
              .resizable()
          }
        }
        .frame(width: 14, height: 14)

        Spacer()

        Text(formatShortDate(comment.createdAt))
          .foregroundColor(.w50)
          .font(.SF12R)
      }

      Text(comment.comment)
        .foregroundColor(.w85)
        .font(.SF14R)
        .lineLimit(nil)
        .multilineTextAlignment(.leading)
    }
    .padding(.vertical, 8)
  }

  private func formatShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일"
    return formatter.string(from: date)
  }
}
