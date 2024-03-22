//
//  ParticleSystem.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

/// A view used to display particles.
/// A ``ParticleSystem`` can be created within views. The behavior of ``Entity`` objects, or "particles", is controlled by what is passed declaratively, like in SwiftUI:
/// ```
/// var body: some View {
///   ParticleSystem {
///     Emitter {
///       Particle {
///         Circle().foregroundColor(.red).frame(width: 20.0, height: 20.0)
///       }
///     }
///     .initialPosition(.center)
///     .initialVelocity(y: 0.5)
///   }
/// }
/// ```
public struct ParticleSystem: View {
  
  internal typealias EntityID = UInt
  internal typealias ProxyID = UInt
  internal typealias GroupID = UInt
  
  // MARK: - Static Properties
  
  static var data: [String: ParticleSystem.Data] = [:]
  
  // MARK: - Stored Properties
  
  internal var _data: Self.Data?
  private var _id: String?
  
  internal var data: Self.Data {
    if let _data {
      return _data
    } else if let _id {
      if let d = Self.data[_id] {
        return d
      } else {
        Self.data[_id] = .init()
        return Self.data[_id]!
      }
    } else {
      fatalError()
    }
  }
  
  // MARK: - Computed Properties
  
  public var body: some View {
    GeometryReader { proxy in
      TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { [self] t in
        Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: true, renderer: renderer) {
          Text("❌").tag("NOT_FOUND")
          SwiftUI.ForEach(Array(data.viewPairs()), id: \.1) { (pair: (AnyView, EntityID)) in
            pair.0.tag(pair.1)
          }
        }
        .border(data.debug ? Color.red.opacity(0.5) : Color.clear)
        .overlay {
          HStack {
            if data.debug {
              VStack {
                debugView
                Spacer()
              }
              Spacer()
            }
          }
        }
      }
    }
  }
  
  private var debugView: some View {
    VStack(alignment: .leading, spacing: 2.0) {
      Text(data.memorySummary())
        .lineLimit(99)
        .fixedSize(horizontal: false, vertical: false)
        .multilineTextAlignment(.leading)
    }
    .font(.caption2)
    .opacity(0.5)
  }
  
  // MARK: - Initalizers
  
  public init<E>(@EntityBuilder entity: () -> E) where E: Entity {
    let e: E = entity()
    self._data = .init()
    self._data?.initialEntity = e
  }
  
  // MARK: - Methods
  
  /// Enables debug mode for this particle system.
  /// When enabled, a border is shown around the system's edges, and statistics are displayed.
  /// - Returns: A modified `ParticleSystem`
  public func debug() -> ParticleSystem {
    self.data.debug = true
    return self
  }
  
  /// Marks this particle system as **state persistent**.
  /// State persistent particle systems to not reset their simulations when the view is re-rendered
  public func statePersistent(_ id: String) -> ParticleSystem {
    var copy = self
    copy._id = id
    if !Self.data.contains(where: { $0.key == id }) {
      Self.data[id] = .init()
    }
    Self.data[id]?.initialEntity = copy._data?.initialEntity
    copy._data = nil
    return copy
  }
  
  private func renderer(_ context: inout GraphicsContext, size: CGSize) {
    self.data.size = size
    if let initialEntity = self.data.initialEntity, data.currentFrame > 1 {
      if self.data.nextEntityRegistry > .zero {
        self.data.nextEntityRegistry = .zero
        self.data.createSingle(entity: initialEntity, spawn: false)
      } else {
        self.data.createSingle(entity: initialEntity, spawn: true)
      }
      self.data.initialEntity = nil
    }
    data.performRenders(&context)
    data.updatePhysics()
    data.updateRenders()
    data.destroyExpiredEntities()
    data.advanceFrame()
    data.emitChildren()
  }
}
