//
//  ParticleSystem.swift
//
//
//  Created by Ben Myers on 10/2/23.
//

import SwiftUI
import Foundation

/// A particle system declaration.
///
/// This creates a `Canvas`, with a greedy size, displaying a system of configurable particles and other entities.
/// To add entities to the system, declare them within ``ParticleSystem`` inside a `View`:
///
/// ```swift
/// var body: some View {
///   Text("Here's a particle system:")
///   ParticleSystem {
///     Emitter {
///       Particle(color: .green)
///     }
///   }
/// }
/// ```
public struct ParticleSystem: View {
  
  // MARK: - Properties
  
  private var colorMode: ColorRenderingMode = .nonLinear
  private var async: Bool = true
  
  private var data: Self.Data
  
  // MARK: - Body View
  
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
  
  // MARK: - Initalizers
  
  /// Creates a particle system using the declared entities.
  /// - Parameters:
  ///   - data: The particle system's data. Provide your own to enable state updates.
  ///   - entities: Any number of ``Entity``s, such as ``Particle``s or ``Emitter``s.
  public init(data: Self.Data = .init(), @Builder<Entity> entities: @escaping () -> [Entity]) {
    self.data = data
    if !self.data.prepared {
      self.data.proxies = entities().map({ $0.makeProxy(source: nil, data: data) })
      self.data.prepared = true
    }
    for proxy in self.data.proxies {
      proxy.onBirth(nil)
    }
  }
  
  // MARK: - Methods
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
    self.data.systemSize = size
    for proxy in data.proxies {
      proxy.onUpdate(&context)
    }
  }
  
  func destroyExpired() {
    data.proxies.removeAll { proxy in
      let kill = Date() >= proxy.expiration
      if kill {
        proxy.onDeath()
      }
      return kill
    }
  }
  
  // MARK: - Subtypes
  
  public class Data {
    var prepared: Bool = false
    var views: Set<AnyTaggedView> = .init()
    var proxies: [Entity.Proxy] = []
    var debug: Bool = false
    public internal(set) var systemSize: CGSize = .zero
    
    public init() {}
  }
}
