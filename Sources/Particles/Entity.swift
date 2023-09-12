//
//  Entity.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Foundation

public class Entity: Identifiable, Hashable, Equatable {
  
  // MARK: - Properties
  
  // Identity
  
  /// The entity's ID.
  public private(set) var id: UUID = UUID()
  /// The parent of the entity.
  public private(set) weak var parent: Entity?
  /// The children of the entity.
  public private(set) var children: Set<Entity?> = .init()
  /// When the entity was created.
  public internal(set) var inception: Date = Date()
  
  /// The lifetime of this entity.
  @Configured var lifetime: TimeInterval = 5.0
  
  // Physical Properties
  
  /// The entity's position.
  @Configured public internal(set) var pos: CGPoint = .zero
  /// The entity's velocity.
  @Configured public internal(set) var vel: CGVector = .zero
  /// The entity's acceleration.
  @Configured public internal(set) var acc: CGVector = .zero
  /// The entity's bounding size.
  @Configured public internal(set) var size: CGSize = .square(15.0)
  /// The entity's rotation.
  @Configured public internal(set) var rotation: Angle = .zero
  /// The entity's torque.
  @Configured public internal(set) var torque: Angle = .zero
  /// The entity's torque variation (change in torque).
  @Configured public internal(set) var torqueVariation: Angle = .zero
  /// The entity's center of rotation.
  @Configured public internal(set) var anchor: UnitPoint = .center
  
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
  
  weak var system: ParticleSystem.Data?
  
  // MARK: - Conformance
  
  init(in system: ParticleSystem) {
    self.system = system.data
    // Default physics configuration
    self._pos.setBehavior { entity, pos in
      let v = entity.vel
      return CGPoint(x: pos.x + v.dx, y: pos.y + v.dy)
    }
    self._vel.setBehavior { entity, vel in
      vel.add(entity.acc)
    }
  }
  
  convenience init(copying origin: Entity, in system: ParticleSystem) {
    self.init(in: system)
    self.lifetime = origin.lifetime
    self.pos = origin.pos
    self.vel = origin.vel
    self.acc = origin.acc
    self.size = origin.size
    self.rotation = origin.rotation
    self.torque = origin.torque
    self.torqueVariation = origin.torqueVariation
    self.anchor = origin.anchor
  }
  
  public static func == (lhs: Entity, rhs: Entity) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    return id.hash(into: &hasher)
  }
  
  // MARK: - Initalizers
  
  func render(_ context: GraphicsContext) {
    // TODO: Render
  }
  
  func debug(_ context: GraphicsContext) {
    // TODO: Debug
  }
  
  func update() {
    // TODO: Implement
  }
  
  func supply(system: ParticleSystem.Data) {
    self.system = system
  }
  
  // MARK: - Subtypes
  
  @propertyWrapper public class Configured<T> {
    
    typealias Behavior = (Entity, T) -> T
    
    public var wrappedValue: T
    private var behaviors: [Behavior] = []
    
    public init(wrappedValue: T) {
      self.wrappedValue = wrappedValue
    }
    
    func setBehavior(_ behavior: @escaping Behavior) {
      self.behaviors = [behavior]
    }
    
    func addBehavior(_ behavior: @escaping Behavior) {
      self.behaviors.append(behavior)
    }
    
    func update(in entity: Entity) {
      for behavior in behaviors {
        update(behavior: behavior, in: entity)
      }
    }
    
    private func update(behavior: Behavior, in entity: Entity) {
      wrappedValue = behavior(entity, wrappedValue)
    }
  }
}
