//
//  AdvancedParticle.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import Foundation

/// An advanced particle declaration with more features.
open class AdvancedParticle: Particle {
  
  // MARK: - Overrides
  
  override public func onBirth<T>(kind: T.Type = Proxy.self, perform action: @escaping (T, Emitter.Proxy?) -> Void) -> Self where T : Entity.Proxy {
    super.onBirth(kind: kind, perform: action)
  }
  
  override public func onUpdate<T>(kind: T.Type = Proxy.self, perform action: @escaping (T) -> Void) -> Self where T : Entity.Proxy {
    super.onUpdate(kind: kind, perform: action)
  }
  
  override public func onDeath<T>(kind: T.Type = Proxy.self, perform action: @escaping (T) -> Void) -> Self where T : Entity.Proxy {
    super.onDeath(kind: kind, perform: action)
  }
  
  override public func start<T, V>(_ path: ReferenceWritableKeyPath<T, V>, at value: V, in kind: T.Type = Proxy.self) -> Self where T: Entity.Proxy {
    super.start(path, at: value, in: kind)
  }
  
  override public func start<T, V>(_ path: ReferenceWritableKeyPath<T, V>, with value: @escaping () -> V, in kind: T.Type = Proxy.self) -> Self where T: Entity.Proxy {
    super.start(path, with: value, in: kind)
  }
  
  override public func fix<T, V>(_ path: ReferenceWritableKeyPath<T, V>, at value: V, in kind: T.Type = Proxy.self) -> Self where T : Entity.Proxy {
    super.fix(path, at: value, in: kind)
  }
  
  override public func fix<T, V>(_ path: ReferenceWritableKeyPath<T, V>, with value: @escaping () -> V, in kind: T.Type = Proxy.self) -> Self where T : Entity.Proxy {
    super.fix(path, with: value, in: kind)
  }
  
  override public func fix<T, V>(_ path: ReferenceWritableKeyPath<T, V>, updatingFrom value: @escaping (V) -> V, in kind: T.Type = Proxy.self) -> Self where T : Entity.Proxy {
    super.fix(path, updatingFrom: value, in: kind)
  }
  
  // MARK: - Subtypes
  
  /// A particle proxy.
  ///
  /// This is the data used to represent the particle in the system. It contains information like the particle's position, velocity, acceleration, rotation, and more.
  /// `Particle.Proxy` also contains properties related to its opacity, scale effect, blur, and more.
  open class Proxy: Particle.Proxy {
    
    // MARK: - Properties
    
    /// The blur of the particle. Default `0.0`.
    public var blur: CGFloat = .zero
    /// The blend mode of the particle.
    public var blendMode: GraphicsContext.BlendMode = .normal
    /// The three-dimensional rotation of the particle.
    public var rotation3D: Rotation3D = .zero
    /// The three-dimensional torque of the particle.
    public var torque3D: Rotation3D = .zero
    
    // MARK: - Overrides
    
    override func onUpdate(_ context: inout GraphicsContext) {
      super.onUpdate(&context)
      context.drawLayer { context in
        // TODO: Incorporate 3D rotation using affineTransform
//        context.transform = rotation3D.affineTransform
        context.rotate(by: rotation)
        context.opacity = opacity
        context.blendMode = blendMode
        if scaleEffect != 1.0 {
          context.scaleBy(x: scaleEffect, y: scaleEffect)
        }
        if !blur.isZero {
          context.addFilter(.blur(radius: blur))
        }
        if !hueRotation.degrees.isZero {
          context.addFilter(.hueRotation(hueRotation))
        }
        context.translateBy(x: position.x, y: position.y)
        self.onDraw(&context)
      }
    }
  }
}
