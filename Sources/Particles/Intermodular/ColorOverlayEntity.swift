//
//  ColorOverlayEntity.swift
//
//
//  Created by Ben Myers on 3/15/24.
//

import SwiftUI

internal struct ColorOverlayEntity<E>: Entity where E: Entity {
  
  internal private(set) var color: Color
  
  var body: E
  
  init(
    entity: E,
    color: Color
  ) {
    self.body = entity
    self.color = color
  }
}
