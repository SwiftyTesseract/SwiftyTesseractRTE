//
//  ImageProcessor.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

/// To be implemented if custom image processing is needed. Methods only need to be implemented; SwiftyTesseractRTE calls the methods internally.
/// If implementing custom image processing logic, results will be 
public protocol AVSampleProcessor {
  // MARK: - Image transformation methods
  func convertToGrayscaleUiImage(from sampleBuffer: CMSampleBuffer) -> UIImage?
  
  // MARK: - Cropping methods
  /// Crops transformed UIImage to the bounds of internal AVCaptureVideoPreviewLayer
  ///
  /// - Parameters:
  ///   - image: The `UIImage` output from `convertToGrayscaleUiImage(from:)`
  ///   - previewLayer: Internal `SwiftyTesseractRTE AVCaptureVideoPreviewLayer`
  /// - Returns: Cropped UIImage
  func crop(_ image: UIImage, toBoundsOf previewLayer: AVCaptureVideoPreviewLayer) -> UIImage?
  
  
  /// Crops pre-cropped `UIImage` to the bounds of areaOfInterest. The areaOfInterest must be located within the bounds
  /// of the AVCaptureVideoPreviewLayer or recognition will not be properly performed.
  ///
  /// - Parameters:
  ///   - image: The pre-cropped image from `crop(output:toBoundsOf:)`
  ///   - areaOfInterest: The area within the `AVCaptureVideoPreviewLayer` to explicitly perform recognition on
  ///   - previewLayer: Internal `SwiftyTesseractRTE
  /// - Returns: Final `UIImage` ready for OCR
  func crop(_ image: UIImage, toBoundsOf areaOfInterest: CGRect, containedIn previewLayer: AVCaptureVideoPreviewLayer) -> UIImage?
}
