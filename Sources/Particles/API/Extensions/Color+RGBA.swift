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

public extension Color {
  
  /// The red component of this `Color`, `0.0`-`1.0`.  (*via* `import Particles`)
  var red: CGFloat {
    components.red
  }
  
  /// The green component of this `Color`, `0.0`-`1.0`.  (*via* `import Particles`)
  var green: CGFloat {
    components.green
  }
  
  /// The blue component of this `Color`, `0.0`-`1.0`.  (*via* `import Particles`)
  var blue: CGFloat {
    components.blue
  }
  
  /// The alpha component of this `Color`, `0.0`-`1.0`.  (*via* `import Particles`)
  var alpha: CGFloat {
    components.opacity
  }
}
