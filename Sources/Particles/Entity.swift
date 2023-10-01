//
//  Entity.swift
//
//
//  Created by Ben Myers on 9/30/23.
//

import SwiftUI
import Foundation

protocol Entity {
  associatedtype Proxy: EntityProxy
  
  var systemData: ParticleSystem.Data? { get set }
  var modifiers: [EntityModifier] { get set }
  
  func makeProxy(source: Emitter.Proxy?) -> Proxy
}

extension Entity {
  
  func start<T>(_ path: PartialKeyPath<T>, at value: T) -> Self {
    var copy = self
    let modifier = EntityModifier(path: path, behavior: .startsAt(value))
    copy.modifiers.append(modifier)
    return copy
  }
}

struct EntityModifier {
  
  var path: AnyKeyPath
  var behavior: Behavior
  
  enum Behavior {
    case startsAt(Any)
  }
}

class EntityProxy: Identifiable, Hashable, Equatable {
  
  var id: UUID = UUID()
  
  var inception: Date = Date()
  var lifetime: TimeInterval = 5.0
  
  var position: CGPoint = .zero
  var velocity: CGVector = .zero
  var rotation: Angle = .zero
  
  weak var systemData: ParticleSystem.Data?
  
  var expiration: Date {
    return inception + lifetime
  }
  
  var timeAlive: TimeInterval {
    return Date().timeIntervalSince(inception)
  }
  
  var lifetimeProgress: Double {
    return timeAlive / lifetime
  }
  
  static func == (lhs: EntityProxy, rhs: EntityProxy) -> Bool {
    return lhs.id == rhs.id
  }
  
  func onUpdate(_ context: inout GraphicsContext) {}
  func onBirth() {}
  func onDeath() {}
  
  func hash(into hasher: inout Hasher) {
    return id.hash(into: &hasher)
  }
  
}

struct Particle: Entity {
  
  weak var systemData: ParticleSystem.Data?
  var modifiers: [EntityModifier] = []
  var taggedView: AnyTaggedView?
  
  private var onDraw: (inout GraphicsContext) -> Void
  
  init(color: Color, radius: CGFloat = 4.0) {
    self.onDraw = { context in
      context.fill(Path(ellipseIn: .init(origin: .zero, size: .init(width: radius * 2.0, height: radius * 2.0))), with: .color(color))
    }
  }
  
  init(onDraw: @escaping (inout GraphicsContext) -> Void) {
    self.onDraw = onDraw
  }
  
  init(@ViewBuilder view: () -> some View) {
    let taggedView = AnyTaggedView(view: AnyView(view()), tag: UUID())
    self.taggedView = taggedView
    self.onDraw = { context in
      guard let resolved = context.resolveSymbol(id: taggedView.tag) else {
        // TODO: WARN
        return
      }
      context.draw(resolved, at: .zero)
    }
  }
  
  func makeProxy(source: Emitter.Proxy?) -> Proxy {
    systemData!.views.insert(taggedView!)
    return Proxy(onDraw: onDraw)
  }
  
  class Proxy: EntityProxy {
    
    var opacity: Double = 1.0
    var scaleEffect: CGFloat = 1.0
    var blur: CGFloat = .zero
    var hueRotation: Angle = .zero
    
    private var onDraw: (inout GraphicsContext) -> Void
    
    init(onDraw: @escaping (inout GraphicsContext) -> Void) {
      self.onDraw = onDraw
    }
    
    override func onUpdate(_ context: inout GraphicsContext) {
      context.drawLayer { context in
        context.translateBy(x: position.x, y: position.y)
        context.rotate(by: rotation)
        context.opacity = opacity
        if scaleEffect != 1.0 {
          context.scaleBy(x: scaleEffect, y: scaleEffect)
        }
        if !blur.isZero {
          context.addFilter(.blur(radius: blur))
        }
        if !hueRotation.degrees.isZero {
          context.addFilter(.hueRotation(hueRotation))
        }
        self.onDraw(&context)
      }
    }
  }
}

struct Emitter: Entity {
  
  weak var systemData: ParticleSystem.Data?
  var modifiers: [EntityModifier] = []
  
  private var entities: (Self.Proxy) -> [any Entity]
  
  init(@Builder<Entity> entities: @escaping (Self.Proxy) -> [any Entity]) {
    self.entities = entities
  }
  
  func makeProxy(source: Emitter.Proxy?) -> Proxy {
    let result = Proxy()
    result.prototypes = entities(result)
    return result
  }
  
  class Proxy: EntityProxy {
    
    var prototypes: [any Entity] = []
    var lastEmitted: Date?
    var emittedCount: Int = 0
    
    var fireRate: Double = 1.0
    var decider: (Proxy) -> Int = { _ in Int.random(in: 0 ... .max) }
    
    override func onUpdate(_ context: inout GraphicsContext) {
      if let lastEmitted {
        guard Date().timeIntervalSince(lastEmitted) >= 1.0 / fireRate else {
          return
        }
      }
      guard !prototypes.isEmpty else {
        // TODO: Warn
        return
      }
      guard let systemData else {
        // TODO: Warn
        return
      }
      let prototype: any Entity = prototypes[decider(self) % prototypes.count]
      let newProxy = prototype.makeProxy(source: self)
      systemData.proxies.insert(newProxy)
      lastEmitted = Date()
      emittedCount += 1
      newProxy.onBirth()
    }
  }
}

struct ParticleSystem: View {
  
  private var colorMode: ColorRenderingMode = .nonLinear
  private var async: Bool = true
  
  var data: Self.Data
  
  var body: some View {
    TimelineView(.animation(paused: false)) { [self] t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
        Text("❌").tag("NOT_FOUND")
        ForEach(Array(data.views), id: \.tag) { taggedView in
          taggedView.view.tag(taggedView.tag)
        }
      }
      .border(Color.red.opacity(data.debug ? 1.0 : 0.1))
      .onChange(of: t.date) { _ in
        destroyExpired()
      }
    }
  }
  
  init(@Builder<Entity> entities: @escaping () -> [any Entity]) {
    self.data = Data()
    self.data.proxies = Set(entities().map({ $0.makeProxy(source: nil) }))
  }
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    self.data.systemSize = size
    for proxy in data.proxies {
      proxy.onUpdate(&context)
    }
  }
  
  func destroyExpired() {
    data.proxies = data.proxies.filter({ proxy in
      Date() < proxy.expiration
    })
  }
  
  class Data {
    var views: Set<AnyTaggedView> = .init()
    var proxies: Set<EntityProxy> = .init()
    var debug: Bool = false
    var systemSize: CGSize = .zero
  }
}

struct SampleView: View {
  var body: some View {
    ParticleSystem {
      Particle(color: .red)
      Emitter { proxy in
        Particle(color: .yellow)
      }
    }
  }
}
