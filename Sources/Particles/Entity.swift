//
//  Entity.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

public class Entity: Identifiable, Renderable, Updatable, Copyable {
  
  // MARK: - Properties
  
  /// The entity's ID.
  public var id: UUID = UUID()
  
  /// A reference to the entity's parent system's data.
  var data: ParticleSystem.Data?
  
  /// The entity's position.
  var pos: CGPoint = .zero
  /// The entity's velocity.
  var vel: CGVector = .zero
  /// The entity's acceleration.
  var acc: CGVector = .zero
  
  /// The entity's rotation.
  var rot: Angle = .zero
  /// The entity's torque.
  var tor: Angle = .zero
  
  /// When the entity was created.
  var inception: Date = Date()
  /// When the entity is to be destroyed.
  var expiration: Date = .distantFuture
  
  // MARK: - Initalizers
  
  init(_ p0: CGPoint, _ v0: CGVector, _ a: CGVector) {
    self.pos = p0
    self.vel = v0
    self.acc = a
  }
  
  init() {}
  
  // MARK: - Conformance
  
  required init(copying origin: Entity) {
    self.data = origin.data
    self.pos = origin.pos
    self.vel = origin.vel
    self.acc = origin.acc
    self.rot = origin.rot
    self.tor = origin.tor
  }
  
  func render(_ context: GraphicsContext) {
    // Do nothing
  }
  
  // MARK: - Methods

  func update() {
    updatePhysics()
  }
  
  func supply(data: ParticleSystem.Data) {
    self.data = data
  }
  
  private func updatePhysics() {
    pos = pos.apply(vel)
    vel = vel.add(acc)
    rot = rot + tor
  }
}

public extension Entity {
  
  // MARK: - Modifiers
  
  func initialPosition(x: CGFloat, y: CGFloat) -> Self {
    self.pos = CGPoint(x: x, y: y)
    return self
  }
  
  func initialVelocity(x: CGFloat, y: CGFloat) -> Self {
    self.vel = CGVector(dx: x, dy: y)
    return self
  }
  
  func initialAcceleration(x: CGFloat, y: CGFloat) -> Self {
    self.acc = CGVector(dx: x, dy: y)
    return self
  }
  
  func initialRotation(_ angle: Angle) -> Self {
    self.rot = angle
    return self
  }
  
  func initialTorque(_ torque: Angle) -> Self {
    self.tor = torque
    return self
  }
}
