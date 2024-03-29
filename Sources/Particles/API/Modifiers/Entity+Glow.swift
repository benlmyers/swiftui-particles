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
  func glow(_ color: Color, radius: CGFloat = 15.0) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom(.glow(color: color, option: nil, radius: radius)))
    return m
  }
  
  /// Applies a color overlay to this entity.
  /// - Parameter color: The color to overlay on to the entity.
  func glow(_ option: GlowOption, radius: CGFloat = 15.0) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom(.glow(color: nil, option: option, radius: radius)))
    return m
  }
}

public enum GlowOption {
  case identity
}
