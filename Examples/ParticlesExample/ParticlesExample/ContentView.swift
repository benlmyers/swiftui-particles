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
    NavigationSplitView {
      List {
        Text("Presets").font(.headline).foregroundStyle(.secondary)
        NavigationLink("Ghost Rider", destination: GhostRiderView.init)
        NavigationLink("Fire", destination: FireView.init)
        NavigationLink("Snow", destination: SnowView.init)
        NavigationLink("Smoke", destination: SmokeView.init)
        NavigationLink("Magic", destination: MagicView.init)
        NavigationLink("Rain", destination: RainView.init)
        NavigationLink("Stars", destination: StarsView.init)
        NavigationLink("Fireworks", destination: FireworksView.init)
        NavigationLink("Lattice", destination: thumbnailView)
      }
    } detail: {
      thumbnailView
    }
    .preferredColorScheme(.dark)
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
