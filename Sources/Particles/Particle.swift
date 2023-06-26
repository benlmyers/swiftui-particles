//
//  Particle.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

class Particle<Content>: Entity<Content> where Content: View {
  
  // MARK: - Properties
  
  /// The content this particle displays.
  var view: Content
  /// The index of the graphical prototype relative to the `Emitter.proto` index.
  var index: Int
  
  // MARK: - Initializers
  
  init(_ view: Content, index: Int, p0: CGPoint, v0: CGVector, a: CGVector) {
    self.view = view
    self.index = index
    super.init(p0, v0, a)
  }
  
  // MARK: - Overrides
  
  override func render(_ context: GraphicsContext) {
    context.drawLayer { context in
      guard let resolved = context.resolveSymbol(id: index) else { return }
      context.draw(resolved, at: pos)
    }
  }
}

