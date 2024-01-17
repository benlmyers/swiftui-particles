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
        .initialVelocity { c in
          return .init(angle: .degrees(Double(c.system.proxiesSpawned) * 8.0), magnitude: 2.0)
        }
      }
    }
    .emitSingle()
    .setPosition(.center)
  }
}
