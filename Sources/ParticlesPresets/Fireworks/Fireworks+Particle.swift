//
//  Fireworks+Particle.swift
//
//
//  Created by Ben Myers on 10/10/23.
//

import SwiftUI
import Particles
import ParticlesCore

public extension Fireworks {
  
  class TrailParticle: ParticlesCore.AdvancedParticle {
    
    public init() {
      super.init(from: AdvancedParticle(onDraw: { context in
        context.translateBy(x: -1.0, y: 1.0)
        context.fill(.square(radius: 2.0), with: .color(.yellow.opacity(0.7)))
      })
        .rotation(degrees: 45.0)
        .lifetime(2.0)
        .onUpdate(perform: { proxy in
          proxy.blendMode = .lighten
          proxy.blur = proxy.timeAlive * 3.0
          proxy.scaleEffect *= 1.01
          proxy.opacity *= 0.96
        })
      )
    }
  }
  
  class Emitter: ParticlesCore.Emitter {
    
    public init() {
      super.init(from: ParticlesCore.Emitter(entities: {
        TrailParticle()
      })
        .onUpdate(perform: { proxy in
          proxy.canFire = proxy.velocity.dy >= -2.0
        })
      )
    }
  }
  
  class BurstParticle: ParticlesCore.Particle {
    
  }
}
