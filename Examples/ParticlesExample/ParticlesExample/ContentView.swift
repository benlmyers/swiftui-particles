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
  
  @State var explodes = false
  @State var p = false
  
  @State var colors: [Color] = [.blue, .red, .pink, .purple, .orange, .white, .cyan, .indigo, .teal, .mint, .green]
  var body: some View {
    NavigationSplitView {
//      List {
//        NavigationLink("Ghost Rider", destination: GhostRiderView.init)
//        NavigationLink("Fire", destination: FireView.init)
//        NavigationLink("Snow", destination: SnowView.init)
//        NavigationLink("Smoke", destination: SmokeView.init)
//        NavigationLink("Magic", destination: MagicView.init)
//        NavigationLink("Rain", destination: RainView.init)
//        NavigationLink("Stars", destination: StarsView.init)
//      }
    } detail: {
//      VStack {
//        ParticleSystem {
//          ForEach([1, 3, 4], merges: .views) { i in
//            Particle { Text("\(i)") }
//              .initialVelocity(withMagnitude: 1)
//              .initialPosition(.center)
//          }
//        }
//        .debug()
//        Text("Welcome to Particles")
//          .font(.title.bold())
//          .foregroundStyle(LinearGradient(colors: [.purple, .blue, .pink, .red, .yellow], startPoint: .leading, endPoint: .trailing))
//        Text("Choose a preset to get started.")
//        Button {
//          explodes = true
//        } label: {
//          Text("Explode!")
//            .font(.title3)
//        }
//      }
//      .dissolve(if: explodes)
      thumbnailView
    }
  }
  
  var thumbnailView: some View {
    ParticleSystem {
      Lattice(spacing: 4, size: CGSize(width: 4, height: 4)) {
        Text("Particles")
          .font(.system(size: 90))
          .foregroundStyle(Color.green)
      }
      .lifetime(99)
      ForEach(0..<40) { i in
        Particle {
          Circle()
            .frame(width: 8, height: 8)
        }
        .colorOverlay(colors[i % colors.count])
        .fixVelocity { context in
          let angle = Double(i) * (2 * Double.pi) / 40
          let speed = max(0.3, 2.5 / (max(context.timeAlive, 1)))
          let dx = speed * cos(angle)
          let dy = speed * sin(angle)
          if context.timeAlive > 3.0 {
            return .init(dx: 0, dy: 0)
          }
          return .init(dx: dx, dy: dy)
        }
      }
      .lifetime(99)
    }
    .debug()
  }

}
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
