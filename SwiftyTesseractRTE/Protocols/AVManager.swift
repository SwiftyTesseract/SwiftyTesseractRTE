//
//  AVManager.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

protocol AVManager: class {
  // MARK: - Required member variables
  var previewLayer: AVCaptureVideoPreviewLayer { get }
  var captureSession: AVCaptureSession { get }
  var sessionQueue: DispatchQueue { get }
  var cameraPosition: AVCaptureDevice.Position { get set }
  var cameraQuality: AVCaptureSession.Preset { get set }
  var videoOrientation: AVCaptureVideoOrientation { get set }
  var mediaType: AVMediaType { get }
  
  // MARK: - Required delegate
  weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate? { get set }
  
}
