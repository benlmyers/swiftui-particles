//
//  File.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

struct MovingModifier: AnimatableModifier {
  
  var time: CGFloat
  let path: Path
  let start: CGPoint
  
  var animatableData: CGFloat {
    get { time }
    set { time = newValue }
  }
  
  func body(content: Content) -> some View {
    content
      .position(
        path.trimmedPath(from: 0, to: time).currentPoint ?? start
      )
  }
}
