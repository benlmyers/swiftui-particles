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
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      if let x = x {
        p.position.x = x
      }
      if let y = y {
        p.position.y = y
      }
      return p
    })
  }
  
  /// Sets the initial position of the entity using the provided closure.
  /// - Parameters:
  ///   - withPoint: A closure returning the 2D point, in pixels, to set the entity upon creation.
  ///   - y: A closure returning the y-position, in pixels, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialPosition(with withPoint: @escaping (Proxy.Context) -> CGPoint) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      let point = withPoint(context)
      p.position.x = point.x
      p.position.y = point.y
      return p
    })
  }
  
  /// Sets the initial position of the entity randomly.
  /// - Parameters:
  ///   - xIn: The x-range, in pixels, to set the entity's x-position to randomly in upon creation.
  ///   - yIn: The y-position, in pixels, to set the entity upon creation. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func initialPosition(xIn: ClosedRange<CGFloat>, yIn: ClosedRange<CGFloat>) -> some Entity {
    initialPosition { _ in
      return CGPoint(x: CGFloat.random(in: xIn), y: CGFloat.random(in: yIn))
    }
  }
  
  /// Sets the initial position of the entity relative to the size of its parent ``ParticleSystem``.
  /// - Parameters:
  ///   - point: The relative location to position the entity at birth.
  /// - Returns: The modified entity.
  func initialPosition(_ point: UnitPoint) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
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
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
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
  ///   - withX: A closure returning the x-offset, in pixels, to apply to the initial position.
  ///   - withY: A closure returning the y-offset, in pixels, to apply to the initial position.
  /// - Returns: The modified entity.
  func initialOffset(
    withX: @escaping (Proxy.Context) -> CGFloat? = { _ in nil },
    withY: @escaping (Proxy.Context) -> CGFloat? = { _ in nil }
  ) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      if let x = withX(context) {
        p.position.x += x
      }
      if let y = withY(context) {
        p.position.y += y
      }
      return p
    })
  }
  
  /// Offsets the initial position of the entity by the specified ranges.
  /// - Parameters:
  ///   - xIn: The x-range, in pixels, to offset the initial x-position by. Set to `nil` for no behavior.
  ///   - yIn: The y-range, in pixels, to offset the initial y-position by. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func initialOffset(xIn: ClosedRange<CGFloat> = .zero ... .zero, yIn: ClosedRange<CGFloat> = .zero ... .zero) -> some Entity {
    initialOffset { _ in
      return .random(in: xIn)
    } withY: { _ in
      return .random(in: yIn)
    }
  }
  
  /// Sets the constant position of the entity.
  /// - Parameters:
  ///   - x: The x-position, in pixels, to set the entity's position to. Set to `nil` for no behavior.
  ///   - y: The y-position, in pixels, to set the entity's position to. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func fixPosition(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
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
  func fixPosition(_ point: UnitPoint) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      guard let size = context.system?.size else {
        return p
      }
      p.position.x = size.width * point.x
      p.position.y = size.height * point.y
      return p
    })
  }
  
  /// Sets the scale of the entity.
  /// - Parameters:
  ///   - scale: The scale of the entity on update.
  /// - Returns: The modified entity.
  func fixScale(_ withScale: @escaping (Proxy.Context) -> CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      let scale = withScale(context)
      p.scale.width *= scale
      p.scale.height *= scale
      return p
    })
  }
  
  
  /// Sets the constant position of the entity using the values returned by the provided closures.
  /// ⚠️ **Warning:** Be sure to specify a return type of `CGPoint` or `UnitPoint` explicitly.
  /// - Parameters:
  ///   - withPoint: A closure returning the 2D point, in pixels, to set the entity's position to.
  /// - Returns: The modified entity.
  func fixPosition(with withPoint: @escaping (Proxy.Context) -> CGPoint) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      let point = withPoint(context)
      p.position.x = point.x
      p.position.y = point.y
      return p
    })
  }
  
  /// Sets the initial velocity of the entity.
  /// - Parameters:
  ///   - x: The x-velocity, in pixels per frame, to set the entity upon creation. Set to `nil` for no behavior.
  ///   - y: The y-velocity, in pixels per frame, to set the entity upon creation. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func initialVelocity(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
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
  ///   - withVelocity: A closure returning the 2D velocity, in pixels per frame, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialVelocity(with withVelocity: @escaping (Proxy.Context) -> CGVector) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      let v = withVelocity(context)
      p.velocity.dx = v.dx
      p.velocity.dy = v.dy
      return p
    })
  }
  
  /// Sets the initial velocity of the entity randomly within the specified ranges.
  /// - Parameters:
  ///   - xIn: The x-range, in pixels per frame, to set the initial x-velocity randomly within.
  ///   - yIn: The y-range, in pixels per frame, to set the initial y-velocity randomly within.
  /// - Returns: The modified entity.
  func initialVelocity(xIn: ClosedRange<CGFloat>, yIn: ClosedRange<CGFloat>) -> some Entity {
    initialVelocity { _ in
        .init(dx: .random(in: xIn), dy: .random(in: yIn))
    }
  }
  
  /// Sets the initial velocity of the entity in a random direction with a specified magnitude.
  /// - Parameters:
  ///   - magnitude: The magnitude of the initial random velocity.
  /// - Returns: The modified entity.
  func initialVelocity(withMagnitude magnitude: Double) -> some Entity {
    initialVelocity { _ in
        .init(angle: .random(), magnitude: magnitude)
    }
  }
  
  /// Sets the constant velocity of the entity.
  /// - Parameters:
  ///   - x: The x-velocity, in pixels per frame, to set the entity's velocity to. Set to `nil` for no behavior.
  ///   - y: The y-velocity, in pixels per frame, to set the entity's velocity to. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func fixVelocity(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
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
  ///   - withVelocity: A closure returning the 2D- velocity, in pixels per frame, to set the entity's velocity to.
  /// - Returns: The modified entity.
  func fixVelocity(with withVelocity: @escaping (Proxy.Context) -> CGVector) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      let v = withVelocity(context)
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
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
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
  ///   - withAcceleration: A closure returning the acceleration, in pixels per second squared, to set the entity upon creation.
  /// - Returns: The modified entity.
  func initialAcceleration(with withAcceleration: @escaping (Proxy.Context) -> CGVector) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      let a = withAcceleration(context)
      p.acceleration.dx = a.dx
      p.acceleration.dy = a.dy
      return p
    })
  }
  
  /// Sets the initial acceleration of the entity randomly within the specified ranges.
    /// - Parameters:
    ///   - xIn: The x-range, in pixels per second squared, to set the initial x-acceleration randomly within.
    ///   - yIn: The y-range, in pixels per second squared, to set the initial y-acceleration randomly within.
    /// - Returns: The modified entity.
  func initialAcceleration(xIn: ClosedRange<CGFloat>, yIn: ClosedRange<CGFloat>) -> some Entity {
    initialAcceleration { _ in
        .init(dx: .random(in: xIn), dy: .random(in: yIn))
    }
  }
  
  /// Sets the constant acceleration of the entity.
  /// - Parameters:
  ///   - x: The x-acceleration, in pixels per second squared, to set the entity's acceleration to. Set to `nil` for no behavior.
  ///   - y: The y-acceleration, in pixels per second squared, to set the entity's acceleration to. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func fixAcceleration(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
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
  ///   - withAcceleration: A closure returning `CGVector` representing the value to set the entity's acceleration to.
  /// - Returns: The modified entity.
  func fixAcceleration(with withAcceleration: @escaping (Proxy.Context) -> CGVector) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      let a = withAcceleration(context)
      p.acceleration.dx = a.dx
      p.acceleration.dy = a.dy
      return p
    })
  }
  
  /// Sets the initial rotation of the entity.
  /// - Parameter angle: The initial rotation angle of the entity.
  /// - Returns: The modified entity.
  func initialRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.rotation = angle
      return p
    })
  }
  
  /// Sets the initial rotation of the entity using the value returned by the provided closure.
  /// - Parameter withAngle: A closure returning the initial rotation angle of the entity.
  /// - Returns: The modified entity.
  func initialRotation(with withAngle: @escaping (Proxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.rotation = withAngle(context)
      return p
    })
  }
  
  /// Sets the initial rotation angle of the entity randomly within the specified range.
    /// - Parameter angleIn: The range of angles to set the initial rotation angle randomly within.
    /// - Returns: The modified entity.
  func initialRotation(angleIn: ClosedRange<Angle>) -> some Entity {
    initialRotation { _ in
        .random(degreesIn: min(angleIn.lowerBound.degrees, angleIn.upperBound.degrees) ... max(angleIn.upperBound.degrees, angleIn.lowerBound.degrees))
    }
  }
  
  /// Sets the constant rotation of the entity.
  /// - Parameter angle: The constant rotation angle of the entity.
  /// - Returns: The modified entity.
  func fixRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      p.rotation = angle
      return p
    })
  }
  
  /// Sets the constant rotation of the entity using the value returned by the provided closure.
  /// - Parameter withAngle: A closure returning the constant rotation angle of the entity.
  /// - Returns: The modified entity.
  func fixRotation(with withAngle: @escaping (Proxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      p.rotation = withAngle(context)
      return p
    })
  }
  
  /// Sets the initial torque of the entity.
  /// - Parameter angle: The initial torque angle of the entity.
  /// - Returns: The modified entity.
  func initialTorque(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.torque = angle
      return p
    })
  }
  
  /// Sets the initial torque of the entity using the value returned by the provided closure.
  /// - Parameter withAngle: A closure returning the initial torque angle of the entity.
  /// - Returns: The modified entity.
  func initialTorque(with withAngle: @escaping (Proxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.torque = withAngle(context)
      return p
    })
  }
  
  /// Sets the initial torque angle of the entity randomly within the specified range.
    /// - Parameter angleIn: The range of angles to set the initial torque angle randomly within.
    /// - Returns: The modified entity.
  func initialTorque(angleIn: ClosedRange<Angle>) -> some Entity {
    initialTorque { _ in
        .random(degreesIn: min(angleIn.lowerBound.degrees, angleIn.upperBound.degrees) ... max(angleIn.upperBound.degrees, angleIn.lowerBound.degrees))
    }
  }
  
  /// Sets the constant torque of the entity.
  /// - Parameter angle: The constant torque angle of the entity.
  /// - Returns: The modified entity.
  func fixTorque(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      p.torque = angle
      return p
    })
  }
  
  /// Sets the constant torque of the entity using the value returned by the provided closure.
  /// - Parameter withAngle: A closure returning the constant torque angle of the entity.
  /// - Returns: The modified entity.
  func fixTorque(with withAngle: @escaping (Proxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      p.torque = withAngle(context)
      return p
    })
  }
  
  /// Sets the lifetime of the entity.
  /// - Parameter value: The lifetime of the entity, in seconds.
  /// - Returns: The modified entity.
  func lifetime(_ value: Double) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.lifetime = value
      return p
    })
  }
  
  /// Sets the lifetime of the entity using the value returned by the provided closure.
  /// - Parameter withValue: A closure returning the lifetime of the entity, in seconds.
  /// - Returns: The modified entity.
  func lifetime(with withValue: @escaping (Proxy.Context) -> Double) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.lifetime = withValue(context)
      return p
    })
  }
  
  /// Sets the lifetime of the entity randomly within the specified range.
  /// - Parameter in: The range of lifetimes, in seconds, to set the lifetime of the entity randomly within.
  /// - Returns: The modified entity.
  func lifetime(in range: ClosedRange<Double>) -> some Entity {
    lifetime { _ in
        .random(in: range)
    }
  }
  
  /// Sets the initial drag of the entity. It is advised to use small values less than `0.1`.
  /// - Parameter value: The initial drag of the entity, from `0.0` (no drag) to `1.0` (immediate stop).
  /// - Returns: The modified entity.
  func drag(_ value: Double) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.drag = value
      return p
    })
  }
  
  /// Sets the constant drag of the entity using the values returned by the provided closure.
  /// - Parameter withDrag: A closure returning a `Double` from `0.0` to `1.0` representing the value to set the entity's drag to.
  /// - Returns: The modified entity.
  func drag(with withDrag: @escaping (Proxy.Context) -> Double) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      p.drag = withDrag(context)
      return p
    })
  }
  
  /// Sets the initial drag of the entity randomly within the specified range.
  /// - Parameter range: The range of possible drag values to use, from `0.0` to `1.0`.
  /// - Returns: The modified entity.
  func drag(in range: ClosedRange<Double>) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.drag = .random(in: range)
      return p
    })
  }
  
  /// Sets the initial z-index of the entity. It is advised to use small values less than `0.1`.
  /// - Parameter value: The initial z-index of the entity.
  /// - Returns: The modified entity.
  func zIndex(_ value: Int) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.zIndex = value
      return p
    })
  }

  /// Sets the constant z-index of the entity using the values returned by the provided closure.
  /// - Parameter withZIndex: A closure returning an `Int` representing the value to set the entity's z-index to.
  /// - Returns: The modified entity.
  func zIndex(with withZIndex: @escaping (Proxy.Context) -> Int) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      p.zIndex = withZIndex(context)
      return p
    })
  }

  /// Sets the initial z-index of the entity randomly within the specified range.
  /// - Parameter range: The range of possible z-index values to use, from `0` to `Int.max`.
  /// - Returns: The modified entity.
  func zIndex(in range: ClosedRange<Int>) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.zIndex = .random(in: range)
      return p
    })
  }

}
