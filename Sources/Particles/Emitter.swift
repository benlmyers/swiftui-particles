//
//  Emitter.swift
//
//
//  Created by Ben Myers on 10/2/23.
//

import SwiftUI
import Foundation

/// An emitter declaration.
///
/// Emitters spawn other entities on a regular time interval. To spawn an entity using an `Emitter`, place it within the emitter's declaration:
///
/// ```swift
/// ParticleSystem {
///   Emitter(
/// }
/// ```
public class Emitter: Entity {
  
  // MARK: - Properties
  
  private var prototypes: [Entity]
  
  // MARK: - Initalizers
  
  public init(@Builder<Entity> entities: @escaping () -> [Entity]) {
    self.prototypes = entities()
  }
  
  // MARK: - Overrides
  
  public override func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    return Proxy(prototypes: prototypes, systemData: data, entityData: self)
  }
  
  // MARK: - Subtypes
  
  public class Proxy: Entity.Proxy {
    
    // MARK: - Properties
    
    private var prototypes: [Entity]
    
    public private(set) var lastEmitted: Date?
    public private(set) var emittedCount: Int = 0
    
    public var fireRate: Double = 1.0
    public var decider: (Proxy) -> Int = { _ in Int.random(in: 0 ... .max) }
    
    // MARK: - Initalizers
    
    init(prototypes: [Entity], systemData: ParticleSystem.Data, entityData: Entity) {
      self.prototypes = prototypes
      super.init(systemData: systemData, entityData: entityData)
    }
    
    // MARK: - Overrides
    
    override func onUpdate(_ context: inout GraphicsContext) {
      super.onUpdate(&context)
      context.stroke(.init(ellipseIn: .init(x: position.x, y: position.y, width: 2.0, height: 2.0)), with: .color(.white))
      if let lastEmitted {
        guard Date().timeIntervalSince(lastEmitted) >= 1.0 / fireRate else {
          return
        }
      }
      guard !prototypes.isEmpty else {
        // TODO: Warn
        return
      }
      guard let systemData else {
        // TODO: Warn
        return
      }
      let prototype: Entity = prototypes[decider(self) % prototypes.count]
      let newProxy = prototype.makeProxy(source: self, data: systemData)
      systemData.proxies.insert(newProxy)
      lastEmitted = Date()
      emittedCount += 1
      newProxy.onBirth(self)
    }
  }
}
