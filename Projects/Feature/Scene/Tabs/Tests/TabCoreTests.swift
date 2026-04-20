import XCTest

import ComposableArchitecture

@testable import FeatureTabs

@MainActor
final class TabCoreTests: XCTestCase {

  // MARK: - Tab enum

  func test_tab_rawValuesMatch() {
    XCTAssertEqual(Tab.home.rawValue, "home")
    XCTAssertEqual(Tab.search.rawValue, "search")
    XCTAssertEqual(Tab.labelScan.rawValue, "label_scan")
    XCTAssertEqual(Tab.myMakgeolli.rawValue, "my_makgeolli")
  }

  // MARK: - Default state

  func test_defaultState_startsAtHome() {
    let state = TabCore.State()
    XCTAssertEqual(state.selectedTab, .home)
  }

  // MARK: - Tab selection

  func test_tabSeoected_changesSelectedTab() async {
    let store = TestStore(initialState: TabCore.State()) { TabCore() }

    await store.send(.tabSeoected(.search)) {
      $0.selectedTab = .search
    }
  }

  func test_tabSeoected_whenLabelScanAnalyzing_isBlocked() async {
    var state = TabCore.State()
    state.labelScanTab.isAnalyzing = true
    let store = TestStore(initialState: state) { TabCore() }

    // 분석 중에는 탭 변경이 무시되어야 함 (docs/git 커밋 d044e06 회귀 테스트)
    await store.send(.tabSeoected(.search))
    // selectedTab이 그대로 .home 유지 — 변화 없음
  }
}
