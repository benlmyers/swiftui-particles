//
//  Entity.swift
//
//
//  Created by Ben Myers on 9/30/23.
//

import SwiftUI
import Foundation

public class Entity {
  
  private var birthActions: [(Entity.Proxy, Emitter.Proxy?) -> Void] = [
    { entityProxy, emitterProxy in
      if let emitterProxy {
        entityProxy.position = emitterProxy.position
      }
    }
  ]
  
  private var deathActions: [(Entity.Proxy) -> Void] = []
  
  private var updateActions: [(Entity.Proxy) -> Void] = [
    { proxy in
      let v: CGVector = proxy.velocity
      let a: CGVector = proxy.acceleration
      proxy.velocity = CGVector(dx: v.dx + a.dx, dy: v.dy + a.dy)
    },
    { proxy in
      let p: CGPoint = proxy.position
      let v: CGVector = proxy.velocity
      proxy.position = CGPoint(x: p.x + v.dx, y: p.y + v.dy)
    }
  ]
  
  func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    let proxy = Proxy(systemData: data, entityData: self)
//    proxy.onBirth()
    return proxy
  }
  
  public class Proxy: Identifiable, Hashable, Equatable {
    
    typealias Behavior = (Any) -> Void
    
    final weak var systemData: ParticleSystem.Data?
    
    final private var entityData: Entity
    
    public final let id: UUID = UUID()
    
    private var inception: Date = Date()
    
    public var lifetime: TimeInterval = 5.0
    public var position: CGPoint = .zero
    public var velocity: CGVector = .zero
    public var acceleration: CGVector = .zero
    public var rotation: Angle = .zero
    
    var expiration: Date {
      return inception + lifetime
    }
    
    var timeAlive: TimeInterval {
      return Date().timeIntervalSince(inception)
    }
    
    var lifetimeProgress: Double {
      return timeAlive / lifetime
    }
    
    init(systemData: ParticleSystem.Data, entityData: Entity) {
      self.systemData = systemData
      self.entityData = entityData
    }
    
    public static func == (lhs: Proxy, rhs: Proxy) -> Bool {
      return lhs.id == rhs.id
    }
    
    func onUpdate(_ context: inout GraphicsContext) {
      for onUpdate in entityData.updateActions {
        onUpdate(self)
      }
    }
    
    func onBirth(_ source: Emitter.Proxy?) {
      for onBirth in entityData.birthActions {
        onBirth(self, source)
      }
    }
    
    func onDeath() {
      for onDeath in entityData.deathActions {
        onDeath(self)
      }
    }
    
    public func hash(into hasher: inout Hasher) {
      return id.hash(into: &hasher)
    }
  }
}

public extension Entity {
 
  func onBirth(perform action: @escaping (Entity.Proxy, Emitter.Proxy?) -> Void) -> Self {
    self.birthActions.append(action)
    return self
  }
  
  func onUpdate(perform action: @escaping (Entity.Proxy) -> Void) -> Self {
    self.updateActions.append(action)
    return self
  }
  
  func onDeath(perform action: @escaping (Entity.Proxy) -> Void) -> Self {
    self.deathActions.append(action)
    return self
  }
}

public class Particle: Entity {
  
  private var taggedView: AnyTaggedView?
  private var onDraw: (inout GraphicsContext) -> Void
  
  public init(color: Color, radius: CGFloat = 4.0) {
    self.onDraw = { context in
      context.fill(Path(ellipseIn: .init(origin: .zero, size: .init(width: radius * 2.0, height: radius * 2.0))), with: .color(color))
    }
  }
  
  public init(onDraw: @escaping (inout GraphicsContext) -> Void) {
    self.onDraw = onDraw
  }
  
  public init(@ViewBuilder view: () -> some View) {
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
  
  override func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Entity.Proxy {
    if let taggedView {
      data.views.insert(taggedView)
    }
    return Proxy(onDraw: onDraw, systemData: data, entityData: self)
  }
  
  public class Proxy: Entity.Proxy {
    
    public var opacity: Double = 1.0
    public var scaleEffect: CGFloat = 1.0
    public var blur: CGFloat = .zero
    public var hueRotation: Angle = .zero
    
    private var onDraw: (inout GraphicsContext) -> Void
    
    init(onDraw: @escaping (inout GraphicsContext) -> Void, systemData: ParticleSystem.Data, entityData: Entity) {
      self.onDraw = onDraw
      super.init(systemData: systemData, entityData: entityData)
    }
    
    override func onUpdate(_ context: inout GraphicsContext) {
      super.onUpdate(&context)
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

public class Emitter: Entity {
  
  private var prototypes: [Entity]
  
  public init(@Builder<Entity> entities: @escaping () -> [Entity]) {
    self.prototypes = entities()
  }
  
  public override func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    return Proxy(prototypes: prototypes, systemData: data, entityData: self)
  }
  
  public class Proxy: Entity.Proxy {
    
    private var prototypes: [Entity]
    
    public private(set) var lastEmitted: Date?
    public private(set) var emittedCount: Int = 0
    
    public var fireRate: Double = 1.0
    public var decider: (Proxy) -> Int = { _ in Int.random(in: 0 ... .max) }
    
    init(prototypes: [Entity], systemData: ParticleSystem.Data, entityData: Entity) {
      self.prototypes = prototypes
      super.init(systemData: systemData, entityData: entityData)
    }
    
    override func onUpdate(_ context: inout GraphicsContext) {
      super.onUpdate(&context)
      context.stroke(.init(ellipseIn: .init(x: position.x, y: position.y, width: 2.0, height: 2.0)), with: .color(.white))
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
      let prototype: Entity = prototypes[decider(self) % prototypes.count]
      let newProxy = prototype.makeProxy(source: self, data: systemData)
      systemData.proxies.insert(newProxy)
      lastEmitted = Date()
      emittedCount += 1
      newProxy.onBirth(self)
    }
  }
}

class MyParticle: Particle {
  
  var color: Color
  
  init(color: Color) {
    self.color = color
    super.init { context in
      context.stroke(Path(roundedRect: .init(origin: .zero, size: .init(width: 10.0, height: 10.0)), cornerSize: .zero), with: .color(color))
    }
  }
}

public struct ParticleSystem: View {
  
  private var colorMode: ColorRenderingMode = .nonLinear
  private var async: Bool = true
  
  var data: Self.Data
  
  public var body: some View {
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
  
  public init(@Builder<Entity> entities: @escaping () -> [Entity]) {
    self.data = Data()
    self.data.proxies = Set(entities().map({ $0.makeProxy(source: nil, data: data) }))
    for proxy in self.data.proxies {
      proxy.onBirth(nil)
    }
  }
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    self.data.systemSize = size
    for proxy in data.proxies {
      proxy.onUpdate(&context)
    }
  }
  
  func destroyExpired() {
    data.proxies = data.proxies.filter({ proxy in
      let result = Date() < proxy.expiration
      if !result {
        proxy.onDeath()
      }
      return result
    })
  }
  
  public class Data {
    var views: Set<AnyTaggedView> = .init()
    var proxies: Set<Entity.Proxy> = .init()
    var debug: Bool = false
    var systemSize: CGSize = .zero
  }
}
