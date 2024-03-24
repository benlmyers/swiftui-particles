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
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom(.colorOverlay(color: color)))
    return m
  }
}
