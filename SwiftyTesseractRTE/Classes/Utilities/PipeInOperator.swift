//
//  PipeInOperator.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/18/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation

infix operator |>: AdditionPrecedence
func |><T, U>(lhs: T, rhs: (T) -> (U)) -> U {
  return rhs(lhs)
}
