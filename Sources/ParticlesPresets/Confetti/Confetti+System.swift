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
    private var color: Color
    private var size: Confetti.Particle.Size
    
    private var fireVelocity: () -> CGVector = { .random(magnitude: 5.0, degreesIn: 180.0 ... 360.0) }
    private var rain: Bool = false
    
    public var body: some View {
      ParticleSystem {
        Emitter {
          Confetti.Particle(color: color, shape: .circle, size: size)
            .onBirth { proxy, _ in
              if rain {
                proxy.position.x = proxy.systemData!.systemSize.width * CGFloat.random(in: -1.0 ... 1.0)
              }
            }
          Confetti.Particle(color: color, shape: .square, size: size)
            .onBirth { proxy, _ in
              if rain {
                proxy.position.x = proxy.systemData!.systemSize.width * CGFloat.random(in: -1.0 ... 1.0)
              }
            }
          Confetti.Particle(color: color, shape: .rectangle, size: size)
            .onBirth { proxy, _ in
              if rain {
                proxy.position.x = proxy.systemData!.systemSize.width * CGFloat.random(in: -1.0 ... 1.0)
              }
            }
        }
        .startPosition(source)
        .fireRate(30.0)
      }
    }
    
    public init(source: UnitPoint = .center, color: Color = .red, size: Confetti.Particle.Size = .medium) {
      self.source = source
      self.color = color
      self.size = size
    }
    
    public func rainFromTop() -> Self {
      var copy = self
      copy.source = .top
      copy.fireVelocity = { .zero }
      copy.rain = true
      return copy
    }
  }
}
