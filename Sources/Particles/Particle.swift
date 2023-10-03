//
//  Particle.swift
//
//
//  Created by Ben Myers on 10/2/23.
//

import SwiftUI
import Foundation

/// A particle declaration.
/// 
/// Particles can be created through various methods; you may use `GraphicsContext` to manually draw the particle's appearance or pass in `some View` to display:
/// 
/// ```swift
/// ParticleSystem {
///   // Create a red circle particle
///   Particle(color: .red, radius: 5.0)
///   // Create a particle of text
///   Particle {
///     Text("Hello")
///   }
/// }
/// ```
open class Particle: Entity {
  
  // MARK: - Properties
  
  private var taggedView: AnyTaggedView?
  private var onDraw: (inout GraphicsContext) -> Void
  
  // MARK: - Initalizers
  
  /// Creates a simple circle particle.
  /// - Parameters:
  ///   - color: The color of the particle.
  ///   - radius: The radius of the particle's circular shape.
  public init(color: Color, radius: CGFloat = 4.0) {
    self.onDraw = { context in
      context.fill(Path(ellipseIn: .init(origin: .zero, size: .init(width: radius * 2.0, height: radius * 2.0))), with: .color(color))
    }
  }
  
  /// Creates a particle with a custom drawing closure.
  /// - Parameter onDraw: An action to perform when the particle is to be rendered. The `GraphicsContext` is translated to the particle's position.
  public init(onDraw: @escaping (inout GraphicsContext) -> Void) {
    self.onDraw = onDraw
  }
  
  /// Creates a particle rendered from a view.
  /// - Parameter view: The view to render as this particle's appearance.
  public init(@ViewBuilder view: () -> some View) {
    let taggedView = AnyTaggedView(view: AnyView(view()), tag: UUID())
    self.taggedView = taggedView
    self.onDraw = { context in
      guard let resolved = context.resolveSymbol(id: taggedView.tag) else {
        // TODO: WARN
        return
      }
      context.draw(resolved, at: .zero)
    }
  }
  
  // MARK: - Overrides
  
  override public func start<T, V>(_ path: ReferenceWritableKeyPath<T, V>, at value: V, in kind: T.Type = Proxy.self) -> Self where T: Entity.Proxy {
    super.start(path, at: value, in: kind)
  }
  
  override public func start<T, V>(_ path: ReferenceWritableKeyPath<T, V>, with value: @escaping () -> V, in kind: T.Type = Proxy.self) -> Self where T: Entity.Proxy {
    super.start(path, with: value, in: kind)
  }
  
  override final func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Entity.Proxy {
    if let taggedView {
      data.views.insert(taggedView)
    }
    return Proxy(onDraw: onDraw, systemData: data, entityData: self)
  }
  
  // MARK: - Subtypes
  
  /// A particle proxy.
  ///
  /// This is the data used to represent the particle in the system. It contains information like the particle's position, velocity, acceleration, rotation, and more.
  /// `Particle.Proxy` also contains properties related to its opacity, scale effect, blur, and more.
  public class Proxy: Entity.Proxy {
    
    // MARK: - Properties
    
    /// The opacity of the particle, from `0.0` to `1.0`. Default `1.0`.
    public var opacity: Double = 1.0
    /// The scale effect of the particle. Default `1.0`.
    public var scaleEffect: CGFloat = 1.0
    /// The blur of the particle. Default `0.0`.
    public var blur: CGFloat = .zero
    /// The hue rotation of the particle. Default `0.0`.
    public var hueRotation: Angle = .zero
    
    private var onDraw: (inout GraphicsContext) -> Void
    
    // MARK: - Initalizers
    
    init(onDraw: @escaping (inout GraphicsContext) -> Void, systemData: ParticleSystem.Data, entityData: Entity) {
      self.onDraw = onDraw
      super.init(systemData: systemData, entityData: entityData)
    }
    
    // MARK: - Overrides
    
    override func onUpdate(_ context: inout GraphicsContext) {
      super.onUpdate(&context)
      context.drawLayer { context in
        context.translateBy(x: position.x, y: position.y)
        context.rotate(by: rotation)
        context.opacity = opacity
        if scaleEffect != 1.0 {
          context.scaleBy(x: scaleEffect, y: scaleEffect)
        }
        if !blur.isZero {
          context.addFilter(.blur(radius: blur))
        }
        if !hueRotation.degrees.isZero {
          context.addFilter(.hueRotation(hueRotation))
        }
        self.onDraw(&context)
      }
    }
  }
}
