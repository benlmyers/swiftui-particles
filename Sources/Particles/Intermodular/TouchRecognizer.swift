//
//  TouchRecognizer.swift
//
//
//  Created by Ben Myers on 4/10/24.
//

#if os(iOS)

import UIKit
import Foundation
import SwiftUI

private class NFingerGestureRecognizer: UIGestureRecognizer {
  
  var tappedCallback: (UITouch, CGPoint?) -> Void
  
  var touchViews = [UITouch:CGPoint]()
  
  init(target: Any?, tappedCallback: @escaping (UITouch, CGPoint?) -> ()) {
    self.tappedCallback = tappedCallback
    super.init(target: target, action: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let location = touch.location(in: touch.view)
      // print("Start: (\(location.x)/\(location.y))")
      touchViews[touch] = location
      tappedCallback(touch, location)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let newLocation = touch.location(in: touch.view)
      // let oldLocation = touchViews[touch]!
      // print("Move: (\(oldLocation.x)/\(oldLocation.y)) -> (\(newLocation.x)/\(newLocation.y))")
      touchViews[touch] = newLocation
      tappedCallback(touch, newLocation)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      // let oldLocation = touchViews[touch]!
      // print("End: (\(oldLocation.x)/\(oldLocation.y))")
      touchViews.removeValue(forKey: touch)
      tappedCallback(touch, nil)
    }
  }
  
}

internal struct TouchRecognizer: UIViewRepresentable {
  
  var tappedCallback: (UITouch, CGPoint?) -> Void
  
  func makeUIView(context: UIViewRepresentableContext<TouchRecognizer>) -> TouchRecognizer.UIViewType {
    let v = UIView(frame: .zero)
    let gesture = NFingerGestureRecognizer(target: context.coordinator, tappedCallback: tappedCallback)
    v.addGestureRecognizer(gesture)
    return v
  }
  
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<TouchRecognizer>) {
    // empty
  }
  
}

#endif
