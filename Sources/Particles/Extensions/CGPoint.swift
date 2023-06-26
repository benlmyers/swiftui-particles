//
//  CGPoint.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import CoreGraphics

public extension CGPoint {
  func apply(_ vec: CGVector) -> CGPoint {
    return CGPoint(x: self.x + vec.dx, y: self.y + vec.dy)
  }
}
