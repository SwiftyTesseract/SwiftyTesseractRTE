//
//  RecognitionReliability.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/6/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

/// The level of reliability required to assure OCR accuracy. The higher the reliability, the longer it will take to return results
public enum RecognitionReliability {
  /// Immediately returns the first result
  case raw
  /// Requires the last two frames return the same results
  case tentative
  /// Requires the last three frames return the same results
  case verifiable
  /// Requires the last four frames return the same results
  case stable
  /// Requires the last five frames return the same results
  case solid
  
  var numberOfResults: Int {
    switch self {
    case .raw: return 1
    case .tentative: return 2
    case .verifiable: return 3
    case .stable: return 4
    case .solid: return 5
    }
  }
}
