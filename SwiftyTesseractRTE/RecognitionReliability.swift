//
//  RecognitionReliability.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/6/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation

public enum RecognitionReliability: Int {
  case tentative = 3
  case verifiable = 4
  case available = 5
  case stable = 6
  case solid = 7
}
