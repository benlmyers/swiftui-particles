//
//  ParticleSystem.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import SwiftUI
import Foundation

struct SampleView: View {
  
  // MARK: - Views
  
  var body: some View {
    VStack {
      Text("test")
      ParticleSystem(views: {
        Text("A").tag("A")
      }) {
        
      }
    }
  }
}

struct ParticleSystem<Content>: View where Content: View {
  
  // MARK: - Parameters
  
  /// Whether the system's animation is paused.
  var paused: Bool
  /// The color mode of the renderer.
  var colorMode: ColorRenderingMode
  /// Whether to render the particles asynchronously.
  var async: Bool
  /// The (tagged) views the system will render.
  var views: () -> Content
  
  // MARK: - State
  
  /// The underlying physics for the particle system.
  @State var entities: [Entity] = []
  
  // MARK: - Views
  
  var body: some View {
    TimelineView(.animation(paused: paused)) { t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer, symbols: views)
        .onChange(of: t.date) { date in
          update()
        }
    }
  }
  
  // MARK: - Initalizers
  
  init(
    paused: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear,
    async: Bool = true,
    @ViewBuilder views: @escaping () -> Content,
    @EntitiesBuilder entities: @escaping () -> [Entity]
  ) {
    self.paused = paused
    self.colorMode = colorMode
    self.async = async
    self.views = views
    self.entities = entities()
  }
  
  // MARK: - Methods
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    for entity in entities {
      context.drawLayer { context in
        guard let resolved = context.resolveSymbol(id: entity.id) else { return }
        context.draw(resolved, at: entity.pos)
      }
    }
  }
  
  func register(entity: Entity) {
    entities.append(entity)
  }
  
  func update() {
    var toRemove: [Entity.ID] = []
    for entity in entities {
      guard entity.expiration > Date() else {
        toRemove.append(entity.id)
        continue
      }
      entity.updatePhysics()
      entity.update()
    }
    entities.removeAll(where: { toRemove.contains($0.id) })
  }
}

@resultBuilder
struct EntitiesBuilder {
  
    static func buildBlock(_ parts: Entity...) -> [Entity] {
        return parts
    }

//    static func buildEither(first component: String) -> String {
//        return component
//    }
//
//    static func buildEither(second component: String) -> String {
//        return component
//    }
//
//    static func buildArray(_ components: [String]) -> String {
//        components.joined(separator: "\n")
//    }
}

class Entity: Identifiable {
  
  // MARK: - Properties
  
  /// The entity's ID.
  var id: UUID
  /// The entity's position.
  var pos: CGPoint
  /// The entity's velocity.
  var vel: CGVector
  /// The entity's acceleration.
  var acc: CGVector
  /// The entity's size.
  var size: CGSize
  /// When the entity is to be destroyed.
  var expiration: Date
  
  // MARK: - Initalizers
  
  init(p0: CGPoint, v0: CGVector = .zero, a: CGVector = .zero, size: CGSize = .init(width: 5.0, height: 5.0), expiration: Date) {
    self.id = UUID()
    self.pos = p0
    self.vel = v0
    self.acc = a
    self.size = size
    self.expiration = expiration
  }
  
  // MARK: - Methods
  
  func updatePhysics() {
    pos = pos.apply(vel)
    vel = vel.add(acc)
  }
  
  func update() {}
}

class Emitter: Entity {
  
  // MARK: - Properties
  
  /// Whether the emitter should fire particles.
  var fire: Bool
  /// The rate at which the emitter fires, in particles per second.
  var rate: Double
  /// The lifetime to give fired particles.
  var lifetime: TimeInterval
  
  /// The particles fired by the emitter.
  var particles: [Particle] = []
  /// The fire velocity. This may be determined by the amount of particles fired and the amount of time since the emitter was created.
  var fireVelocity: (Int, TimeInterval) -> (CGVector) = { _, _ in return .zero }
  /// Whether to spawn particles independent of the emitter's velocity.
  var ignoreInheritedVelocity: Bool = false
  
  /// The date this emitter was created.
  var inception: Date = Date()
  /// The last time the emitter fired a particle.
  var lastFire: Date?
  /// The amount of particles this emitter has spawned.
  var count: Int = 0
  
  // MARK: - Initalizers
  
  init(
    p0: CGPoint,
    v0: CGVector = .zero,
    a: CGVector = .zero,
    size: CGSize = .zero,
    fire: Bool = true,
    rate: Double,
    lifetime: TimeInterval = 3.0) {
    self.fire = fire
    self.rate = rate
    self.lifetime = lifetime
    super.init(p0: p0, v0: v0, a: a, size: size, expiration: Date.distantFuture)
  }
  
  // MARK: - Override
  
  override func update() {
    emit()
  }
  
  // MARK: - Methods
  
  func emit() {
    if let lastFire {
      guard Date().timeIntervalSince(lastFire) < 1.0 / rate else { return }
    }
    let vel = fireVelocity(count, Date().timeIntervalSince(inception))
    let particle = Particle(p0: self.pos, v0: ignoreInheritedVelocity ? vel : vel.add(self.vel), expiration: Date() + lifetime)
    particles.append(particle)
    lastFire = Date()
    count += 1
  }
}

class Particle: Entity {
  
  // MARK: - Properties
  
  /// The particle's resolved Canvas image.
  var image: GraphicsContext.ResolvedSymbol
  
  // MARK: - Initalizers
  
  init?(id: String, context: GraphicsContext) {
    guard let image = context.resolveSymbol(id: id) else {
      return nil
    }
    self.image = image
  }
}

struct ParticleSystem_Previews: PreviewProvider {
  static var previews: some View {
    SampleView()
  }
}
