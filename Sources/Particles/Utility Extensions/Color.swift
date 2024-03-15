//
//  Color.swift
//
//
//  Created by Demirhan Mehmet Atabey on 23.01.2024.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


extension Color {
#if canImport(UIKit)
  var asNative: UIColor { UIColor(self) }
#elseif canImport(AppKit)
  var asNative: NSColor { NSColor(self) }
#endif
  
  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//    let color = asNative.usingColorSpace(.deviceRGB)!
//    var t = (CGFloat(), CGFloat(), CGFloat(), CGFloat())
//    color.getRed(&t.0, green: &t.1, blue: &t.2, alpha: &t.3)
//    return t
    return (0,0,0,0)
  }
  
  static func toColor(from rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)) -> Color {
    return Color(red: Double(rgba.red), green: Double(rgba.green), blue: Double(rgba.blue), opacity: Double(rgba.alpha))
  }
}
