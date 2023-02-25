//
//  Emoji.swift
//  Particles
//
//  Created by Ben Myers on 2/24/23.
//

import SwiftUI
import Foundation

public struct Emoji: Particle {
  
  // MARK: - Inherited Properties
  
  public var emoji: String
  public var size: ParticleSize
  
  // MARK: - Public Initalizers
  
  /**
   An emoji.
   
   - parameter emoji: The emoji text.
   - parameter size: The confetti's size.
   */
  public init(_ emoji: String, size: ParticleSize = .medium) {
    self.emoji = emoji
    self.size = size
  }
  
  // MARK: - Inherited Methods
  
  public func body(_ animate: Binding<Bool>, duration: TimeInterval, delay: TimeInterval, forever: Bool) -> some View {
    Group {
      Text(emoji)
      .frame(width: size, height: size)
      .rotationEffect(animate.wrappedValue ? .zero : .tau)
      .animation(.linear(duration: .random(in: 2.0 ... 8.0)).forever(forever, autoreverses: false).delay(delay), value: animate.wrappedValue)
      .animation(.linear(duration: .random(in: 1.0 ... 4.0)).forever(forever, autoreverses: false).delay(delay), value: animate.wrappedValue)
    }
  }
}

