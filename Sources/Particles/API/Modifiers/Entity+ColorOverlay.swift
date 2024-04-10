//
//  Entity+ColorOverlay.swift
//
//
//  Created by Ben Myers on 3/16/24.
//

import SwiftUI
import Foundation

public extension Entity {
  
  /// Applies a color overlay to this entity.
  /// - Parameter color: The color to overlay on to the entity.
  func colorOverlay(_ color: Color) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .colorOverlay(color: color) }))
    return m
  }
  
  /// Applies a color overlay to this entity randomly.
  /// - Parameter fromColor: Sets the color overlay of the entity to a color chosen randomly between `fromColor` and `toColor`.
  /// - Parameter toColor: Sets the color overlay of the entity to a color chosen randomly between `fromColor` and `toColor`.
  /// - Returns: The modified entity.
  func colorOverlay(from fromColor: Color, to toColor: Color) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .colorOverlay(color: Color.lerp(a: fromColor, b: toColor, t: .random(in: 0.0 ... 1.0))) }))
    return m
  }

  /// Applies a color overlay to this entity using the provided closure on update.
  /// - Parameter withColor: A closure that produces the color overlay to use on update.
  /// - Returns: The modified entity.
  func colorOverlay(
    with withColor: @escaping (Proxy.Context) -> Color = { _ in .white }
  ) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .colorOverlay(color: withColor(c)) }))
    return m
  }
}
