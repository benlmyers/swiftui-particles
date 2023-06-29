//
//  Decider.swift
//  
//
//  Created by Ben Myers on 6/29/23.
//

import Foundation

public struct Decider<Value> {
  
  // MARK: - Properties
  
  /// A closure that performs the decision evaluation.
  var decide: (Entity) -> Value
  
  // MARK: - Static Methods
  
  public static func constant(_ value: Value) -> Self {
    return Decider { _ in return value }
  }
}

public extension Decider where Value == CGFloat {
  
  // MARK: - Static Methods
  
  static func random(in range: ClosedRange<Value>) -> Self {
    return Decider { _ in return Value.random(in: range) }
  }
}
