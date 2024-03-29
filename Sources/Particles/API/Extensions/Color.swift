//
//  Color.swift
//
//
//  Created by Ben Myers on 3/27/24.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
  
  internal var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
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
  
  /// The red component of this `Color`, `0.0`-`1.0`.  (*via* `import Particles`)
  public var red: CGFloat {
    components.red
  }
  
  /// The green component of this `Color`, `0.0`-`1.0`.  (*via* `import Particles`)
  public var green: CGFloat {
    components.green
  }
  
  /// The blue component of this `Color`, `0.0`-`1.0`.  (*via* `import Particles`)
  public var blue: CGFloat {
    components.blue
  }
  
  /// The alpha component of this `Color`, `0.0`-`1.0`.  (*via* `import Particles`)
  public var alpha: CGFloat {
    components.opacity
  }
}
