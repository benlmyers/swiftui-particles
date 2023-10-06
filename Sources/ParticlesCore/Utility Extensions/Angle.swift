//
//  Angle.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI

public extension Angle {
  
  /// Upwards.
  static let up: Angle = Angle(degrees: 270.0)
  /// Downwards.
  static let down: Angle = Angle(degrees: 90.0)
  /// Leftwards.
  static let left: Angle = Angle(degrees: 180.0)
  /// Rightwards.
  static let right: Angle = Angle.zero
  
  var isZero: Bool {
    return degrees == 0.0
  }
  
  /// Returns a random angle.
  /// - Returns: A randomly generated angle.
  static func random() -> Angle {
    return Angle(degrees: .random(in: 0.0 ... 360.0))
  }
  
  /// Returns a random angle within the specified range of degrees.
  /// - Parameter range: The range of degrees within which the angle should be generated.
  /// - Returns: A randomly generated angle within the specified range.
  static func random(degreesIn range: ClosedRange<Double>) -> Angle {
    return Angle(degrees: .random(in: range))
  }
}

/// Calculates the cosine of an angle.
///
/// - Parameter angle: The angle in radians.
/// - Returns: The cosine of the angle.
public func cos(_ angle: Angle) -> Double {
  return cos(angle.radians)
}

/// Calculates the sine of an angle.
///
/// - Parameter angle: The angle in radians.
/// - Returns: The sine of the angle.
public func sin(_ angle: Angle) -> Double {
  return sin(angle.radians)
}

