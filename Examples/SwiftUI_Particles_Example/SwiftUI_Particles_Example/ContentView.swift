//
//  ContentView.swift
//  SwiftUI_Particles_Example
//
//  Created by Ben Myers on 6/22/22.
//

import SwiftUI
import Particles

struct ContentView: View {
  
  // MARK: - Body View
  
  var body: some View {
    ZStack {
      Circle().frame(width: 5.0)
      Emitter {
        Confetti(.rainbow)
      }
      .emitVelocity(x: 100.0, y: -100.0)
      .emitForever(intensity: 20)
      .particleLifetime(0.75)
      .emitSpread(0.4)
      Text("🎉").font(.title)
    }
    .border(.gray)
    .frame(width: 300.0, height: 300.0)
  }
}
