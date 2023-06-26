//
//  Emitter.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

public class Emitter<Content>: Entity<Content> where Content: View {
  
  // MARK: - Properties
  
  /// Whether the emitter should fire particles.
  var fire: Bool = true
  /// The rate at which the emitter fires, in particles per second.
  var rate: Double = 1.0
  /// The lifetime to give fired particles.
  var lifetime: TimeInterval = 5.0
  
  /// The prototypical views that this emitter creates particles for, and their respective system view indices.
  var protos: [Content]
  /// The base index registered in the particle system for prototypical views.
  var baseIndex: Int?
  
  /// The particles fired by the emitter.
  var particles: [Particle<Content>] = []
  /// The fire velocity. This may be determined by the amount of particles fired and the amount of time since the emitter was created.
  var fireVelocity: (Int, TimeInterval) -> CGVector = { _, _ in return .zero }
  /// The emit chooser. This is determined by the amount of particles fired and the amount of time since the emitter was created.
  var chooser: (Int, TimeInterval) -> Int
  /// Whether to spawn particles independent of the emitter's velocity.
  var useInheritedVelocity: Bool = true
  
  /// The last time the emitter fired a particle.
  var lastFire: Date?
  /// The amount of particles this emitter has spawned.
  var count: Int = 0
  
  // MARK: - Initalizers
  
  public init(@EmitterBuilder views: @escaping () -> [Content]) where Content: View {
    let views: [Content] = views()
    self.protos = views
    self.chooser = { _, _ in return Int.random(in: 0 ..< views.count) }
    super.init()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.00001) {
      guard let data = self.data else {
        fatalError("The particle system's data could not be accessed by the particle.")
      }
      self.baseIndex = data.views.count
      for view in views {
        data.views.append(view)
      }
    }
  }
  
  // MARK: - Override
  
  override func update() {
    for particle in particles {
      particle.updatePhysics()
      particle.update()
    }
    if let lastFire {
      guard Date().timeIntervalSince(lastFire) < 1.0 / rate else { return }
    }
    emit()
  }
  
  // MARK: - Overrides
  
  override func render(_ context: GraphicsContext) {
    for particle in particles {
      particle.render(context)
    }
  }
  
  // MARK: - Methods
  
  func emit() {
    let interval: TimeInterval = Date().timeIntervalSince(inception)
    let vel: CGVector = fireVelocity(count, interval)
    let i: Int = chooser(count, interval)
    guard let data = self.data else {
      fatalError("The particle system's data could not be accessed by the particle.")
    }
    guard !data.views.isEmpty else {
      return
      // fatalError("The particle system did not have any prototypical views.")
    }
    guard i < data.views.count else {
      fatalError("Out of bounds: Your chooser closure looked for content of index \(i), but this emitter only has content up to index \(data.views.count).")
    }
    guard let baseIndex else {
      fatalError("No base index was assigned.")
    }
    let view: Content = data.views[i]
    let particle: Particle = Particle(view, index: baseIndex + i, p0: pos, v0: useInheritedVelocity ? self.vel.add(vel) : vel, a: .zero)
    particle.data = self.data
    self.particles.append(particle)
    lastFire = Date()
    count += 1
  }
}

public extension Emitter {
  
  func particlesInheritVelocity(_ flag: Bool) -> Emitter {
    self.useInheritedVelocity = flag
    return self
  }
  
  func emitVelocity(x: CGFloat, y: CGFloat) -> Emitter {
    self.fireVelocity = { _, _ in return CGVector(dx: x, dy: y) }
    return self
  }
  
  func emitVelocity(_ velocityFromParticleCount: @escaping (Int) -> CGVector) {
    self.fireVelocity = { i, _ in return velocityFromParticleCount(i) }
  }

  func emitVelocity(_ velocityFromTimeAlive: @escaping (TimeInterval) -> CGVector) {
    self.fireVelocity = { _, t in return velocityFromTimeAlive(t) }
  }
}
