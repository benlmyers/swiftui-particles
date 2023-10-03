//
//  Path.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI

public extension Path {
  
  /// A circular path.
  /// - Parameter radius: The radius of the circle.
  /// - Returns: The circular path.
  static func circle(radius: CGFloat) -> Path {
    Path(ellipseIn: .init(radius: radius))
  }
  
  /// A square path.
  /// - Parameter radius: The radius of the square.
  /// - Returns: The square path.
  static func square(radius: CGFloat) -> Path {
    Path(roundedRect: .init(radius: radius), cornerSize: .zero)
  }
  
  /// A rectangular path.
  /// - Parameters:
  ///   - width: The width of the rectangle.
  ///   - height: The height of the rectangle.
  /// - Returns: The rectangular path.
  static func rectangle(width: CGFloat, height: CGFloat) -> Path {
    Path(roundedRect: .init(width: width, height: height), cornerSize: .zero)
  }
  
  /// A rounded rectangular path.
  /// - Parameters:
  ///   - width: The width of the rectangle.
  ///   - height: The height of the rectangle.
  ///   - cornerRadius: The corner radius.
  /// - Returns: The rounded rectangular path.
  static func roundedRectangle(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> Path {
    Path(roundedRect: .init(width: width, height: height), cornerSize: .init(width: cornerRadius, height: cornerRadius))
  }
}
