//
//  Image.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Foundation

internal extension Image {
  init(packageResource name: String, ofType type: String) {
#if canImport(UIKit)
    guard let path = Bundle.main.path(forResource: name, ofType: type),
          let image = UIImage(contentsOfFile: path) else {
      self.init(name)
      return
    }
    self.init(uiImage: image)
#elseif canImport(AppKit)
    guard let path = Bundle.main.path(forResource: name, ofType: type),
          let image = NSImage(contentsOfFile: path) else {
      self.init(name)
      return
    }
    self.init(nsImage: image)
#else
    self.init(name)
#endif
  }
}
