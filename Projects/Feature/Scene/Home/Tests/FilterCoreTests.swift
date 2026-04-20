import XCTest

import ComposableArchitecture

@testable import Core
@testable import FeatureHome

@MainActor
final class FilterCoreTests: XCTestCase {

  // MARK: - UI toggles

  func test_toggleSortInfoAlert_togglesFlag() async {
    let store = TestStore(initialState: FilterCore.State()) { FilterCore() }

    await store.send(.toggleSortInfoAlertTapped) {
      $0.showSortInfoAlert = true
    }
    await store.send(.toggleSortInfoAlertTapped) {
      $0.showSortInfoAlert = false
    }
  }

  func test_toggleSortOptions_togglesFlag() async {
    let store = TestStore(initialState: FilterCore.State()) { FilterCore() }

    await store.send(.toggleSortOptions) {
      $0.showSortOptions = true
    }
  }

  func test_dismissSortOptions_setsFalse() async {
    var state = FilterCore.State()
    state.showSortOptions = true
    let store = TestStore(initialState: state) { FilterCore() }

    await store.send(.dismissSortOptions) {
      $0.showSortOptions = false
    }
  }

  // MARK: - Filter selection

  func test_toggleFilterTapped_insertsFilter_andEmitsApply() async {
    let store = TestStore(initialState: FilterCore.State()) {
      FilterCore()
    } withDependencies: {
      $0.supabaseClient.fetchFilteredMakgeollis = { _, _, _ in [] }
    }

    await store.send(.toggleFilterTapped(.sweet)) {
      $0.selectedFilters.insert(.sweet)
    }
    await store.receive(\.applyFilters) {
      $0.scrollToTop = true
    }
    await store.receive(\.fetchMakgeollis) {
      $0.isLoadingMakgeollis = true
    }
    await store.receive(\.makgeollisResponse) {
      $0.isLoadingMakgeollis = false
      $0.hasMoreData = false
      $0.tempMakgeollis = []
    }
  }

  func test_toggleFilterTapped_secondTime_removesFilter() async {
    var state = FilterCore.State()
    state.selectedFilters = [.sour]
    let store = TestStore(initialState: state) {
      FilterCore()
    } withDependencies: {
      $0.supabaseClient.fetchFilteredMakgeollis = { _, _, _ in [] }
    }

    await store.send(.toggleFilterTapped(.sour)) {
      $0.selectedFilters.remove(.sour)
    }
    await store.receive(\.applyFilters) {
      $0.scrollToTop = true
    }
    await store.receive(\.fetchMakgeollis) {
      $0.isLoadingMakgeollis = true
    }
    await store.receive(\.makgeollisResponse) {
      $0.isLoadingMakgeollis = false
      $0.hasMoreData = false
      $0.tempMakgeollis = []
    }
  }

  // MARK: - Sort selection

  func test_selectSort_updatesSortAndClosesOptions() async {
    var state = FilterCore.State()
    state.showSortOptions = true
    let store = TestStore(initialState: state) { FilterCore() }

    await store.send(.selectSort(.highAlcohol)) {
      $0.selectedSort = .highAlcohol
      $0.showSortOptions = false
    }
  }

  // MARK: - Misc

  func test_resetScroll_setsFlagFalse() async {
    var state = FilterCore.State()
    state.scrollToTop = true
    let store = TestStore(initialState: state) { FilterCore() }

    await store.send(.resetScroll) {
      $0.scrollToTop = false
    }
  }

  func test_moveToInformation_isNoop() async {
    let store = TestStore(initialState: FilterCore.State()) { FilterCore() }

    let makgeolli = Self.sampleMakgeolli
    await store.send(.moveToInformation(makgeolli, nil))
  }

  // MARK: - Helpers

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
