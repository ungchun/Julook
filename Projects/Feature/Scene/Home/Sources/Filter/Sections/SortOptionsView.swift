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
          Text("어떤 순서로 정렬되나요")
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
        .alert("추천순으로 정렬", isPresented: Binding(
          get: { store.showSortInfoAlert },
          set: { if !$0 { store.send(.toggleSortInfoAlertTapped) } }
        )) {
          Button("확인", role: .cancel) {
            store.send(.toggleSortInfoAlertTapped)
          }
        } message: {
          Text("최근에 나온 막걸리일수록 리스트 상단에 정렬돼요.")
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
