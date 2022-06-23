//
//  Angle.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

public extension Angle {
  
  // MARK: - Public Static Properties
  
  /// Rightwards.
  static let right: Self = .zero
  /// Up and to the right.
  static let upRight: Self = .degrees(45.0)
  /// Upwards.
  static let up: Self = .degrees(90.0)
  /// Up and to the left.
  static let upLeft: Self = .degrees(135.0)
  /// Leftwards.
  static let left: Self = .degrees(180.0)
  /// Down and to the left.
  static let downLeft: Self = .degrees(225.0)
  /// Downwards.
  static let down: Self = .degrees(270.0)
  /// Down and to the right.
  static let downRight: Self = .degrees(315.0)
  /// A full cucle.
  static let tau: Self = .degrees(360.0)
}

extension Angle {
  
  static var random: Self {
    Self.degrees(Double.random(in: 0 ... 360.0))
  }
}
