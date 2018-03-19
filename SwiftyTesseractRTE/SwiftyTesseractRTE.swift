//
//  SwiftyTesseractRTE.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/5/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation
import SwiftyTesseract

// MARK: - SwiftyTesseractRTEDelegate definition
public protocol SwiftyTesseractRTEDelegate: class {
  func onRecognitionComplete(_ recognizedString: String)
  func captured(image: UIImage)
}

public class SwiftyTesseractRTE: NSObject {
  
  // MARK: - Private variables
  private var recognitionQueue: RecognitionQueue<String>
  private var isAuthorized = false
  
  // MARK: - Private constants
  
  private let swiftyTesseract: SwiftyTesseract
  
  private let sessionQueue: DispatchQueue
  private let cameraPosition: AVCaptureDevice.Position
  private let cameraQuality: AVCaptureSession.Preset
  
  private let ciContext: CIContext
  
  // MARK: - Public variables
  public weak var sampleDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
  public weak var delegate: SwiftyTesseractRTEDelegate?
  public weak var previewLayer: AVCaptureVideoPreviewLayer?
  public var areaOfInterest: CGRect?
  public let captureSession: AVCaptureSession
  public var whitelist: String? {
    set {
      swiftyTesseract.whiteList = newValue
    }
    get {
      return swiftyTesseract.whiteList
    }
  }
  
  // MARK: - Initializer
  public init(desiredReliability: RecognitionReliability,
              previewLayer: AVCaptureVideoPreviewLayer?,
              bundle: Bundle = .main,
              recognitionLanguage: RecognitionLanguage = .english,
              ciContext: CIContext = CIContext(),
              captureSession: AVCaptureSession = AVCaptureSession(),
              sessionQueue: DispatchQueue = DispatchQueue(queueLabel: .session),
              cameraPosition: AVCaptureDevice.Position = .back,
              cameraQuality: AVCaptureSession.Preset = .medium,
              mediaType: AVMediaType = .video) {

    recognitionQueue = RecognitionQueue(maxElements: desiredReliability.rawValue)
    swiftyTesseract = SwiftyTesseract(language: recognitionLanguage, bundle: .main, engineMode: .lstmOnly)
    self.sessionQueue = sessionQueue
    self.cameraPosition = cameraPosition
    self.cameraQuality = cameraQuality
    self.ciContext = ciContext
    self.captureSession = captureSession
    self.previewLayer = previewLayer
    super.init()
    isAuthorized(for: mediaType)
    sessionQueue.async { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.configure(captureSession: strongSelf.captureSession,
                           withQuality: cameraQuality,
                           forMediaType: mediaType,
                           AndCameraPosition: cameraPosition)
      
      strongSelf.captureSession.startRunning()
    }
  }
  
  // MARK: - AVFoundation Methods
  
  @discardableResult
  private func isAuthorized(for mediaType: AVMediaType) -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: mediaType) {
    case .authorized:
      return true
    case .notDetermined:
      requestPermission(for: mediaType)
      return false
    default:
      return false
    }
  }
  
  private func requestPermission(for mediaType: AVMediaType) {
    sessionQueue.suspend()
    AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
      guard let strongSelf = self else { return }
      
      if granted {
        strongSelf.configure(captureSession: strongSelf.captureSession,
                             withQuality: strongSelf.cameraQuality,
                             forMediaType: mediaType,
                             AndCameraPosition: strongSelf.cameraPosition)
        
        strongSelf.sessionQueue.resume()
      }
    }
  }
  
  private func configure(captureSession: AVCaptureSession, withQuality quality: AVCaptureSession.Preset, forMediaType mediaType: AVMediaType,
                         AndCameraPosition cameraPosition: AVCaptureDevice.Position) {
    
    guard isAuthorized(for: mediaType) else { return }
    
    captureSession.sessionPreset = quality
    
    guard
      let captureDevice = AVCaptureDevice.default(for: mediaType),
      let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
      captureSession.canAddInput(captureDeviceInput)
    else { return }
    captureSession.addInput(captureDeviceInput)
    
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(queueLabel: .videoOutput))

    guard captureSession.canAddOutput(videoOutput) else { return }
    captureSession.addOutput(videoOutput)
    
    guard
      let connection = videoOutput.connection(with: mediaType),
      connection.isVideoOrientationSupported,
      connection.isVideoMirroringSupported
    else { return }

    connection.videoOrientation = .portrait
    connection.isVideoMirrored = cameraPosition == .front
  }
  
  
  // MARK: - Image processing methods
  
  private func adjustColors(in ciImage: CIImage?) -> CIImage? {
    guard
      let ciImage = ciImage,
      let filter = CIFilter(name: "CIColorControls",
                                withInputParameters: [kCIInputImageKey: ciImage,
                                                      kCIInputSaturationKey: 0,
                                                      kCIInputContrastKey: 1.45]),
      let processedImage = filter.outputImage
    else { return nil }
    
    return processedImage
  }
  
  private func convertToGrayscale(_ image: CGImage?) -> CGImage? {
    guard let image = image else { return nil }
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
    let cgContext = CGContext(data: nil,
                              width: image.width,
                              height: image.height,
                              bitsPerComponent: 8,
                              bytesPerRow: 0,
                              space: colorSpace,
                              bitmapInfo: bitmapInfo.rawValue)
    cgContext?.draw(image,
                    in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    
    return cgContext?.makeImage()
  }
  
  private func imageFrom(sampleBuffer: CMSampleBuffer) -> UIImage? {
    return sampleBuffer
      |> convertToCvImageBuffer
      |> convertToCiImage
      |> adjustColors
      |> convertToCgImage
      |> convertToGrayscale
      |> convertToUiImage
  }
  
  private func convertToCvImageBuffer(from sampleBuffer: CMSampleBuffer) -> CVImageBuffer? {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    return imageBuffer
  }
  
  private func convertToCiImage(from imageBuffer: CVImageBuffer?) -> CIImage? {
    guard let imageBuffer = imageBuffer else { return nil }
    return CIImage(cvImageBuffer: imageBuffer)
  }
  
  private func convertToCgImage(from ciImage: CIImage?) -> CGImage? {
    guard
      let ciImage = ciImage,
      let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
    else { return nil }
    return cgImage
  }
  
  private func convertToUiImage(from cgImage: CGImage?) -> UIImage? {
    guard let cgImage = cgImage else { return nil }
    return UIImage(cgImage: cgImage)
  }

  // MARK: - Cropping methods
  func crop(ouput image: UIImage, toBoundsOf previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {

    let widthToHeightRatio = previewLayer.bounds.size.width / previewLayer.bounds.size.height
    
    let cropWidth = image.size.width < image.size.height ? image.size.width : image.size.height * widthToHeightRatio
    let cropHeight = image.size.width < image.size.height ? cropWidth / widthToHeightRatio : image.size.height
    let cropX = cropWidth < cropHeight ? 0 : (image.size.width - cropWidth) / 2.0
    let cropY = (image.size.height - cropHeight) / 2.0
    
    let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
    
    guard let cropImage = image.cgImage?.cropping(to: cropRect) else { return nil }

    return UIImage(cgImage: cropImage, scale: image.scale, orientation: image.imageOrientation)
  }
  
  func crop(output image: UIImage, toBoundsOf areaOfInterest: CGRect) -> UIImage? {
    
    let previewLayerSize = previewLayer!.bounds.size

    let newSizeRect = CGRect(origin: .zero, size: previewLayerSize)
    let newRect = AVMakeRect(aspectRatio: image.size, insideRect: newSizeRect)
    UIGraphicsBeginImageContext(previewLayerSize)
    defer {
      UIGraphicsEndImageContext()
    }
    image.draw(in: newRect)
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
  
    guard let cropImage = newImage.cgImage?.cropping(to: areaOfInterest) else { return newImage }
    return UIImage(cgImage: cropImage, scale: image.scale, orientation: image.imageOrientation)

  }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Extension

extension SwiftyTesseractRTE: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    guard
      let cgImage = sampleBuffer
        |> convertToCvImageBuffer
        |> convertToCiImage
        |> adjustColors
        |> convertToCgImage
        |> convertToGrayscale
    else { return }
    
    let image = UIImage(cgImage: cgImage)
    guard
      let previewLayer = previewLayer,
      let thisImage = crop(ouput: image, toBoundsOf: previewLayer),
      let thatImage = crop(output: thisImage, toBoundsOf: areaOfInterest!)
    else { return }
    
    delegate?.captured(image: thatImage)
    swiftyTesseract.performOCR(from: thatImage) { [weak self] success, recognizedString in
      guard success, let recognizedString = recognizedString else { return }
      self?.delegate?.onRecognitionComplete(recognizedString)
    }
  }
}
