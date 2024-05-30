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
    
    public var colors: [Color] = [.red, .yellow, .green]
    
    public var body: some Entity {
      Emitter {
        Particle(view: { EmptyView() })
      }
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Preset.Aura>)] {[]}
  }
}
