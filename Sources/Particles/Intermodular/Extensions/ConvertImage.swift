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

internal extension View {
  #if os(iOS)
  func asImage() -> UIImage? {
    let controller = UIHostingController(rootView: self)
    let view = controller.view
    let targetSize = controller.view.intrinsicContentSize
    view?.bounds = CGRect(origin: .zero, size: targetSize)
    view?.backgroundColor = .clear
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    return renderer.image { _ in
        view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
    }
  }
  #else
  func asImage() -> NSImage? {
    let controller = NSHostingController(rootView: self)
    let targetSize = controller.view.intrinsicContentSize
    let contentRect = NSRect(origin: .zero, size: targetSize)
    
    let window = NSWindow(
      contentRect: contentRect,
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    window.contentView = controller.view
    
    guard
      let bitmapRep = controller.view.bitmapImageRepForCachingDisplay(in: contentRect)
    else { return nil }
    
    controller.view.cacheDisplay(in: contentRect, to: bitmapRep)
    let image = NSImage(size: bitmapRep.size)
    image.addRepresentation(bitmapRep)
    return image
  }
  #endif
}

#if os(iOS)
internal extension UIImage {
  convenience init(view: UIView) {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
    
//    view.layer.proxy(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: image!.cgImage!)
  }
}
#else
internal extension NSImage {
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
