#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

import SwiftUI

extension Color {
  
  func toRGBA() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
    #if os(iOS)
    let uiColor = UIColor(self)
    #elseif os(macOS)
    let uiColor = NSColor(self).usingColorSpace(.sRGB)
    #endif
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    uiColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (red, green, blue, alpha)
  }
}
