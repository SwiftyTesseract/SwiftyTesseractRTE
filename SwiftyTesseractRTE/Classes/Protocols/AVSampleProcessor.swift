//
//  AVSampleProcessor.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

/// To be implemented if custom image processing is needed.
/// The default SwiftyTesseractRTE implementation does a small
/// amount of image enhancement and conversion to grayscale.
/// If the results from `RealTimeEngine` do not come back reliably,
/// then performing your own image processing may be neccessary to
/// receive optimal results.
public protocol AVSampleProcessor {
  // MARK: - Image transformation methods
  
  /// Converts CMSampleBuffer into a grayscale UIImage.
  ///
  /// - Parameter sampleBuffer: The incoming `CMSampleBuffer` from the AVCaptureSession
  /// - Returns: An optional grayscale `UIImage`
  func convertToGrayscaleUiImage(from sampleBuffer: CMSampleBuffer) -> UIImage?
  
  /// Crops `UIImage` to the bounds of areaOfInterest. The areaOfInterest must be located within the bounds
  /// of the AVCaptureVideoPreviewLayer or recognition will not be properly performed.
  ///
  /// - Parameters:
  ///   - image: The image to be processed for OCR
  ///   - areaOfInterest: The area within the `AVCaptureVideoPreviewLayer` to explicitly perform recognition on
  ///   - previewLayer: Internal `RealTimeEngine
  /// - Returns: Final `UIImage` ready for OCR
  func crop(_ image: UIImage, toBoundsOf areaOfInterest: CGRect, containedIn previewLayer: AVCaptureVideoPreviewLayer) -> UIImage?
}
