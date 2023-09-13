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
  public internal(set) var children: Set<Entity?> = .init()
  /// When the entity was created.
  public internal(set) var inception: Date = Date()
  
  /// The lifetime of this entity.
  @Configured public internal(set) var lifetime: TimeInterval = 5.0
  
  // Physical Properties
  
  /// The entity's position.
  @Configured public internal(set) var pos: CGPoint = .zero
  /// The entity's velocity.
  @Configured public internal(set) var vel: CGVector = .zero
  /// The entity's acceleration.
  @Configured public internal(set) var acc: CGVector = .zero
  /// The entity's rotation.
  @Configured public internal(set) var rotation: Angle = .zero
  /// The entity's torque.
  @Configured public internal(set) var torque: Angle = .zero
  /// The entity's torque variation (change in torque).
  @Configured public internal(set) var torqueVariation: Angle = .zero
  /// The entity's center of rotation.
  @Configured public internal(set) var anchor: CGVector = .zero
  
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
  
  // MARK: - Initalizers
  
  init() {
    // Default physics configuration
    self._pos.setBehavior { entity, pos in
      let v = entity.vel
      return CGPoint(x: pos.x + v.dx, y: pos.y + v.dy)
    }
    self._vel.setBehavior { entity, vel in
      vel.add(entity.acc)
    }
    self._rotation.setBehavior { entity, rotation in
      Angle(degrees: rotation.degrees + entity.torque.degrees)
    }
    self._torque.setBehavior { entity, torque in
      Angle(degrees: torque.degrees + entity.torqueVariation.degrees)
    }
  }
  
  init(copying e: Entity) {
    self._lifetime = e.$lifetime.copy()
    self._pos = e.$pos.copy()
    self._vel = e.$vel.copy()
    self._acc = e.$acc.copy()
    self._rotation = e.$rotation.copy()
    self._torque = e.$torque.copy()
    self._torqueVariation = e.$torqueVariation.copy()
    self._anchor = e.$anchor.copy()
    self.system = e.system
  }
  
  // MARK: - Conformance
  
  public static func == (lhs: Entity, rhs: Entity) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    return id.hash(into: &hasher)
  }
  
  // MARK: - Initalizers
  
  func render(_ context: GraphicsContext) {
    // Do nothing.
  }
  
  func debug(_ context: GraphicsContext) {
    context.fill(Path(ellipseIn: .init(x: pos.x, y: pos.y, width: 2.0, height: 2.0)), with: .color(.red))
  }
  
  func update() {
    $lifetime.update(in: self)
    $pos.update(in: self)
    $vel.update(in: self)
    $acc.update(in: self)
    $rotation.update(in: self)
    $torque.update(in: self)
    $torqueVariation.update(in: self)
    $anchor.update(in: self)
  }
  
  func supply(system: ParticleSystem.Data) {
    self.system = system
  }
  
  // MARK: - Subtypes
  
  @propertyWrapper public class Configured<T> {
    
    public typealias Behavior = (Entity, T) -> T
    
    public internal(set) var wrappedValue: T
    private var behaviors: [Behavior] = []
    
    public var projectedValue: Configured<T> {
      return self
    }
    
    public init(wrappedValue: T) {
      self.wrappedValue = wrappedValue
    }
    
    public func set(to constant: T) {
      self.setBehavior { _, _ in constant }
    }
    
    public func setBehavior(_ behavior: @escaping Behavior) {
      self.behaviors = [behavior]
    }
    
    public func addBehavior(_ behavior: @escaping Behavior) {
      self.behaviors.append(behavior)
    }
    
    public func bind(to binding: Binding<T>) {
      self.setBehavior { _, _ in binding.wrappedValue }
    }
    
    func update(in entity: Entity) {
      for behavior in behaviors {
        update(behavior: behavior, in: entity)
      }
    }
    
    func copy() -> Configured<T> {
      var copy = Configured<T>.init(wrappedValue: wrappedValue)
      copy.behaviors = behaviors
      return copy
    }
    
    private func update(behavior: Behavior, in entity: Entity) {
      wrappedValue = behavior(entity, wrappedValue)
    }
  }
}

public extension Entity {
  
  func bind<T>(_ key: KeyPath<Entity, Configured<T>>, to value: Binding<T>) -> Self {
    self[keyPath: key].bind(to: value)
    return self
  }
  
  func setConstant<T>(_ key: KeyPath<Entity, Configured<T>>, to value: T) -> Self {
    self[keyPath: key].set(to: value)
    return self
  }
  
  func setInitial<T>(_ key: KeyPath<Entity, Configured<T>>, to value: T) -> Self {
    self[keyPath: key].wrappedValue = value
    return self
  }
  
  func setCustom<T>(_ key: KeyPath<Entity, Configured<T>>, onUpdate: @escaping (Entity, T) -> T) -> Self {
    self[keyPath: key].addBehavior(onUpdate)
    return self
  }
}

public extension Entity {
  
  func starts(atPoint point: CGPoint) -> Self {
    self.pos = point
    return self
  }
  
  func starts(at unitPoint: UnitPoint) -> Self {
    guard let system: ParticleSystem.Data else {
      return self
    }
    self.pos = CGPoint(x: unitPoint.x * system.size.width, y: unitPoint.y * system.size.height)
    return self
  }
  
  func initialVelocity(_ vector: CGVector) -> Self {
    self.vel = vector
    return self
  }
  
  func constantVelocity(_ vector: CGVector) -> Self {
    self.$vel.set(to: vector)
    return self
  }
  
  func constantAcceleration(_ vector: CGVector) -> Self {
    self.$acc.set(to: vector)
    return self
  }
}
