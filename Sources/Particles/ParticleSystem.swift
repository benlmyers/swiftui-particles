//
//  ParticleSystem.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import SwiftUI
import Foundation

fileprivate struct SampleView: View {
  
  // MARK: - Views
  
  var body: some View {
    VStack {
      Text("test")
      ParticleSystem {
        Emitter {
          Text("x")
          Text("o")
        }
      }
    }
  }
}

public struct ParticleSystem<Content>: View where Content: View {
  
  // MARK: - Properties
  
  /// Whether the system's animation is paused.
  var paused: Bool = false
  /// The color mode of the renderer.
  var colorMode: ColorRenderingMode = .nonLinear
  /// Whether to render the particles asynchronously.
  var async: Bool = true
  
  /// The system's distinct views to render.
  var views: Box<[Content]> = .init([])
  /// A map of entity IDs to view indices.
  var idMap: Box<[Entity<Content>.ID: Int]> = .init([:])
  
  // MARK: - State
  
  /// The underlying physics for the particle system.
  var entities: [Entity<Content>] = []
  
  // MARK: - Views
  
  public var body: some View {
    TimelineView(.animation(paused: paused)) { t in
      Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
        ForEach(0 ..< views.item.count) { i in
          views.item[i].tag(i)
        }
      }
      .onChange(of: t.date) { date in
        update()
      }
    }
  }
  
  // MARK: - Initalizers
  
  public init(@ParticleSystemBuilder entities: @escaping () -> [Entity<Content>]) {
    let entities = entities()
    for entity in entities {
      self.entities.append(entity)
    }
    for entity in self.entities {
      entity.views = self.views
      entity.idMap = self.idMap
    }
  }
  
  // MARK: - Methods
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    for entity in entities {
      entity.render(context)
    }
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
    //entities.removeAll(where: { toRemove.contains($0.id) })
  }
}

@resultBuilder
public struct ParticleSystemBuilder {
  
  public static func buildBlock<Content>(_ parts: Entity<Content>...) -> [Entity<Content>] where Content: View {
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

protocol Renderable {
  func render(_ context: GraphicsContext)
}

public class Entity<Content>: Identifiable, Renderable where Content: View {
  
  // MARK: - Properties
  
  /// The entity's ID.
  public var id: UUID = UUID()
  
  /// A reference to the entity's parent system of views.
  unowned var views: Box<[Content]>?
  /// A reference to the entity's parent system's id mappings.
  unowned var idMap: Box<[Entity<Content>.ID: Int]>?
  
  /// The entity's position.
  var pos: CGPoint = .zero
  /// The entity's velocity.
  var vel: CGVector = .zero
  /// The entity's acceleration.
  var acc: CGVector = .zero
  /// The entity's size.
  var size: CGSize = .zero
  
  /// When the entity was created.
  var inception: Date = Date()
  /// When the entity is to be destroyed.
  var expiration: Date = .distantFuture
  
  // MARK: - Initalizers
  
  init(_ p0: CGPoint, _ v0: CGVector, _ a: CGVector) {
    self.pos = p0
    self.vel = v0
    self.acc = a
  }
  
  init() {
    
  }
  
  // MARK: - Implementation
  
  func render(_ context: GraphicsContext) {
    // Do nothing
  }
  
  // MARK: - Methods
  
  func updatePhysics() {
    pos = pos.apply(vel)
    vel = vel.add(acc)
  }
  
  func update() {}
}

public class Emitter<Content>: Entity<Content> where Content: View {
  
  // MARK: - Properties
  
  /// Whether the emitter should fire particles.
  var fire: Bool = true
  /// The rate at which the emitter fires, in particles per second.
  var rate: Double = 1.0
  /// The lifetime to give fired particles.
  var lifetime: TimeInterval = 5.0
  
  /// The prototypical views that this emitter creates particles for.
  var protos: [Content]
  /// The particles fired by the emitter.
  var particles: [Particle<Content>] = []
  /// The fire velocity. This may be determined by the amount of particles fired and the amount of time since the emitter was created.
  var fireVelocity: (Int, TimeInterval) -> CGVector = { _, _ in return .zero }
  /// The emit chooser. This is determined by the amount of particles fired and the amount of time since the emitter was created.
  var chooser: (Int, TimeInterval) -> Int
  /// Whether to spawn particles independent of the emitter's velocity.
  var useInheritedVelocity: Bool = true
  
  /// The last time the emitter fired a particle.
  var lastFire: Date?
  /// The amount of particles this emitter has spawned.
  var count: Int = 0
  
  // MARK: - Initalizers
  
  public init(@EmitterBuilder views: @escaping () -> [Content]) where Content: View {
    let views: [Content] = views()
    self.protos = views
    self.chooser = { _, _ in return Int.random(in: 0 ..< views.count) }
    super.init()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.00001) {
      guard var _views = self.views, var _idMap = self.idMap else {
        fatalError("The particle system could not be accessed by the particle.")
      }
      for view in views {
        _views.item.append(view)
        _idMap.item[self.id] = _views.item.count - 1
      }
    }
  }
  
  // MARK: - Override
  
  override func update() {
    if let lastFire {
      guard Date().timeIntervalSince(lastFire) < 1.0 / rate else { return }
    }
    emit()
  }
  
  // MARK: - Overrides
  
  override func render(_ context: GraphicsContext) {
    for particle in particles {
      particle.render(context)
    }
  }
  
  // MARK: - Methods
  
  func emit() {
    let interval: TimeInterval = Date().timeIntervalSince(inception)
    let vel: CGVector = fireVelocity(count, interval)
    let i: Int = chooser(count, interval)
    guard var views = self.views else {
      fatalError("The particle system could not be accessed by the particle.")
    }
    guard !views.item.isEmpty else {
      fatalError("The particle system did not have any prototypical views.")
    }
    guard i < views.item.count else {
      fatalError("Out of bounds: Your chooser closure looked for content of index \(i), but this emitter only has content up to index \(views.item.count).")
    }
    let view: Content = views.item[i]
    var particle: Particle = Particle(view, p0: pos, v0: useInheritedVelocity ? self.vel.add(vel) : vel, a: .zero)
    particle.views = self.views
    particle.idMap = self.idMap
    self.particles.append(particle)
    lastFire = Date()
    count += 1
  }
}

@resultBuilder
public struct EmitterBuilder {
  
  public static func buildBlock<Content>(_ parts: Content...) -> [Content] where Content: View {
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
  
  // MARK: - Properties
  
  var view: Content
  
  // MARK: - Initializers
  
  init(_ view: Content, p0: CGPoint, v0: CGVector, a: CGVector) {
    self.view = view
    super.init(p0, v0, a)
  }
  
  // MARK: - Overrides
  
  override func render(_ context: GraphicsContext) {
    context.drawLayer { context in
      let index = resolveTagIndex(from: self.id)
      guard let resolved = context.resolveSymbol(id: index) else { return }
      context.draw(resolved, at: pos)
    }
  }
  
  // MARK: - Methods
  
  func resolveTagIndex(from entityID: Entity.ID) -> Int {
    guard var idMap = self.idMap else {
      fatalError("The particle system could not be accessed by the particle.")
    }
    guard let i = idMap.item[entityID] else {
      fatalError("A problem occured trying to resolve entity ID \(entityID) in the following map: \(idMap.item)")
    }
    return i
  }
}

struct ParticleSystem_Previews: PreviewProvider {
  static var previews: some View {
    SampleView()
  }
}
