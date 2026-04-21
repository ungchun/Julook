import Foundation

import Core
import DesignSystem

import ComposableArchitecture

@Reducer
public struct HomeCore {
  @ObservableState
  public struct State: Equatable {
    public var isInitialized: Bool = false

    // 신상 막걸리
    public var isLoadingNewReleases: Bool = false
    public var newReleases: [Makgeolli] = []
    public var newReleasesImages: [UUID: URL] = [:]

    // 랜덤 막걸리
    public var isLoadingRandomMakgeollis: Bool = false
    public var randomMakgeollis: [Makgeolli] = []
    public var randomMakgeolliImages: [UUID: URL] = [:]

    // 수상
    public var isLoadingAwards: Bool = false
    public var awards: [Award] = []

    // 오늘의 랭킹
    public var isLoadingTopLiked: Bool = false
    public var topLikedMakgeollis: [Makgeolli] = []
    public var topLikedImages: [UUID: URL] = [:]
    public var topLikedFavoriteStatus: [UUID: Bool] = [:]

    // 최근 코멘트
    public var isLoadingRecentComments: Bool = false
    public var recentComments: [UserComment] = []
    public var recentCommentMakgeollis: [UUID: Makgeolli] = [:]
    public var recentCommentImages: [UUID: URL] = [:]
    public var recentCommentReactions: [UUID: String] = [:]

    // 번역 (영어 로컬라이징)
    public var translationsByMakgeolliId: [UUID: MakgeolliTranslation] = [:]

    public init() { }
  }

  public enum Action {
    // 라이프사이클
    case onAppear

    // 사용자 액션
    case filterButtonTapped
    case filterItemTapped(FilterType)
    case newReleaseItemTapped(Makgeolli)
    case randomMakgeolliItemTapped(Makgeolli)
    case topicItemTapped(Award)
    case topLikedItemTapped(Makgeolli)
    case topLikedFavoriteButtonTapped(Makgeolli)

    // 신상 막걸리
    case fetchNewReleases
    case newReleasesResponse(TaskResult<[Makgeolli]>)
    case fetchNewReleasesImage(Makgeolli)
    case newReleasesImageResponse(id: UUID, TaskResult<URL>)

    // 랜덤 막걸리
    case fetchRandomMakgeollis
    case randomMakgeollisResponse(TaskResult<[Makgeolli]>)
    case fetchRandomMakgeolliImage(Makgeolli)
    case randomMakgeolliImageResponse(id: UUID, TaskResult<URL>)

    // 수상
    case fetchAwards
    case awardsResponse(TaskResult<[Award]>)

    // 오늘의 랭킹
    case fetchTopLikedMakgeollis
    case topLikedMakgeollisResponse(TaskResult<[Makgeolli]>)
    case fetchTopLikedImage(Makgeolli)
    case topLikedImageResponse(id: UUID, TaskResult<URL>)
    case loadTopLikedFavoriteStatus(Makgeolli)
    case updateTopLikedFavoriteStatus(id: UUID, Bool)

    // 최근 코멘트
    case fetchRecentComments
    case recentCommentsResponse(TaskResult<[UserComment]>)
    case fetchRecentCommentMakgeolli(UserComment)
    case recentCommentMakgeolliResponse(UserComment, TaskResult<Makgeolli?>)
    case fetchRecentCommentImage(Makgeolli)
    case recentCommentImageResponse(id: UUID, TaskResult<URL>)
    case loadRecentCommentReaction(UserComment)
    case updateRecentCommentReaction(commentId: UUID, String?)
    case refreshRecentCommentReactions
    case recentCommentItemTapped(UserComment)

    // 번역 (영어 로컬라이징)
    case fetchTranslations
    case translationsResponse(TaskResult<[MakgeolliTranslation]>)

    // 네비게이션
    case moveToFilter
    case moveToFilterWithSelection(FilterType)
    case moveToFilterWithTopic(String)
    case moveToInformation(Makgeolli, URL?)
    case moveToCommentList

    // 알림
    case recentCommentsChangedNotification

    case logError(HomeCoreError)
    case showToast(String, ToastType)
  }

  public init() { }

  @Dependency(\.supabaseClient) var supabaseClient
  @Dependency(\.myMakgeolliClient) var myMakgeolliClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return handleOnAppear(&state)

      case .filterButtonTapped:
        return .send(.moveToFilter)

      case let .filterItemTapped(filter):
        return .send(.moveToFilterWithSelection(filter))

      case let .newReleaseItemTapped(m):
        return .send(.moveToInformation(m, state.newReleasesImages[m.id]))

      case let .randomMakgeolliItemTapped(m):
        return .send(.moveToInformation(m, state.randomMakgeolliImages[m.id]))

      case let .topicItemTapped(award):
        return .send(.moveToFilterWithTopic(award.name))

      case let .topLikedItemTapped(m):
        return .send(.moveToInformation(m, state.topLikedImages[m.id]))

      case let .topLikedFavoriteButtonTapped(m):
        return handleToggleTopLikedFavorite(makgeolli: m)

      case .fetchNewReleases:
        state.isLoadingNewReleases = true
        return fetchNewReleasesEffect()

      case let .newReleasesResponse(.success(ms)):
        state.isLoadingNewReleases = false
        state.newReleases = ms
        return .merge(ms.map { .send(.fetchNewReleasesImage($0)) })

      case let .newReleasesResponse(.failure(error)):
        state.isLoadingNewReleases = false
        return logErrorEffect(code: .failToFetchNewReleases, error: error)

      case let .fetchNewReleasesImage(m):
        return fetchImageEffect(makgeolli: m) { .newReleasesImageResponse(id: $0, $1) }

      case let .newReleasesImageResponse(id, .success(url)):
        state.newReleasesImages[id] = url
        return .none

      case let .newReleasesImageResponse(_, .failure(error)):
        return logErrorEffect(code: .failToFetchImage, error: error)

      case .fetchRandomMakgeollis:
        state.isLoadingRandomMakgeollis = true
        return fetchRandomMakgeollisEffect()

      case let .randomMakgeollisResponse(.success(ms)):
        state.isLoadingRandomMakgeollis = false
        state.randomMakgeollis = ms
        return .merge(ms.map { .send(.fetchRandomMakgeolliImage($0)) })

      case let .randomMakgeollisResponse(.failure(error)):
        state.isLoadingRandomMakgeollis = false
        return logErrorEffect(code: .failToFetchRandomMakgeollis, error: error)

      case let .fetchRandomMakgeolliImage(m):
        return fetchImageEffect(makgeolli: m) { .randomMakgeolliImageResponse(id: $0, $1) }

      case let .randomMakgeolliImageResponse(id, .success(url)):
        state.randomMakgeolliImages[id] = url
        return .none

      case let .randomMakgeolliImageResponse(_, .failure(error)):
        return logErrorEffect(code: .failToFetchImage, error: error)

      case .fetchAwards:
        state.isLoadingAwards = true
        return fetchAwardsEffect()

      case let .awardsResponse(.success(awards)):
        state.isLoadingAwards = false
        state.awards = awards
        return .none

      case let .awardsResponse(.failure(error)):
        state.isLoadingAwards = false
        return logErrorEffect(code: .failToFetchAwards, error: error)

      case .fetchTopLikedMakgeollis:
        state.isLoadingTopLiked = true
        return fetchTopLikedMakgeollisEffect()

      case let .topLikedMakgeollisResponse(.success(ms)):
        state.isLoadingTopLiked = false
        state.topLikedMakgeollis = ms
        return .merge(ms.flatMap { [
          .send(.fetchTopLikedImage($0)),
          .send(.loadTopLikedFavoriteStatus($0))
        ] })

      case let .topLikedMakgeollisResponse(.failure(error)):
        state.isLoadingTopLiked = false
        return logErrorEffect(code: .failToFetchTopLiked, error: error)

      case let .fetchTopLikedImage(m):
        return fetchImageEffect(makgeolli: m) { .topLikedImageResponse(id: $0, $1) }

      case let .topLikedImageResponse(id, .success(url)):
        state.topLikedImages[id] = url
        return .none

      case let .topLikedImageResponse(_, .failure(error)):
        return logErrorEffect(code: .failToFetchImage, error: error)

      case let .loadTopLikedFavoriteStatus(m):
        return loadTopLikedFavoriteStatusEffect(makgeolli: m)

      case let .updateTopLikedFavoriteStatus(id, isFavorite):
        state.topLikedFavoriteStatus[id] = isFavorite
        return .none

      case .fetchRecentComments:
        state.isLoadingRecentComments = true
        return fetchRecentCommentsEffect()

      case let .recentCommentsResponse(.success(comments)):
        state.isLoadingRecentComments = false
        state.recentComments = comments
        return .merge(comments.map { .send(.fetchRecentCommentMakgeolli($0)) })

      case let .recentCommentsResponse(.failure(error)):
        state.isLoadingRecentComments = false
        return logErrorEffect(code: .failToFetchRecentComments, error: error)

      case let .fetchRecentCommentMakgeolli(comment):
        return fetchRecentCommentMakgeolliEffect(comment: comment)

      case let .recentCommentMakgeolliResponse(comment, .success(makgeolli)):
        guard let makgeolli = makgeolli else { return .none }
        state.recentCommentMakgeollis[comment.makgeolliId] = makgeolli
        let shouldFetchImage = state.recentCommentImages[makgeolli.id] == nil
        return .merge(
          shouldFetchImage ? .send(.fetchRecentCommentImage(makgeolli)) : .none,
          .send(.loadRecentCommentReaction(comment))
        )

      case let .recentCommentMakgeolliResponse(_, .failure(error)):
        return logErrorEffect(code: .failToFetchRecentComments, error: error)

      case let .fetchRecentCommentImage(m):
        return fetchImageEffect(makgeolli: m) { .recentCommentImageResponse(id: $0, $1) }

      case let .recentCommentImageResponse(id, .success(url)):
        state.recentCommentImages[id] = url
        return .none

      case let .recentCommentImageResponse(_, .failure(error)):
        return logErrorEffect(code: .failToFetchImage, error: error)

      case let .loadRecentCommentReaction(comment):
        return loadRecentCommentReactionEffect(comment: comment)

      case let .updateRecentCommentReaction(commentId, reactionType):
        state.recentCommentReactions[commentId] = reactionType
        return .none

      case .refreshRecentCommentReactions:
        return .merge(state.recentComments.map { .send(.loadRecentCommentReaction($0)) })

      case let .recentCommentItemTapped(comment):
        guard let makgeolli = state.recentCommentMakgeollis[comment.makgeolliId] else {
          return .none
        }
        return .send(.moveToInformation(makgeolli, state.recentCommentImages[makgeolli.id]))

      case .fetchTranslations:
        return fetchTranslationsEffect()

      case let .translationsResponse(.success(translations)):
        state.translationsByMakgeolliId = Dictionary(
          uniqueKeysWithValues: translations.map { ($0.makgeolliId, $0) }
        )
        return .none

      case let .translationsResponse(.failure(error)):
        return logErrorEffect(code: .failToFetchTranslations, error: error)

      case .moveToFilter, .moveToFilterWithSelection, .moveToFilterWithTopic,
           .moveToInformation, .moveToCommentList:
        return .none

      case .recentCommentsChangedNotification:
        return .send(.fetchRecentComments)

      case let .logError(error):
        return dispatchLogError(error)

      case .showToast:
        return .none
      }
    }
  }
}
