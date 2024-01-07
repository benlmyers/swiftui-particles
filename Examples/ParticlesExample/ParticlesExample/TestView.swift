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
    EmptyView()
  }
}

struct AnyTaggedView: Hashable, Identifiable {
  
  // MARK: - Properties
  
  var view: AnyView
  var tag: UInt8
  
  var id: UInt8 { tag }
  
  // MARK: - Static Methods
  
  static func == (lhs: AnyTaggedView, rhs: AnyTaggedView) -> Bool {
    return lhs.tag == rhs.tag
  }
  
  // MARK: - Methods
  
  func hash(into hasher: inout Hasher) {
    return tag.hash(into: &hasher)
  }
}


@resultBuilder public struct EntityBuilder {
  
  public static func buildExpression<E>(_ content: E) -> E where E: Entity {
    content
  }
  
  public static func buildBlock<E>(_ content: E) -> E where E: Entity {
    content
  }
  
  public static func buildBlock<E1>(_ c1: E1) -> some Entity where E1: Entity {
    TupleEntity(value: (c1))
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

public struct ParticleSystem {
  var data: Self.Data
  public var body: some View {
    GeometryReader { proxy in
      TimelineView(.animation(paused: false)) { [self] t in
        Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: true, renderer: { context, size in
          
        }) {
          Text("❌").tag("NOT_FOUND")
          ForEach(Array(data.views), id: \.tag) { taggedView in
            taggedView.view.tag(taggedView.tag)
          }
        }
      }
      .task {
        data.systemSize = proxy.size
      }
    }
  }
  init<E>(@EntityBuilder entity: () -> E) where E: Entity {
    let e: E = entity()
    self.data = .init()
    if let tuple = e as? TupleEntity<(any Entity)> {
      self.data.register(tuple.value)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity)> {
      self.data.register(tuple.value.0)
      self.data.register(tuple.value.1)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity, any Entity)> {
      self.data.register(tuple.value.0)
      self.data.register(tuple.value.1)
      self.data.register(tuple.value.2)
    } else if let tuple = e as? TupleEntity<(any Entity, any Entity, any Entity, any Entity)> {
      self.data.register(tuple.value.0)
      self.data.register(tuple.value.1)
      self.data.register(tuple.value.2)
      self.data.register(tuple.value.3)
    }
  }
  class Data {
    internal var views: Set<AnyTaggedView>
    internal var systemSize: CGSize = .zero
    internal var currentFrame: UInt16 = .zero
    private var entities: [UInt8: any Entity] = [:]
    private var nextEntityRegistry: UInt8 = .zero
    private var currentIndex: UInt8
    init() {
      views = .init()
      currentIndex = .zero
    }
    func register(_ entity: any Entity) {
      self.entities[nextEntityRegistry] = entity
      guard nextEntityRegistry < .max else {
        fatalError("For performance purposes, you may not have more than 256 entity variants.")
      }
      nextEntityRegistry += 1
    }
  }
}

extension Never: Entity {}

public protocol Entity {
  var body: Self.Body { get }
  associatedtype Body: Entity
}

extension Entity {
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy { return context.physics }
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy { return context.physics }
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy { return context.render }
}

public struct EmptyEntity: Entity {
  public var body: Never
  public typealias Body = Never
}

public struct TupleEntity<T>: Entity {
  public typealias Body = Never
  public var body: Never { .transferRepresentation }
  var value: T
  public init(value: T) {
    self.value = value
  }
}

public struct Particle<V>: Entity where V: View {
  public typealias Body = Never
  public var body: Never { .transferRepresentation }
  private var view: V
  public init(@ViewBuilder view: () -> V) {
    self.view = view()
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

struct PhysicsProxy: Proxy {
  typealias C = Context
  // x = 10 => 1 pixel x-positioning
  var x: UInt16
  // y = 10 => 1 pixel y-positioning
  var y: UInt16
  // velX = 1 => 1 pixel per frame x-velocity
  var velX: Float16
  // velY = 1 => 1 pixel per frame y-velocity
  var velY: Float16
  // accX = 1 => 1 pixel per frame x-acceleration
  var accX: Float16
  // accY = 1 => 1 pixel per frame y-acceleration
  var accY: Float16
  // rotation = 1 => 1.411° rotation
  var rotation: UInt8
  // torque = 1 => 1.411° per frame rotation
  init() {
    x = .zero
    y = .zero
    velX = .zero
    velY = .zero
    accX = .zero
    accY = .zero
    rotation = .zero
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

struct RenderProxy: Proxy {
  typealias C = Context
  var viewID: AnyTaggedView.ID
  var opacity: UInt8
  var hueRotation: UInt8
  var blur: UInt8
  var scaleX: Float16
  var scaleY: Float16
  init(viewID: AnyTaggedView.ID) {
    self.viewID = viewID
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
    let newContext: PhysicsProxy.Context = .init(physics: proxy, data: context.data!)
    return birth(context)
  }
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    let proxy = body.onPhysicsUpdate(context)
    guard let data = context.data else { return proxy }
    let newContext: PhysicsProxy.Context = .init(physics: proxy, data: context.data!)
    return update(context)
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
    return update(context)
  }
}

public extension Entity {
  func initialPosition(_ pos: CGVector) -> some Entity {
    PhysicsModifiedEntity(entity: self, onUpdate: { context in
      var p = context.physics
      p.x = UInt16(pos.dx * 10.0)
      p.y = UInt16(pos.dy * 10.0)
      return p
    })
  }
}
