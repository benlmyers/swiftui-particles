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

//public struct ParticleSystem {
//  
//  var data: Self.Data
//  
//  @State private var currentFrame: UInt8 = .zero
//  
//  init(entity: () -> AnyEntity) {
//    self.data = .init()
//  }
//  
//  public var body: some View {
//    GeometryReader { proxy in
//      TimelineView(.animation(paused: false)) { [self] t in
//        Canvas(renderer: renderer)
//        Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: async, renderer: self.renderer) {
//          Text("❌").tag("NOT_FOUND")
////          ForEach(Array(data.views), id: \.tag) { taggedView in
////            taggedView.view.tag(taggedView.tag)
////          }
//        }
//        .border(Color.red.opacity(data.debug ? 1.0 : 0.1))
//      }
//      .task {
//        data.systemSize = proxy.size
//      }
//    }
//  }
//  
//  func renderer(context: inout GraphicsContext, size: CGSize) {
////    destroyExpired()
//  }
//  
//  class Data {
//    
//    internal var views: Set<AnyTaggedView>
//    private var systemSize: CGSize = .zero
//    private var entities: [UInt8: EntityProxy]
//    private var physics: [UInt8: PhysicalProxy]
//    private var renders: [UInt8: RenderProxy]
//    private var currentIndex: UInt8
//    
//    init() {
//      views = .init()
//      entities = [:]
//      physics = [:]
//      renders = [:]
//      currentIndex = .zero
//    }
//  }
//}
//
//public typealias Frames = UInt16
//
//public struct EntityProxy: Identifiable {
//  public var id: UInt8
//  private var _birth: UInt16
//  private var _lifetime: UInt16
//  private var _x: UInt16
//  private var _y: UInt16
//  private var _duration: UInt8
//  private var _rotation: UInt8
//  
////  public var birth: Frames { get {
////    return _birth
////  } set {
////    self._birth = newValue
////  }}
////  
////  public var lifetime: Frames { get {
////    return UInt8(_lifetime)
////  } set {
////    self._lifetime = newValue
////  }}
////  
////  public var position: CGVector { get {
////    return CGVector(dx: CGFloat(_x), dy: CGFloat(_y))
////  } set {
////    self._x = UInt16(newValue.dx)
////    self._y = UInt16(newValue.dy)
////  }}
//}
//
//public struct PhysicalProxy {
//  private var velX: Int8
//  private var velY: Int8
//  private var accX: Int8
//  private var accY: Int8
//  private var torque: Int8
//}
//
//public struct RenderProxy {
//  private var viewID: UUID
//  private var scale: Int8
//  private var hue: UInt8
//  private var opacity: UInt8
//  private var blur: UInt8
//}
//
//public struct SpawnerProxy {
//  private var spawnEvery: UInt8
//  private var spawnTarget: UInt8
//}
//
//public protocol Entity {
//  var modifiers: [Modifier] { get }
//}
//
//public extension Entity {
////  private var modifiers: [EntityModifier]
////  func onBirth() {}
////  func onDeath() {}
//}
//
//public struct AnyEntity {
//  var modifiers: [Modifier]
//  init<E>(_ entity: E) where E: Entity {
//    self.modifiers = entity.modifiers
//  }
//}
//
//public enum Modifier {
//  case initialValue(_ v: Any)
//  case constantValue(_ v: Any)
//  case incrementBy(_ v: Any)
//}
//
////public protocol Physical {
////  func updatePhysics(proxy: PhysicalProxy) -> PhysicalProxy
////}
////
////public extension Physical {
////  func updatePhysics(proxy: PhysicalProxy) -> PhysicalProxy { return proxy }
////}
//
//public protocol Renderable {
//  associatedtype V: View
//  var body: V { get }
//}
//
//extension Renderable {
//  var taggedView: AnyTaggedView {
//    .init(view: AnyView(body), tag: UUID())
//  }
//}
//
//public protocol Spawner {
//  @EntityBuilder var prototypes: Set<AnyEntity> { get }
//}
//
//extension Spawner {
//  public func updateSpawner(proxy: SpawnerProxy) -> SpawnerProxy { return proxy }
//}
//
//public struct Particles {}
//
//extension Particles {
//  public struct Circle: Entity, Physical, Renderable {
//    public var modifiers: [EntityModifier]
//    
//    public var body: some View {
//      SwiftUI.Circle().frame(width: 10.0, height: 10.0)
//    }
//  }
//}
//
//public struct Particle<V>: Entity, Physical, Renderable where V: View {
//  public var body: V
//  init(@ViewBuilder body: () -> V) {
//    self.body = body()
//  }
//}
//
//public struct Emitter: Entity, Spawner {
//  public var prototype: some Entity {
//    Particles.Circle()
//  }
//}
//
//public struct
//  
//  // MARK: - Properties
//  
//  var view: AnyView
//  var tag: UUID
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
//
struct AnyTaggedView: Hashable {
  
  // MARK: - Properties
  
  var view: AnyView
  var tag: UUID
  
  // MARK: - Static Methods
  
  static func == (lhs: AnyTaggedView, rhs: AnyTaggedView) -> Bool {
    return lhs.tag == rhs.tag
  }
  
  // MARK: - Methods
  
  func hash(into hasher: inout Hasher) {
    return tag.hash(into: &hasher)
  }
}
//
//
//@resultBuilder public struct EntityBuilder {
//  
//  /// Builds an expression within the builder.
//  public static func buildExpression<E>(_ content: E) -> [AnyEntity] where E: Entity {
//    [AnyEntity(content)]
//  }
//  
//  /// Builds an empty view from a block containing no statements.
//  public static func buildBlock() -> [AnyEntity] {
//    [AnyEntity]()
//  }
//  
//  /// Passes a single view written as a child view through unmodified.
//  ///
//  /// An example of a single view written as a child view is
//  /// `{ Text("Hello") }`.
//  public static func buildBlock<E>(_ content: E) -> [AnyEntity] where E: Entity {
//    [AnyEntity(content)]
//  }
//  
//  public static func buildBlock<each E>(_ components: repeat each E) -> [AnyEntity] where repeat each E: Entity {
//    var result: [AnyEntity] = []
//    var x: repeat (each E) =
//    result.append(contentsOf: repeat (each components))
//    return result
//  }
//}

public struct ParticleSystem {
  @State private var currentFrame: UInt8 = .zero
  var data: Self.Data
  public var body: some View {
    GeometryReader { proxy in
      TimelineView(.animation(paused: false)) { [self] t in
        Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: true, renderer: { context, size in
          context.scaleBy(x: 1, y: 2)
        }) {
          Text("❌").tag("NOT_FOUND")
//          ForEach(Array(data.views), id: \.tag) { taggedView in
//            taggedView.view.tag(taggedView.tag)
//          }
        }
      }
      .task {
        data.systemSize = proxy.size
      }
    }
  }
  class Data {
    internal var views: Set<AnyTaggedView>
    internal var systemSize: CGSize = .zero
    private var currentIndex: UInt8
    init() {
      views = .init()
      currentIndex = .zero
    }
  }
}

extension Never: Entity {}

public protocol Entity {
  var body: Self.Body { get }
  associatedtype Body: Entity
}

public struct TupleEntity<T>: Entity {
  public typealias Body = Never
  public var body: Never { .transferRepresentation }
  var value: T
  public init(value: T) {
    self.value = value
  }
}

public struct Particle<V> where V: View {
  public typealias Body = Never
  private var view: V
  public init(@ViewBuilder view: () -> V) {
    self.view = view()
  }
}

@available(macOS 14.0.0, *)
public struct Emitter<E> where E: Entity {
  
}
