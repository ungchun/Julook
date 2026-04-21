import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct MakgeolliSearchResultRow: View {
  let makgeolli: Makgeolli
  let store: StoreOf<SearchCore>

  var body: some View {
    Button {
      store.send(.makgeolliTapped(makgeolli))
    } label: {
      HStack(spacing: 0) {
        Group {
          if let imageURL = store.makgeolliImages[makgeolli.id] {
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

private extension MakgeolliSearchResultRow {
  @ViewBuilder
  func ScoreItem(score: Int?, label: String, color: Color) -> some View {
    VStack(spacing: 4) {
      if let score = score {
        switch score {
        case 0:
          DesignSystemAsset.Images._0Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 1:
          DesignSystemAsset.Images._1Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 2:
          DesignSystemAsset.Images._2Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 3:
          DesignSystemAsset.Images._3Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 4:
          DesignSystemAsset.Images._4Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 5:
          DesignSystemAsset.Images._5Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        default:
          DesignSystemAsset.Images.nillScore.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        }
      } else {
        DesignSystemAsset.Images.nillScore.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
      }

      Text(label)
        .foregroundColor(.w50)
        .font(.SF10B)
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
