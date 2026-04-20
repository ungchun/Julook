import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct MakgeolliGridView: View {
  let store: StoreOf<FilterCore>

  var body: some View {
    LazyVStack {
      LazyVGrid(
        columns: [
          GridItem(.flexible(), spacing: 16),
          GridItem(.flexible())
        ],
        spacing: 16
      ) {
        ForEach(Array(store.makgeollis.enumerated()), id: \.offset) { index, makgeolli in
          MakgeolliCardView(makgeolli: makgeolli, imageURL: store.makgeolliImages[makgeolli.id])
            .id(makgeolli.id.uuidString + String(index))
        }
      }
      .padding(.horizontal, 16)

      if store.hasMoreData {
        LoadMoreView(isLoading: store.isLoadingMakgeollis)
          .onAppear {
            if !store.isLoadingMakgeollis {
              store.send(.loadMoreMakgeollis)
            }
          }
      }
    }
  }
}

private extension MakgeolliGridView {
  @ViewBuilder
  func MakgeolliCardView(makgeolli: Makgeolli, imageURL: URL?) -> some View {
    VStack(spacing: 16) {
      cardImage(imageURL: imageURL)
      cardNameLine(makgeolli: makgeolli)
      cardScoreRow(makgeolli: makgeolli)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 12)
    .padding(.bottom, 28)
    .padding(.top, 32)
    .background(Color.darkgray)
    .cornerRadius(20)
    .onTapGesture {
      store.send(.moveToInformation(makgeolli, imageURL))
    }
  }

  @ViewBuilder
  func cardImage(imageURL: URL?) -> some View {
    if let imageURL = imageURL {
      AsyncImage(url: imageURL) { phase in
        cardImagePhase(phase)
      }
    } else {
      Rectangle()
        .fill(Color.darkgray)
        .frame(height: 150)
        .overlay(
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .w))
        )
    }
  }

  @ViewBuilder
  func cardImagePhase(_ phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      ProgressView().frame(height: 150)
    case .success(let image):
      image.resizable().aspectRatio(contentMode: .fit).frame(height: 150).clipped()
    case .failure, _:
      DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
        .resizable().aspectRatio(contentMode: .fit).frame(height: 150)
    }
  }

  @ViewBuilder
  func cardNameLine(makgeolli: Makgeolli) -> some View {
    VStack(spacing: 2) {
      Text(makgeolli.name)
        .foregroundColor(.w)
        .font(.SF12R)
        .lineLimit(1)

      if let brewery = makgeolli.brewery {
        Text("\(brewery) ･ \(formatValue(makgeolli.alcoholPercentage))도")
          .foregroundColor(.w50).font(.SF10R).lineLimit(1)
      } else {
        Text("\(formatValue(makgeolli.alcoholPercentage))도")
          .foregroundColor(.w50).font(.SF10R).lineLimit(1)
      }
    }
  }

  @ViewBuilder
  func cardScoreRow(makgeolli: Makgeolli) -> some View {
    HStack(spacing: 6) {
      cardScoreColumn(score: makgeolli.sweetness, label: "단맛")
      cardScoreColumn(score: makgeolli.sourness, label: "신맛")
      cardScoreColumn(score: makgeolli.thickness, label: "걸쭉")
      cardScoreColumn(score: makgeolli.carbonation, label: "탄산")
    }
  }

  @ViewBuilder
  func cardScoreColumn(score: Int?, label: String) -> some View {
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
    case 0: return DesignSystemAsset.Images._0Score.swiftUIImage
    case 1: return DesignSystemAsset.Images._1Score.swiftUIImage
    case 2: return DesignSystemAsset.Images._2Score.swiftUIImage
    case 3: return DesignSystemAsset.Images._3Score.swiftUIImage
    case 4: return DesignSystemAsset.Images._4Score.swiftUIImage
    case 5: return DesignSystemAsset.Images._5Score.swiftUIImage
    default: return DesignSystemAsset.Images.nillScore.swiftUIImage
    }
  }

  func formatValue<T>(_ value: T?) -> String {
    guard let value = value else { return "-" }
    return "\(value)"
  }

  @ViewBuilder
  func LoadMoreView(isLoading: Bool) -> some View {
    HStack {
      Spacer()
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .w))
      Spacer()
    }
    .frame(height: 50)
  }
}
