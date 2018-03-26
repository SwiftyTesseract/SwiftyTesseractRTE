//
//  RecognitionReliability.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/6/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

/// The level of reliability required to assure OCR accuracy
///
/// - verifiable: A result is considered verifiable if the last three frames return the same results
/// - stable: A result is considered stable if the last four frames return the same results
/// - solid: A result is considered solid if the last five frames return the same results
public enum RecognitionReliability: Int {
  case verifiable = 3
  case stable = 4
  case solid = 5
}
