//
//  Entity.swift
//
//
//  Created by Ben Myers on 9/30/23.
//

import SwiftUI
import Foundation

/// An entity declaration class. This class cannot be initialized.
open class Entity: Identifiable {
  
  // MARK: - Properties
  
  public private(set) var id: UUID = UUID()
  
  private final var birthActions: [(Entity.Proxy, Emitter.Proxy?) -> Void] = [
    { entityProxy, emitterProxy in
      if let emitterProxy {
        entityProxy.position = emitterProxy.position
      }
    }
  ]
  
  private final var deathActions: [(Entity.Proxy) -> Void] = []
  
  private final var updateActions: [(Entity.Proxy) -> Void] = [
    { proxy in
      let v: CGVector = proxy.velocity
      let a: CGVector = proxy.acceleration
      proxy.velocity = CGVector(dx: v.dx + a.dx, dy: v.dy + a.dy)
    },
    { proxy in
      let p: CGPoint = proxy.position
      let v: CGVector = proxy.velocity
      proxy.position = CGPoint(x: p.x + v.dx, y: p.y + v.dy)
    }
  ]
  
  // MARK: - Methods
  
  // Modifiers
  
  /// Modifies the behavior of the entity upon birth.
  ///
  /// If the entity came from an emitter, this method is called when the particle is emitted.
  /// If the entity was declared in a `ParticleSystem` or elsewhere, this method is called when the system's view appears.
  /// - Parameter action: The action to perform upon birth. If the entity was spawned from an `Emitter`, its proxy is passed in the closure.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  public final func onBirth(perform action: @escaping (Entity.Proxy, Emitter.Proxy?) -> Void) -> Self {
    self.birthActions.append(action)
    return self
  }
  
  /// Modifies the behavior of the entity upon update.
  ///
  /// This method is called each frame the `Canvas` powering the particle system updates.
  /// - Parameter action: The action to perform on update.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  public final func onUpdate(perform action: @escaping (Entity.Proxy) -> Void) -> Self {
    self.updateActions.append(action)
    return self
  }
  
  /// Modifies the behavior of the entity upon death.
  ///
  /// This method is called after an entity despawns.
  /// - Parameter action: The action to perform on death.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  public final func onDeath(perform action: @escaping (Entity.Proxy) -> Void) -> Self {
    self.deathActions.append(action)
    return self
  }
  
  /// Starts a particular value of the entity upon birth.
  /// - Parameters:
  ///   - path: A key path pointing to the proxy value to update.
  ///   - value: The initial value of the property.
  ///   - kind: The root type of the key path, some subclass of ``Entity.Proxy``.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  public func start<T, V>(_ path: ReferenceWritableKeyPath<T, V>, at value: V, in kind: T.Type = Proxy.self) -> Self where T: Entity.Proxy {
    self.onBirth { proxy, _ in
      guard let cast = proxy as? T else { fatalError("Something went wrong. Please submit a Github issue if you encounter this issue.") }
      cast[keyPath: path] = value
    }
  }
  
  /// Starts a particular value of the entity upon birth.
  /// - Parameters:
  ///   - path: A key path pointing to the proxy value to update.
  ///   - value: A closure returning the desired initial value of the property.
  ///   - kind: The root type of the key path, some subclass of ``Entity.Proxy``.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  public func start<T, V>(_ path: ReferenceWritableKeyPath<T, V>, with value: @escaping () -> V, in kind: T.Type = Proxy.self) -> Self where T: Entity.Proxy {
    self.onBirth { proxy, _ in
      guard let cast = proxy as? T else { fatalError("Something went wrong. Please submit a Github issue if you encounter this issue.") }
      cast[keyPath: path] = value()
    }
  }
  
  /// Fixes a particular value of the entity upon update.
  /// - Parameters:
  ///   - path: A key path pointing to the proxy value to update.
  ///   - value: The fixed value of the property.
  ///   - kind: The root type of the key path, some subclass of ``Entity.Proxy``.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  public func fix<T, V>(_ path: ReferenceWritableKeyPath<T, V>, at value: V, in kind: T.Type = Proxy.self) -> Self where T: Entity.Proxy {
    self.onUpdate { proxy in
      guard let cast = proxy as? T else { fatalError("Something went wrong. Please submit a Github issue if you encounter this issue.") }
      cast[keyPath: path] = value
    }
  }
  
  /// Fixes a particular value of the entity upon update.
  /// - Parameters:
  ///   - path: A key path pointing to the proxy value to update.
  ///   - value: A closure returning the desired fixed value of the property.
  ///   - kind: The root type of the key path, some subclass of ``Entity.Proxy``.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  public func fix<T, V>(_ path: ReferenceWritableKeyPath<T, V>, with value: @escaping () -> V, in kind: T.Type = Proxy.self) -> Self where T: Entity.Proxy {
    self.onUpdate { proxy in
      guard let cast = proxy as? T else { fatalError("Something went wrong. Please submit a Github issue if you encounter this issue.") }
      cast[keyPath: path] = value()
    }
  }
  
  // Implementation
  
  func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    let proxy = Proxy(systemData: data, entityData: self)
    return proxy
  }
  
  func updateBehaviors(from entity: Entity) {
    self.birthActions = entity.birthActions
    self.updateActions = entity.updateActions
    self.deathActions = entity.deathActions
  }
  
  // MARK: - Subtypes
  
  /// An entity proxy.
  ///
  /// This is the data used to represent an entity in the system. It contains information like the entity's position, velocity, acceleration, rotation, and more.
  open class Proxy {
    
    typealias Behavior = (Any) -> Void
    
    // MARK: - Properties
    
    public internal(set) final weak var systemData: ParticleSystem.Data?
    final var entityData: Entity
    
    private final let id: UUID = UUID()
    
    private var inception: Date = Date()
    
    public var lifetime: TimeInterval = 5.0
    public var position: CGPoint = .zero
    public var velocity: CGVector = .zero
    public var acceleration: CGVector = .zero
    public var rotation: Angle = .zero
    
    public var expiration: Date {
      return inception + lifetime
    }
    
    public var timeAlive: TimeInterval {
      return Date().timeIntervalSince(inception)
    }
    
    public var lifetimeProgress: Double {
      return timeAlive / lifetime
    }
    
    // MARK: - Initalizers
    
    init(systemData: ParticleSystem.Data, entityData: Entity) {
      self.systemData = systemData
      self.entityData = entityData
    }
    
    // MARK: - Methods
    
    func onUpdate(_ context: inout GraphicsContext) {
      for onUpdate in entityData.updateActions {
        onUpdate(self)
      }
    }
    
    func onBirth(_ source: Emitter.Proxy?) {
      for onBirth in entityData.birthActions {
        onBirth(self, source)
      }
    }
    
    func onDeath() {
      for onDeath in entityData.deathActions {
        onDeath(self)
      }
    }
  }
}

//public extension Entity {
//  
//  /// Sets the start position 
//  func startPosition(at point: UnitPoint) -> Self {
//    self.onBirth { proxy, emitter in
//      let size: CGSize = proxy.systemData!.systemSize
//      proxy.position = CGPoint(x: size.width * point.x, y: size.height * point.y)
//    }
//  }
//}
