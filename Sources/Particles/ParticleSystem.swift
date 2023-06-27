//
//  ParticleSystem.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import SwiftUI
import Foundation

public struct ParticleSystem: View {
  
  // MARK: - Properties
  
  /// Whether the system's animation is paused.
  var paused: Bool = false
  /// The color mode of the renderer.
  var colorMode: ColorRenderingMode = .nonLinear
  /// Whether to render the particles asynchronously.
  var async: Bool = true
  
  /// The particle system data to pass to child entities.
  var data: ParticleSystem.Data = .init()
  
  // MARK: - Views
  
  public var body: some View {
    TimelineView(.animation(paused: paused)) { t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
        Text("❌").tag("NOT_FOUND")
        ForEach(0 ..< data.views.count, id: \.self) { i in
          data.views[i].view.tag(data.views[i].tag)
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
  
  public init(@EntitiesBuilder entities: @escaping () -> [Entity]) {
    let entities = entities()
    self.init(entities)
  }
  
  init(_ entities: [Entity]) {
    for entity in entities {
      entity.supply(data: data)
      self.data.entities.append(entity)
    }
  }
  
  init(copying system: Self) {
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
    var toRemove: [Entity.ID] = []
    for entity in data.entities {
      guard entity.expiration > Date() else {
        toRemove.append(entity.id)
        continue
      }
      entity.update()
    }
    //entities.removeAll(where: { toRemove.contains($0.id) })
  }
}

extension ParticleSystem {
  
  class Data {
    
    // MARK: - Properties
    
    /// The particle views that the particle system will render.
    var views: [AnyTaggedView] = []
    /// A (recursive) collection of each active entity in the particle system.
    var entities: [Entity] = []
    /// Whether to enable debug mode.
    var debug: Bool = false
  }
}
