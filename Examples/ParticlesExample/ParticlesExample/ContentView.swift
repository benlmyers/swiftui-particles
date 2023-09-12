//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import PresetParticles

struct ContentView: View {
  
  @State var pause: Bool = false
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
