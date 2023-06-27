//
//  Emitter.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

public class Emitter: Entity {
  
  // MARK: - Properties
  
  /// Whether the emitter should fire particles.
  var fire: Bool = true
  /// The rate at which the emitter fires, in particles per second.
  var rate: Double = 3.0
  /// The lifetime to give fired particles.
  var lifetime: TimeInterval = 0.2
  
  /// The prototypical entities this emitter spawns.
  var spawn: [Entity]
  
  /// The fire velocity. This may be determined by the amount of particles fired and the amount of time since the emitter was created.
  var fireVelocity: (Int, TimeInterval) -> CGVector = { _, _ in return .zero }
  /// The emit chooser. This is determined by the amount of particles fired and the amount of time since the emitter was created.
  var chooser: (Int, TimeInterval) -> Int
  /// Whether to spawn particles independent of the emitter's velocity.
  var useInheritedVelocity: Bool = true
  
  /// The entities spawned by the emitter.
  var spawned: [Entity?] = []
  /// The last time the emitter fired a particle.
  var lastFire: Date?
  /// The amount of particles this emitter has spawned.
  var count: Int = 0
  
  // MARK: - Initalizers
  
  public init(@EntitiesBuilder entities: @escaping () -> [Entity]) {
    let entities: [Entity] = entities()
    self.spawn = entities
    self.chooser = { _, _ in return Int.random(in: 0 ..< entities.count) }
    super.init()
  }
  
  // MARK: - Conformance
  
  required init(copying origin: Entity) {
    if let emitter = origin as? Emitter {
      self.fire = emitter.fire
      self.rate = emitter.rate
      self.lifetime = emitter.lifetime
      self.spawn = emitter.spawn
      self.fireVelocity = emitter.fireVelocity
      self.chooser = emitter.chooser
      self.useInheritedVelocity = emitter.useInheritedVelocity
      self.spawn = emitter.spawn
    } else {
      fatalError("Attempted to copy an entity as an Emitter, but found another origin type (\(type(of: origin))) instead.")
    }
    super.init(copying: origin)
  }
  
  // MARK: - Overrides
  
  override func debug(_ context: GraphicsContext) {
    super.debug(context)
    context.stroke(
      Path(ellipseIn: CGRect(origin: .zero, size: CGSize(width: 5.0, height: 5.0))),
      with: .color(.yellow),
      lineWidth: 4
    )
  }
  
  override func update() {
    super.update()
    ParticleSystem.destroyExpiredEntities(in: &spawned)
    for entity in spawned {
      entity?.update()
    }
    if let lastFire {
      guard Date().timeIntervalSince(lastFire) >= 1.0 / rate else { return }
    }
    emit()
  }
  
  override func render(_ context: GraphicsContext) {
    super.render(context)
    for entity in spawned {
      entity?.render(context)
    }
    if data?.debug ?? false {
      debug(context)
    }
  }
  
  override func supply(data: ParticleSystem.Data) {
    self.data = data
    for entity in spawn {
      entity.supply(data: data)
    }
  }
  
  // MARK: - Methods
  
  func emit() {
    let interval: TimeInterval = Date().timeIntervalSince(inception)
    let fireVel: CGVector = fireVelocity(count, interval)
    let i: Int = chooser(count, interval)
    guard let data else {
      return
      //fatalError("This entity could not access the particle system's data.")
    }
    guard i < spawn.count else {
      fatalError("Out of bounds: Your emitter's chooser closure looked for an entity prototype of index \(i), but this emitter only has prototypes up to index \(spawn.count).")
    }
    let spawn: Entity = spawn[i]
    var toSpawn: Entity
    if let particle = spawn as? Particle {
      toSpawn = Particle(copying: particle)
    } else if let emitter = spawn as? Emitter {
      toSpawn = Emitter(copying: emitter)
    } else {
      fatalError("Cannot emit an unsupported entity of type \(type(of: spawn)).")
    }
    toSpawn.inception = Date()
    toSpawn.expiration = Date().advanced(by: lifetime)
    toSpawn.supply(data: data)
    if useInheritedVelocity {
      toSpawn.vel = toSpawn.vel.add(self.vel)
    }
    toSpawn.vel = toSpawn.vel.add(fireVel)
    toSpawn.pos = self.pos
    spawned.append(toSpawn)
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
