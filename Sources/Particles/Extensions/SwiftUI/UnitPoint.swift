//
//  UnitPoint.swift
//  
//
//  Created by Ben Myers on 6/17/22.
//

import SwiftUI

public extension UnitPoint {
  
  // MARK: - Public Methods
  
  /**
   Projects a ``UnitPoint`` to a ``CGPoint`` within a given bound.
   
   - parameter size: The size of the bound.
   */
  func projected(to size: CGSize) -> CGPoint {
    return CGPoint(x: self.x * size.width, y: self.y * size.height)
  }
  
  /**
   Translates a ``UnitPoint`` by the values in a ``CGVector``.
   */
  func translated(by v: CGVector) -> UnitPoint {
    return UnitPoint(x: self.x + v.dx, y: self.y + v.dy)
  }
}
