//
//  Fire.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Fire: Entity, PresetEntry {
    
    var metadata: PresetMetadata {
      .init(
        name: "Fire",
        target: "ParticlesPresets",
        description: "Heat up your SwiftUI views with fire particles.",
        author: "benlmyers"
      )
    }
    
    var colors: [Color]
    var spawnWidth: CGFloat
    
    public var body: some Entity {
      Emitter {
        Particle {
          Text("hi")
//          Image(packageResource: "flame", ofType: "png")
        }
        .initialVelocity(y: -0.1)
        .initialPosition(.center)
      }
    }
    
    public init(colors: [Color] = [.red, .orange, .yellow], spawnWidth: CGFloat = 5.0) {
      self.colors = colors
      self.spawnWidth = spawnWidth
    }
  }
}

