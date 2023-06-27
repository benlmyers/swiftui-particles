//
//  Particle.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

public class Particle: Entity {
  
  // MARK: - Properties
  
  /// The ID of the graphical prototype for use in the particle system's Canvas instance.
  var viewID: UUID
  
  // MARK: - Initializers
  
  public init(@ViewBuilder view: () -> some View) {
    self.viewID = UUID()
    super.init(.zero, .zero, .zero)
    let view = AnyTaggedView(view: AnyView(view()), tag: viewID)
    DispatchQueue.main.async {
      guard let data = self.data else {
        return
        //fatalError("This entity could not access the particle system's data.")
      }
      data.views.append(view)
    }
  }
  
  // MARK: - Conformance
  
  required init(copying origin: Entity) {
    if let particle = origin as? Particle {
      self.viewID = particle.viewID
    } else {
      fatalError("Attempted to copy an entity as a Particle, but found another origin type (\(type(of: origin))) instead.")
    }
    super.init(copying: origin)
  }
  
  override func render(_ context: GraphicsContext) {
    super.render(context)
    context.drawLayer { context in
      context.translateBy(x: pos.x, y: pos.y)
      context.rotate(by: rot)
      var resolved: GraphicsContext.ResolvedSymbol = context.resolveSymbol(id: "NOT_FOUND")!
      if let r = context.resolveSymbol(id: viewID) {
        resolved = r
      }
      context.draw(resolved, at: .zero)
    }
  }
}

