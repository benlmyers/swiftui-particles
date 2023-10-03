//
//  CGVector.swift
//
//
//  Created by Ben Myers on 10/2/23.
//

import SwiftUI

public extension CGVector {
  
  /// Generates a vector with a fixed magnitude in a random direction.
  /// - Parameter magnitude: The magnitude of the vector to generate.
  /// - Returns: The random vector.
  static func random(magnitude: CGFloat) -> CGVector {
    let angle: Angle = .degrees(.random(in: 0.0 ... 360.0))
    return CGVector(dx: magnitude * CGFloat(cos(angle.radians)), dy: magnitude * CGFloat(sin(angle.radians)))
  }
  
  /// Generates a vector with a random direction and magnitude in a fixed range.
  /// - Parameter range: The range of possible values of the magnitude of the generated vector.
  /// - Returns: The random vector.
  static func random(magnitudeIn range: ClosedRange<CGFloat>) -> CGVector {
    let angle: Angle = .degrees(.random(in: 0.0 ... 360.0))
    let magnitude: CGFloat = .random(in: range)
    return CGVector(dx: magnitude * CGFloat(cos(angle.radians)), dy: magnitude * CGFloat(sin(angle.radians)))
  }
}
