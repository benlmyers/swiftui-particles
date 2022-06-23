//
//  Particle.swift
//  
//
//  Created by Ben Myers on 6/17/22.
//

import SwiftUI
import Foundation

public protocol Particle {
  
  associatedtype V: View
  
  // MARK: - Properties

  /// The color of the particle.
  var colors: [Color]? { get set }
  /// The size of the particle.
  var size: ParticleSize { get set }
  
  // MARK: - Methods
  
  /**
   The particle's view.
   
   - parameter animate: Whether the animation flag is active.
   */
  func body(_ animate: Binding<Bool>, duration: TimeInterval, delay: TimeInterval, forever: Bool) -> V
}
