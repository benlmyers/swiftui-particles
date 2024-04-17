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


struct CometView: View {
  
  @State var size: CGFloat = 20.0
  @State var intensity: Double = 20
  
  var body: some View {
    ParticleSystem {
      Group {
        Emitter(every: 14.0) {
          Particle {
            RadialGradient(
              colors: [Color.pink, Color.red],
              center: .center,
              startRadius: 0.0,
              endRadius: 10
            )
            .clipShape(Circle())
          }
          .hueRotation(angleIn: .degrees(0) ... .degrees(360))
          .lifetime(12)
          .glow(Color.red.opacity(0.5), radius: 40.0)
          .initialVelocity(x: 2, y: -2)
          .initialPosition { c in
            let pairs = [(-600, 500), (Int(c.system.size.width) - 600, Int(c.system.size.height) + 500)]
            let randomPair = pairs.randomElement()!
            return CGPoint(x: randomPair.0, y: randomPair.1)
          }
        }
        Stars()
        Preset.Comet()
      }
    }
  }
  
  struct Stars: Entity {
    public var body: some Entity {
      Emitter(every: 0.01) {
        Star()
      }
    }
    public struct Star: Entity {
      public var body: some Entity {
        Particle {
          Circle()
            .frame(width: 14.0, height: 14.0)
        }
        .initialPosition { c in
          let x = Int.random(in: 0 ... Int(c.system.size.width))
          let y = Int.random(in: 0 ... Int(c.system.size.height))
          return CGPoint(x: x, y: y)
        }
        .opacity { c in
          return 1.0 * (c.timeAlive)
        }
        .lifetime(in: 3.0 +/- 1.0)
        .scale(factorIn: 0.1 ... 0.6)
        .blendMode(.plusLighter)
        .initialVelocity(xIn: 0.2 ... 0.8, yIn: -0.5 ... 0.25)
        .fixAcceleration(x: 0.3, y: -0.3)
      }
    }
  }
}
