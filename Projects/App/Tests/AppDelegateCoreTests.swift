import XCTest

import ComposableArchitecture

@testable import Core
@testable import Julook

@MainActor
final class AppDelegateCoreTests: XCTestCase {

  // MARK: - Launch flow

  func test_didFinishLaunching_dispatchesSetupSupabaseAndSwiftData() async {
    let store = TestStore(initialState: AppDelegateCore.State()) {
      AppDelegateCore()
    } withDependencies: {
      $0.supabaseClient.initialize = { }
      $0.myMakgeolliClient.initialize = { }
    }

    await store.send(.didFinishLaunching)
    await store.receive(\.setupSupabase)
    await store.receive(\.setupSwiftData)
  }

  // MARK: - SwiftData setup failure

  func test_setupSwiftData_whenInitializeFails_logsError() async {
    struct DummyError: Error {}
    let store = TestStore(initialState: AppDelegateCore.State()) {
      AppDelegateCore()
    } withDependencies: {
      $0.myMakgeolliClient.initialize = { throw DummyError() }
    }

    await store.send(.setupSwiftData)
    await store.receive(\.logError)
  }
}

final class AppDelegateCoreErrorTests: XCTestCase {

  func test_init_preservesCodeAndUnderlying() {
    struct Dummy: Error {}
    let error = AppDelegateCoreError(
      code: .failToSwiftDataInitialized,
      underlying: Dummy()
    )

    XCTAssertEqual(error.code, .failToSwiftDataInitialized)
    XCTAssertTrue(error.underlying is Dummy)
  }

  func test_code_rawValuesAreStable() {
    XCTAssertEqual(AppDelegateCoreError.Code.failToSupabaseInitialized.rawValue, 0)
    XCTAssertEqual(AppDelegateCoreError.Code.failToSwiftDataInitialized.rawValue, 1)
  }
}
