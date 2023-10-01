//
//  CGPoint.swift
//  
//
//  Created by Ben Myers on 6/25/23.
//

import CoreGraphics

extension CGPoint {
  func apply(_ vec: CGVector) -> CGPoint {
    return CGPoint(x: self.x + vec.dx, y: self.y + vec.dy)
  }
  func distance(to point: CGPoint) -> CGFloat {
    let dx: CGFloat = point.x - self.x
    let dy: CGFloat = point.y - self.y
    return sqrt(dx * dx + dy * dy)
  }
}
