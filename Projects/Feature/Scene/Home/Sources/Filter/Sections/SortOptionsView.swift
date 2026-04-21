import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct SortOptionsView: View {
  let store: StoreOf<FilterCore>

  var body: some View {
    VStack {
      HStack {
        HStack(spacing: 4) {
          Text(L10n.Home.Sort.questionLabel)
            .foregroundColor(.w50)
            .font(.SF12R)

          Image(systemName: "questionmark.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 12, height: 12)
            .foregroundColor(.w50)
        }
        .onTapGesture {
          store.send(.toggleSortInfoAlertTapped)
        }
        .alert(L10n.Home.Sort.InfoAlert.title, isPresented: Binding(
          get: { store.showSortInfoAlert },
          set: { if !$0 { store.send(.toggleSortInfoAlertTapped) } }
        )) {
          Button(L10n.Common.Button.confirm, role: .cancel) {
            store.send(.toggleSortInfoAlertTapped)
          }
        } message: {
          Text(L10n.Home.Sort.InfoAlert.message)
        }

        Spacer()

        Menu {
          Picker("", selection: Binding(
            get: { self.store.selectedSort },
            set: { option in
              Amp.track(event: "sort_option_selected", properties: [
                "sort_option": option.rawValue
              ])
              self.store.send(.selectSort(option))
              self.store.send(.applySorting)
            }
          )) {
            ForEach(SortOption.allCases) { option in
              Text(option.description)
                .foregroundColor(.white)
                .font(.SF14R)
                .tag(option)
            }
          }
          .labelsHidden()
        } label: {
          HStack(spacing: 4) {
            Group {
              Text(self.store.selectedSort.description)
              Image(systemName: "chevron.up.chevron.down")
            }
            .font(.SF12B)
            .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
    }
  }
}
