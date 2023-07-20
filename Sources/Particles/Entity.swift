//
//  Entity.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Foundation

public class Entity: Item, Identifiable, Renderable, Updatable, Copyable {
  
  // MARK: - Properties
  
  /// The entity's ID.
  public private(set) var id: UUID = UUID()
  
  /// A reference to the emitter that spawned this entity.
  var source: Emitter?
  
  /// The entity's position.
  public internal(set) var pos: CGPoint = .zero
  /// The entity's velocity.
  public internal(set) var vel: CGVector = .zero
  /// The entity's acceleration.
  public internal(set) var acc: CGVector = .zero
  
  /// The entity's rotation.
  public internal(set) var rot: Angle = .zero
  /// The entity's torque.
  public internal(set) var tor: Angle = .zero
  
  /// When the entity was created.
  public internal(set) var inception: Date = Date()
  /// The lifetime of this entity.
  public internal(set) var lifetime: TimeInterval = 5.0
  
  /// The particle's custom position over time.
  var customPos: LifetimeBound<CGPoint>?
  /// The particle's custom rotation over time.
  var customRot: LifetimeBound<Angle>?
  
  /// Whether this entity ignores field effects.
  var ignoreFields: Bool = false
  
  // MARK: - Computed Properties
  
  /// When this particle is to be destroyed.
  public var expiration: Date {
    return inception + lifetime
  }
  
  /// The amount of time this particle has been alive.
  public var timeAlive: TimeInterval {
    return Date().timeIntervalSince(inception)
  }
  
  /// The particle's progress from birth to death, a `Double` from `0.0` to `1.0`.
  public var lifetimeProgress: Double {
    return timeAlive / lifetime
  }
  
  // MARK: - Initalizers
  
  init(_ p0: CGPoint, _ v0: CGVector, _ a: CGVector) {
    self.pos = p0
    self.vel = v0
    self.acc = a
    super.init()
  }

  // MARK: - Overrides
  
  override init() {
    super.init()
  }
  
  override func debug(_ context: GraphicsContext) {
    context.stroke(
      Path { build in
        build.move(to: pos)
        build.addLine(to: pos.apply(vel.scale(10.0)))
      },
      with: .color(.green),
      lineWidth: 2.0
    )
  }
  
  // MARK: - Conformance
  
  required init(copying origin: Entity) {
    self.inception = Date()
    self.pos = origin.pos
    self.vel = origin.vel
    self.acc = origin.acc
    self.rot = origin.rot
    self.tor = origin.tor
    self.lifetime = origin.lifetime
    self.customPos = origin.customPos
    self.customRot = origin.customRot
    super.init()
    super.data = origin.data
  }
  
  func render(_ context: GraphicsContext) {
    if data?.debug ?? false {
      debug(context)
    }
  }
  
  // MARK: - Methods

  func update() {
    acc = .zero
    updatePhysics()
  }
  
  func supply(data: ParticleSystem.Data) {
    self.data = data
  }
  
  func inherit(effect: Field.Effect) {
    effect.closure(self)
  }
  
  private func updatePhysics() {
    for field in data?.fields ?? [] {
      guard !ignoreFields else { break }
      guard field.bounds.contains(self.pos) else { continue }
      inherit(effect: field.effect)
    }
    pos = pos.apply(vel)
    vel = vel.add(acc)
    rot = rot + tor
    if let customPos {
      pos = customPos.closure(lifetimeProgress)
    }
    if let customRot {
      rot = customRot.closure(lifetimeProgress)
    }
  }
}

public extension Entity {
  
  func initialPosition(x: Decider<CGFloat>, y: Decider<CGFloat>) -> Self {
    self.pos = CGPoint(x: x.decide(self), y: x.decide(self))
    return self
  }
  
  func initialPosition(x: CGFloat, y: CGFloat) -> Self {
    return self.initialPosition(x: .constant(x), y: .constant(y))
  }
  
  func initialVelocity(x: Decider<CGFloat>, y: Decider<CGFloat>) -> Self {
    self.vel = CGVector(dx: x.decide(self), dy: y.decide(self))
    return self
  }
  
  func initialVelocity(x: CGFloat, y: CGFloat) -> Self {
    return self.initialVelocity(x: .constant(x), y: .constant(y))
  }
  
  func initialRotation(_ angle: Angle) -> Self {
    self.rot = angle
    return self
  }
  
  func initialTorque(_ torque: Angle) -> Self {
    self.tor = torque
    return self
  }
  
  func ignoreFields(_ flag: Bool) -> Self {
    self.ignoreFields = flag
    return self
  }
  
  func lifetime(_ duration: TimeInterval) -> Self {
    self.lifetime = duration
    return self
  }
}

public extension Entity {
  
  func customPosition(_ bound: LifetimeBound<CGPoint>) -> Self {
    self.customPos = bound
    return self
  }
  
  func customRot(_ bound: LifetimeBound<Angle>) -> Self {
    self.customRot = bound
    return self
  }
}

public extension Entity {
  
  func customPosition(_ closure: @escaping (Double) -> CGPoint) -> Self {
    customPosition(.init(closure: closure))
  }
  
  func customRot(_ closure: @escaping (Double) -> Angle) -> Self {
    customRot(.init(closure: closure))
  }
}
