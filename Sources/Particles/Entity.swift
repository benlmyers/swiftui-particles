//
//  Entity.swift
//
//
//  Created by Ben Myers on 9/30/23.
//

import SwiftUI
import Foundation

/// An entity declaration class. This class cannot be initialized.
public class Entity {
  
  // MARK: - Properties
  
  private var birthActions: [(Entity.Proxy, Emitter.Proxy?) -> Void] = [
    { entityProxy, emitterProxy in
      if let emitterProxy {
        entityProxy.position = emitterProxy.position
      }
    }
  ]
  
  private var deathActions: [(Entity.Proxy) -> Void] = []
  
  private var updateActions: [(Entity.Proxy) -> Void] = [
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
  
  func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    let proxy = Proxy(systemData: data, entityData: self)
    return proxy
  }
  
  /// An entity proxy.
  ///
  /// This is the data used to represent an entity in the system. It contains information like the entity's position, velocity, acceleration, rotation, and more.
  public class Proxy: Identifiable, Hashable, Equatable {
    
    typealias Behavior = (Any) -> Void
    
    // MARK: - Properties
    
    final weak var systemData: ParticleSystem.Data?
    private final var entityData: Entity
    
    public final let id: UUID = UUID()
    
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
    
    // MARK: - Conformance
    
    public static func == (lhs: Proxy, rhs: Proxy) -> Bool {
      return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
      return id.hash(into: &hasher)
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

public extension Entity {
  
  /// Modifies the behavior of the entity upon birth.
  ///
  /// If the entity came from an emitter, this method is called when the particle is emitted.
  /// If the entity was declared in a `ParticleSystem` or elsewhere, this method is called when the system's view appears.
  /// - Parameter action: The action to perform upon birth. If the entity was spawned from an `Emitter`, its proxy is passed in the closure.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  func onBirth(perform action: @escaping (Entity.Proxy, Emitter.Proxy?) -> Void) -> Self {
    self.birthActions.append(action)
    return self
  }
  
  /// Modifies the behavior of the entity upon update.
  ///
  /// This method is called each frame the `Canvas` powering the particle system updates.
  /// - Parameter action: The action to perform on update.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  func onUpdate(perform action: @escaping (Entity.Proxy) -> Void) -> Self {
    self.updateActions.append(action)
    return self
  }
  
  /// Modifies the behavior of the entity upon death.
  ///
  /// This method is called after an entity despawns.
  /// - Parameter action: The action to perform on death.
  /// - Returns: The updated entity declaration. This is an entity modifier.
  func onDeath(perform action: @escaping (Entity.Proxy) -> Void) -> Self {
    self.deathActions.append(action)
    return self
  }
}
