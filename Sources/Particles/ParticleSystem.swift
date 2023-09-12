//
//  ParticleSystem.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import SwiftUI
import Foundation

// MARK: - Internal

public struct ParticleSystem {
  
  // MARK: - Properties
  
  /// Whether the system's animation is paused.
  var paused: Binding<Bool> = .constant(false)
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
  }
  
  init(copying system: Self) {
    self.paused = system.paused
    self.async = system.async
    self.colorMode = system.colorMode
    self.data = system.data
  }
  
  // MARK: - Methods
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    self.data.size = size
    for entity in data.entities {
      entity.render(context)
    }
  }
  
  func update() {
    for entity in data.entities {
      entity.update()
    }
  }
  
  func destroyExpired() {
    data.entities.removeAll(where: { Date() > $0.expiration })
  }
  
  // MARK: - Subtypes
  
  class Data {
    
    // MARK: - Properties
    
    var views: [AnyTaggedView] = []
    var entities: [Entity] = []
    var debug: Bool = false
    var size: CGSize = .zero
  }
}

// MARK: - Public API

extension ParticleSystem: View {
  
  // MARK: - Initalizers
  
  public init(@Builder<Entity> entities: @escaping () -> [Entity]) {
    let entities = entities()
    self.init(entities)
  }
  
  // MARK: - Conformance
  
  public var body: some View {
    TimelineView(.animation(paused: paused.wrappedValue)) { t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
        Text("❌").tag("NOT_FOUND")
        ForEach(0 ..< data.views.count, id: \.self) { i in
          data.views[i].view.tag(data.views[i].tag)
        }
      }
      .border(Color.red.opacity(data.debug ? 1.0 : 0.1))
      .opacity(t.date == Date() ? 1.0 : 1.0)
      .onChange(of: t.date) { date in
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
  
  func paused(_ flag: Binding<Bool>) -> ParticleSystem {
    var new = self
    new.paused = flag
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
