import SwiftUI

import Core
import DesignSystem

extension InformationView {
  @ViewBuilder
  func MakgeolliEvaluationAndCommentsSection() -> some View {
    VStack(alignment: .leading, spacing: 20) {
      evaluationHeader
      evaluationBar
      publicCommentsStrip
    }
    .padding(.bottom, 40)
  }

  // MARK: - Header

  @ViewBuilder
  private var evaluationHeader: some View {
    HStack {
      Text("평가 및 코멘트")
        .foregroundColor(.w)
        .font(.SF20B)
      Spacer()
    }
  }

  // MARK: - Reaction ratio bar

  @ViewBuilder
  private var evaluationBar: some View {
    if let reactionCounts = store.state.reactionCounts {
      let total = reactionCounts.likeCount + reactionCounts.dislikeCount
      if total > 0 {
        reactionBar(like: reactionCounts.likeCount, dislike: reactionCounts.dislikeCount)
      } else {
        emptyReactionBar
      }
    } else {
      emptyReactionBar
    }
  }

  @ViewBuilder
  private func reactionBar(like: Int, dislike: Int) -> some View {
    let total = Double(like + dislike)
    let likePct = Double(like) / total * 100
    let dislikePct = Double(dislike) / total * 100

    VStack(spacing: 4) {
      HStack {
        Text("\(String(format: "%.0f", likePct))%")
          .foregroundColor(.w85)
          .font(.SF14R)

        Spacer()

        GeometryReader { geometry in
          ratioGradient(likePct: likePct, width: geometry.size.width)
        }
        .frame(height: 5)

        Spacer()

        Text("\(String(format: "%.0f", dislikePct))%")
          .foregroundColor(.w85)
          .font(.SF14R)
      }

      HStack {
        Text("좋았어요 (\(like))")
          .foregroundColor(.w50)
          .font(.SF14R)
        Spacer()
        Text("아쉬워요 (\(dislike))")
          .foregroundColor(.w50)
          .font(.SF14R)
      }
    }
  }

  @ViewBuilder
  private func ratioGradient(likePct: Double, width: CGFloat) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 4)
        .fill(Color.w10)
        .frame(width: width, height: 5)

      RoundedRectangle(cornerRadius: 4)
        .fill(LinearGradient(
          gradient: Gradient(stops: [
            .init(color: DesignSystemAsset.Colors.goldenyellow.swiftUIColor, location: 0),
            .init(color: DesignSystemAsset.Colors.goldenyellow.swiftUIColor,
                  location: CGFloat(likePct / 100)),
            .init(color: DesignSystemAsset.Colors.lilac.swiftUIColor,
                  location: CGFloat(likePct / 100)),
            .init(color: DesignSystemAsset.Colors.lilac.swiftUIColor, location: 1)
          ]),
          startPoint: .leading,
          endPoint: .trailing
        ))
        .frame(width: width, height: 5)
    }
  }

  @ViewBuilder
  private var emptyReactionBar: some View {
    VStack(spacing: 4) {
      HStack {
        Text("- %").foregroundColor(.w).font(.SF14R)
        Spacer()
        RoundedRectangle(cornerRadius: 4).fill(Color.w10).frame(height: 5)
        Spacer()
        Text("- %").foregroundColor(.w).font(.SF14R)
      }
    }
  }

  // MARK: - Public comments strip

  @ViewBuilder
  private var publicCommentsStrip: some View {
    if !store.state.publicComments.isEmpty {
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 12) {
          ForEach(Array(store.state.publicComments.prefix(5)), id: \.id) { comment in
            publicCommentCard(comment)
          }
        }
      }
    } else {
      emptyPublicCommentsCard
    }
  }

  @ViewBuilder
  private func publicCommentCard(_ comment: UserComment) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        reactionIcon(for: comment.userId)
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
    .onTapGesture { store.send(.showCommentsSheet(true)) }
  }

  @ViewBuilder
  private func reactionIcon(for userId: UUID) -> some View {
    Group {
      if let reaction = getUserReaction(for: userId) {
        switch reaction {
        case "like": DesignSystemAsset.Images.circleLike.swiftUIImage.resizable()
        case "dislike": DesignSystemAsset.Images.circleDislike.swiftUIImage.resizable()
        default: DesignSystemAsset.Images.circleNone.swiftUIImage.resizable()
        }
      } else {
        DesignSystemAsset.Images.circleNone.swiftUIImage.resizable()
      }
    }
  }

  @ViewBuilder
  private var emptyPublicCommentsCard: some View {
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
