//
//  Entity.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

// MARK: - Protocol Definition

/// A protocol used to define the behavior of objects within a ``ParticleSystem``.
/// Like views in SwiftUI, new entity types can be defined using ``Entity/body`` conformance:
/// ```
/// struct MyCustomParticle: Entity {
///   var body: some Entity {
///     Particle { Text("☀️") }
///       .hueRotation(.degrees(45.0))
///       .scale({ _ in .random(in: 1.0 ... 3.0) })
///   }
/// }
/// ```
public protocol Entity {
  
  associatedtype Body: Entity
  
  var _confirmedEmptyUnderlyingEmitter: Bool { get set }
  
  /// The inner content of the entity.
  /// Inner content often holds additional modifiers to apply to ``PhysicsProxy`` or ``RenderProxy`` instances upon spawn.
  var body: Self.Body { get }
  
  /// A method transforms a ``PhysicsProxy`` via ``PhysicsProxy/Context`` to an updated model upon the entity's **birth**.
  /// - Parameter context: The context of the proxy, including the proxy data and surrounding ``ParticleSystem`` data.
  /// - Returns: The updated ``PhysicsProxy`` after modifiers have been applied on birth.
  func _onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy
  
  /// A method transforms a ``PhysicsProxy`` via ``PhysicsProxy/Context`` to an updated model upon the entity's **update**.
  /// - Parameter context: The context of the proxy, including the proxy data and surrounding ``ParticleSystem`` data.
  /// - Returns: The updated ``PhysicsProxy`` after modifiers have been applied on update.
  func _onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy
  
  /// A method transforms a ``RenderProxy`` via ``RenderProxy/Context`` to an updated model upon the entity's **birth**.
  /// - Parameter context: The context of the proxy, including the proxy data and surrounding ``ParticleSystem`` data.
  /// - Returns: The updated ``RenderProxy`` after modifiers have been applied on birth.
  func _onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy
  
  /// A method transforms a ``RenderProxy`` via ``RenderProxy/Context`` to an updated model upon the entity's **update**.
  /// - Parameter context: The context of the proxy, including the proxy data and surrounding ``ParticleSystem`` data.
  /// - Returns: The updated ``RenderProxy`` after modifiers have been applied on update.
  func _onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy
}

extension Never: Entity {
  public var _confirmedEmptyUnderlyingEmitter: Bool { get { .init() } set {}}
}

// MARK: - Default Implementation

extension Entity {
  
  private var _initialPhysicsCarried: PhysicsProxy? { get { .init(currentFrame: 0) } set {}}
  private var _initialRenderCarried: RenderProxy { get { .init() } set {}}
  
  public var _confirmedEmptyUnderlyingEmitter: Bool { get { false } set {}}
  
  public func _onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    if self is EmptyEntity {
      return context.physics
    } else {
      return body._onPhysicsBirth(context)
    }
  }
  
  public func _onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    var result: PhysicsProxy
    if self is EmptyEntity {
      result = context.physics
    } else {
      result = body._onPhysicsUpdate(context)
    }
    result.velocity.dx += result.acceleration.dx
    result.velocity.dy += result.acceleration.dy
    result.position.x += result.velocity.dx
    result.position.y += result.velocity.dy
    result.rotation.degrees += result.torque.degrees
    return result
  }
  
  public func _onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    if self is EmptyEntity {
      return context.render
    } else {
      return body._onRenderBirth(context)
    }
  }
  
  public func _onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    if self is EmptyEntity {
      return context.render
    } else {
      return body._onRenderUpdate(context)
    }
  }
  
  internal func viewToRegister() -> AnyView? {
    let performanceTimer = PerformanceTimer(title: "VIEW TO REGISTER")
    performanceTimer.calculateElapsedTime()
    if let particle = self as? Particle {
      return particle.view
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.viewToRegister()
    }
  }
  
  internal func underlyingGroup() -> Group? {
    let performanceTimer = PerformanceTimer(title: "UNDERLYING GROUP")
    performanceTimer.calculateElapsedTime()
    if let group = self as? Group {
      return group
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingGroup()
    }
  }
  
  internal func underlyingEmitter() -> Emitter? {
    if _confirmedEmptyUnderlyingEmitter {
      return nil
    }
    let performanceTimer = PerformanceTimer(title: "UNDERLYING EMITTER")
    performanceTimer.calculateElapsedTime()
    if let emitter = self as? Emitter {
      return emitter
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingEmitter()
    }
  }
  
//  internal func underlyingBurst() -> Burst? {
//    if let burst = self as? Burst {
//      return burst
//    } else if self is EmptyEntity {
//      return nil
//    } else {
//      return body.underlyingBurst()
//    }
//  }
  
  internal func underlyingTransitions() -> [(AnyTransition, TransitionBounds, Double)] {
    var result: [(AnyTransition, TransitionBounds, Double)] = []
    if let e = self as? TransitionEntity<Body> {
      result.append((e.transition, e.bounds, e.duration))
    } else if self is EmptyEntity {
      return result
    }
    result.append(contentsOf: body.underlyingTransitions())
    return result
  }
  
  internal func underlyingGlow() -> (Color, CGFloat)? {
    if let glowEntity = self as? GlowEntity<Body> {
      return (glowEntity.color, glowEntity.radius)
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingGlow()
    }
  }
  
  internal func underlyingColorOverlay() -> Color? {
    if let colorOverlay = self as? ColorOverlayEntity<Body> {
      return colorOverlay.color
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingColorOverlay()
    }
  }
}
