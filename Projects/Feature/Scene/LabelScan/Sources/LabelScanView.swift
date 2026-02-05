//
//  LabelScanView.swift
//  FeatureLabelScan
//
//  Created by Claude Code on 12/27/24.
//  Copyright © 2024 com.azhy.julook. All rights reserved.
//

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
      "알림",
      isPresented: Binding(
        get: { store.isShowingError },
        set: { _ in store.send(.dismissError) }
      )
    ) {
      Button("확인") {
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
      Text("막걸리 라벨을 프레임 안에 맞춰주세요")
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

// MARK: - Camera Components

private struct CameraPreviewContainer: View {
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

private struct ScanGuideFrame: View {
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

private struct CameraPreviewView: UIViewRepresentable {
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

private final class CameraManager: NSObject, ObservableObject, @unchecked Sendable {
  nonisolated(unsafe) let session = AVCaptureSession()
  nonisolated(unsafe) private var photoOutput = AVCapturePhotoOutput()
  private var photoCaptureDelegate: PhotoCaptureDelegate?
  var onPhotoCaptured: ((UIImage) -> Void)?
  
  deinit {
    session.stopRunning()
  }
  
  func checkPermissionAndSetup() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      setupCamera()
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        if granted {
          DispatchQueue.main.async {
            self?.setupCamera()
          }
        }
      }
    default:
      break
    }
  }
  
  private func setupCamera() {
    session.beginConfiguration()
    
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                               for: .video, position: .back),
          let input = try? AVCaptureDeviceInput(device: device) else {
      session.commitConfiguration()
      return
    }
    
    if session.canAddInput(input) {
      session.addInput(input)
    }
    
    if session.canAddOutput(photoOutput) {
      session.addOutput(photoOutput)
    }
    
    session.commitConfiguration()
    
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.session.startRunning()
    }
  }
  
  func capturePhoto() {
    let settings = AVCapturePhotoSettings()
    let delegate = PhotoCaptureDelegate { [weak self] image in
      DispatchQueue.main.async {
        self?.onPhotoCaptured?(image)
      }
    }
    self.photoCaptureDelegate = delegate
    photoOutput.capturePhoto(with: settings, delegate: delegate)
  }
  
  func stopSession() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.session.stopRunning()
    }
  }
  
  func pauseSession() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.session.stopRunning()
    }
  }
  
  func resumeSession() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      if self?.session.isRunning == false {
        self?.session.startRunning()
      }
    }
  }
}

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
  private let completion: @Sendable (UIImage) -> Void
  
  init(completion: @escaping @Sendable (UIImage) -> Void) {
    self.completion = completion
  }
  
  func photoOutput(_ output: AVCapturePhotoOutput,
                   didFinishProcessingPhoto photo: AVCapturePhoto,
                   error: Error?) {
    guard error == nil,
          let data = photo.fileDataRepresentation(),
          let image = UIImage(data: data) else {
      return
    }
    completion(image)
  }
}

extension Notification.Name {
  static let capturePhoto = Notification.Name("capturePhoto")
}

// MARK: - Candidate Selection

private struct CandidateSelectionView: View {
  let store: StoreOf<LabelScanCore>
  
  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(Color.w10)
        .frame(width: 36, height: 5)
        .padding(.top, 8)
        .padding(.bottom, 20)
      
      ScrollView {
        VStack(spacing: 16) {
          ForEach(store.candidates) { makgeolli in
            let imageURL = store.candidateImages[makgeolli.id]
            
            CandidateRow(
              makgeolli: makgeolli,
              imageURL: imageURL,
              store: store
            )
            
            if makgeolli.id != store.candidates.last?.id {
              Divider()
                .background(Color.w10)
            }
          }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
      }
    }
    .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
  }
}

private struct CandidateRow: View {
  let makgeolli: Makgeolli
  let imageURL: URL?
  let store: StoreOf<LabelScanCore>
  
  var body: some View {
    Button {
      store.send(.selectCandidate(makgeolli))
    } label: {
      HStack(spacing: 0) {
        Group {
          if let imageURL = imageURL {
            AsyncImage(url: imageURL) { phase in
              makeImageView(for: phase)
            }
          } else {
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 30, height: 60)
          }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(DesignSystemAsset.Colors.darkgray.swiftUIColor)
        .cornerRadius(12)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(makgeolli.name)
            .foregroundColor(.w)
            .font(.SF14R)
            .lineLimit(1)
          
          if let brewery = makgeolli.brewery {
            Text("\(brewery) ･ \(formatValue(makgeolli.alcoholPercentage))도")
              .foregroundColor(.w50)
              .font(.SF10B)
              .lineLimit(1)
          } else {
            Text("\(formatValue(makgeolli.alcoholPercentage))도")
              .foregroundColor(.w50)
              .font(.SF10B)
              .lineLimit(1)
          }
        }
        .padding(.horizontal, 16)
        
        Spacer()
        
        HStack(spacing: 6) {
          ScoreItem(
            score: makgeolli.sweetness,
            label: "단맛",
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.sourness,
            label: "신맛",
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.thickness,
            label: "걸쭉",
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.carbonation,
            label: "탄산",
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
        }
      }
    }
    .padding(.vertical, 8)
  }
}

private extension CandidateRow {
  @ViewBuilder
  func ScoreItem(score: Int?, label: String, color: Color) -> some View {
    VStack(spacing: 4) {
      getScoreImage(for: score)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24, height: 24)
      
      Text(label)
        .foregroundColor(.w50)
        .font(.SF10B)
    }
  }
  
  func getScoreImage(for score: Int?) -> Image {
    guard let score = score else {
      return DesignSystemAsset.Images.nillScore.swiftUIImage
    }
    
    switch score {
    case 0:
      return DesignSystemAsset.Images._0Score.swiftUIImage
    case 1:
      return DesignSystemAsset.Images._1Score.swiftUIImage
    case 2:
      return DesignSystemAsset.Images._2Score.swiftUIImage
    case 3:
      return DesignSystemAsset.Images._3Score.swiftUIImage
    case 4:
      return DesignSystemAsset.Images._4Score.swiftUIImage
    case 5:
      return DesignSystemAsset.Images._5Score.swiftUIImage
    default:
      return DesignSystemAsset.Images.nillScore.swiftUIImage
    }
  }
  
  @ViewBuilder
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      AnyView(
        ProgressView()
          .frame(width: 30, height: 60)
      )
    case .success(let image):
      AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    case .failure:
      AnyView(
        DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    @unknown default:
      AnyView(
        DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    }
  }
  
  func formatValue<T>(_ value: T?) -> String {
    guard let value = value else { return "-" }
    return "\(value)"
  }
}
