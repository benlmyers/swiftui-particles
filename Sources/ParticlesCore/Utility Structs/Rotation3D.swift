//
//  Rotation3D.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI

/// A structure representing a 3D rotation.
public struct Rotation3D {
  
  /// Zero rotation.
  public static let zero = Rotation3D()
  
  /// The rotation angle around the x-axis.
  public var theta: Angle = .zero
  
  /// The rotation angle around the y-axis.
  public var phi: Angle = .zero
  
  /// Whether the rotation value is zero.
  public var isZero: Bool {
    return theta == .zero && phi == .zero
  }
  
  /// The rotation represented as a `CGAffineTransform`.
  public var affineTransform: CGAffineTransform {
    // FIXME: Change this to cos(theta), cos(phi), etc.
    .init(1.5, 0, 0, 1, 0.0, 0.0)
  }
  
  /// Creates a new `Rotation3D` instance with the specified rotation angles.
  /// - Parameters:
  ///   - theta: The rotation angle around the x-axis.
  ///   - phi: The rotation angle around the y-axis.
  public init(theta: Angle, phi: Angle) {
    self.theta = theta
    self.phi = phi
  }
  
  /// Creates a new `Rotation3D` instance with zero rotation.
  public init() {}
}
