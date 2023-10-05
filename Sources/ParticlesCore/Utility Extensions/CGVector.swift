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

  /// Generates a random CGVector with the specified magnitude and angle range.
  /// - Parameters:
  ///   - magnitude: The magnitude of the CGVector.
  ///   - range: The range of angles in degrees.
  /// - Returns: A CGVector with the specified magnitude and a randomly generated angle within the specified range.
  static func random(magnitude: CGFloat, degreesIn range: ClosedRange<Double>) -> CGVector {
    let angle: Angle = .degrees(.random(in: range))
    return CGVector(dx: magnitude * CGFloat(cos(angle.radians)), dy: magnitude * CGFloat(sin(angle.radians)))
  }

  /// Generates a random CGVector with the specified magnitude range and angle range.
  /// - Parameters:
  ///   - magnitudeIn: The range of possible values of the magnitude of the generated vector.
  ///   - degreesIn: The range of angles in degrees.
  /// - Returns: A CGVector with a randomly generated magnitude within the specified range and a randomly generated angle within the specified range.
  static func random(magnitudeIn: ClosedRange<CGFloat>, degreesIn: ClosedRange<Double>) -> CGVector {
    let angle: Angle = .degrees(.random(in: degreesIn))
    let magnitude: CGFloat = .random(in: magnitudeIn)
    return CGVector(dx: magnitude * CGFloat(cos(angle.radians)), dy: magnitude * CGFloat(sin(angle.radians)))
  }
}
