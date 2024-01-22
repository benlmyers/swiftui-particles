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
    VStack {
      Button("\(x)") { x += 1 }
      ParticleSystem {
        CrazyEmitter(x: x)
      }
      .statePersistent("1")
      .debug()
    }
  }
}

struct CrazyEmitter: Entity {
  
  let colors = [Color.red, .orange, .yellow, .green, .blue, .purple, .pink, .white]
  
  var x: Int
  
  var body: some Entity {
    Emitter(interval: 0.01) {
      ForEach(colors) { color in
        Particle {
          Circle().foregroundColor(color).frame(width: 10.0, height: 10.0)
        }
//        .hueRotation { c in
//          .degrees(c.render.hueRotation.degrees + 10)
//        }
        .lifetime(0.8)
        .initialVelocity { c in
          return .init(angle: .degrees(Double(x) * 20.0), magnitude: 1.0)
        }
        .initialAcceleration(y: 0.01)
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
