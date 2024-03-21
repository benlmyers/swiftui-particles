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
    ZStack {
      ParticleSystem {
        Burst(maxSpawns: 100) {
          v
        } withBehavior: { p in
          p
        } customView: {
          Rectangle().frame(width: 3.0, height: 3.0)
        }
        .initialOffset(y: 50.0)
      }
      .debug()
      ZStack(alignment: .topLeading) {
        Color.black
        v.offset(y: 50.0)
      }
      .opacity(0.1)
    }
    .frame(width: 400.0, height: 300.0)
  }
  
  var v: some View {
    Text("Hello, Demi!")
      .font(.system(size: 48))
      .fontWeight(.black)
      .foregroundStyle(LinearGradient(colors: [.red, .yellow, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
