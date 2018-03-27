//
//  ImageProcessor.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

/// To be implemented if custom image processing is needed. Methods only need to be implemented; SwiftyTesseractRTE calls the methods internally.
public protocol AVSampleProcessor {
  // MARK: - `CIContext` member variable is required to reduce memory footprint - for use in converting from `CIImage` to `CGImage`
  var ciContext: CIContext { get }
  
  // MARK: - Color adjustment methods
  /// Used to apply a `CIFilter` to converted `CIImage` output from `convertToCiImage(from:)`
  ///
  /// - Parameter ciImage: The `CIImage` to apply `CIFilter` to
  /// - Returns: New CIImage 
  func adjustColors(in ciImage: CIImage?) -> CIImage?
  
  /// Used to transform CGImage to grayscale from CGImage output from `convertToCgImage(from:)`
  ///
  /// - Parameter image: The `CGImage` to convert to grayscale
  /// - Returns: Grayscale `CGImage`
  func convertToGrayscale(_ image: CGImage?) -> CGImage?
  
  // MARK: - Image transformation methods
  func convertToCvImageBuffer(from sampleBuffer: CMSampleBuffer) -> CVImageBuffer?
  func convertToCiImage(from imageBuffer: CVImageBuffer?) -> CIImage?
  func convertToCgImage(from ciImage: CIImage?) -> CGImage?
  func convertToUiImage(from cgImage: CGImage?) -> UIImage?
  
  func convertToGrayscaleUiImage(from sampleBuffer: CMSampleBuffer) -> UIImage?
  
  // MARK: - Cropping methods
  /// Crops transformed UIImage to the bounds of internal AVCaptureVideoPreviewLayer
  ///
  /// - Parameters:
  ///   - image: The `UIImage` output from `convertToGrayscaleUiImage(from:)`
  ///   - previewLayer: Internal `SwiftyTesseractRTE AVCaptureVideoPreviewLayer`
  /// - Returns: Cropped UIImage
  func crop(output image: UIImage, toBoundsOf previewLayer: AVCaptureVideoPreviewLayer) -> UIImage?
  
  
  /// Crops pre-cropped `UIImage` to the bounds of areaOfInterest. The areaOfInterest must be located within the bounds
  /// of the AVCaptureVideoPreviewLayer or recognition will not be properly performed.
  ///
  /// - Parameters:
  ///   - image: The pre-cropped image from `crop(output:toBoundsOf:)`
  ///   - areaOfInterest: The area within the `AVCaptureVideoPreviewLayer` to explicitly perform recognition on
  ///   - previewLayer: Internal `SwiftyTesseractRTE
  /// - Returns: Final `UIImage` ready for OCR
  func crop(output image: UIImage, toBoundsOf areaOfInterest: CGRect, containedIn previewLayer: AVCaptureVideoPreviewLayer) -> UIImage?
}

public extension AVSampleProcessor {
  /// Chains all image processing methods together for simplicity at the call site.
  ///
  /// Default implementation provided, but may be implemented if customization is neccessary.
  ///
  /// - Parameter sampleBuffer: The sampleBuffer output by the internal AVCaptureSession
  /// - Returns: UIImage processed from raw CMSampleBuffer
  func convertToGrayscaleUiImage(from sampleBuffer: CMSampleBuffer) -> UIImage? {
    guard
      let uiImage = sampleBuffer
        |> convertToCvImageBuffer
        |> convertToCiImage
        |> adjustColors
        |> convertToCgImage
        |> convertToGrayscale
        |> convertToUiImage
      else { return nil }
    
    return uiImage
  }

}
