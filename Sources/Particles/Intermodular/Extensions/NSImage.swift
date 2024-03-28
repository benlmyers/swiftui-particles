//
//  NSImage.swift
//
//
//  Created by Demirhan Mehmet Atabey on 23.01.2024.
//

#if os(macOS)
import AppKit

internal extension NSImage {
  var cgImage: CGImage? {
    return cgImage(forProposedRect: nil,
                   context: nil,
                   hints: nil)
  }
}
#endif
