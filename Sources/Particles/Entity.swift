//
//  Entity.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

public class Entity<Content>: Identifiable, Renderable where Content: View {
  
  // MARK: - Properties
  
  /// The entity's ID.
  public var id: UUID = UUID()
  
  /// A reference to the entity's parent system's data.
  var data: ParticleSystem<Content>.Data<Content>?
  
  /// The entity's position.
  var pos: CGPoint = .zero
  /// The entity's velocity.
  var vel: CGVector = .zero
  /// The entity's acceleration.
  var acc: CGVector = .zero
  /// The entity's size.
  var size: CGSize = .zero
  
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
  
  init() {
    
  }
  
  // MARK: - Implementation
  
  func render(_ context: GraphicsContext) {
    // Do nothing
  }
  
  // MARK: - Methods
  
  func updatePhysics() {
    pos = pos.apply(vel)
    vel = vel.add(acc)
  }
  
  func update() {}
}

public extension Entity {
  
  func initialVelocity(x: CGFloat, y: CGFloat) -> Self {
    self.vel = CGVector(dx: x, dy: y)
    return self
  }
  
  func setAcceleration(x: CGFloat, y: CGFloat) -> Self {
    self.acc = CGVector(dx: x, dy: y)
    return self
  }
}
