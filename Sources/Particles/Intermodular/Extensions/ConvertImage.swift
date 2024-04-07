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

#if os(iOS)
extension UIView {
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
  }
}
#endif

public extension View {
  
  #if os(iOS)
  func asImage() -> UIImage? {
    let controller = UIHostingController(rootView: self)
    controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
    let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
    controller.view.bounds = CGRect(origin: .zero, size: size)
    controller.view.sizeToFit()
    UIApplication.shared.windows.first?.rootViewController?.view.addSubview(controller.view)
    let image = controller.view.asImage()
    controller.view.removeFromSuperview()
    return image
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

//#if os(iOS)
//internal extension UIImage {
//  convenience init(view: UIView) {
//    
//    let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
//    let image = renderer.image { ctx in
//        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//    }
//    
////    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
//    
////    view.layer.proxy(in: UIGraphicsGetCurrentContext()!)
////    let image = UIGraphicsGetImageFromCurrentImageContext()
////    UIGraphicsEndImageContext()
//    self.init(cgImage: image.cgImage!)
//  }
//}
//#else
//internal extension NSImage {
//  convenience init(view: NSView) {
//    guard let bitmapRepresentation = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
//      self.init()
//      return
//    }
//    
//    view.cacheDisplay(in: view.bounds, to: bitmapRepresentation)
//    self.init(cgImage: bitmapRepresentation.cgImage!, size: view.bounds.size)
//  }
//}
//#endif
