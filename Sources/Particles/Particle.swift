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

  // MARK: - Methods

  func registerView(_ view: AnyTaggedView) {
    DispatchQueue.main.async {
      guard let data: ParticleSystem.Data = super.system else {
        fatalError("This entity could not access the particle system's data.")
//        return
      }
      data.views.append(view)
    }
  }
}
