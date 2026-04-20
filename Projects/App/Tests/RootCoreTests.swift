import XCTest

import ComposableArchitecture

@testable import Core
@testable import Julook

@MainActor
final class RootCoreTests: XCTestCase {

  // MARK: - Toast

  func test_showToast_setsMessageAndType() async {
    let store = TestStore(initialState: RootCore.State()) { RootCore() }

    await store.send(.showToast("에러 발생", .error)) {
      $0.toastMessage = "에러 발생"
      $0.toastType = .error
      $0.showToast = true
    }
  }

  func test_dismissToast_clearsFlag() async {
    var state = RootCore.State()
    state.showToast = true
    state.toastMessage = "prev"
    let store = TestStore(initialState: state) { RootCore() }

    await store.send(.dismissToast) {
      $0.showToast = false
    }
  }

  // MARK: - Update alert

  func test_dismissUpdateAlert_clearsFlag() async {
    var state = RootCore.State()
    state.showUpdateAlert = true
    let store = TestStore(initialState: state) { RootCore() }

    await store.send(.dismissUpdateAlert) {
      $0.showUpdateAlert = false
    }
  }

  // MARK: - Splash completion idempotency

  func test_splashCompleted_whileCheckingForUpdates_isNoop() async {
    var state = RootCore.State()
    state.isCheckingForUpdates = true
    let store = TestStore(initialState: state) { RootCore() }

    await store.send(.splashCompleted)
    // destination 변경 없음 — 로딩 중에는 전환 차단
  }

  func test_splashCompleted_whenShowUpdateAlert_isNoop() async {
    var state = RootCore.State()
    state.showUpdateAlert = true
    let store = TestStore(initialState: state) { RootCore() }

    await store.send(.splashCompleted)
    // 업데이트 alert 표시 중에는 전환 차단
  }
}
