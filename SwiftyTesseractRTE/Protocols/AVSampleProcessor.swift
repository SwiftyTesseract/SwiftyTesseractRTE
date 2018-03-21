//
//  ImageProcessor.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation
import AVFoundation

public protocol AVSampleProcessor {
  var ciContext: CIContext { get }
  
  // Color adjustment methods
  func adjustColors(in ciImage: CIImage?) -> CIImage?
  func convertToGrayscale(_ image: CGImage?) -> CGImage?
  
  // Image transformation methods
  func convertToCvImageBuffer(from sampleBuffer: CMSampleBuffer) -> CVImageBuffer?
  func convertToCiImage(from imageBuffer: CVImageBuffer?) -> CIImage?
  func convertToCgImage(from ciImage: CIImage?) -> CGImage?
  func convertToUiImage(from cgImage: CGImage?) -> UIImage?
  func convertToGrayscaleCgImage(from sampleBuffer: CMSampleBuffer) -> CGImage?
  
  func crop(output image: UIImage, toBoundsOf previewLayer: AVCaptureVideoPreviewLayer) -> UIImage?
  func crop(output image: UIImage, toBoundsOf areaOfInterest: CGRect, containedIn previewLayer: AVCaptureVideoPreviewLayer) -> UIImage?
}
