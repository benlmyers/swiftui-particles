//
//  Entity+Shader.swift
//
//
//  Created by Ben Myers on 3/20/24.
//

import SwiftUI

@available(macOS 14.0, iOS 17.0, *)
public extension Entity {
  
  /// Applies a shader to this entity.
  /// - Parameter shader: The shader to apply to this entity.
  func shader(_ shader: Shader) -> some Entity {
    return ShaderEntity(entity: self) { _ in
      return shader
    }
  }
  
  /// Applies a shader to this entity.
  /// - Parameter withShader: The shader to apply to this entity using the contextual callback.
  func shader(with withShader: @escaping (Proxy.Context) -> Shader) -> some Entity {
    return ShaderEntity(entity: self, shader: withShader)
  }
}
