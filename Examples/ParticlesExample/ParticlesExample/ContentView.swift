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
  
  @State var x: Bool = true
  
  var body: some View {
    Button("Switch") {
      
      x.toggle()
    }
    .padding()
    VStack {
      ParticleSystem {
        Emitter {
          Particle { EmptyView() }
        }
        .fixPosition(.center)
//        if x {
//          Preset.Fire()
//        } else {
//          Preset.Rain()
//        }
      }
      .statePersistent("1")
      .debug()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
