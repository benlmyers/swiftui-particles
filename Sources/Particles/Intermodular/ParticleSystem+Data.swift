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
    private var updateTime: TimeInterval = .zero
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
      guard currentFrame > 1 else { return }
      let proxyIDs = physicsProxies.keys
      for proxyID in proxyIDs {
        guard let proxy: PhysicsProxy = physicsProxies[proxyID] else { continue }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        guard let entity: FlatEntity = entities[entityID] else { continue }
        guard let emitter = (entity.root as? _Emitter) else { continue }
        guard let protoEntities: [EntityID] = emitEntities[entityID] else { continue }
        if let emitted: UInt = lastEmitted[proxyID] {
          let emitAt: UInt = emitted + UInt(emitter.emitInterval * 60.0)
          guard currentFrame >= emitAt else { continue }
        }
        var finalEntities: [EntityID] = protoEntities
        if let chooser = emitter.emitChooser, !protoEntities.isEmpty {
          let context = PhysicsProxy.Context(physics: proxy, system: self)
          finalEntities = [protoEntities[chooser(context) % protoEntities.count]]
        }
        for protoEntity in finalEntities {
          guard let _: ProxyID = self.createProxy(protoEntity, inherit: proxy) else { continue }
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
          continue
        }
      }
    }
    
    internal func updatePhysicsAndRenders() {
      let flag = Date()
      let group = DispatchGroup()
      let queue = DispatchQueue(label: "com.benmyers.particles.physics.update", qos: .userInteractive, attributes: .concurrent)
      var newPhysicsProxies: [ProxyID: PhysicsProxy] = [:]
      var newRenderProxies: [ProxyID: RenderProxy] = [:]
      let lock = NSLock()
      for (proxyID, entityID) in proxyEntities {
        group.enter()
        queue.async(group: group) { [weak self] in
          guard let self else {
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
          let context = PhysicsProxy.Context(physics: physicsProxy, system: self)
          var newPhysics: PhysicsProxy = entity.onPhysicsUpdate(context)
          var newRender: RenderProxy?
          newPhysics.velocity.dx += newPhysics.acceleration.dx
          newPhysics.velocity.dy += newPhysics.acceleration.dy
          newPhysics.position.x += newPhysics.velocity.dx
          newPhysics.position.y += newPhysics.velocity.dy
          newPhysics.rotation.degrees += newPhysics.torque.degrees
          if let renderProxy: RenderProxy = renderProxies[proxyID] {
            let context = RenderProxy.Context(physics: newPhysics, render: renderProxy, system: self)
            newRender = entity.onRenderUpdate(context)
          }
          lock.lock()
          newPhysicsProxies[proxyID] = newPhysics
          if let newRender {
            newRenderProxies[proxyID] = newRender
          }
          lock.unlock()
          group.leave()
        }
      }
      group.wait()
      for (proxyID, newPhysicsProxy) in newPhysicsProxies {
        physicsProxies[proxyID] = newPhysicsProxy
      }
      for (proxyID, newRenderProxy) in newRenderProxies {
        renderProxies[proxyID] = newRenderProxy
      }
      self.updateTime = Date().timeIntervalSince(flag)
    }
    
    internal func performRenders(_ context: GraphicsContext) {
      for proxyID in physicsProxies.keys {
        context.drawLayer { context in
          let render: RenderProxy? = renderProxies[proxyID]
          guard let physics: PhysicsProxy = physicsProxies[proxyID] else { return }
          guard let entityID: EntityID = proxyEntities[proxyID] else { return }
          guard let entity: FlatEntity = entities[entityID] else { return }
          var resolvedEntityID: EntityID = entityID
          if let maybe = views[entityID] {
            switch maybe {
            case .merged(let mergedID): resolvedEntityID = mergedID
            case .some(_):
              if refreshViews {
                guard let view: AnyView = (entity.root as? Particle)?.view else { break }
                views[entityID] = .some(view)
              }
              break
            }
          } else {
            guard let view: AnyView = (entity.root as? Particle)?.view else { return }
            views[entityID] = .some(view)
          }
          guard let resolved = context.resolveSymbol(id: resolvedEntityID) else {
            return
          }
          guard
            physics.position.x > -resolved.size.width,
            physics.position.x < size.width + resolved.size.width,
            physics.position.y > -resolved.size.height,
            physics.position.y < size.height + resolved.size.height,
            currentFrame > physics.inception
          else { return }
          context.opacity = 1.0
          context.blendMode = .normal
          if let render {
            context.blendMode = render.blendMode
            context.opacity = render.opacity
          }
          context.drawLayer { context in
            context.translateBy(x: physics.position.x, y: physics.position.y)
            context.rotate(by: physics.rotation)
            if let render {
#if !os(watchOS)
              if render.rotation3d != .zero {
                var transform = CATransform3DIdentity
                transform = CATransform3DRotate(transform, render.rotation3d.x, 1, 0, 0)
                transform = CATransform3DRotate(transform, render.rotation3d.y, 0, 1, 0)
                transform = CATransform3DRotate(transform, render.rotation3d.z, 0, 0, 1)
                context.addFilter(.projectionTransform(ProjectionTransform(transform)))
              }
#endif
              context.scaleBy(x: render.scale.width, y: render.scale.height)
              context.addFilter(.hueRotation(render.hueRotation))
              context.addFilter(.blur(radius: render.blur))
            }
            for preference in entity.preferences {
              if case .custom(let custom) = preference {
                if case .glow(let color, let radius) = custom {
                  context.addFilter(.shadow(color: color, radius: radius, x: 0.0, y: 0.0, blendMode: .normal, options: .shadowAbove))
                }
                else if case .colorOverlay(let overlay) = custom {
                  var m: ColorMatrix = ColorMatrix()
                  m.r1 = 0
                  m.g2 = 0
                  m.b3 = 0
                  m.a4 = 1
                  m.r5 = 1
                  m.g5 = 1
                  m.b5 = 1
                  context.addFilter(.colorMultiply(overlay))
                  context.addFilter(.colorMatrix(m))
                  context.addFilter(.colorMultiply(overlay))
                } else if case .transition(let transition, let bounds, let duration) = custom {
                  let c = PhysicsProxy.Context(physics: physics, system: self)
                  if bounds == .birth || bounds == .birthAndDeath {
                    guard c.timeAlive < duration else { continue }
                  }
                  if bounds == .death || bounds == .birthAndDeath {
                    guard c.timeAlive > physics.lifetime - duration else { continue }
                  }
                  transition.modifyRender(
                    getTransitionProgress(bounds: bounds, duration: duration, context: c),
                    c,
                    &context
                  )
                }
              }
            }
            context.draw(resolved, at: .zero)
//            self.performRenderTime = Date().timeIntervalSince(flag)
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
    internal func create<E>(entity: E, spawn: Bool = true) -> [(EntityID, ProxyID?)] where E: Entity {
      guard !(entity is EmptyEntity) else { return [] }
      var result: [(EntityID, ProxyID?)] = []
      let (flatEntites, merges) = FlatEntity.make(entity)
      var firstID: EntityID?
      for flat in flatEntites {
        var proxyID: ProxyID?
        let entityID: EntityID = self.register(entity: flat)
        if spawn {
          proxyID = self.createProxy(entityID)
        }
        if let root = flat.root, root is _Emitter {
          self.emitEntities[entityID] = self.create(entity: root.body, spawn: false).map({ $0.0 })
        }
        if let merges: Group.Merges, let firstID: EntityID {
          switch merges {
          case .views:
            self.views[entityID] = .merged(firstID)
          case .entities:
            unregister(entityID: entityID)
            if let proxyID {
              proxyEntities[proxyID] = firstID
            }
          }
        }
        if firstID == nil {
          firstID = entityID
        }
        result.append((entityID, proxyID))
      }
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
      arr.append("Proxies: \(physicsProxies.count) physics \t(\(String(format: "%.1f", updateTime * 1000))ms)")
      arr.append("System: \(entities.count) entities \t \(views.filter({ $0.value.isSome }).count) views \t Rendering: \(String(format: "%.1f", performRenderTime * 1000))ms")
      if advanced {
        arr.append("PE=\(proxyEntities.count), LE=\(lastEmitted.count), EE=\(emitEntities.count), EG=\(entityGroups.count)")
      }
      return arr.joined(separator: "\n")
    }
    
    @discardableResult
    private func createProxy(_ id: EntityID, inherit: PhysicsProxy? = nil) -> ProxyID? {
      guard let entity: FlatEntity = self.entities[id] else { return nil }
      var physics = PhysicsProxy(currentFrame: currentFrame)
      if let inherit {
        physics.position = inherit.position
        physics.rotation = inherit.rotation
        physics.velocity = inherit.velocity
      }
      if entity.root is _Emitter {
        physics.lifetime = .infinity
      }
      let context = PhysicsProxy.Context(physics: physics, system: self)
      let newPhysics = entity.onPhysicsBirth(context)
      self.physicsProxies[nextProxyRegistry] = newPhysics
      if let _: AnyView = (entity.root as? Particle)?.view {
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
