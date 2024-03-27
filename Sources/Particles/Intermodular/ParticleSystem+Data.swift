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
    
    // ID of entity -> Flattened entity
    private var entities: [EntityID: FlatEntity] = [:]
    // ID of entity -> View to render
    private var views: [EntityID: MaybeView] = .init()
    // ID of proxy -> Physics data
    private var proxies: [ProxyID: Proxy] = [:]
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
      return proxies.count
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
      let proxyIDs = proxies.keys
      for proxyID in proxyIDs {
        guard let proxy: Proxy = proxies[proxyID] else { continue }
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
          let context = Proxy.Context(proxy: proxy, system: self)
          finalEntities = [protoEntities[chooser(context) % protoEntities.count]]
        }
        for protoEntity in finalEntities {
          guard let _: ProxyID = self.createProxy(protoEntity, inherit: proxy) else { continue }
          self.lastEmitted[proxyID] = currentFrame
        }
      }
    }
    
    internal func destroyExpiredEntities() {
      let proxyIDs = proxies.keys
      for proxyID in proxyIDs {
        guard let proxy: Proxy = proxies[proxyID] else { continue }
        var deathFrame: Int = .max
        if proxy.lifetime < .infinity {
          deathFrame = Int(Double(proxy.inception) + proxy.lifetime * 60.0)
        }
        if Int(currentFrame) >= deathFrame {
          proxies.removeValue(forKey: proxyID)
          proxies.removeValue(forKey: proxyID)
          proxyEntities.removeValue(forKey: proxyID)
          continue
        }
      }
    }
    
    internal func updateProxies() {
      let flag = Date()
      let group = DispatchGroup()
      let queue = DispatchQueue(label: "com.benmyers.particles.proxy.update", qos: .userInteractive, attributes: .concurrent)
      var newProxies: [ProxyID: Proxy] = [:]
      let lock = NSLock()
      for (proxyID, entityID) in proxyEntities {
        group.enter()
        queue.async(group: group) { [weak self] in
          guard let self else {
            group.leave()
            return
          }
          guard let proxy: Proxy = proxies[proxyID] else {
            group.leave()
            return
          }
          guard let entity: FlatEntity = entities[entityID] else {
            group.leave()
            return
          }
          let context = Proxy.Context(proxy: proxy, system: self)
          var new: Proxy = entity.onUpdate(context)
          new.velocity.dx += new.acceleration.dx
          new.velocity.dy += new.acceleration.dy
          new.position.x += new.velocity.dx
          new.position.y += new.velocity.dy
          new.rotation.degrees += new.torque.degrees
          lock.lock()
          newProxies[proxyID] = new
          lock.unlock()
          group.leave()
        }
      }
      group.wait()
      for (proxyID, newProxy) in newProxies {
        proxies[proxyID] = newProxy
      }
      self.updateTime = Date().timeIntervalSince(flag)
    }
    
    internal func performRenders(_ context: GraphicsContext) {
      
      let flag = Date()
      
      for proxyID in proxies.keys {
        // Initial checks
        guard
          let proxy: Proxy = proxies[proxyID],
          let entityID: EntityID = proxyEntities[proxyID],
          let entity: FlatEntity = entities[entityID]
        else {
          continue
        }
        // Resolve the view
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
          guard let view: AnyView = (entity.root as? Particle)?.view else {
            continue
          }
          views[entityID] = .some(view)
        }
        guard let resolved: GraphicsContext.ResolvedSymbol = context.resolveSymbol(id: resolvedEntityID) else {
          continue
        }
        // Ensure position in system bounds
        guard
          proxy.position.x > -resolved.size.width,
          proxy.position.x < self.size.width + resolved.size.width,
          proxy.position.y > -resolved.size.height,
          proxy.position.y < self.size.height + resolved.size.height,
          self.currentFrame > proxy.inception
        else {
          continue
        }
        var cc: GraphicsContext = context
        // Apply proxy
        cc.opacity = proxy.opacity
        cc.blendMode = proxy.blendMode
        cc.drawLayer { cc in
          cc.translateBy(x: proxy.position.x, y: proxy.position.y)
          cc.rotate(by: proxy.rotation)
#if !os(watchOS)
          if proxy.rotation3d != .zero {
            var transform = CATransform3DIdentity
            transform = CATransform3DRotate(transform, proxy.rotation3d.x, 1, 0, 0)
            transform = CATransform3DRotate(transform, proxy.rotation3d.y, 0, 1, 0)
            transform = CATransform3DRotate(transform, proxy.rotation3d.z, 0, 0, 1)
            cc.addFilter(.projectionTransform(ProjectionTransform(transform)))
          }
#endif
          cc.scaleBy(x: proxy.scale.width, y: proxy.scale.height)
          cc.addFilter(.hueRotation(proxy.hueRotation))
          cc.addFilter(.blur(radius: proxy.blur))
          
          for preference in entity.preferences {
            if case .custom(let custom) = preference {
              if case .glow(let color, let radius) = custom {
                cc.addFilter(.shadow(color: color, radius: radius, x: 0.0, y: 0.0, blendMode: .normal, options: .shadowAbove))
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
                cc.addFilter(.colorMultiply(overlay))
                cc.addFilter(.colorMatrix(m))
                cc.addFilter(.colorMultiply(overlay))
              } else if case .transition(let transition, let bounds, let duration) = custom {
                let c = Proxy.Context(proxy: proxy, system: self)
                if bounds == .birth || bounds == .birthAndDeath {
                  guard c.timeAlive < duration else { continue }
                }
                if bounds == .death || bounds == .birthAndDeath {
                  guard c.timeAlive > proxy.lifetime - duration else { continue }
                }
                transition.modifyRender(
                  getTransitionProgress(bounds: bounds, duration: duration, context: c),
                  c,
                  &cc
                )
              }
            }
          }
          cc.draw(resolved, at: .zero)
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
    
    internal func performanceSummary(advanced: Bool = false) -> String {
      var arr: [String] = []
      arr.append("\(Int(size.width)) x \(Int(size.height)) \t Frame \(currentFrame) \t \(Int(fps)) FPS")
      arr.append("Proxies: \(proxies.count) physics \t(\(String(format: "%.1f", updateTime * 1000))ms)")
      arr.append("System: \(entities.count) entities \t \(views.filter({ $0.value.isSome }).count) views \t Rendering: \(String(format: "%.1f", performRenderTime * 1000))ms")
      if advanced {
        arr.append("PE=\(proxyEntities.count), LE=\(lastEmitted.count), EE=\(emitEntities.count), EG=\(entityGroups.count)")
      }
      return arr.joined(separator: "\n")
    }
    
    @discardableResult
    private func createProxy(_ id: EntityID, inherit: Proxy? = nil) -> ProxyID? {
      guard let entity: FlatEntity = self.entities[id] else { return nil }
      var physics = Proxy(currentFrame: currentFrame)
      if let inherit {
        physics.position = inherit.position
        physics.rotation = inherit.rotation
        physics.velocity = inherit.velocity
      }
      if entity.root is _Emitter {
        physics.lifetime = .infinity
      }
      let context = Proxy.Context(proxy: physics, system: self)
      let new = entity.onBirth(context)
      self.proxies[nextProxyRegistry] = new
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
    
    private func getTransitionProgress(bounds: TransitionBounds, duration: TimeInterval, context: Proxy.Context) -> Double {
      switch bounds {
      case .birth:
        return 1 - min(max(context.timeAlive / duration, 0.0), 1.0)
      case .death:
        return min(max((context.timeAlive - context.proxy.lifetime + duration) / duration, 0.0), 1.0)
      case .birthAndDeath:
        if context.timeAlive < context.proxy.lifetime / 2.0 {
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
