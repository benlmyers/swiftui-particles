//
//  ParticleSystem.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import SwiftUI
import Foundation

public struct ParticleSystem<Content>: View where Content: View {
  
  // MARK: - Properties
  
  /// Whether the system's animation is paused.
  var paused: Bool = false
  /// The color mode of the renderer.
  var colorMode: ColorRenderingMode = .nonLinear
  /// Whether to render the particles asynchronously.
  var async: Bool = true
  
  /// The particle system data to pass to child entities.
  var data: ParticleSystem.Data<Content> = .init()
  
  // MARK: - Views
  
  public var body: some View {
    TimelineView(.animation(paused: paused)) { t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
        ForEach(0 ..< data.views.count, id: \.self) { i in
          data.views[i].tag(i)
        }
      }
      .frame(width: 200.0, height: 200.0)
      .border(Color.red.opacity(data.debug ? 1.0 : 0.1))
      .opacity(t.date == Date() ? 1.0 : 1.0)
      .onChange(of: t.date) { date in
        update()
      }
    }
  }
  
  // MARK: - Initalizers
  
  init(_ entities: [Entity<Content>]) {
    for entity in entities {
      self.data.entities.append(entity)
    }
    for entity in self.data.entities {
      entity.data = self.data
    }
  }
  
  public init(@ParticleSystemBuilder entities: @escaping () -> [Entity<Content>]) {
    let entities = entities()
    self.init(entities)
  }
  
  public init(copying system: Self) {
    self.paused = system.paused
    self.async = system.async
    self.colorMode = system.colorMode
    self.data = system.data
  }
  
  // MARK: - Methods
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    for entity in data.entities {
      entity.render(context)
    }
  }
  
  func update() {
    var toRemove: [Entity<Content>.ID] = []
    for entity in data.entities {
      guard entity.expiration > Date() else {
        toRemove.append(entity.id)
        continue
      }
      entity.updatePhysics()
      entity.update()
    }
    //entities.removeAll(where: { toRemove.contains($0.id) })
  }
}

extension ParticleSystem {
  
  class Data<Content> where Content: View {
    
    // MARK: - Properties
    
    /// The particle views that the particle system will render.
    var views: [Content] = []
    /// A (recursive) collection of each active entity in the particle system.
    var entities: [Entity<Content>] = []
    /// Whether to enable debug mode.
    var debug: Bool = false
  }
}
