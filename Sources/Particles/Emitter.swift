//
//  Emitter.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation
import SwiftUI

public struct Emitter<P>: View where P: Particle {
  
  // MARK: - Properties
  
  let start: UnitPoint
  let end: UnitPoint
  var velocity: CGVector = .init(dx: 0.0, dy: 0.0)
  var duration: TimeInterval = 1.0
  var delay: TimeInterval = 0.0
  var volume: Int = 10
  var spread: Double = 0.1
  var interval: TimeInterval = 0.1
  var forever: Bool = true
  let particle: P
  let isEmitting: Binding<Bool>
  
  // MARK: - Private Properties
  
  var modifiedEnd: UnitPoint {
    return end.translated(by: .init(CGFloat.random(in: 0.0 ... CGFloat(spread)), angle: .random))
  }
  
  // MARK: - Body View
  
  public var body: some View {
    GeometryReader { proxy in
      ZStack {
        ForEach(1...volume, id: \.self) { i in
          ParticleView(particle: particle,
                       bounds: proxy.size,
                       start: start,
                       velocity: velocity,
                       end: modifiedEnd,
                       duration: duration,
                       forever: forever,
                       delay: interval * Double(i) + delay)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }
  }
  
  // MARK: - Public Initalizers
  
  /**
   A particle emitter.
   
   - parameter start: The point to emit particles from.
   - parameter end: The point for particles to travel to.
   - parameter particle: The particle to emit.
   */
  public init(from start: UnitPoint = .center,
              to end: UnitPoint = .topTrailing,
              isEmitting: Binding<Bool> = .constant(true),
              particle: @escaping () -> P
  ) {
    self.start = start
    self.end = end
    self.particle = particle()
    self.isEmitting = isEmitting
  }
}

public extension Emitter {
  
  // MARK: - Public Methods
  
  /**
   Change the emit velocity of emitted particles.
   
   - parameter x: The x-component of the particles' initial velocity.
   - parameter y: The y-component of the particles' initial velocity.
   */
  func emitVelocity(x: CGFloat, y: CGFloat) -> Emitter {
    var copy = self
    copy.velocity = .init(dx: x, dy: y)
    return copy
  }
  
  /**
   Emits a certain amount of particles once.
   
   - parameter volume: The amount to emit.
   */
  func emitOnce(amount volume: Int) -> Emitter {
    var copy = self
    copy.forever = false
    copy.volume = volume
    return copy
  }
  
  /**
   Emits particles forever.
   
   - parameter intensity: The amount of particles to emit repeatedly.
   */
  func emitForever(intensity volume: Int) -> Emitter {
    var copy = self
    copy.forever = true
    copy.volume = volume
    return copy
  }
  
  /**
   Sets the lifetime of emitted particles.
   
   - parameter duration: The duration of each particle's life.
   */
  func particleLifetime(_ duration: TimeInterval) -> Emitter {
    var copy = self
    copy.duration = duration
    return copy
  }
  
  /**
   Sets how far particles can spread.
   
   - parameter value: The amount particles can spread.
   */
  func emitSpread(_ value: Double) -> Emitter {
    var copy = self
    copy.spread = value
    return copy
  }
  
  /**
   Delays the emitter's animation.
   
   - parameter value: The delay to apply.
   */
  func emitDelay(_ value: TimeInterval) -> Emitter {
    var copy = self
    copy.delay = value
    return copy
  }
  
  /**
   Bursts the particles at a specified rate.
   
   - parameter rate: The rate to emit particles at.
   */
  func emitRate(_ rate: ParticleEmitRate) -> Emitter {
    var copy = self
    copy.interval = rate
    return copy
  }
}
