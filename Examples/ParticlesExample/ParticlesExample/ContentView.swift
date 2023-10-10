//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import ParticlesCore
import ParticlesPresets

struct ContentView: View {
  
  @State var canFire: Bool = true
  
  private let systemData = ParticleSystem.Data()
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      HStack {
        Toggle("Fire", isOn: $canFire)
      }
//      Confetti.System(data: systemData).rainFromTop().canFire($canFire)
      Fireworks.System()
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
