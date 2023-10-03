//
//  SystemValue.swift
//
//
//  Created by Ben Myers on 10/2/23.
//

import SwiftUI

/// A protocol defining a type as one that can be derived from its system.
public protocol SystemValue {
  
  associatedtype Value
  
  /// Derives the value from a proxy and its environment.
  /// - Parameter proxy: The proxy to obtain a value from.
  /// - Returns: The value derived from the proxy's properties.
  func getValue(from proxy: Entity.Proxy) -> Value
}

extension UnitPoint: SystemValue {
  
  public typealias Value = CGPoint
  
  public func getValue(from proxy: Entity.Proxy) -> CGPoint {
    let size = proxy.systemData!.systemSize
    return CGPoint(x: size.width * self.x, y: size.height * self.y)
  }
}
