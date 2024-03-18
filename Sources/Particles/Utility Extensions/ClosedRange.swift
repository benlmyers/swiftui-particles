//
//  ClosedRange.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import Foundation
import CoreGraphics

infix operator +/- : RangeFormationPrecedence

public extension Double {
  
  static func random(in range: ClosedRange<Double>, seed: Int) -> Double {
    srand48(seed)
    return range.lowerBound + (range.upperBound - range.lowerBound) * drand48()
  }
  
  static func +/- (lhs: Double, rhs: Double) -> ClosedRange<Double> {
    return lhs - rhs ... lhs + rhs
  }
}

public extension Int {
  
  static func random(in range: ClosedRange<Int>, seed: Int) -> Int {
    srand48(seed)
    return Int(Double(range.lowerBound) + Double(range.upperBound - range.lowerBound) * drand48())
  }
  
  static func +/- (lhs: Int, rhs: Int) -> ClosedRange<Int> {
    return lhs - rhs ... lhs + rhs
  }
}

public extension CGFloat {
  
  static func random(in range: ClosedRange<CGFloat>, seed: Int) -> CGFloat {
    srand48(seed)
    return CGFloat(CGFloat(range.lowerBound) + CGFloat(range.upperBound - range.lowerBound) * drand48())
  }
  
  static func +/- (lhs: CGFloat, rhs: CGFloat) -> ClosedRange<CGFloat> {
    return lhs - rhs ... lhs + rhs
  }
}
