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
  
  @State private var debug: Bool = false
  
  var body: some View {
    NavigationSplitView {
      VStack(spacing: .zero) {
        List {
          Section("Presets") {
            ForEach(Preset.allDefaults, id: \.0) { d in
              NavigationLink(d.0, destination: d.1.demo(customization: customization, debug: debug))
            }
          }
          Section("Demos") {
            NavigationLink("Space Comet", destination: SpaceCometDemo())
            NavigationLink("Lattice", destination: LatticeDemo())
            NavigationLink("Hugging Lattice", destination: HuggingLatticeDemo())
            NavigationLink("Fireplace", destination: FireplaceDemo())
          }
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
      LatticeDemo()
    }
    .preferredColorScheme(.dark)
    .background(Color.black)
    .environment(\.debug, debug)
  }
  
  @ViewBuilder
  var settingsToggles: some View {
    Toggle("Preset Customization", isOn: $customization)
    Toggle("Debug Mode", isOn: $debug)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

//struct CometView: View {
//  
//  @State var size: CGFloat = 20.0
//  @State var intensity: Double = 20
//  
//  var body: some View {
//    ParticleSystem {
//      Group {
//        Emitter(every: 14.0) {
//          Particle {
//            RadialGradient(
//              colors: [Color.pink, Color.red],
//              center: .center,
//              startRadius: 0.0,
//              endRadius: 10
//            )
//            .clipShape(Circle())
//          }
//          .hueRotation(angleIn: .degrees(0) ... .degrees(360))
//          .lifetime(12)
//          .glow(Color.red.opacity(0.5), radius: 40.0)
//          .initialVelocity(x: 2, y: -2)
//          .initialPosition { c in
//            let pairs = [(-600, 500), (Int(c.system.size.width) - 600, Int(c.system.size.height) + 500)]
//            let randomPair = pairs.randomElement()!
//            return CGPoint(x: randomPair.0, y: randomPair.1)
//          }
//        }
//        Stars()
//        Preset.Comet()
//      }
//    }
//  }
//  
//  struct Stars: Entity {
//    public var body: some Entity {
//      Emitter(every: 0.01) {
//        Star()
//      }
//    }
//    public struct Star: Entity {
//      public var body: some Entity {
//        Particle {
//          Circle()
//            .frame(width: 14.0, height: 14.0)
//        }
//        .initialPosition { c in
//          let x = Int.random(in: 0 ... Int(c.system.size.width))
//          let y = Int.random(in: 0 ... Int(c.system.size.height))
//          return CGPoint(x: x, y: y)
//        }
//        .opacity { c in
//          return 1.0 * (c.timeAlive)
//        }
//        .lifetime(in: 3.0 +/- 1.0)
//        .scale(factorIn: 0.1 ... 0.6)
//        .blendMode(.plusLighter)
//        .initialVelocity(xIn: 0.2 ... 0.8, yIn: -0.5 ... 0.25)
//        .fixAcceleration(x: 0.3, y: -0.3)
//      }
//    }
//  }
//}

struct DebugEnvironmentKey: EnvironmentKey {
  static let defaultValue: Bool = false
}

extension EnvironmentValues {
  var debug: Bool {
    get { self[DebugEnvironmentKey.self] }
    set { self[DebugEnvironmentKey.self] = newValue }
  }
}
