//
//  NSImage.swift
//
//
//  Created by Demirhan Mehmet Atabey on 23.01.2024.
//

#if os(macOS)
import AppKit

extension NSImage {
  var cgImage: CGImage? {
    var proposedRect = CGRect(origin: .zero, size: size)
    
    return cgImage(forProposedRect: &proposedRect,
                   context: nil,
                   hints: nil)
  }
}
#endif
