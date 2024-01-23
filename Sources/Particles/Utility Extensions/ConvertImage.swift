//
//  ConvertImage.swift
//
//
//  Created by Demirhan Mehmet Atabey on 23.01.2024.
//

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension View {
  #if os(iOS)
  func asImage() -> UIImage {
    let controller = UIHostingController(rootView: self)
    let image = UIImage(view: controller.view)
    return image
  }
  #else
  func asImage() -> NSImage {
    let controller = NSHostingController(rootView: self)
    let image = NSImage(view: controller.view)
    return image
  }
  #endif
}

#if os(iOS)
extension UIImage {
  convenience init(view: UIView) {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: image!.cgImage!)
  }
}
#else
extension NSImage {
  convenience init(view: NSView) {
    guard let bitmapRepresentation = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
      self.init()
      return
    }
    
    view.cacheDisplay(in: view.bounds, to: bitmapRepresentation)
    self.init(cgImage: bitmapRepresentation.cgImage!, size: view.bounds.size)
  }
}
#endif
