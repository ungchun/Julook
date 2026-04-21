import SwiftUI

import Core
import DesignSystem

extension InformationView {
  @ViewBuilder
  func MakgeolliIngredientsSection() -> some View {
    if let ingredients = store.makgeolli.ingredients {
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          Text(L10n.Information.Ingredients.title)
            .foregroundColor(.w)
            .font(.SF20B)
            .padding(.bottom, 20)

          Text(ingredients.joined(separator: ", "))
            .foregroundColor(.w85)
            .font(.SF14R)
            .multilineTextAlignment(.leading)
            .padding(.bottom, 16)

          Text(L10n.Information.Ingredients.source)
            .foregroundColor(.w25)
            .font(.SF12B)
        }
        Spacer()
      }
      .padding(.bottom, 40)
    }
  }
}
