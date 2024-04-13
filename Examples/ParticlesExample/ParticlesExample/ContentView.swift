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
  
  @State var customization: Bool = true
  @State var debug: Bool = false
  
  var body: some View {
    NavigationSplitView {
      VStack(spacing: .zero) {
        List {
          Text("Presets").font(.headline).foregroundStyle(.secondary)
          ForEach(Preset.allDefaults, id: \.0) { d in
            NavigationLink(d.0, destination: d.1.demo(customization: customization, debug: debug))
          }
          NavigationLink("Lattice", destination: thumbnailView)
        }
        Spacer()
        Divider()
        ViewThatFits {
          HStack(spacing: 16.0) {
            settingsToggles
          }
          VStack {
            settingsToggles
          }
        }
        .padding()
      }
    } detail: {
      thumbnailView
    }
    .preferredColorScheme(.dark)
    .background(Color.black)
  }
  
  @ViewBuilder
  var settingsToggles: some View {
    Toggle("Preset Customization", isOn: $customization)
    Toggle("Debug Mode", isOn: $debug)
  }
  
  var thumbnailView: some View {
    ParticleSystem {
      Lattice(spacing: 4) {
        Text("Particles")
          .fontWeight(.black)
          .font(.system(size: 90))
          .foregroundStyle(Color.red)
      }
      .delay(with: { c in
        return Double(c.proxy.position.x) * 0.005 + Double.random(in: 0.0 ... 0.5)
      })
      .transition(.scale, on: .birth, duration: 1.0)
      .hueRotation(with: { c in
        return .degrees(c.proxy.position.x + 60 * (c.timeAlive + c.proxy.seed.0))
      })
      .glow(radius: 8)
      .scale(1.5)
      .lifetime(99)
      .zIndex(1)
      .fixVelocity { c in
          .init(dx: 0.1 * cos(6 * (c.timeAlive + c.proxy.seed.0)), dy: 0.1 * sin(6 * (c.timeAlive + c.proxy.seed.1)))
      }
    }
    .debug(debug)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
