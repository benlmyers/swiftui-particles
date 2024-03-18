//
//  Entity+ColorOverlay.swift
//
//
//  Created by Ben Myers on 3/16/24.
//

import SwiftUI
import Foundation

public extension Entity {
  
  /// Applies a color overlay to this entity.
  /// - Parameter color: The color to overlay on to the entity.
  func colorOverlay(_ color: Color) -> some Entity {
    return ColorOverlayEntity(entity: self, color: color)
  }
}
