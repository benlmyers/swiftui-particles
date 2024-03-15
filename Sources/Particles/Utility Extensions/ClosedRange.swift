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
  static func +/- (lhs: Double, rhs: Double) -> ClosedRange<Double> {
    return lhs - rhs ... lhs + rhs
  }
}

public extension Int {
  static func +/- (lhs: Int, rhs: Int) -> ClosedRange<Int> {
    return lhs - rhs ... lhs + rhs
  }
}

public extension CGFloat {
  static func +/- (lhs: CGFloat, rhs: CGFloat) -> ClosedRange<CGFloat> {
    return lhs - rhs ... lhs + rhs
  }
}
