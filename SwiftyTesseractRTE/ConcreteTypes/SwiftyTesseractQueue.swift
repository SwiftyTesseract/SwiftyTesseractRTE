//
//  RecognitionArray.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/3/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

struct RecognitionQueue<T: Hashable> {
  private var values: [T]
  
  let size: Int

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
  
  var count: Int {
    return values.count
  }
  
  var allValuesMatch: Bool {
    return Set(values).count == 1
  }
  
  mutating func enqueue(_ value: T) {
    values.append(value)
    if values.count > size {
      values.remove(at: 0)
    }
  }
  
  mutating func clear() {
    values.removeAll()
  }
  
  @discardableResult
  mutating func dequeue() -> T? {
    guard !values.isEmpty else { return nil }
    return values.remove(at: 0)
  }
  
}

extension RecognitionQueue {
  init(desiredReliability: RecognitionReliability) {
    self.init(maxElements: desiredReliability.rawValue)
  }
}
