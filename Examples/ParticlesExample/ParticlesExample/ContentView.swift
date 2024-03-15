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
  
  var body: some View {
    ParticleSystem {
//      Preset.Fire()
      Burst(v: {
        RadialGradient(colors: [.red, .clear], center: .center, startRadius: 2.0, endRadius: 12.0)
          .clipShape(Circle())
          .frame(width: 90.0, height: 90.0)
      })
    }
    .debug()
    .background(Color.black)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
