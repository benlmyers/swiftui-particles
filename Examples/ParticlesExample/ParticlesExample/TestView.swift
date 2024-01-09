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
      MyCustomParticle(text: "A")
        .lifetime(1.0)
        .initialPosition(x: 200.0, y: 200.0)
      MyCustomParticle(text: "B")
        .lifetime(2.0)
        .initialPosition(x: 300.0, y: 200.0)
      Emitter(interval: 1.0) {
        MyCustomParticle(text: "C")
          .lifetime(3.0)
      }
      .initialPosition(x: 400.0, y: 200.0)
//      .initialVelocity(x: 0.2, y: nil)
    }
  }
}

struct MyCustomParticle: Entity {
  var text: String
  var body: some Entity {
    Particle {
      Text(text)
    }
    .constantVelocity(x: nil, y: 0.2)
    .constantTorque(.degrees(2.0))
  }
}

@resultBuilder public struct EntityBuilder {
  
  public static func buildExpression<E>(_ content: E) -> E where E: Entity {
    content
  }
  
  public static func buildBlock<E>(_ content: E) -> E where E: Entity {
    content
  }
  
  public static func buildBlock<E1, E2>(_ c1: E1, _ c2: E2) -> some Entity where E1: Entity, E2: Entity {
    TupleEntity(values: [.init(body: c1), .init(body: c2)])
  }
  
  public static func buildBlock<E1, E2, E3>(_ c1: E1, _ c2: E2, _ c3: E3) -> some Entity where E1: Entity, E2: Entity, E3: Entity {
    TupleEntity(values: [.init(body: c1), .init(body: c2), .init(body: c3)])
  }
  
  public static func buildBlock<E1, E2, E3, E4>(
    _ c1: E1, _ c2: E2, _ c3: E3, _ c4: E4
  ) -> some Entity where E1: Entity, E2: Entity, E3: Entity, E4: Entity {
    TupleEntity(values: [.init(body: c1), .init(body: c2), .init(body: c3), .init(body: c4)])
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
      Text("\(data.nextProxyRegistry) proxies registered")
      Text("\(data.nextEntityRegistry) entities registered")
    }
    .font(.caption)
    .opacity(0.5)
  }
  init<E>(@EntityBuilder entity: () -> E) where E: Entity {
    let e: E = entity()
    self.data = .init()
    if let tuple = e as? TupleEntity {
      for v in tuple.values {
        guard let e = v.body as? any Entity else { continue }
        self.data.createSingle(entity: e)
      }
    } else {
      self.data.createSingle(entity: e)
    }
  }
  func renderer(_ context: inout GraphicsContext, size: CGSize) {
    self.data.systemSize = size
    data.updatePhysics()
    data.updateRenders()
    data.advanceFrame()
    data.emitChildren()
    data.performRenders(&context)
  }
  class Data {
    public internal(set) var systemSize: CGSize = .zero
    internal private(set) var currentFrame: UInt16 = .zero
    internal private(set) var lastFrameUpdate: Date = .distantPast
    internal var debug: Bool = true
    private var entities: [EntityID: any Entity] = [:]
    private var views: [EntityID: AnyView] = .init()
    private var physicsProxies: [ProxyID: PhysicsProxy] = [:]
    private var renderProxies: [ProxyID: RenderProxy] = [:]
    private var proxyEntities: [ProxyID: EntityID] = [:]
    private var lastEmitted: [ProxyID: UInt16] = [:]
    private var emitEntities: [EntityID: [EntityID]] = [:]
    internal private(set) var nextEntityRegistry: EntityID = .zero
    internal private(set) var nextProxyRegistry: ProxyID = .zero
    init() {}
    internal func emitChildren() {
      let proxyIDs = physicsProxies.keys
      for proxyID in proxyIDs {
        guard let proxy: PhysicsProxy = physicsProxies[proxyID] else { continue }
        guard let entityID: EntityID = proxyEntities[proxyID] else { continue }
        guard let entity: any Entity = entities[entityID] else { continue }
        guard let emitter = entity.underlyingEmitter() else { continue }
        guard let protoEntities: [EntityID] = emitEntities[entityID] else { continue }
        if let emitted: UInt16 = lastEmitted[proxyID] {
          let emitAt: UInt16 = emitted + UInt16(emitter.emitInterval * 60.0)
          guard currentFrame >= emitAt else { continue }
        }
        for protoEntity in protoEntities {
          // Spawn the child proxy
          guard let childProxyID: ProxyID = self.create(protoEntity) else { continue }
          self.lastEmitted[proxyID] = currentFrame
          // Endow the child proxy with parent physics
          guard let childPhyics: PhysicsProxy = self.physicsProxies[childProxyID] else { continue }
          let context = PhysicsProxy.Context(physics: childPhyics, data: self)
          self.physicsProxies[childProxyID] = entity.onPhysicsBirth(context)
        }
      }
    }
    internal func updatePhysics() {
      let proxyIDs = physicsProxies.keys
      for proxyID in proxyIDs {
        guard let proxy: PhysicsProxy = physicsProxies[proxyID] else { continue }
        let deathFrame: Int = Int(Double(proxy.inception) + proxy.lifetime * 60.0)
        if Int(currentFrame) >= deathFrame {
          physicsProxies[proxyID] = nil
          renderProxies[proxyID] = nil
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
          if render.scale.width != 1.0 || render.scale.height != 1.0 {
            context.scaleBy(x: render.scale.width, y: render.scale.height)
          }
          context.translateBy(x: physics.position.x, y: physics.position.y)
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
    internal func createSingle(entity: any Entity) -> EntityID {
      let entityID: EntityID = self.register(entity: entity)
      self.create(entityID)
      if let emitter = entity.underlyingEmitter(), let e = emitter.prototype.body as? any Entity {
        if let tuple = e as? TupleEntity {
          var arr: [EntityID] = []
          for v in tuple.values {
            guard let e = v.body as? any Entity else { continue }
            let id = self.createSingle(entity: e)
            arr.append(id)
          }
          self.emitEntities[entityID] = arr
        } else {
          let id = self.createSingle(entity: e)
          self.emitEntities[entityID] = [id]
        }
      }
      return entityID
    }
    internal func viewPairs() -> [(AnyView, EntityID)] {
      var result: [(AnyView, EntityID)] = []
      for (id, view) in views {
        result.append((view, id))
      }
      return result
    }
    private func create(_ id: EntityID) -> ProxyID? {
      guard let entity = self.entities[id] else { return nil }
      let physics = PhysicsProxy(currentFrame: currentFrame)
      let context = PhysicsProxy.Context(physics: physics, data: self)
      let newPhysics = entity.onPhysicsBirth(context)
      self.physicsProxies[nextProxyRegistry] = newPhysics
      if let _: AnyView = entity.viewToRegister() {
        self.renderProxies[nextProxyRegistry] = RenderProxy()
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

extension Never: Entity {}

public protocol Entity {
  var body: Self.Body { get }
  associatedtype Body: Entity
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy
}

extension Entity {
  internal func viewToRegister() -> AnyView? {
    if let particle = self as? Particle {
      return particle.view
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.viewToRegister()
    }
  }
  internal func underlyingEmitter() -> Emitter? {
    if let emitter = self as? Emitter {
      return emitter
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingEmitter()
    }
  }
  public func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    if self is EmptyEntity {
      return context.physics
    } else {
      return body.onPhysicsBirth(context)
    }
  }
  public func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    var result: PhysicsProxy
    if self is EmptyEntity {
      result = context.physics
    } else {
      result = body.onPhysicsUpdate(context)
    }
    result.velocity.dx += result.acceleration.dx
    result.velocity.dy += result.acceleration.dy
    result.position.x += result.velocity.dx
    result.position.y += result.velocity.dy
    result.rotation.degrees += result.torque.degrees
    return result
  }
  public func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    if self is EmptyEntity {
      return context.render
    } else {
      return body.onRenderUpdate(context)
    }
  }
}

public struct EmptyEntity: Entity {
  public var body: Never { .transferRepresentation }
  public typealias Body = Never
}

public struct AnyEntity {
  public var body: Any
  public typealias Body = Any
  init<T>(body: T) where T: Entity {
    self.body = body
  }
}

public struct TupleEntity: Entity {
  public var body: EmptyEntity { .init() }
  var values: [AnyEntity]
  public init(values: [AnyEntity]) {
    self.values = values
  }
}

public struct Particle: Entity {
  public var body = EmptyEntity()
  internal var view: AnyView
  public init<V>(@ViewBuilder view: () -> V) where V: View {
    self.view = .init(view())
  }
}

public struct Emitter: Entity {
  public var body: EmptyEntity { .init() }
  internal private(set) var prototype: AnyEntity
  internal private(set) var emitInterval: TimeInterval
  public init<E>(interval: TimeInterval, @EntityBuilder emits: () -> E) where E: Entity {
    self.emitInterval = interval
    self.prototype = .init(body: emits())
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
    CGPoint(x: CGFloat(_x) / 10.0, y: CGFloat(_y) / 10.0)
  } set {
    _x = UInt16(clamping: Int(newValue.x * 10.0))
    _y = UInt16(clamping: Int(newValue.y * 10.0))
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
  func initialVelocity(x: CGFloat?, y: CGFloat?) -> some Entity {
    PhysicsModifiedEntity(entity: self, onBirth: { context in
      var p = context.physics
      if let x {
        p.velocity.dx = x
      }
      if let y {
        p.velocity.dy = y
      }
      return p
    })
  }
  func constantVelocity(x: CGFloat?, y: CGFloat?) -> some Entity {
    PhysicsModifiedEntity(entity: self, onUpdate: { context in
      var p = context.physics
      if let x {
        p.velocity.dx = x
      }
      if let y {
        p.velocity.dy = y
      }
      return p
    })
  }
  func initialAcceleration(x: CGFloat?, y: CGFloat?) -> some Entity {
    PhysicsModifiedEntity(entity: self, onBirth: { context in
      var p = context.physics
      if let x {
        p.acceleration.dx = x
      }
      if let y {
        p.acceleration.dy = y
      }
      return p
    })
  }
  func constantAcceleration(x: CGFloat?, y: CGFloat?) -> some Entity {
    PhysicsModifiedEntity(entity: self, onUpdate: { context in
      var p = context.physics
      if let x {
        p.acceleration.dx = x
      }
      if let y {
        p.acceleration.dy = y
      }
      return p
    })
  }
  func initialRotation(_ angle: Angle) -> some Entity {
    PhysicsModifiedEntity(entity: self, onBirth: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  func constantRotation(_ angle: Angle) -> some Entity {
    PhysicsModifiedEntity(entity: self, onUpdate: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  func initialTorque(_ angle: Angle) -> some Entity {
    PhysicsModifiedEntity(entity: self, onBirth: { context in
      var p = context.physics
      p.torque = angle
      return p
    })
  }
  func constantTorque(_ angle: Angle) -> some Entity {
    PhysicsModifiedEntity(entity: self, onUpdate: { context in
      var p = context.physics
      p.torque = angle
      return p
    })
  }
  func lifetime(_ value: Double) -> some Entity {
    PhysicsModifiedEntity(entity: self, onBirth: { context in
      var p = context.physics
      p.lifetime = value
      return p
    })
  }
  func opacity(_ value: Double) -> some Entity {
    RenderModifiedEntity(entity: self, onUpdate: { context in
      var p = context.render
      p.opacity = value
      return p
    })
  }
  func hueRotation(_ angle: Angle) -> some Entity {
    RenderModifiedEntity(entity: self, onUpdate: { context in
      var p = context.render
      p.hueRotation = angle
      return p
    })
  }
  func blur(_ size: CGFloat) -> some Entity {
    RenderModifiedEntity(entity: self, onUpdate: { context in
      var p = context.render
      p.blur = size
      return p
    })
  }
  func scale(x: CGFloat?, y: CGFloat?) -> some Entity {
    RenderModifiedEntity(entity: self, onUpdate: { context in
      var p = context.render
      if let x {
        p.scale.width = x
      }
      if let y {
        p.scale.height = y
      }
      return p
    })
  }
  func scale(_ size: CGFloat) -> some Entity {
    self.scale(x: size, y: size)
  }
  func customBirthPhysics(_ closure: @escaping (PhysicsProxy.Context) -> PhysicsProxy) -> some Entity {
    PhysicsModifiedEntity(entity: self, onBirth: closure)
  }
  func customUpdatePhysics(_ closure: @escaping (PhysicsProxy.Context) -> PhysicsProxy) -> some Entity {
    PhysicsModifiedEntity(entity: self, onUpdate: closure)
  }
  func customUpdateRender(_ closure: @escaping (RenderProxy.Context) -> RenderProxy) -> some Entity {
    RenderModifiedEntity(entity: self, onUpdate: closure)
  }
}
