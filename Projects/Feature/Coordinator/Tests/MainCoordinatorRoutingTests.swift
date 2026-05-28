import XCTest

import ComposableArchitecture
import TCACoordinators

@testable import Core
@testable import FeatureHome
@testable import FeatureTabs
@testable import MainCoordinator

@MainActor
final class MainCoordinatorRoutingTests: XCTestCase {

  // MARK: - Home → Filter

  func test_homeTab_moveToFilter_pushesFilterRoute() async {
    let store = makeStore()

    await store.send(.router(.routeAction(id: 0, action: .tabs(.homeTab(.moveToFilter))))) {
      $0.routes.append(.push(.filter(FilterCore.State())))
    }
  }

  func test_homeTab_moveToFilterWithSelection_pushesPrefilteredRoute() async {
    let store = makeStore()

    await store.send(.router(.routeAction(
      id: 0, action: .tabs(.homeTab(.moveToFilterWithSelection(.sweet)))))
    ) {
      $0.routes.append(.push(.filter(FilterCore.State(initSelectedFilters: .sweet))))
    }
  }

  func test_homeTab_moveToFilterWithTopic_pushesTopicRoute() async {
    let store = makeStore()

    await store.send(.router(.routeAction(
      id: 0, action: .tabs(.homeTab(.moveToFilterWithTopic(
        name: "2024 대한민국 주류대상",
        displayTitle: "2024 Korea Awards"
      )))))
    ) {
      $0.routes.append(.push(.filter(FilterCore.State(
        topicTitle: "2024 대한민국 주류대상",
        displayTitle: "2024 Korea Awards"
      ))))
    }
  }

  // MARK: - Home → Information (cover)

  func test_homeTab_moveToInformation_presentsInformationCover() async {
    let makgeolli = Self.sampleMakgeolli
    let store = makeStore()

    await store.send(.router(.routeAction(
      id: 0, action: .tabs(.homeTab(.moveToInformation(makgeolli, nil)))))
    ) {
      $0.routes.append(
        .cover(.information(InformationCore.State(makgeolli: makgeolli, makgeolliImage: nil)))
      )
    }
  }

  // MARK: - Home → CommentList

  func test_homeTab_moveToCommentList_pushesCommentList() async {
    let store = makeStore()

    await store.send(.router(.routeAction(
      id: 0, action: .tabs(.homeTab(.moveToCommentList))))
    ) {
      $0.routes.append(.push(.commentList(CommentListCore.State())))
    }
  }

  // MARK: - Filter → Information

  func test_filter_moveToInformation_presentsCover() async {
    let makgeolli = Self.sampleMakgeolli
    var initialState = makeInitialState()
    initialState.routes.append(.push(.filter(FilterCore.State())))
    let store = TestStore(initialState: initialState) { MainCoordinatorCore() }

    await store.send(.router(.routeAction(
      id: 1, action: .filter(.moveToInformation(makgeolli, nil))))
    ) {
      $0.routes.append(
        .cover(.information(InformationCore.State(makgeolli: makgeolli, makgeolliImage: nil)))
      )
    }
  }

  // MARK: - Search → Information

  func test_searchTab_moveToInformation_presentsCover() async {
    let makgeolli = Self.sampleMakgeolli
    let store = makeStore()

    await store.send(.router(.routeAction(
      id: 0, action: .tabs(.searchTab(.moveToInformation(makgeolli, nil)))))
    ) {
      $0.routes.append(
        .cover(.information(InformationCore.State(makgeolli: makgeolli, makgeolliImage: nil)))
      )
    }
  }

  // MARK: - MyMakgeolli → Information

  func test_myMakgeolliTab_moveToInformation_presentsCover() async {
    let makgeolli = Self.sampleMakgeolli
    let store = makeStore()

    await store.send(.router(.routeAction(
      id: 0, action: .tabs(.myMakgeolliTab(.moveToInformation(makgeolli, nil)))))
    ) {
      $0.routes.append(
        .cover(.information(InformationCore.State(makgeolli: makgeolli, makgeolliImage: nil)))
      )
    }
  }

  // MARK: - LabelScan → Information

  func test_labelScanTab_moveToInformation_presentsCover() async {
    let makgeolli = Self.sampleMakgeolli
    let store = makeStore()

    await store.send(.router(.routeAction(
      id: 0, action: .tabs(.labelScanTab(.moveToInformation(makgeolli, nil)))))
    ) {
      $0.routes.append(
        .cover(.information(InformationCore.State(makgeolli: makgeolli, makgeolliImage: nil)))
      )
    }
  }

  // MARK: - Information dismiss

  func test_information_dismiss_removesCover() async {
    let makgeolli = Self.sampleMakgeolli
    var initialState = makeInitialState()
    initialState.routes.append(
      .cover(.information(InformationCore.State(makgeolli: makgeolli, makgeolliImage: nil)))
    )
    let store = TestStore(initialState: initialState) { MainCoordinatorCore() }

    await store.send(.router(.routeAction(id: 1, action: .information(.dismiss)))) {
      $0.routes.removeLast()
    }
  }

  // MARK: - CommentList dismiss

  func test_commentList_dismiss_popsRoute() async {
    var initialState = makeInitialState()
    initialState.routes.append(.push(.commentList(CommentListCore.State())))
    let store = TestStore(initialState: initialState) { MainCoordinatorCore() }

    await store.send(.router(.routeAction(id: 1, action: .commentList(.dismiss)))) {
      $0.routes.goBack()
    }
  }

  // MARK: - Helpers

  private func makeInitialState() -> MainCoordinatorCore.State {
    MainCoordinatorCore.State(
      routes: [.root(.tabs(TabCore.State()), withNavigation: true)]
    )
  }

  private func makeStore() -> TestStoreOf<MainCoordinatorCore> {
    TestStore(initialState: makeInitialState()) { MainCoordinatorCore() }
  }

  private static let sampleMakgeolli = Makgeolli(
    id: UUID(),
    name: "테스트",
    brewery: nil,
    website: nil,
    awards: nil,
    sweetness: nil,
    sourness: nil,
    thickness: nil,
    carbonation: nil,
    hasSweetener: nil,
    ingredients: nil,
    alcoholPercentage: nil,
    imageName: nil,
    createdAt: nil,
    updatedAt: nil
  )
}
