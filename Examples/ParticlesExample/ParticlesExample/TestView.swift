//
//  TestView.swift
//
//
//  Created by Ben Myers on 1/3/24.
//

import SwiftUI
import Foundation

struct TestView: View {
  
  var body: some View {
    ParticleSystem {
      Particle {
        Text("Hi")
      }
      .constantPosition(x: 225.0, y: 25.0)
    }
  }
}

//struct AnyTaggedView: Hashable, Identifiable {
//  
//  // MARK: - Properties
//  
//  var view: AnyView
//  var tag: UInt8
//  
//  var id: UInt8 { tag }
//  
//  // MARK: - Static Methods
//  
//  static func == (lhs: AnyTaggedView, rhs: AnyTaggedView) -> Bool {
//    return lhs.tag == rhs.tag
//  }
//  
//  // MARK: - Methods
//  
//  func hash(into hasher: inout Hasher) {
//    return tag.hash(into: &hasher)
//  }
//}

@resultBuilder public struct EntityBuilder {
  
  public static func buildExpression<E>(_ content: E) -> E where E: Entity {
    content
  }
  
  public static func buildBlock<E>(_ content: E) -> E where E: Entity {
    content
  }
  
  public static func buildBlock<E1, E2>(_ c1: E1, _ c2: E2) -> some Entity where E1: Entity, E2: Entity {
    TupleEntity(value: (c1, c2))
  }
  
  public static func buildBlock<E1, E2, E3>(_ c1: E1, _ c2: E2, _ c3: E3) -> some Entity where E1: Entity, E2: Entity, E3: Entity {
    TupleEntity(value: (c1, c2, c3))
  }
  
  public static func buildBlock<E1, E2, E3, E4>(
    _ c1: E1, _ c2: E2, _ c3: E3, _ c4: E4
  ) -> some Entity where E1: Entity, E2: Entity, E3: Entity, E4: Entity {
    TupleEntity(value: (c1, c2, c3, c4))
  }
}

public struct ParticleSystem: View {
  internal typealias EntityID = UInt8
  internal typealias ProxyID = UInt16
  var data: Self.Data
  public var body: some View {
    GeometryReader { proxy in
      TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { [self] t in
        Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: true, renderer: renderer) {
          Text("❌").tag("NOT_FOUND")
          ForEach(Array(data.viewPairs()), id: \.1) { (pair: (AnyView, EntityID)) in
            pair.0.tag(pair.1)
          }
        }
        .border(data.debug ? Color.red.opacity(0.5) : Color.clear)
        .overlay {
          HStack {
            VStack {
              debugView
              Spacer()
            }
            Spacer()
          }
        }
      }
    }
  }
  private var debugView: some View {
    VStack(alignment: .leading, spacing: 2.0) {
      Text("Frame \(data.currentFrame)")
      Text("\(1.0 / Date().timeIntervalSince(data.lastFrameUpdate), specifier: "%.1f") FPS")
      Text("\(data.stats.renderUpdatesLastFrame) render updates")
      Text("\(data.stats.physicsUpdatesLastFrame) physics updates")
      Text("\(data.nextProxyRegistry) proxies registered")
      Text("\(data.nextEntityRegistry) entities registered")
    }
    .font(.caption)
    .opacity(0.5)
  }
  init<E>(@EntityBuilder entity: () -> E) where E: Entity {
    let e: E = entity()
    self.data = .init()
    if let tuple = e as? TupleEntity<(any Entity)> {
      self.data.createSingle(entity: tuple.value)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity)> {
      self.data.createSingle(entity: tuple.value.0)
      self.data.createSingle(entity: tuple.value.1)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity, any Entity)> {
      self.data.createSingle(entity: tuple.value.0)
      self.data.createSingle(entity: tuple.value.1)
      self.data.createSingle(entity: tuple.value.2)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity, any Entity, any Entity)> {
      self.data.createSingle(entity: tuple.value.0)
      self.data.createSingle(entity: tuple.value.1)
      self.data.createSingle(entity: tuple.value.2)
      self.data.createSingle(entity: tuple.value.3)
    } else {
      self.data.createSingle(entity: e)
    }
  }
  func renderer(_ context: inout GraphicsContext, size: CGSize) {
    self.data.systemSize = size
    data.updatePhysics()
    data.updateRenders()
    data.advanceFrame()
    data.performRenders(&context)
  }
  class Stats {
    internal var renderUpdatesLastFrame: UInt16 = .zero
    internal var physicsUpdatesLastFrame: UInt16 = .zero
    init() {}
  }
  class Data {
    public internal(set) var systemSize: CGSize = .zero
    internal private(set) var currentFrame: UInt16 = .zero
    internal private(set) var lastFrameUpdate: Date = .distantPast
    internal var debug: Bool = true
    internal var stats: Stats = .init()
    private var entities: [EntityID: any Entity] = [:]
    private var views: [EntityID: AnyView] = .init()
    private var physicsProxies: [ProxyID: PhysicsProxy] = [:]
    private var renderProxies: [ProxyID: RenderProxy] = [:]
    private var proxyEntities: [ProxyID: EntityID] = [:]
    internal private(set) var nextEntityRegistry: EntityID = .zero
    internal private(set) var nextProxyRegistry: ProxyID = .zero
    init() {}
    internal func updatePhysics() {
      let proxyIDs = physicsProxies.keys
      for proxyID in proxyIDs {
        guard let proxy: PhysicsProxy = physicsProxies[proxyID] else { continue }
        let deathFrame: Int = Int(Double(proxy.inception) + proxy.lifetime * 60.0)
        print("\(currentFrame)/\(deathFrame)")
        if Int(currentFrame) >= deathFrame {
          physicsProxies[proxyID] = nil
          renderProxies[proxyID] = nil
        }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        guard let entity: any Entity = entities[entityID] else { continue }
        let context = PhysicsProxy.Context(physics: proxy, data: self)
        let newPhysics = entity.onPhysicsUpdate(context)
        physicsProxies[proxyID] = newPhysics
        stats.physicsUpdatesLastFrame += 1
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
        stats.renderUpdatesLastFrame += 1
      }
    }
    internal func performRenders(_ context: inout GraphicsContext) {
      for proxyID in physicsProxies.keys {
        guard let render: RenderProxy = renderProxies[proxyID] else { continue }
        guard let physics: PhysicsProxy = physicsProxies[proxyID] else { continue }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        if views[entityID] == nil {
          guard let entity: any Entity = entities[entityID] else { continue }
          guard let view: AnyView = entity.viewToRegister() else { continue }
          views[entityID] = view
        }
        guard
          physics.position.x > -10.0,
          physics.position.x < systemSize.width + 10.0,
          physics.position.y > -10.0,
          physics.position.y < systemSize.height + 10.0
        else { return }
        context.drawLayer { context in
          context.opacity = render.opacity
          if !render.hueRotation.degrees.isZero {
            context.addFilter(.hueRotation(render.hueRotation))
          }
          context.translateBy(x: physics.position.x, y: physics.position.y)
          context.rotate(by: physics.rotation)
          if render.scale.width != 1.0 || render.scale.height != 1.0 {
            context.scaleBy(x: render.scale.width, y: render.scale.height)
          }
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
    internal func createSingle(entity: any Entity) {
      let entityID: EntityID = self.register(entity: entity)
      self.create(entityID)
    }
    internal func viewPairs() -> [(AnyView, EntityID)] {
      var result: [(AnyView, EntityID)] = []
      for (id, view) in views {
        result.append((view, id))
      }
      return result
    }
    private func create(_ id: EntityID) {
      guard let entity = self.entities[id] else { return }
      self.physicsProxies[nextProxyRegistry] = PhysicsProxy(currentFrame: currentFrame)
      if let view: AnyView = entity.viewToRegister() {
        self.renderProxies[nextProxyRegistry] = RenderProxy()
      }
      self.proxyEntities[nextProxyRegistry] = id
      nextProxyRegistry += 1
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

extension Never: Entity {}

public protocol Entity {
  var body: Self.Body { get }
  associatedtype Body: Entity
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy
}

extension Entity {
  func viewToRegister() -> AnyView? {
    if let particle = self as? Particle {
      return particle.view
    } else {
      return body.viewToRegister()
    }
  }
  public func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy { return context.physics }
  public func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy { return context.physics }
  public func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy { return context.render }
}

public struct EmptyEntity: Entity {
  public var body: Never
  public typealias Body = Never
}

public struct AnyEntity {
  public var body: Any
  public typealias Body = Any
  init<T>(body: T) where T: Entity {
    self.body = body
  }
}

public struct TupleEntity<T>: Entity {
  public typealias Body = Never
  public var body: Never { .transferRepresentation }
  var value: T
  public init(value: T) {
    self.value = value
  }
}

public struct Particle: Entity {
  public typealias Body = Never
  public var body: Never { .transferRepresentation }
  internal var view: AnyView
  public init<V>(@ViewBuilder view: () -> V) where V: View {
    self.view = .init(view())
  }
}

@available(macOS 14.0.0, *)
public struct Emitter<E> where E: Entity {
  private var prototype: E
  public init(@EntityBuilder emits: () -> E) {
    self.prototype = emits()
  }
}

public struct PhysicsProxy {
  typealias C = Context
  private var _x: UInt16
  private var _y: UInt16
  private var _velX: Float16
  private var _velY: Float16
  private var _accX: Float16
  private var _accY: Float16
  private var _rotation: UInt8
  private var _torque: Int8
  private var _inception: UInt16
  private var _lifetime: Float16
  init(currentFrame: UInt16) {
    _x = .zero
    _y = .zero
    _velX = .zero
    _velY = .zero
    _accX = .zero
    _accY = .zero
    _rotation = .zero
    _torque = .zero
    _inception = currentFrame
    _lifetime = 5.0
  }
  public struct Context {
    var physics: PhysicsProxy
    weak var data: ParticleSystem.Data?
    init(physics: PhysicsProxy, data: ParticleSystem.Data) {
      self.physics = physics
      self.data = data
    }
  }
}

public extension PhysicsProxy {
  var position: CGPoint { get {
    CGPoint(x: CGFloat(_x * 10), y: CGFloat(_y * 10))
  } set {
    _x = UInt16(newValue.x / 10.0)
    _y = UInt16(newValue.y / 10.0)
  }}
  var velocity: CGVector { get {
    CGVector(dx: CGFloat(_velX), dy: CGFloat(_velY))
  } set {
    _velX = Float16(newValue.dx)
    _velY = Float16(newValue.dy)
  }}
  var acceleration: CGVector { get {
    CGVector(dx: CGFloat(_accX), dy: CGFloat(_accY))
  } set {
    _accX = Float16(newValue.dx)
    _accY = Float16(newValue.dy)
  }}
  var rotation: Angle { get {
    Angle(degrees: Double(_rotation) * 1.41176)
  } set {
    _rotation = UInt8(floor((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
  }}
  var torque: Angle { get {
    Angle(degrees: Double(_torque) * 1.41176)
  } set {
    _torque = Int8(floor((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
  }}
  var inception: Int {
    Int(_inception)
  }
  var lifetime: Double { get {
    Double(_lifetime)
  } set {
    _lifetime = Float16(newValue)
  }}
}

public struct RenderProxy {
  typealias C = Context
  private var _opacity: UInt8
  private var _hueRotation: UInt8
  private var _blur: UInt8
  private var _scaleX: Float16
  private var _scaleY: Float16
  init() {
    self._opacity = .max
    self._hueRotation = .zero
    self._blur = .zero
    self._scaleX = 1
    self._scaleY = 1
  }
  public struct Context {
    var physics: PhysicsProxy
    var render: RenderProxy
    weak var data: ParticleSystem.Data?
    init(physics: PhysicsProxy, render: RenderProxy, data: ParticleSystem.Data) {
      self.physics = physics
      self.render = render
      self.data = data
    }
  }
}

public extension RenderProxy {
  var opacity: Double { get {
    Double(_opacity) / Double(UInt8.max)
  } set {
    _opacity = UInt8(clamping: Int(newValue * Double(UInt8.max)))
  }}
  var hueRotation: Angle { get {
    Angle(degrees: Double(_hueRotation) * 1.41176)
  } set {
    _hueRotation = UInt8(floor((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
  }}
  var blur: CGFloat { get {
    CGFloat(_blur) * 3.0
  } set {
    _blur = UInt8(clamping: Int(newValue / 3))
  }}
  var scale: CGSize { get {
    CGSize(width: CGFloat(_scaleX), height: CGFloat(_scaleY))
  } set {
    _scaleX = Float16(newValue.width)
    _scaleY = Float16(newValue.height)
  }}
}

internal struct PhysicsModifiedEntity<E>: Entity where E: Entity {
  private var birth: (PhysicsProxy.Context) -> PhysicsProxy
  private var update: (PhysicsProxy.Context) -> PhysicsProxy
  var body: E
  init(
    entity: E,
    onBirth: @escaping (PhysicsProxy.Context) -> PhysicsProxy = { p in return p.physics },
    onUpdate: @escaping (PhysicsProxy.Context) -> PhysicsProxy = { p in return p.physics }
  ) {
    self.body = entity
    self.birth = onBirth
    self.update = onUpdate
  }
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    let proxy = body.onPhysicsBirth(context)
    guard let data = context.data else { return proxy }
    let newContext: PhysicsProxy.Context = .init(physics: proxy, data: data)
    return birth(newContext)
  }
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    let proxy = body.onPhysicsUpdate(context)
    guard let data = context.data else { return proxy }
    let newContext: PhysicsProxy.Context = .init(physics: proxy, data: data)
    return update(newContext)
  }
}

internal struct RenderModifiedEntity<E>: Entity where E: Entity {
  private var update: (RenderProxy.Context) -> RenderProxy
  internal var body: E
  init(entity: E, onUpdate: @escaping (RenderProxy.Context) -> RenderProxy) {
    self.body = entity
    self.update = onUpdate
  }
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    let proxy = body.onRenderUpdate(context)
    guard let data = context.data else { return proxy }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: proxy, data: data)
    return update(newContext)
  }
}

public extension Entity {
  func initialPosition(x: CGFloat?, y: CGFloat?) -> some Entity {
    PhysicsModifiedEntity(entity: self, onBirth: { context in
      var p = context.physics
      if let x {
        p.position.x = x
      }
      if let y {
        p.position.y = y
      }
      return p
    })
  }
  func constantPosition(x: CGFloat?, y: CGFloat?) -> some Entity {
    PhysicsModifiedEntity(entity: self, onUpdate: { context in
      var p = context.physics
      if let x {
        p.position.x = x
      }
      if let y {
        p.position.y = y
      }
      return p
    })
  }
}
