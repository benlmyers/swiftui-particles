//
//  File.swift
//  
//
//  Created by Ben Myers on 10/2/23.
//

import SwiftUI

//public struct SystemValue<V> {
//  var getValue: (ParticleSystem.Data, Entity.Proxy) -> V
//}
//
//extension SystemValue where V == CGPoint {
//  
//  public init(_ position: UnitPoint) {
//    self.getValue = { data, _ in
//      let size = data.systemSize
//      return CGPoint(x: position.x * size.width, y: position.y * size.height)
//    }
//  }
//}

public protocol SystemValue {
  associatedtype Value
  func getValue(from proxy: Entity.Proxy) -> Value
}

extension UnitPoint: SystemValue {
  
  public typealias Value = CGPoint
  
  public func getValue(from proxy: Entity.Proxy) -> CGPoint {
    let size = proxy.systemData!.systemSize
    return CGPoint(x: size.width * self.x, y: size.height * self.y)
  }
}
