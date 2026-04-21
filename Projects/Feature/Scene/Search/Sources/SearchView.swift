import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct SearchView: View {
  @Bindable var store: StoreOf<SearchCore>
  @FocusState private var focused: Bool

  public init(store: StoreOf<SearchCore>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()
        .onTapGesture {
          if store.isSearchBarFocused {
            focused = false
            store.send(.setSearchBarFocus(false))
          }
        }

      VStack(spacing: 0) {
        SearchBar()
          .padding(.bottom, 16)

        if store.recentSearches.isEmpty
            && store.searchText.isEmpty
            && !store.isSearchBarFocused {
          Spacer()
          EmptyStateView()
          Spacer()
        } else {
          ScrollView(showsIndicators: false) {
            if store.searchText.isEmpty && (store.isSearchBarFocused || !store.recentSearches.isEmpty) {
              RecentSearchesView()
            }

            if !store.searchText.isEmpty {
              SearchResultsView(store: store)
            }
          }
          .simultaneousGesture(
            DragGesture().onChanged { _ in
              if store.isSearchBarFocused {
                focused = false
                store.send(.setSearchBarFocus(false))
              }
            }
          )
        }
      }
      .padding(.horizontal, 16)
    }
    .onAppear {
      store.send(.onAppear)
      focused = false
    }
  }
}

private extension SearchView {
  @ViewBuilder
  func SearchBar() -> some View {
    HStack {
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.w50)
          .padding(.leading, 8)

        TextField(L10n.Search.Input.placeholder, text: $store.searchText)
          .foregroundColor(.w)
          .accentColor(DesignSystemAsset.Colors.primary.swiftUIColor)
          .focused($focused)
          .submitLabel(.search)
          .onSubmit {
            Amp.track(event: "search_submitted", properties: [
              "search_query": store.searchText
            ])
            store.send(.searchSubmitted)
          }
          .onChange(of: store.searchText) { _, newValue in
            store.send(.searchTextChanged(newValue))
          }
          .onChange(of: focused) { _, newValue in
            store.send(.setSearchBarFocus(newValue))
          }

        if !store.searchText.isEmpty {
          Button {
            store.searchText = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.w50)
          }
          .padding(.trailing, 8)
        }
      }
      .padding(.vertical, 10)
      .background(DesignSystemAsset.Colors.w10.swiftUIColor)
      .cornerRadius(10)

      if focused {
        Button(L10n.Common.Button.cancel) {
          focused = false
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
        .padding(.leading, 8)
        .transition(.move(edge: .trailing).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.2), value: focused)
      }
    }
  }

  @ViewBuilder
  func EmptyStateView() -> some View {
    VStack(spacing: 20) {
      Text(L10n.Search.EmptyState.prompt)
        .foregroundColor(.w50)
        .font(.SF17R)

      DesignSystemAsset.Images.searchJulook.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(height: 140)
    }
  }

  @ViewBuilder
  func RecentSearchesView() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      recentSearchesHeader
      recentSearchesList
    }
    .padding(.top, 16)
  }

  @ViewBuilder
  private var recentSearchesHeader: some View {
    HStack {
      Text(L10n.Search.Recent.title)
        .foregroundColor(.w)
        .font(.SF14R)
      Spacer()
      Button {
        if !store.recentSearches.isEmpty {
          store.send(.showClearConfirmAlert(true))
        }
      } label: {
        Text(L10n.Common.Button.clear)
          .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
          .font(.SF14R)
      }
    }
    .padding(.bottom, 20)
    .alert(L10n.Search.Recent.ClearAlert.title, isPresented: $store.isShowingClearConfirmAlert) {
      Button(L10n.Common.Button.cancel, role: .cancel) { store.send(.showClearConfirmAlert(false)) }
      Button(L10n.Common.Button.clear, role: .destructive) {
        store.send(.clearRecentSearches)
        store.send(.showClearConfirmAlert(false))
      }
    } message: {
      Text(L10n.Search.Recent.ClearAlert.message)
    }
  }

  @ViewBuilder
  private var recentSearchesList: some View {
    ForEach(store.recentSearches, id: \.self) { search in
      VStack(spacing: 12) {
        recentSearchRow(search)

        if search != store.recentSearches.last {
          Divider()
            .background(Color.w10)
            .padding(.bottom, 12)
        }
      }
    }
  }

  @ViewBuilder
  private func recentSearchRow(_ search: String) -> some View {
    HStack {
      Text(search)
        .foregroundColor(.w)
        .font(.SF17R)

      Spacer()

      Button {
        store.send(.removeRecentSearchTapped(search))
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 16))
          .foregroundColor(.w50)
      }
      .buttonStyle(BorderlessButtonStyle())
    }
    .contentShape(Rectangle())
    .onTapGesture {
      Amp.track(event: "recent_search_clicked", properties: [
        "search_query": search
      ])
      if store.isSearchBarFocused {
        focused = false
        store.send(.setSearchBarFocus(false))
      }
      store.searchText = search
      store.send(.searchSubmitted)
    }
  }
}
