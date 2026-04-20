import Foundation
import UIKit
import AVFoundation

final class CameraManager: NSObject, ObservableObject, @unchecked Sendable {
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

final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
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
