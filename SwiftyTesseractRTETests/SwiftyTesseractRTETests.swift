//
//  SwiftyTesseractRTETests.swift
//  SwiftyTesseractRTETests
//
//  Created by Steven Sherry on 3/3/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import XCTest
@testable import SwiftyTesseractRTE


class SwiftyTesseractRTETests: XCTestCase {
    
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
    
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
    
  func testQueueMaintainsSize() {
    var queue = RecognitionQueue(maxElements: 5, values: 1,2,3,4,5)
    queue.enqueue(6)
    XCTAssert(queue.size == 5)
    XCTAssertEqual(queue.size, queue.count)
  }
  
  func testQueueInit_valueCountGreaterThanSize() {
    let queue = RecognitionQueue(maxElements: 3, values: 1, 2, 3, 4)
    XCTAssertEqual(queue.size, queue.count)
  }
  
  func testQueueInit_withRecognitionReliability() {
    let verifiableQueue = RecognitionQueue<Int>(desiredReliability: .verifiable)
    let repeatableQueue = RecognitionQueue<Int>(desiredReliability: .repeatable)
    let stableQueue = RecognitionQueue<Int>(desiredReliability: .stable)
    
    XCTAssert(verifiableQueue.size == 3)
    XCTAssert(repeatableQueue.size == 4)
    XCTAssert(stableQueue.size == 5)
  }
  
  func testQueueAllValuesMatch() {
    let queue = RecognitionQueue(maxElements: 5, values: 1,1,1,1,1)
    XCTAssert(queue.allValuesMatch)
  }
  
  func testQueueDequeueValue() {
    var queue = RecognitionQueue(maxElements: 5, values: 1,2,3,4,5)
    guard let value = queue.dequeue() else { fatalError("Found nil when dequeuing queue with values") }
    XCTAssertEqual(value, 1)
  }
  
  func testQueueDequeueNil() {
    var queue = RecognitionQueue(maxElements: 1, values: 1)
    queue.dequeue()
    XCTAssertNil(queue.dequeue())
  }

}
