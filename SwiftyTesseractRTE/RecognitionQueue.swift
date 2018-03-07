//
//  RecognitionArray.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/3/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation

public struct RecognitionQueue<T: Hashable> {
  private var values: [T]
  
  public let size: Int
  public var count: Int {
    return values.count
  }
  public var allValuesMatch: Bool {
    return Set(values).count == 1
  }
  
  init(maxElements: Int) {
    size = maxElements
    values = [T]()
  }
  
  init(maxElements: Int, values: T...) {
    size = maxElements
    if values.count > size {
      let numberOfValuesToIgnore = values.count - size
      self.values = .init(values[numberOfValuesToIgnore...values.count - 1])
    } else {
      self.values = values
    }
  }
  
  public mutating func enqueue(_ value: T) {
    values.append(value)
    if values.count > size {
      values.remove(at: 0)
    }
  }
  
  @discardableResult
  public mutating func dequeue() -> T? {
    guard !values.isEmpty else { return nil }
    return values.remove(at: 0)
  }
}
