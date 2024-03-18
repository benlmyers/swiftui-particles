//
//  GlowEntity.swift
//
//
//  Created by Ben Myers on 3/17/24.
//

import SwiftUI

internal struct GlowEntity<E>: Entity where E: Entity {
  
  internal private(set) var color: Color
  internal private(set) var radius: CGFloat
  internal private(set) var opacity: Double
  
  var body: E
  
  init(
    entity: E,
    color: Color,
    radius: CGFloat,
    opacity: Double
  ) {
    self.body = entity
    self.color = color
    self.radius = radius
    self.opacity = opacity
  }
}
