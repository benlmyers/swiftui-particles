//
//  CGVector.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

extension CGVector {
  
  // MARK: - Initalizers
  
  /**
   Creates a ``CGVector`` with a given magnitude and angle.
   
   - parameter magnitude: The magnitude of the vector.
   - parameter angle: The angle of the vector, with respect to the horizontal.
   */
  init(_ magnitude: CGFloat, angle: Angle) {
    self.init(dx: magnitude * cos(angle.radians), dy: magnitude * sin(angle.radians))
  }
}
