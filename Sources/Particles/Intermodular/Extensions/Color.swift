//
//  Color.swift
//
//
//  Created by Ben Myers on 4/7/24.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

internal extension Color {
  
  static func lerp(a: Color, b: Color, t: CGFloat) -> Color {
    return Color(
      .sRGB,
      red: lerp(a.components.red, b.components.red, t),
      green: lerp(a.components.green, b.components.green, t),
      blue: lerp(a.components.blue, b.components.blue, t)
    )
  }
  
  private static func lerp(_ a: Double, _ b: Double, _ t: CGFloat) -> Double {
    return a + (b - a) * Double(t)
  }
  
  var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
#if canImport(UIKit)
    typealias NativeColor = UIColor
#elseif canImport(AppKit)
    typealias NativeColor = NSColor
#endif
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var o: CGFloat = 0
    NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
    return (r, g, b, o)
  }
}
