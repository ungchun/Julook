import SwiftUI
import AVFoundation

import DesignSystem
import Core

import ComposableArchitecture

public struct LabelScanView: View {
  @Bindable var store: StoreOf<LabelScanCore>

  public init(store: StoreOf<LabelScanCore>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack(spacing: 0) {
        TopBar()
        CameraPreviewContainer(store: store)
        BottomControls()
      }

      if store.isAnalyzing {
        AnalyzingOverlay()
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
    .onDisappear {
      store.send(.onDisappear)
    }
    .alert(
      L10n.Common.Alert.notice,
      isPresented: Binding(
        get: { store.isShowingError },
        set: { _ in store.send(.dismissError) }
      )
    ) {
      Button(L10n.Common.Button.confirm) {
        store.send(.dismissError)
      }
    } message: {
      Text(store.errorMessage ?? "")
    }
    .sheet(
      isPresented: Binding(
        get: { store.isShowingCandidates },
        set: { _ in store.send(.dismissCandidates) }
      )
    ) {
      CandidateSelectionView(store: store)
    }
  }
}

// MARK: - UI Components

private extension LabelScanView {
  @ViewBuilder
  func TopBar() -> some View {
    HStack {
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(Color.black)
  }

  @ViewBuilder
  func BottomControls() -> some View {
    VStack(spacing: 24) {
      Text(L10n.LabelScan.Guide.prompt)
        .font(.SF15R)
        .foregroundColor(.w50)

      Button {
        NotificationCenter.default.post(name: .capturePhoto, object: nil)
      } label: {
        ZStack {
          Circle()
            .stroke(Color.white, lineWidth: 4)
            .frame(width: 64, height: 64)

          Circle()
            .fill(Color.white)
            .frame(width: 52, height: 52)
        }
      }
      .disabled(store.capturedImage != nil)
    }
    .padding(.vertical, 24)
    .frame(maxWidth: .infinity)
    .background(Color.black)
  }

  @ViewBuilder
  func AnalyzingOverlay() -> some View {
    ZStack {
      Color.black.opacity(0.7)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
          .scaleEffect(1.5)
      }
    }
  }
}
