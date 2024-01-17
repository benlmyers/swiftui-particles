//
//  TestView.swift
//
//
//  Created by Ben Myers on 1/3/24.
//

import SwiftUI
import Particles
import Foundation

struct TestView: View {
  
  @State var x: Int = 1
  
  var body: some View {
    ParticleSystem {
      CrazyEmitter()
      Fire(color: .red)
    }
    .debug()
  }
}

struct CrazyEmitter: Entity {
  
  let colors = [Color.red, .orange, .yellow, .green, .blue, .purple, .pink, .white]
  
  var body: some Entity {
    Emitter(interval: 0.02) {
      ForEach(colors) { color in
        Particle {
          Circle().foregroundColor(color).frame(width: 10.0, height: 10.0)
        }
        .hueRotation { c in
          .degrees(c.render.hueRotation.degrees + 10)
        }
        .lifetime(0.8)
        .initialVelocity { c in
          return .init(angle: .degrees(Double(c.system.proxiesSpawned) * 8.0), magnitude: 1.0)
        }
      }
    }
    .emitSingle()
    .setPosition(.center)
  }
}

struct Fire: Entity {
  
  let color: Color
  
  var body: some Entity {
    Emitter(interval: 0.4) {
      particle
    }
    .setPosition(.center)
  }
  
  var particle: some Entity {
    Particle {
      Circle().foregroundColor(color).frame(width: 10.0, height: 10.0)
    }
    .setPosition({ c in
      return CGPoint(x: c.physics.position.x + 0.6 * cos(Double(c.physics.inception) * 0.6 + 5.0 * c.system.time), y: c.physics.position.y)
    })
    .hueRotation({ _ in
      .random(degreesIn: -50.0 ... 50.0)
    })
    .initialVelocity(y: -1)
    .blur(4.0)
    .setScale { c in
      3.0 * sin(Double(c.system.time) * 0.3 + Double(c.physics.inception))
    }
  }
}
