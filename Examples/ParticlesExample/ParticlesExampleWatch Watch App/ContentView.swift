//
//  ContentView.swift
//  ParticlesExampleWatch Watch App
//
//  Created by Ben Myers on 4/10/24.
//

import SwiftUI
import Particles
import ParticlesPresets

struct ContentView: View {
  var body: some View {
    ScrollView {
      List {
        Section("Presets") {
          ForEach(Preset.allDefaults, id: \.0) { d in
            NavigationLink(d.0, destination: d.1.demo(customization: false, debug: false))
          }
        }
      }
    }
    .preferredColorScheme(.dark)
    .background(Color.black)
  }
}

#Preview {
  ContentView()
}
