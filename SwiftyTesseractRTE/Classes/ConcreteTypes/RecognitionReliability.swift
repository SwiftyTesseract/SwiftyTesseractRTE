//
//  RecognitionReliability.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/6/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

/// The level of reliability required to assure OCR accuracy. The higher the reliability, the longer it will take to return results
public enum RecognitionReliability: Int {
  /// Immediately returns the first result
  case raw = 1
  /// Requires the last two frames return the same results
  case tentative = 2
  /// Requires the last three frames return the same results
  case verifiable = 3
  /// Requires the last four frames return the same results
  case stable = 4
  /// Requires the last five frames return the same results
  case solid = 5
}
