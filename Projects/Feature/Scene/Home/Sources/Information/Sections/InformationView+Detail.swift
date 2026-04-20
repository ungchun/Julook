import SwiftUI

import Core
import DesignSystem

extension InformationView {
  @ViewBuilder
  func MakgeolliDetailSectionView() -> some View {
    ZStack {
      Circle()
        .fill(LinearGradient.lilacNeutral)
        .frame(width: 234, height: 234)
        .offset(y: -40)

      if let imageURL = store.state.makgeolliImage {
        AsyncImage(url: imageURL) { phase in
          switch phase {
          case .empty:
            ProgressView()
              .frame(height: 244)
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 244)
              .clipped()
          case .failure:
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 244)
          @unknown default:
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 244)
          }
        }
      }
    }
    .padding(.bottom, 32)

    VStack(spacing: 4) {
      Text(store.state.makgeolli.name)
        .foregroundColor(.w)
        .font(.SF24B)
        .lineLimit(1)

      if let brewery = store.makgeolli.brewery {
        Text("\(brewery) ･ \(formatValue(store.state.makgeolli.alcoholPercentage))도")
          .foregroundColor(.w50)
          .font(.SF15R)
          .lineLimit(1)
      } else {
        Text("\(formatValue(store.state.makgeolli.alcoholPercentage))도")
          .foregroundColor(.w50)
          .font(.SF15R)
          .lineLimit(1)
      }
    }
    .padding(.bottom, 16)

    HStack(spacing: 16) {
      VStack(spacing: 6) {
        getScoreImage(for: store.state.makgeolli.sweetness)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)

        Text("단맛")
          .foregroundColor(.w50)
          .font(.SF12B)
      }

      VStack(spacing: 6) {
        getScoreImage(for: store.state.makgeolli.sourness)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)

        Text("신맛")
          .foregroundColor(.w50)
          .font(.SF12B)
      }

      VStack(spacing: 6) {
        getScoreImage(for: store.state.makgeolli.thickness)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)

        Text("걸쭉")
          .foregroundColor(.w50)
          .font(.SF12B)
      }

      VStack(spacing: 6) {
        getScoreImage(for: store.state.makgeolli.carbonation)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)

        Text("탄산")
          .foregroundColor(.w50)
          .font(.SF12B)
      }
    }
    .padding(.bottom, 32)
  }

  func getScoreImage(for score: Int?) -> Image {
    guard let score = score else {
      return DesignSystemAsset.Images.nillScore.swiftUIImage
    }

    switch score {
    case 0:
      return DesignSystemAsset.Images._0Score.swiftUIImage
    case 1:
      return DesignSystemAsset.Images._1Score.swiftUIImage
    case 2:
      return DesignSystemAsset.Images._2Score.swiftUIImage
    case 3:
      return DesignSystemAsset.Images._3Score.swiftUIImage
    case 4:
      return DesignSystemAsset.Images._4Score.swiftUIImage
    case 5:
      return DesignSystemAsset.Images._5Score.swiftUIImage
    default:
      return DesignSystemAsset.Images.nillScore.swiftUIImage
    }
  }

  func formatValue<T>(_ value: T?) -> String {
    guard let value = value else { return "-" }
    return "\(value)"
  }

  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: date)
  }

  func formatShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일"
    return formatter.string(from: date)
  }

  func getUserReaction(for userId: UUID) -> String? {
    return store.state.userReactions[userId]
  }
}
