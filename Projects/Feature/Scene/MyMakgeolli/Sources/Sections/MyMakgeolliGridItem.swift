import SwiftUI

import Core
import DesignSystem

final class ImageCache: @unchecked Sendable {
  static let shared = ImageCache()
  private var cache: [String: UIImage] = [:]
  private let queue = DispatchQueue(label: "ImageCache", attributes: .concurrent)

  func getImage(for url: String) -> UIImage? {
    queue.sync {
      return cache[url]
    }
  }

  func setImage(_ image: UIImage, for url: String) {
    queue.async(flags: .barrier) {
      self.cache[url] = image
    }
  }
}

struct MyMakgeolliGridItem: View {
  @State private var loadedImage: UIImage?
  @State private var isLoading = false

  let makgeolli: MyMakgeolliEntity
  let imageURL: URL?
  let reactionType: String?
  let hasComment: Bool

  var body: some View {
    VStack(spacing: 12) {
      Group {
        if let loadedImage = loadedImage {
          Image(uiImage: loadedImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 120)
            .clipped()
            .cornerRadius(12)
        } else {
          DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 120)
            .cornerRadius(12)
            .opacity(isLoading ? 0.5 : 1.0)
        }
      }
      .onAppear {
        if let imageURL = imageURL, loadedImage == nil {
          if let cached = ImageCache.shared.getImage(for: imageURL.absoluteString) {
            loadedImage = cached
          } else {
            loadImage(from: imageURL)
          }
        }
      }
      .onChange(of: imageURL) { _, newURL in
        if let newURL = newURL, loadedImage == nil {
          if let cached = ImageCache.shared.getImage(for: newURL.absoluteString) {
            loadedImage = cached
          } else {
            loadImage(from: newURL)
          }
        }
      }

      Text(makgeolli.name)
        .font(.style(.SF12B))
        .foregroundColor(.white)
        .lineLimit(1)
        .multilineTextAlignment(.center)

      HStack(spacing: 12) {
        reactionIcon
        commentIcon
        favoriteIcon
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 20)
  }
}

private extension MyMakgeolliGridItem {
  @ViewBuilder
  var reactionIcon: some View {
    Group {
      if reactionType == "like" {
        DesignSystemAsset.Images.circleLike.swiftUIImage.resizable()
      } else if reactionType == "dislike" {
        DesignSystemAsset.Images.circleDislike.swiftUIImage.resizable()
      } else {
        DesignSystemAsset.Images.circleNone.swiftUIImage.resizable()
      }
    }
    .frame(width: 16, height: 16)
  }

  @ViewBuilder
  var commentIcon: some View {
    Group {
      if hasComment {
        DesignSystemAsset.Images.commentFill.swiftUIImage.resizable()
      } else {
        DesignSystemAsset.Images.commentNone.swiftUIImage.resizable()
      }
    }
    .frame(width: 16, height: 16)
  }

  @ViewBuilder
  var favoriteIcon: some View {
    Group {
      if makgeolli.isFavorite {
        DesignSystemAsset.Images.heartFill.swiftUIImage.resizable()
      } else {
        DesignSystemAsset.Images.heartNone.swiftUIImage.resizable()
      }
    }
    .frame(width: 16, height: 16)
  }

  func loadImage(from url: URL) {
    guard !isLoading else { return }
    isLoading = true

    Task {
      do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
          ImageCache.shared.setImage(uiImage, for: url.absoluteString)
          await MainActor.run {
            self.loadedImage = uiImage
            self.isLoading = false
          }
        } else {
          await MainActor.run { self.isLoading = false }
        }
      } catch {
        await MainActor.run { self.isLoading = false }
      }
    }
  }
}
