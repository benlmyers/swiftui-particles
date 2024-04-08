//
//  Entity+Delay.swift
//
//
//  Created by Ben Myers on 4/7/24.
//

import Foundation

public extension Entity {
  
  /// Applies a delay to this entity. This causes it to wait for a specified amount of time until birth.
  /// - Parameter duration: The duration, in seconds, of the delay.
  /// - Returns: The modified entity.
  func delay(_ duration: TimeInterval) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom(.delay(duration: duration)))
    return m
  }
}
