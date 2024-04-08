//
//  Entity+Glow.swift
//
//
//  Created by Ben Myers on 3/17/24.
//

import SwiftUI
import Foundation

public extension Entity {
  
  /// Applies a glow to this entity.
  /// - Parameter color: The color the entity glows. Pass `nil` to glow the same color of the entity.
  /// - Parameter radius: The radius of the glow effect. Default `15.0`.
  func glow(_ color: Color? = nil, radius: CGFloat = 15.0) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .glow(color: color, radius: radius) }))
    return m
  }
  
  /// Applies a glow to this entity randomly.
  /// - Parameter fromColor: Sets the glow of the entity to a color randomly between `fromColor` and `toColor`.
  /// - Parameter toColor: Sets the glow of the entity to a color randomly between `fromColor` and `toColor`.
  /// - Parameter radiusIn: A range to randomly choose a radius for the glow effect.
  func glow(from fromColor: Color, to toColor: Color, radiusIn: ClosedRange<CGFloat>) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(
      .custom(
        { c in
            .glow(
              color: Color.lerp(a: fromColor, b: toColor, t: .random(in: 0.0 ... 1.0)),
              radius: .random(in: radiusIn)
            )
        }
      )
    )
    return m
  }
  
  /// Applies a glow to this entity using the provided closure on update.
  /// - Parameter withColor: A closure that produces a glow color to use on update.
  /// - Returns: A closure that produces a radius to use on update.
  func glow(
    withColor: @escaping (Proxy.Context) -> Color? = { _ in nil },
    withRadius: @escaping (Proxy.Context) -> CGFloat = { _ in 15.0 }
  ) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .glow(color: withColor(c), radius: withRadius(c)) }))
    return m
  }
}
