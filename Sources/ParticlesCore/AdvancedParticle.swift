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
  
  override open func _makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Entity.Proxy {
    return Proxy(from: super._makeProxy(source: source, data: data) as! Particle.Proxy, entityData: self)
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
    /// The three-dimensional rotational axis of the particle. Used with ``Entity/Proxy/rotation``.
    public var axis3D: (Double, Double, Double) = (.zero, .zero, 1.0)
    /// The three-dimensional rotation of the particle along its ``axis3D``.
    public var rotation3D: Angle = .zero
    /// The three-dimensional torque of the particle along its ``axis3D``.
    public var torque3D: Angle = .zero
    /// Graphical filters to apply to this view.
    public var filters: [GraphicsContext.Filter] = []
    /// A configuration for how to draw the particle's trail.
    public var trail: (GraphicsContext.Shading, StrokeStyle)?
//    /// The color overlay of the particle. If `.clear`, the color overlay will not be applied.
//    public var colorOverlay: Color = .clear
    
    // MARK: - Initalizers
    
    public init(from particle: Particle.Proxy, entityData: AdvancedParticle) {
      super.init(onDraw: particle.onDraw, systemData: particle.systemData!, entityData: entityData)
    }
    
    // MARK: - Overrides
    
    override func onUpdate(_ context: inout GraphicsContext) {
      super.onUpdate(&context)
      context.drawLayer { context in
        if let trail {
          var path = Path()
          path.move(to: position)
          path.addLine(to: CGPoint(x: position.x - 10 * velocity.dx, y: position.y - 10 * velocity.dy))
          context.stroke(path, with: trail.0, style: trail.1)
        }
        context.opacity = opacity
        context.blendMode = blendMode
        if !hueRotation.degrees.isZero {
          context.addFilter(.hueRotation(hueRotation))
        }
        if !blur.isZero {
          context.addFilter(.blur(radius: blur))
        }
        context.translateBy(x: position.x, y: position.y)
        context.addFilter(.projectionTransform(getRotationProjection()))
//        context.addFilter(.layerShader(., maxSampleOffset: <#T##CGSize#>)
        context.rotate(by: rotation)
        for filter in filters {
          context.addFilter(filter)
        }
        if scaleEffect != 1.0 {
          context.scaleBy(x: scaleEffect, y: scaleEffect)
        }
        self.onDraw(&context)
      }
    }
    
    // MARK: - Methods
    
    private func getRotationProjection() -> ProjectionTransform {
      var t = CATransform3DIdentity
      t = CATransform3DRotate(t, rotation3D.radians, axis3D.0, axis3D.1, axis3D.2)
      return ProjectionTransform(t)
    }
  }
}
