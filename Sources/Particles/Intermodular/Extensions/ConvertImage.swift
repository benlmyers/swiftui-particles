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
@available(watchOS, unavailable)
extension UIView {
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
  }
}
#endif

@available(watchOS, unavailable)
public extension View {
  
  #if os(iOS)
  func asImage() -> UIImage? {
    let controller = UIHostingController(rootView: self)
    controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
    let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
    controller.view.bounds = CGRect(origin: .zero, size: size)
    controller.view.sizeToFit()
    keyWindow?.addSubview(controller.view)
    let image = controller.view.asImage()
    controller.view.removeFromSuperview()
    return image
  }
  
  private var keyWindow: UIWindow? {
    let allScenes = UIApplication.shared.connectedScenes
    for scene in allScenes {
      guard let windowScene = scene as? UIWindowScene else { continue }
      for window in windowScene.windows where window.isKeyWindow {
        return window
      }
    }
    return nil
  }
#elseif os(macOS)
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
  #else
  func asImage() -> UIImage? {
    return nil
  }
  #endif
}
