//
//  Entity+Glow.swift
//
//
//  Created by Ben Myers on 3/17/24.
//

import SwiftUI
import Foundation

public extension Entity {
  
  /// Applies a color overlay to this entity.
  /// - Parameter color: The color to overlay on to the entity.
  func glow(_ color: Color, radius: CGFloat = 15.0, opacity: Double = 0.5) -> some Entity {
    return GlowEntity(entity: self, color: color, radius: radius, opacity: opacity)
  }
}
