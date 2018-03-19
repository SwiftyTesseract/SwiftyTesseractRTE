//
//  ImageProcessor.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation
import AVFoundation

struct ImageProcessor {
  private(set) var ciContext: CIContext
  
  init(ciContext: CIContext = CIContext()) {
    self.ciContext = ciContext
  }
}

extension ImageProcessor: AVSampleProcessor {
  func adjustColors(in ciImage: CIImage?) -> CIImage? {
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
  
  func convertToGrayscale(_ image: CGImage?) -> CGImage? {
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
  
  func convertToCvImageBuffer(from sampleBuffer: CMSampleBuffer) -> CVImageBuffer? {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    return imageBuffer
  }
  
  func convertToCiImage(from imageBuffer: CVImageBuffer?) -> CIImage? {
    guard let imageBuffer = imageBuffer else { return nil }
    return CIImage(cvImageBuffer: imageBuffer)
  }
  
  func convertToCgImage(from ciImage: CIImage?) -> CGImage? {
    guard
      let ciImage = ciImage,
      let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
    else { return nil }
    return cgImage
  }
  
  func convertToUiImage(from cgImage: CGImage?) -> UIImage? {
    guard let cgImage = cgImage else { return nil }
    return UIImage(cgImage: cgImage)
  }
  
  func crop(output image: UIImage, toBoundsOf previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
    let widthToHeightRatio = previewLayer.bounds.size.width / previewLayer.bounds.size.height
    
    let cropWidth = image.size.width < image.size.height ? image.size.width : image.size.height * widthToHeightRatio
    let cropHeight = image.size.width < image.size.height ? cropWidth / widthToHeightRatio : image.size.height
    let cropX = cropWidth < cropHeight ? 0 : (image.size.width - cropWidth) / 2.0
    let cropY = (image.size.height - cropHeight) / 2.0

    let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
    
    guard let cropImage = image.cgImage?.cropping(to: cropRect) else { return nil }

    return UIImage(cgImage: cropImage, scale: image.scale, orientation: image.imageOrientation)
  }
  
  func crop(output image: UIImage, toBoundsOf areaOfInterest: CGRect, containedIn previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
    let previewLayerSize = previewLayer.bounds.size
    let heightMultiplier = image.size.height / previewLayerSize.height
    let widthMultiplier = image.size.width / previewLayerSize.width
    let xOffset = image.size.width - previewLayerSize.width / 2
    let yOffset = image.size.height - previewLayerSize.height / 2

    let newSizeRect = CGRect(origin: .zero, size: previewLayerSize)
    let newRect = AVMakeRect(aspectRatio: image.size, insideRect: newSizeRect)
    UIGraphicsBeginImageContext(previewLayerSize)
    defer {
      UIGraphicsEndImageContext()
    }
    image.draw(in: newRect)
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
//    let transformation = CGAffineTransform
//      .identity
//      .translatedBy(x: areaOfInterest.origin.x * widthMultiplier / 2, y: areaOfInterest.origin.y * heightMultiplier / 2)
//      .scaledBy(x: widthMultiplier, y: heightMultiplier)
//    
//    
//    let croppingRect = areaOfInterest.applying(transformation)
//    
//    guard let cropImage = image.cgImage?.cropping(to: croppingRect) else { return newImage }
    guard let cropImage = newImage.cgImage?.cropping(to: areaOfInterest) else { return newImage }
    return UIImage(cgImage: cropImage, scale: image.scale, orientation: image.imageOrientation)
  }
  
  func convertToGrayscaleCgImage(from sampleBuffer: CMSampleBuffer) -> CGImage? {
    guard
      let cgImage = sampleBuffer
        |> convertToCvImageBuffer
        |> convertToCiImage
        |> adjustColors
        |> convertToCgImage
        |> convertToGrayscale
      else { return nil }
    return cgImage
  }
}
