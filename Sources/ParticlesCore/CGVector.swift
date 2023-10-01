//
//  CGVector.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import SwiftUI
import CoreGraphics

extension CGVector {
  
  var isZero: Bool {
    return dx.isZero && dy.isZero
  }
  
  func add(_ v: CGVector) -> CGVector {
    return CGVector(dx: self.dx + v.dx, dy: self.dy + v.dy)
  }
  func scale(_ s: CGFloat) -> CGVector {
    return CGVector(dx: self.dx * s, dy: self.dy * s)
  }
  
  public init(magnitude: Double, angle: Angle) {
    self = CGVector(dx: magnitude * cos(angle.radians), dy: magnitude * sin(angle.radians))
  }
}
