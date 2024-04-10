//
//  ContentView.swift
//  ParticlesExampleWatch Watch App
//
//  Created by Ben Myers on 4/10/24.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationSplitView {
      List {
        Text("Presets").font(.headline).foregroundStyle(.secondary)
        NavigationLink("Comet", destination: CometView.init)
        NavigationLink("Ghost Rider", destination: GhostRiderView.init)
        NavigationLink("Fire", destination: FireView.init)
        NavigationLink("Snow", destination: SnowView.init)
        NavigationLink("Smoke", destination: SmokeView.init)
        NavigationLink("Magic", destination: MagicView.init)
        NavigationLink("Rain", destination: RainView.init)
        NavigationLink("Stars", destination: StarsView.init)
        NavigationLink("Fireworks", destination: FireworksView.init)
      }
    } detail: {
      Text("Particles")
    }
    .preferredColorScheme(.dark)
  }
}

#Preview {
  ContentView()
}
