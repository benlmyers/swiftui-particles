//
//  ParticleSystem+Data.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation
import CoreGraphics

extension ParticleSystem {
  internal class Data {
    public internal(set) var systemSize: CGSize = .zero
    internal private(set) var currentFrame: UInt16 = .zero
    internal private(set) var lastFrameUpdate: Date = .distantPast
    internal var debug: Bool = false
    internal var systemTime: TimeInterval {
      return Date().timeIntervalSince(inception)
    }
    private var inception: Date = Date()
    private var entities: [EntityID: any Entity] = [:]
    // ID of entity -> View to render
    private var views: [EntityID: AnyView] = .init()
    // ID of proxy -> Physics data
    private var physicsProxies: [ProxyID: PhysicsProxy] = [:]
    // ID of proxy -> Render data
    private var renderProxies: [ProxyID: RenderProxy] = [:]
    // ID of proxy -> ID of entity containing data behaviors
    private var proxyEntities: [ProxyID: EntityID] = [:]
    // ID of emitter proxy -> Frame such proxy last emitted a child
    private var lastEmitted: [ProxyID: UInt16] = [:]
    // ID of emitter entity -> Entity IDs to create children with
    private var emitEntities: [EntityID: [EntityID]] = [:]
    // ID of entity contained in EntityGroup -> Group entity top-level ID
    private var entityGroups: [EntityID: EntityID] = [:]
    internal private(set) var nextEntityRegistry: EntityID = .zero
    internal private(set) var nextProxyRegistry: ProxyID = .zero
    init() {}
    internal func emitChildren() {
      let proxyIDs = physicsProxies.keys
      for proxyID in proxyIDs {
        guard let _: PhysicsProxy = physicsProxies[proxyID] else { continue }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        guard let entity: any Entity = entities[entityID] else { continue }
        guard let emitter = entity.underlyingEmitter() else { continue }
        guard let protoEntities: [EntityID] = emitEntities[entityID] else { continue }
        if let emitted: UInt16 = lastEmitted[proxyID] {
          let emitAt: UInt16 = emitted + UInt16(emitter.emitInterval * 60.0)
          guard currentFrame >= emitAt else { continue }
        }
        for protoEntity in protoEntities {
          guard let _: ProxyID = self.create(protoEntity, inherit: entityID) else { continue }
          self.lastEmitted[proxyID] = currentFrame
        }
      }
    }
    internal func updatePhysics() {
      let proxyIDs = physicsProxies.keys
      for proxyID in proxyIDs {
        guard let proxy: PhysicsProxy = physicsProxies[proxyID] else { continue }
        var deathFrame: Int = .max
        if proxy.lifetime < .infinity {
          deathFrame = Int(Double(proxy.inception) + proxy.lifetime * 60.0)
        }
        if Int(currentFrame) >= deathFrame {
          physicsProxies.removeValue(forKey: proxyID)
          renderProxies.removeValue(forKey: proxyID)
          proxyEntities.removeValue(forKey: proxyID)
        }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        guard let entity: any Entity = entities[entityID] else { continue }
        let context = PhysicsProxy.Context(physics: proxy, data: self)
        let newPhysics = entity.onPhysicsUpdate(context)
        physicsProxies[proxyID] = newPhysics
      }
    }
    internal func updateRenders() {
      let proxyIDs = physicsProxies.keys
      for proxyID in proxyIDs {
        guard let renderProxy: RenderProxy = renderProxies[proxyID] else { continue }
        guard let physicsProxy: PhysicsProxy = physicsProxies[proxyID] else { continue }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        guard let entity: any Entity = entities[entityID] else { continue }
        let context = RenderProxy.Context(physics: physicsProxy, render: renderProxy, data: self)
        let newPhysics = entity.onRenderUpdate(context)
        renderProxies[proxyID] = newPhysics
      }
    }
    internal func performRenders(_ context: inout GraphicsContext) {
      for proxyID in physicsProxies.keys {
        let render: RenderProxy? = renderProxies[proxyID]
        guard let physics: PhysicsProxy = physicsProxies[proxyID] else { continue }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        if views[entityID] == nil {
          guard let entity: any Entity = entities[entityID] else { continue }
          guard let view: AnyView = entity.viewToRegister() else { continue }
          views[entityID] = view
        }
        guard
          physics.position.x > -20.0,
          physics.position.x < systemSize.width + 20.0,
          physics.position.y > -20.0,
          physics.position.y < systemSize.height + 20.0
        else { continue }
        context.drawLayer { context in
          if let render {
            context.opacity = render.opacity
            if !render.hueRotation.degrees.isZero {
              context.addFilter(.hueRotation(render.hueRotation))
            }
          }
          context.translateBy(x: physics.position.x, y: physics.position.y)
          if let render, render.scale.width != 1.0 || render.scale.height != 1.0 {
            context.scaleBy(x: render.scale.width, y: render.scale.height)
          }
          context.rotate(by: physics.rotation)
          guard let resolved = context.resolveSymbol(id: entityID) else {
            return
          }
          context.draw(resolved, at: .zero)
        }
      }
    }
    internal func advanceFrame() {
      if self.currentFrame < .max {
        self.currentFrame += 1
      } else {
        self.currentFrame = 0
      }
      self.lastFrameUpdate = Date()
    }
    @discardableResult
    internal func createSingle<E>(entity: E) -> [EntityID] where E: Entity {
      var result: [EntityID] = []
      if let group = entity.underlyingGroup() {
        for v in group.values {
          guard let e = v.body as? any Entity else { continue }
          let modified = applyGroup(to: e, group: entity)
          result.append(contentsOf: self.createSingle(entity: modified))
        }
      } else {
        let entityID: EntityID = self.register(entity: entity)
        self.create(entityID)
        if let emitter = entity.underlyingEmitter(), let e = emitter.prototype.body as? any Entity {
          self.emitEntities[entityID] = self.createSingle(entity: e)
        }
        result.append(entityID)
      }
      return result
    }
    internal func viewPairs() -> [(AnyView, EntityID)] {
      var result: [(AnyView, EntityID)] = []
      for (id, view) in views {
        result.append((view, id))
      }
      return result
    }
    internal func memorySummary() -> String {
      var arr: [String] = []
      arr.append("\(systemSize.width)x\(systemSize.height) | \(currentFrame)")
      arr.append("\(entities.count) entities, \(views.count) views")
      arr.append("\(physicsProxies.count) physics, \(renderProxies.count) renders")
      return arr.joined(separator: "\n")
    }
    private func applyGroup<E>(to entity: E, group: any Entity) -> some Entity where E: Entity {
      let m = ModifiedEntity(entity: entity, onBirthPhysics: { c in
        group.onPhysicsBirth(c)
      }, onUpdatePhysics: { c in
        group.onPhysicsUpdate(c)
      }, onBirthRender: { c in
        group.onRenderBirth(c)
      }, onUpdateRender: { c in
        group.onRenderUpdate(c)
      })
      return m
    }
    @discardableResult
    private func create(_ id: EntityID, inherit: EntityID? = nil) -> ProxyID? {
      guard let entity = self.entities[id] else { return nil }
      var physics = PhysicsProxy(currentFrame: currentFrame)
      if entity is Emitter {
        physics.lifetime = .infinity
      }
      if let inherit, let parent: any Entity = entities[inherit] {
        let context = PhysicsProxy.Context(physics: physics, data: self)
        physics = parent.onPhysicsBirth(context)
      }
      let context = PhysicsProxy.Context(physics: physics, data: self)
      let newPhysics = entity.onPhysicsBirth(context)
      self.physicsProxies[nextProxyRegistry] = newPhysics
      if let _: AnyView = entity.viewToRegister() {
        let newRender = entity.onRenderBirth(.init(physics: newPhysics, render: RenderProxy(), data: self))
        let updateRender = entity.onRenderUpdate(.init(physics: newPhysics, render: RenderProxy(), data: self))
        if newRender != RenderProxy() || updateRender != RenderProxy() {
          self.renderProxies[nextProxyRegistry] = newRender
        }
      }
      self.proxyEntities[nextProxyRegistry] = id
      let proxyID = nextProxyRegistry
      nextProxyRegistry += 1
      return proxyID
    }
    private func register(entity: any Entity) -> EntityID {
      self.entities[nextEntityRegistry] = entity
      guard nextEntityRegistry < .max else {
        fatalError("For performance purposes, you may not have more than 256 entity variants.")
      }
      let id = nextEntityRegistry
      nextEntityRegistry += 1
      return id
    }
  }
}
