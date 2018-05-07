//
//  AVManager.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

public protocol AVManager: class {
  var previewLayer: AVCaptureVideoPreviewLayer { get }
  var cameraQuality: AVCaptureSession.Preset { get set }
  var captureSession: AVCaptureSession { get }

  var delegate: AVCaptureVideoDataOutputSampleBufferDelegate? { get set }
}
