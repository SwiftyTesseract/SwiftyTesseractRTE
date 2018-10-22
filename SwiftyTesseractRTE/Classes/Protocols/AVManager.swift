//
//  AVManager.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

/// To be implemented if custom AVFoundation logic is needed. This may be desireable if using
/// RealTimeEngine in tandem with another class or library that requires CMSampleBuffers
/// for processing.
public protocol AVManager: class {
  /// The `AVCaptureVideoPreviewLayer` displayed to the user
  var previewLayer: AVCaptureVideoPreviewLayer { get }
  /// The quality of the previewLayer video session.
  var cameraQuality: AVCaptureSession.Preset { get set }
  /// The underlying capture session providing previewLayer it's video feed
  var captureSession: AVCaptureSession { get }

  /// The delegate to receive the `CMSampleBuffer`s for processing.
  ///
  /// *Note*: If you are creating a custom object to conform to AVManager, you must
  /// manually set SwiftyTesseractRTE as it's delegate for SwiftyTesseractRTE to
  /// receive the `CMSampleBuffer`s *or* have another delegate directly pass
  /// the paramters of `capture(_:didOutput:from:)` to `RealTimeEngine`'s implementation
  /// otherwise they will not be received to be processed for OCR
  var delegate: AVCaptureVideoDataOutputSampleBufferDelegate? { get set }
}
