//
//  ParticleSystem+Data.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Dispatch
import Foundation
import CoreGraphics

public extension ParticleSystem {
  
  class Data {
    
    // MARK: - Stored Properties
    
    /// Whether this ``ParticleSystem`` is in debug mode.
    public internal(set) var debug: Bool = false
    /// The size of the ``ParticleSystem``, in pixels.
    public internal(set) var size: CGSize = .zero
    /// The current frame of the ``ParticleSystem``.
    public private(set) var currentFrame: Int = .zero
    /// The date of the last frame update in the ``ParticleSystem``.
    public private(set) var lastFrameUpdate: Date = .distantPast
    
    internal var initialEntity: (any Entity)?
    internal var nextEntityRegistry: EntityID = .zero
    internal private(set) var fps: Double = .zero
    internal private(set) var nextProxyRegistry: ProxyID = .zero
    
    private var inception: Date = Date()
    private var last60: Date = .distantPast
    
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
    private var lastEmitted: [ProxyID: Int] = [:]
    // ID of emitter entity -> Entity IDs to create children with
    private var emitEntities: [EntityID: [EntityID]] = [:]
    // ID of entity contained in Group -> Group entity top-level ID
    private var entityGroups: [EntityID: EntityID] = [:]
    
    // MARK: - Computed Properties
    
    /// The amount of time, in seconds, that has elapsed since the ``ParticleSystem`` was created.
    public var time: TimeInterval {
      return Date().timeIntervalSince(inception)
    }
    
    /// The total number of proxies alive.
    public var proxiesAlive: Int {
      return physicsProxies.count
    }
    
    /// The total number of proxies spawned in the simulation.
    public var proxiesSpawned: Int {
      return Int(nextProxyRegistry)
    }
    
    /// The average frame rate, in frames per second, of the system simulation.
    public var averageFrameRate: Double {
      return Double(currentFrame) / Date().timeIntervalSince(inception)
    }
    
    // MARK: - Initalizers
    
    init() {}
    
    // MARK: - Methods
    
    internal func emitChildren() {
      guard currentFrame > 1 else { return }
      let proxyIDs = physicsProxies.keys
      for proxyID in proxyIDs {
        guard let proxy: PhysicsProxy = physicsProxies[proxyID] else { continue }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        guard let entity: any Entity = entities[entityID] else { continue }
        guard let emitter = entity.underlyingEmitter() else { continue }
        guard let protoEntities: [EntityID] = emitEntities[entityID] else { continue }
        if let emitted: Int = lastEmitted[proxyID] {
          let emitAt: Int = emitted + Int(emitter.emitInterval * 60.0)
          guard currentFrame >= emitAt else { continue }
        }
        var finalEntities: [EntityID] = protoEntities
        if let chooser = emitter.emitChooser, !protoEntities.isEmpty {
          let context = PhysicsProxy.Context(physics: proxy, system: self)
          finalEntities = [protoEntities[chooser(context) % protoEntities.count]]
        }
        for protoEntity in finalEntities {
          guard let _: ProxyID = self.create(protoEntity, inherit: proxy) else { continue }
          self.lastEmitted[proxyID] = currentFrame
        }
      }
    }
    
    internal func destroyExpiredEntities() {
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
          return
        } else {
//          print("Still alive, remains \(deathFrame - Int(currentFrame))")
        }
      }
    }
    
    internal func updatePhysics() {
      let group = DispatchGroup()
      let queue = DispatchQueue(label: "com.benmyers.particles.physics.update", attributes: .concurrent)
      var newPhysicsProxies: [ProxyID: PhysicsProxy] = [:]
      let lock = NSLock()
      for (proxyID, entityID) in proxyEntities {
        group.enter()
        queue.async { [weak self] in
          guard let self else {
            group.leave()
            return
          }
          guard let proxy: PhysicsProxy = physicsProxies[proxyID] else {
            group.leave()
            return
          }
          guard let entity: any Entity = entities[entityID] else {
            group.leave()
            return
          }
          let context = PhysicsProxy.Context(physics: proxy, system: self)
          let newPhysics = entity._onPhysicsUpdate(context)
          lock.lock()
          newPhysicsProxies[proxyID] = newPhysics
          lock.unlock()
          group.leave()
        }
      }
      group.wait()
      for (proxyID, newPhysicsProxy) in newPhysicsProxies {
        physicsProxies[proxyID] = newPhysicsProxy
      }
    }
    
    internal func updateRenders() {
      if fps < 45 {
        guard currentFrame % 10 == 0 else { return }
      }
      let group = DispatchGroup()
      let queue = DispatchQueue(label: "com.benmyers.particles.renders.update", attributes: .concurrent)
      var newRenderProxies: [ProxyID: RenderProxy] = [:]
      let lock = NSLock()
      for (proxyID, entityID) in proxyEntities {
        group.enter()
        queue.async { [weak self] in
          guard let self else {
            group.leave()
            return
          }
          guard let renderProxy: RenderProxy = renderProxies[proxyID] else {
            group.leave()
            return
          }
          guard let physicsProxy: PhysicsProxy = physicsProxies[proxyID] else {
            group.leave()
            return
          }
          guard let entity: any Entity = entities[entityID] else {
            group.leave()
            return
          }
          let context = RenderProxy.Context(physics: physicsProxy, render: renderProxy, system: self)
          let newRender = entity._onRenderUpdate(context)
          lock.lock()
          newRenderProxies[proxyID] = newRender
          lock.unlock()
          group.leave()
        }
      }
      group.wait()
      for (proxyID, newRenderProxy) in newRenderProxies {
        renderProxies[proxyID] = newRenderProxy
      }
    }
    
    internal func performRenders(_ context: inout GraphicsContext) {
      context.drawLayer { context in
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
            physics.position.x < size.width + 20.0,
            physics.position.y > -20.0,
            physics.position.y < size.height + 20.0,
            currentFrame > physics.inception
          else { continue }
          if let render, render.blendMode != .normal {
            context.blendMode = render.blendMode
            
          }
          context.drawLayer { context in
            if let render {
              context.opacity = render.opacity
              if !render.hueRotation.degrees.isZero {
                context.addFilter(.hueRotation(render.hueRotation))
              }
              if !render.blur.isZero {
                context.addFilter(.blur(radius: render.blur))
              }
            }
            context.drawLayer { context in
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
      }
    }
    
    internal func advanceFrame() {
      if self.currentFrame > .max - 601 {
        self.currentFrame = 2
        for k in self.lastEmitted.keys {
          self.lastEmitted[k] = 0
        }
      } else {
        self.currentFrame += 1
      }
      self.lastFrameUpdate = Date()
      if self.currentFrame % 15 == 0 {
        let fps: Double = 15.0 / Date().timeIntervalSince(self.last60)
        self.fps = fps
        self.last60 = Date()
      }
    }
    
    @discardableResult
    internal func createSingle<E>(entity: E, spawn: Bool = true) -> [EntityID] where E: Entity {
      var result: [EntityID] = []
      if let group = entity.underlyingGroup() {
        for v in group.values {
          guard let e = v.body as? any Entity else { continue }
          let modified = applyGroup(to: e, group: entity)
          result.append(contentsOf: self.createSingle(entity: modified, spawn: spawn))
        }
      } else {
        let entityID: EntityID = self.register(entity: entity)
        if spawn {
          self.create(entityID)
        }
        if let emitter = entity.underlyingEmitter(), let e = emitter.prototype.body as? any Entity {
          self.emitEntities[entityID] = self.createSingle(entity: e, spawn: false)
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
      arr.append("\(Int(size.width)) x \(Int(size.height)) | Frame \(currentFrame) | \(Int(fps)) FPS")
      arr.append("Proxies: \(physicsProxies.count) physics, \(renderProxies.count) renders")
      arr.append("System: \(entities.count) entities, \(views.count) views")
      return arr.joined(separator: "\n")
    }
    
    private func applyGroup<E>(to entity: E, group: any Entity) -> some Entity where E: Entity {
      let m = ModifiedEntity(entity: entity, onBirthPhysics: { c in
        group._onPhysicsBirth(c)
      }, onUpdatePhysics: { c in
        group._onPhysicsUpdate(c)
      }, onBirthRender: { c in
        group._onRenderBirth(c)
      }, onUpdateRender: { c in
        group._onRenderUpdate(c)
      })
      return m
    }
    
    @discardableResult
    private func create(_ id: EntityID, inherit: PhysicsProxy? = nil) -> ProxyID? {
      guard let entity = self.entities[id] else { return nil }
      var physics = PhysicsProxy(currentFrame: currentFrame)
      if let inherit {
        physics.position = inherit.position
        physics.rotation = inherit.rotation
        physics.velocity = inherit.velocity
      }
      if let _ = entity.underlyingEmitter() {
        physics.lifetime = .infinity
      }
      let context = PhysicsProxy.Context(physics: physics, system: self)
      let newPhysics = entity._onPhysicsBirth(context)
      self.physicsProxies[nextProxyRegistry] = newPhysics
      if let _: AnyView = entity.viewToRegister() {
        let newRender = entity._onRenderBirth(.init(physics: newPhysics, render: RenderProxy(), system: self))
        let updateRender = entity._onRenderUpdate(.init(physics: newPhysics, render: RenderProxy(), system: self))
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
