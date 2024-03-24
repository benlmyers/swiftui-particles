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
    public private(set) var currentFrame: UInt = .zero
    /// The date of the last frame update in the ``ParticleSystem``.
    public private(set) var lastFrameUpdate: Date = .distantPast
    
    internal var initialEntity: (any Entity)?
    internal var nextEntityRegistry: EntityID = .zero
    internal var refreshViews: Bool = false
    internal private(set) var fps: Double = .zero
    internal private(set) var nextProxyRegistry: ProxyID = .zero
    
    private var inception: Date = Date()
    private var last60: Date = .distantPast
    private var updateRenderTime: TimeInterval = .zero
    private var updatePhysicsTime: TimeInterval = .zero
    private var performRenderTime: TimeInterval = .zero
    
    private var entities: [EntityID: FlatEntity] = [:]
    // ID of entity -> View to render
    private var views: [EntityID: MaybeView] = .init()
    // ID of proxy -> Physics data
    private var physicsProxies: [ProxyID: PhysicsProxy] = [:]
    // ID of proxy -> Render data
    private var renderProxies: [ProxyID: RenderProxy] = [:]
    // ID of proxy -> ID of entity containing data behaviors
    private var proxyEntities: [ProxyID: EntityID] = [:]
    // ID of emitter proxy -> Frame such proxy last emitted a child
    private var lastEmitted: [ProxyID: UInt] = [:]
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
//      guard currentFrame > 1 else { return }
//      let proxyIDs = physicsProxies.keys
//      for proxyID in proxyIDs {
//        guard let proxy: PhysicsProxy = physicsProxies[proxyID] else { continue }
//        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
//        guard let entity: any Entity = entities[entityID] else { continue }
//        guard let emitter = entity.underlyingEmitter() else { continue }
//        guard let protoEntities: [EntityID] = emitEntities[entityID] else { continue }
//        if let emitted: UInt = lastEmitted[proxyID] {
//          let emitAt: UInt = emitted + UInt(emitter.emitInterval * 60.0)
//          guard currentFrame >= emitAt else { continue }
//        }
//        var finalEntities: [EntityID] = protoEntities
//        if let chooser = emitter.emitChooser, !protoEntities.isEmpty {
//          let context = PhysicsProxy.Context(physics: proxy, system: self)
//          finalEntities = [protoEntities[chooser(context) % protoEntities.count]]
//        }
//        for protoEntity in finalEntities {
//          guard let _: ProxyID = self.create(protoEntity, inherit: proxy) else { continue }
//          self.lastEmitted[proxyID] = currentFrame
//        }
//      }
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
          continue
        }
      }
    }
    
    internal func updatePhysics() {
      let flag = Date()
      let group = DispatchGroup()
      let queue = DispatchQueue(label: "com.benmyers.particles.physics.update", qos: .userInteractive, attributes: .concurrent)
      var newPhysicsProxies: [ProxyID: PhysicsProxy] = [:]
      let lock = NSLock()
      for (proxyID, entityID) in proxyEntities {
        group.enter()
        queue.async(group: group) { [weak self] in
          guard let self else {
            group.leave()
            return
          }
          guard let proxy: PhysicsProxy = physicsProxies[proxyID] else {
            group.leave()
            return
          }
          guard let entity: FlatEntity = entities[entityID] else {
            group.leave()
            return
          }
          let context = PhysicsProxy.Context(physics: proxy, system: self)
          let newPhysics = entity.onPhysicsUpdate(context)
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
      self.updatePhysicsTime = Date().timeIntervalSince(flag)
    }
    
    internal func updateRenders() {
      if fps < 45 {
        guard currentFrame % 10 == 0 else { return }
      }
      let flag = Date()
      let group = DispatchGroup()
      let queue = DispatchQueue(label: "com.benmyers.particles.renders.update", attributes: .concurrent)
      var newRenderProxies: [ProxyID: RenderProxy] = [:]
      let lock = NSLock()
      for (proxyID, entityID) in proxyEntities {
        group.enter()
        queue.async(group: group) { [weak self] in
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
          guard let entity: FlatEntity = entities[entityID] else {
            group.leave()
            return
          }
          let context = RenderProxy.Context(physics: physicsProxy, render: renderProxy, system: self)
          let newRender = entity.onRenderUpdate(context)
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
      self.updateRenderTime = Date().timeIntervalSince(flag)
    }
    
    internal func performRenders(_ context: inout GraphicsContext) {
      let flag = Date()
      context.drawLayer { context in
        for proxyID in physicsProxies.keys {
          let render: RenderProxy? = renderProxies[proxyID]
          guard let physics: PhysicsProxy = physicsProxies[proxyID] else { continue }
          guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
          guard let entity: FlatEntity = entities[entityID] else { continue }
          var resolvedEntityID: EntityID = entityID
          if let maybe = views[entityID] {
            switch maybe {
            case .merged(let mergedID): resolvedEntityID = mergedID
            case .some(_): 
              if refreshViews {
                guard let view: AnyView = entity.view else { break }
                views[entityID] = .some(view)
              }
              break
            }
          } else {
            guard let view: AnyView = entity.view else { break }
            views[entityID] = .some(view)
          }
          guard
            physics.position.x > -20.0,
            physics.position.x < size.width + 20.0,
            physics.position.y > -20.0,
            physics.position.y < size.height + 20.0,
            currentFrame > physics.inception
          else { continue }
          context.opacity = 1.0
          context.blendMode = .normal
          if let render {
            context.blendMode = render.blendMode
            context.opacity = render.opacity
          }
          context.drawLayer { context in
            context.translateBy(x: physics.position.x, y: physics.position.y)
            context.rotate(by: physics.rotation)
//            if let (color, radius) = entity.underlying(GlowEntity.self) {
//              context.addFilter(.shadow(color: color, radius: radius, x: 0.0, y: 0.0, blendMode: .normal, options: .shadowAbove))
//            }
//            if let overlay: Color = entity.underlyingColorOverlay() {
//              var m: ColorMatrix = ColorMatrix()
//              m.r1 = 0
//              m.g2 = 0
//              m.b3 = 0
//              m.a4 = 1
//              m.r5 = 1
//              m.g5 = 1
//              m.b5 = 1
//              context.addFilter(.colorMultiply(overlay))
//              context.addFilter(.colorMatrix(m))
//              context.addFilter(.colorMultiply(overlay))
//            }
            if let render {
              context.scaleBy(x: render.scale.width, y: render.scale.height)
              context.addFilter(.hueRotation(render.hueRotation))
              context.addFilter(.blur(radius: render.blur))
            }
//            let transitions = entity.underlyingTransitions()
//            if !transitions.isEmpty {
//              let c = PhysicsProxy.Context(physics: physics, system: self)
//              // (transition, bounds, duration)
//              for t in transitions {
//                let transition: AnyTransition = t.0
//                let bounds: TransitionBounds = t.1
//                let duration: Double = t.2
//                guard c.timeAlive < duration || c.timeAlive > physics.lifetime - duration else { continue }
//                transition.modifyRender(
//                  getTransitionProgress(bounds: bounds, duration: duration, context: c),
//                  c,
//                  &context
//                )
//              }
//            }
//            if debug, let _ = entity.underlyingEmitter() {
//              context.fill(.init(ellipseIn: .init(origin: .zero, size: .init(width: 10, height: 10))), with: .color(.red))
//            }
            guard let resolved = context.resolveSymbol(id: resolvedEntityID) else {
              return
            }
            
            context.draw(resolved, at: .zero)
            self.performRenderTime = Date().timeIntervalSince(flag)
          }
        }
      }
      refreshViews = false
    }
    
    internal func advanceFrame() {
      if self.currentFrame > .max - 1000 {
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
    internal func createSingle<E>(entity: E, spawn: Bool = true, mergingView: EntityID? = nil) -> [(EntityID, ProxyID?)] where E: Entity {
      var result: [(EntityID, ProxyID?)] = []
      var proxyID: ProxyID?
//      if let group = entity.underlyingGroup() {
//        var firstEntityID: EntityID?
//        for v in group.values {
//          guard let e = v.body as? any Entity else { continue }
//          var modified = e
//          if group.appliesModifiers {
//            modified = applyGroupModifiers(to: e, groupRoot: entity)
//          }
//          // Merge view
//          var mergingViewParameter: EntityID?
//          if let merges: Group.Merges = group.merges, merges == .views {
//            mergingViewParameter = firstEntityID
//          }
//          let new: [(EntityID, ProxyID?)] = self.createSingle(entity: modified, spawn: spawn, mergingView: mergingViewParameter)
//          // Merge entity
//          if let firstEntityID, let merges: Group.Merges = group.merges, merges == .entities
//          {
//            for n in new {
//              unregister(entityID: n.0)
//              if let proxyID = n.1 {
//                proxyEntities[proxyID] = firstEntityID
//              }
//            }
//          }
//          result.append(contentsOf: new)
//          if firstEntityID == nil {
//            firstEntityID = new.first?.0
//          }
//        }
//      } else {
      let entityID: EntityID = self.register(entity: .init(entity))
      if let mergingView: EntityID {
        self.views[entityID] = .merged(mergingView)
      }
      if spawn {
        proxyID = self.create(entityID)
      }
//        if let emitter = entity.underlyingEmitter(), let e = emitter.prototype.body as? any Entity {
//          self.emitEntities[entityID] = self.createSingle(entity: e, spawn: false).map({ $0.0 })
//        }
      result.append((entityID, proxyID))
//      }
      return result
    }
    
    internal func viewPairs() -> [(AnyView, EntityID)] {
      var result: [(AnyView, EntityID)] = []
      for (id, maybe) in views {
        if case MaybeView.some(let view) = maybe {
          result.append((view, id))
        }
      }
      return result
    }
    
    internal func memorySummary(advanced: Bool = true) -> String {
      var arr: [String] = []
      arr.append("\(Int(size.width)) x \(Int(size.height)) \t Frame \(currentFrame) \t \(Int(fps)) FPS")
      arr.append("Proxies: \(physicsProxies.count) physics \t(\(String(format: "%.1f", updatePhysicsTime * 1000))ms) \t\(renderProxies.count) renders \t(\(String(format: "%.1f", updateRenderTime * 1000))ms)")
      arr.append("System: \(entities.count) entities \t \(views.filter({ $0.value.isSome }).count) views \t Rendering: \(String(format: "%.1f", performRenderTime * 1000))ms")
      if advanced {
        arr.append("PE=\(proxyEntities.count), LE=\(lastEmitted.count), EE=\(emitEntities.count), EG=\(entityGroups.count)")
      }
      return arr.joined(separator: "\n")
    }
    
    private func applyGroupModifiers<E>(to entity: E, groupRoot: any Entity) -> some Entity where E: Entity {
//      let m = ModifiedEntity(entity: entity, onBirthPhysics: { c in
//        groupRoot._onPhysicsBirth(c)
//      }, onUpdatePhysics: { c in
//        groupRoot._onPhysicsUpdate(c)
//      }, onBirthRender: { c in
//        groupRoot._onRenderBirth(c)
//      }, onUpdateRender: { c in
//        groupRoot._onRenderUpdate(c)
//      })
//      return m
      return entity
    }
    
    @discardableResult
    private func create(_ id: EntityID, inherit: PhysicsProxy? = nil) -> ProxyID? {
      guard let entity: FlatEntity = self.entities[id] else { return nil }
      var physics = PhysicsProxy(currentFrame: currentFrame)
      if let inherit {
        physics.position = inherit.position
        physics.rotation = inherit.rotation
        physics.velocity = inherit.velocity
      }
//      if let _ = entity.underlyingEmitter() {
//        physics.lifetime = .infinity
//      }
      let context = PhysicsProxy.Context(physics: physics, system: self)
      let newPhysics = entity.onPhysicsBirth(context)
      self.physicsProxies[nextProxyRegistry] = newPhysics
      if let _: AnyView = entity.view {
        let newRender = entity.onRenderBirth(.init(physics: newPhysics, render: RenderProxy(), system: self))
        let updateRender = entity.onRenderUpdate(.init(physics: newPhysics, render: RenderProxy(), system: self))
        if newRender != RenderProxy() || updateRender != RenderProxy() {
          self.renderProxies[nextProxyRegistry] = newRender
        }
      }
      self.proxyEntities[nextProxyRegistry] = id
      let proxyID = nextProxyRegistry
      nextProxyRegistry += 1
      return proxyID
    }
    
    private func register(entity: FlatEntity) -> EntityID {
      self.entities[nextEntityRegistry] = entity
      let id = nextEntityRegistry
      nextEntityRegistry += 1
      return id
    }
    
    private func unregister(entityID: EntityID) {
      self.entities.removeValue(forKey: entityID)
    }
    
    private func getTransitionProgress(bounds: TransitionBounds, duration: TimeInterval, context: PhysicsProxy.Context) -> Double {
      switch bounds {
      case .birth:
        return 1 - min(max(context.timeAlive / duration, 0.0), 1.0)
      case .death:
        return min(max((context.timeAlive - context.physics.lifetime + duration) / duration, 0.0), 1.0)
      case .birthAndDeath:
        if context.timeAlive < context.physics.lifetime / 2.0 {
          return getTransitionProgress(bounds: .birth, duration: duration, context: context)
        } else {
          return getTransitionProgress(bounds: .death, duration: duration, context: context)
        }
      }
    }
    
    // MARK: - Subtypes
    
    private enum MaybeView {
      case some(AnyView)
      case merged(EntityID)
      var isSome: Bool {
        switch self {
        case .some(_):
          return true
        case .merged(_):
          return false
        }
      }
    }
  }
}
