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
          Text("검색 결과가 없어요.")
            .foregroundColor(.w50)
            .font(.SF17R)
          Spacer()
        }
        .lineLimit(1)

        Button {
          store.send(.requestRegisterMakgeolli(store.searchText))
        } label: {
          Text("등록 요청하기")
            .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
            .font(.SF17R)
        }
        .alert("등록 요청 완료", isPresented: $store.isShowingRequestAlert) {
          Button("확인", role: .cancel) {
            store.send(.showRequestAlert(false))
          }
        } message: {
          Text("빠른 시일내에 추가할게요!")
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
