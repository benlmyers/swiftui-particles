//
//  Entity+Modifiers.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import Foundation
import ParticlesCore

public extension Entity {
  
  func startPosition(x: CGFloat, y: CGFloat) -> Self {
    self.start(\.position, at: CGPoint(x: x, y: y))
  }
  
  func startPosition(_ point: UnitPoint) -> Self {
    self.onBirth { proxy, _ in
      let size = proxy.systemData!.systemSize
      proxy.position = CGPoint(x: point.x * size.width, y: point.y * size.height)
    }
  }
  
  func startVelocity(x: CGFloat, y: CGFloat) -> Self {
    self.start(\.velocity, at: CGVector(dx: x, dy: y))
  }
}
