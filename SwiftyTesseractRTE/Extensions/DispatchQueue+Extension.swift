//
//  DispatchQueue+Extension.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/18/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation

extension DispatchQueue {
  convenience init(queueLabel: DispatchQueue.Label) {
    self.init(label: queueLabel.rawValue)
  }
  
  enum Label: String {
    case session, videoOutput
  }
}
