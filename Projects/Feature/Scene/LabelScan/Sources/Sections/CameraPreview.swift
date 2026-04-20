import SwiftUI
import AVFoundation

import Core
import DesignSystem

import ComposableArchitecture

struct CameraPreviewContainer: View {
  let store: StoreOf<LabelScanCore>
  @StateObject private var cameraManager = CameraManager()

  var body: some View {
    GeometryReader { geometry in
      let frameWidth = geometry.size.width * 0.75
      let frameHeight = frameWidth * 1.3

      ZStack {
        CameraPreviewView(session: cameraManager.session)
          .ignoresSafeArea()

        if let capturedImage = store.capturedImage {
          Image(uiImage: capturedImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: frameWidth, height: frameHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }

        ScanGuideFrame(size: geometry.size)
      }
    }
    .onAppear {
      cameraManager.checkPermissionAndSetup()
      cameraManager.onPhotoCaptured = { image in
        store.send(.photoCaptured(image))
      }
    }
    .onChange(of: store.capturedImage) { _, newImage in
      if newImage != nil {
        cameraManager.pauseSession()
      } else {
        cameraManager.resumeSession()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .capturePhoto)) { _ in
      cameraManager.capturePhoto()
    }
  }
}

struct ScanGuideFrame: View {
  let size: CGSize

  var body: some View {
    let frameWidth = size.width * 0.75
    let frameHeight = frameWidth * 1.3

    ZStack {
      Rectangle()
        .fill(Color.black.opacity(0.5))
        .mask(
          Rectangle()
            .overlay(
              RoundedRectangle(cornerRadius: 20)
                .frame(width: frameWidth, height: frameHeight)
                .blendMode(.destinationOut)
            )
            .compositingGroup()
        )

      RoundedRectangle(cornerRadius: 20)
        .stroke(DesignSystemAsset.Colors.primary.swiftUIColor, lineWidth: 3)
        .frame(width: frameWidth, height: frameHeight)
    }
  }
}

struct CameraPreviewView: UIViewRepresentable {
  let session: AVCaptureSession

  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: .zero)
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.frame = view.bounds
    view.layer.addSublayer(previewLayer)
    context.coordinator.previewLayer = previewLayer
    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    DispatchQueue.main.async {
      context.coordinator.previewLayer?.frame = uiView.bounds
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  class Coordinator {
    var previewLayer: AVCaptureVideoPreviewLayer?
  }
}

extension Notification.Name {
  static let capturePhoto = Notification.Name("capturePhoto")
}
