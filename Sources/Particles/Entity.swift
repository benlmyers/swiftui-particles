//
//  Entity.swift
//
//
//  Created by Ben Myers on 9/30/23.
//

import SwiftUI
import Foundation

public class Entity {
  
  var modifiers: [EntityModifier] = []
  
  func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    let newProxy = Proxy(data: data)
    newProxy.systemData = data
    return newProxy
  }
  
  public class Proxy: Identifiable, Hashable, Equatable {
    
    final weak var systemData: ParticleSystem.Data?
    
    public final let id: UUID = UUID()
    
    var inception: Date = Date()
    var lifetime: TimeInterval = 5.0
    
    var position: CGPoint = .zero
    var velocity: CGVector = .zero
    var rotation: Angle = .zero
    
    var expiration: Date {
      return inception + lifetime
    }
    
    var timeAlive: TimeInterval {
      return Date().timeIntervalSince(inception)
    }
    
    var lifetimeProgress: Double {
      return timeAlive / lifetime
    }
    
    init(data: ParticleSystem.Data) {
      self.systemData = data
    }
    
    public static func == (lhs: Proxy, rhs: Proxy) -> Bool {
      return lhs.id == rhs.id
    }
    
    func onUpdate(_ context: inout GraphicsContext) {}
    func onBirth() {}
    func onDeath() {}
    
    public func hash(into hasher: inout Hasher) {
      return id.hash(into: &hasher)
    }
  }
}

extension Entity {
  
  func start<T, V>(_ path: KeyPath<T, V>, at value: V) -> Self where T: Entity {
    let copy = self
    let modifier = EntityModifier(path: path, behavior: .startsAt(value))
    copy.modifiers.append(modifier)
    return copy
  }
}

public struct EntityModifier {
  
  var path: AnyKeyPath
  var behavior: Behavior
  
  enum Behavior {
    case startsAt(Any)
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
  
  public override func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    if let taggedView {
      data.views.insert(taggedView)
    }
    let newProxy = Proxy(onDraw: onDraw, data: data)
    newProxy.systemData = data
    return newProxy
  }
  
  public class Proxy: Entity.Proxy {
    
    var opacity: Double = 1.0
    var scaleEffect: CGFloat = 1.0
    var blur: CGFloat = .zero
    var hueRotation: Angle = .zero
    
    private var onDraw: (inout GraphicsContext) -> Void
    
    init(onDraw: @escaping (inout GraphicsContext) -> Void, data: ParticleSystem.Data) {
      self.onDraw = onDraw
      super.init(data: data)
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

public class Emitter: Entity {
  
  private var prototypes: [Entity]
  
  public init(@Builder<Entity> entities: @escaping () -> [Entity]) {
    self.prototypes = entities()
  }
  
  public override func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    let result = Proxy(prototypes: prototypes, data: data)
    return result
  }
  
  public class Proxy: Entity.Proxy {
    
    var prototypes: [Entity]
    var lastEmitted: Date?
    var emittedCount: Int = 0
    
    var fireRate: Double = 1.0
    var decider: (Proxy) -> Int = { _ in Int.random(in: 0 ... .max) }
    
    init(prototypes: [Entity], data: ParticleSystem.Data) {
      self.prototypes = prototypes
      super.init(data: data)
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
  
  public init(_ entity:Particle) {
    self.data = Data()
    self.data.proxies = [entity.makeProxy(source: nil, data: data)]
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
