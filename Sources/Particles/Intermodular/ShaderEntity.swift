//
//  ShaderEntity.swift
//
//
//  Created by Ben Myers on 3/20/24.
//

import SwiftUI

@available(macOS 14.0, *)
internal struct ShaderEntity<E>: Entity where E: Entity {
  
  internal private(set) var shader: (PhysicsProxy.Context) -> Shader
  
  var body: E
  
  init(
    entity: E,
    shader: @escaping (PhysicsProxy.Context) -> Shader
  ) {
    self.body = entity
    self.shader = shader
  }
}

