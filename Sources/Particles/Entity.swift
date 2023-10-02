//
//  Entity.swift
//
//
//  Created by Ben Myers on 9/30/23.
//

import SwiftUI
import Foundation

public class Entity {
  
  private var birthActions: [(Entity.Proxy) -> Void] = []
  private var updateActions: [(Entity.Proxy) -> Void] = []
  
  func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    return Proxy(source: nil, systemData: data, entityData: self)
  }
  
  public class Proxy: Identifiable, Hashable, Equatable {
    
    typealias Behavior = (Any) -> Void
    
    final weak var systemData: ParticleSystem.Data?
    final weak var source: Emitter?
    
    private var entityData: Entity
    
    public final let id: UUID = UUID()
    
    private var inception: Date = Date()
    
    public var lifetime: TimeInterval = 5.0
    public var position: CGPoint = .zero
    public var velocity: CGVector = .zero
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
    
    init(source: Emitter.Proxy?, systemData: ParticleSystem.Data, entityData: Entity) {
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
    
    func onBirth() {
      for onUpdate in entityData.birthActions {
        onUpdate(self)
      }
    }
    
    func onDeath() {}
    
    public func hash(into hasher: inout Hasher) {
      return id.hash(into: &hasher)
    }
  }
}

public extension Entity {
 
  func onBirth(perform action: @escaping (Entity.Proxy) -> Void) -> Self {
    self.birthActions.append(action)
    return self
  }
  
  func onUpdate(perform action: @escaping (Entity.Proxy) -> Void) -> Self {
    self.updateActions.append(action)
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
    
    var opacity: Double = 1.0
    var scaleEffect: CGFloat = 1.0
    var blur: CGFloat = .zero
    var hueRotation: Angle = .zero
    
    private var onDraw: (inout GraphicsContext) -> Void
    
    init(onDraw: @escaping (inout GraphicsContext) -> Void, systemData: ParticleSystem.Data, entityData: Entity) {
      self.onDraw = onDraw
      super.init(source: nil, systemData: systemData, entityData: entityData)
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
    
    var prototypes: [Entity]
    var lastEmitted: Date?
    var emittedCount: Int = 0
    
    var fireRate: Double = 1.0
    var decider: (Proxy) -> Int = { _ in Int.random(in: 0 ... .max) }
    
    init(prototypes: [Entity], systemData: ParticleSystem.Data, entityData: Entity) {
      self.prototypes = prototypes
      super.init(source: nil, systemData: systemData, entityData: entityData)
    }
    
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
      let prototype: Entity = prototypes[decider(self) % prototypes.count]
      let newProxy = prototype.makeProxy(source: self, data: systemData)
      systemData.proxies.insert(newProxy)
      lastEmitted = Date()
      emittedCount += 1
      newProxy.onBirth()
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
  
  public class Data {
    var views: Set<AnyTaggedView> = .init()
    var proxies: Set<Entity.Proxy> = .init()
    var debug: Bool = false
    var systemSize: CGSize = .zero
  }
}
