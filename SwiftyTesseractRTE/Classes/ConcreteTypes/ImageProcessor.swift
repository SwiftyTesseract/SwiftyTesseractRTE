//
//  ImageProcessor.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

struct ImageProcessor {
  private var ciContext: CIContext
  
  init(ciContext: CIContext = CIContext()) {
    self.ciContext = ciContext
  }
  
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
  
}

extension ImageProcessor: AVSampleProcessor {

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
  
  func crop(_ image: UIImage, toBoundsOf previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
    
    let widthToHeightRatio = previewLayer.bounds.size.width / previewLayer.bounds.size.height
    
    let cropWidth = image.size.width < image.size.height ? image.size.width : image.size.height * widthToHeightRatio
    let cropHeight = image.size.width < image.size.height ? cropWidth / widthToHeightRatio : image.size.height
    let cropX = cropWidth < cropHeight ? 0 : (image.size.width - cropWidth) / 2.0
    let cropY = (image.size.height - cropHeight) / 2.0

    let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
    
    guard let cropImage = image.cgImage?.cropping(to: cropRect) else { return nil }
    return UIImage(cgImage: cropImage, scale: image.scale, orientation: image.imageOrientation)
  }
  
  func crop(_ image: UIImage, toBoundsOf areaOfInterest: CGRect, containedIn previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
    let previewLayerSize = previewLayer.bounds.size
    let yAxisMultiplier = image.size.height / previewLayerSize.height
    let xAxisMultiplier = image.size.width / previewLayerSize.width
    
    let resizedAreaOfInterest = CGRect(x: areaOfInterest.origin.x * xAxisMultiplier,
                                       y: areaOfInterest.origin.y * yAxisMultiplier,
                                       width: areaOfInterest.width * xAxisMultiplier,
                                       height: areaOfInterest.height * yAxisMultiplier)
    
    guard let cropImage = image.cgImage?.cropping(to: resizedAreaOfInterest) else { return image }
    return UIImage(cgImage: cropImage, scale: image.scale, orientation: image.imageOrientation)
  }
}
