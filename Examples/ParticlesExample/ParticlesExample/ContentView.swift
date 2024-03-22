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
  
  @State var explodes = false
  
  var body: some View {
    NavigationSplitView {
      List {
        NavigationLink("Ghost Rider", destination: GhostRiderView.init)
        NavigationLink("Fire", destination: FireView.init)
        NavigationLink("Snow", destination: SnowView.init)
        NavigationLink("Smoke", destination: SmokeView.init)
      }
    } detail: {
      Text("Welcome to Particles")
        .font(.title.bold())
        .foregroundStyle(LinearGradient(colors: [.purple, .blue, .pink, .red, .yellow], startPoint: .leading, endPoint: .trailing))
        .frame(width: 900, height: 900, alignment: .center)
        .explode(if: explodes)
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            explodes = true
          }
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
