//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import ParticlesCore

struct ContentView: View {
  
  @State var canFire: Bool = true
  
  private let systemData = ParticleSystem.Data()
  
  var body: some View {
    VStack {
      TestView()
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
