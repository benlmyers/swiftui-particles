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
    
    var color: Color
    var width: CGFloat
    
    public var body: some Entity {
      Emitter(interval: 0.5) {
        Particle {
          Image("flame", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: width)
        }
        .initialPosition(.center)
        .opacity(0.5)
        .blendMode(.colorDodge)
        .onUpdate(perform: { physics, render, system in
          physics.position.x += 0.010 * width * cos(system.time + Double(system.proxiesSpawned))
          physics.position.y += 0.008 * width * sin(system.time + Double(system.proxiesSpawned))
        })
      }
    }
    
    public init(color: Color = .red, width: CGFloat = 40.0) {
      self.color = color
      self.width = width
    }
  }
}

