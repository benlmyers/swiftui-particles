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
  @State var purchased = false
  var body: some View {
    NavigationSplitView {
      List {
        Text("Presets").font(.headline).foregroundStyle(.secondary)
        ForEach(Preset.allDefaults, id: \.0) { preset in
          NavigationLink(String(describing: type(of: preset.1)).capitalized, destination: AnyView(preset.1.demo))
        }
      }
    } detail: {
      thumbnailView
    }
//    VStack {
//      Text(purchased ? "Thank you!" : "")
//        .emits(every: 0.1, if: purchased, offset: CGPoint(x: 0, y: -20)) {
//          Particle { Text("❤️") }
//            .fixAcceleration(y: 0.05)
//            .initialVelocity(xIn: -2.0 ... 2.0, yIn: -2.0 ... -1.5)
//            .transition(.scale)
//        }
//      Button("Purchase") {
//        purchased = true
//      }
//      .dissolve(if: purchased)
//    }
//    .frame(height: 300)
  }
  
  var thumbnailView: some View {
    ParticleSystem {
      Lattice(spacing: 4) {
        Text("Particles")
          .fontWeight(.black)
          .font(.system(size: 90))
          .foregroundStyle(Color.red)
      }
      .hueRotation(with: { c in
        return .degrees(c.proxy.position.x + 60 * (c.timeAlive + c.proxy.seed.0))
      })
      .glow(radius: 4)
      .scale(1.5)
      .lifetime(99)
      .fixVelocity { c in
          .init(dx: 0.1 * cos(6 * (c.timeAlive + c.proxy.seed.0)), dy: 0.1 * sin(6 * (c.timeAlive + c.proxy.seed.1)))
      }
      Emitter(every: 0.01) {
        Particle {
          Circle()
            .frame(width: 5, height: 5)
            .foregroundStyle(.red)
        }
        .hueRotation(angleIn: .zero ... .degrees(360))
        .glow(radius: 5)
        .transition(.opacity, on: .birth, duration: 1.0)
        .initialOffset(y: -150.0)
        .transition(.twinkle, on: .death, duration: 4.0)
        .fixVelocity { c in
          let t: Double = c.timeAlive * ((2.0 + 0.5 * c.proxy.seed.0) /*+ c.proxy.seed.1 * 2 * .pi*/)
          return CGVector(dx: 15 * cos(t + 0.1 * c.proxy.seed.2), dy: 10 * sin(t - 0.6))
        }
      }
    }
    .debug()
  }

}
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
