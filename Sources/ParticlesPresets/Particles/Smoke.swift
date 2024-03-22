//
//  Smoke.swift
//
//
//  Created by Demirhan Mehmet Atabey on 22.03.2024.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Smoke: Entity, PresetEntry {
    
    var metadata: PresetMetadata {
      .init(
        name: "Smoke",
        target: "ParticlesPresets",
        description: "Infuse your SwiftUI views with swirling smoke effects.",
        author: "grandsir",
        version: 1
      )
    }
    
    var color: Color
    var startRadius: CGFloat =  8.0
    var endRadius: CGFloat = 30.0
    var spawnPoint: UnitPoint
    var spawnRadius: CGSize
    var dirty: Bool = false
    
    private var velocityX: ClosedRange<CGFloat> {
      switch spawnPoint {
      case .bottomLeading, .leading, .topLeading:
        return -0.6 ... -0.3
      case .topTrailing, .bottomTrailing, .trailing:
        return 0.3 ... 0.6
      default:
        return 0 ... 0
      }
    }
    
    private var velocityY: ClosedRange<CGFloat> {
      switch spawnPoint {
      case .bottomLeading, .bottomTrailing, .bottom:
        return 0.1 ... 0.3
      case .leading, .trailing:
        return 0 ... 0
      default:
        return -0.3 ... 0.1
      }
    }

    private var velocityAccelerationY: CGFloat {
      switch spawnPoint {
      case .bottom, .bottomLeading, .bottomTrailing:
        return 0.002
      case .leading, .trailing:
        return 0
      default:
        return -0.002
      }
    }
    
    public var body: some Entity {
      Emitter(every: 0.01) {
        Particle {
          RadialGradient(
            colors: [color, .clear],
            center: .center,
            startRadius: startRadius,
            endRadius: endRadius
          )
          .clipShape(Circle())
        }
        .initialPosition(.center)
        .initialOffset(xIn: -spawnRadius.width ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialVelocity(xIn: velocityX, yIn: velocityY)
        .fixAcceleration(y: velocityAccelerationY)
        .lifetime(in: 3 +/- 0.2)
        .blendMode(dirty ? .hardLight : .normal)
        .transition(.scale, on: .death, duration: 0.5)
        .transition(.opacity, on: .birth)
        .opacity(0.3)
      }
    }
    
    public init(
      color: Color = Color(red: 128/255, green: 128/255, blue: 128/255, opacity: 1),
      dirty: Bool = false,
      spawnPoint: UnitPoint = .center,
      startRadius: CGFloat =  12.0,
      endRadius: CGFloat = 35.0,
      spawnRadius: CGSize = .init(width: 40.0, height: 8.0)
    ) {
      self.dirty = dirty
      self.color = color
      self.spawnPoint = spawnPoint
      self.startRadius = startRadius
      self.endRadius = endRadius
      self.spawnRadius = spawnRadius
    }
  }
}
