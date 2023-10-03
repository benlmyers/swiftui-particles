//
//  Entity+Modifiers.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import Foundation
import ParticlesCore

public extension Entity {
  
  /// Sets the starting position of the entity.
  /// - Parameters:
  ///   - x: The x-coordinate of the starting position.
  ///   - y: The y-coordinate of the starting position.
  /// - Returns: The modified entity.
  final func startPosition(x: CGFloat, y: CGFloat) -> Self {
    self.start(\.position, at: CGPoint(x: x, y: y))
  }
  
  /// Sets the starting position of the entity.
  /// - Parameter point: The unit point representing the starting position.
  /// - Returns: The modified entity.
  final func startPosition(_ point: UnitPoint) -> Self {
    self.onBirth { proxy, _ in
      let size = proxy.systemData!.systemSize
      proxy.position = CGPoint(x: point.x * size.width, y: point.y * size.height)
    }
  }
  
  /// Sets the starting velocity of the entity.
  /// - Parameters:
  ///   - x: The x-component of the starting velocity.
  ///   - y: The y-component of the starting velocity.
  /// - Returns: The modified entity.
  final func startVelocity(x: CGFloat, y: CGFloat) -> Self {
    self.start(\.velocity, at: CGVector(dx: x, dy: y))
  }
  
  /// Sets the acceleration of the entity.
  /// - Parameters:
  ///   - x: The x-component of the acceleration.
  ///   - y: The y-component of the acceleration.
  /// - Returns: The modified entity.
  final func acceleration(x: CGFloat, y: CGFloat) -> Self {
    self.fix(\.acceleration, at: CGVector(dx: x, dy: y))
  }
  
  /// Applies gravity to the object.
  /// - Parameter factor: The factor by which gravity is applied. Default value is 1.0.
  /// - Returns: The modified object.
  final func useGravity(_ factor: Double = 1.0) -> Self {
    self.acceleration(x: 0.0, y: factor * 0.98)
  }

  /// Sets the lifetime of the object.
  /// - Parameter value: The desired lifetime of the object.
  /// - Returns: The modified object.
  final func lifetime(_ value: TimeInterval) -> Self {
    self.fix(\.lifetime, at: value)
  }

  /// Sets the rotation of the object.
  /// - Parameter degrees: The rotation angle in degrees.
  /// - Returns: The modified object.
  final func rotation(degrees: Double) -> Self {
    self.fix(\.rotation, at: Angle(degrees: degrees))
  }

  /// Sets the rotation speed of the object.
  /// - Parameter speed: The rotation speed in degrees per second.
  /// - Returns: The modified object.
  final func rotationSpeed(speed: Double) -> Self {
    self.fix(\.torque, at: Angle(degrees: speed))
  }
}
