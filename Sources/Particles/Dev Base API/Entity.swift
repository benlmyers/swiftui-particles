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
  
  /// The inner content of the entity.
  /// Inner content often holds additional modifiers to apply to ``PhysicsProxy`` or ``RenderProxy`` instances upon spawn.
  var body: Self.Body { get }
  
  /// A method transforms a ``PhysicsProxy`` via ``PhysicsProxy/Context`` to an updated model upon the entity's **birth**.
  /// - Parameter context: The context of the proxy, including the proxy data and surrounding ``ParticleSystem`` data.
  /// - Returns: The updated ``PhysicsProxy`` after modifiers have been applied on birth.
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy
  
  /// A method transforms a ``PhysicsProxy`` via ``PhysicsProxy/Context`` to an updated model upon the entity's **update**.
  /// - Parameter context: The context of the proxy, including the proxy data and surrounding ``ParticleSystem`` data.
  /// - Returns: The updated ``PhysicsProxy`` after modifiers have been applied on update.
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy
  
  /// A method transforms a ``RenderProxy`` via ``RenderProxy/Context`` to an updated model upon the entity's **birth**.
  /// - Parameter context: The context of the proxy, including the proxy data and surrounding ``ParticleSystem`` data.
  /// - Returns: The updated ``RenderProxy`` after modifiers have been applied on birth.
  func onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy
  
  /// A method transforms a ``RenderProxy`` via ``RenderProxy/Context`` to an updated model upon the entity's **update**.
  /// - Parameter context: The context of the proxy, including the proxy data and surrounding ``ParticleSystem`` data.
  /// - Returns: The updated ``RenderProxy`` after modifiers have been applied on update.
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy
}

extension Never: Entity {}

// MARK: - Default Implementation

extension Entity {
  
  public func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    if self is EmptyEntity {
      return context.physics
    } else {
      return body.onPhysicsBirth(context)
    }
  }
  
  public func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    var result: PhysicsProxy
    if self is EmptyEntity {
      result = context.physics
    } else {
      result = body.onPhysicsUpdate(context)
    }
    result.velocity.dx += result.acceleration.dx
    result.velocity.dy += result.acceleration.dy
    result.position.x += result.velocity.dx
    result.position.y += result.velocity.dy
    result.rotation.degrees += result.torque.degrees
    return result
  }
  
  public func onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    if self is EmptyEntity {
      return context.render
    } else {
      return body.onRenderBirth(context)
    }
  }
  
  public func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    if self is EmptyEntity {
      return context.render
    } else {
      return body.onRenderUpdate(context)
    }
  }
  
  internal func viewToRegister() -> AnyView? {
    if let particle = self as? Particle {
      return particle.view
    } else if let burst = self as? Burst {
      return burst.view
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.viewToRegister()
    }
  }
  
  internal func underlyingGroup() -> Group? {
    if let group = self as? Group {
      return group
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingGroup()
    }
  }
  
  internal func underlyingEmitter() -> Emitter? {
    if let emitter = self as? Emitter {
      return emitter
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingEmitter()
    }
  }
  
  internal func underlyingBurst() -> Burst? {
    if let burst = self as? Burst {
      return burst
    } else if self is EmptyEntity {
      return nil
    } else {
      return body.underlyingBurst()
    }
  }
}
