import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct TodaysRankingView: View {
  let store: StoreOf<HomeCore>

  var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("인기 막걸리")
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }

      VStack(alignment: .leading, spacing: 0) {
        ForEach(Array(store.topLikedMakgeollis.enumerated()), id: \.element.id) { idx, makgeolli in
          HStack(alignment: .center, spacing: 16) {
            Text("\(idx+1)")
              .foregroundColor(.w)
              .font(.SF24B)

            Group {
              if let imageUrl = store.topLikedImages[makgeolli.id] {
                AsyncImage(url: imageUrl) { phase in
                  makeImageView(for: phase)
                }
              } else {
                ProgressView()
                  .frame(width: 30, height: 60)
              }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
              Rectangle()
                .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
                .cornerRadius(12)
            )

            VStack(alignment: .leading, spacing: 8) {
              Text(makgeolli.name)
                .foregroundColor(.w)
                .font(.SF12R)
                .lineLimit(1)

              HStack(spacing: 6) {
                VStack(spacing: 6) {
                  getScoreImage(for: makgeolli.sweetness)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)

                  Text("단맛")
                    .foregroundColor(.w50)
                    .font(.SF10B)
                }

                VStack(spacing: 6) {
                  getScoreImage(for: makgeolli.sourness)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)

                  Text("신맛")
                    .foregroundColor(.w50)
                    .font(.SF10B)
                }

                VStack(spacing: 6) {
                  getScoreImage(for: makgeolli.thickness)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)

                  Text("걸쭉")
                    .foregroundColor(.w50)
                    .font(.SF10B)
                }

                VStack(spacing: 6) {
                  getScoreImage(for: makgeolli.carbonation)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)

                  Text("탄산")
                    .foregroundColor(.w50)
                    .font(.SF10B)
                }
              }
            }
            .layoutPriority(1)

            Spacer()

            Image(systemName: (
              store.topLikedFavoriteStatus[makgeolli.id] ?? false
            ) ? "heart.fill" : "heart")
            .font(.SF24B)
            .foregroundColor(
              (store.topLikedFavoriteStatus[makgeolli.id] ?? false) ? .red : .w25
            )
            .frame(width: 24, height: 24)
            .onTapGesture {
              store.send(.topLikedFavoriteButtonTapped(makgeolli))
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            Amp.track(event: "top_liked_clicked", properties: [
              "ranking": idx + 1,
              "makgeolli_name": makgeolli.name
            ])
            store.send(.topLikedItemTapped(makgeolli))
          }

          if idx != 2 {
            Divider()
              .padding(.vertical, 12)
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 20)
  }
}

private extension TodaysRankingView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      return AnyView(
        ProgressView()
          .frame(width: 30, height: 60)
      )
    case .success(let image):
      return AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    case .failure:
      return AnyView(defaultMakgeolliImage())

    @unknown default:
      return AnyView(defaultMakgeolliImage())
    }
  }

  func defaultMakgeolliImage() -> some View {
    DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 30, height: 60)
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
}
