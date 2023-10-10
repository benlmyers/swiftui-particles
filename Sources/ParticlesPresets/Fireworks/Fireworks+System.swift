//
//  Fireworks+System.swift
//
//
//  Created by Ben Myers on 10/10/23.
//

import SwiftUI
import ParticlesCore

public extension Fireworks {
  
  struct System: View {
    
    public var body: some View {
      ParticleSystem {
        ParticlesCore.Emitter {
          Fireworks.Emitter()
            .startPosition(.center)
            .startVelocity(x: 0.0, y: -3.0)
            .acceleration(x: 0.0, y: 0.05)
            .fireRate(30.0)
            .start(\.velocity.dx, with: {
              .random(in: -3.0 ... 3.0)
            })
        }
      }
    }
    
    public init() {}
  }
}
