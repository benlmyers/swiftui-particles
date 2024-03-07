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
        author: "benlmyers",
        version: 1
      )
    }
    
    var color: Color
    var spawnPoint: UnitPoint
    var spawnRadius: CGSize
    
    public var body: some Entity {
      Emitter(interval: 0.1) {
        Particle {
          Image("circle", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 10.0, height: 10.0)
            .foregroundColor(.yellow)
        }
        .initialPosition(.center)
        .opacity(0.5)
        .blendMode(.screen)
      }
    }
    
    public init(color: Color = .yellow, spawnPoint: UnitPoint = .center, spawnRadius: CGSize = .init(width: 50.0, height: 4.0)) {
      self.color = color
      self.spawnPoint = spawnPoint
      self.spawnRadius = spawnRadius
    }
  }
}

