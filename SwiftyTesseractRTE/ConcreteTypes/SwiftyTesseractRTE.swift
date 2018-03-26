//
//  SwiftyTesseractRTE.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/5/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import SwiftyTesseract
import AVFoundation

// MARK: - SwiftyTesseractRTEDelegate definition
public protocol SwiftyTesseractRTEDelegate: class {
  /// SwiftyTesseractRTEDelegate
  ///
  /// - Parameter recognizedString: The string returned after recognition has completed
  func onRecognitionComplete(_ recognizedString: String)

}

public class SwiftyTesseractRTE: NSObject {
  
  // MARK: - Private variables
  /// Used as a container to hold the last N frames OCR results to verify stability of recognition accuracy,
  /// where N is defined by the raw value of the RecognitionReliability set by the user during initialization.
  private var recognitionQueue: RecognitionQueue<String>
  
  // MARK: - Private constants
  private let swiftyTesseract: SwiftyTesseract
  private let imageProcessor: AVSampleProcessor
  private let avManager: AVManager
  
  // MARK: - Public variables
  /// The region within the AVCaptureVideoPreviewLayer that OCR is to be performed. If using a UIView to define the region of interest this **must**
  /// be assigned as the UIView's frame and be a subview of the the AVCaptureVideoPreviewLayer's parent view.
  public var regionOfInterest: CGRect?

  /// Sets recognition to be running or not. Default is **true**. Setting the value to false will allow the preview to be active without processing
  /// incoming video frames. If it is not desired for recognition to be active after initialization, set this value to false immediately after
  /// creating an instance of SwiftyTesseractRTE
  public var recognitionIsActive: Bool = true
  
  // MARK: - Computed Properties
  /// Returns the previewLayer configured for SwiftyTesseractRTE set to aspectFill. This is a **get** only property. The video gravity is set to
  /// resizeAspectFill; changing this setting will result in undefined behavior.
  public var previewLayer: AVCaptureVideoPreviewLayer {
    return avManager.previewLayer
  }
  
  /// The quality of the previewLayer video session. The default is set to .medium. Changing this setting will only affect how the video is displayed to the
  /// user and will not affect the results of OCR if set above `.medium`. Setting the quality higher will result in decreased performance.
  public var cameraQuality: AVCaptureSession.Preset {
    get {
      return avManager.cameraQuality
    }
    set {
      avManager.cameraQuality = newValue
    }
  }
  
  // MARK: - Delegate
  public weak var delegate: SwiftyTesseractRTEDelegate?

  // MARK: - Initializers
  /// Primary initializer
  ///
  /// - Parameters:
  ///   - swiftyTesseract: Instance of SwiftyTesseract
  ///   - desiredReliability: The desired reliability of the recognition results.
  ///   - cameraQuality: The desired camera quality output to be seen by the end user. The default is `.medium`.
  ///   Anything higher than `.medium` has no impact on recognition reliability
  public convenience init(swiftyTesseract: SwiftyTesseract,
                          desiredReliability: RecognitionReliability,
                          cameraQuality: AVCaptureSession.Preset = .medium) {
    
    let recognitionQueue = RecognitionQueue<String>(desiredReliability: desiredReliability)
    let videoManager = VideoManager(cameraQuality: cameraQuality)
    
    self.init(swiftyTesseract: swiftyTesseract,
              recognitionQueue: recognitionQueue,
              avManager: videoManager)
  }
  
  /// Secondary Initializer. Use this **only** if custom image processing logic is needed
  ///
  /// - Parameters:
  ///   - swiftyTesseract: Instance of SwiftyTesseract
  ///   - desiredReliability: The desired reliability of the recognition results.
  ///   - imageProcessor: Performs conversion and processing from `CMSampleBuffer` to `UIImage`
  ///   - cameraQuality: The desired camera quality output to be seen by the end user. The default is .medium.
  ///   Anything higher than .medium has no impact on recognition reliability
  public convenience init(swiftyTesseract: SwiftyTesseract,
                          desiredReliability: RecognitionReliability,
                          imageProcessor: AVSampleProcessor,
                          cameraQuality: AVCaptureSession.Preset = .medium) {
    
    let recognitionQueue = RecognitionQueue<String>(desiredReliability: desiredReliability)
    let avManager = VideoManager(cameraQuality: cameraQuality)
    
    self.init(swiftyTesseract: swiftyTesseract,
              recognitionQueue: recognitionQueue,
              imageProcessor: imageProcessor,
              avManager: avManager)
  }
  
  init(swiftyTesseract: SwiftyTesseract,
       recognitionQueue: RecognitionQueue<String>,
       imageProcessor: AVSampleProcessor = ImageProcessor(),
       avManager: AVManager = VideoManager()) {
    
    self.swiftyTesseract = swiftyTesseract
    self.recognitionQueue = recognitionQueue
    self.imageProcessor = imageProcessor
    self.avManager = avManager
    super.init()
    self.avManager.delegate = self
  }
  
  // MARK: - Public functions
  /// Stops the camera preview
  public func stopPreview() {
    avManager.captureSession.stopRunning()
  }
  
  /// Restarts the camera preview
  public func resumePreview() {
    avManager.captureSession.startRunning()
  }
  
  /// Binds SwiftyTesseractRTE AVCaptureVideoPreviewLayer to UIView.
  ///
  /// - Parameter view: The view to present the live preview
  public func bindPreviewLayer(to view: UIView) {
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else { return }
      view.layer.addSublayer(strongSelf.avManager.previewLayer)
      strongSelf.avManager.previewLayer.frame = view.bounds
    }
    
  }
  
  // MARK: - Helper functions
  private func cropAndConvert(sampleBuffer: CMSampleBuffer) -> UIImage? {
    
    guard
      let processedImage = imageProcessor.convertToGrayscaleUiImage(from: sampleBuffer),
      let imageCroppedToPreviewLayer = imageProcessor.crop(output: processedImage, toBoundsOf: previewLayer)
    else { return nil }
    
    guard
      let regionOfInterest = regionOfInterest,
      let imageCroppedToRegionOfInterest = imageProcessor.crop(output: imageCroppedToPreviewLayer, toBoundsOf: regionOfInterest, containedIn: previewLayer)
    else { return imageCroppedToPreviewLayer }
    
    return imageCroppedToRegionOfInterest
  }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Extension

extension SwiftyTesseractRTE: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    guard recognitionIsActive, let croppedImage = cropAndConvert(sampleBuffer: sampleBuffer) else { return }
    
    try? swiftyTesseract.performOCR(on: croppedImage) { [weak self] recognizedString in

      guard let recognizedString = recognizedString, let strongSelf = self else { return }

      guard strongSelf.recognitionQueue.count == strongSelf.recognitionQueue.size && strongSelf.recognitionQueue.allValuesMatch else {
        strongSelf.recognitionQueue.enqueue(recognizedString)
        return
      }
      
      strongSelf.delegate?.onRecognitionComplete(recognizedString)
      strongSelf.recognitionQueue.clear()
    }
  }
}
