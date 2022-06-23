//
//  CGPoint.swift
//  
//
//  Created by Ben Myers on 6/18/22.
//

import SwiftUI

extension CGPoint {
  
  static func midpoint(_ a: Self, _ b: Self) -> CGPoint {
    return CGPoint(x: (a.x + a.x) / 2.0, y: (a.y + b.y) / 2.0)
  }
  
  func translated(by v: CGVector) -> CGPoint {
    return CGPoint(x: self.x + v.dx, y: self.y + v.dy)
  }
}
