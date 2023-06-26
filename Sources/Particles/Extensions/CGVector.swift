//
//  CGVector.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import CoreGraphics

extension CGVector {
  func add(_ v: CGVector) -> CGVector {
    return CGVector(dx: self.dx + v.dx, dy: self.dy + v.dy)
  }
}
