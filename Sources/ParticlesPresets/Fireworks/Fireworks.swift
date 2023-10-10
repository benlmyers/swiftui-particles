//
//  Fireworks.swift
//
//
//  Created by Ben Myers on 10/10/23.
//

import SwiftUI
import ParticlesCore

public struct Fireworks: Extension {

  public var name: String = "Fireworks"
  public var description: String = "An extension used to create fun firework particle effects."
  public var author: String = "Particles"
  
  public var example: some View {
    Fireworks.System()
  }
}
