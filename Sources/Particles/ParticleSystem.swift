//
//  ParticleSystem.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import SwiftUI
import Foundation

// MARK: - Internal

public struct ParticleSystem: View {
  
  // MARK: - Properties
  
  /// The color mode of the renderer.
  var colorMode: ColorRenderingMode = .nonLinear
  /// Whether to render the particles asynchronously.
  var async: Bool = true
  
  /// The particle system data to pass to child entities.
  var data: ParticleSystem.Data = .init()
  
  // MARK: - Initalizers
  
  init(_ items: [Entity]) {
    for item in items {
      self.data.entities.append(item)
    }
    for item in self.data.entities {
      item.supply(system: self.data)
    }
  }
  
  init(copying system: ParticleSystem) {
    self.async = system.async
    self.colorMode = system.colorMode
    self.data = system.data
  }
  
  // MARK: - Methods
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    self.data.size = size
    for entity in data.entities.compactMap({ $0 as? PhysicalEntity }) {
      entity.render(context)
      if data.debug {
        entity.debug(context)
      }
    }
  }
  
  func update() {
    for entity in data.entities.compactMap({ $0 as? PhysicalEntity }) {
      entity.update()
    }
  }
  
  func destroyExpired() {
    data.entities.removeAll(where: { e in
      guard let p = e as? PhysicalEntity else { return false }
      return Date() > p.expiration
    })
  }
  
  // MARK: - Subtypes
  
  class Data {
    
    // MARK: - Properties
    
    var views: [AnyTaggedView] = []
    var entities: [Entity] = []
    var debug: Bool = false
    var size: CGSize = .zero
  }
  
  // MARK: - Initalizers
  
  public init(@Builder<Entity> entities: @escaping () -> [Entity]) {
    let entities = entities()
    self.init(entities)
  }
  
  // MARK: - Conformance
  
  public var body: some View {
    TimelineView(.animation(paused: false)) { [self] t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
        Text("❌").tag("NOT_FOUND")
        ForEach(0 ..< data.views.count, id: \.self) { [self] i in
          data.views[i].view.tag(data.views[i].tag)
        }
      }
      .border(Color.red.opacity(data.debug ? 1.0 : 0.1))
      .opacity(t.date == Date() ? 1.0 : 1.0)
      .onChange(of: t.date) { [self] date in
        destroyExpired()
        update()
      }
    }
  }
}

public extension ParticleSystem {
  
  // MARK: - Modifiers
  
  func debug() -> ParticleSystem {
    let new = self
    new.data.debug = true
    return new
  }
  
  func colorMode(_ mode: ColorRenderingMode) -> ParticleSystem {
    var new = self
    new.colorMode = mode
    return new
  }
  
  func renderAsync(_ flag: Bool) -> ParticleSystem {
    var new = self
    new.async = flag
    return new
  }
}
