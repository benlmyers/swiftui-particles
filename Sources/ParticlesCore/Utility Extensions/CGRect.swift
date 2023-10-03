//
//  CGRect.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import CoreGraphics

public extension CGRect {
  
  /// Creates a rectangle centered at the origin with a specified width and height.
  /// - Parameters:
  ///   - width: The width of the rectangle.
  ///   - height: The height of the rectangle.
  init(width: CGFloat, height: CGFloat) {
    self.init(origin: .zero, size: .init(width: width, height: height))
  }
  
  /// Creates a square centered at the origin with a specified radius.
  /// - Parameter radius: The radius of the square.
  init(radius: CGFloat) {
    self.init(origin: .zero, size: .init(width: 2.0 * radius, height: 2.0 * radius))
  }
}
