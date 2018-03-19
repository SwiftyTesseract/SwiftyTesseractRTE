//
//  AVCaptureSession+Extension.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/18/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureSession {
  convenience init(quality: AVCaptureSession.Preset) {
    self.init()
    self.sessionPreset = quality
  }
}
