import XCTest

import ComposableArchitecture

@testable import Core
@testable import FeatureLabelScan

@MainActor
final class LabelScanCoreTests: XCTestCase {

  // MARK: - Camera lifecycle

  func test_cameraReady_setsFlag() async {
    let store = TestStore(initialState: LabelScanCore.State()) { LabelScanCore() }

    await store.send(.cameraReady) {
      $0.isCameraReady = true
    }
  }

  func test_onAppear_isNoop() async {
    let store = TestStore(initialState: LabelScanCore.State()) { LabelScanCore() }

    await store.send(.onAppear)
  }

  func test_onDisappear_clearsCapturedAndResult() async {
    var initial = LabelScanCore.State()
    initial.capturedImage = UIImage()
    initial.analysisResult = Self.sampleMakgeolli
    let store = TestStore(initialState: initial) { LabelScanCore() }

    await store.send(.onDisappear) {
      $0.capturedImage = nil
      $0.analysisResult = nil
    }
  }

  // MARK: - Error display

  func test_showError_setsMessageAndFlag() async {
    let store = TestStore(initialState: LabelScanCore.State()) { LabelScanCore() }

    await store.send(.showError("테스트 에러")) {
      $0.errorMessage = "테스트 에러"
      $0.isShowingError = true
    }
  }

  func test_dismissError_clearsMessageAndFlag() async {
    var initial = LabelScanCore.State()
    initial.errorMessage = "prev"
    initial.isShowingError = true
    let store = TestStore(initialState: initial) { LabelScanCore() }

    await store.send(.dismissError) {
      $0.errorMessage = nil
      $0.isShowingError = false
    }
  }

  // MARK: - Candidates

  func test_dismissCandidates_resets() async {
    var initial = LabelScanCore.State()
    initial.candidates = [Self.sampleMakgeolli]
    initial.capturedImage = UIImage()
    initial.isShowingCandidates = true
    let store = TestStore(initialState: initial) { LabelScanCore() }

    await store.send(.dismissCandidates) {
      $0.candidates = []
      $0.isShowingCandidates = false
      $0.capturedImage = nil
    }
  }

  func test_candidateImagesLoaded_showsSheetAndSetsMap() async {
    let store = TestStore(initialState: LabelScanCore.State()) { LabelScanCore() }
    let url = URL(string: "https://example.com/a.png")!
    let id = UUID()

    await store.send(.candidateImagesLoaded([id: url])) {
      $0.candidateImages = [id: url]
      $0.isShowingCandidates = true
    }
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
