//
//  Confetti+System.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import Particles
import ParticlesCore

public extension Confetti {
  
  struct System: View {
    
    private var source: UnitPoint
    private var colors: [Color]
    private var size: Confetti.Particle.Size
    
    private var fireVelocity: () -> CGVector = { .random(magnitude: 5.0, degreesIn: 180.0 ... 360.0) }
    private var rain: Bool = false
    
    public var body: some View {
      ParticleSystem {
        Emitter {
          Confetti.Particle(shape: .circle, size: size)
            .onBirth { proxy, _ in
              if rain {
                proxy.position.x = proxy.systemData!.systemSize.width * CGFloat.random(in: 0.0 ... 1.0)
              }
              proxy.colorOverlay = colors.randomElement()!
            }
          Confetti.Particle(shape: .square, size: size)
            .onBirth { proxy, _ in
              if rain {
                proxy.position.x = proxy.systemData!.systemSize.width * CGFloat.random(in: 0.0 ... 1.0)
              }
              proxy.colorOverlay = colors.randomElement()!
            }
          Confetti.Particle(shape: .rectangle, size: size)
            .onBirth { proxy, _ in
              if rain {
                proxy.position.x = proxy.systemData!.systemSize.width * CGFloat.random(in: 0.0 ... 1.0)
              }
              proxy.colorOverlay = colors.randomElement()!
            }
        }
        .startPosition(source)
        .fireRate(30.0)
      }
    }
    
    public init(source: UnitPoint = .center, colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple], size: Confetti.Particle.Size = .medium) {
      self.source = source
      self.colors = colors
      self.size = size
    }
    
    public func rainFromTop() -> Self {
      var copy = self
      copy.source = UnitPoint(x: 0.5, y: -0.05)
      copy.fireVelocity = { .zero }
      copy.rain = true
      return copy
    }
  }
}
