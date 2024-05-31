//
//  Aura.swift
//
//
//  Created by Ben Myers on 5/29/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Aura: Entity, PresetEntry {
    
    internal var colors: [Color] = [.red, .yellow, .green]
    internal var size: CGFloat = 300.0
    
    public var body: some Entity {
      Emitter(every: 0.02) {
        ForEach(colors, merges: .none) { color in
          Particle {
            RadialGradient(colors: [color, Color.clear], center: .center, startRadius: 0.0, endRadius: size)
              .opacity(0.2)
          }
          .initialPosition { c in
            CGPoint(x: Int.random(in: 0 ... Int(c.system.size.width)), y: Int.random(in: 0 ... Int(c.system.size.height)))
          }
          .initialVelocity(xIn: -3.0 ... 3.0, yIn: -3.0 ... 3.0)
        }
      }
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Preset.Aura>)] {[
      ("Size", .floatRange(70.0, min: 30.0, max: 100.0), \.size)
    ]}
  }
}
