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
  
  /// Gets a random value.
  /// - Parameter range: The range of possible values.
  /// - Parameter seed: An integer seed use to generate a number chosen from the specified range.
  static func random(in range: ClosedRange<Double>, seed: Int) -> Double {
    srand48(seed)
    return range.lowerBound + (range.upperBound - range.lowerBound) * drand48()
  }
  
  /// Gets a random value.
  /// - Parameter range: The range of possible values.
  /// - Parameter seed: A double seed use to generate a number chosen from the specified range. Deterministic modulo `1.0`.
  static func random(in range: ClosedRange<Double>, seed: Double) -> Double {
    let seed: Double = seed.truncatingRemainder(dividingBy: 1.0)
    return random(in: range, seed: Int(seed * Double(Int.max)))
  }
  
  static func +/- (lhs: Double, rhs: Double) -> ClosedRange<Double> {
    return lhs - rhs ... lhs + rhs
  }
}

public extension Int {
  
  /// Gets a random value.
  /// - Parameter range: The range of possible values.
  /// - Parameter seed: An integer seed use to generate a number chosen from the specified range.
  static func random(in range: ClosedRange<Int>, seed: Int) -> Int {
    srand48(seed)
    return Int(Double(range.lowerBound) + Double(range.upperBound - range.lowerBound) * drand48())
  }
  
  /// Gets a random value.
  /// - Parameter range: The range of possible values.
  /// - Parameter seed: A double seed use to generate a number chosen from the specified range. Deterministic modulo `1.0`.
  static func random(in range: ClosedRange<Int>, seed: Double) -> Int {
    random(in: range, seed: Int(seed * Double(Int.max)))
  }
  
  static func +/- (lhs: Int, rhs: Int) -> ClosedRange<Int> {
    return lhs - rhs ... lhs + rhs
  }
}

public extension CGFloat {
  
  /// Gets a random value.
  /// - Parameter range: The range of possible values.
  /// - Parameter seed: An integer seed use to generate a number chosen from the specified range.
  static func random(in range: ClosedRange<CGFloat>, seed: Int) -> CGFloat {
    srand48(seed)
    return CGFloat(CGFloat(range.lowerBound) + CGFloat(range.upperBound - range.lowerBound) * drand48())
  }
  
  /// Gets a random value.
  /// - Parameter range: The range of possible values.
  /// - Parameter seed: A double seed use to generate a number chosen from the specified range. Deterministic modulo `1.0`.
  static func random(in range: ClosedRange<CGFloat>, seed: Double) -> CGFloat {
    random(in: range, seed: Int(seed * Double(Int.max)))
  }
  
  static func +/- (lhs: CGFloat, rhs: CGFloat) -> ClosedRange<CGFloat> {
    return lhs - rhs ... lhs + rhs
  }
}
