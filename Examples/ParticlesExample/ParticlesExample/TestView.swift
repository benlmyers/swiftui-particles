//
//  TestView.swift
//
//
//  Created by Ben Myers on 1/3/24.
//

import SwiftUI
import Foundation

struct TestView: View {
  
  @State var x: Int = 0
  
  var body: some View {
    VStack {
      Button("\(x)", action: { x += 1 })
      ParticleSystem {
        Particle {
          Text("Test")
        }
        .initialPosition(x: 100.0, y: 100.0)
      }
      .debug()
    }
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
    EntityGroup(values: [.init(body: c1), .init(body: c2)])
  }
  
  public static func buildBlock<E1, E2, E3>(_ c1: E1, _ c2: E2, _ c3: E3) -> some Entity where E1: Entity, E2: Entity, E3: Entity {
    EntityGroup(values: [.init(body: c1), .init(body: c2), .init(body: c3)])
  }
  
  public static func buildBlock<E1, E2, E3, E4>(
    _ c1: E1, _ c2: E2, _ c3: E3, _ c4: E4
  ) -> some Entity where E1: Entity, E2: Entity, E3: Entity, E4: Entity {
    EntityGroup(values: [.init(body: c1), .init(body: c2), .init(body: c3), .init(body: c4)])
  }
}

public struct ParticleSystem: View {
  internal typealias EntityID = UInt8
  internal typealias ProxyID = UInt16
  internal typealias GroupID = UInt8
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
      Text(data.memorySummary())
        .lineLimit(99)
        .fixedSize(horizontal: false, vertical: false)
        .multilineTextAlignment(.leading)
    }
    .font(.caption2)
    .opacity(0.5)
  }
  init<E>(@EntityBuilder entity: () -> E) where E: Entity {
    let e: E = entity()
    self.data = .init()
    self.data.createSingle(entity: e)
  }
  public func debug() -> ParticleSystem {
    self.data.debug = true
    return self
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

extension Never: Entity {}

public protocol Entity {
  var body: Self.Body { get }
  associatedtype Body: Entity
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy
  func onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy
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
  internal func underlyingGroup() -> EntityGroup? {
    if let group = self as? EntityGroup {
      return group
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingGroup()
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
  public func onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    if self is EmptyEntity {
      return context.render
    } else {
      return body.onRenderBirth(context)
    }
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

public struct EntityGroup: Entity {
  public var body: EmptyEntity { .init() }
  internal var values: [AnyEntity]
  internal init(values: [AnyEntity]) {
    self.values = values
  }
  public init<E>(@EntityBuilder entities: () -> E) where E: Entity {
    if let e = entities() as? EntityGroup {
      self = e
    } else {
      self.values = [.init(body: entities())]
    }
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
    weak private(set) var data: ParticleSystem.Data?
    init(physics: PhysicsProxy, data: ParticleSystem.Data) {
      self.physics = physics
      self.data = data
    }
  }
}

public extension PhysicsProxy {
  var position: CGPoint { get {
    CGPoint(x: (CGFloat(_x) - 250.0) / 10.0, y: (CGFloat(_y) - 250.0) / 10.0)
  } set {
    _x = UInt16(clamping: Int(newValue.x * 10.0) + 250)
    _y = UInt16(clamping: Int(newValue.y * 10.0) + 250)
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
    _rotation = UInt8(ceil((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
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

public struct RenderProxy: Equatable {
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

internal struct ModifiedEntity<E>: Entity where E: Entity {
  private var birthPhysics: ((PhysicsProxy.Context) -> PhysicsProxy)?
  private var updatePhysics: ((PhysicsProxy.Context) -> PhysicsProxy)?
  private var birthRender: ((RenderProxy.Context) -> RenderProxy)?
  private var updateRender: ((RenderProxy.Context) -> RenderProxy)?
  var body: E
  init(
    entity: E,
    onBirthPhysics: ((PhysicsProxy.Context) -> PhysicsProxy)? = nil,
    onUpdatePhysics: ((PhysicsProxy.Context) -> PhysicsProxy)? = nil,
    onBirthRender: ((RenderProxy.Context) -> RenderProxy)? = nil,
    onUpdateRender: ((RenderProxy.Context) -> RenderProxy)? = nil
  ) {
    self.body = entity
    self.birthPhysics = onBirthPhysics
    self.updatePhysics = onUpdatePhysics
    self.birthRender = onBirthRender
    self.updateRender = onUpdateRender
  }
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    guard let data = context.data else { return body.onPhysicsBirth(context) }
    guard let birthPhysics else { return body.onPhysicsBirth(context) }
    let newContext: PhysicsProxy.Context = .init(physics: birthPhysics(context), data: data)
    return body.onPhysicsBirth(newContext)
  }
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    guard let data = context.data else { return body.onPhysicsUpdate(context) }
    guard let updatePhysics else { return body.onPhysicsUpdate(context) }
    let newContext: PhysicsProxy.Context = .init(physics: updatePhysics(context), data: data)
    return body.onPhysicsUpdate(newContext)
  }
  func onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    guard let data = context.data else { return body.onRenderBirth(context) }
    guard let birthRender else { return body.onRenderBirth(context) }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: birthRender(context), data: data)
    return body.onRenderBirth(newContext)
  }
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    guard let data = context.data else { return body.onRenderUpdate(context) }
    guard let updateRender else { return body.onRenderUpdate(context) }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: updateRender(context), data: data)
    return body.onRenderUpdate(newContext)
  }
}

public extension Entity {
  func initialPosition(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
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
  func initialPosition(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.position.x = x
      }
      if let y = y(context) {
        p.position.y = y
      }
      return p
    })
  }
  func initialOffset(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x {
        p.position.x += x
      }
      if let y {
        p.position.y += y
      }
      return p
    })
  }
  func initialOffset(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.position.x += x
      }
      if let y = y(context) {
        p.position.y += y
      }
      return p
    })
  }
  func constantPosition(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
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
  func constantPosition(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.position.x = x
      }
      if let y = y(context) {
        p.position.y = y
      }
      return p
    })
  }
  func initialVelocity(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
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
  func initialVelocity(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.velocity.dx = x
      }
      if let y = y(context) {
        p.velocity.dy = y
      }
      return p
    })
  }
  func constantVelocity(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
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
  func constantVelocity(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.velocity.dx = x
      }
      if let y = y(context) {
        p.velocity.dy = y
      }
      return p
    })
  }
  func initialAcceleration(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
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
  func initialAcceleration(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.acceleration.dx = x
      }
      if let y = y(context) {
        p.acceleration.dy = y
      }
      return p
    })
  }
  func constantAcceleration(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
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
  func constantAcceleration(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.acceleration.dx = x
      }
      if let y = y(context) {
        p.acceleration.dy = y
      }
      return p
    })
  }
  func initialRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  func initialRotation(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.rotation = angle(context)
      return p
    })
  }
  func constantRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  func constantRotation(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.rotation = angle(context)
      return p
    })
  }
  func initialTorque(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.torque = angle
      return p
    })
  }
  func initialTorque(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.torque = angle(context)
      return p
    })
  }
  func constantTorque(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.torque = angle(context)
      return p
    })
  }
  func lifetime(_ value: Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.lifetime = value
      return p
    })
  }
  func lifetime(_ value: @escaping (PhysicsProxy.Context) -> Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.lifetime = value(context)
      return p
    })
  }
  func opacity(_ value: Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      p.opacity *= value
      return p
    })
  }
  func opacity(_ value: @escaping (RenderProxy.Context) -> Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      p.opacity *= value(context)
      return p
    })
  }
  func hueRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdateRender: { context in
      var p = context.render
      p.hueRotation = angle
      return p
    })
  }
  func hueRotation(_ angle: @escaping (RenderProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdateRender: { context in
      var p = context.render
      p.hueRotation = angle(context)
      return p
    })
  }
  func blur(_ size: CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      p.blur = size
      return p
    })
  }
  func blur(_ size: @escaping (RenderProxy.Context) -> CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      p.blur = size(context)
      return p
    })
  }
  func scale(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      if let x {
        p.scale.width *= x
      }
      if let y {
        p.scale.height *= y
      }
      return p
    })
  }
  func scale(x: @escaping (RenderProxy.Context) -> CGFloat?, y: @escaping (RenderProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      if let x = x(context) {
        p.scale.width *= x
      }
      if let y = y(context) {
        p.scale.height *= y
      }
      return p
    })
  }
  func scale(_ size: CGFloat) -> some Entity {
    self.scale(x: size, y: size)
  }
  func scale(_ size: @escaping (RenderProxy.Context) -> CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onBirthRender: { context in
      var p = context.render
      let s = size(context)
      p.scale.width *= s
      p.scale.height *= s
      return p
    })
  }
}
