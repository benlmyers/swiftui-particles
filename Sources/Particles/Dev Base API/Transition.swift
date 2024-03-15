//
//  Transition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import SwiftUI
import Foundation

public protocol Transition {
  func modifyRender(progress: Double, context: inout GraphicsContext)
}

public enum TransitionBounds {
  case birth
  case death
  case birthAndDeath
}
