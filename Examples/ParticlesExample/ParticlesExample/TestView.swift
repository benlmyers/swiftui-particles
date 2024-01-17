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
  
  @State var x: Int = 1
  
  var body: some View {
    ParticleSystem {
      Emitter {
        Particle {
          Circle().foregroundColor(.red).frame(width: 20.0, height: 20.0)
        }
        .initialPosition(x: 100, y: 100)
        .initialVelocity(y: 0.5)
      }
    }
  }
}
