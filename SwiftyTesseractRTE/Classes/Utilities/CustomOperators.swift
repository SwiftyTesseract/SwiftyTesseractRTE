//
//  CustomOperators.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/18/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation

infix operator >>>: MultiplicationPrecedence
/// Operator for function composition
///
/// - Parameters:
///   - f: Function on the left hand side that transforms from A to B
///   - g: Function on the right hand side that transforms from B to C
/// - Returns: A function that transforms from A to C
func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
  return { a in
    g(f(a))
  }
}

/// An overload of >>> that allows for function composition of methods that take non-optionals
/// as input and return optionals
///
/// - Parameters:
///   - f: Function on the left hand side that transforms from A to B?
///   - g: Function on the right hand side that transforms from B to C?
/// - Returns: A function that transforms from A to C?
func >>> <A, B, C>(_ f: @escaping (A) -> B?, _ g: @escaping (B) -> C?) -> (A) -> C? {
  return { a in
    guard let b = f(a) else { return nil }
    return g(b)
  }
}

infix operator <=<: MultiplicationPrecedence

/// Operator for passing a parameter to a function that performs side-effects.
/// Passes the parameter into the function from the right-hand side for readability at
/// the call site
///
/// - Parameters:
///   - fn: A function that takes A and returns Void
///   - x: The parameter being used for performing side effects.
func <=< <A>(_ fn: @escaping (A) -> (), _ x: A) {
  fn(x)
}


