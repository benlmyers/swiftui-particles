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
      .initialPosition(x: 25.0, y: 25.0)
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
      TimelineView(.animation(paused: false)) { [self] t in
        Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: true, renderer: { context, size in
          
        }) {
          Text("❌").tag("NOT_FOUND")
          ForEach(Array(data.viewPairs()), id: \.1) { (pair: (AnyView, EntityID)) in
            pair.0.tag(pair.1)
          }
        }
      }
      .onAppear {
        // TODO: Verify this works (before it was Task and threw warning)
        data.systemSize = proxy.size
      }
    }
  }
  init<E>(@EntityBuilder entity: () -> E) where E: Entity {
    let e: E = entity()
    self.data = .init()
    if let tuple = e as? TupleEntity<(any Entity)> {
      self.data.create(entity: tuple.value)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity)> {
      self.data.create(entity: tuple.value.0)
      self.data.create(entity: tuple.value.1)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity, any Entity)> {
      self.data.create(entity: tuple.value.0)
      self.data.create(entity: tuple.value.1)
      self.data.create(entity: tuple.value.2)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity, any Entity, any Entity)> {
      self.data.create(entity: tuple.value.0)
      self.data.create(entity: tuple.value.1)
      self.data.create(entity: tuple.value.2)
      self.data.create(entity: tuple.value.3)
    }
  }
  private func renderProxy(_ proxyID: ProxyID) {
//    guard
//      position.x > 0,
//      position.x < systemData!.systemSize.width,
//      position.y > 0,
//      position.y < systemData!.systemSize.height
//    else { return }
//    context.drawLayer { context in
//      context.opacity = opacity
//      if !hueRotation.degrees.isZero {
//        context.addFilter(.hueRotation(hueRotation))
//      }
//      context.translateBy(x: position.x, y: position.y)
//      context.rotate(by: rotation)
//      if scaleEffect != 1.0 {
//        context.scaleBy(x: scaleEffect, y: scaleEffect)
//      }
//      guard let resolved = context.resolveSymbol(id: taggedView.tag) else {
//        // TODO: WARN
//        return
//      }
//      context.draw(resolved, at: .zero)
//    }
  }
  class Data {
    internal var systemSize: CGSize = .zero
    internal private(set) var currentFrame: UInt16 = .zero
    private var entities: [EntityID: any Entity] = [:]
    private var views: [EntityID: AnyView] = .init()
    private var physicsProxies: [ProxyID: PhysicsProxy] = [:]
    private var renderProxies: [ProxyID: RenderProxy] = [:]
    private var proxyEntities: [ProxyID: EntityID] = [:]
    private var nextEntityRegistry: EntityID = .zero
    private var nextProxyRegistry: ProxyID = .zero
    init() {}
    internal func create(entity: any Entity) {
      self.register(entity: entity)
    }
    internal func viewPairs() -> [(AnyView, EntityID)] {
      var result: [(AnyView, EntityID)] = []
      for (id, view) in views {
        result.append((view, id))
      }
      return result
    }
    private func register(entity: any Entity) {
      self.entities[nextEntityRegistry] = entity
      self.physicsProxies[nextProxyRegistry] = PhysicsProxy()
      if let view: AnyView = entity.viewToRegister() {
        self.renderProxies[nextProxyRegistry] = RenderProxy()
        self.views[nextEntityRegistry] = view
      }
      self.proxyEntities[nextProxyRegistry] = nextEntityRegistry
      guard nextEntityRegistry < .max else {
        fatalError("For performance purposes, you may not have more than 256 entity variants.")
      }
      nextEntityRegistry += 1
      nextProxyRegistry += 1
    }
  }
}

extension Never: Entity {}

public protocol Entity {
  var body: Self.Body { get }
  associatedtype Body: Entity
}

extension Entity {
  func viewToRegister() -> AnyView? {
    if let particle = self as? Particle {
      return particle.view
    } else {
      return body.viewToRegister()
    }
  }
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy { return context.physics }
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy { return context.physics }
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy { return context.render }
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

protocol SystemContext {
  var data: ParticleSystem.Data? { get }
}
protocol Proxy {
  associatedtype C: SystemContext
}

public struct PhysicsProxy: Proxy {
  typealias C = Context
  // x = 10 => 1 pixel x-positioning
  private var _x: UInt16
  // y = 10 => 1 pixel y-positioning
  private var _y: UInt16
  // velX = 1 => 1 pixel per frame x-velocity
  private var _velX: Float16
  // velY = 1 => 1 pixel per frame y-velocity
  private var _velY: Float16
  // accX = 1 => 1 pixel per frame x-acceleration
  private var _accX: Float16
  // accY = 1 => 1 pixel per frame y-acceleration
  private var _accY: Float16
  // rotation = 1 => 1.411° rotation
  private var _rotation: UInt8
  // torque = 1 => 1.411° per frame rotation
  init() {
    _x = .zero
    _y = .zero
    _velX = .zero
    _velY = .zero
    _accX = .zero
    _accY = .zero
    _rotation = .zero
  }
  struct Context: SystemContext {
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
}

struct RenderProxy: Proxy {
  typealias C = Context
  var opacity: UInt8
  var hueRotation: UInt8
  var blur: UInt8
  var scaleX: Float16
  var scaleY: Float16
  init() {
    self.opacity = .max
    self.hueRotation = .zero
    self.blur = .zero
    self.scaleX = 1
    self.scaleY = 1
  }
  struct Context: SystemContext {
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
