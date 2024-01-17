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
//      Emitter {
        ForEach(in: [Color.red, .orange, .yellow, .green, .blue, .purple]) { color in
          Particle {
            Circle().foregroundColor(color).frame(width: 20.0, height: 20.0)
          }
        }
        .initialPosition(.center)
        .initialVelocity { context in
            .init(dx: .random(in: -1.0 ... 1.0), dy: .random(in: -1.0 ... 1.0))
        }
        .setAcceleration(y: 0.01)
//      }
//      .emitSingle()
    }
    .debug()
  }
}
