import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct FilterOptionsView: View {
  let store: StoreOf<FilterCore>

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(Array(FilterType.allCases.enumerated()), id: \.element) { index, option in
          Button {
            Amp.track(event: "filter_type_clicked", properties: [
              "filter_type": option.description
            ])
            store.send(.toggleFilterTapped(option))
          } label: {
            Text(option.description)
              .foregroundColor(.w)
              .font(.SF15R)
          }
          .cornerRadius(10)
          .buttonStyle(.borderedProminent)
          .tint(store.selectedFilters.contains(option) ? Color.lilac : Color.w10)
          .padding(.leading, index == 0 ? 16 : 0)
        }
      }
    }
    .padding(.vertical, 10)
  }
}
