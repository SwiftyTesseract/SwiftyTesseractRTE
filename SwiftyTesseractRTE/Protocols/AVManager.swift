//
//  AVManager.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation
import AVFoundation

protocol AVManager: class {
  var previewLayer: AVCaptureVideoPreviewLayer { get }
  var captureSession: AVCaptureSession { get }
  var sessionQueue: DispatchQueue { get }
  weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate? { get set }
  var cameraPosition: AVCaptureDevice.Position { get }
  var cameraQuality: AVCaptureSession.Preset { get set }
  var mediaType: AVMediaType { get }
  
  @discardableResult
  func isAuthorized(for mediaType: AVMediaType) -> Bool
  
  func requestPermission(for mediaType: AVMediaType)
  func configure(captureSession: AVCaptureSession, withQuality quality: AVCaptureSession.Preset, forMediaType mediaType: AVMediaType, andCameraPosition cameraPosition: AVCaptureDevice.Position)
  
}
