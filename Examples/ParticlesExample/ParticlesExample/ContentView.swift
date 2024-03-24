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
    NavigationSplitView {
      List {
        NavigationLink("Ghost Rider", destination: GhostRiderView.init)
        NavigationLink("Fire", destination: FireView.init)
        NavigationLink("Snow", destination: SnowView.init)
        NavigationLink("Smoke", destination: SmokeView.init)
        NavigationLink("Magic", destination: MagicView.init)
        NavigationLink("Rain", destination: RainView.init)
        NavigationLink("Stars", destination: StarsView.init)
      }
    } detail: {
      VStack {
        Text("Welcome to Particles")
          .font(.title.bold())
          .foregroundStyle(LinearGradient(colors: [.purple, .blue, .pink, .red, .yellow], startPoint: .leading, endPoint: .trailing))
        Text("Choose a preset to get started.")
        Button {
          explodes = true
        } label: {
          Text("Explode!")
            .font(.title3)
        }

      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
