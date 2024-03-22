//
//  View+BoundlessOverlay.swift
//
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI

public extension View {
  
  /// Applies a boundless overlay to the view.
  /// - Parameter atop: Whether the overlay view goes on top or under the source view.
  /// - Parameter overlay: The view to overlay. This can extend the bounds of the base view without affecting the size of its frame.
  func boundlessOverlay<V>(atop: Bool = true, minSize: CGSize = .zero, @ViewBuilder overlay: () -> V) -> some View where V: View {
    BoundlessOverlayWrapper(atop: atop, minSize: minSize, content: { self }, overlay: overlay)
  }
}

fileprivate struct BoundlessOverlayWrapper<Content, Overlay>: View where Content: View, Overlay: View {
  
  @State private var contentSize: CGSize?
  
  var content: Content
  var overlay: Overlay
  var atop: Bool
  var minSize: CGSize
  
  var body: some View {
    ZStack {
      if atop {
        c
        o
      } else {
        o
        c
      }
    }
    .frame(width: contentSize?.width, height: contentSize?.height)
  }
  
  var c: some View {
    content
      .background {
        GeometryReader { proxy in Color.clear.onAppear { contentSize = proxy.size } }
      }
  }
  
  var o: some View {
    overlay
      .frame(minWidth: minSize.width, minHeight: minSize.height)
  }
  
  init(atop: Bool = true, minSize: CGSize = .zero, @ViewBuilder content: () -> Content, @ViewBuilder overlay: () -> Overlay) {
    self.content = content()
    self.overlay = overlay()
    self.minSize = minSize
    self.atop = atop
  }
}
