import SwiftUI

import Core
import DesignSystem

extension InformationView {
  @ViewBuilder
  func NavigationBar() -> some View {
    HStack {
      Image(systemName: store.state.isFavorite ? "heart.fill" : "heart")
        .font(.SF24B)
        .foregroundColor(store.state.isFavorite ? .red : .w25)
        .onTapGesture {
          store.send(.favoriteButtonTapped)
        }
      Spacer()
      DesignSystemAsset.Images.close.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 26)
        .onTapGesture {
          store.send(.dismiss)
        }
    }
    .frame(height: 40)
    .padding(.top, 4)
    .padding(.bottom, 32)
  }
}
