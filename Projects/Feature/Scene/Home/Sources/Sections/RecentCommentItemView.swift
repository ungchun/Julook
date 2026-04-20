import SwiftUI

import Core
import DesignSystem

struct RecentCommentItemView: View, Equatable {
  let comment: UserComment
  let makgeolli: Makgeolli
  let imageUrl: URL?
  let reactionType: String?
  let isLast: Bool
  let onTap: () -> Void

  nonisolated static func == (lhs: RecentCommentItemView, rhs: RecentCommentItemView) -> Bool {
    lhs.comment.id == rhs.comment.id &&
    lhs.makgeolli.id == rhs.makgeolli.id &&
    lhs.imageUrl?.absoluteString == rhs.imageUrl?.absoluteString &&
    lhs.reactionType == rhs.reactionType &&
    lhs.isLast == rhs.isLast
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .top, spacing: 16) {
        RecentCommentImageView(imageUrl: imageUrl)
          .padding(.vertical, 12)
          .padding(.horizontal, 16)
          .background(
            Rectangle()
              .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
              .cornerRadius(12)
          )

        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 8) {
            Text(makgeolli.name)
              .foregroundColor(.w)
              .font(.SF14R)
              .lineLimit(1)

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
            .frame(width: 12, height: 12)
          }

          Text(comment.comment)
            .foregroundColor(.w85)
            .font(.SF14R)
            .lineLimit(2)
            .multilineTextAlignment(.leading)

          Spacer()

          Text(formatDate(comment.createdAt))
            .foregroundColor(.w50)
            .font(.SF12R)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(Rectangle())
      .onTapGesture {
        onTap()
      }

      if !isLast {
        Divider()
          .padding(.vertical, 12)
      }
    }
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: date)
  }
}

struct RecentCommentImageView: View {
  let imageUrl: URL?

  @State private var loadedImage: UIImage?
  @State private var isLoading = false
  @State private var hasFailed = false

  var body: some View {
    Group {
      if let loadedImage = loadedImage {
        Image(uiImage: loadedImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      } else if hasFailed {
        defaultMakgeolliImage()
      } else {
        ProgressView()
          .frame(width: 30, height: 60)
      }
    }
    .task(id: imageUrl?.absoluteString) {
      guard let imageUrl = imageUrl, loadedImage == nil, !isLoading else { return }

      isLoading = true
      hasFailed = false

      do {
        let (data, _) = try await URLSession.shared.data(from: imageUrl)
        if let image = UIImage(data: data) {
          loadedImage = image
        } else {
          hasFailed = true
        }
      } catch {
        hasFailed = true
      }

      isLoading = false
    }
  }

  private func defaultMakgeolliImage() -> some View {
    DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 30, height: 60)
  }
}
