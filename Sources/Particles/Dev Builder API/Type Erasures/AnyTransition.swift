//
//  AnyTransition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import SwiftUI
import Foundation

/// A type-erased ``Transition`` struct.
public struct AnyTransition {
  
  internal private(set) var modifyRender: (Double, PhysicsProxy.Context, inout GraphicsContext) -> Void
  
  public init<T>(_ transition: T) where T: Particles.Transition {
    self.modifyRender = transition.modifyRender
  }
}
