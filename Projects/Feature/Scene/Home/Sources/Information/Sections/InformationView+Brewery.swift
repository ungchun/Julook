import SwiftUI

import Core
import DesignSystem

extension InformationView {
  @ViewBuilder
  func BreweryWebsiteSection() -> some View {
    if store.makgeolli.brewery != nil
        && store.makgeolli.website != nil {
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          Text(L10n.Information.Brewery.link)
            .foregroundColor(.w)
            .font(.SF20B)
            .padding(.bottom, 20)

          if let brewery = store.makgeolli.brewery {
            if let website = store.makgeolli.website {
              Text(brewery)
                .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
                .font(.SF14R)
                .onTapGesture {
                  if let url = URL(string: website) {
                    UIApplication.shared.open(url)
                  }
                }
            } else {
              Text(brewery)
                .foregroundColor(.w)
                .font(.SF14R)
            }
          }
        }
        Spacer()
      }
      .padding(.bottom, 40)
    }
  }
}
