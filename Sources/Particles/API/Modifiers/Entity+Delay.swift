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
    m.preferences.append(.custom({ c in .delay(duration: duration) }))
    return m
  }
  
  /// Applies a delay to this entity randomly. This causes it to wait for a specified amount of time until birth.
  /// - Parameter range: The range of durations, in seconds, of the possible delay value.
  /// - Returns: The modified entity.
  func delay(in range: ClosedRange<TimeInterval>) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .delay(duration: .random(in: range)) }))
    return m
  }
  
  /// Applies a delay to this entity using the provided closure before birth. This causes it to wait for a specified amount of time.
  /// - Parameter withDelay: A closure that produces a value to use as the delay interval for this proxy.
  /// - Returns: The modified entity.
  func delay(with withDelay: @escaping (Proxy.Context) -> TimeInterval) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .delay(duration: withDelay(c)) }))
    return m
  }
}
