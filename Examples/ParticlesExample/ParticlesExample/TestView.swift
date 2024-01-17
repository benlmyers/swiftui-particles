//
//  TestView.swift
//
//
//  Created by Ben Myers on 1/3/24.
//

import SwiftUI
import Foundation
import Particles

struct TestView: View {
  
  @State var x: Int = 0
  
  var body: some View {
    VStack {
      Text("Test")
      Button("\(x)", action: { x += 1 })
      ParticleSystem {
        Particle {
          Text("Test")
        }
        .initialPosition(x: 100.0, y: 100.0)
      }
      .debug()
    }
  }
}
