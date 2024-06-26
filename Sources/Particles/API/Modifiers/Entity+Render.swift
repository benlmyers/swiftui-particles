//
//  Entity+Render.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

public extension Entity {
  
  /// Adjusts the opacity of the entity.
  /// - Parameter value: The opacity value to multiply the current opacity by.
  /// - Returns: The modified entity.
  func opacity(_ value: Double) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.opacity *= value
      return p
    })
  }
  
  /// Adjusts the opacity of the entity using the value returned by the provided closure.
  /// - Parameter withValue: A closure returning the opacity value to multiply the current opacity by.
  /// - Returns: The modified entity.
  func opacity(with withValue: @escaping (Proxy.Context) -> Double) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      p.opacity = withValue(context)
      return p
    })
  }
  
  /// Adjusts the opacity of the entity randomly.
  /// - Parameter value: The range to randomly choose an opacity value to multiply the current opacity by.
  /// - Returns: The modified entity.
  func opacity(in range: ClosedRange<Double>) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.opacity = .random(in: range)
      return p
    })
  }
  
  /// Applies a hue rotation to the entity.
  /// - Parameter angle: The angle of rotation in hue space.
  /// - Returns: The modified entity.
  func hueRotation(_ angle: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.hueRotation = angle
      return p
    })
  }
  
  /// Applies a hue rotation to the entity using the value returned by the provided closure.
  /// - Parameter withAngle: A closure returning the angle of rotation in hue space.
  /// - Returns: The modified entity.
  func hueRotation(with withAngle: @escaping (Proxy.Context) -> Angle) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      let hr = withAngle(context)
      p.hueRotation = hr
      return p
    })
  }
  
  /// Applies a hue rotation to the entity.
  /// - Parameter angle: The angle of rotation in hue space.
  /// - Returns: The modified entity.
  func hueRotation(angleIn: ClosedRange<Angle>) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      let hr = Angle.random(degreesIn: min(angleIn.lowerBound.degrees, angleIn.upperBound.degrees) ... max(angleIn.upperBound.degrees, angleIn.lowerBound.degrees))
      p.hueRotation = hr
      return p
    })
  }
  
  /// Applies a blur effect to the entity.
  /// - Parameter size: The size of the blur radius in pixels.
  /// - Returns: The modified entity.
  func blur(_ size: CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.blur = size
      return p
    })
  }
  
  /// Applies a blur effect randomly to the entity.
  /// - Parameter size: The range of the size of the blur radius in pixels.
  /// - Returns: The modified entity.
  func blur(in range: ClosedRange<CGFloat>) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.blur = .random(in: range)
      return p
    })
  }
  
  /// Applies a blending mode to the entity.
  /// - Parameter mode: The blending mode to use.
  /// - Returns: The modified entity.
  func blendMode(_ mode: GraphicsContext.BlendMode) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.blendMode = mode
      return p
    })
  }
  
  /// Scales the entity in the x and y directions by the specified sizes.
  /// - Parameters:
  ///   - x: The scaling factor to apply to the x dimension. Set to `nil` for no behavior.
  ///   - y: The scaling factor to apply to the y dimension. Set to `nil` for no behavior.
  /// - Returns: The modified entity.
  func scale(x: CGFloat? = nil, y: CGFloat? = nil) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      if let x = x {
        p.scale.width *= x
      }
      if let y = y {
        p.scale.height *= y
      }
      return p
    })
  }
  
  /// Scales the entity by the specified size in both the x and y directions.
  /// - Parameter size: The scaling factor to apply to both the x and y dimensions.
  /// - Returns: The modified entity.
  func scale(_ factor: CGFloat) -> some Entity {
    self.scale(x: factor, y: factor)
  }
  
  /// Scales the entity by the size returned by the provided closure in both the x and y directions.
  /// - Parameter withSize: A closure returning the scaling factor to apply to both the x and y dimensions.
  /// - Returns: The modified entity.
  func scale(with withFactor: @escaping (Proxy.Context) -> CGFloat) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      let s = withFactor(context)
      p.scale.width = s
      p.scale.height = s
      return p
    })
  }
  
  /// Scales the entity by the specified size in both the x and y directions.
  /// - Parameter range: A range to randomly scale the entity by.
  /// - Returns: The modified entity.
  func scale(factorIn range: ClosedRange<CGFloat>) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      let s: CGFloat = CGFloat.random(in: range)
      p.scale.width *= s
      p.scale.height *= s
      return p
    })
  }
  
  /// Scales the entity in the x and y directions by the sizes returned by the provided closures.
  /// - Parameter withSize: A closure returning the scaling factors to apply to the x and y dimensions.
  /// - Returns: The modified entity.
  func scale(with withSize: @escaping (Proxy.Context) -> CGSize) -> some Entity {
    ModifiedEntity(entity: self, onUpdate: { context in
      var p = context.proxy
      let s = withSize(context)
      p.scale.width = s.width
      p.scale.height = s.height
      return p
    })
  }
  
  /// Applies a 3D rotation effect to the entity.
  /// - Parameter x: The x-rotation.
  /// - Parameter y: The y-rotation.
  /// - Parameter z: The z-rotation.
  func rotation3D(x: Angle, y: Angle, z: Angle) -> some Entity {
    ModifiedEntity(entity: self, onBirth: { context in
      var p = context.proxy
      p.rotation3d.x = x.radians
      p.rotation3d.y = y.radians
      p.rotation3d.z = z.radians
      return p
    })
  }
}
