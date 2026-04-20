import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct MakgeolliFilterView: View {
  let store: StoreOf<HomeCore>

  var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("특징으로 찾기")
          .foregroundColor(.w)
          .font(.SF20B)

        DesignSystemAsset.Images.arrowRight.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 16)
          .foregroundColor(.w)

        Spacer()
      }
      .onTapGesture {
        Amp.track(event: "feature_filter_clicked")
        store.send(.filterButtonTapped)
      }
      .padding(.horizontal, 16)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(FilterType.allCases) { filterType in
            VStack(spacing: 8) {
              filterType.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .background(Circle().fill(Color.darkgray))
                .clipShape(Circle())

              Text(filterType.description)
                .foregroundColor(.w85)
                .font(.SF12B)
            }
            .onTapGesture {
              Amp.track(event: "filter_type_clicked", properties: [
                "filter_type": filterType.description
              ])
              store.send(.filterItemTapped(filterType))
            }
          }
        }
        .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 20)
  }
}
