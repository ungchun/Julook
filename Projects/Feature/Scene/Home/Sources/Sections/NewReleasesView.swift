import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct NewReleasesView: View {
  let store: StoreOf<HomeCore>

  var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("새로 나왔어요")
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }
      .padding(.horizontal, 16)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 16) {
          if store.isLoadingNewReleases {
            ForEach(0..<5, id: \.self) { idx in
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkgray)
                .frame(width: 104, height: 240)
                .overlay(alignment: .center) {
                  ProgressView()
                    .frame(width: 50, height: 114)
                    .progressViewStyle(CircularProgressViewStyle(tint: .w))
                }
                .padding(.leading, idx == 0 ? 16 : 0)
            }
          } else {
            ForEach(Array(store.newReleases.enumerated()), id: \.element.id) { idx, makgeolli in
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkgray)
                .frame(width: 104, height: 240)
                .overlay {
                  VStack(spacing: 12) {
                    if let imageUrl = store.newReleasesImages[makgeolli.id] {
                      AsyncImage(url: imageUrl) { phase in
                        makeImageView(for: phase)
                      }
                    } else {
                      ProgressView()
                        .frame(width: 50, height: 114)
                    }

                    Text(makgeolli.name)
                      .foregroundColor(.w)
                      .font(.SF12R)
                      .lineLimit(1)

                    VStack(spacing: 0) {
                      Spacer()
                      HStack(alignment: .bottom, spacing: 4) {
                        VStack(spacing: 4) {
                          getChartImage(for: makgeolli.sweetness)
                          Text("단")
                            .foregroundColor(.w50)
                            .font(.SF10B)
                        }

                        VStack(spacing: 4) {
                          getChartImage(for: makgeolli.sourness)
                          Text("신")
                            .foregroundColor(.w50)
                            .font(.SF10B)
                        }

                        VStack(spacing: 4) {
                          getChartImage(for: makgeolli.thickness)
                          Text("걸")
                            .foregroundColor(.w50)
                            .font(.SF10B)
                        }

                        VStack(spacing: 4) {
                          getChartImage(for: makgeolli.carbonation)
                          Text("탄")
                            .foregroundColor(.w50)
                            .font(.SF10B)
                        }
                      }
                    }
                  }
                  .padding(20)
                }
                .onTapGesture {
                  Amp.track(event: "new_release_clicked")
                  store.send(.newReleaseItemTapped(makgeolli))
                }
                .padding(.leading, idx == 0 ? 16 : 0)
            }
          }
        }
        .padding(.trailing, 16)
      }
    }
    .padding(.bottom, 20)
  }
}

private extension NewReleasesView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      return AnyView(
        ProgressView()
          .frame(width: 50, height: 114)
      )
    case .success(let image):
      return AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 50, height: 114)
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
      .frame(width: 50, height: 114)
  }

  func getChartImage(for value: Int?) -> Image {
    guard let value = value else {
      return DesignSystemAsset.Images.nillChart.swiftUIImage
    }

    switch value {
    case 0:
      return DesignSystemAsset.Images._0Chart.swiftUIImage
    case 1:
      return DesignSystemAsset.Images._1Chart.swiftUIImage
    case 2:
      return DesignSystemAsset.Images._2Chart.swiftUIImage
    case 3:
      return DesignSystemAsset.Images._3Chart.swiftUIImage
    case 4:
      return DesignSystemAsset.Images._4Chart.swiftUIImage
    case 5:
      return DesignSystemAsset.Images._5Chart.swiftUIImage
    default:
      return DesignSystemAsset.Images.nillChart.swiftUIImage
    }
  }
}
