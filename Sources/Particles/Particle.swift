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
  
  /// The particle's custom scale over time.
  var customScale: LifetimeBound<CGFloat>?
  /// The particle's custom opacity over time.
  var customOpacity: LifetimeBound<CGFloat>?
  
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
      context.rotate(by: rot)
      context.scaleBy(x: scale, y: scale)
      var resolved: GraphicsContext.ResolvedSymbol = context.resolveSymbol(id: "NOT_FOUND")!
      if let r = context.resolveSymbol(id: viewID) {
        resolved = r
      }
      context.draw(resolved, at: .zero)
    }
  }
  
  // MARK: - Overrides
  
  override func update() {
    super.update()
    if let customScale {
      self.scale = customScale(lifetimeProgress)
    }
    if let customOpacity {
      self.opacity = customOpacity(lifetimeProgress)
    }
  }
  
  required init(copying origin: Entity) {
    if let particle = origin as? Particle {
      self.viewID = particle.viewID
      self.opacity = particle.opacity
      self.scale = particle.scale
      self.customScale = particle.customScale
      self.customOpacity = particle.customOpacity
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
}

public extension Particle {
  
  func customScale(_ closure: @escaping LifetimeBound<CGFloat>) -> Self {
    self.customScale = closure
    return self
  }
  
  func customOpacity(_ closure: @escaping LifetimeBound<CGFloat>) -> Self {
    self.customOpacity = closure
    return self
  }
}
