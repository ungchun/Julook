import SwiftUI

import Core
import DesignSystem

extension InformationView {
  @ViewBuilder
  func MakgeolliEvaluationAndCommentsSection() -> some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack {
        Text("평가 및 코멘트")
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }

      if let reactionCounts = store.state.reactionCounts {
        let likeCount = reactionCounts.likeCount
        let dislikeCount = reactionCounts.dislikeCount
        let totalCount = likeCount + dislikeCount

        if totalCount > 0 {
          let likePercentage = Double(likeCount) / Double(totalCount) * 100
          let dislikePercentage = Double(dislikeCount) / Double(totalCount) * 100

          VStack(spacing: 4) {
            HStack {
              Text("\(String(format: "%.0f", likePercentage))%")
                .foregroundColor(.w85)
                .font(.SF14R)

              Spacer()

              GeometryReader { geometry in
                ZStack {
                  RoundedRectangle(cornerRadius: 4)
                    .fill(Color.w10)
                    .frame(width: geometry.size.width, height: 5)

                  RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(
                      gradient: Gradient(stops: [
                        .init(color: DesignSystemAsset.Colors.goldenyellow.swiftUIColor,
                              location: 0),
                        .init(color: DesignSystemAsset.Colors.goldenyellow.swiftUIColor,
                              location: CGFloat(likePercentage / 100)),
                        .init(color: DesignSystemAsset.Colors.lilac.swiftUIColor,
                              location: CGFloat(likePercentage / 100)),
                        .init(color: DesignSystemAsset.Colors.lilac.swiftUIColor,
                              location: 1)
                      ]),
                      startPoint: .leading,
                      endPoint: .trailing
                    ))
                    .frame(width: geometry.size.width, height: 5)
                }
              }
              .frame(height: 5)

              Spacer()

              Text("\(String(format: "%.0f", dislikePercentage))%")
                .foregroundColor(.w85)
                .font(.SF14R)
            }

            HStack {
              Text("좋았어요 (\(likeCount))")
                .foregroundColor(.w50)
                .font(.SF14R)

              Spacer()

              Text("아쉬워요 (\(dislikeCount))")
                .foregroundColor(.w50)
                .font(.SF14R)
            }
          }
        } else {
          VStack(spacing: 4) {
            HStack {
              Text("- %")
                .foregroundColor(.w)
                .font(.SF14R)

              Spacer()

              RoundedRectangle(cornerRadius: 4)
                .fill(Color.w10)
                .frame(height: 5)

              Spacer()

              Text("- %")
                .foregroundColor(.w)
                .font(.SF14R)
            }
          }
        }
      } else {
        VStack(spacing: 4) {
          HStack {
            Text("- %")
              .foregroundColor(.w)
              .font(.SF14R)

            Spacer()

            RoundedRectangle(cornerRadius: 4)
              .fill(Color.w10)
              .frame(height: 5)

            Spacer()

            Text("- %")
              .foregroundColor(.w)
              .font(.SF14R)
          }
        }
      }

      if !store.state.publicComments.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 12) {
            ForEach(Array(store.state.publicComments.prefix(5)), id: \.id) { comment in
              VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                  Group {
                    if let userReaction = getUserReaction(for: comment.userId) {
                      if userReaction == "like" {
                        DesignSystemAsset.Images.circleLike.swiftUIImage
                          .resizable()
                      } else if userReaction == "dislike" {
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
                  .frame(width: 10, height: 10)

                  Spacer()
                }

                Text(comment.comment)
                  .foregroundColor(.w85)
                  .font(.SF14R)
                  .lineLimit(4)
                  .multilineTextAlignment(.leading)
                  .fixedSize(horizontal: false, vertical: true)
                  .clipped()

                Spacer()

                Text(formatShortDate(comment.createdAt))
                  .foregroundColor(.w50)
                  .font(.SF12R)
              }
              .frame(width: 120, height: 120)
              .padding(12)
              .background(Color.darkgray)
              .cornerRadius(12)
              .onTapGesture {
                store.send(.showCommentsSheet(true))
              }
            }
          }
        }
      } else {
        VStack(alignment: .center, spacing: 8) {
          Text("공개된 코멘트가 없어요.")
            .foregroundColor(.w50)
            .font(.SF12R)
            .frame(maxWidth: .infinity)
        }
        .frame(width: 120, height: 120)
        .padding(12)
        .background(Color.darkgray)
        .cornerRadius(12)
      }
    }
    .padding(.bottom, 40)
  }
}
