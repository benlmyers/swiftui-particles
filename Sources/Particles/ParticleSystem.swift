//
//  ParticleSystem.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import SwiftUI
import Foundation

struct ParticleSystem: View {
  
  // MARK: - Parameters
  
  /// Whether the system's animation is paused.
  var paused: Bool = false
  /// The color mode of the renderer.
  var colorMode: ColorRenderingMode = .nonLinear
  /// Whether to render the particles asynchronously.
  var async: Bool = true
  
  // MARK: - Properties
  
  /// The underlying physics for the particle system.
  @State var entities: [Entity] = []
  /// The views the system shall render.
  @State var views: [AnyView] = []
  
  // MARK: - Views
  
  var body: some View {
    TimelineView(.animation(paused: paused)) { t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
        Text("x").tag(0)
      }
    }
  }
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    
  }
  
  // MARK: - Methods
  
  func calculate() {
    var toRemove: [Entity.ID] = []
    for entity in entities {
      entity.update()
      if entity.expiration >= Date() {
        toRemove.append(entity.id)
      }
    }
    entities.removeAll(where: { toRemove.contains($0.id) })
  }
}

class Entity: Identifiable {
  
  // MARK: - Properties
  
  var id: UUID
  var pos: CGPoint
  var vel: CGVector
  var acc: CGVector
  var size: CGSize
  var expiration: Date
  
  // MARK: - Initalizers
  
  init(p0: CGPoint, v0: CGVector = .zero, a: CGVector = .zero, size: CGSize = .init(width: 5.0, height: 5.0), expiration: Date) {
    self.id = UUID()
    self.pos = p0
    self.vel = v0
    self.acc = a
    self.size = size
    self.expiration = expiration
  }
  
  // MARK: - Methods
  
  func update() {
    pos = pos.apply(vel)
    vel = vel.add(acc)
  }
}

class Emitter: Entity {
  
  // MARK: - Properties
  
  /// Whether the emitter should fire particles.
  var fire: Bool
  /// The rate at which the emitter fires, in particles per second.
  var rate: Double
  /// The lifetime to give fired particles.
  var lifetime: TimeInterval
  
  /// The particles fired by the emitter.
  var particles: [Particle] = []
  /// The fire velocity. This may be determined by the amount of particles fired and the amount of time since the emitter was created.
  var fireVelocity: (Int, TimeInterval) -> (CGVector) = { _, _ in return .zero }
  /// Whether to spawn particles independent of the emitter's velocity.
  var ignoreInheritedVelocity: Bool = false
  
  /// The date this emitter was created.
  var inception: Date = Date()
  /// The last time the emitter fired a particle.
  var lastFire: Date?
  /// The amount of particles this emitter has spawned.
  var count: Int = 0
  
  // MARK: - Initalizers
  
  init(p0: CGPoint, v0: CGVector = .zero, a: CGVector = .zero, size: CGSize = .zero, fire: Bool = true, rate: Double, lifetime: TimeInterval = 3.0) {
    self.fire = fire
    self.rate = rate
    self.lifetime = lifetime
    super.init(p0: p0, v0: v0, a: a, size: size, expiration: Date.distantFuture)
  }
  
  // MARK: - Methods
  
  func emit() {
    if let lastFire {
      guard Date().timeIntervalSince(lastFire) < 1.0 / rate else { return }
    }
    let vel = fireVelocity(count, Date().timeIntervalSince(inception))
    let particle = Particle(p0: self.pos, v0: ignoreInheritedVelocity ? vel : vel.add(self.vel), expiration: Date() + lifetime)
    lastFire = Date()
  }
}

class Particle: Entity {
  /// The particle's appearance.
  var view: some View = Circle()
}

struct ParticleSystem_Previews: PreviewProvider {
  static var previews: some View {
    ParticleSystem()
  }
}
