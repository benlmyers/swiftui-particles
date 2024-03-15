//
//  AnyEntity.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

/// A tyoe-erased ``Entity``.
public struct AnyEntity {
  
  public var body: Any
  public typealias Body = Any
  
  init<T>(body: T) where T: Entity {
    self.body = body
  }
}
