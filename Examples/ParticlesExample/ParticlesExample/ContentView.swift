//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import ParticlesPresets

struct ContentView: View {
  
  var body: some View {
    ParticleSystem {
      Burst {
        Text("Hello, World!").font(.title).bold()
      } withBehavior: { e in
        e.initialVelocity(xIn: -0.5 ... 0.5, yIn: -0.5 ... 0.5)
      }

//      Emitter {
//        Particle {
//          Circle().frame(width: 30.0, height: 30.0).foregroundColor(.orange)
//        }
//        .initialPosition(.center)
//        .initialVelocity(y: 0.3)
//        .colorOverlay(.red)
//      }
//      Preset.Fire()
//      Burst {
//        RadialGradient(colors: [.red, .clear], center: .center, startRadius: 2.0, endRadius: 12.0)
//          .clipShape(Circle())
//          .frame(width: 90.0, height: 90.0)
//      }
    }
    .debug()
    .background(Color.black)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
