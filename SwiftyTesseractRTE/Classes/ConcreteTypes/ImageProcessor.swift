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
}

// MARK: - Helper Functions
extension ImageProcessor {
  private func adjustColors(in ciImage: CIImage) -> CIImage? {
    let filter = CIFilter(name: "CIColorControls",
                          parameters: [kCIInputImageKey: ciImage,
                                       kCIInputSaturationKey: 0,
                                       kCIInputContrastKey: 1.45])
    return filter?.outputImage
  }
  
  private func grayscaled(_ image: CGImage) -> CGImage? {
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
  
  private func calculateCroppingRect(for image: UIImage, toSize size: CGSize) -> CGRect {
    let aspectRatio = size.width / size.height
    let cropWidth = aspectRatio > 1 ? image.size.width : image.size.height * aspectRatio
    let cropHeight = aspectRatio > 1 ? cropWidth / aspectRatio : image.size.height / aspectRatio
    let cropX = aspectRatio > 1 ? 0 : (image.size.width - cropWidth) / 2.0
    let cropY = (image.size.height - cropHeight) / 2.0
    return CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
  }
  
  private func crop(_ image: UIImage, toBoundsOf previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
    let previewLayerSize = previewLayer.bounds.size
    let cropRect = calculateCroppingRect(for: image, toSize: previewLayerSize)
    return image.cgImage?.cropping(to: cropRect)
      .flatMap { croppedImage in
        return UIImage(cgImage: croppedImage, scale: image.scale, orientation: image.imageOrientation)
    }
  }
    
  private func crop(_ image: UIImage, toBoundsOf areaOfInterest: CGRect, at scale: TwoDimensionalScale) -> UIImage? {
    let resizedAreaOfInterest = resize(areaOfInterest, to: scale)
    
    return image.cgImage?.cropping(to: resizedAreaOfInterest)
      .flatMap { croppedImage in
        return UIImage(cgImage: croppedImage, scale: image.scale, orientation: image.imageOrientation)
    }
  }
  
  private func resize(_ rect: CGRect, to scale: TwoDimensionalScale) -> CGRect {
    return CGRect(x: rect.origin.x * scale.y,
                  y: rect.origin.y * scale.x,
                  width: rect.width * scale.y,
                  height: rect.height * scale.x)
  }
}

extension ImageProcessor: AVSampleProcessor {
  func convertToGrayscaleUiImage(from sampleBuffer: CMSampleBuffer) -> UIImage? {
    return CMSampleBufferGetImageBuffer(sampleBuffer)
        .flatMap(
          CIImage.init(cvImageBuffer:) >>>
          adjustColors >>>
          ciContext.createCGImage >>>
          grayscaled >>>
          UIImage.init
        )
  }
  
  func crop(_ image: UIImage, toBoundsOf areaOfInterest: CGRect, containedIn previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
    return crop(image, toBoundsOf: previewLayer).flatMap { image in
      let previewLayerSize = previewLayer.bounds.size
      let scale = TwoDimensionalScale(x: image.size.height / previewLayerSize.height, y: image.size.width / previewLayerSize.width)
      return crop(image, toBoundsOf: areaOfInterest, at: scale)
    }
  }
}

extension CIContext {
  // Helper function to allow for passing a single value to `createCGImage(_:from:)`
  func createCGImage(_ ciImage: CIImage) -> CGImage? {
    return createCGImage(ciImage, from: ciImage.extent)
  }
}

// Helper struct to reduce the API surface area of CGPoint when using it for scaling operations
private struct TwoDimensionalScale {
  private let cgPoint: CGPoint
  
  var y: CGFloat {
    return cgPoint.y
  }
  
  var x: CGFloat {
    return cgPoint.x
  }
  
  init(x: CGFloat, y: CGFloat) {
    cgPoint = CGPoint(x: x, y: y)
  }
}
