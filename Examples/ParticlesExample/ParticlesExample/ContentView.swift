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
  
  @State var velocity: CGVector = .init(dx: 1, dy: 1)
  @State var acceleration: CGVector = .zero
  @State var opacity: CGFloat = 1.0
  
  private let systemData = ParticleSystem.Data()
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      HStack {
        Button("Acc") {
          acceleration = .random(magnitude: 0.05)
        }
      }
      Confetti.System().rainFromTop()
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
