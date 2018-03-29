//
//  RecognitionReliability.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/6/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

/// The level of reliability required to assure OCR accuracy. The higher the reliability, the longer it will take to return results
///
/// - verifiable: Requires the last three frames return the same results
/// - stable:     Requires the last four frames return the same results
/// - solid:      Requires the last five frames return the same results
public enum RecognitionReliability: Int {
  case verifiable = 3
  case stable = 4
  case solid = 5
}
