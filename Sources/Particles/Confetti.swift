//
//  Confetti.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

public struct Confetti: Particle {
  
  // MARK: - Inherited Properties
  
  public var colors: [Color]?
  public var size: ParticleSize
  
  // MARK: - Public Initalizers
  
  /**
   A piece of confetti.
   
   - parameter colors: The colors of the confetti.
   - parameter size: The confetti's size.
   */
  public init(_ colors: [Color]? = nil, size: ParticleSize = .medium) {
    self.colors = colors
    self.size = size
  }
  
  /**
   A piece of confetti.
   
   - parameter colors: The colors of the confetti.
   - parameter size: The confetti's size.
   */
  public init(_ colors: Color..., size: ParticleSize = .medium) {
    self.init(colors, size: size)
  }
  
  /**
   A piece of confetti.
   
   - parameter color: The color of the confetti.
   - parameter size: The confetti's size.
   */
  public init(_ color: Color, size: ParticleSize = .medium) {
    self.init([color], size: size)
  }
  
  // MARK: - Inherited Methods
  
  public func body(_ animate: Binding<Bool>, duration: TimeInterval, delay: TimeInterval, forever: Bool) -> some View {
    Group {
      Group {
        if Bool.random() {
          Rectangle()
        } else {
          Circle()
        }
      }
      .frame(width: size, height: size)
      .rotationEffect(animate.wrappedValue ? .zero : .tau)
      .animation(.linear(duration: .random(in: 2.0 ... 8.0)).forever(forever, autoreverses: false).delay(delay), value: animate.wrappedValue)
      .rotation3DEffect(animate.wrappedValue ? .zero : .tau, axis: randomAxis())
      .animation(.linear(duration: .random(in: 1.0 ... 4.0)).forever(forever, autoreverses: false).delay(delay), value: animate.wrappedValue)
      .foregroundColor(colors?.randomElement()! ?? .white)
    }
  }
}
