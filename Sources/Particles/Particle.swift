//
//  Particle.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Dispatch

public class Particle: Entity {
  
  // MARK: - Properties
  
  /// The ID of the graphical prototype for use in the particle system's Canvas instance.
  var viewID: UUID
  
  /// The scale of this particle.
  public internal(set) var scale: CGFloat = 1.0
  /// The opacity of this particle.
  public internal(set) var opacity: CGFloat = 1.0
  /// The 3D rotation of this particle (a basic flip effect).
  public internal(set) var flip: Angle = .zero
  /// The torque of the 3D flip effect.
  public internal(set) var flipTor: Angle = .zero
  /// The blur radius of this particle.
  public internal(set) var blur: CGFloat = .zero
  /// The hue color rotation of this particle.
  public internal(set) var hueRotation: Angle = .zero
  
  /// The particle's custom scale over time.
  var customScale: LifetimeBound<CGFloat>?
  /// The particle's custom opacity over time.
  var customOpacity: LifetimeBound<CGFloat>?
  /// The particle's custom 3D flip over time.
  var customFlip: LifetimeBound<Angle>?
  /// The particle's custom blur radius over time.
  var customBlur: LifetimeBound<CGFloat>?
  /// The particle's custom hue rotation over time.
  var customHueRotation: LifetimeBound<Angle>?
  
  // MARK: - Initializers
  
  public init(@ViewBuilder view: () -> some View) {
    self.viewID = UUID()
    super.init(.zero, .zero, .zero)
    let view = AnyTaggedView(view: AnyView(view()), tag: viewID)
    registerView(view)
  }
  
  public init(color: Color, radius: CGFloat) {
    self.viewID = UUID()
    super.init(.zero, .zero, .zero)
    let view = AnyTaggedView(
      view: AnyView(Circle().foregroundColor(color).frame(width: radius, height: radius)),
      tag: viewID
    )
    registerView(view)
  }
  
  // MARK: - Conformance
  
  override func render(_ context: GraphicsContext) {
    super.render(context)
    context.drawLayer { context in
      context.translateBy(x: pos.x, y: pos.y)
      context.scaleBy(x: cos(flip.radians), y: 1.0)
      context.rotate(by: rot)
      context.scaleBy(x: scale, y: scale)
      var resolved: GraphicsContext.ResolvedSymbol = context.resolveSymbol(id: "NOT_FOUND")!
      if let r = context.resolveSymbol(id: viewID) {
        resolved = r
      }
      if !blur.isZero {
        context.addFilter(.blur(radius: blur))
      }
      if !hueRotation.degrees.isZero {
        context.addFilter(.hueRotation(hueRotation))
      }
      context.draw(resolved, at: .zero)
    }
  }
  
  // MARK: - Overrides
  
  override func update() {
    super.update()
    self.updatePhysics()
    if let customScale {
      self.scale = customScale.closure(lifetimeProgress)
    }
    if let customOpacity {
      self.opacity = customOpacity.closure(lifetimeProgress)
    }
    if let customBlur {
      self.blur = customBlur.closure(lifetimeProgress)
    }
    if let customFlip {
      self.flip = customFlip.closure(lifetimeProgress)
    }
    if let customHueRotation {
      self.hueRotation = customHueRotation.closure(lifetimeProgress)
    }
  }
  
  required init(copying origin: Entity) {
    if let particle = origin as? Particle {
      self.viewID = particle.viewID
      self.scale = particle.scale
      self.opacity = particle.opacity
      self.flip = particle.flip
      self.flipTor = particle.flipTor
      self.blur = particle.blur
      self.hueRotation = particle.hueRotation
      self.customScale = particle.customScale
      self.customOpacity = particle.customOpacity
      self.customFlip = particle.customFlip
      self.customBlur = particle.customBlur
      self.customHueRotation = particle.customHueRotation
    } else {
      fatalError("Attempted to copy an entity as a Particle, but found another origin type (\(type(of: origin))) instead.")
    }
    super.init(copying: origin)
  }
  
  // MARK: - Methods
  
  func registerView(_ view: AnyTaggedView) {
    DispatchQueue.main.async {
      guard let data = self.data else {
        return
        //fatalError("This entity could not access the particle system's data.")
      }
      data.views.append(view)
    }
  }
  
  private func updatePhysics() {
    for field in data?.fields ?? [] {
      guard !ignoreFields else { break }
      guard field.bounds.contains(self.pos) else { continue }
      inherit(effect: field.effect)
    }
    flip = flip + flipTor
  }
}

public extension Particle {
  
  func initialFlip(_ angle: Angle) -> Self {
    self.flip = angle
    return self
  }
  
  func initialFlipTorque(_ torque: Angle) -> Self {
    self.flipTor = torque
    return self
  }
}

public extension Particle {
  
  func customScale(_ bound: LifetimeBound<CGFloat>) -> Self {
    self.customScale = bound
    return self
  }
  
  func customOpacity(_ bound: LifetimeBound<CGFloat>) -> Self {
    self.customOpacity = bound
    return self
  }
  
  func customFlip(_ bound: LifetimeBound<Angle>) -> Self {
    self.customFlip = bound
    return self
  }
  
  func customBlur(_ bound: LifetimeBound<CGFloat>) -> Self {
    self.customBlur = bound
    return self
  }
  
  func customHueRotation(_ bound: LifetimeBound<Angle>) -> Self {
    self.customHueRotation = bound
    return self
  }
}

public extension Particle {
  
  func customScale(_ closure: @escaping (Double) -> CGFloat) -> Self {
    customScale(.init(closure: closure))
  }
  
  func customOpacity(_ closure: @escaping (Double) -> CGFloat) -> Self {
    customOpacity(.init(closure: closure))
  }
  
  func customFlip(_ closure: @escaping (Double) -> Angle) -> Self {
    customFlip(.init(closure: closure))
  }
  
  func customBlur(_ closure: @escaping (Double) -> CGFloat) -> Self {
    customBlur(.init(closure: closure))
  }
  
  func customHueRotation(_ closure: @escaping (Double) -> Angle) -> Self {
    customHueRotation(.init(closure: closure))
  }
}
