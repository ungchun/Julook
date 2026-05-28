import Foundation

import Core
import DesignSystem

import ComposableArchitecture

public enum MyMakgeolliFilterTab: String, CaseIterable, Equatable {
  case all
  case like
  case dislike
  case favorite
  case comment

  public var displayName: String {
    switch self {
    case .all: return L10n.MyMakgeolli.Tab.all
    case .like: return L10n.Common.Reaction.like
    case .dislike: return L10n.Common.Reaction.dislike
    case .favorite: return L10n.MyMakgeolli.Tab.favorite
    case .comment: return L10n.MyMakgeolli.Tab.comment
    }
  }
}

@Reducer
public struct MyMakgeolliCore: Sendable {
  @ObservableState
  public struct State: Equatable, Hashable {
    public var isInitialized: Bool = false
    public var isLoading: Bool = false
    public var selectedTab: MyMakgeolliFilterTab = .all
    public var allMyMakgeollis: [MyMakgeolliEntity] = []
    public var likedMakgeollis: [MyMakgeolliEntity] = []
    public var dislikedMakgeollis: [MyMakgeolliEntity] = []
    public var favoriteMakgeollis: [MyMakgeolliEntity] = []
    public var commentMakgeollis: [MyMakgeolliEntity] = []
    public var makgeolliImages: [UUID: URL] = [:]
    public var myMakgeollis: [MyMakgeolliEntity] {
      switch selectedTab {
      case .all:
        return allMyMakgeollis
      case .like:
        return likedMakgeollis
      case .dislike:
        return dislikedMakgeollis
      case .favorite:
        return favoriteMakgeollis
      case .comment:
        return commentMakgeollis
      }
    }

    public init() { }
  }

  public enum Action {
    case viewAppeared

    case tabSelected(MyMakgeolliFilterTab)
    case refreshMyMakgeollis
    case loadReactionData
    case myMakgeolliDataChanged
    case updateAllData(
      [MyMakgeolliEntity], [MyMakgeolliEntity], [MyMakgeolliEntity], [MyMakgeolliEntity], [MyMakgeolliEntity]
    )
    case loadMakgeolliImages([MyMakgeolliEntity])
    case loadNewMakgeolliImages([MyMakgeolliEntity])
    case updateMakgeolliImage(UUID, URL)
    case myMakgeolliItemTapped(MyMakgeolliEntity)
    case fetchMakgeolliResponse(MyMakgeolliEntity, TaskResult<Makgeolli?>)

    case moveToInformation(Makgeolli, URL?)

    case logError(MyMakgeolliCoreError)
    case showToast(String, ToastType)
  }

  public init() { }

  @Dependency(\.myMakgeolliClient) var myMakgeolliClient
  @Dependency(\.makgeolliReactionClient) var makgeolliReactionClient
  @Dependency(\.supabaseClient) var supabaseClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .viewAppeared:
        if state.isInitialized { return .none }
        state.isInitialized = true
        state.isLoading = true
        return .send(.loadReactionData)

      case let .tabSelected(tab):
        state.selectedTab = tab
        return .none

      case .refreshMyMakgeollis, .myMakgeolliDataChanged:
        return .send(.loadReactionData)

      case .loadReactionData:
        return loadReactionDataEffect()

      case let .updateAllData(allData, likedData, dislikedData, favoriteData, commentData):
        state.allMyMakgeollis = allData
        state.likedMakgeollis = likedData
        state.dislikedMakgeollis = dislikedData
        state.favoriteMakgeollis = favoriteData
        state.commentMakgeollis = commentData
        state.isLoading = false

        var unique = Set<MyMakgeolliEntity>()
        unique.formUnion(allData)
        unique.formUnion(likedData)
        unique.formUnion(dislikedData)
        unique.formUnion(favoriteData)
        unique.formUnion(commentData)

        return .send(.loadMakgeolliImages(Array(unique)))

      case let .loadMakgeolliImages(myMakgeollis),
           let .loadNewMakgeolliImages(myMakgeollis):
        return loadMakgeolliImagesEffect(myMakgeollis)

      case let .updateMakgeolliImage(id, url):
        state.makgeolliImages[id] = url
        return .none

      case let .myMakgeolliItemTapped(entity):
        return fetchMakgeolliDetailEffect(entity)

      case let .fetchMakgeolliResponse(entity, .success(makgeolli)):
        guard let makgeolli = makgeolli else {
          return .send(.logError(MyMakgeolliCoreError(
            code: .makgeolliNotFound,
            underlying: nil
          )))
        }
        return .send(.moveToInformation(makgeolli, state.makgeolliImages[entity.id]))

      case let .fetchMakgeolliResponse(_, .failure(error)):
        return .send(.logError(MyMakgeolliCoreError(
          code: .failToFetchMakgeolliDetail,
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
