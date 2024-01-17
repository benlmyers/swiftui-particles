//
//  Entity+Physics.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

public extension Entity {
  
  /// Sets the initial position of the entity.
  /// - Parameters:
  ///   - x: The x-position, in pixels, to set the entity upon creation. Set to `nil` for no behavior.
  ///   - y: The y-position, in pixels, to set the entity upon creation. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func initialPosition(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x {
        p.position.x = x
      }
      if let y = y {
        p.position.y = y
      }
      return p
    })
  }
  
  /// Sets the initial position of the entity.
  /// - Parameters:
  ///   - point: A closure returning the 2D point, in pixels, to set the entity upon creation.
  ///   - y: A closure returning the y-position, in pixels, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialPosition(_ point: @escaping (PhysicsProxy.Context) -> CGPoint) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      let point = point(context)
      p.position.x = point.x
      p.position.y = point.y
      return p
    })
  }
  
  /// Sets the initial position of the entity relative to the size of its parent ``ParticleSystem``.
  /// - Parameters:
  ///   - point: The relative location to position the entity at birth.
  /// - Returns: The modified entity.
  func initialPosition(_ point: UnitPoint) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let w = context.system?.size.width {
        p.position.x = w * point.x
      }
      if let h = context.system?.size.height {
        p.position.y = h * point.y
      }
      return p
    })
  }
  
  /// Offsets the initial position of the entity by the specified amounts.
  /// - Parameters:
  ///   - x: The x-offset, in pixels, to apply to the initial position. Set to `nil` for no behavior.
  ///   - y: The y-offset, in pixels, to apply to the initial position. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func initialOffset(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x {
        p.position.x += x
      }
      if let y = y {
        p.position.y += y
      }
      return p
    })
  }
  
  /// Offsets the initial position of the entity by the amounts returned by the provided closures.
  /// - Parameters:
  ///   - x: A closure returning the x-offset, in pixels, to apply to the initial position.
  ///   - y: A closure returning the y-offset, in pixels, to apply to the initial position.
  /// - Returns: The modified entity.
  func initialOffset(
    x: @escaping (PhysicsProxy.Context) -> CGFloat? = { _ in nil },
    y: @escaping (PhysicsProxy.Context) -> CGFloat? = { _ in nil }
  ) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.position.x += x
      }
      if let y = y(context) {
        p.position.y += y
      }
      return p
    })
  }
  
  /// Sets the constant position of the entity.
  /// - Parameters:
  ///   - x: The x-position, in pixels, to set the entity's position to. Set to `nil` for no behavior.
  ///   - y: The y-position, in pixels, to set the entity's position to. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func setPosition(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x {
        p.position.x = x
      }
      if let y = y {
        p.position.y = y
      }
      return p
    })
  }
  
  /// Sets the position of the entity relative to the size of its parent ``ParticleSystem``.
  /// - Parameters:
  ///   - point: The relative location to position the entity on update.
  /// - Returns: The modified entity.
  func setPosition(_ point: UnitPoint) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      guard let size = context.system?.size else {
        return p
      }
      p.position.x = size.width * point.x
      p.position.y = size.height * point.y
      return p
    })
  }
  
  /// Sets the constant position of the entity using the values returned by the provided closures.
  /// ⚠️ **Warning:** Be sure to specify a return type of `CGPoint` or `UnitPoint` explicitly.
  /// - Parameters:
  ///   - point: A closure returning the 2D point, in pixels, to set the entity's position to.
  /// - Returns: The modified entity.
  func setPosition(_ point: @escaping (PhysicsProxy.Context) -> CGPoint) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      let point = point(context)
      p.position.x = point.x
      p.position.y = point.y
      return p
    })
  }
  
  /// Sets the position of the entity relative to the size of its parent ``ParticleSystem`` using the provided closure.
  /// ⚠️ **Warning:** Be sure to specify a return type of `CGPoint` or `UnitPoint` explicitly.
  /// - Parameters:
  ///   - point: The relative location to position the entity on update.
  /// - Returns: The modified entity.
  func setPosition(_ point: @escaping (PhysicsProxy.Context) -> UnitPoint) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      let point = point(context)
      guard let size = context.system?.size else {
        return p
      }
      p.position.x = size.width * point.x
      p.position.y = size.height * point.y
      return p
    })
  }
  
  /// Sets the initial velocity of the entity.
  /// - Parameters:
  ///   - x: The x-velocity, in pixels per frame, to set the entity upon creation. Set to `nil` for no behavior.
  ///   - y: The y-velocity, in pixels per frame, to set the entity upon creation. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func initialVelocity(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x {
        p.velocity.dx = x
      }
      if let y = y {
        p.velocity.dy = y
      }
      return p
    })
  }
  
  /// Sets the initial velocity of the entity using the values returned by the provided closures.
  /// - Parameters:
  ///   - velocity: A closure returning the 2D velocity, in pixels per frame, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialVelocity(_ velocity: @escaping (PhysicsProxy.Context) -> CGVector) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      let v = velocity(context)
      p.velocity.dx = v.dx
      p.velocity.dy = v.dy
      return p
    })
  }
  
  /// Sets the constant velocity of the entity.
  /// - Parameters:
  ///   - x: The x-velocity, in pixels per frame, to set the entity's velocity to. Set to `nil` for no behavior.
  ///   - y: The y-velocity, in pixels per frame, to set the entity's velocity to. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func setVelocity(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x {
        p.velocity.dx = x
      }
      if let y = y {
        p.velocity.dy = y
      }
      return p
    })
  }
  
  /// Sets the constant velocity of the entity using the values returned by the provided closures.
  /// - Parameters:
  ///   - velocity: A closure returning the 2D- velocity, in pixels per frame, to set the entity's velocity to.
  /// - Returns: The modified entity.
  func setVelocity(_ velocity: @escaping (PhysicsProxy.Context) -> CGVector) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      let v = velocity(context)
      p.velocity.dx = v.dx
      p.velocity.dy = v.dy
      return p
    })
  }
  
  /// Sets the initial acceleration of the entity.
  /// - Parameters:
  ///   - x: The x-acceleration, in pixels per second squared, to set the entity upon creation. Set to `nil` for no behavior.
  ///   - y: The y-acceleration, in pixels per second squared, to set the entity upon creation. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func initialAcceleration(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x {
        p.acceleration.dx = x
      }
      if let y = y {
        p.acceleration.dy = y
      }
      return p
    })
  }
  
  /// Sets the initial acceleration of the entity using the values returned by the provided closures.
  /// - Parameters:
  ///   - acceleration: A closure returning the acceleration, in pixels per second squared, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialAcceleration(_ acceleration: @escaping (PhysicsProxy.Context) -> CGVector) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      let a = acceleration(context)
      p.acceleration.dx = a.dx
      p.acceleration.dy = a.dy
      return p
    })
  }
  
  /// Sets the constant acceleration of the entity.
  /// - Parameters:
  ///   - x: The x-acceleration, in pixels per second squared, to set the entity's acceleration to. Set to `nil` for no behavior.
  ///   - y: The y-acceleration, in pixels per second squared, to set the entity's acceleration to. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func setAcceleration(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x {
        p.acceleration.dx = x
      }
      if let y = y {
        p.acceleration.dy = y
      }
      return p
    })
  }
  
  /// Sets the constant acceleration of the entity using the values returned by the provided closures.
  /// - Parameters:
  ///   - x: A closure returning the x-acceleration, in pixels per second squared, to set the entity's acceleration to.
  ///   - y: A closure returning the y-acceleration, in pixels per second squared, to set the entity's acceleration to.
  /// - Returns: The modified entity.
  func setAcceleration(_ acceleration: @escaping (PhysicsProxy.Context) -> CGVector) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      let a = acceleration(context)
      p.acceleration.dx = a.dx
      p.acceleration.dy = a.dy
      return p
    })
  }
  
  /// Sets the initial rotation of the entity.
  /// - Parameter angle: The initial rotation angle of the entity.
  /// - Returns: The modified entity.
  func initialRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  
  /// Sets the initial rotation of the entity using the value returned by the provided closure.
  /// - Parameter angle: A closure returning the initial rotation angle of the entity.
  /// - Returns: The modified entity.
  func initialRotation(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.rotation = angle(context)
      return p
    })
  }
  
  /// Sets the constant rotation of the entity.
  /// - Parameter angle: The constant rotation angle of the entity.
  /// - Returns: The modified entity.
  func setRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  
  /// Sets the constant rotation of the entity using the value returned by the provided closure.
  /// - Parameter angle: A closure returning the constant rotation angle of the entity.
  /// - Returns: The modified entity.
  func setRotation(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.rotation = angle(context)
      return p
    })
  }
  
  /// Sets the initial torque of the entity.
  /// - Parameter angle: The initial torque angle of the entity.
  /// - Returns: The modified entity.
  func initialTorque(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.torque = angle
      return p
    })
  }
  
  /// Sets the initial torque of the entity using the value returned by the provided closure.
  /// - Parameter angle: A closure returning the initial torque angle of the entity.
  /// - Returns: The modified entity.
  func initialTorque(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.torque = angle(context)
      return p
    })
  }
  
  /// Sets the constant torque of the entity.
  /// - Parameter angle: A closure returning the constant torque angle of the entity.
  /// - Returns: The modified entity.
  func setTorque(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.torque = angle
      return p
    })
  }
  
  /// Sets the constant torque of the entity using the value returned by the provided closure.
  /// - Parameter angle: A closure returning the constant torque angle of the entity.
  /// - Returns: The modified entity.
  func setTorque(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.torque = angle(context)
      return p
    })
  }
  
  /// Sets the lifetime of the entity.
  /// - Parameter value: The lifetime of the entity, in seconds.
  /// - Returns: The modified entity.
  func lifetime(_ value: Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.lifetime = value
      return p
    })
  }
  
  /// Sets the lifetime of the entity using the value returned by the provided closure.
  /// - Parameter value: A closure returning the lifetime of the entity, in seconds.
  /// - Returns: The modified entity.
  func lifetime(_ value: @escaping (PhysicsProxy.Context) -> Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.lifetime = value(context)
      return p
    })
  }
}
