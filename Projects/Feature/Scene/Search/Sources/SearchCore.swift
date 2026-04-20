import Foundation

import Core
import DesignSystem

import ComposableArchitecture
import Supabase

@Reducer
public struct SearchCore {
  @ObservableState
  public struct State: Equatable {
    // 검색
    public var searchText: String = ""
    public var isSearchBarFocused: Bool = false
    public var isSearching: Bool = false
    public var searchDebounceId: UUID?
    public var isShowingRequestAlert: Bool = false

    // 최근 검색어
    public var recentSearches: [String] = []
    public var isShowingClearConfirmAlert: Bool = false

    // 검색 결과
    public var searchResults: [Makgeolli] = []
    public var makgeolliImages: [UUID: URL] = [:]

    public init() {}
  }

  public enum Action: BindableAction {
    // 라이프사이클
    case onAppear
    case binding(BindingAction<State>)

    // 사용자 액션
    case makgeolliTapped(Makgeolli)
    case removeRecentSearchTapped(String)

    // 검색
    case searchTextChanged(String)
    case searchSubmitted
    case setSearchBarFocus(Bool)
    case debouncedSearch(id: UUID, query: String)
    case showRequestAlert(Bool)
    case requestRegisterMakgeolli(String)

    // 최근 검색어
    case addRecentSearch(String)
    case clearRecentSearches
    case loadRecentSearches
    case recentSearchesResponse([String])
    case showClearConfirmAlert(Bool)

    // 검색
    case searchMakgeollis(String)
    case searchResponse(TaskResult<[Makgeolli]>)

    // 이미지 로딩
    case fetchMakgeolliImage(Makgeolli)
    case makgeolliImageResponse(id: UUID, TaskResult<URL>)

    // 네비게이션
    case moveToInformation(Makgeolli, URL?)

    case logError(SearchCoreError)
    case showToast(String, ToastType)
  }

  public init() { }

  @Dependency(\.supabaseClient) var supabaseClient
  @Dependency(\.continuousClock) var clock
  @Dependency(\.userDefaultsClient) var userDefaultsClient

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isSearchBarFocused = false
        return .send(.loadRecentSearches)

      case .binding:
        return .none

      case let .showRequestAlert(isShowing):
        state.isShowingRequestAlert = isShowing
        return .none

      case let .makgeolliTapped(makgeolli):
        let imageURL = state.makgeolliImages[makgeolli.id]
        return .merge(
          .send(.addRecentSearch(makgeolli.name)),
          .send(.moveToInformation(makgeolli, imageURL))
        )

      case let .removeRecentSearchTapped(search):
        guard let index = state.recentSearches.firstIndex(of: search) else {
          return .none
        }
        state.recentSearches.remove(at: index)
        return persistRecentSearchesEffect(state.recentSearches)

      case let .searchTextChanged(text):
        state.isSearching = true
        state.searchText = text

        if text.isEmpty {
          state.searchResults = []
          state.isSearching = false
          return .cancel(id: state.searchDebounceId)
        }

        let searchId = UUID()
        let previousId = state.searchDebounceId
        state.searchDebounceId = searchId

        let clock = self.clock
        return .merge(
          .cancel(id: previousId),
          .run { [text] send in
            try await clock.sleep(for: .seconds(1))
            await send(.debouncedSearch(id: searchId, query: text))
          }
            .cancellable(id: searchId)
        )

      case .searchSubmitted:
        return state.searchText.isEmpty
          ? .none
          : .send(.addRecentSearch(state.searchText))

      case let .setSearchBarFocus(isFocused):
        state.isSearchBarFocused = isFocused
        return .none

      case let .debouncedSearch(id, query):
        guard id == state.searchDebounceId, !query.isEmpty else {
          return .none
        }
        return .send(.searchMakgeollis(query))

      case let .addRecentSearch(search):
        if let index = state.recentSearches.firstIndex(of: search) {
          state.recentSearches.remove(at: index)
        }
        state.recentSearches.insert(search, at: 0)
        return persistRecentSearchesEffect(state.recentSearches)

      case .clearRecentSearches:
        state.recentSearches.removeAll()
        return removeRecentSearchesEffect()

      case .loadRecentSearches:
        return loadRecentSearchesEffect()

      case let .requestRegisterMakgeolli(searchText):
        return requestRegisterMakgeolliEffect(searchText: searchText)

      case let .recentSearchesResponse(searches):
        state.recentSearches = searches
        return .none

      case let .showClearConfirmAlert(isShowing):
        state.isShowingClearConfirmAlert = isShowing
        return .none

      case let .searchMakgeollis(query):
        guard !query.isEmpty else {
          state.searchResults = []
          state.isSearching = false
          return .none
        }
        state.isSearching = true
        return searchMakgeollisEffect(query: query)

      case let .searchResponse(.success(makgeollis)):
        state.isSearching = false
        state.searchResults = makgeollis
        return .merge(makgeollis.map { .send(.fetchMakgeolliImage($0)) })

      case let .searchResponse(.failure(error)):
        state.isSearching = false
        state.searchResults = []
        return .send(.logError(SearchCoreError(
          code: .failToSearch,
          underlying: error
        )))

      case let .fetchMakgeolliImage(makgeolli):
        guard !state.makgeolliImages.keys.contains(makgeolli.id) else {
          return .none
        }
        return fetchMakgeolliImageEffect(makgeolli: makgeolli)

      case let .makgeolliImageResponse(id, .success(url)):
        state.makgeolliImages[id] = url
        return .none

      case let .makgeolliImageResponse(_, .failure(error)):
        return .send(.logError(SearchCoreError(
          code: .failToFetchImage,
          underlying: error
        )))

      case .moveToInformation:
        return .none

      case let .logError(error):
        return dispatchLogError(error)

      case .showToast:
        return .none
      }
    }
  }
}
