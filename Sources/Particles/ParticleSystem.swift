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
      ParticleSystem {
        Emitter {
          Text("x")
        }
      }
    }
  }
}

struct ParticleSystem<Content>: View where Content: View {
  
  // MARK: - Properties
  
  /// Whether the system's animation is paused.
  var paused: Bool = false
  /// The color mode of the renderer.
  var colorMode: ColorRenderingMode = .nonLinear
  /// Whether to render the particles asynchronously.
  var async: Bool = true
  
  /// The system's distinct views to render.
  var views: [Content] = []
  
  // MARK: - State
  
  /// The underlying physics for the particle system.
  @State var entities: [Entity<Content>] = []
  
  // MARK: - Views
  
  var body: some View {
    TimelineView(.animation(paused: paused)) { t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
        
      }
      .onChange(of: t.date) { date in
        update()
      }
    }
  }
  
  // MARK: - Initalizers
  
  init(
    @ParticleSystemBuilder entities: @escaping () -> [Entity<Content>]
  ) {
    self.entities = entities()
    for entity in self.entities {
      entity.system = self
    }
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
  
  func register(entity: Entity<Content>) {
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
struct ParticleSystemBuilder {
  
  static func buildBlock<Content>(_ parts: Entity<Content>...) -> [Entity<Content>] where Content: View {
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

class Entity<Content>: Identifiable where Content: View {
  
  // MARK: - Properties
  
  /// The entity's parent system.
  var system: ParticleSystem<Content>?
  /// The entity's ID.
  var id: UUID = UUID()
  /// The entity's position.
  var pos: CGPoint = .zero
  /// The entity's velocity.
  var vel: CGVector = .zero
  /// The entity's acceleration.
  var acc: CGVector = .zero
  /// The entity's size.
  var size: CGSize = .zero
  /// When the entity is to be destroyed.
  var expiration: Date = .distantFuture
  
  // MARK: - Methods
  
  func updatePhysics() {
    pos = pos.apply(vel)
    vel = vel.add(acc)
  }
  
  func update() {}
}

class Emitter<Content>: Entity<Content> where Content: View {
  
  // MARK: - Properties
  
  /// Whether the emitter should fire particles.
  var fire: Bool = true
  /// The rate at which the emitter fires, in particles per second.
  var rate: Double = 1.0
  /// The lifetime to give fired particles.
  var lifetime: TimeInterval = 5.0
  
  /// The particles fired by the emitter.
  var particles: [Particle<Content>] = []
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
  
  init(@EmitterBuilder views: @escaping () -> [Content]) where Content: View {
    super.init()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
      guard var system = self.system else {
        fatalError("The particle views were not present in the particle system.")
      }
      for view in views() {
        system.views.append(view)
      }
    }
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
    // TODO: Implement emission
    lastFire = Date()
    count += 1
  }
}

@resultBuilder
struct EmitterBuilder {
  
  static func buildBlock<Content>(_ parts: Content...) -> [Content] where Content: View {
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

class Particle<Content>: Entity<Content> where Content: View {
}

struct ParticleSystem_Previews: PreviewProvider {
  static var previews: some View {
    SampleView()
  }
}
