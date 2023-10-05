//
//  Emitter+Modifiers.swift
//
//
//  Created by Ben Myers on 10/5/23.
//

import SwiftUI
import Foundation
import ParticlesCore

public extension Emitter {
  
  /// Sets the fire rate of the emitter.
  /// - Parameters:
  ///   - x: The fire rate value.
  ///   - y: The fire rate unit.
  /// - Returns: The modified emitter instance.
  final func fireRate(_ rate: Double) -> Self {
    self.start(\.fireRate, at: rate)
  }
  
  /// Sets the fire interval of the emitter.
  /// - Parameter interval: The fire interval value.
  /// - Returns: The modified emitter instance.
  final func fireInteral(_ interval: TimeInterval) -> Self {
    self.fireRate(1.0 / interval)
  }
}

