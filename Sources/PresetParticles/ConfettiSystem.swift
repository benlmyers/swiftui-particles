//
//  ConfettiSystem.swift
//  
//
//  Created by Ben Myers on 7/20/23.
//

import SwiftUI
import Particles

public struct ConfettiSystem: View {
  
  public var body: some View {
    ParticleSystem {
      Field(bounds: .all, effect: .gravity(.init(dx: 0.0, dy: 0.02)))
      Emitter(rate: 100.0) {
        Particle {
          Rectangle()
            .frame(width: 10.0, height: 5.0)
            .foregroundColor(.red)
        }
        .lifetime(6.0)
        .initialRotation(.random(in: .degrees(0.0) ... .degrees(360.0)))
        .initialTorque(.constant(.degrees(1.0)))
        .initialFlip(.random(in: .degrees(0.0) ... .degrees(360.0)))
        .initialFlipTorque(.degrees(3.0))
        .floatDownward(speed: 3.0)
      }
      .emitVelocity(x: .random(in: -2.0...2.0), y: .constant(-2.0))
      .stopAfter(numberEmitted: 5000)
      .initialPosition(.center)
      .ignoreFields(true)
      
    }
  }
  
  public init() {}
}
