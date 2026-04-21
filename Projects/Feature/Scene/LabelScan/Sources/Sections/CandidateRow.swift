import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct CandidateRow: View {
  let makgeolli: Makgeolli
  let imageURL: URL?
  let store: StoreOf<LabelScanCore>

  var body: some View {
    Button {
      store.send(.selectCandidate(makgeolli))
    } label: {
      HStack(spacing: 0) {
        Group {
          if let imageURL = imageURL {
            AsyncImage(url: imageURL) { phase in
              makeImageView(for: phase)
            }
          } else {
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 30, height: 60)
          }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(DesignSystemAsset.Colors.darkgray.swiftUIColor)
        .cornerRadius(12)

        VStack(alignment: .leading, spacing: 4) {
          Text(makgeolli.name)
            .foregroundColor(.w)
            .font(.SF14R)
            .lineLimit(1)

          if let brewery = makgeolli.brewery {
            Text(L10n.Common.Format.breweryAlcohol(brewery, formatValue(makgeolli.alcoholPercentage)))
              .foregroundColor(.w50)
              .font(.SF10B)
              .lineLimit(1)
          } else {
            Text(L10n.Common.Format.alcoholOnly(formatValue(makgeolli.alcoholPercentage)))
              .foregroundColor(.w50)
              .font(.SF10B)
              .lineLimit(1)
          }
        }
        .padding(.horizontal, 16)

        Spacer()

        HStack(spacing: 6) {
          ScoreItem(
            score: makgeolli.sweetness,
            label: L10n.Common.Taste.sweetness,
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.sourness,
            label: L10n.Common.Taste.sourness,
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.thickness,
            label: L10n.Common.Taste.thickness,
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.carbonation,
            label: L10n.Common.Taste.carbonation,
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
        }
      }
    }
    .padding(.vertical, 8)
  }
}

private extension CandidateRow {
  @ViewBuilder
  func ScoreItem(score: Int?, label: String, color: Color) -> some View {
    VStack(spacing: 4) {
      getScoreImage(for: score)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24, height: 24)

      Text(label)
        .foregroundColor(.w50)
        .font(.SF10B)
    }
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

  @ViewBuilder
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      AnyView(
        ProgressView()
          .frame(width: 30, height: 60)
      )
    case .success(let image):
      AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    case .failure:
      AnyView(
        DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    @unknown default:
      AnyView(
        DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    }
  }

  func formatValue<T>(_ value: T?) -> String {
    guard let value = value else { return "-" }
    return "\(value)"
  }
}
