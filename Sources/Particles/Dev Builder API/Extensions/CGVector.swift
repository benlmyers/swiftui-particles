//
//  CGVector.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

public extension CGVector {
  
  init(angle: Angle, magnitude: CGFloat) {
    self.init(dx: cos(angle) * magnitude, dy: sin(angle) * magnitude)
  }
}
