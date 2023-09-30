//
//  Particle.swift
//
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Dispatch

public class Particle: PhysicalEntity {

  // MARK: - Properties
  
  // View Tagging
  
  /// The ID of the graphical prototype for use in the particle system's Canvas instance.
  private var viewID: UUID?
  
  private var onDraw: (GraphicsContext) -> Void = { context in }
  
  // Effects

  /// The scale of this particle.
  @Configured public internal(set) var scaleEffect: CGFloat = 1.0
  /// The opacity of this particle.
  @Configured public internal(set) var opacity: CGFloat = 1.0
  /// The blur radius of this particle.
  @Configured public internal(set) var blur: CGFloat = .zero
  /// The hue color rotation of this particle.
  @Configured public internal(set) var hueRotation: Angle = .zero

  // MARK: - Initializers

  public init(@ViewBuilder view: () -> some View) {
    super.init()
    let id = UUID()
    self.viewID = id
    let view = AnyTaggedView(view: AnyView(view()), tag: id)
    registerView(view)
    onDraw = { context in
      var resolved: GraphicsContext.ResolvedSymbol = context.resolveSymbol(id: "NOT_FOUND")!
      if let r = context.resolveSymbol(id: id) {
        resolved = r
      }
      context.draw(resolved, at: .zero)
    }
  }

  public init(color: Color, radius: CGFloat) {
    super.init()
    onDraw = { context in
      context.fill(Path(ellipseIn: .init(x: -radius, y: -radius, width: 2 * radius, height: 2 * radius)), with: GraphicsContext.Shading.color(color))
    }
  }

  // MARK: - Overrides
  
  public func start<V>(_ key: KeyPath<Particle, Configured<V>>, at val: V) -> Self {
    self[keyPath: key].setSpawnBehavior(to: { _ in return val })
    return self
  }
  
  public func start<V>(_ key: KeyPath<Particle, Configured<V>>, from closure: @escaping (PhysicalEntity) -> V) -> Self {
    self[keyPath: key].setSpawnBehavior(to: closure)
    return self
  }
  
  public func fix<V>(_ key: KeyPath<Particle, Configured<V>>, at val: V) -> Self {
    self[keyPath: key].fix(to: val)
    return self
  }
  
  public func bind<V>(_ key: KeyPath<Particle, Configured<V>>, to binding: Binding<V>) -> Self {
    self[keyPath: key].bind(to: binding)
    return self
  }
  
  public func update<V>(_ key: KeyPath<Particle, Configured<V>>, from closure: @escaping (PhysicalEntity) -> V) -> Self {
    self[keyPath: key].setUpdateBehavior(to: closure)
    return self
  }

  override func render(_ context: GraphicsContext) {
    super.render(context)
    context.drawLayer { context in
      // Move to position
      context.translateBy(x: pos.x, y: pos.y)
      // Rotate
      context.rotate(by: rotation)
      // Effects
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
      // Draw
      // TODO: Anchor
      self.onDraw(context)
    }
  }

  override func update() {
    super.update()
    $scaleEffect.update(in: self)
    $opacity.update(in: self)
    $blur.update(in: self)
    $hueRotation.update(in: self)
  }
  
  override init(copying e: PhysicalEntity, from emitter: Emitter) {
    super.init(copying: e, from: emitter)
    guard let p = e as? Particle else {
      fatalError("An entity failed to cast to a particle.")
    }
    self._scaleEffect = p.$scaleEffect.copy(in: self)
    self._opacity = p.$opacity.copy(in: self)
    self._blur = p.$blur.copy(in: self)
    self._hueRotation = p.$hueRotation.copy(in: self)
    self.onDraw = p.onDraw
    self.viewID = p.viewID
  }

  // MARK: - Methods

  func registerView(_ view: AnyTaggedView) {
    DispatchQueue.main.async {
      guard let data: ParticleSystem.Data = super.system else {
        fatalError("This entity could not access the particle system's data.")
      }
      data.views.append(view)
    }
  }
}
