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
  
  internal static var data: [String: ParticleSystem.Data] = [:]
  
  // MARK: - Stored Properties
  
  internal var _data: Self.Data?
  private var _id: String?
  private var _checksTouches: Bool = true
  
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
    ZStack {
      GeometryReader { proxy in
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { [self] t in
          Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: false, renderer: renderer) {
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
      #if os(iOS)
      if _checksTouches {
        TapView { touch, optLocation in
          data.touches[touch] = optLocation
          print(data.touches.count)
        }
      }
      #endif
    }
    .onDisappear {
      if let _id {
        ParticleSystem.data.removeValue(forKey: _id)
      }
    }
  }
  
  private var debugView: some View {
    VStack(alignment: .leading, spacing: 2.0) {
      Text(data.performanceSummary())
        .lineLimit(99)
        .fixedSize(horizontal: false, vertical: false)
        .multilineTextAlignment(.leading)
    }
    .font(.caption2)
    .opacity(0.5)
  }
  
  // MARK: - Initalizers
  
  /// Creates a particle system with the passed entity/entities.
  /// Any entities passed will have one copy created at the start of the system's simulation.
  /// - Parameter entity: The entity or entities to create when the system begins.
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
  /// State persistent particle systems to not reset their simulations when the view is re-rendered.
  /// - Parameter id: A `String` ID to use for the particle system. A unique ID will allow the system to persist across state updates.
  /// - Parameter refreshesViews: Whether view refreshes at the top level should reset and re-render all particle views. Default `false`.
  public func statePersistent(_ id: String, refreshesViews: Bool = false) -> ParticleSystem {
    var copy = self
    copy._id = id
    if !Self.data.contains(where: { $0.key == id }) {
      Self.data[id] = .init()
    } else if refreshesViews {
      Self.data[id]?.refreshViews = true
    }
    Self.data[id]?.initialEntity = copy._data?.initialEntity
    copy._data = nil
    return copy
  }
  
  /// Sets whether this particle system checks and updates ``ParticleSystem/Data/touches``.
  /// - Parameter flag: Whether to update `touches`.
  public func checksTouches(_ flag: Bool = true) -> ParticleSystem {
    var copy = self
    copy._checksTouches = flag
    return copy
  }
  
  private func renderer(_ context: inout GraphicsContext, size: CGSize) {
    context.stroke(.init(roundedRect: .init(x: 0.0, y: 0.0, width: size.width, height: size.height), cornerSize: .zero), with: .color(.white.opacity(0.001)))
    self.data.update(context: context, size: size)
  }
}

//----

#if os(iOS)

import UIKit
import Foundation

class NFingerGestureRecognizer: UIGestureRecognizer {
  
  var tappedCallback: (UITouch, CGPoint?) -> Void
  
  var touchViews = [UITouch:CGPoint]()
  
  init(target: Any?, tappedCallback: @escaping (UITouch, CGPoint?) -> ()) {
    self.tappedCallback = tappedCallback
    super.init(target: target, action: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let location = touch.location(in: touch.view)
      // print("Start: (\(location.x)/\(location.y))")
      touchViews[touch] = location
      tappedCallback(touch, location)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let newLocation = touch.location(in: touch.view)
      // let oldLocation = touchViews[touch]!
      // print("Move: (\(oldLocation.x)/\(oldLocation.y)) -> (\(newLocation.x)/\(newLocation.y))")
      touchViews[touch] = newLocation
      tappedCallback(touch, newLocation)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      // let oldLocation = touchViews[touch]!
      // print("End: (\(oldLocation.x)/\(oldLocation.y))")
      touchViews.removeValue(forKey: touch)
      tappedCallback(touch, nil)
    }
  }
  
}

struct TapView: UIViewRepresentable {
  
  var tappedCallback: (UITouch, CGPoint?) -> Void
  
  func makeUIView(context: UIViewRepresentableContext<TapView>) -> TapView.UIViewType {
    let v = UIView(frame: .zero)
    let gesture = NFingerGestureRecognizer(target: context.coordinator, tappedCallback: tappedCallback)
    v.addGestureRecognizer(gesture)
    return v
  }
  
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<TapView>) {
    // empty
  }
  
}
#endif

