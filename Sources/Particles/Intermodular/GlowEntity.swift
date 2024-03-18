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
  
  var body: E
  
  init(
    entity: E,
    color: Color,
    radius: CGFloat
  ) {
    self.body = entity
    self.color = color
    self.radius = radius
  }
}
