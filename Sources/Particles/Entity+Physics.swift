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
  ///   - x: The x-position, in pixels, to set the entity upon creation.
  ///   - y: The y-position, in pixels, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialPosition(x: CGFloat?, y: CGFloat?) -> some Entity {
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
  ///   - x: A closure returning the x-position, in pixels, to set the entity upon creation.
  ///   - y: A closure returning the y-position, in pixels, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialPosition(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.position.x = x
      }
      if let y = y(context) {
        p.position.y = y
      }
      return p
    })
  }
  
  /// Offsets the initial position of the entity by the specified amounts.
  /// - Parameters:
  ///   - x: The x-offset, in pixels, to apply to the initial position.
  ///   - y: The y-offset, in pixels, to apply to the initial position.
  /// - Returns: The modified entity.
  func initialOffset(x: CGFloat?, y: CGFloat?) -> some Entity {
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
  func initialOffset(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
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
  ///   - x: The x-position, in pixels, to set the entity's position to.
  ///   - y: The y-position, in pixels, to set the entity's position to.
  /// - Returns: The modified entity.
  func constantPosition(x: CGFloat?, y: CGFloat?) -> some Entity {
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
  
  /// Sets the constant position of the entity using the values returned by the provided closures.
  /// - Parameters:
  ///   - x: A closure returning the x-position, in pixels, to set the entity's position to.
  ///   - y: A closure returning the y-position, in pixels, to set the entity's position to.
  /// - Returns: The modified entity.
  func constantPosition(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.position.x = x
      }
      if let y = y(context) {
        p.position.y = y
      }
      return p
    })
  }
  
  /// Sets the initial velocity of the entity.
  /// - Parameters:
  ///   - x: The x-velocity, in pixels per second, to set the entity upon creation.
  ///   - y: The y-velocity, in pixels per second, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialVelocity(x: CGFloat?, y: CGFloat?) -> some Entity {
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
  ///   - x: A closure returning the x-velocity, in pixels per second, to set the entity upon creation.
  ///   - y: A closure returning the y-velocity, in pixels per second, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialVelocity(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.velocity.dx = x
      }
      if let y = y(context) {
        p.velocity.dy = y
      }
      return p
    })
  }
  
  /// Sets the constant velocity of the entity.
  /// - Parameters:
  ///   - x: The x-velocity, in pixels per second, to set the entity's velocity to.
  ///   - y: The y-velocity, in pixels per second, to set the entity's velocity to.
  /// - Returns: The modified entity.
  func constantVelocity(x: CGFloat?, y: CGFloat?) -> some Entity {
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
  ///   - x: A closure returning the x-velocity, in pixels per second, to set the entity's velocity to.
  ///   - y: A closure returning the y-velocity, in pixels per second, to set the entity's velocity to.
  /// - Returns: The modified entity.
  func constantVelocity(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.velocity.dx = x
      }
      if let y = y(context) {
        p.velocity.dy = y
      }
      return p
    })
  }
  
  /// Sets the initial acceleration of the entity.
  /// - Parameters:
  ///   - x: The x-acceleration, in pixels per second squared, to set the entity upon creation.
  ///   - y: The y-acceleration, in pixels per second squared, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialAcceleration(x: CGFloat?, y: CGFloat?) -> some Entity {
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
  ///   - x: A closure returning the x-acceleration, in pixels per second squared, to set the entity upon creation.
  ///   - y: A closure returning the y-acceleration, in pixels per second squared, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialAcceleration(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.acceleration.dx = x
      }
      if let y = y(context) {
        p.acceleration.dy = y
      }
      return p
    })
  }
  
  /// Sets the constant acceleration of the entity.
  /// - Parameters:
  ///   - x: The x-acceleration, in pixels per second squared, to set the entity's acceleration to.
  ///   - y: The y-acceleration, in pixels per second squared, to set the entity's acceleration to.
  /// - Returns: The modified entity.
  func constantAcceleration(x: CGFloat?, y: CGFloat?) -> some Entity {
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
  func constantAcceleration(x: @escaping (PhysicsProxy.Context) -> CGFloat?, y: @escaping (PhysicsProxy.Context) -> CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x = x(context) {
        p.acceleration.dx = x
      }
      if let y = y(context) {
        p.acceleration.dy = y
      }
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
  func constantRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  
  /// Sets the constant rotation of the entity using the value returned by the provided closure.
  /// - Parameter angle: A closure returning the constant rotation angle of the entity.
  /// - Returns: The modified entity.
  func constantRotation(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
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
  func constantTorque(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.torque = angle
      return p
    })
  }
  
  /// Sets the constant torque of the entity using the value returned by the provided closure.
  /// - Parameter angle: A closure returning the constant torque angle of the entity.
  /// - Returns: The modified entity.
  func constantTorque(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
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
