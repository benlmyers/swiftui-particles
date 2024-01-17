//
//  Entity+Physics.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

public extension Entity {
  
  func initialPosition(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x {
        p.position.x = x
      }
      if let y {
        p.position.y = y
      }
      return p
    })
  }
  
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
  
  func initialOffset(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x {
        p.position.x += x
      }
      if let y {
        p.position.y += y
      }
      return p
    })
  }
  
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
  
  func constantPosition(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x {
        p.position.x = x
      }
      if let y {
        p.position.y = y
      }
      return p
    })
  }
  
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
  
  func initialVelocity(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x {
        p.velocity.dx = x
      }
      if let y {
        p.velocity.dy = y
      }
      return p
    })
  }
  
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
  
  func constantVelocity(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x {
        p.velocity.dx = x
      }
      if let y {
        p.velocity.dy = y
      }
      return p
    })
  }
  
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
  
  func initialAcceleration(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      if let x {
        p.acceleration.dx = x
      }
      if let y {
        p.acceleration.dy = y
      }
      return p
    })
  }
  
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
  
  func constantAcceleration(x: CGFloat?, y: CGFloat?) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      if let x {
        p.acceleration.dx = x
      }
      if let y {
        p.acceleration.dy = y
      }
      return p
    })
  }
  
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
  
  func initialRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  
  func initialRotation(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.rotation = angle(context)
      return p
    })
  }
  
  func constantRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.rotation = angle
      return p
    })
  }
  
  func constantRotation(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.rotation = angle(context)
      return p
    })
  }
  
  func initialTorque(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.torque = angle
      return p
    })
  }
  
  func initialTorque(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.torque = angle(context)
      return p
    })
  }
  
  func constantTorque(_ angle: @escaping (PhysicsProxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdatePhysics: { context in
      var p = context.physics
      p.torque = angle(context)
      return p
    })
  }
  
  func lifetime(_ value: Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.lifetime = value
      return p
    })
  }
  
  func lifetime(_ value: @escaping (PhysicsProxy.Context) -> Double) -> some Entity {
    ModifiedEntity(entity: self, onBirthPhysics: { context in
      var p = context.physics
      p.lifetime = value(context)
      return p
    })
  }
}
