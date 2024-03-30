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
  /// - Parameter
  /// - Parameter color: The color to overlay on to the entity. Pass `nil` to use the color of the particle itself.
  func glow(_ color: Color? = nil, radius: CGFloat = 15.0) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom(.glow(color: color, radius: radius)))
    return m
  }
}
