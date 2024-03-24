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
  
  var body: some View {
    
    VStack {
      ParticleSystem {
        Emitter(every: 0.001) {
          
          Particle {
            Text("🤣")
          }
          .initialPosition(.center)
          .initialVelocity(xIn: -0.2 ... 0.2, yIn: -0.2 ... 0.2)
          .fixTorque(.degrees(0.1))
          .lifetime(99)
        }
      }
      .debug()
    }
  }
    
//    NavigationSplitView {
//      List {
//        NavigationLink("Ghost Rider", destination: GhostRiderView.init)
//        NavigationLink("Fire", destination: FireView.init)
//        NavigationLink("Snow", destination: SnowView.init)
//        NavigationLink("Smoke", destination: SmokeView.init)
//        NavigationLink("Magic", destination: MagicView.init)
//        NavigationLink("Rain", destination: RainView.init)
//        NavigationLink("Stars", destination: StarsView.init)
//      }
//    } detail: {
//      VStack {
//        Text("Welcome to Particles")
//          .font(.title.bold())
//          .foregroundStyle(LinearGradient(colors: [.purple, .blue, .pink, .red, .yellow], startPoint: .leading, endPoint: .trailing))
//          .explode(if: explodes)
//          .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//              explodes = true
//            }
//          }
//        Text("Choose a preset to get started.")
//      }
//    }
//  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
