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
    self._pos.behavior = { entity, pos in
      let v = entity.vel
      return CGPoint(x: pos.x + v.dx, y: pos.y + v.dy)
    }
    self._vel.behavior = { entity, vel in
      vel.add(entity.acc)
    }
    self._rotation.behavior = { entity, rotation in
      Angle(degrees: rotation.degrees + entity.torque.degrees)
    }
    self._torque.behavior = { entity, torque in
      Angle(degrees: torque.degrees + entity.torqueVariation.degrees)
    }
  }
  
  init(copying e: Entity, from emitter: Emitter) {
    self._lifetime = e.$lifetime.copy(parentValue: emitter.lifetime)
    self._pos = e.$pos.copy(parentValue: emitter.pos)
    self._vel = e.$vel.copy(parentValue: emitter.vel)
    self._acc = e.$acc.copy(parentValue: emitter.acc)
    self._rotation = e.$rotation.copy(parentValue: emitter.rotation)
    self._torque = e.$torque.copy(parentValue: emitter.torque)
    self._torqueVariation = e.$torqueVariation.copy(parentValue: emitter.torqueVariation)
    self._anchor = e.$anchor.copy(parentValue: emitter.anchor)
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
    context.fill(Path(ellipseIn: .init(x: pos.x, y: pos.y, width: 2.0, height: 2.0)), with: .color(
      [Color.red, .orange, .yellow, .green, .blue, .purple].randomElement()!
    ))
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
    
    private var initialValue: T
    public internal(set) var wrappedValue: T
    var behavior: (Entity, T) -> T
    public internal(set) var inheritsFromParent: Bool = true
    
    public var projectedValue: Configured<T> {
      return self
    }
    
    public init(wrappedValue: T) {
      self.wrappedValue = wrappedValue
      self.initialValue = wrappedValue
      self.behavior = { _, v in return v }
    }
    
    public func setInitial(to value: T) {
      self.initialValue = value
      self.wrappedValue = value
    }
    
    public func fix(to constant: T) {
      self.behavior = { _, _ in
        return constant
      }
    }
    
    public func bind(to binding: Binding<T>) {
      self.behavior = { _, _ in
        return binding.wrappedValue
      }
    }
    
    func update(in entity: Entity) {
      // 1. Apply behavior
      wrappedValue = behavior(entity, wrappedValue)
    }
    
    func copy(parentValue: T? = nil) -> Configured<T> {
      let copy = Configured<T>.init(wrappedValue: initialValue)
      copy.behavior = behavior
      copy.inheritsFromParent = inheritsFromParent
      if copy.inheritsFromParent, let parentValue {
        copy.wrappedValue = parentValue
      }
      return copy
    }
  }
}
