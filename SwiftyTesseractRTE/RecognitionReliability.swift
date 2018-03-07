//
//  RecognitionReliability.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/6/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation

public enum RecognitionReliability: Int {
  case tentative = 1
  case verifiable = 2
  case available = 3
  case stable = 4
  case solid = 5
}
