import Foundation

import Core

import ComposableArchitecture

@Reducer
public struct FilterCore {
  @ObservableState
  public struct State: Equatable {
    // 필터
    public var selectedFilters: Set<FilterType> = []
    public var initSelectedFilters: FilterType?

    // 정렬
    public var showSortOptions: Bool = false
    public var selectedSort: SortOption = .recommended
    public var showSortInfoAlert: Bool = false

    // 막걸리 데이터
    public var isLoadingMakgeollis: Bool = false
    public var makgeollis: [Makgeolli] = []
    public var tempMakgeollis: [Makgeolli] = []
    public var makgeolliImages: [UUID: URL] = [:]

    // 페이지네이션
    public var currentPage: Int = 0
    public var hasMoreData: Bool = true
    public var pageSize: Int = 10

    // 토픽 모드
    public var isTopicMode: Bool = false
    public var topicTitle: String = ""         // 쿼리 키 (원본 한국어 — Supabase fetch 용)
    public var topicDisplayTitle: String = ""  // 뷰 표시용 (로케일 반영된 표시명)

    // UI
    public var scrollToTop: Bool = false

    public init(initSelectedFilters: FilterType? = nil) {
      self.initSelectedFilters = initSelectedFilters
      self.isTopicMode = false
      self.topicTitle = ""
      self.topicDisplayTitle = ""
    }

    public init(topicTitle: String, displayTitle: String? = nil) {
      self.isTopicMode = true
      self.topicTitle = topicTitle
      self.topicDisplayTitle = displayTitle ?? topicTitle
    }
  }

  public enum Action {
    // 라이프사이클
    case onAppear

    // 사용자 액션
    case toggleSortInfoAlertTapped
    case toggleFilterTapped(FilterType)

    // 정렬
    case applyFilters
    case toggleSortOptions
    case selectSort(SortOption)
    case applySorting
    case dismissSortOptions

    // 데이터 로딩
    case fetchMakgeollis
    case loadMoreMakgeollis
    case fetchMakgeollisByTopic
    case makgeollisResponse(TaskResult<[Makgeolli]>, Bool)

    // 이미지 로딩
    case fetchMakgeolliImage(Makgeolli)
    case makgeolliImageResponse(id: UUID, TaskResult<URL>)

    // UI
    case resetScroll

    // 네비게이션
    case moveToInformation(Makgeolli, URL?)

    case logError(FilterCoreError)
  }

  public init() { }

  @Dependency(\.supabaseClient) var supabaseClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        if let filter = state.initSelectedFilters {
          state.selectedFilters.insert(filter)
        }
        guard !state.isLoadingMakgeollis && state.makgeollis.isEmpty else {
          return .none
        }
        return state.isTopicMode
          ? .send(.fetchMakgeollisByTopic)
          : .send(.fetchMakgeollis)

      case .toggleSortInfoAlertTapped:
        state.showSortInfoAlert.toggle()
        return .none

      case let .toggleFilterTapped(filter):
        if state.selectedFilters.contains(filter) {
          state.selectedFilters.remove(filter)
        } else {
          state.selectedFilters.insert(filter)
        }
        return .send(.applyFilters)

      case .applyFilters:
        state.currentPage = 0
        state.makgeollis = []
        state.makgeolliImages = [:]
        state.hasMoreData = true
        state.scrollToTop = true
        state.selectedSort = .recommended
        return .send(.fetchMakgeollis)

      case .toggleSortOptions:
        state.showSortOptions.toggle()
        return .none

      case let .selectSort(sort):
        state.selectedSort = sort
        state.showSortOptions = false
        return .none

      case .applySorting:
        applySort(&state.makgeollis, sort: state.selectedSort)
        return .none

      case .dismissSortOptions:
        state.showSortOptions = false
        return .none

      case .fetchMakgeollis:
        if state.isLoadingMakgeollis { return .none }
        state.isLoadingMakgeollis = true
        return fetchMakgeollisEffect(
          pageSize: state.pageSize, selectedFilters: state.selectedFilters
        )

      case .loadMoreMakgeollis:
        if state.isLoadingMakgeollis || !state.hasMoreData { return .none }
        state.isLoadingMakgeollis = true
        let nextPage = state.currentPage + 1
        let offset = nextPage * state.pageSize
        return loadMoreMakgeollisEffect(
          isTopicMode: state.isTopicMode,
          topicTitle: state.topicTitle,
          pageSize: state.pageSize,
          offset: offset,
          selectedFilters: state.selectedFilters
        )

      case .fetchMakgeollisByTopic:
        if state.isLoadingMakgeollis { return .none }
        state.isLoadingMakgeollis = true
        return fetchMakgeollisByTopicEffect(
          topicTitle: state.topicTitle, pageSize: state.pageSize
        )

      case let .makgeollisResponse(.success(makgeollis), isLoadMore):
        state.isLoadingMakgeollis = false
        state.hasMoreData = makgeollis.count >= state.pageSize

        if isLoadMore {
          state.currentPage += 1
          let unique = removeDuplicates(from: makgeollis)
          let existingIds = Set(state.makgeollis.map { $0.id })
          let newOnes = unique.filter { !existingIds.contains($0.id) }
          state.tempMakgeollis.append(contentsOf: newOnes)
        } else {
          state.tempMakgeollis = makgeollis
        }

        return .merge(makgeollis.map { .send(.fetchMakgeolliImage($0)) })

      case let .makgeollisResponse(.failure(error), _):
        state.isLoadingMakgeollis = false
        return .send(.logError(FilterCoreError(
          code: .failToFetchMakgeollis,
          underlying: error
        )))

      case let .fetchMakgeolliImage(makgeolli):
        return fetchMakgeolliImageEffect(makgeolli: makgeolli)

      case let .makgeolliImageResponse(id, .success(url)):
        state.makgeolliImages[id] = url
        state.makgeollis.append(contentsOf: state.tempMakgeollis)
        state.tempMakgeollis = []
        return .none

      case let .makgeolliImageResponse(_, .failure(error)):
        state.makgeollis.append(contentsOf: state.tempMakgeollis)
        state.tempMakgeollis = []
        return .send(.logError(FilterCoreError(
          code: .failToFetchImage,
          underlying: error
        )))

      case .resetScroll:
        state.scrollToTop = false
        return .none

      case .moveToInformation:
        return .none

      case let .logError(error):
        return .run { _ in Log.error(error) }
      }
    }
  }
}
