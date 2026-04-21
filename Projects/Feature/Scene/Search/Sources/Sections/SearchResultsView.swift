import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct SearchResultsView: View {
  @Bindable var store: StoreOf<SearchCore>

  var body: some View {
    if store.isSearching {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .w))
        .padding(.top, 32)
    } else if store.searchResults.isEmpty {
      VStack(spacing: 16) {
        HStack(spacing: 4) {
          Spacer()
          Text("'\(store.searchText)'")
            .foregroundColor(.w85)
            .font(.SF17R)
          Text(L10n.Search.Results.empty)
            .foregroundColor(.w50)
            .font(.SF17R)
          Spacer()
        }
        .lineLimit(1)

        Button {
          store.send(.requestRegisterMakgeolli(store.searchText))
        } label: {
          Text(L10n.Search.Results.requestRegister)
            .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
            .font(.SF17R)
        }
        .alert(L10n.Search.Results.RequestComplete.title, isPresented: $store.isShowingRequestAlert) {
          Button(L10n.Common.Button.confirm, role: .cancel) {
            store.send(.showRequestAlert(false))
          }
        } message: {
          Text(L10n.Search.Results.RequestComplete.message)
        }
      }
      .padding(.top, 32)
    } else {
      VStack(spacing: 16) {
        ForEach(store.searchResults, id: \.id) { makgeolli in
          MakgeolliSearchResultRow(makgeolli: makgeolli, store: store)

          if makgeolli.id != store.searchResults.last?.id {
            Divider()
              .background(Color.w10)
          }
        }
      }
      .padding(.top, 16)
    }
  }
}
