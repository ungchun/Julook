import Foundation
import UIKit

import Core
import DesignSystem

import ComposableArchitecture

@Reducer
public struct LabelScanCore {
  @ObservableState
  public struct State: Equatable, Hashable {
    // 카메라 상태
    public var isCameraReady: Bool = false
    public var capturedImage: UIImage?

    // 분석 상태
    public var isAnalyzing: Bool = false
    public var analysisResult: Makgeolli?

    // 선택 화면 (여러 후보가 있을 때)
    public var candidates: [Makgeolli] = []
    public var candidateImages: [UUID: URL] = [:]
    public var isShowingCandidates: Bool = false

    // 에러
    public var errorMessage: String?
    public var isShowingError: Bool = false

    public init() {}
  }

  public enum Action {
    case onAppear
    case onDisappear

    case cameraReady
    case capturePhoto
    case photoCaptured(UIImage)
    case retakePhoto
    case resetCamera

    case analyzeImage(UIImage)
    case analysisCompleted(TaskResult<Makgeolli>)

    case showCandidates([Makgeolli])
    case candidateImagesLoaded([UUID: URL])
    case selectCandidate(Makgeolli)
    case dismissCandidates

    case showError(String)
    case dismissError

    case moveToInformation(Makgeolli, URL?)
  }

  public init() {}

  @Dependency(\.supabaseClient) var supabaseClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .onDisappear:
        state.capturedImage = nil
        state.analysisResult = nil
        return .none

      case .cameraReady:
        state.isCameraReady = true
        return .none

      case .capturePhoto:
        return .none

      case let .photoCaptured(image):
        state.capturedImage = image
        return .send(.analyzeImage(image))

      case .retakePhoto:
        state.capturedImage = nil
        state.analysisResult = nil
        state.isAnalyzing = false
        return .none

      case .resetCamera:
        state.capturedImage = nil
        return .none

      case let .analyzeImage(image):
        state.isAnalyzing = true
        return analyzeImageEffect(image: image)

      case let .analysisCompleted(.success(makgeolli)):
        state.isAnalyzing = false
        state.analysisResult = makgeolli
        return .none

      case .analysisCompleted(.failure):
        state.isAnalyzing = false
        return .send(.showError(L10n.LabelScan.Error.analysisFailed))

      case let .showError(message):
        state.isAnalyzing = false
        state.errorMessage = message
        state.isShowingError = true
        return .none

      case .dismissError:
        state.isShowingError = false
        state.errorMessage = nil
        state.capturedImage = nil
        state.analysisResult = nil
        return .none

      case let .showCandidates(candidates):
        state.isAnalyzing = false
        state.candidates = candidates
        return showCandidatesEffect(candidates: candidates)

      case let .candidateImagesLoaded(images):
        state.candidateImages = images
        state.isShowingCandidates = true
        return .none

      case let .selectCandidate(makgeolli):
        let imageURL = state.candidateImages[makgeolli.id]
        state.isShowingCandidates = false
        state.candidates = []
        state.candidateImages = [:]
        state.analysisResult = makgeolli
        return selectCandidateEffect(makgeolli: makgeolli, imageURL: imageURL)

      case .dismissCandidates:
        state.isShowingCandidates = false
        state.candidates = []
        state.capturedImage = nil
        return .none

      case .moveToInformation:
        return .none
      }
    }
  }
}
